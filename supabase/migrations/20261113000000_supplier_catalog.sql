-- Filyxa — Phase 5 : catalogue fournisseur et disponibilité.
--
-- Le fournisseur gère ses références (supplier_references) et leur stock brut.
-- Les ateliers ne lisent jamais cette table : ils passent par la vue
-- supplier_catalog, qui applique la règle d'affichage choisie par le fournisseur
-- (quantité exacte, paliers, ou masquée) et exclut les références retirées.

create type public.availability_mode as enum ('exact', 'tiers', 'hidden');
create type public.availability_status as enum ('available', 'low', 'on_order', 'out_of_stock');

-- Réglages du fournisseur ----------------------------------------------------------
create table public.supplier_settings (
  org_id                 uuid primary key references public.organizations (id) on delete cascade,
  availability_mode      public.availability_mode not null default 'tiers',
  low_stock_threshold_m  numeric(10, 2) not null default 50 check (low_stock_threshold_m >= 0),
  -- Association colonnes du fichier → champs, mémorisée pour le prochain import.
  import_mapping         jsonb not null default '{}'::jsonb,
  updated_at             timestamptz not null default now()
);

-- Références --------------------------------------------------------------------------
create table public.supplier_references (
  id                     uuid primary key default gen_random_uuid(),
  supplier_org_id        uuid not null references public.organizations (id) on delete cascade,
  code                   text not null check (char_length(btrim(code)) between 1 and 80),
  -- Code sans espaces, tirets ni casse : « DR 4521-nv » = « DR4521NV ».
  code_normalized        text generated always as (upper(regexp_replace(code, '[^A-Za-z0-9]', '', 'g'))) stored,
  name                   text not null check (char_length(btrim(name)) between 1 and 160),
  color_name             text check (color_name is null or char_length(color_name) <= 80),
  color_hex              text check (color_hex is null or color_hex ~ '^#[0-9A-F]{6}$'),
  composition            jsonb not null default '[]'::jsonb check (public.composition_is_valid(composition)),
  weight_gsm             integer check (weight_gsm is null or weight_gsm between 1 and 2000),
  width_cm               integer check (width_cm is null or width_cm between 1 and 600),
  weave                  text,
  care                   text[] not null default '{}',
  certifications         text[] not null default '{}',
  uses                   text[] not null default '{}',
  -- Stock brut en mètres : lisible par le seul fournisseur.
  stock_m                numeric(12, 2) check (stock_m is null or stock_m >= 0),
  lead_time_weeks        integer check (lead_time_weeks is null or lead_time_weeks between 0 and 104),
  -- Réglages propres à la référence (null = réglage général du fournisseur).
  availability_mode      public.availability_mode,
  low_stock_threshold_m  numeric(10, 2) check (low_stock_threshold_m is null or low_stock_threshold_m >= 0),
  retired_at             timestamptz,
  created_at             timestamptz not null default now(),
  updated_at             timestamptz not null default now(),
  unique (supplier_org_id, code_normalized)
);

create index supplier_references_org_idx on public.supplier_references (supplier_org_id, updated_at desc);

create trigger supplier_references_touch before update on public.supplier_references
  for each row execute function public.touch_updated_at();
create trigger supplier_settings_touch before update on public.supplier_settings
  for each row execute function public.touch_updated_at();

-- Seules les organisations fournisseur ont un catalogue.
create or replace function public.ensure_supplier_org_id(org uuid)
returns void
language plpgsql
set search_path = ''
as $$
begin
  if not exists (select 1 from public.organizations o where o.id = org and o.kind = 'supplier') then
    raise exception 'not_a_supplier' using errcode = '42501';
  end if;
end;
$$;

create or replace function public.supplier_references_check_org()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  perform public.ensure_supplier_org_id(new.supplier_org_id);
  return new;
end;
$$;

create or replace function public.supplier_settings_check_org()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  perform public.ensure_supplier_org_id(new.org_id);
  return new;
end;
$$;

create trigger supplier_references_kind before insert or update on public.supplier_references
  for each row execute function public.supplier_references_check_org();
create trigger supplier_settings_kind before insert or update on public.supplier_settings
  for each row execute function public.supplier_settings_check_org();

-- Disponibilité ------------------------------------------------------------------------
-- Statut d'une référence : stock > seuil → disponible ; 0 < stock ≤ seuil → faible ;
-- sinon « sur commande » si un délai est indiqué, « rupture » sinon.
create or replace function public.availability_status_of(
  stock numeric, threshold numeric, lead_time integer
)
returns public.availability_status
language sql
immutable
set search_path = ''
as $$
  select case
    when stock is not null and stock > coalesce(threshold, 0) then 'available'::public.availability_status
    when stock is not null and stock > 0 then 'low'::public.availability_status
    when lead_time is not null then 'on_order'::public.availability_status
    else 'out_of_stock'::public.availability_status
  end;
$$;

-- Vrai si l'utilisateur connecté appartient à au moins un atelier.
create or replace function public.is_atelier_member()
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1 from public.memberships m
    join public.organizations o on o.id = m.org_id
    where m.user_id = (select auth.uid()) and o.kind = 'atelier'
  );
$$;

-- Catalogue publié : ce que voient les ateliers (et le fournisseur lui-même).
-- La vue s'exécute avec les droits de son propriétaire : le filtre d'accès est
-- dans la clause where, et le stock brut n'est exposé qu'en mode « exact ».
create view public.supplier_catalog
with (security_barrier = true)
as
select
  r.id,
  r.supplier_org_id,
  o.name                               as supplier_name,
  r.code,
  r.code_normalized,
  r.name,
  r.color_name,
  r.color_hex,
  r.composition,
  r.weight_gsm,
  r.width_cm,
  r.weave,
  r.care,
  r.certifications,
  r.uses,
  r.lead_time_weeks,
  mode.value                           as availability_mode,
  case when mode.value = 'hidden' then null
       else public.availability_status_of(r.stock_m, threshold.value, r.lead_time_weeks)
  end                                  as availability_status,
  case when mode.value = 'exact' then r.stock_m end as stock_m,
  r.updated_at
from public.supplier_references r
join public.organizations o on o.id = r.supplier_org_id
left join public.supplier_settings s on s.org_id = r.supplier_org_id
cross join lateral (select coalesce(r.availability_mode, s.availability_mode, 'tiers')::public.availability_mode as value) mode
cross join lateral (select coalesce(r.low_stock_threshold_m, s.low_stock_threshold_m, 50) as value) threshold
where r.retired_at is null
  and (
    public.is_atelier_member()
    or r.supplier_org_id in (select public.my_org_ids('viewer'))
  );

-- Import en lot ----------------------------------------------------------------------
-- Crée ou met à jour les références par code (sans doublon). Chaque ligne est
-- traitée isolément : une ligne invalide est rejetée avec son motif, les autres
-- sont importées. Renvoie { inserted, updated, errors: [{ row, error }] }.
create or replace function public.import_supplier_references(p_org uuid, p_rows jsonb)
returns jsonb
language plpgsql
security invoker
set search_path = ''
as $$
declare
  rec jsonb;
  idx integer := 0;
  inserted integer := 0;
  updated integer := 0;
  errors jsonb := '[]'::jsonb;
  existed boolean;
begin
  if not public.has_role(p_org, 'editor') then
    raise exception 'forbidden' using errcode = '42501';
  end if;
  if jsonb_typeof(p_rows) <> 'array' or jsonb_array_length(p_rows) > 5000 then
    raise exception 'too_many_rows' using errcode = '22023';
  end if;

  for rec in select * from jsonb_array_elements(p_rows) loop
    idx := idx + 1;
    begin
      select exists (
        select 1 from public.supplier_references
        where supplier_org_id = p_org
          and code_normalized = upper(regexp_replace(coalesce(rec ->> 'code', ''), '[^A-Za-z0-9]', '', 'g'))
      ) into existed;

      insert into public.supplier_references (
        supplier_org_id, code, name, color_name, color_hex, composition, weight_gsm, width_cm,
        weave, care, certifications, uses, stock_m, lead_time_weeks, retired_at
      ) values (
        p_org,
        btrim(rec ->> 'code'),
        btrim(rec ->> 'name'),
        nullif(btrim(rec ->> 'color_name'), ''),
        nullif(upper(rec ->> 'color_hex'), ''),
        coalesce(rec -> 'composition', '[]'::jsonb),
        (rec ->> 'weight_gsm')::integer,
        (rec ->> 'width_cm')::integer,
        nullif(rec ->> 'weave', ''),
        coalesce(array(select jsonb_array_elements_text(rec -> 'care')), '{}'),
        coalesce(array(select jsonb_array_elements_text(rec -> 'certifications')), '{}'),
        coalesce(array(select jsonb_array_elements_text(rec -> 'uses')), '{}'),
        (rec ->> 'stock_m')::numeric,
        (rec ->> 'lead_time_weeks')::integer,
        null
      )
      on conflict (supplier_org_id, code_normalized) do update set
        code            = excluded.code,
        name            = excluded.name,
        color_name      = coalesce(excluded.color_name, public.supplier_references.color_name),
        color_hex       = coalesce(excluded.color_hex, public.supplier_references.color_hex),
        composition     = case when jsonb_array_length(excluded.composition) > 0
                               then excluded.composition else public.supplier_references.composition end,
        weight_gsm      = coalesce(excluded.weight_gsm, public.supplier_references.weight_gsm),
        width_cm        = coalesce(excluded.width_cm, public.supplier_references.width_cm),
        weave           = coalesce(excluded.weave, public.supplier_references.weave),
        care            = case when cardinality(excluded.care) > 0 then excluded.care else public.supplier_references.care end,
        certifications  = case when cardinality(excluded.certifications) > 0 then excluded.certifications else public.supplier_references.certifications end,
        uses            = case when cardinality(excluded.uses) > 0 then excluded.uses else public.supplier_references.uses end,
        stock_m         = excluded.stock_m,
        lead_time_weeks = coalesce(excluded.lead_time_weeks, public.supplier_references.lead_time_weeks),
        -- Une référence réimportée est de nouveau publiée.
        retired_at      = null;

      if existed then updated := updated + 1; else inserted := inserted + 1; end if;
    exception when others then
      errors := errors || jsonb_build_object('row', idx, 'error', sqlerrm);
    end;
  end loop;

  return jsonb_build_object('inserted', inserted, 'updated', updated, 'errors', errors);
end;
$$;

-- Règles d'accès -------------------------------------------------------------------------
alter table public.supplier_references enable row level security;
alter table public.supplier_settings   enable row level security;

create policy "supplier_references: lecture fournisseur" on public.supplier_references
  for select to authenticated
  using (supplier_org_id in (select public.my_org_ids('viewer')));
create policy "supplier_references: écriture éditeurs" on public.supplier_references
  for all to authenticated
  using (supplier_org_id in (select public.my_org_ids('editor')))
  with check (supplier_org_id in (select public.my_org_ids('editor')));

create policy "supplier_settings: lecture fournisseur" on public.supplier_settings
  for select to authenticated
  using (org_id in (select public.my_org_ids('viewer')));
create policy "supplier_settings: écriture éditeurs" on public.supplier_settings
  for all to authenticated
  using (org_id in (select public.my_org_ids('editor')))
  with check (org_id in (select public.my_org_ids('editor')));

revoke all on public.supplier_references, public.supplier_settings, public.supplier_catalog from anon, authenticated;
grant select, insert, update, delete on public.supplier_references, public.supplier_settings to authenticated;
grant select on public.supplier_catalog to authenticated;
grant all on public.supplier_references, public.supplier_settings, public.supplier_catalog to service_role;

revoke execute on function public.import_supplier_references(uuid, jsonb) from public, anon;
grant execute on function public.import_supplier_references(uuid, jsonb) to authenticated;
revoke execute on function public.is_atelier_member() from public, anon;
grant execute on function public.is_atelier_member() to authenticated, service_role;
grant execute on function public.availability_status_of(numeric, numeric, integer) to authenticated, service_role;
