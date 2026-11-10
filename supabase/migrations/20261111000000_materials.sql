-- Filyxa — Phase 3 : TissuTech minimal (matières textiles saisies à la main).
--
-- Une matière appartient à une organisation. Ses caractéristiques textiles sont
-- dans textile_specs (les cuirs et composants auront leurs propres tables).
-- Les valeurs de vocabulaire sont des codes normalisés, traduits par l'app :
--   fibres ISO 2076 (WO, CO, PES…), entretien ISO 3758 (wash_30, iron_low…),
--   armures, usages et certifications en listes fermées.
-- Lecture : tout membre. Écriture : Éditeur ou Admin.

create type public.material_kind as enum ('textile');

create table public.materials (
  id               uuid primary key default gen_random_uuid(),
  org_id           uuid not null references public.organizations (id) on delete cascade,
  kind             public.material_kind not null default 'textile',
  name             text not null check (char_length(btrim(name)) between 1 and 160),
  supplier_name    text check (supplier_name is null or char_length(supplier_name) <= 160),
  supplier_code    text check (supplier_code is null or char_length(supplier_code) <= 80),
  color_name       text check (color_name is null or char_length(color_name) <= 80),
  color_hex        text check (color_hex is null or color_hex ~ '^#[0-9A-F]{6}$'),
  photo_path       text,
  atelier_stock_m  numeric(10, 2) check (atelier_stock_m is null or atelier_stock_m >= 0),
  notes            text check (notes is null or char_length(notes) <= 4000),
  created_by       uuid references auth.users (id) on delete set null,
  created_at       timestamptz not null default now(),
  updated_at       timestamptz not null default now()
);

create index materials_org_idx on public.materials (org_id, updated_at desc);

create table public.textile_specs (
  material_id     uuid primary key references public.materials (id) on delete cascade,
  -- [{ "fiber": "WO", "pct": 62 }, …] ; total 100 % ou composition vide.
  composition     jsonb not null default '[]'::jsonb,
  weight_gsm      integer check (weight_gsm is null or weight_gsm between 1 and 2000),
  width_cm        integer check (width_cm is null or width_cm between 1 and 600),
  weave           text,
  care            text[] not null default '{}',
  certifications  text[] not null default '{}',
  uses            text[] not null default '{}'
);

-- Somme des pourcentages : 100 (à 0,5 près) ou composition vide.
create or replace function public.composition_is_valid(c jsonb)
returns boolean
language sql
immutable
set search_path = ''
as $$
  select jsonb_typeof(c) = 'array'
    and (
      jsonb_array_length(c) = 0
      or abs(coalesce((select sum((e ->> 'pct')::numeric) from jsonb_array_elements(c) e), 0) - 100) <= 0.5
    )
    and not exists (
      select 1 from jsonb_array_elements(c) e
      where coalesce(e ->> 'fiber', '') = '' or (e ->> 'pct')::numeric <= 0
    );
$$;

alter table public.textile_specs
  add constraint textile_specs_composition_valid check (public.composition_is_valid(composition));

-- Horodatage de modification.
create or replace function public.touch_updated_at()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  new.updated_at := now();
  return new;
end;
$$;

create trigger materials_touch before update on public.materials
  for each row execute function public.touch_updated_at();

-- Une matière ne change jamais d'organisation.
create or replace function public.materials_keep_org()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  if new.org_id is distinct from old.org_id then
    raise exception 'org_immutable' using errcode = '42501';
  end if;
  return new;
end;
$$;

create trigger materials_keep_org before update on public.materials
  for each row execute function public.materials_keep_org();

-- Enregistrement atomique d'une matière textile (création ou modification).
-- SECURITY INVOKER : les règles d'accès s'appliquent comme pour un appel direct.
create or replace function public.save_textile_material(payload jsonb)
returns uuid
language plpgsql
security invoker
set search_path = ''
as $$
declare
  v_id uuid := nullif(payload ->> 'id', '')::uuid;
  specs jsonb := coalesce(payload -> 'specs', '{}'::jsonb);
begin
  if v_id is null then
    insert into public.materials (
      org_id, name, supplier_name, supplier_code, color_name, color_hex,
      photo_path, atelier_stock_m, notes, created_by
    ) values (
      (payload ->> 'org_id')::uuid,
      btrim(payload ->> 'name'),
      nullif(btrim(payload ->> 'supplier_name'), ''),
      nullif(btrim(payload ->> 'supplier_code'), ''),
      nullif(btrim(payload ->> 'color_name'), ''),
      nullif(upper(payload ->> 'color_hex'), ''),
      nullif(payload ->> 'photo_path', ''),
      (payload ->> 'atelier_stock_m')::numeric,
      nullif(payload ->> 'notes', ''),
      auth.uid()
    )
    returning id into v_id;
  else
    update public.materials set
      name            = btrim(payload ->> 'name'),
      supplier_name   = nullif(btrim(payload ->> 'supplier_name'), ''),
      supplier_code   = nullif(btrim(payload ->> 'supplier_code'), ''),
      color_name      = nullif(btrim(payload ->> 'color_name'), ''),
      color_hex       = nullif(upper(payload ->> 'color_hex'), ''),
      photo_path      = nullif(payload ->> 'photo_path', ''),
      atelier_stock_m = (payload ->> 'atelier_stock_m')::numeric,
      notes           = nullif(payload ->> 'notes', '')
    where id = v_id;
    if not found then
      raise exception 'material_not_found' using errcode = 'P0002';
    end if;
  end if;

  insert into public.textile_specs (
    material_id, composition, weight_gsm, width_cm, weave, care, certifications, uses
  ) values (
    v_id,
    coalesce(specs -> 'composition', '[]'::jsonb),
    (specs ->> 'weight_gsm')::integer,
    (specs ->> 'width_cm')::integer,
    nullif(specs ->> 'weave', ''),
    coalesce(array(select jsonb_array_elements_text(specs -> 'care')), '{}'),
    coalesce(array(select jsonb_array_elements_text(specs -> 'certifications')), '{}'),
    coalesce(array(select jsonb_array_elements_text(specs -> 'uses')), '{}')
  )
  on conflict (material_id) do update set
    composition    = excluded.composition,
    weight_gsm     = excluded.weight_gsm,
    width_cm       = excluded.width_cm,
    weave          = excluded.weave,
    care           = excluded.care,
    certifications = excluded.certifications,
    uses           = excluded.uses;

  return v_id;
end;
$$;

-- Règles d'accès ----------------------------------------------------------------
alter table public.materials     enable row level security;
alter table public.textile_specs enable row level security;

create policy "materials: lecture membres" on public.materials
  for select to authenticated using (public.has_role(org_id, 'viewer'));
create policy "materials: création éditeurs" on public.materials
  for insert to authenticated with check (public.has_role(org_id, 'editor'));
create policy "materials: modification éditeurs" on public.materials
  for update to authenticated
  using (public.has_role(org_id, 'editor'))
  with check (public.has_role(org_id, 'editor'));
create policy "materials: suppression éditeurs" on public.materials
  for delete to authenticated using (public.has_role(org_id, 'editor'));

create policy "textile_specs: lecture membres" on public.textile_specs
  for select to authenticated
  using (exists (select 1 from public.materials m
                 where m.id = material_id and public.has_role(m.org_id, 'viewer')));
create policy "textile_specs: écriture éditeurs" on public.textile_specs
  for all to authenticated
  using (exists (select 1 from public.materials m
                 where m.id = material_id and public.has_role(m.org_id, 'editor')))
  with check (exists (select 1 from public.materials m
                      where m.id = material_id and public.has_role(m.org_id, 'editor')));

revoke all on public.materials, public.textile_specs from anon, authenticated;
grant select, insert, update, delete on public.materials, public.textile_specs to authenticated;
grant all on public.materials, public.textile_specs to service_role;

revoke execute on function public.save_textile_material(jsonb) from public, anon;
grant execute on function public.save_textile_material(jsonb) to authenticated;
grant execute on function public.composition_is_valid(jsonb) to authenticated, service_role;

-- Photos des matières ---------------------------------------------------------
-- Bucket privé ; chemin : <org_id>/<fichier>. Lecture membres, écriture éditeurs.
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('material-photos', 'material-photos', false, 8388608,
        array['image/jpeg', 'image/png', 'image/webp'])
on conflict (id) do nothing;

-- Rôle dans l'organisation dont l'identifiant est le premier dossier du chemin.
-- Renvoie faux (au lieu d'une erreur) si ce dossier n'est pas un identifiant.
create or replace function public.has_role_for_path(object_name text, min_role public.member_role)
returns boolean
language plpgsql
stable
security definer
set search_path = ''
as $$
declare
  folder text := split_part(object_name, '/', 1);
begin
  if folder !~ '^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$' then
    return false;
  end if;
  return public.has_role(folder::uuid, min_role);
end;
$$;

revoke execute on function public.has_role_for_path(text, public.member_role) from public, anon;
grant execute on function public.has_role_for_path(text, public.member_role) to authenticated, service_role;

create policy "material-photos: lecture membres" on storage.objects
  for select to authenticated
  using (bucket_id = 'material-photos' and public.has_role_for_path(name, 'viewer'));
create policy "material-photos: ajout éditeurs" on storage.objects
  for insert to authenticated
  with check (bucket_id = 'material-photos' and public.has_role_for_path(name, 'editor'));
create policy "material-photos: modification éditeurs" on storage.objects
  for update to authenticated
  using (bucket_id = 'material-photos' and public.has_role_for_path(name, 'editor'));
create policy "material-photos: suppression éditeurs" on storage.objects
  for delete to authenticated
  using (bucket_id = 'material-photos' and public.has_role_for_path(name, 'editor'));
