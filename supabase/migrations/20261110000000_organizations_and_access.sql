-- Filyxa — Phase 1 : organisations, appartenances, invitations, profils.
--
-- Principe d'accès : toute lecture passe par l'appartenance (public.memberships)
-- et la fonction public.has_role(). Les écritures sensibles (création
-- d'organisation, invitations, rôles) passent par l'Edge Function admin-users,
-- qui seule utilise les droits d'administration de la base.

-- Types -----------------------------------------------------------------------
create type public.org_kind as enum ('atelier', 'supplier');
create type public.member_role as enum ('admin', 'editor', 'viewer');

-- Organisations ---------------------------------------------------------------
create table public.organizations (
  id          uuid primary key default gen_random_uuid(),
  name        text not null check (char_length(btrim(name)) between 2 and 120),
  kind        public.org_kind not null,
  plan        text not null default 'pilot',
  scan_quota  integer not null default 300 check (scan_quota >= 0),
  created_by  uuid references auth.users (id) on delete set null,
  created_at  timestamptz not null default now()
);

-- Profils ---------------------------------------------------------------------
create table public.profiles (
  id             uuid primary key references auth.users (id) on delete cascade,
  email          text not null,
  full_name      text check (full_name is null or char_length(full_name) <= 120),
  locale         text not null default 'fr'
                   check (locale in ('fr', 'en', 'it', 'es', 'pt', 'ro')),
  is_superadmin  boolean not null default false,
  created_at     timestamptz not null default now()
);

-- Appartenances ---------------------------------------------------------------
create table public.memberships (
  user_id     uuid not null references auth.users (id) on delete cascade,
  org_id      uuid not null references public.organizations (id) on delete cascade,
  role        public.member_role not null,
  created_at  timestamptz not null default now(),
  primary key (user_id, org_id)
);

-- V1 : une personne appartient à une seule organisation. Le schéma accepte
-- déjà plusieurs organisations ; retirer cet index suffira à les autoriser.
create unique index memberships_one_org_per_user on public.memberships (user_id);
create index memberships_org_idx on public.memberships (org_id);

-- Invitations -----------------------------------------------------------------
create table public.invitations (
  id           uuid primary key default gen_random_uuid(),
  org_id       uuid not null references public.organizations (id) on delete cascade,
  email        text not null check (email = lower(btrim(email)) and email like '%_@_%._%'),
  role         public.member_role not null,
  invited_by   uuid references auth.users (id) on delete set null,
  created_at   timestamptz not null default now(),
  expires_at   timestamptz not null default now() + interval '48 hours',
  accepted_at  timestamptz,
  revoked_at   timestamptz
);

-- Une seule invitation en attente par adresse.
create unique index invitations_one_pending_per_email
  on public.invitations (email)
  where accepted_at is null and revoked_at is null;
create index invitations_org_idx on public.invitations (org_id);

-- Fonctions d'autorisation ----------------------------------------------------
create or replace function public.is_superadmin()
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select coalesce(
    (select p.is_superadmin from public.profiles p where p.id = auth.uid()),
    false
  );
$$;

-- Rang d'un rôle : admin (3) > editor (2) > viewer (1).
create or replace function public.role_rank(r public.member_role)
returns integer
language sql
immutable
set search_path = ''
as $$
  select case r when 'admin' then 3 when 'editor' then 2 else 1 end;
$$;

-- Vrai si l'utilisateur connecté appartient à l'organisation avec au moins ce rôle.
create or replace function public.has_role(target_org uuid, min_role public.member_role)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1
    from public.memberships m
    where m.org_id = target_org
      and m.user_id = auth.uid()
      and public.role_rank(m.role) >= public.role_rank(min_role)
  );
$$;

-- Acceptation d'une invitation par l'utilisateur connecté (après vérification
-- du code). Retourne l'organisation rejointe.
-- Erreurs : invitation_not_found, invitation_expired, already_member.
create or replace function public.accept_invitation()
returns uuid
language plpgsql
security definer
set search_path = ''
as $$
declare
  me_email text := lower(coalesce(auth.jwt() ->> 'email', ''));
  inv public.invitations;
begin
  if auth.uid() is null then
    raise exception 'not_authenticated' using errcode = '28000';
  end if;

  select * into inv
  from public.invitations i
  where i.email = me_email and i.accepted_at is null and i.revoked_at is null
  order by i.created_at desc
  limit 1
  for update;

  if not found then
    raise exception 'invitation_not_found' using errcode = 'P0002';
  end if;
  if inv.expires_at < now() then
    raise exception 'invitation_expired' using errcode = 'P0001';
  end if;
  if exists (select 1 from public.memberships m where m.user_id = auth.uid()) then
    raise exception 'already_member' using errcode = '23505';
  end if;

  insert into public.memberships (user_id, org_id, role)
  values (auth.uid(), inv.org_id, inv.role);

  update public.invitations set accepted_at = now() where id = inv.id;
  return inv.org_id;
end;
$$;

revoke execute on function public.accept_invitation() from public, anon;
grant execute on function public.accept_invitation() to authenticated;

-- Création du profil à la création du compte. Aucun privilège n'est lu
-- depuis les métadonnées fournies par le client.
create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  insert into public.profiles (id, email)
  values (new.id, lower(new.email))
  on conflict (id) do nothing;
  return new;
end;
$$;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

create or replace function public.handle_user_email_change()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  update public.profiles set email = lower(new.email) where id = new.id;
  return new;
end;
$$;

create trigger on_auth_user_email_changed
  after update of email on auth.users
  for each row when (old.email is distinct from new.email)
  execute function public.handle_user_email_change();

-- Règles d'accès --------------------------------------------------------------
alter table public.organizations enable row level security;
alter table public.profiles      enable row level security;
alter table public.memberships   enable row level security;
alter table public.invitations   enable row level security;

-- Organisations : lecture par les membres et le super-admin ; écriture via admin-users.
create policy "organizations: lecture membres" on public.organizations
  for select to authenticated
  using (public.has_role(id, 'viewer') or public.is_superadmin());

-- Profils : son profil, ceux des membres de son organisation, tous pour le super-admin.
create policy "profiles: lecture" on public.profiles
  for select to authenticated
  using (
    id = auth.uid()
    or public.is_superadmin()
    or exists (
      select 1
      from public.memberships mine
      join public.memberships theirs on theirs.org_id = mine.org_id
      where mine.user_id = auth.uid() and theirs.user_id = profiles.id
    )
  );

create policy "profiles: modification de son profil" on public.profiles
  for update to authenticated
  using (id = auth.uid())
  with check (id = auth.uid());

-- Appartenances : lecture par les membres de l'organisation et le super-admin.
create policy "memberships: lecture membres" on public.memberships
  for select to authenticated
  using (public.has_role(org_id, 'viewer') or public.is_superadmin());

-- Invitations : lecture par les admins de l'organisation et le super-admin.
create policy "invitations: lecture admins" on public.invitations
  for select to authenticated
  using (public.has_role(org_id, 'admin') or public.is_superadmin());

-- Privilèges explicites : les nouvelles tables ne sont pas exposées par défaut.
-- Lecture seule pour les comptes connectés (filtrée par les règles ci-dessus),
-- rien pour les visiteurs anonymes. Les écritures passent par admin-users,
-- sauf le nom et la langue de son propre profil.
revoke all on public.organizations, public.profiles, public.memberships, public.invitations
  from anon, authenticated;
grant select on public.organizations, public.memberships, public.invitations to authenticated;
grant select on public.profiles to authenticated;
grant update (full_name, locale) on public.profiles to authenticated;
grant all on public.organizations, public.profiles, public.memberships, public.invitations
  to service_role;

revoke execute on function public.is_superadmin(), public.role_rank(public.member_role),
  public.has_role(uuid, public.member_role) from public, anon;
grant execute on function public.is_superadmin(), public.role_rank(public.member_role),
  public.has_role(uuid, public.member_role) to authenticated, service_role;
