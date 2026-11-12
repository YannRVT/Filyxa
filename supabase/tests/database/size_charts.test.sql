-- Tests des grilles de tailles et des quantités par taille (phase 17).
begin;
create extension if not exists pgtap with schema extensions;
select plan(16);

insert into auth.users (id, email) values
  ('00000000-0000-0000-0000-0000000000e1', 'admin@taille.test'),
  ('00000000-0000-0000-0000-0000000000e2', 'claire@taille.test'),
  ('00000000-0000-0000-0000-0000000000e5', 'autre@taille.test');
insert into public.organizations (id, name, kind, plan) values
  ('c0000000-0000-0000-0000-00000000000a', 'Atelier Taille', 'atelier', 'pro'),
  ('c0000000-0000-0000-0000-00000000000b', 'Atelier Essentiel', 'atelier', 'essential');
insert into public.memberships (user_id, org_id, role) values
  ('00000000-0000-0000-0000-0000000000e1', 'c0000000-0000-0000-0000-00000000000a', 'admin'),
  ('00000000-0000-0000-0000-0000000000e2', 'c0000000-0000-0000-0000-00000000000a', 'editor'),
  ('00000000-0000-0000-0000-0000000000e5', 'c0000000-0000-0000-0000-00000000000b', 'admin');
insert into public.collections (id, org_id, name) values
  ('c3000000-0000-0000-0000-000000000001', 'c0000000-0000-0000-0000-00000000000a', 'AH27'),
  ('c3000000-0000-0000-0000-000000000002', 'c0000000-0000-0000-0000-00000000000b', 'PE28');
insert into public.models (id, collection_id, name, product_type) values
  ('c4000000-0000-0000-0000-000000000001', 'c3000000-0000-0000-0000-000000000001', 'Veste Arno', 'garment'),
  ('c4000000-0000-0000-0000-000000000002', 'c3000000-0000-0000-0000-000000000002', 'Sac Ola', 'leather_goods');

set local role authenticated;

-- L'Éditeur voit les grilles fournies ; il n'en crée pas.
select set_config('request.jwt.claims', '{"sub":"00000000-0000-0000-0000-0000000000e2","role":"authenticated"}', true);
select is((select count(*)::int from public.size_charts where org_id is null), 4, 'quatre grilles fournies');
select throws_ok($$insert into public.size_charts (org_id, name, sizes) values ('c0000000-0000-0000-0000-00000000000a', 'X', array['A'])$$,
  '42501', null, 'l''Éditeur ne crée pas de grille');

-- L'Admin crée la grille de l'atelier.
select set_config('request.jwt.claims', '{"sub":"00000000-0000-0000-0000-0000000000e1","role":"authenticated"}', true);
select lives_ok($$insert into public.size_charts (id, org_id, name, sizes) values
  ('c5000000-0000-0000-0000-000000000001', 'c0000000-0000-0000-0000-00000000000a', 'Enfant', array['4A', ' 6A ', '8A'])$$,
  'l''Admin crée une grille');
select is((select sizes from public.size_charts where id = 'c5000000-0000-0000-0000-000000000001'), array['4A', '6A', '8A'],
  'tailles nettoyées');
select throws_ok($$insert into public.size_charts (org_id, name, sizes) values ('c0000000-0000-0000-0000-00000000000a', 'Doublon', array['S', 'S'])$$,
  '22023', 'invalid_sizes', 'tailles en double refusées');
update public.size_charts set sizes = array['S'] where code = 'alpha';
select is((select cardinality(sizes) from public.size_charts where code = 'alpha'), 6, 'une grille fournie n''est pas modifiable');

-- Le modèle choisit la grille ; les quantités se saisissent par taille et par coloris.
select set_config('request.jwt.claims', '{"sub":"00000000-0000-0000-0000-0000000000e2","role":"authenticated"}', true);
update public.models set size_chart_id = 'c5000000-0000-0000-0000-000000000001' where id = 'c4000000-0000-0000-0000-000000000001';
insert into public.colorway_size_quantities (colorway_id, size, quantity)
select id, s, q from public.colorways, (values ('4A', 10), ('6A', 20), ('8A', 5)) v(s, q)
where model_id = 'c4000000-0000-0000-0000-000000000001';
select is((select quantity from public.colorways where model_id = 'c4000000-0000-0000-0000-000000000001'), 35,
  'la quantité du coloris est la somme de ses tailles');
select throws_ok($$insert into public.colorway_size_quantities (colorway_id, size, quantity)
  select id, 'XXL', 1 from public.colorways where model_id = 'c4000000-0000-0000-0000-000000000001'$$,
  '22023', 'size_not_in_chart', 'une taille hors grille est refusée');

-- Une taille qui a des quantités ne peut pas être retirée de la grille ; une taille vide, si.
select set_config('request.jwt.claims', '{"sub":"00000000-0000-0000-0000-0000000000e1","role":"authenticated"}', true);
select throws_ok($$update public.size_charts set sizes = array['4A', '8A'] where id = 'c5000000-0000-0000-0000-000000000001'$$,
  '23503', 'size_in_use', 'taille utilisée : retrait refusé');
select lives_ok($$update public.size_charts set name = 'Enfants', sizes = array['8A', '6A', '4A', '10A'] where id = 'c5000000-0000-0000-0000-000000000001'$$,
  'renommer, réordonner et ajouter une taille');
select throws_ok($$delete from public.size_charts where id = 'c5000000-0000-0000-0000-000000000001'$$,
  '23503', null, 'une grille utilisée par un modèle ne se supprime pas');

-- Changer de grille efface les quantités devenues sans objet.
select set_config('request.jwt.claims', '{"sub":"00000000-0000-0000-0000-0000000000e2","role":"authenticated"}', true);
update public.models set size_chart_id = (select id from public.size_charts where code = 'alpha')
  where id = 'c4000000-0000-0000-0000-000000000001';
select is((select count(*)::int from public.colorway_size_quantities q join public.colorways c on c.id = q.colorway_id
  where c.model_id = 'c4000000-0000-0000-0000-000000000001'), 0, 'changer de grille efface les quantités sans objet');
select is((select quantity from public.colorways where model_id = 'c4000000-0000-0000-0000-000000000001'), 0,
  'la quantité du coloris suit');

-- Sans grille : la quantité par coloris se saisit comme en V1.
update public.models set size_chart_id = null where id = 'c4000000-0000-0000-0000-000000000001';
update public.colorways set quantity = 120 where model_id = 'c4000000-0000-0000-0000-000000000001';
select is((select quantity from public.colorways where model_id = 'c4000000-0000-0000-0000-000000000001'), 120,
  'sans grille, quantité par coloris comme en V1');

-- Hors Pro : refusé.
select set_config('request.jwt.claims', '{"sub":"00000000-0000-0000-0000-0000000000e5","role":"authenticated"}', true);
select throws_ok($$update public.models set size_chart_id = (select id from public.size_charts where code = 'alpha')
  where id = 'c4000000-0000-0000-0000-000000000002'$$, '42501', 'pro_required', 'hors Pro, pas de grille sur un modèle');
select throws_ok($$insert into public.size_charts (org_id, name, sizes) values ('c0000000-0000-0000-0000-00000000000b', 'X', array['A'])$$,
  '42501', 'pro_required', 'hors Pro, pas de grille d''atelier');

select * from finish();
rollback;
