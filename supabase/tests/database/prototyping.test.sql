-- Tests du prototypage (phase 19).
begin;
create extension if not exists pgtap with schema extensions;
select plan(5);

insert into auth.users (id, email) values
  ('00000000-0000-0000-0000-0000000000a2', 'claire@proto.test'),
  ('00000000-0000-0000-0000-0000000000a5', 'autre@proto.test');
insert into public.organizations (id, name, kind, plan) values
  ('a2000000-0000-0000-0000-00000000000a', 'Atelier Proto', 'atelier', 'pro'),
  ('a2000000-0000-0000-0000-00000000000b', 'Atelier Essentiel', 'atelier', 'essential');
insert into public.memberships (user_id, org_id, role) values
  ('00000000-0000-0000-0000-0000000000a2', 'a2000000-0000-0000-0000-00000000000a', 'editor'),
  ('00000000-0000-0000-0000-0000000000a5', 'a2000000-0000-0000-0000-00000000000b', 'editor');
insert into public.materials (id, org_id, name) values
  ('a2100000-0000-0000-0000-000000000001', 'a2000000-0000-0000-0000-00000000000a', 'Sergé'),
  ('a2100000-0000-0000-0000-000000000002', 'a2000000-0000-0000-0000-00000000000b', 'Toile');
insert into public.collections (id, org_id, name) values
  ('a3000000-0000-0000-0000-000000000001', 'a2000000-0000-0000-0000-00000000000a', 'AH27'),
  ('a3000000-0000-0000-0000-000000000002', 'a2000000-0000-0000-0000-00000000000b', 'PE28');
insert into public.models (id, collection_id, name, product_type) values
  ('a4000000-0000-0000-0000-000000000001', 'a3000000-0000-0000-0000-000000000001', 'Veste', 'garment'),
  ('a4000000-0000-0000-0000-000000000002', 'a3000000-0000-0000-0000-000000000002', 'Sac', 'leather_goods');
insert into public.model_materials (colorway_id, material_id, role, consumption)
select c.id, m.id, 'main', 1.8 from public.colorways c
join public.models md on md.id = c.model_id
join public.materials m on m.org_id = md.org_id;

set local role authenticated;
select set_config('request.jwt.claims', '{"sub":"00000000-0000-0000-0000-0000000000a2","role":"authenticated"}', true);
select results_eq($$select prototype_count, (select proto_loss_pct from public.model_materials mm join public.colorways c on c.id = mm.colorway_id
  where c.model_id = m.id) from public.models m where id = 'a4000000-0000-0000-0000-000000000001'$$,
  $$values (1, 25.00::numeric)$$, 'un prototype et 25 % de perte par défaut');
select lives_ok($$update public.models set prototype_count = 3 where id = 'a4000000-0000-0000-0000-000000000001'$$, 'nombre de prototypes');
select lives_ok($$update public.model_materials set proto_loss_pct = 40 where org_id = 'a2000000-0000-0000-0000-00000000000a'$$,
  'perte de prototypage par ligne');

select set_config('request.jwt.claims', '{"sub":"00000000-0000-0000-0000-0000000000a5","role":"authenticated"}', true);
select throws_ok($$update public.models set prototype_count = 3 where id = 'a4000000-0000-0000-0000-000000000002'$$,
  '42501', 'pro_required', 'hors Pro, pas de prototypes');
select throws_ok($$update public.model_materials set proto_loss_pct = 40 where org_id = 'a2000000-0000-0000-0000-00000000000b'$$,
  '42501', 'pro_required', 'hors Pro, pas de perte de prototypage');

select * from finish();
rollback;
