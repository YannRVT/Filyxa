-- Filyxa — Phase 17 : grilles de tailles et quantités par taille et par coloris.
--
-- Filyxa fournit quatre grilles (org_id null, non modifiables) ; l'Admin d'un
-- atelier crée les siennes. Un modèle qui choisit une grille saisit ses quantités
-- par taille et par coloris ; la quantité du coloris devient la somme de ses
-- tailles, ce qui garde le calcul du besoin de la V1. Sans grille, la quantité
-- par coloris se saisit comme en V1. Réservé à l'offre Pro.

create table public.size_charts (
  id          uuid primary key default gen_random_uuid(),
  -- null : grille fournie par Filyxa.
  org_id      uuid references public.organizations (id) on delete cascade,
  -- Grilles fournies : code traduit à l'affichage ; grilles de l'atelier : nom saisi.
  code        text unique check (code is null or code in ('alpha', 'eu', 'shoes', 'one')),
  name        text check (name is null or char_length(btrim(name)) between 1 and 60),
  sizes       text[] not null check (cardinality(sizes) between 1 and 30),
  position    integer not null default 0,
  created_at  timestamptz not null default now(),
  check ((org_id is null) = (code is not null)),
  check (code is not null or name is not null)
);
create index size_charts_org_idx on public.size_charts (org_id, position);

insert into public.size_charts (code, sizes, position) values
  ('alpha', array['XS', 'S', 'M', 'L', 'XL', 'XXL'], 0),
  ('eu', array['34', '36', '38', '40', '42', '44', '46', '48'], 1),
  ('shoes', array['35', '36', '37', '38', '39', '40', '41', '42', '43', '44', '45', '46'], 2),
  ('one', array['TU'], 3);

-- Tailles distinctes et non vides.
create or replace function public.size_charts_check()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_removed text[];
begin
  new.sizes := array(select btrim(s) from unnest(new.sizes) with ordinality u(s, i) order by i);
  if exists (select 1 from unnest(new.sizes) s where s = '' or char_length(s) > 12)
     or (select count(distinct s) from unnest(new.sizes) s) <> cardinality(new.sizes) then
    raise exception 'invalid_sizes' using errcode = '22023';
  end if;
  if tg_op = 'UPDATE' then
    if old.org_id is null then
      raise exception 'forbidden' using errcode = '42501';
    end if;
    -- Une taille qui a des quantités ne peut pas disparaître.
    v_removed := array(select s from unnest(old.sizes) s where s <> all (new.sizes));
    if exists (
      select 1 from public.colorway_size_quantities q
      join public.colorways c on c.id = q.colorway_id
      join public.models m on m.id = c.model_id
      where m.size_chart_id = old.id and q.size = any (v_removed) and q.quantity > 0
    ) then
      raise exception 'size_in_use' using errcode = '23503';
    end if;
  end if;
  if new.org_id is not null and not public.has_pro(new.org_id) then
    raise exception 'pro_required' using errcode = '42501';
  end if;
  return new;
end;
$$;

alter table public.models add column size_chart_id uuid references public.size_charts (id) on delete restrict;

create table public.colorway_size_quantities (
  colorway_id  uuid not null references public.colorways (id) on delete cascade,
  size         text not null,
  org_id       uuid not null references public.organizations (id) on delete cascade,
  quantity     integer not null default 0 check (quantity between 0 and 10000000),
  primary key (colorway_id, size)
);

create trigger size_charts_check before insert or update on public.size_charts
  for each row execute function public.size_charts_check();

-- Quantités : organisation reprise du coloris, taille de la grille du modèle, offre Pro.
create or replace function public.colorway_size_quantities_guard()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_org uuid;
  v_sizes text[];
begin
  select c.org_id, sc.sizes into v_org, v_sizes
  from public.colorways c
  join public.models m on m.id = c.model_id
  left join public.size_charts sc on sc.id = m.size_chart_id
  where c.id = new.colorway_id;
  if v_org is null then
    raise exception 'parent_not_found' using errcode = 'P0002';
  end if;
  if v_sizes is null or not (new.size = any (v_sizes)) then
    raise exception 'size_not_in_chart' using errcode = '22023';
  end if;
  if not public.has_pro(v_org) then
    raise exception 'pro_required' using errcode = '42501';
  end if;
  new.org_id := v_org;
  return new;
end;
$$;

create trigger colorway_size_quantities_guard before insert or update on public.colorway_size_quantities
  for each row execute function public.colorway_size_quantities_guard();

-- La quantité du coloris suit la somme de ses tailles (si le modèle a une grille).
create or replace function public.colorway_size_quantities_sum()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_colorway uuid := coalesce(new.colorway_id, old.colorway_id);
begin
  update public.colorways c
     set quantity = coalesce((select sum(q.quantity) from public.colorway_size_quantities q where q.colorway_id = c.id), 0)
   where c.id = v_colorway
     and exists (select 1 from public.models m where m.id = c.model_id and m.size_chart_id is not null);
  return null;
end;
$$;

create trigger colorway_size_quantities_sum after insert or update or delete on public.colorway_size_quantities
  for each row execute function public.colorway_size_quantities_sum();

-- Changer de grille : réservé à l'offre Pro ; les quantités des tailles absentes de la nouvelle grille sont effacées.
create or replace function public.models_size_chart_guard()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  if tg_op = 'INSERT' and new.size_chart_id is null then
    return new;
  end if;
  if new.size_chart_id is not null and not exists (
    select 1 from public.size_charts sc where sc.id = new.size_chart_id and (sc.org_id is null or sc.org_id = new.org_id)
  ) then
    raise exception 'size_chart_not_found' using errcode = 'P0002';
  end if;
  if not public.has_pro(new.org_id) then
    raise exception 'pro_required' using errcode = '42501';
  end if;
  return new;
end;
$$;

create trigger models_size_chart_guard before insert or update of size_chart_id on public.models
  for each row execute function public.models_size_chart_guard();

create or replace function public.models_size_chart_cleanup()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  delete from public.colorway_size_quantities q
  using public.colorways c
  where c.id = q.colorway_id and c.model_id = new.id
    and not exists (select 1 from public.size_charts sc where sc.id = new.size_chart_id and q.size = any (sc.sizes));
  -- Nouvelle grille : la quantité de chaque coloris devient la somme de ses tailles.
  if new.size_chart_id is not null then
    update public.colorways c
       set quantity = coalesce((select sum(q.quantity) from public.colorway_size_quantities q where q.colorway_id = c.id), 0)
     where c.model_id = new.id;
  end if;
  return null;
end;
$$;

create trigger models_size_chart_cleanup after update of size_chart_id on public.models
  for each row when (old.size_chart_id is distinct from new.size_chart_id)
  execute function public.models_size_chart_cleanup();

-- Règles d'accès.
alter table public.size_charts enable row level security;
create policy "size_charts: lecture" on public.size_charts
  for select to authenticated using (org_id is null or org_id in (select public.my_org_ids('viewer')));
create policy "size_charts: écriture admins" on public.size_charts
  for all to authenticated
  using (org_id in (select public.my_org_ids('admin')))
  with check (org_id in (select public.my_org_ids('admin')));
revoke all on public.size_charts from anon, authenticated;
grant select, insert, update, delete on public.size_charts to authenticated;
grant all on public.size_charts to service_role;

alter table public.colorway_size_quantities enable row level security;
create policy "colorway_size_quantities: lecture membres" on public.colorway_size_quantities
  for select to authenticated using (org_id in (select public.my_org_ids('viewer')));
create policy "colorway_size_quantities: écriture éditeurs" on public.colorway_size_quantities
  for all to authenticated
  using (org_id in (select public.my_org_ids('editor')))
  with check (org_id in (select public.my_org_ids('editor')));
revoke all on public.colorway_size_quantities from anon, authenticated;
grant select, insert, update, delete on public.colorway_size_quantities to authenticated;
grant all on public.colorway_size_quantities to service_role;
