-- Filyxa — Phase 15 : statuts du modèle et verrou de l'offre Pro.
--
-- Les fonctionnalités du Studio avancé (V2) sont réservées aux offres qui
-- portent le drapeau « pro » : Pro, Sur mesure et Pilote (le temps du pilote).
-- Le contrôle se fait côté serveur, à chaque écriture, par has_pro(). Après un
-- retour à une offre inférieure, les données restent lisibles mais ne se
-- modifient plus.
--
-- Un modèle suit les statuts Idée → Prototype → Validé → En production → Livré,
-- ou passe en Abandonné. On peut revenir en arrière, sauf depuis Livré.
-- Pour un atelier Pro, seuls les modèles en Prototype, Validé ou En production
-- déclenchent les notifications de stock et de fiche fournisseur. Hors Pro, les
-- statuts ne sont pas utilisés : tous les modèles comptent, comme en V1.

alter table public.plans add column pro boolean not null default false;
update public.plans set pro = true where code in ('pilot', 'pro', 'custom');

create or replace function public.has_pro(p_org uuid)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select coalesce((
    select p.pro from public.organizations o join public.plans p on p.code = o.plan where o.id = p_org
  ), false);
$$;
revoke execute on function public.has_pro(uuid) from public, anon;
grant execute on function public.has_pro(uuid) to authenticated;

create type public.model_status as enum (
  'idea', 'prototype', 'validated', 'in_production', 'delivered', 'abandoned'
);

alter table public.models add column status public.model_status not null default 'idea';
-- La V1 considérait tous les modèles comme en cours : les modèles existants passent
-- en Prototype pour continuer à recevoir les notifications. Les nouveaux partent d'Idée.
update public.models set status = 'prototype';

-- Un statut actif déclenche les alertes de stock et de fiche fournisseur.
create or replace function public.model_status_is_active(p_status public.model_status)
returns boolean
language sql
immutable
set search_path = ''
as $$
  select p_status in ('prototype', 'validated', 'in_production');
$$;

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
    return new;
  end if;
  if new.status is distinct from old.status then
    if not public.has_pro(new.org_id) then
      raise exception 'pro_required' using errcode = '42501';
    end if;
    if old.status = 'delivered' then
      raise exception 'invalid_status_transition' using errcode = '22023';
    end if;
  end if;
  return new;
end;
$$;

-- Après le trigger qui recopie org_id depuis la collection (ordre alphabétique).
create trigger models_status_guard before insert or update on public.models
  for each row execute function public.models_status_guard();

-- Notifications du Studio : mêmes règles qu'en phase 11, limitées aux modèles
-- actifs pour un atelier Pro.
create or replace function public.notify_reference_change()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_kind text;
  v_mode public.availability_mode;
  v_threshold numeric;
  old_status public.availability_status;
  new_status public.availability_status;
  rec record;
begin
  if old.retired_at is null and new.retired_at is not null then
    v_kind := 'reference_retired';
  elsif new.retired_at is null then
    select coalesce(new.availability_mode, s.availability_mode, 'tiers'),
           coalesce(new.low_stock_threshold_m, s.low_stock_threshold_m, 50)
      into v_mode, v_threshold
    from (select 1) x
    left join public.supplier_settings s on s.org_id = new.supplier_org_id;

    if v_mode <> 'hidden' then
      old_status := public.availability_status_of(old.stock_m, v_threshold, old.lead_time_weeks);
      new_status := public.availability_status_of(new.stock_m, v_threshold, new.lead_time_weeks);
      if new_status in ('out_of_stock', 'on_order') and old_status in ('available', 'low') then
        v_kind := 'stock_out';
      elsif new_status = 'low' and old_status = 'available' then
        v_kind := 'stock_low';
      end if;
    end if;

    if v_kind is null and (
      new.name, new.color_name, new.color_hex, new.composition, new.weight_gsm, new.width_cm,
      new.weave, new.care, new.certifications, new.uses
    ) is distinct from (
      old.name, old.color_name, old.color_hex, old.composition, old.weight_gsm, old.width_cm,
      old.weave, old.care, old.certifications, old.uses
    ) then
      v_kind := 'reference_updated';
    end if;
  end if;

  if v_kind is null then
    return new;
  end if;

  -- Ateliers concernés : matière liée à la référence et utilisée dans au moins
  -- un modèle actif (tous les modèles hors offre Pro).
  for rec in
    select m.org_id, m.id as material_id, m.name as material_name,
           jsonb_agg(distinct jsonb_build_object('id', md.id, 'name', md.name)) as models
    from public.materials m
    join public.model_materials mm on mm.material_id = m.id
    join public.colorways c on c.id = mm.colorway_id
    join public.models md on md.id = c.model_id
    where m.supplier_reference_id = new.id
      and (public.model_status_is_active(md.status) or not public.has_pro(m.org_id))
    group by m.org_id, m.id, m.name
  loop
    insert into public.notifications (user_id, org_id, kind, material_id, reference_id, data)
    select mb.user_id, rec.org_id, v_kind, rec.material_id, new.id,
           jsonb_build_object('code', new.code, 'name', rec.material_name, 'models', rec.models,
                              'lead_time', new.lead_time_weeks)
    from public.memberships mb
    where mb.org_id = rec.org_id
      and not exists (
        select 1 from public.notifications n
        where n.user_id = mb.user_id and n.reference_id = new.id and n.material_id = rec.material_id
          and n.kind = v_kind and n.read_at is null
      );
  end loop;
  return new;
end;
$$;
