-- Filyxa — Phase 9 : signalements d'erreur et notifications dans l'app.
--
-- Depuis une matière liée, un Éditeur signale une erreur sur un champ de la
-- référence fournisseur (valeur constatée, commentaire facultatif). Le
-- fournisseur la voit sans le nom de l'atelier, sauf si celui-ci a choisi de le
-- partager. Il la passe à « Corrigé » ou « Rejeté » (motif obligatoire).
-- L'atelier voit le statut sur sa fiche et reçoit une notification.
--
-- Les ateliers et les fournisseurs n'écrivent jamais directement dans ces
-- tables : tout passe par les fonctions ci-dessous, qui vérifient les droits.

create type public.report_field as enum (
  'name', 'color', 'composition', 'weight', 'width', 'weave', 'care', 'certifications', 'uses',
  'availability', 'other'
);
create type public.report_status as enum ('open', 'fixed', 'rejected');

create table public.error_reports (
  id               uuid primary key default gen_random_uuid(),
  reference_id     uuid not null references public.supplier_references (id) on delete cascade,
  supplier_org_id  uuid not null references public.organizations (id) on delete cascade,
  atelier_org_id   uuid not null references public.organizations (id) on delete cascade,
  material_id      uuid references public.materials (id) on delete set null,
  field            public.report_field not null,
  observed_value   text not null check (char_length(btrim(observed_value)) between 1 and 500),
  comment          text check (comment is null or char_length(comment) <= 2000),
  -- Identité de l'atelier visible par le fournisseur (désactivé par défaut).
  share_identity   boolean not null default false,
  status           public.report_status not null default 'open',
  response         text check (response is null or char_length(response) <= 2000),
  created_by       uuid references auth.users (id) on delete set null,
  created_at       timestamptz not null default now(),
  resolved_at      timestamptz,
  constraint rejected_has_reason check (status <> 'rejected' or char_length(btrim(coalesce(response, ''))) > 0)
);

create index error_reports_supplier_idx on public.error_reports (supplier_org_id, status, created_at desc);
create index error_reports_material_idx on public.error_reports (material_id, created_at desc);

alter table public.error_reports enable row level security;

-- L'atelier lit ses propres signalements. Le fournisseur passe par
-- supplier_error_reports() qui masque l'atelier.
create policy "error_reports: lecture atelier" on public.error_reports
  for select to authenticated using (public.has_role(atelier_org_id, 'viewer'));

-- Notifications dans l'app, une ligne par destinataire.
create table public.notifications (
  id           uuid primary key default gen_random_uuid(),
  user_id      uuid not null references auth.users (id) on delete cascade,
  org_id       uuid not null references public.organizations (id) on delete cascade,
  -- report_new (fournisseur) · report_fixed / report_rejected (atelier)
  kind         text not null check (kind in ('report_new', 'report_fixed', 'report_rejected')),
  report_id    uuid references public.error_reports (id) on delete cascade,
  material_id  uuid references public.materials (id) on delete cascade,
  reference_id uuid references public.supplier_references (id) on delete cascade,
  -- Textes figés au moment de l'événement (nom de matière, code…).
  data         jsonb not null default '{}'::jsonb,
  created_at   timestamptz not null default now(),
  read_at      timestamptz
);

create index notifications_user_idx on public.notifications (user_id, created_at desc);
create index notifications_unread_idx on public.notifications (user_id) where read_at is null;

alter table public.notifications enable row level security;

create policy "notifications: lecture destinataire" on public.notifications
  for select to authenticated using (user_id = auth.uid());
create policy "notifications: marquer lue" on public.notifications
  for update to authenticated using (user_id = auth.uid()) with check (user_id = auth.uid());
-- Lecture seule pour les utilisateurs ; seule la date de lecture d'une notification se modifie.
revoke all on public.error_reports, public.notifications from anon, authenticated;
grant select on public.error_reports, public.notifications to authenticated;
grant update (read_at) on public.notifications to authenticated;
grant all on public.error_reports, public.notifications to service_role;

-- Notifie chaque membre d'une organisation.
create or replace function public.notify_org(
  p_org uuid, p_kind text, p_report uuid, p_material uuid, p_reference uuid, p_data jsonb
)
returns void
language sql
security definer
set search_path = ''
as $$
  insert into public.notifications (user_id, org_id, kind, report_id, material_id, reference_id, data)
  select m.user_id, p_org, p_kind, p_report, p_material, p_reference, p_data
  from public.memberships m
  where m.org_id = p_org;
$$;

revoke execute on function public.notify_org(uuid, text, uuid, uuid, uuid, jsonb) from public, anon, authenticated;

-- Atelier : signaler une erreur sur la référence liée à une matière.
create or replace function public.create_error_report(
  p_material uuid, p_field public.report_field, p_observed text, p_comment text default null,
  p_share_identity boolean default false
)
returns uuid
language plpgsql
security definer
set search_path = ''
as $$
declare
  m public.materials;
  r public.supplier_references;
  v_id uuid;
begin
  select * into m from public.materials where id = p_material;
  if not found or not public.has_role(m.org_id, 'editor') then
    raise exception 'forbidden' using errcode = '42501';
  end if;
  if m.supplier_reference_id is null then
    raise exception 'material_not_linked' using errcode = '22023';
  end if;
  select * into r from public.supplier_references where id = m.supplier_reference_id;
  if not found or r.retired_at is not null then
    raise exception 'reference_not_available' using errcode = 'P0002';
  end if;

  insert into public.error_reports (
    reference_id, supplier_org_id, atelier_org_id, material_id, field, observed_value, comment,
    share_identity, created_by
  ) values (
    r.id, r.supplier_org_id, m.org_id, m.id, p_field, btrim(p_observed), nullif(btrim(p_comment), ''),
    coalesce(p_share_identity, false), auth.uid()
  )
  returning id into v_id;

  perform public.notify_org(r.supplier_org_id, 'report_new', v_id, null, r.id,
    jsonb_build_object('code', r.code, 'name', r.name, 'field', p_field));
  return v_id;
end;
$$;

revoke execute on function public.create_error_report(uuid, public.report_field, text, text, boolean) from public, anon;
grant execute on function public.create_error_report(uuid, public.report_field, text, text, boolean) to authenticated;

-- Fournisseur : ses signalements, sans l'atelier sauf partage choisi par celui-ci.
create or replace function public.supplier_error_reports(p_org uuid)
returns table (
  id uuid, reference_id uuid, reference_code text, reference_name text, field public.report_field,
  observed_value text, comment text, atelier_name text, status public.report_status, response text,
  created_at timestamptz, resolved_at timestamptz
)
language sql
stable
security definer
set search_path = ''
as $$
  select e.id, e.reference_id, r.code, r.name, e.field, e.observed_value, e.comment,
    case when e.share_identity then o.name end,
    e.status, e.response, e.created_at, e.resolved_at
  from public.error_reports e
  join public.supplier_references r on r.id = e.reference_id
  join public.organizations o on o.id = e.atelier_org_id
  where e.supplier_org_id = p_org and public.has_role(p_org, 'viewer')
  order by (e.status = 'open') desc, e.created_at desc;
$$;

revoke execute on function public.supplier_error_reports(uuid) from public, anon;
grant execute on function public.supplier_error_reports(uuid) to authenticated;

-- Fournisseur : corriger ou rejeter (motif obligatoire), une seule fois.
create or replace function public.resolve_error_report(
  p_report uuid, p_status public.report_status, p_response text default null
)
returns void
language plpgsql
security definer
set search_path = ''
as $$
declare
  e public.error_reports;
  r public.supplier_references;
  v_material_name text;
begin
  select * into e from public.error_reports where id = p_report;
  if not found or not public.has_role(e.supplier_org_id, 'editor') then
    raise exception 'forbidden' using errcode = '42501';
  end if;
  if p_status = 'open' then
    raise exception 'invalid_status' using errcode = '22023';
  end if;
  if e.status <> 'open' then
    raise exception 'report_already_resolved' using errcode = '22023';
  end if;
  if p_status = 'rejected' and char_length(btrim(coalesce(p_response, ''))) = 0 then
    raise exception 'reason_required' using errcode = '22023';
  end if;

  update public.error_reports set
    status = p_status, response = nullif(btrim(p_response), ''), resolved_at = now()
  where id = p_report;

  select * into r from public.supplier_references where id = e.reference_id;
  select name into v_material_name from public.materials where id = e.material_id;
  perform public.notify_org(e.atelier_org_id,
    case when p_status = 'fixed' then 'report_fixed' else 'report_rejected' end,
    e.id, e.material_id, e.reference_id,
    jsonb_build_object('code', r.code, 'name', coalesce(v_material_name, r.name), 'field', e.field,
                       'response', nullif(btrim(p_response), '')));
end;
$$;

revoke execute on function public.resolve_error_report(uuid, public.report_status, text) from public, anon;
grant execute on function public.resolve_error_report(uuid, public.report_status, text) to authenticated;
