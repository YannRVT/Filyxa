-- Tests de l'association de colonnes mémorisée de l'import atelier (phase 25).
begin;
create extension if not exists pgtap with schema extensions;
select plan(4);

insert into auth.users (id, email) values
  ('00000000-0000-0000-0000-000000000d21', 'claire@map.test'),
  ('00000000-0000-0000-0000-000000000d22', 'paul@map.test'),
  ('00000000-0000-0000-0000-000000000d23', 'lea@map.test');
insert into public.organizations (id, name, kind) values ('d5000000-0000-0000-0000-00000000000a', 'Atelier Map', 'atelier');
insert into public.memberships (user_id, org_id, role) values
  ('00000000-0000-0000-0000-000000000d21', 'd5000000-0000-0000-0000-00000000000a', 'editor'),
  ('00000000-0000-0000-0000-000000000d22', 'd5000000-0000-0000-0000-00000000000a', 'editor'),
  ('00000000-0000-0000-0000-000000000d23', 'd5000000-0000-0000-0000-00000000000a', 'viewer');

set local role authenticated;
select set_config('request.jwt.claims', '{"sub":"00000000-0000-0000-0000-000000000d21","role":"authenticated"}', true);
select lives_ok($$insert into public.atelier_settings (org_id, import_mapping) values
  ('d5000000-0000-0000-0000-00000000000a', '{"name":"Désignation","price":"PU"}')
  on conflict (org_id) do update set import_mapping = excluded.import_mapping$$, 'l''Éditeur mémorise l''association');

select set_config('request.jwt.claims', '{"sub":"00000000-0000-0000-0000-000000000d22","role":"authenticated"}', true);
select is((select import_mapping ->> 'price' from public.atelier_settings), 'PU', 'partagée par tous les Éditeurs de l''atelier');

select set_config('request.jwt.claims', '{"sub":"00000000-0000-0000-0000-000000000d23","role":"authenticated"}', true);
update public.atelier_settings set import_mapping = '{}';
select is((select import_mapping ->> 'price' from public.atelier_settings), 'PU', 'le Lecteur ne la modifie pas');
select throws_ok($$insert into public.atelier_settings (org_id, import_mapping) values ('d5000000-0000-0000-0000-00000000000a', '[]')$$,
  null, null, 'une association est un objet');

select * from finish();
rollback;
