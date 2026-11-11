-- Tests des notifications du Studio (phase 11).
begin;
create extension if not exists pgtap with schema extensions;
select plan(9);

insert into auth.users (id, email) values
  ('00000000-0000-0000-0000-0000000000b1', 'marco@alerte.test'),
  ('00000000-0000-0000-0000-0000000000b2', 'claire@alerte.test'),
  ('00000000-0000-0000-0000-0000000000b3', 'lea@alerte.test');
insert into public.organizations (id, name, kind) values
  ('f0000000-0000-0000-0000-00000000000c', 'Tissage Alerte', 'supplier'),
  ('f0000000-0000-0000-0000-00000000000a', 'Atelier Alerte', 'atelier');
insert into public.memberships (user_id, org_id, role) values
  ('00000000-0000-0000-0000-0000000000b1', 'f0000000-0000-0000-0000-00000000000c', 'admin'),
  ('00000000-0000-0000-0000-0000000000b2', 'f0000000-0000-0000-0000-00000000000a', 'editor'),
  ('00000000-0000-0000-0000-0000000000b3', 'f0000000-0000-0000-0000-00000000000a', 'viewer');
insert into public.supplier_settings (org_id, availability_mode, low_stock_threshold_m)
values ('f0000000-0000-0000-0000-00000000000c', 'tiers', 50);
insert into public.supplier_references (id, supplier_org_id, code, name, weight_gsm, stock_m) values
  ('f1000000-0000-0000-0000-000000000001', 'f0000000-0000-0000-0000-00000000000c', 'TA-1', 'Sergé', 280, 300),
  ('f1000000-0000-0000-0000-000000000002', 'f0000000-0000-0000-0000-00000000000c', 'TA-2', 'Hors modèle', 200, 300);
insert into public.materials (id, org_id, name, supplier_reference_id) values
  ('f2000000-0000-0000-0000-000000000001', 'f0000000-0000-0000-0000-00000000000a', 'Mon sergé', 'f1000000-0000-0000-0000-000000000001'),
  ('f2000000-0000-0000-0000-000000000002', 'f0000000-0000-0000-0000-00000000000a', 'Pas utilisée', 'f1000000-0000-0000-0000-000000000002');
insert into public.collections (id, org_id, name) values ('f3000000-0000-0000-0000-000000000001', 'f0000000-0000-0000-0000-00000000000a', 'AH27');
insert into public.models (id, collection_id, name, product_type)
  values ('f4000000-0000-0000-0000-000000000001', 'f3000000-0000-0000-0000-000000000001', 'Veste Arno', 'garment');
insert into public.model_materials (colorway_id, material_id, role, consumption)
select id, 'f2000000-0000-0000-0000-000000000001', 'main', 1.8 from public.colorways
where model_id = 'f4000000-0000-0000-0000-000000000001';

-- Le fournisseur fait évoluer ses références.
set local role authenticated;
select set_config('request.jwt.claims', '{"sub":"00000000-0000-0000-0000-0000000000b1","role":"authenticated"}', true);
update public.supplier_references set stock_m = 20 where id = 'f1000000-0000-0000-0000-000000000001';
update public.supplier_references set stock_m = 10 where id = 'f1000000-0000-0000-0000-000000000001';
update public.supplier_references set stock_m = 0 where id = 'f1000000-0000-0000-0000-000000000001';
update public.supplier_references set stock_m = 0 where id = 'f1000000-0000-0000-0000-000000000002';
reset role;

select is((select count(*)::int from public.notifications where kind = 'stock_low'), 2,
  'stock faible : chaque membre de l''atelier est prévenu, une seule fois');
select is((select count(*)::int from public.notifications where kind = 'stock_out'), 2, 'rupture : notifiée');
select results_eq($$select distinct data -> 'models' -> 0 ->> 'name', material_id from public.notifications where kind = 'stock_out'$$,
  $$values ('Veste Arno'::text, 'f2000000-0000-0000-0000-000000000001'::uuid)$$,
  'la notification cite le modèle et ouvre la fiche');
select is((select count(*)::int from public.notifications where reference_id = 'f1000000-0000-0000-0000-000000000002'), 0,
  'une matière utilisée dans aucun modèle ne déclenche rien');

-- Rupture répétée : pas de doublon tant que non lue ; nouvelle notification après lecture.
update public.supplier_references set stock_m = 100 where id = 'f1000000-0000-0000-0000-000000000001';
update public.supplier_references set stock_m = 0 where id = 'f1000000-0000-0000-0000-000000000001';
select is((select count(*)::int from public.notifications where kind = 'stock_out'), 2, 'pas de doublon non lu');
update public.notifications set read_at = now();
update public.supplier_references set stock_m = 100 where id = 'f1000000-0000-0000-0000-000000000001';
update public.supplier_references set stock_m = 0 where id = 'f1000000-0000-0000-0000-000000000001';
select is((select count(*)::int from public.notifications where kind = 'stock_out' and read_at is null), 2,
  'une nouvelle rupture après lecture est notifiée');

-- Fiche modifiée, puis retirée.
update public.supplier_references set weight_gsm = 290 where id = 'f1000000-0000-0000-0000-000000000001';
select is((select count(*)::int from public.notifications where kind = 'reference_updated'), 2, 'fiche modifiée : notifiée');
update public.supplier_references set retired_at = now() where id = 'f1000000-0000-0000-0000-000000000001';
select is((select count(*)::int from public.notifications where kind = 'reference_retired'), 2, 'référence retirée : notifiée');

-- Disponibilité masquée : le stock n'est jamais révélé par une notification.
update public.supplier_references set retired_at = null, stock_m = 300, availability_mode = 'hidden'
  where id = 'f1000000-0000-0000-0000-000000000001';
delete from public.notifications;
update public.supplier_references set stock_m = 0 where id = 'f1000000-0000-0000-0000-000000000001';
select is((select count(*)::int from public.notifications), 0, 'disponibilité masquée : aucune notification de stock');

select * from finish();
rollback;
