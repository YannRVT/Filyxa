-- Tests du quota de scans (phase 6).
begin;
create extension if not exists pgtap with schema extensions;
select plan(9);

insert into auth.users (id, email) values
  ('00000000-0000-0000-0000-0000000000e1', 'editeur@quota.test'),
  ('00000000-0000-0000-0000-0000000000e2', 'autre@quota.test');
insert into public.organizations (id, name, kind, scan_quota) values
  ('40000000-0000-0000-0000-00000000000a', 'Atelier Quota', 'atelier', 2),
  ('40000000-0000-0000-0000-00000000000b', 'Autre atelier', 'atelier', 300),
  ('40000000-0000-0000-0000-00000000000c', 'Fournisseur', 'supplier', 300);
insert into public.memberships (user_id, org_id, role) values
  ('00000000-0000-0000-0000-0000000000e1', '40000000-0000-0000-0000-00000000000a', 'editor'),
  ('00000000-0000-0000-0000-0000000000e2', '40000000-0000-0000-0000-00000000000b', 'admin');

-- En tant que service (Edge Function)
select is(public.reserve_scan('40000000-0000-0000-0000-00000000000a'), '{"scans":1,"quota":2}'::jsonb, 'premier scan réservé');
select is(public.reserve_scan('40000000-0000-0000-0000-00000000000a'), '{"scans":2,"quota":2}'::jsonb, 'deuxième scan réservé');
select throws_ok($$select public.reserve_scan('40000000-0000-0000-0000-00000000000a')$$, 'P0001', 'quota_exceeded',
  'au-delà du quota, le scan est refusé');
select lives_ok($$select public.release_scan('40000000-0000-0000-0000-00000000000a')$$, 'un scan non effectué est rendu');
select is((public.reserve_scan('40000000-0000-0000-0000-00000000000a') ->> 'scans')::int, 2, 'le scan rendu est de nouveau disponible');
select throws_ok($$select public.reserve_scan('40000000-0000-0000-0000-00000000000c')$$, '42501', 'not_an_atelier',
  'un fournisseur ne scanne pas');

set local role authenticated;
select set_config('request.jwt.claims', '{"sub":"00000000-0000-0000-0000-0000000000e1","role":"authenticated"}', true);
select is(public.current_scan_usage('40000000-0000-0000-0000-00000000000a'), '{"scans":2,"quota":2}'::jsonb,
  'un membre lit l''usage de son atelier');
select is(public.current_scan_usage('40000000-0000-0000-0000-00000000000b'), null, 'mais pas celui d''un autre atelier');
select throws_ok($$select public.reserve_scan('40000000-0000-0000-0000-00000000000a')$$, '42501', null,
  'un utilisateur ne peut pas réserver de scan lui-même (contournement de l''IA)');

select * from finish();
rollback;
