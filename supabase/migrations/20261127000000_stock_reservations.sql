-- Filyxa — Phase 20 : réservation et déduction du stock atelier.
--
-- Au passage « En production », l'Éditeur confirme le besoin de chaque matière
-- (production et prototypage, tel qu'affiché par l'app) : il est réservé sur le
-- stock atelier. Stock disponible = stock atelier − réservé (il peut devenir
-- négatif : c'est le manque). Au passage « Livré », l'Éditeur confirme les mètres
-- réellement consommés (la réservation par défaut) : ils sont déduits du stock
-- atelier, et la réservation disparaît. Abandonner un modèle, ou le ramener avant
-- « En production », libère sa réservation. Réservé à l'offre Pro.

create table public.stock_reservations (
  model_id     uuid not null references public.models (id) on delete cascade,
  material_id  uuid not null references public.materials (id) on delete cascade,
  org_id       uuid not null references public.organizations (id) on delete cascade,
  meters       numeric(12, 3) not null check (meters >= 0),
  created_at   timestamptz not null default now(),
  primary key (model_id, material_id)
);
create index stock_reservations_material_idx on public.stock_reservations (material_id);

alter table public.stock_reservations enable row level security;
create policy "stock_reservations: lecture membres" on public.stock_reservations
  for select to authenticated using (org_id in (select public.my_org_ids('viewer')));
-- Écriture uniquement par les fonctions ci-dessous.
revoke all on public.stock_reservations from anon, authenticated;
grant select on public.stock_reservations to authenticated;
grant all on public.stock_reservations to service_role;

-- Contrôles communs : modèle de l'atelier, Éditeur, offre Pro, lignes valides.
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
  if jsonb_typeof(p_lines) <> 'array' or exists (
    select 1 from jsonb_array_elements(p_lines) e
    where (e ->> 'meters')::numeric < 0
       or not exists (select 1 from public.materials m where m.id = (e ->> 'material_id')::uuid and m.org_id = v_org)
  ) then
    raise exception 'invalid_lines' using errcode = '22023';
  end if;
  return v_org;
end;
$$;

-- Lancement en production : réservation confirmée, puis statut « En production ».
create or replace function public.start_production(p_model uuid, p_lines jsonb)
returns void
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_org uuid := public.production_check(p_model, p_lines);
begin
  delete from public.stock_reservations where model_id = p_model;
  insert into public.stock_reservations (model_id, material_id, org_id, meters)
  select p_model, (e ->> 'material_id')::uuid, v_org, sum((e ->> 'meters')::numeric)
  from jsonb_array_elements(p_lines) e
  group by (e ->> 'material_id')::uuid;
  update public.models set status = 'in_production' where id = p_model;
end;
$$;

-- Livraison : déduction confirmée du stock atelier, puis statut « Livré ».
create or replace function public.deliver_model(p_model uuid, p_lines jsonb)
returns void
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_org uuid := public.production_check(p_model, p_lines);
begin
  update public.materials m
     set atelier_stock_m = greatest(0, coalesce(m.atelier_stock_m, 0) - d.meters)
    from (
      select (e ->> 'material_id')::uuid as material_id, sum((e ->> 'meters')::numeric) as meters
      from jsonb_array_elements(p_lines) e group by 1
    ) d
   where m.id = d.material_id and m.org_id = v_org;
  delete from public.stock_reservations where model_id = p_model;
  update public.models set status = 'delivered' where id = p_model;
end;
$$;

revoke execute on function public.production_check(uuid, jsonb) from public, anon, authenticated;
revoke execute on function public.start_production(uuid, jsonb) from public, anon;
grant execute on function public.start_production(uuid, jsonb) to authenticated;
revoke execute on function public.deliver_model(uuid, jsonb) from public, anon;
grant execute on function public.deliver_model(uuid, jsonb) to authenticated;

-- Quitter « En production » autrement que par une livraison confirmée libère la réservation.
create or replace function public.models_release_reservations()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  if old.status = 'in_production' and new.status <> 'in_production' then
    delete from public.stock_reservations where model_id = new.id;
  end if;
  return null;
end;
$$;

create trigger models_release_reservations after update of status on public.models
  for each row execute function public.models_release_reservations();
