-- Tests des matières liées à une référence fournisseur (phase 7).
begin;
create extension if not exists pgtap with schema extensions;
select plan(15);

insert into auth.users (id, email) values
  ('00000000-0000-0000-0000-0000000000f1', 'marco@lien.test'),
  ('00000000-0000-0000-0000-0000000000f2', 'claire@lien.test'),
  ('00000000-0000-0000-0000-0000000000f3', 'autre@lien.test');
insert into public.organizations (id, name, kind) values
  ('50000000-0000-0000-0000-00000000000c', 'Tisseur Lien', 'supplier'),
  ('50000000-0000-0000-0000-00000000000a', 'Atelier Lien', 'atelier'),
  ('50000000-0000-0000-0000-00000000000b', 'Atelier Autre', 'atelier');
insert into public.memberships (user_id, org_id, role) values
  ('00000000-0000-0000-0000-0000000000f1', '50000000-0000-0000-0000-00000000000c', 'admin'),
  ('00000000-0000-0000-0000-0000000000f2', '50000000-0000-0000-0000-00000000000a', 'editor'),
  ('00000000-0000-0000-0000-0000000000f3', '50000000-0000-0000-0000-00000000000b', 'admin');
insert into public.supplier_references (id, supplier_org_id, code, name, color_name, color_hex, composition, weight_gsm, weave, stock_m)
values
  ('60000000-0000-0000-0000-000000000001', '50000000-0000-0000-0000-00000000000c', 'DR4521-NV', 'Drap laine froide', 'Marine', '#2F4A6B',
   '[{"fiber":"WO","pct":62},{"fiber":"PES","pct":38}]', 280, 'twill', 340),
  ('60000000-0000-0000-0000-000000000002', '50000000-0000-0000-0000-00000000000c', 'DR4522-NV', 'Drap voisin', null, null, '[]', 300, null, 10),
  ('60000000-0000-0000-0000-000000000003', '50000000-0000-0000-0000-00000000000c', 'POP-110', 'Popeline', null, null, '[]', 110, 'plain', 0);

set local role authenticated;

-- Atelier : rapprochement -----------------------------------------------------------
select set_config('request.jwt.claims', '{"sub":"00000000-0000-0000-0000-0000000000f2","role":"authenticated"}', true);
select results_eq($$select id, score from public.match_supplier_references('dr 4521 nv', 'Tisseur Lien') limit 1$$,
  $$values ('60000000-0000-0000-0000-000000000001'::uuid, 1.0::real)$$, 'code écrit autrement : correspondance exacte');
select ok((select count(*) from public.match_supplier_references('DR452', null)) >= 2,
  'code tronqué : plusieurs références proches proposées');
select is((select count(*)::int from public.match_supplier_references('ZZZZ-999', null)), 0, 'code sans rapport : aucune proposition');

-- Atelier : création liée -------------------------------------------------------------
select lives_ok($$select public.save_textile_material('{"org_id":"50000000-0000-0000-0000-00000000000a",
  "name":"Mon drap","supplier_reference_id":"60000000-0000-0000-0000-000000000001","price_per_m":24.5,
  "tags":["AH27"],"specs":{"weight_gsm":999,"composition":[{"fiber":"CO","pct":100}]}}'::jsonb)$$,
  'une Éditrice crée une matière liée');
select results_eq($$select m.supplier_code, m.supplier_name, s.weight_gsm, s.weave from public.materials m
  join public.textile_specs s on s.material_id = m.id where m.name = 'Mon drap'$$,
  $$values ('DR4521-NV'::text, 'Tisseur Lien'::text, 280, 'twill'::text)$$,
  'les données techniques viennent du fournisseur (le payload est ignoré)');
select set_config('test.material', (select id::text from public.materials where name = 'Mon drap'), false);
select results_eq($$select p.price_per_m, m.tags from public.materials m join public.material_prices p on p.material_id = m.id where m.name = 'Mon drap'$$,
  $$values (24.50::numeric, array['AH27']::text[])$$, 'la couche privée de l''atelier est enregistrée');
select throws_ok($$update public.textile_specs set weight_gsm = 1
  where material_id = (select id from public.materials where name = 'Mon drap')$$,
  '42501', 'linked_material_readonly', 'l''atelier ne modifie pas les données techniques d''une matière liée');
select throws_ok($$select public.copy_reference_to_material(
  (select id from public.materials where name = 'Mon drap'), '60000000-0000-0000-0000-000000000002')$$,
  '42501', null, 'la copie interne n''est pas accessible aux utilisateurs');

-- Fournisseur : mise à jour puis retrait -----------------------------------------------
select set_config('request.jwt.claims', '{"sub":"00000000-0000-0000-0000-0000000000f1","role":"authenticated"}', true);
update public.supplier_references set weight_gsm = 290, color_name = 'Marine profond'
where id = '60000000-0000-0000-0000-000000000001';
reset role;
select results_eq($$select s.weight_gsm, m.color_name from public.materials m join public.textile_specs s on s.material_id = m.id
  where m.name = 'Mon drap'$$, $$values (290, 'Marine profond'::text)$$,
  'une modification du fournisseur arrive chez l''atelier sans action de sa part');
set local role authenticated;
select set_config('request.jwt.claims', '{"sub":"00000000-0000-0000-0000-0000000000f1","role":"authenticated"}', true);
update public.supplier_references set retired_at = now() where id = '60000000-0000-0000-0000-000000000001';
update public.supplier_references set weight_gsm = 1 where id = '60000000-0000-0000-0000-000000000001';
reset role;
select is((select s.weight_gsm from public.materials m join public.textile_specs s on s.material_id = m.id
  where m.name = 'Mon drap'), 290, 'après retrait, l''atelier garde les dernières valeurs connues');
set local role authenticated;

-- Atelier : référence retirée, déliaison, autre atelier ---------------------------------
select set_config('request.jwt.claims', '{"sub":"00000000-0000-0000-0000-0000000000f2","role":"authenticated"}', true);
select is((select count(*)::int from public.supplier_catalog where id = '60000000-0000-0000-0000-000000000001'), 0,
  'la référence retirée n''est plus dans le catalogue publié');
select throws_ok($$select public.save_textile_material('{"org_id":"50000000-0000-0000-0000-00000000000a",
  "name":"Trop tard","supplier_reference_id":"60000000-0000-0000-0000-000000000001"}'::jsonb)$$,
  'P0002', 'reference_not_available', 'impossible de lier une référence retirée');
select lives_ok($$select public.save_textile_material(jsonb_build_object(
  'id', (select id from public.materials where name = 'Mon drap'), 'org_id', '50000000-0000-0000-0000-00000000000a',
  'name', 'Mon drap', 'supplier_reference_id', null,
  'specs', '{"weight_gsm":300,"composition":[{"fiber":"WO","pct":100}]}'::jsonb))$$,
  'délier : la fiche redevient propre à l''atelier');
select is((select s.weight_gsm from public.materials m join public.textile_specs s on s.material_id = m.id
  where m.name = 'Mon drap'), 300, 'une fiche déliée se modifie librement');

select set_config('request.jwt.claims', '{"sub":"00000000-0000-0000-0000-0000000000f3","role":"authenticated"}', true);
select throws_ok($$select public.save_textile_material(jsonb_build_object(
  'id', current_setting('test.material'), 'org_id', '50000000-0000-0000-0000-00000000000b',
  'name', 'Volée', 'supplier_reference_id', '60000000-0000-0000-0000-000000000002'))$$,
  'P0002', 'material_not_found', 'un autre atelier ne peut pas lier une matière qui n''est pas à lui');

select * from finish();
rollback;
