-- Tests de la gradation (phase 18).
begin;
create extension if not exists pgtap with schema extensions;
select plan(8);

insert into auth.users (id, email) values
  ('00000000-0000-0000-0000-0000000000f2', 'claire@grade.test'),
  ('00000000-0000-0000-0000-0000000000f5', 'autre@grade.test');
insert into public.organizations (id, name, kind, plan) values
  ('b2000000-0000-0000-0000-00000000000a', 'Atelier Grade', 'atelier', 'pro'),
  ('b2000000-0000-0000-0000-00000000000b', 'Atelier Essentiel', 'atelier', 'essential');
insert into public.memberships (user_id, org_id, role) values
  ('00000000-0000-0000-0000-0000000000f2', 'b2000000-0000-0000-0000-00000000000a', 'editor'),
  ('00000000-0000-0000-0000-0000000000f5', 'b2000000-0000-0000-0000-00000000000b', 'editor');
insert into public.collections (id, org_id, name) values
  ('b3000000-0000-0000-0000-000000000001', 'b2000000-0000-0000-0000-00000000000a', 'AH27'),
  ('b3000000-0000-0000-0000-000000000002', 'b2000000-0000-0000-0000-00000000000b', 'PE28');
insert into public.models (id, collection_id, name, product_type, size_chart_id) values
  ('b4000000-0000-0000-0000-000000000001', 'b3000000-0000-0000-0000-000000000001', 'Veste', 'garment',
   (select id from public.size_charts where code = 'alpha'));
insert into public.models (id, collection_id, name, product_type) values
  ('b4000000-0000-0000-0000-000000000002', 'b3000000-0000-0000-0000-000000000002', 'Sac', 'leather_goods');

set local role authenticated;
select set_config('request.jwt.claims', '{"sub":"00000000-0000-0000-0000-0000000000f2","role":"authenticated"}', true);
select is((select grade_pct from public.models where id = 'b4000000-0000-0000-0000-000000000001'), 4.00::numeric,
  'écart de 4 % par taille par défaut');
select lives_ok($$update public.models set base_size = 'M', grade_pct = 3 where id = 'b4000000-0000-0000-0000-000000000001'$$,
  'taille de base et écart du modèle');
select throws_ok($$update public.models set base_size = '40' where id = 'b4000000-0000-0000-0000-000000000001'$$,
  '22023', 'size_not_in_chart', 'la taille de base appartient à la grille');
select lives_ok($$insert into public.model_size_grades (model_id, size, grade_pct) values ('b4000000-0000-0000-0000-000000000001', 'XXL', 15)$$,
  'écart propre à une taille');
select throws_ok($$insert into public.model_size_grades (model_id, size, grade_pct) values ('b4000000-0000-0000-0000-000000000001', '42', 5)$$,
  '22023', 'size_not_in_chart', 'écart propre : taille de la grille');

-- Changer de grille : taille de base et écarts propres qui n'existent plus disparaissent.
update public.models set size_chart_id = (select id from public.size_charts where code = 'eu') where id = 'b4000000-0000-0000-0000-000000000001';
select results_eq($$select base_size, (select count(*)::int from public.model_size_grades where model_id = m.id)
  from public.models m where id = 'b4000000-0000-0000-0000-000000000001'$$,
  $$values (null::text, 0)$$, 'nouvelle grille : base et écarts propres effacés');

-- Hors Pro : refusé.
select set_config('request.jwt.claims', '{"sub":"00000000-0000-0000-0000-0000000000f5","role":"authenticated"}', true);
select throws_ok($$update public.models set grade_pct = 5 where id = 'b4000000-0000-0000-0000-000000000002'$$,
  '42501', 'pro_required', 'hors Pro, pas de gradation');
select lives_ok($$update public.models set waste_pct = 10 where id = 'b4000000-0000-0000-0000-000000000002'$$,
  'hors Pro, la marge se modifie comme en V1');

select * from finish();
rollback;
