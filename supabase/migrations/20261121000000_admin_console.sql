-- Filyxa — Phase 14 : console super-admin — offres, quotas et usage.
--
-- Le super-admin change l'offre ou le quota de scans d'une organisation : le
-- scanner lit organizations.scan_quota à chaque scan, le changement s'applique
-- donc immédiatement. Il consulte l'usage du mois (scans, membres, références)
-- et le coût estimé de l'IA, calculé à partir des jetons consommés et du tarif
-- du modèle (modifiable, en dollars par million de jetons).
-- Toutes ces fonctions refusent tout compte qui n'est pas super-admin.

-- Offres : quota de scans mensuel par défaut ; « custom » garde un quota saisi à la main.
create table public.plans (
  code               text primary key,
  default_scan_quota integer check (default_scan_quota is null or default_scan_quota >= 0),
  position           integer not null default 0
);

insert into public.plans (code, default_scan_quota, position) values
  ('pilot', 300, 0),
  ('essential', 1000, 1),
  ('pro', 3000, 2),
  ('custom', null, 3);

update public.organizations set plan = 'pilot' where plan not in (select code from public.plans);
alter table public.organizations
  add constraint organizations_plan_fkey foreign key (plan) references public.plans (code);

alter table public.plans enable row level security;
create policy "plans: lecture" on public.plans for select to authenticated using (true);
revoke all on public.plans from anon, authenticated;
grant select on public.plans to authenticated;
grant all on public.plans to service_role;

-- Réglages de la plateforme (une seule ligne).
create table public.platform_settings (
  id                      boolean primary key default true check (id),
  -- Tarif du modèle d'analyse d'étiquettes (Claude Opus 5.5 : 4 $ / 20 $ par million de jetons).
  ai_input_usd_per_mtok   numeric(10, 4) not null default 4 check (ai_input_usd_per_mtok >= 0),
  ai_output_usd_per_mtok  numeric(10, 4) not null default 20 check (ai_output_usd_per_mtok >= 0),
  updated_at              timestamptz not null default now()
);
insert into public.platform_settings default values;

create trigger platform_settings_touch before update on public.platform_settings
  for each row execute function public.touch_updated_at();

alter table public.platform_settings enable row level security;
create policy "platform_settings: super-admin" on public.platform_settings
  for all to authenticated using (public.is_superadmin()) with check (public.is_superadmin());
revoke all on public.platform_settings from anon, authenticated;
grant select, update (ai_input_usd_per_mtok, ai_output_usd_per_mtok) on public.platform_settings to authenticated;
grant all on public.platform_settings to service_role;

-- Changer l'offre et/ou le quota d'une organisation (effet immédiat sur le scanner).
-- p_quota null : quota par défaut de l'offre (obligatoire pour « custom »).
create or replace function public.admin_set_plan(p_org uuid, p_plan text, p_quota integer default null)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_default integer;
  v_quota integer;
begin
  if not public.is_superadmin() then
    raise exception 'forbidden' using errcode = '42501';
  end if;
  select default_scan_quota into v_default from public.plans where code = p_plan;
  if not found then
    raise exception 'unknown_plan' using errcode = '22023';
  end if;
  v_quota := coalesce(p_quota, v_default);
  if v_quota is null or v_quota < 0 then
    raise exception 'quota_required' using errcode = '22023';
  end if;
  update public.organizations set plan = p_plan, scan_quota = v_quota where id = p_org;
  if not found then
    raise exception 'organization_not_found' using errcode = 'P0002';
  end if;
  return jsonb_build_object('plan', p_plan, 'scan_quota', v_quota);
end;
$$;

-- Usage d'un mois, par organisation : scans, membres, références, jetons et coût estimé.
create or replace function public.admin_usage(p_month date default null)
returns table (
  org_id uuid, name text, kind public.org_kind, plan text, scan_quota integer, scans integer,
  members integer, items integer, input_tokens bigint, output_tokens bigint, cost_usd numeric
)
language plpgsql
stable
security definer
set search_path = ''
as $$
declare
  v_month date := date_trunc('month', coalesce(p_month, (now() at time zone 'utc')::date))::date;
  s public.platform_settings;
begin
  if not public.is_superadmin() then
    raise exception 'forbidden' using errcode = '42501';
  end if;
  select * into s from public.platform_settings where id;
  return query
  select o.id, o.name, o.kind, o.plan, o.scan_quota,
    coalesce(u.scans, 0),
    (select count(*)::int from public.memberships m where m.org_id = o.id),
    -- Atelier : matières de TissuTech ; fournisseur : références publiées.
    case when o.kind = 'atelier'
      then (select count(*)::int from public.materials x where x.org_id = o.id)
      else (select count(*)::int from public.supplier_references r where r.supplier_org_id = o.id and r.retired_at is null)
    end,
    coalesce(u.input_tokens, 0),
    coalesce(u.output_tokens, 0),
    round((coalesce(u.input_tokens, 0) * s.ai_input_usd_per_mtok
           + coalesce(u.output_tokens, 0) * s.ai_output_usd_per_mtok) / 1000000.0, 4)
  from public.organizations o
  left join public.usage_counters u on u.org_id = o.id and u.month = v_month
  order by o.name;
end;
$$;

revoke execute on function public.admin_set_plan(uuid, text, integer) from public, anon;
grant execute on function public.admin_set_plan(uuid, text, integer) to authenticated;
revoke execute on function public.admin_usage(date) from public, anon;
grant execute on function public.admin_usage(date) to authenticated;
