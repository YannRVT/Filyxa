-- Tests des statuts du modèle et du verrou Pro (phase 15).
begin;
create extension if not exists pgtap with schema extensions;
select plan(15);

insert into auth.users (id, email) values
  ('00000000-0000-0000-0000-0000000000c1', 'marco@statut.test'),
  ('00000000-0000-0000-0000-0000000000c2', 'claire@statut.test'),
  ('00000000-0000-0000-0000-0000000000c3', 'lea@statut.test'),
  ('00000000-0000-0000-0000-0000000000c4', 'super@statut.test');
update public.profiles set is_superadmin = true where id = '00000000-0000-0000-0000-0000000000c4';
insert into public.organizations (id, name, kind, plan) values
  ('e0000000-0000-0000-0000-00000000000c', 'Tissage Statut', 'supplier', 'pilot'),
  ('e0000000-0000-0000-0000-00000000000a', 'Atelier Statut', 'atelier', 'essential');
insert into public.memberships (user_id, org_id, role) values
  ('00000000-0000-0000-0000-0000000000c1', 'e0000000-0000-0000-0000-00000000000c', 'admin'),
  ('00000000-0000-0000-0000-0000000000c2', 'e0000000-0000-0000-0000-00000000000a', 'editor'),
  ('00000000-0000-0000-0000-0000000000c3', 'e0000000-0000-0000-0000-00000000000a', 'viewer');
insert into public.supplier_references (id, supplier_org_id, code, name, stock_m) values
  ('e1000000-0000-0000-0000-000000000001', 'e0000000-0000-0000-0000-00000000000c', 'TS-1', 'Sergé', 300);
insert into public.materials (id, org_id, name, supplier_reference_id) values
  ('e2000000-0000-0000-0000-000000000001', 'e0000000-0000-0000-0000-00000000000a', 'Mon sergé', 'e1000000-0000-0000-0000-000000000001');
insert into public.collections (id, org_id, name) values ('e3000000-0000-0000-0000-000000000001', 'e0000000-0000-0000-0000-00000000000a', 'AH27');
insert into public.models (id, collection_id, name, product_type)
  values ('e4000000-0000-0000-0000-000000000001', 'e3000000-0000-0000-0000-000000000001', 'Veste Arno', 'garment');
insert into public.model_materials (colorway_id, material_id, role, consumption)
select id, 'e2000000-0000-0000-0000-000000000001', 'main', 1.8 from public.colorways
where model_id = 'e4000000-0000-0000-0000-000000000001';

select is((select status::text from public.models where id = 'e4000000-0000-0000-0000-000000000001'), 'idea',
  'un nouveau modèle part d''Idée');
select results_eq($$select code from public.plans where pro order by position$$,
  $$values ('pilot'::text), ('pro'), ('custom')$$, 'Pilote, Pro et Sur mesure ouvrent les fonctionnalités Pro');

set local role authenticated;

-- Atelier Essentiel : statut verrouillé.
select set_config('request.jwt.claims', '{"sub":"00000000-0000-0000-0000-0000000000c2","role":"authenticated"}', true);
select is(public.has_pro('e0000000-0000-0000-0000-00000000000a'), false, 'Essentiel : pas d''accès Pro');
select throws_ok($$update public.models set status = 'prototype' where id = 'e4000000-0000-0000-0000-000000000001'$$,
  '42501', 'pro_required', 'hors Pro, le serveur refuse le changement de statut');
select lives_ok($$update public.models set name = 'Veste Arno 2' where id = 'e4000000-0000-0000-0000-000000000001'$$,
  'hors Pro, le reste du modèle se modifie comme en V1');

-- Hors Pro, tous les modèles comptent pour les notifications (comportement V1).
select set_config('request.jwt.claims', '{"sub":"00000000-0000-0000-0000-0000000000c1","role":"authenticated"}', true);
update public.supplier_references set stock_m = 0 where id = 'e1000000-0000-0000-0000-000000000001';
reset role;
select is((select count(*)::int from public.notifications where org_id = 'e0000000-0000-0000-0000-00000000000a'), 2,
  'hors Pro, un modèle en Idée est notifié comme en V1');
delete from public.notifications;
update public.supplier_references set stock_m = 300 where id = 'e1000000-0000-0000-0000-000000000001';
set local role authenticated;

-- Le super-admin passe l'atelier en Pro : effet immédiat.
select set_config('request.jwt.claims', '{"sub":"00000000-0000-0000-0000-0000000000c4","role":"authenticated"}', true);
select public.admin_set_plan('e0000000-0000-0000-0000-00000000000a', 'pro');
select set_config('request.jwt.claims', '{"sub":"00000000-0000-0000-0000-0000000000c2","role":"authenticated"}', true);
select is(public.has_pro('e0000000-0000-0000-0000-00000000000a'), true, 'Pro : accès ouvert sans reconnexion');
select set_config('request.jwt.claims', '{"sub":"00000000-0000-0000-0000-0000000000c1","role":"authenticated"}', true);
select is(public.has_pro('e0000000-0000-0000-0000-00000000000a'), false, 'has_pro ne renseigne pas sur une autre organisation');
select set_config('request.jwt.claims', '{"sub":"00000000-0000-0000-0000-0000000000c2","role":"authenticated"}', true);

-- Pro : un modèle en Idée ne notifie plus ; en Prototype, si.
select set_config('request.jwt.claims', '{"sub":"00000000-0000-0000-0000-0000000000c1","role":"authenticated"}', true);
update public.supplier_references set stock_m = 0 where id = 'e1000000-0000-0000-0000-000000000001';
reset role;
select is((select count(*)::int from public.notifications where org_id = 'e0000000-0000-0000-0000-00000000000a'), 0,
  'Pro : un modèle en Idée ne déclenche pas de notification');
set local role authenticated;
update public.supplier_references set stock_m = 300 where id = 'e1000000-0000-0000-0000-000000000001';

select set_config('request.jwt.claims', '{"sub":"00000000-0000-0000-0000-0000000000c3","role":"authenticated"}', true);
update public.models set status = 'prototype' where id = 'e4000000-0000-0000-0000-000000000001';
select set_config('request.jwt.claims', '{"sub":"00000000-0000-0000-0000-0000000000c2","role":"authenticated"}', true);
select is((select status::text from public.models where id = 'e4000000-0000-0000-0000-000000000001'), 'idea',
  'le Lecteur ne change pas le statut');
select lives_ok($$update public.models set status = 'prototype' where id = 'e4000000-0000-0000-0000-000000000001'$$,
  'l''Éditeur passe le modèle en Prototype');

select set_config('request.jwt.claims', '{"sub":"00000000-0000-0000-0000-0000000000c1","role":"authenticated"}', true);
update public.supplier_references set stock_m = 0 where id = 'e1000000-0000-0000-0000-000000000001';
reset role;
select is((select count(*)::int from public.notifications where org_id = 'e0000000-0000-0000-0000-00000000000a'), 2,
  'Pro : un modèle en Prototype est notifié');
set local role authenticated;

-- Retour en arrière permis, sauf depuis Livré.
select set_config('request.jwt.claims', '{"sub":"00000000-0000-0000-0000-0000000000c2","role":"authenticated"}', true);
select throws_ok($$update public.models set status = 'delivered' where id = 'e4000000-0000-0000-0000-000000000001'$$,
  '22023', 'invalid_status_transition', '« Livré » ne s''atteint que par la livraison confirmée');
select public.deliver_model('e4000000-0000-0000-0000-000000000001', '[]');
select throws_ok($$update public.models set status = 'in_production' where id = 'e4000000-0000-0000-0000-000000000001'$$,
  '22023', 'invalid_status_transition', 'un modèle livré ne change plus de statut');

-- Retour en Essentiel : le statut reste lisible.
select set_config('request.jwt.claims', '{"sub":"00000000-0000-0000-0000-0000000000c4","role":"authenticated"}', true);
select public.admin_set_plan('e0000000-0000-0000-0000-00000000000a', 'essential');
select set_config('request.jwt.claims', '{"sub":"00000000-0000-0000-0000-0000000000c2","role":"authenticated"}', true);
select is((select status::text from public.models where id = 'e4000000-0000-0000-0000-000000000001'), 'delivered',
  'après un retour en Essentiel, le statut reste lisible');

select * from finish();
rollback;
