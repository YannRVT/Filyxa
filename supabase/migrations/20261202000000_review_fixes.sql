-- Filyxa — Corrections issues de la relecture des phases 15 à 25.
--
-- 1. Livraison : « Livré » ne s'atteint que par deliver_model (déduction du stock
--    confirmée), une seule fois, depuis un statut ni livré ni abandonné.
-- 2. Lignes de production : mètres obligatoires et numériques.
-- 3. Grilles de tailles : retirer une taille nettoie la taille de base, les
--    écarts propres et les quantités (nulles) qui y renvoyaient.
-- 4. has_pro ne renseigne que sur les organisations dont on est membre.

-- 1. Livraison --------------------------------------------------------------------------------

create or replace function public.models_status_guard()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  if tg_op = 'INSERT' then
    if new.status <> 'idea' and not public.has_pro(new.org_id) then
      raise exception 'pro_required' using errcode = '42501';
    end if;
    if new.status = 'delivered' then
      raise exception 'invalid_status_transition' using errcode = '22023';
    end if;
    return new;
  end if;
  if new.status is distinct from old.status then
    if not public.has_pro(new.org_id) then
      raise exception 'pro_required' using errcode = '42501';
    end if;
    if old.status = 'delivered' then
      raise exception 'invalid_status_transition' using errcode = '22023';
    end if;
    -- « Livré » passe obligatoirement par deliver_model, qui déduit le stock.
    if new.status = 'delivered'
       and coalesce(current_setting('filyxa.delivering', true), '') <> new.id::text then
      raise exception 'invalid_status_transition' using errcode = '22023';
    end if;
  end if;
  return new;
end;
$$;

-- 2. Lignes de production : mètres présents, numériques et positifs.
create or replace function public.production_check(p_model uuid, p_lines jsonb)
returns uuid
language plpgsql
stable
security definer
set search_path = ''
as $$
declare
  v_org uuid;
begin
  select org_id into v_org from public.models where id = p_model;
  if v_org is null then
    raise exception 'model_not_found' using errcode = 'P0002';
  end if;
  if v_org not in (select public.my_org_ids('editor')) then
    raise exception 'forbidden' using errcode = '42501';
  end if;
  if not public.has_pro(v_org) then
    raise exception 'pro_required' using errcode = '42501';
  end if;
  if p_lines is null or jsonb_typeof(p_lines) <> 'array' or exists (
    select 1 from jsonb_array_elements(p_lines) e
    where jsonb_typeof(e) <> 'object'
       or jsonb_typeof(e -> 'meters') is distinct from 'number'
       or (e ->> 'meters')::numeric < 0
       or jsonb_typeof(e -> 'material_id') is distinct from 'string'
       or not exists (
         select 1 from public.materials m where m.id::text = e ->> 'material_id' and m.org_id = v_org
       )
  ) then
    raise exception 'invalid_lines' using errcode = '22023';
  end if;
  return v_org;
end;
$$;
revoke execute on function public.production_check(uuid, jsonb) from public, anon, authenticated;

-- Livraison : une seule fois, depuis un statut ni livré ni abandonné. Le verrou sur
-- le modèle sérialise deux appels simultanés (double clic, nouvel essai réseau).
create or replace function public.deliver_model(p_model uuid, p_lines jsonb)
returns void
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_org uuid := public.production_check(p_model, p_lines);
  v_status public.model_status;
begin
  select status into v_status from public.models where id = p_model for update;
  if v_status in ('delivered', 'abandoned') then
    raise exception 'invalid_status_transition' using errcode = '22023';
  end if;
  update public.materials m
     set atelier_stock_m = greatest(0, coalesce(m.atelier_stock_m, 0) - d.meters)
    from (
      select (e ->> 'material_id')::uuid as material_id, sum((e ->> 'meters')::numeric) as meters
      from jsonb_array_elements(p_lines) e group by 1
    ) d
   where m.id = d.material_id and m.org_id = v_org;
  delete from public.stock_reservations where model_id = p_model;
  perform set_config('filyxa.delivering', p_model::text, true);
  update public.models set status = 'delivered' where id = p_model;
  perform set_config('filyxa.delivering', '', true);
end;
$$;
revoke execute on function public.deliver_model(uuid, jsonb) from public, anon;
grant execute on function public.deliver_model(uuid, jsonb) to authenticated;

-- 3. Grilles de tailles -----------------------------------------------------------------------

-- Une taille retirée d'une grille disparaît des modèles qui l'utilisent.
create or replace function public.size_charts_cleanup()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  update public.models set base_size = null
   where size_chart_id = new.id and base_size is not null and base_size <> all (new.sizes);
  delete from public.model_size_grades g
   using public.models m
   where m.id = g.model_id and m.size_chart_id = new.id and g.size <> all (new.sizes);
  delete from public.colorway_size_quantities q
   using public.colorways c, public.models m
   where c.id = q.colorway_id and m.id = c.model_id and m.size_chart_id = new.id and q.size <> all (new.sizes);
  return null;
end;
$$;

create trigger size_charts_cleanup after update of sizes on public.size_charts
  for each row when (old.sizes is distinct from new.sizes)
  execute function public.size_charts_cleanup();

-- Données déjà incohérentes.
update public.models m set base_size = null
  from public.size_charts sc
 where sc.id = m.size_chart_id and m.base_size is not null and m.base_size <> all (sc.sizes);
update public.models set base_size = null where size_chart_id is null and base_size is not null;
delete from public.model_size_grades g
 using public.models m
 where m.id = g.model_id
   and not exists (select 1 from public.size_charts sc where sc.id = m.size_chart_id and g.size = any (sc.sizes));
delete from public.colorway_size_quantities q
 using public.colorways c, public.models m
 where c.id = q.colorway_id and m.id = c.model_id
   and not exists (select 1 from public.size_charts sc where sc.id = m.size_chart_id and q.size = any (sc.sizes));

-- 4. has_pro ----------------------------------------------------------------------------------

-- Exécutée avec les droits de l'appelant : un utilisateur ne lit que ses propres
-- organisations (règles d'accès), donc has_pro renvoie faux pour les autres. Les
-- fonctions internes (security definer) gardent la réponse complète.
create or replace function public.has_pro(p_org uuid)
returns boolean
language sql
stable
security invoker
set search_path = ''
as $$
  select coalesce((
    select p.pro from public.organizations o join public.plans p on p.code = o.plan where o.id = p_org
  ), false);
$$;
revoke execute on function public.has_pro(uuid) from public, anon;
grant execute on function public.has_pro(uuid) to authenticated;
