-- Données de démonstration pour le développement local (appliquées par `supabase db reset`).
-- Ne jamais utiliser en production.
--
--   super@filyxa.local   / Filyxa2027  → super-admin, sans atelier
--   claire@filyxa.local  / Filyxa2027  → Admin de « Atelier Démo »
--   lea@filyxa.local     / Filyxa2027  → Lectrice de « Atelier Démo »

with demo (id, email) as (
  values
    ('d0000000-0000-0000-0000-000000000001'::uuid, 'super@filyxa.local'),
    ('d0000000-0000-0000-0000-000000000002'::uuid, 'claire@filyxa.local'),
    ('d0000000-0000-0000-0000-000000000003'::uuid, 'lea@filyxa.local')
)
insert into auth.users (
  instance_id, id, aud, role, email, encrypted_password, email_confirmed_at,
  raw_app_meta_data, raw_user_meta_data, created_at, updated_at,
  confirmation_token, recovery_token, email_change_token_new, email_change,
  email_change_token_current, phone_change, phone_change_token, reauthentication_token
)
select
  '00000000-0000-0000-0000-000000000000', id, 'authenticated', 'authenticated',
  email, extensions.crypt('Filyxa2027', extensions.gen_salt('bf')), now(),
  '{"provider":"email","providers":["email"]}', '{}', now(), now(),
  '', '', '', '', '', '', '', ''
from demo;

insert into auth.identities (id, user_id, provider_id, provider, identity_data, created_at, updated_at, last_sign_in_at)
select
  gen_random_uuid(), u.id, u.id::text, 'email',
  jsonb_build_object('sub', u.id::text, 'email', u.email, 'email_verified', true),
  now(), now(), now()
from auth.users u
where u.email like '%@filyxa.local';

update public.profiles set is_superadmin = true
where id = 'd0000000-0000-0000-0000-000000000001';
update public.profiles set full_name = 'Claire Martin'
where id = 'd0000000-0000-0000-0000-000000000002';
update public.profiles set full_name = 'Léa Dubois'
where id = 'd0000000-0000-0000-0000-000000000003';

insert into public.organizations (id, name, kind)
values ('d1000000-0000-0000-0000-000000000001', 'Atelier Démo', 'atelier');

insert into public.memberships (user_id, org_id, role) values
  ('d0000000-0000-0000-0000-000000000002', 'd1000000-0000-0000-0000-000000000001', 'admin'),
  ('d0000000-0000-0000-0000-000000000003', 'd1000000-0000-0000-0000-000000000001', 'viewer');
