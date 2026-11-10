-- Filyxa — Phase 6 : compteur mensuel de scans et quota par organisation.
--
-- Chaque analyse d'étiquette par l'IA a un coût : elle est comptée par
-- organisation et par mois. Au-delà du quota (organizations.scan_quota), le scan
-- est refusé ; la saisie manuelle reste toujours possible.

create table public.usage_counters (
  org_id      uuid not null references public.organizations (id) on delete cascade,
  month       date not null check (month = date_trunc('month', month)::date),
  scans       integer not null default 0 check (scans >= 0),
  -- Coût estimé (jetons consommés), pour la console super-admin.
  input_tokens   bigint not null default 0,
  output_tokens  bigint not null default 0,
  updated_at  timestamptz not null default now(),
  primary key (org_id, month)
);

create trigger usage_counters_touch before update on public.usage_counters
  for each row execute function public.touch_updated_at();

-- Réserve un scan pour l'organisation, de façon atomique. Appelée par l'Edge
-- Function analyze-tag (droits d'administration) avant l'appel à l'IA.
-- Renvoie { scans, quota } après réservation ; erreur quota_exceeded si le
-- quota du mois est atteint.
create or replace function public.reserve_scan(p_org uuid)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_month date := date_trunc('month', now() at time zone 'utc')::date;
  v_quota integer;
  v_scans integer;
begin
  select scan_quota into v_quota from public.organizations where id = p_org and kind = 'atelier';
  if v_quota is null then
    raise exception 'not_an_atelier' using errcode = '42501';
  end if;

  insert into public.usage_counters (org_id, month, scans) values (p_org, v_month, 0)
  on conflict (org_id, month) do nothing;

  update public.usage_counters
  set scans = scans + 1
  where org_id = p_org and month = v_month and scans < v_quota
  returning scans into v_scans;

  if v_scans is null then
    raise exception 'quota_exceeded' using errcode = 'P0001';
  end if;
  return jsonb_build_object('scans', v_scans, 'quota', v_quota);
end;
$$;

-- Rend un scan réservé quand l'analyse n'a pas pu avoir lieu (panne du service IA).
create or replace function public.release_scan(p_org uuid)
returns void
language sql
security definer
set search_path = ''
as $$
  update public.usage_counters
  set scans = greatest(scans - 1, 0)
  where org_id = p_org and month = date_trunc('month', now() at time zone 'utc')::date;
$$;

-- Ajoute les jetons consommés par une analyse.
create or replace function public.record_scan_tokens(p_org uuid, p_input bigint, p_output bigint)
returns void
language sql
security definer
set search_path = ''
as $$
  update public.usage_counters
  set input_tokens = input_tokens + greatest(p_input, 0),
      output_tokens = output_tokens + greatest(p_output, 0)
  where org_id = p_org and month = date_trunc('month', now() at time zone 'utc')::date;
$$;

-- Usage du mois en cours, lisible par tout membre (avertissements dans l'app).
create or replace function public.current_scan_usage(p_org uuid)
returns jsonb
language sql
stable
security definer
set search_path = ''
as $$
  select case when public.has_role(p_org, 'viewer') or public.is_superadmin() then
    jsonb_build_object(
      'scans', coalesce((select u.scans from public.usage_counters u
                         where u.org_id = p_org
                           and u.month = date_trunc('month', now() at time zone 'utc')::date), 0),
      'quota', (select o.scan_quota from public.organizations o where o.id = p_org)
    )
  end;
$$;

alter table public.usage_counters enable row level security;

create policy "usage_counters: lecture membres" on public.usage_counters
  for select to authenticated
  using (org_id in (select public.my_org_ids('viewer')) or public.is_superadmin());

revoke all on public.usage_counters from anon, authenticated;
grant select on public.usage_counters to authenticated;
grant all on public.usage_counters to service_role;

-- Réservation et jetons : uniquement via analyze-tag (droits d'administration).
revoke execute on function public.reserve_scan(uuid) from public, anon, authenticated;
revoke execute on function public.release_scan(uuid) from public, anon, authenticated;
revoke execute on function public.record_scan_tokens(uuid, bigint, bigint) from public, anon, authenticated;
grant execute on function public.reserve_scan(uuid) to service_role;
grant execute on function public.release_scan(uuid) to service_role;
grant execute on function public.record_scan_tokens(uuid, bigint, bigint) to service_role;

revoke execute on function public.current_scan_usage(uuid) from public, anon;
grant execute on function public.current_scan_usage(uuid) to authenticated, service_role;
