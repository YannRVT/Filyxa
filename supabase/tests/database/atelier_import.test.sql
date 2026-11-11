-- Tests de l'import atelier et du rapprochement automatique (phase 8).
begin;
create extension if not exists pgtap with schema extensions;
select plan(15);

insert into auth.users (id, email) values
  ('00000000-0000-0000-0000-0000000000e1', 'marco@import.test'),
  ('00000000-0000-0000-0000-0000000000e2', 'claire@import.test'),
  ('00000000-0000-0000-0000-0000000000e3', 'lea@import.test');
insert into public.organizations (id, name, kind) values
  ('70000000-0000-0000-0000-00000000000c', 'Tissage Import', 'supplier'),
  ('70000000-0000-0000-0000-00000000000a', 'Atelier Import', 'atelier');
insert into public.memberships (user_id, org_id, role) values
  ('00000000-0000-0000-0000-0000000000e1', '70000000-0000-0000-0000-00000000000c', 'admin'),
  ('00000000-0000-0000-0000-0000000000e2', '70000000-0000-0000-0000-00000000000a', 'editor'),
  ('00000000-0000-0000-0000-0000000000e3', '70000000-0000-0000-0000-00000000000a', 'viewer');
insert into public.supplier_references (id, supplier_org_id, code, name, composition, weight_gsm, weave, stock_m) values
  ('80000000-0000-0000-0000-000000000001', '70000000-0000-0000-0000-00000000000c', 'TI-SRG-280', 'Sergé', '[{"fiber":"WO","pct":100}]', 280, 'twill', 100),
  ('80000000-0000-0000-0000-000000000002', '70000000-0000-0000-0000-00000000000c', 'TI-POP-110', 'Popeline', '[]', 110, 'plain', 10),
  ('80000000-0000-0000-0000-000000000003', '70000000-0000-0000-0000-00000000000c', 'TI-POP-111', 'Popeline bis', '[]', 115, 'plain', 10);

set local role authenticated;
select set_config('request.jwt.claims', '{"sub":"00000000-0000-0000-0000-0000000000e3","role":"authenticated"}', true);
select throws_ok($$select public.import_atelier_materials('70000000-0000-0000-0000-00000000000a', '[]'::jsonb)$$,
  '42501', 'forbidden', 'un Lecteur ne peut pas importer');

select set_config('request.jwt.claims', '{"sub":"00000000-0000-0000-0000-0000000000e2","role":"authenticated"}', true);
-- 1 : code exact + bon fournisseur → liée. 2 : code tronqué → à confirmer.
-- 3 : code exact mais fournisseur absent → à confirmer. 4 : sans code → propre à l'atelier.
-- 5 : grammage invalide → erreur.
select set_config('test.result', public.import_atelier_materials('70000000-0000-0000-0000-00000000000a', '[
  {"name":"Mon sergé","supplier_name":"Tissage Import","supplier_code":"ti srg 280","price_per_m":18,"tags":["hiver"],
   "specs":{"weight_gsm":999,"composition":[{"fiber":"CO","pct":100}]}},
  {"name":"Popeline","supplier_name":"Tissage Import","supplier_code":"TI-POP"},
  {"name":"Sergé sans fournisseur","supplier_code":"TI-SRG-280-B"},
  {"name":"Lin maison","color_name":"Écru","atelier_stock_m":12,"specs":{"composition":[{"fiber":"LI","pct":100}],"weight_gsm":180}},
  {"name":"Cassé","supplier_code":"X1","specs":{"weight_gsm":99999}}
]'::jsonb)::text, false);
select is((current_setting('test.result')::jsonb ->> 'inserted')::int, 4, '4 matières créées');
select is((current_setting('test.result')::jsonb ->> 'linked')::int, 1, '1 reliée automatiquement');
select is((current_setting('test.result')::jsonb ->> 'pending')::int, 2, '2 à confirmer');
select is(jsonb_array_length(current_setting('test.result')::jsonb -> 'errors'), 1, '1 ligne refusée');
select is((current_setting('test.result')::jsonb -> 'errors' -> 0 ->> 'row')::int, 5, 'avec son numéro de ligne');

select results_eq($$select m.supplier_reference_id, m.supplier_code, s.weight_gsm, m.price_per_m from public.materials m
  join public.textile_specs s on s.material_id = m.id where m.name = 'Mon sergé'$$,
  $$values ('80000000-0000-0000-0000-000000000001'::uuid, 'TI-SRG-280'::text, 280, 18.00::numeric)$$,
  'correspondance sûre : liée, données du fournisseur, couche privée conservée');
select results_eq($$select name from public.materials where org_id = '70000000-0000-0000-0000-00000000000a'
  and link_review = 'pending' order by name$$,
  $$values ('Popeline'::text), ('Sergé sans fournisseur'::text)$$, 'les correspondances incertaines sont à confirmer');
select is((select supplier_reference_id from public.materials where name = 'Popeline'), null,
  'rien n''est lié sans confirmation quand la correspondance est incertaine');

-- « Aucune de ces références » puis réimport : ni doublon, ni nouvelle proposition.
update public.materials set link_review = 'dismissed' where name = 'Popeline';
select set_config('test.result', public.import_atelier_materials('70000000-0000-0000-0000-00000000000a', '[
  {"name":"Mon sergé","supplier_name":"Tissage Import","supplier_code":"TI-SRG-280","atelier_stock_m":40},
  {"name":"Popeline","supplier_name":"Tissage Import","supplier_code":"TI-POP"},
  {"name":"Lin maison","color_name":"Écru"}
]'::jsonb)::text, false);
select results_eq($$select (current_setting('test.result')::jsonb ->> 'inserted')::int,
  (current_setting('test.result')::jsonb ->> 'updated')::int$$, $$values (0, 3)$$, 'réimport : 3 mises à jour, aucune création');
select is((select count(*)::int from public.materials where org_id = '70000000-0000-0000-0000-00000000000a'), 4,
  'un import relancé ne duplique pas les matières');
select results_eq($$select atelier_stock_m, price_per_m, supplier_reference_id from public.materials where name = 'Mon sergé'$$,
  $$values (40.00::numeric, 18.00::numeric, '80000000-0000-0000-0000-000000000001'::uuid)$$,
  'réimport : valeurs nouvelles prises, cellules vides sans effet, lien conservé');
select is((select link_review from public.materials where name = 'Popeline'), 'dismissed',
  'une correspondance écartée n''est plus proposée');

select is((public.import_atelier_materials('70000000-0000-0000-0000-00000000000a',
  '[{"name":"Hors catalogue","supplier_code":"ZZZZ-999"}]'::jsonb) ->> 'inserted')::int, 1,
  'code sans aucune référence proche : importée, propre à l''atelier');

-- Confirmation d'une correspondance : le lien efface « à confirmer ».
select public.save_textile_material(jsonb_build_object(
  'id', (select id from public.materials where name = 'Sergé sans fournisseur'),
  'org_id', '70000000-0000-0000-0000-00000000000a', 'name', 'Sergé sans fournisseur',
  'supplier_reference_id', '80000000-0000-0000-0000-000000000001'));
select is((select link_review from public.materials where name = 'Sergé sans fournisseur'), null,
  'une correspondance confirmée n''est plus à traiter');

select * from finish();
rollback;
