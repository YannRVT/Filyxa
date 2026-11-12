-- Filyxa — Phase 16 : échéances, planning de collection et notification de retard.
--
-- Chaque étape d'un modèle (Prototype, Validé, En production, Livré) peut recevoir
-- une échéance : la date à laquelle le modèle doit l'avoir atteinte. Une échéance
-- est dépassée quand la date est passée et que le modèle n'a pas encore atteint
-- l'étape (un modèle Abandonné n'a plus d'échéance). Le jour du dépassement,
-- chaque membre de l'atelier reçoit une notification, une seule fois par échéance
-- (une nouvelle date réarme la notification). Réservé à l'offre Pro.

alter table public.notifications drop constraint notifications_kind_check;
alter table public.notifications add constraint notifications_kind_check check (kind in (
  'report_new', 'report_fixed', 'report_rejected',
  'stock_low', 'stock_out', 'reference_updated', 'reference_retired',
  'deadline_overdue'
));

-- Rang d'avancement d'un statut (Abandonné hors échelle).
create or replace function public.model_status_rank(p_status public.model_status)
returns integer
language sql
immutable
set search_path = ''
as $$
  select case p_status
    when 'idea' then 0 when 'prototype' then 1 when 'validated' then 2
    when 'in_production' then 3 when 'delivered' then 4 else null end;
$$;

create table public.model_deadlines (
  model_id     uuid not null references public.models (id) on delete cascade,
  stage        public.model_status not null check (stage in ('prototype', 'validated', 'in_production', 'delivered')),
  org_id       uuid not null references public.organizations (id) on delete cascade,
  due_date     date not null,
  notified_at  timestamptz,
  primary key (model_id, stage)
);
create index model_deadlines_due_idx on public.model_deadlines (due_date) where notified_at is null;

-- org_id recopié depuis le modèle ; écriture réservée à l'offre Pro ; une nouvelle date réarme la notification.
create or replace function public.model_deadlines_guard()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_org uuid;
begin
  if tg_op = 'DELETE' then
    -- Suppression du modèle (cascade) : toujours permise, même hors Pro.
    if not exists (select 1 from public.models where id = old.model_id) then
      return old;
    end if;
    v_org := old.org_id;
  else
    select org_id into v_org from public.models where id = new.model_id;
    if v_org is null then
      raise exception 'parent_not_found' using errcode = 'P0002';
    end if;
    new.org_id := v_org;
    if tg_op = 'UPDATE' and new.due_date is distinct from old.due_date then
      new.notified_at := null;
    end if;
  end if;
  if not public.has_pro(v_org) then
    raise exception 'pro_required' using errcode = '42501';
  end if;
  return case when tg_op = 'DELETE' then old else new end;
end;
$$;

create trigger model_deadlines_guard before insert or update or delete on public.model_deadlines
  for each row execute function public.model_deadlines_guard();

alter table public.model_deadlines enable row level security;
create policy "model_deadlines: lecture membres" on public.model_deadlines
  for select to authenticated using (org_id in (select public.my_org_ids('viewer')));
create policy "model_deadlines: écriture éditeurs" on public.model_deadlines
  for all to authenticated
  using (org_id in (select public.my_org_ids('editor')))
  with check (org_id in (select public.my_org_ids('editor')));
revoke all on public.model_deadlines from anon, authenticated;
grant select, insert, update, delete on public.model_deadlines to authenticated;
grant all on public.model_deadlines to service_role;

-- Notifie les échéances dépassées (date passée, étape non atteinte, modèle ni livré ni abandonné).
-- Lancée toutes les heures : la notification part le jour du dépassement.
create or replace function public.notify_overdue_deadlines(p_today date default null)
returns integer
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_today date := coalesce(p_today, (now() at time zone 'Europe/Paris')::date);
  v_count integer := 0;
  rec record;
begin
  for rec in
    select d.model_id, d.stage, d.org_id, d.due_date, m.name
    from public.model_deadlines d
    join public.models m on m.id = d.model_id
    where d.notified_at is null
      and d.due_date < v_today
      and m.status not in ('delivered', 'abandoned')
      and public.model_status_rank(m.status) < public.model_status_rank(d.stage)
      and public.has_pro(d.org_id)
    for update of d skip locked
  loop
    insert into public.notifications (user_id, org_id, kind, data)
    select mb.user_id, rec.org_id, 'deadline_overdue',
           jsonb_build_object('model_id', rec.model_id, 'name', rec.name, 'stage', rec.stage, 'due_date', rec.due_date)
    from public.memberships mb
    where mb.org_id = rec.org_id;
    update public.model_deadlines set notified_at = now() where model_id = rec.model_id and stage = rec.stage;
    v_count := v_count + 1;
  end loop;
  return v_count;
end;
$$;
revoke execute on function public.notify_overdue_deadlines(date) from public, anon, authenticated;

create extension if not exists pg_cron;
select cron.schedule('notify-overdue-deadlines', '5 * * * *', 'select public.notify_overdue_deadlines()');
