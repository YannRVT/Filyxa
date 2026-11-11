-- Tests du Studio (phase 10).
begin;
create extension if not exists pgtap with schema extensions;
select plan(15);

insert into auth.users (id, email) values
  ('00000000-0000-0000-0000-0000000000c1', 'claire@studio.test'),
  ('00000000-0000-0000-0000-0000000000c2', 'lea@studio.test'),
  ('00000000-0000-0000-0000-0000000000c3', 'paul@studio.test');
insert into public.organizations (id, name, kind) values
  ('c0000000-0000-0000-0000-00000000000a', 'Atelier Studio', 'atelier'),
  ('c0000000-0000-0000-0000-00000000000b', 'Atelier Autre', 'atelier');
insert into public.memberships (user_id, org_id, role) values
  ('00000000-0000-0000-0000-0000000000c1', 'c0000000-0000-0000-0000-00000000000a', 'editor'),
  ('00000000-0000-0000-0000-0000000000c2', 'c0000000-0000-0000-0000-00000000000a', 'viewer'),
  ('00000000-0000-0000-0000-0000000000c3', 'c0000000-0000-0000-0000-00000000000b', 'admin');
insert into public.materials (id, org_id, name) values
  ('d0000000-0000-0000-0000-0000000000a1', 'c0000000-0000-0000-0000-00000000000a', 'Sergé'),
  ('d0000000-0000-0000-0000-0000000000a2', 'c0000000-0000-0000-0000-00000000000a', 'Doublure'),
  ('d0000000-0000-0000-0000-0000000000b1', 'c0000000-0000-0000-0000-00000000000b', 'Tissu d''un autre atelier');

set local role authenticated;

-- Lecteur ------------------------------------------------------------------------------------
select set_config('request.jwt.claims', '{"sub":"00000000-0000-0000-0000-0000000000c2","role":"authenticated"}', true);
select throws_ok($$insert into public.collections (org_id, name) values ('c0000000-0000-0000-0000-00000000000a', 'AH27')$$,
  '42501', null, 'un Lecteur ne crée pas de collection');

-- Éditrice -----------------------------------------------------------------------------------
select set_config('request.jwt.claims', '{"sub":"00000000-0000-0000-0000-0000000000c1","role":"authenticated"}', true);
insert into public.collections (id, org_id, name) values ('e0000000-0000-0000-0000-000000000001', 'c0000000-0000-0000-0000-00000000000a', 'AH27');
insert into public.models (id, collection_id, name, product_type)
  values ('e0000000-0000-0000-0000-000000000002', 'e0000000-0000-0000-0000-000000000001', 'Veste Arno', 'garment');
select results_eq($$select org_id, waste_pct from public.models where id = 'e0000000-0000-0000-0000-000000000002'$$,
  $$values ('c0000000-0000-0000-0000-00000000000a'::uuid, 8.00::numeric)$$, 'le modèle hérite de l''atelier, marge 8 % par défaut');
select is((select count(*)::int from public.colorways where model_id = 'e0000000-0000-0000-0000-000000000002'), 1,
  'un modèle naît avec un coloris par défaut');
select set_config('test.cw1', (select id::text from public.colorways where model_id = 'e0000000-0000-0000-0000-000000000002'), false);

insert into public.model_materials (colorway_id, material_id, role, consumption) values
  (current_setting('test.cw1')::uuid, 'd0000000-0000-0000-0000-0000000000a1', 'main', 1.8),
  (current_setting('test.cw1')::uuid, 'd0000000-0000-0000-0000-0000000000a2', 'Doublure manches', 0.6);
select throws_ok(format($$insert into public.model_materials (colorway_id, material_id, role) values (%L, 'd0000000-0000-0000-0000-0000000000b1', 'main')$$,
  current_setting('test.cw1')), '42501', 'material_not_in_org', 'impossible d''utiliser la matière d''un autre atelier');

select set_config('test.cw2', public.add_colorway('e0000000-0000-0000-0000-000000000002', 'Noir', current_setting('test.cw1')::uuid)::text, false);
select is((select count(*)::int from public.model_materials where colorway_id = current_setting('test.cw2')::uuid), 2,
  'un nouveau coloris reprend la nomenclature du coloris d''origine');
select is((select position from public.colorways where id = current_setting('test.cw2')::uuid), 1, 'le coloris se range après les autres');
update public.model_materials set consumption = 2 where colorway_id = current_setting('test.cw2')::uuid and role = 'main';
select is((select consumption from public.model_materials where colorway_id = current_setting('test.cw1')::uuid and role = 'main'), 1.800,
  'chaque coloris a ses propres matières');

select lives_ok(format($$delete from public.colorways where id = %L$$, current_setting('test.cw2')), 'supprimer un coloris parmi deux');
select throws_ok(format($$delete from public.colorways where id = %L$$, current_setting('test.cw1')),
  '22023', 'last_colorway', 'un modèle garde au moins un coloris');
select throws_ok($$update public.models set waste_pct = 150 where id = 'e0000000-0000-0000-0000-000000000002'$$,
  '23514', null, 'marge de perte entre 0 et 100 %');

-- Lecteur : consultation ---------------------------------------------------------------------
select set_config('request.jwt.claims', '{"sub":"00000000-0000-0000-0000-0000000000c2","role":"authenticated"}', true);
select is((select count(*)::int from public.model_materials), 2, 'le Lecteur consulte le Studio');
update public.models set name = 'Piratée' where id = 'e0000000-0000-0000-0000-000000000002';
select is((select name from public.models where id = 'e0000000-0000-0000-0000-000000000002'), 'Veste Arno', 'sans pouvoir le modifier');

-- Autre atelier --------------------------------------------------------------------------------
select set_config('request.jwt.claims', '{"sub":"00000000-0000-0000-0000-0000000000c3","role":"authenticated"}', true);
select is((select count(*)::int from public.models), 0, 'un autre atelier ne voit pas le Studio');
select throws_ok($$insert into public.models (collection_id, name, product_type)
  values ('e0000000-0000-0000-0000-000000000001', 'Intrus', 'footwear')$$, '42501', null,
  'impossible d''ajouter un modèle dans la collection d''un autre atelier');

-- Suppression en cascade ------------------------------------------------------------------------
select set_config('request.jwt.claims', '{"sub":"00000000-0000-0000-0000-0000000000c1","role":"authenticated"}', true);
delete from public.collections where id = 'e0000000-0000-0000-0000-000000000001';
reset role;
select is((select count(*)::int from public.colorways where model_id = 'e0000000-0000-0000-0000-000000000002'), 0,
  'supprimer une collection supprime ses modèles et coloris');

select * from finish();
rollback;
