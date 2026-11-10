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

-- Matières de démonstration de « Atelier Démo » (sans photo : aplat du coloris).
insert into public.materials (id, org_id, name, supplier_name, supplier_code, color_name, color_hex, atelier_stock_m, notes, created_by)
values
  ('d2000000-0000-0000-0000-000000000001', 'd1000000-0000-0000-0000-000000000001', 'Drap laine froide',
   'Dormeuil', 'DR4521-NV', 'Marine', '#2F4A6B', 42.5, 'Toucher sec et nerveux, tient bien le pli.',
   'd0000000-0000-0000-0000-000000000002'),
  ('d2000000-0000-0000-0000-000000000002', 'd1000000-0000-0000-0000-000000000001', 'Gabardine coton stretch',
   'Marzotto', 'MZ-GB-118', 'Camel', '#B9A58B', 12.5, null, 'd0000000-0000-0000-0000-000000000002'),
  ('d2000000-0000-0000-0000-000000000003', 'd1000000-0000-0000-0000-000000000001', 'Doublure viscose',
   null, null, 'Vert sapin', '#1E3B36', 120, null, 'd0000000-0000-0000-0000-000000000002');

insert into public.textile_specs (material_id, composition, weight_gsm, width_cm, weave, care, certifications, uses)
values
  ('d2000000-0000-0000-0000-000000000001', '[{"fiber":"WO","pct":62},{"fiber":"PES","pct":38}]', 280, 150, 'twill',
   '{wash_30,no_bleach,no_tumble,iron_low,dryclean_p}', '{RWS}', '{jacket,trousers}'),
  ('d2000000-0000-0000-0000-000000000002', '[{"fiber":"CO","pct":97},{"fiber":"EL","pct":3}]', 245, 148, 'twill',
   '{wash_40,iron_medium}', '{GOTS}', '{trousers,coat}'),
  ('d2000000-0000-0000-0000-000000000003', '[{"fiber":"CV","pct":100}]', 72, 140, 'plain',
   '{hand_wash,no_tumble,iron_low}', '{}', '{lining}');

-- Fournisseur de démonstration « Tissage Démo » (marco@filyxa.local / Filyxa2027, Admin).
with demo (id, email) as (
  values ('d0000000-0000-0000-0000-000000000004'::uuid, 'marco@filyxa.local')
)
insert into auth.users (
  instance_id, id, aud, role, email, encrypted_password, email_confirmed_at,
  raw_app_meta_data, raw_user_meta_data, created_at, updated_at,
  confirmation_token, recovery_token, email_change_token_new, email_change,
  email_change_token_current, phone_change, phone_change_token, reauthentication_token
)
select '00000000-0000-0000-0000-000000000000', id, 'authenticated', 'authenticated',
  email, extensions.crypt('Filyxa2027', extensions.gen_salt('bf')), now(),
  '{"provider":"email","providers":["email"]}', '{}', now(), now(), '', '', '', '', '', '', '', ''
from demo;

insert into auth.identities (id, user_id, provider_id, provider, identity_data, created_at, updated_at, last_sign_in_at)
select gen_random_uuid(), u.id, u.id::text, 'email',
  jsonb_build_object('sub', u.id::text, 'email', u.email, 'email_verified', true), now(), now(), now()
from auth.users u where u.email = 'marco@filyxa.local';

update public.profiles set full_name = 'Marco Rossi' where id = 'd0000000-0000-0000-0000-000000000004';

insert into public.organizations (id, name, kind)
values ('d1000000-0000-0000-0000-000000000002', 'Tissage Démo', 'supplier');
insert into public.memberships (user_id, org_id, role)
values ('d0000000-0000-0000-0000-000000000004', 'd1000000-0000-0000-0000-000000000002', 'admin');
insert into public.supplier_settings (org_id, availability_mode, low_stock_threshold_m)
values ('d1000000-0000-0000-0000-000000000002', 'tiers', 50);

insert into public.supplier_references
  (supplier_org_id, code, name, color_name, color_hex, composition, weight_gsm, width_cm, weave, care, certifications, uses, stock_m, lead_time_weeks)
values
  ('d1000000-0000-0000-0000-000000000002', 'TD-SRG-280', 'Sergé laine froide', 'Marine', '#2F4A6B',
   '[{"fiber":"WO","pct":62},{"fiber":"PES","pct":38}]', 280, 150, 'twill', '{wash_30,iron_low,dryclean_p}', '{RWS}', '{jacket,trousers}', 340, 4),
  ('d1000000-0000-0000-0000-000000000002', 'TD-POP-110', 'Popeline coton bio', 'Blanc', '#F4F2EC',
   '[{"fiber":"CO","pct":100}]', 110, 150, 'plain', '{wash_40,iron_medium}', '{GOTS}', '{shirt,dress}', 22, 3),
  ('d1000000-0000-0000-0000-000000000002', 'TD-VEL-320', 'Velours côtelé', 'Bordeaux', '#7A2E3A',
   '[{"fiber":"CO","pct":98},{"fiber":"EL","pct":2}]', 320, 145, 'corduroy', '{wash_30,no_tumble}', '{}', '{trousers,jacket}', 0, 6);
