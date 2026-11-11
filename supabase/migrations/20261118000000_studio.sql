-- Filyxa — Phase 10 : Studio — collections, modèles, coloris et besoin en matière.
--
-- collection → modèles (type de produit, marge de perte) → coloris (quantité
-- prévue) → matières du coloris (rôle, consommation par pièce en mètres).
-- Chaque modèle naît avec un coloris par défaut, caché tant qu'il est seul.
-- Besoin = consommation × quantité × (1 + marge) : calculé dans l'app.
--
-- org_id est recopié sur chaque table (depuis le parent, par déclencheur) pour
-- des règles d'accès simples et rapides.

create type public.product_type as enum ('garment', 'footwear', 'leather_goods', 'accessory');

create table public.collections (
  id          uuid primary key default gen_random_uuid(),
  org_id      uuid not null references public.organizations (id) on delete cascade,
  name        text not null check (char_length(btrim(name)) between 1 and 80),
  created_by  uuid references auth.users (id) on delete set null,
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now()
);
create index collections_org_idx on public.collections (org_id, updated_at desc);

create table public.models (
  id             uuid primary key default gen_random_uuid(),
  org_id         uuid not null references public.organizations (id) on delete cascade,
  collection_id  uuid not null references public.collections (id) on delete cascade,
  name           text not null check (char_length(btrim(name)) between 1 and 120),
  reference      text check (reference is null or char_length(reference) <= 60),
  product_type   public.product_type not null,
  -- Marge de perte en pourcentage (8 % par défaut).
  waste_pct      numeric(5, 2) not null default 8 check (waste_pct between 0 and 100),
  created_by     uuid references auth.users (id) on delete set null,
  created_at     timestamptz not null default now(),
  updated_at     timestamptz not null default now()
);
create index models_collection_idx on public.models (collection_id, created_at);

create table public.colorways (
  id          uuid primary key default gen_random_uuid(),
  org_id      uuid not null references public.organizations (id) on delete cascade,
  model_id    uuid not null references public.models (id) on delete cascade,
  -- null pour le coloris par défaut tant qu'il n'est pas nommé.
  name        text check (name is null or char_length(btrim(name)) between 1 and 60),
  color_hex   text check (color_hex is null or color_hex ~ '^#[0-9A-F]{6}$'),
  -- Quantité de pièces prévue.
  quantity    integer not null default 0 check (quantity between 0 and 10000000),
  position    integer not null default 0,
  created_at  timestamptz not null default now()
);
create index colorways_model_idx on public.colorways (model_id, position);

create table public.model_materials (
  id           uuid primary key default gen_random_uuid(),
  org_id       uuid not null references public.organizations (id) on delete cascade,
  colorway_id  uuid not null references public.colorways (id) on delete cascade,
  material_id  uuid not null references public.materials (id) on delete cascade,
  -- Code de rôle intégré (main, lining…) ou rôle libre saisi par l'atelier.
  role         text not null check (char_length(btrim(role)) between 1 and 60),
  -- Consommation par pièce, en mètres.
  consumption  numeric(10, 3) not null default 0 check (consumption between 0 and 1000),
  position     integer not null default 0,
  created_at   timestamptz not null default now()
);
create index model_materials_colorway_idx on public.model_materials (colorway_id, position);
create index model_materials_material_idx on public.model_materials (material_id);

create trigger collections_touch before update on public.collections
  for each row execute function public.touch_updated_at();
create trigger models_touch before update on public.models
  for each row execute function public.touch_updated_at();

-- org_id recopié depuis le parent : impossible de rattacher une ligne à une autre organisation.
create or replace function public.studio_inherit_org()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  if tg_table_name = 'models' then
    select org_id into new.org_id from public.collections where id = new.collection_id;
  elsif tg_table_name = 'colorways' then
    select org_id into new.org_id from public.models where id = new.model_id;
  elsif tg_table_name = 'model_materials' then
    select org_id into new.org_id from public.colorways where id = new.colorway_id;
    if not exists (select 1 from public.materials m where m.id = new.material_id and m.org_id = new.org_id) then
      raise exception 'material_not_in_org' using errcode = '42501';
    end if;
  end if;
  if new.org_id is null then
    raise exception 'parent_not_found' using errcode = 'P0002';
  end if;
  return new;
end;
$$;

create trigger models_inherit_org before insert or update of collection_id on public.models
  for each row execute function public.studio_inherit_org();
create trigger colorways_inherit_org before insert or update of model_id on public.colorways
  for each row execute function public.studio_inherit_org();
create trigger model_materials_inherit_org before insert or update of colorway_id, material_id on public.model_materials
  for each row execute function public.studio_inherit_org();

-- Chaque modèle naît avec son coloris par défaut.
create or replace function public.models_default_colorway()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  insert into public.colorways (model_id, org_id, position) values (new.id, new.org_id, 0);
  return new;
end;
$$;

create trigger models_default_colorway after insert on public.models
  for each row execute function public.models_default_colorway();

-- Un modèle garde toujours au moins un coloris.
create or replace function public.colorways_keep_one()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  if exists (select 1 from public.models where id = old.model_id)
     and (select count(*) from public.colorways where model_id = old.model_id) <= 1 then
    raise exception 'last_colorway' using errcode = '22023';
  end if;
  return old;
end;
$$;

create trigger colorways_keep_one before delete on public.colorways
  for each row execute function public.colorways_keep_one();

-- Nouveau coloris, avec la nomenclature d'un coloris existant (sans ressaisie).
create or replace function public.add_colorway(p_model uuid, p_name text, p_copy_from uuid default null)
returns uuid
language plpgsql
security invoker
set search_path = ''
as $$
declare
  v_id uuid;
begin
  insert into public.colorways (model_id, name, position)
  values (p_model, nullif(btrim(p_name), ''),
          coalesce((select max(position) + 1 from public.colorways where model_id = p_model), 0))
  returning id into v_id;

  if p_copy_from is not null then
    insert into public.model_materials (colorway_id, material_id, role, consumption, position)
    select v_id, mm.material_id, mm.role, mm.consumption, mm.position
    from public.model_materials mm
    join public.colorways c on c.id = mm.colorway_id
    where mm.colorway_id = p_copy_from and c.model_id = p_model;
  end if;
  return v_id;
end;
$$;

revoke execute on function public.add_colorway(uuid, text, uuid) from public, anon;
grant execute on function public.add_colorway(uuid, text, uuid) to authenticated;

-- Règles d'accès : lecture pour tous les membres, écriture pour les Éditeurs.
do $$
declare t text;
begin
  foreach t in array array['collections', 'models', 'colorways', 'model_materials'] loop
    execute format('alter table public.%I enable row level security', t);
    execute format($p$create policy "%1$s: lecture membres" on public.%1$I
      for select to authenticated using (org_id in (select public.my_org_ids('viewer')))$p$, t);
    execute format($p$create policy "%1$s: écriture éditeurs" on public.%1$I
      for all to authenticated
      using (org_id in (select public.my_org_ids('editor')))
      with check (org_id in (select public.my_org_ids('editor')))$p$, t);
    execute format('revoke all on public.%I from anon, authenticated', t);
    execute format('grant select, insert, update, delete on public.%I to authenticated', t);
    execute format('grant all on public.%I to service_role', t);
  end loop;
end;
$$;
