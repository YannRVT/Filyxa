-- Tests des matières (phase 3) : lecture membres, écriture Éditeur, isolation, composition.
begin;
create extension if not exists pgtap with schema extensions;
select plan(11);

insert into auth.users (id, email) values
  ('00000000-0000-0000-0000-0000000000a1', 'admin@a.test'),
  ('00000000-0000-0000-0000-0000000000a2', 'editeur@a.test'),
  ('00000000-0000-0000-0000-0000000000a3', 'lecteur@a.test'),
  ('00000000-0000-0000-0000-0000000000b1', 'admin@b.test');
insert into public.organizations (id, name, kind) values
  ('20000000-0000-0000-0000-00000000000a', 'Atelier A', 'atelier'),
  ('20000000-0000-0000-0000-00000000000b', 'Atelier B', 'atelier');
insert into public.memberships (user_id, org_id, role) values
  ('00000000-0000-0000-0000-0000000000a1', '20000000-0000-0000-0000-00000000000a', 'admin'),
  ('00000000-0000-0000-0000-0000000000a2', '20000000-0000-0000-0000-00000000000a', 'editor'),
  ('00000000-0000-0000-0000-0000000000a3', '20000000-0000-0000-0000-00000000000a', 'viewer'),
  ('00000000-0000-0000-0000-0000000000b1', '20000000-0000-0000-0000-00000000000b', 'admin');

set local role authenticated;

-- Éditrice de A ------------------------------------------------------------------
select set_config('request.jwt.claims', '{"sub":"00000000-0000-0000-0000-0000000000a2","role":"authenticated"}', true);
select isnt(
  public.save_textile_material('{"org_id":"20000000-0000-0000-0000-00000000000a","name":"Drap laine froide",
    "supplier_name":"Dormeuil","supplier_code":"DR4521","color_hex":"#2f4a6b","atelier_stock_m":42.5,
    "specs":{"composition":[{"fiber":"WO","pct":62},{"fiber":"PES","pct":38}],"weight_gsm":280,"width_cm":150,
             "weave":"twill","care":["wash_30","iron_low"],"certifications":["RWS"],"uses":["jacket"]}}'::jsonb),
  null, 'une Éditrice crée une matière avec ses caractéristiques');
select is((select color_hex from public.materials where name = 'Drap laine froide'), '#2F4A6B',
  'la couleur est normalisée en majuscules');
select is((select weight_gsm from public.textile_specs s join public.materials m on m.id = s.material_id
           where m.name = 'Drap laine froide'), 280, 'les caractéristiques textiles sont enregistrées');
select throws_ok(
  $$select public.save_textile_material('{"org_id":"20000000-0000-0000-0000-00000000000a","name":"Faux",
    "specs":{"composition":[{"fiber":"WO","pct":60},{"fiber":"PES","pct":30}]}}'::jsonb)$$,
  '23514', null, 'une composition qui ne fait pas 100 % est refusée');
select throws_ok(
  $$select public.save_textile_material('{"org_id":"20000000-0000-0000-0000-00000000000b","name":"Intrus"}'::jsonb)$$,
  '42501', null, 'impossible de créer une matière dans un autre atelier');
select throws_ok(
  $$update public.materials set org_id = '20000000-0000-0000-0000-00000000000b' where name = 'Drap laine froide'$$,
  '42501', null, 'une matière ne change pas d''atelier');

-- Lectrice de A -------------------------------------------------------------------
select set_config('request.jwt.claims', '{"sub":"00000000-0000-0000-0000-0000000000a3","role":"authenticated"}', true);
select is((select count(*)::int from public.materials), 1, 'la Lectrice voit les matières de son atelier');
select throws_ok(
  $$select public.save_textile_material('{"org_id":"20000000-0000-0000-0000-00000000000a","name":"Interdit"}'::jsonb)$$,
  '42501', null, 'la Lectrice ne peut pas créer de matière');
update public.materials set atelier_stock_m = 0;
select is((select atelier_stock_m from public.materials where name = 'Drap laine froide'), 42.50::numeric,
  'la Lectrice ne peut pas modifier le stock');

-- Admin de B ----------------------------------------------------------------------
select set_config('request.jwt.claims', '{"sub":"00000000-0000-0000-0000-0000000000b1","role":"authenticated"}', true);
select is((select count(*)::int from public.materials), 0, 'un autre atelier ne voit rien');
select is((select count(*)::int from public.textile_specs), 0, 'ni les caractéristiques textiles');

select * from finish();
rollback;
