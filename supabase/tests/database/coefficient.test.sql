-- Tests du prix de vente visé et du coefficient minimal (phase 22).
begin;
create extension if not exists pgtap with schema extensions;
select plan(7);

insert into auth.users (id, email) values
  ('00000000-0000-0000-0000-000000000c11', 'admin@coef.test'),
  ('00000000-0000-0000-0000-000000000c12', 'claire@coef.test'),
  ('00000000-0000-0000-0000-000000000c13', 'lea@coef.test');
insert into public.organizations (id, name, kind, plan) values
  ('c5000000-0000-0000-0000-00000000000a', 'Atelier Coef', 'atelier', 'pro');
insert into public.memberships (user_id, org_id, role) values
  ('00000000-0000-0000-0000-000000000c11', 'c5000000-0000-0000-0000-00000000000a', 'admin'),
  ('00000000-0000-0000-0000-000000000c12', 'c5000000-0000-0000-0000-00000000000a', 'editor'),
  ('00000000-0000-0000-0000-000000000c13', 'c5000000-0000-0000-0000-00000000000a', 'viewer');
insert into public.collections (id, org_id, name) values ('c5300000-0000-0000-0000-000000000001', 'c5000000-0000-0000-0000-00000000000a', 'AH27');
insert into public.models (id, collection_id, name, product_type) values
  ('c5400000-0000-0000-0000-000000000001', 'c5300000-0000-0000-0000-000000000001', 'Veste', 'garment');

set local role authenticated;
select set_config('request.jwt.claims', '{"sub":"00000000-0000-0000-0000-000000000c12","role":"authenticated"}', true);
select is((select min_coefficient from public.organizations), 2.50::numeric, 'coefficient minimal de 2,5 par défaut');
select lives_ok($$insert into public.model_prices (model_id, target_price) values ('c5400000-0000-0000-0000-000000000001', 120)$$,
  'l''Éditeur fixe le prix de vente visé');
select throws_ok($$select public.set_min_coefficient('c5000000-0000-0000-0000-00000000000a', 3)$$, '42501', 'forbidden',
  'seul l''Admin modifie le coefficient minimal');

select set_config('request.jwt.claims', '{"sub":"00000000-0000-0000-0000-000000000c11","role":"authenticated"}', true);
select lives_ok($$select public.set_min_coefficient('c5000000-0000-0000-0000-00000000000a', 3)$$, 'l''Admin le modifie');
select is((select min_coefficient from public.organizations), 3.00::numeric, 'nouveau minimum');

select set_config('request.jwt.claims', '{"sub":"00000000-0000-0000-0000-000000000c13","role":"authenticated"}', true);
select is((select count(*)::int from public.model_prices), 0, 'le Lecteur ne reçoit pas le prix de vente');

-- Hors Pro : refusé.
reset role;
update public.organizations set plan = 'essential' where id = 'c5000000-0000-0000-0000-00000000000a';
set local role authenticated;
select set_config('request.jwt.claims', '{"sub":"00000000-0000-0000-0000-000000000c11","role":"authenticated"}', true);
select throws_ok($$select public.set_min_coefficient('c5000000-0000-0000-0000-00000000000a', 2)$$, '42501', 'pro_required',
  'hors Pro, coefficient minimal verrouillé');

select * from finish();
rollback;
