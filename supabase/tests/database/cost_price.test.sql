-- Tests du coût de revient et de la confidentialité des prix (phase 21).
begin;
create extension if not exists pgtap with schema extensions;
select plan(9);

insert into auth.users (id, email) values
  ('00000000-0000-0000-0000-000000000b12', 'claire@cout.test'),
  ('00000000-0000-0000-0000-000000000b13', 'lea@cout.test'),
  ('00000000-0000-0000-0000-000000000b15', 'autre@cout.test');
insert into public.organizations (id, name, kind, plan) values
  ('b5000000-0000-0000-0000-00000000000a', 'Atelier Coût', 'atelier', 'pro'),
  ('b5000000-0000-0000-0000-00000000000b', 'Atelier Essentiel', 'atelier', 'essential');
insert into public.memberships (user_id, org_id, role) values
  ('00000000-0000-0000-0000-000000000b12', 'b5000000-0000-0000-0000-00000000000a', 'editor'),
  ('00000000-0000-0000-0000-000000000b13', 'b5000000-0000-0000-0000-00000000000a', 'viewer'),
  ('00000000-0000-0000-0000-000000000b15', 'b5000000-0000-0000-0000-00000000000b', 'editor');
insert into public.collections (id, org_id, name) values
  ('b5300000-0000-0000-0000-000000000001', 'b5000000-0000-0000-0000-00000000000a', 'AH27'),
  ('b5300000-0000-0000-0000-000000000002', 'b5000000-0000-0000-0000-00000000000b', 'PE28');
insert into public.models (id, collection_id, name, product_type) values
  ('b5400000-0000-0000-0000-000000000001', 'b5300000-0000-0000-0000-000000000001', 'Veste', 'garment'),
  ('b5400000-0000-0000-0000-000000000002', 'b5300000-0000-0000-0000-000000000002', 'Sac', 'leather_goods');

set local role authenticated;

-- L'Éditeur enregistre un prix par la fiche matière.
select set_config('request.jwt.claims', '{"sub":"00000000-0000-0000-0000-000000000b12","role":"authenticated"}', true);
select set_config('test.mat', public.save_textile_material(
  '{"org_id":"b5000000-0000-0000-0000-00000000000a","name":"Sergé","price_per_m":18.5,"specs":{}}')::text, true);
select is((select price_per_m from public.material_prices where material_id = current_setting('test.mat')::uuid), 18.50::numeric,
  'le prix est enregistré dans la couche privée');
select lives_ok($$select public.save_textile_material(jsonb_build_object('id', current_setting('test.mat'),
  'org_id', 'b5000000-0000-0000-0000-00000000000a', 'name', 'Sergé', 'price_per_m', null, 'specs', '{}'::jsonb))$$,
  'effacer le prix');
select is((select count(*)::int from public.material_prices), 0, 'prix effacé');
select public.save_textile_material(jsonb_build_object('id', current_setting('test.mat'),
  'org_id', 'b5000000-0000-0000-0000-00000000000a', 'name', 'Sergé', 'price_per_m', 18.5, 'specs', '{}'::jsonb));
select lives_ok($$insert into public.model_costs (model_id, kind, label, unit_price) values
  ('b5400000-0000-0000-0000-000000000001', 'labor', 'Façon', 22)$$, 'ligne de coût');

-- Le Lecteur ne reçoit ni le prix ni les coûts.
select set_config('request.jwt.claims', '{"sub":"00000000-0000-0000-0000-000000000b13","role":"authenticated"}', true);
select is((select count(*)::int from public.materials), 1, 'le Lecteur voit la matière');
select is((select count(*)::int from public.material_prices), 0, 'mais pas son prix');
select is((select count(*)::int from public.model_costs), 0, 'ni les coûts');
select ok(not exists (select 1 from information_schema.columns where table_name = 'materials' and column_name = 'price_per_m'),
  'le prix ne figure plus dans la table des matières');

-- Hors Pro : pas de ligne de coût.
select set_config('request.jwt.claims', '{"sub":"00000000-0000-0000-0000-000000000b15","role":"authenticated"}', true);
select throws_ok($$insert into public.model_costs (model_id, kind, label, unit_price) values
  ('b5400000-0000-0000-0000-000000000002', 'labor', 'Façon', 22)$$, '42501', 'pro_required', 'hors Pro, pas de coût de revient');

select * from finish();
rollback;
