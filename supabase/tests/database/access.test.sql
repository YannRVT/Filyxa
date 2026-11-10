-- Tests des règles d'accès de la phase 1 (pgTAP).
-- Lancement : supabase start && supabase test db
begin;
create extension if not exists pgtap with schema extensions;

select plan(14);

-- Jeu de données : deux ateliers, un membre chacun, un super-admin, un invité.
insert into auth.users (id, email) values
  ('00000000-0000-0000-0000-00000000000a', 'claire@atelier-a.fr'),
  ('00000000-0000-0000-0000-00000000000b', 'marc@atelier-b.fr'),
  ('00000000-0000-0000-0000-00000000000c', 'super@filyxa.test'),
  ('00000000-0000-0000-0000-00000000000d', 'nouveau@atelier-a.fr'),
  ('00000000-0000-0000-0000-00000000000e', 'tard@atelier-a.fr');

update public.profiles set is_superadmin = true where id = '00000000-0000-0000-0000-00000000000c';

insert into public.organizations (id, name, kind) values
  ('10000000-0000-0000-0000-00000000000a', 'Atelier A', 'atelier'),
  ('10000000-0000-0000-0000-00000000000b', 'Atelier B', 'atelier');

insert into public.memberships (user_id, org_id, role) values
  ('00000000-0000-0000-0000-00000000000a', '10000000-0000-0000-0000-00000000000a', 'admin'),
  ('00000000-0000-0000-0000-00000000000b', '10000000-0000-0000-0000-00000000000b', 'viewer');

insert into public.invitations (org_id, email, role) values
  ('10000000-0000-0000-0000-00000000000a', 'nouveau@atelier-a.fr', 'editor');
insert into public.invitations (org_id, email, role, expires_at) values
  ('10000000-0000-0000-0000-00000000000a', 'tard@atelier-a.fr', 'editor', now() - interval '1 hour');

-- Le trigger crée un profil par compte.
select is((select count(*)::int from public.profiles
            where id::text like '00000000-0000-0000-0000-00000000000_'), 5,
  'un profil par compte créé');

-- Membre de l'atelier A ------------------------------------------------------
set local role authenticated;
select set_config('request.jwt.claims',
  '{"sub":"00000000-0000-0000-0000-00000000000a","email":"claire@atelier-a.fr","role":"authenticated"}', true);

select results_eq(
  'select name from public.organizations',
  array['Atelier A'],
  'un membre ne voit que son organisation');
select is((select count(*)::int from public.memberships), 1,
  'un membre ne voit que les appartenances de son organisation');
select is((select count(*)::int from public.profiles where email = 'marc@atelier-b.fr'), 0,
  'un membre ne voit pas les profils d''une autre organisation');
select is((select count(*)::int from public.invitations), 2,
  'un admin voit les invitations de son organisation');
select throws_ok(
  $$insert into public.organizations (name, kind) values ('Pirate', 'atelier')$$,
  '42501', null, 'aucune création d''organisation depuis le client');
select throws_ok(
  $$update public.profiles set is_superadmin = true where id = auth.uid()$$,
  '42501', null, 'impossible de se déclarer super-admin');
select lives_ok(
  $$update public.profiles set locale = 'ro' where id = auth.uid()$$,
  'la langue de son profil est modifiable');

-- Membre Lecteur de l'atelier B ----------------------------------------------
select set_config('request.jwt.claims',
  '{"sub":"00000000-0000-0000-0000-00000000000b","email":"marc@atelier-b.fr","role":"authenticated"}', true);
select is((select count(*)::int from public.invitations), 0,
  'un Lecteur ne voit pas les invitations');

-- Super-admin -----------------------------------------------------------------
select set_config('request.jwt.claims',
  '{"sub":"00000000-0000-0000-0000-00000000000c","email":"super@filyxa.test","role":"authenticated"}', true);
select is((select count(*)::int from public.organizations
            where id in ('10000000-0000-0000-0000-00000000000a', '10000000-0000-0000-0000-00000000000b')),
  2, 'le super-admin voit toutes les organisations');

-- Invité : acceptation valide --------------------------------------------------
select set_config('request.jwt.claims',
  '{"sub":"00000000-0000-0000-0000-00000000000d","email":"nouveau@atelier-a.fr","role":"authenticated"}', true);
select is(public.accept_invitation(), '10000000-0000-0000-0000-00000000000a'::uuid,
  'l''invitation valide rattache à l''organisation');
select results_eq(
  'select role::text from public.memberships where user_id = auth.uid()',
  array['editor'],
  'le rôle de l''invitation est appliqué');

-- Invité : invitation expirée --------------------------------------------------
select set_config('request.jwt.claims',
  '{"sub":"00000000-0000-0000-0000-00000000000e","email":"tard@atelier-a.fr","role":"authenticated"}', true);
select throws_ok('select public.accept_invitation()', 'P0001', 'invitation_expired',
  'une invitation expirée est refusée');

-- Sans invitation ---------------------------------------------------------------
select set_config('request.jwt.claims',
  '{"sub":"00000000-0000-0000-0000-00000000000b","email":"marc@atelier-b.fr","role":"authenticated"}', true);
select throws_ok('select public.accept_invitation()', 'P0002', 'invitation_not_found',
  'sans invitation, rien n''est créé');

select * from finish();
rollback;
