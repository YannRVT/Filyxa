-- Tests de la réservation et de la déduction du stock (phase 20).
begin;
create extension if not exists pgtap with schema extensions;
select plan(14);

insert into auth.users (id, email) values
  ('00000000-0000-0000-0000-000000000a12', 'claire@resa.test'),
  ('00000000-0000-0000-0000-000000000a13', 'lea@resa.test'),
  ('00000000-0000-0000-0000-000000000a15', 'autre@resa.test');
insert into public.organizations (id, name, kind, plan) values
  ('a5000000-0000-0000-0000-00000000000a', 'Atelier Résa', 'atelier', 'pro'),
  ('a5000000-0000-0000-0000-00000000000b', 'Atelier Essentiel', 'atelier', 'essential');
insert into public.memberships (user_id, org_id, role) values
  ('00000000-0000-0000-0000-000000000a12', 'a5000000-0000-0000-0000-00000000000a', 'editor'),
  ('00000000-0000-0000-0000-000000000a13', 'a5000000-0000-0000-0000-00000000000a', 'viewer'),
  ('00000000-0000-0000-0000-000000000a15', 'a5000000-0000-0000-0000-00000000000b', 'editor');
insert into public.materials (id, org_id, name, atelier_stock_m) values
  ('a5100000-0000-0000-0000-000000000001', 'a5000000-0000-0000-0000-00000000000a', 'Sergé', 300),
  ('a5100000-0000-0000-0000-000000000002', 'a5000000-0000-0000-0000-00000000000a', 'Satin', 50),
  ('a5100000-0000-0000-0000-000000000003', 'a5000000-0000-0000-0000-00000000000b', 'Toile', 80);
insert into public.collections (id, org_id, name) values
  ('a5300000-0000-0000-0000-000000000001', 'a5000000-0000-0000-0000-00000000000a', 'AH27'),
  ('a5300000-0000-0000-0000-000000000002', 'a5000000-0000-0000-0000-00000000000b', 'PE28');
insert into public.models (id, collection_id, name, product_type, status) values
  ('a5400000-0000-0000-0000-000000000001', 'a5300000-0000-0000-0000-000000000001', 'Veste', 'garment', 'validated'),
  ('a5400000-0000-0000-0000-000000000002', 'a5300000-0000-0000-0000-000000000001', 'Manteau', 'garment', 'validated');
insert into public.models (id, collection_id, name, product_type) values
  ('a5400000-0000-0000-0000-000000000003', 'a5300000-0000-0000-0000-000000000002', 'Sac', 'leather_goods');

set local role authenticated;

-- Le Lecteur ne lance pas la production.
select set_config('request.jwt.claims', '{"sub":"00000000-0000-0000-0000-000000000a13","role":"authenticated"}', true);
select throws_ok($$select public.start_production('a5400000-0000-0000-0000-000000000001',
  '[{"material_id":"a5100000-0000-0000-0000-000000000001","meters":120}]')$$, '42501', 'forbidden', 'le Lecteur ne réserve pas');

-- L'Éditeur lance la Veste : réservation confirmée, statut « En production ».
select set_config('request.jwt.claims', '{"sub":"00000000-0000-0000-0000-000000000a12","role":"authenticated"}', true);
select lives_ok($$select public.start_production('a5400000-0000-0000-0000-000000000001',
  '[{"material_id":"a5100000-0000-0000-0000-000000000001","meters":120},{"material_id":"a5100000-0000-0000-0000-000000000002","meters":80}]')$$,
  'lancement en production');
select results_eq($$select status::text, (select sum(meters) from public.stock_reservations where model_id = m.id)
  from public.models m where id = 'a5400000-0000-0000-0000-000000000001'$$,
  $$values ('in_production'::text, 200.000::numeric)$$, 'statut et réservation');
select is((select m.atelier_stock_m - coalesce(sum(r.meters), 0) from public.materials m
  left join public.stock_reservations r on r.material_id = m.id
  where m.id = 'a5100000-0000-0000-0000-000000000002' group by m.atelier_stock_m), -30.000::numeric,
  'stock disponible = stock − réservé ; négatif quand il manque');
select throws_ok($$insert into public.stock_reservations (model_id, material_id, org_id, meters)
  values ('a5400000-0000-0000-0000-000000000002', 'a5100000-0000-0000-0000-000000000001', 'a5000000-0000-0000-0000-00000000000a', 5)$$,
  '42501', null, 'les réservations ne s''écrivent que par le lancement');
select throws_ok($$select public.start_production('a5400000-0000-0000-0000-000000000002',
  '[{"material_id":"a5100000-0000-0000-0000-000000000003","meters":5}]')$$, '22023', 'invalid_lines',
  'une matière d''un autre atelier est refusée');

-- Livraison : déduction ajustée, réservation libérée.
select lives_ok($$select public.deliver_model('a5400000-0000-0000-0000-000000000001',
  '[{"material_id":"a5100000-0000-0000-0000-000000000001","meters":115.5},{"material_id":"a5100000-0000-0000-0000-000000000002","meters":80}]')$$,
  'livraison');
select results_eq($$select name, atelier_stock_m from public.materials where org_id = 'a5000000-0000-0000-0000-00000000000a' order by name$$,
  $$values ('Satin'::text, 0.00::numeric), ('Sergé', 184.50)$$, 'stock atelier déduit (jamais en dessous de 0)');
select results_eq($$select status::text, (select count(*)::int from public.stock_reservations where model_id = m.id)
  from public.models m where id = 'a5400000-0000-0000-0000-000000000001'$$,
  $$values ('delivered'::text, 0)$$, 'livré, réservation disparue');

-- Abandon ou retour en arrière : la réservation est libérée.
select lives_ok($$select public.start_production('a5400000-0000-0000-0000-000000000002',
  '[{"material_id":"a5100000-0000-0000-0000-000000000001","meters":60}]')$$, 'lancement du Manteau');
update public.models set status = 'validated' where id = 'a5400000-0000-0000-0000-000000000002';
select is((select count(*)::int from public.stock_reservations where model_id = 'a5400000-0000-0000-0000-000000000002'), 0,
  'retour avant « En production » : réservation libérée');
select lives_ok($$select public.start_production('a5400000-0000-0000-0000-000000000002',
  '[{"material_id":"a5100000-0000-0000-0000-000000000001","meters":60}]')$$, 'relance');
update public.models set status = 'abandoned' where id = 'a5400000-0000-0000-0000-000000000002';
select is((select count(*)::int from public.stock_reservations), 0, 'abandon : réservation libérée');

-- Hors Pro : refusé.
select set_config('request.jwt.claims', '{"sub":"00000000-0000-0000-0000-000000000a15","role":"authenticated"}', true);
select throws_ok($$select public.start_production('a5400000-0000-0000-0000-000000000003',
  '[{"material_id":"a5100000-0000-0000-0000-000000000003","meters":5}]')$$, '42501', 'pro_required', 'hors Pro, pas de réservation');

select * from finish();
rollback;
