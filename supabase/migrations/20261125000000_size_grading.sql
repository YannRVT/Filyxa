-- Filyxa — Phase 18 : gradation — besoin par taille.
--
-- La consommation saisie est celle de la taille de base. Chaque taille s'en
-- écarte de grade_pct % par taille d'écart (+ au-dessus, − en dessous), sauf
-- écart propre à une taille (model_size_grades, écart total par rapport à la
-- base). Sans taille de base choisie, c'est la taille du milieu de la grille.
-- Besoin d'une taille = consommation de base × (1 + écart) × quantité × (1 + marge).
-- Réservé à l'offre Pro.

alter table public.models
  add column base_size text check (base_size is null or char_length(base_size) <= 12),
  add column grade_pct numeric(5, 2) not null default 4 check (grade_pct between -50 and 50);

create table public.model_size_grades (
  model_id   uuid not null references public.models (id) on delete cascade,
  size       text not null,
  org_id     uuid not null references public.organizations (id) on delete cascade,
  -- Écart total de cette taille par rapport à la taille de base, en %.
  grade_pct  numeric(6, 2) not null check (grade_pct between -90 and 300),
  primary key (model_id, size)
);

-- Taille de base dans la grille, écart du modèle : offre Pro.
create or replace function public.models_grading_guard()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  if new.base_size is not distinct from old.base_size and new.grade_pct = old.grade_pct then
    return new;
  end if;
  if not public.has_pro(new.org_id) then
    raise exception 'pro_required' using errcode = '42501';
  end if;
  if new.base_size is not null and not exists (
    select 1 from public.size_charts sc where sc.id = new.size_chart_id and new.base_size = any (sc.sizes)
  ) then
    raise exception 'size_not_in_chart' using errcode = '22023';
  end if;
  return new;
end;
$$;

create trigger models_grading_guard before update of base_size, grade_pct on public.models
  for each row execute function public.models_grading_guard();

create or replace function public.model_size_grades_guard()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_org uuid;
  v_sizes text[];
begin
  select m.org_id, sc.sizes into v_org, v_sizes
  from public.models m left join public.size_charts sc on sc.id = m.size_chart_id
  where m.id = new.model_id;
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

create trigger model_size_grades_guard before insert or update on public.model_size_grades
  for each row execute function public.model_size_grades_guard();

-- Changer de grille : la taille de base et les écarts propres qui n'existent plus disparaissent.
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
  delete from public.model_size_grades g
  where g.model_id = new.id
    and not exists (select 1 from public.size_charts sc where sc.id = new.size_chart_id and g.size = any (sc.sizes));
  if new.base_size is not null and not exists (
    select 1 from public.size_charts sc where sc.id = new.size_chart_id and new.base_size = any (sc.sizes)
  ) then
    update public.models set base_size = null where id = new.id;
  end if;
  -- Nouvelle grille : la quantité de chaque coloris devient la somme de ses tailles.
  if new.size_chart_id is not null then
    update public.colorways c
       set quantity = coalesce((select sum(q.quantity) from public.colorway_size_quantities q where q.colorway_id = c.id), 0)
     where c.model_id = new.id;
  end if;
  return null;
end;
$$;

alter table public.model_size_grades enable row level security;
create policy "model_size_grades: lecture membres" on public.model_size_grades
  for select to authenticated using (org_id in (select public.my_org_ids('viewer')));
create policy "model_size_grades: écriture éditeurs" on public.model_size_grades
  for all to authenticated
  using (org_id in (select public.my_org_ids('editor')))
  with check (org_id in (select public.my_org_ids('editor')));
revoke all on public.model_size_grades from anon, authenticated;
grant select, insert, update, delete on public.model_size_grades to authenticated;
grant all on public.model_size_grades to service_role;
