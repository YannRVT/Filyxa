-- Tests de la console super-admin (phase 14).
begin;
create extension if not exists pgtap with schema extensions;
select plan(11);

insert into auth.users (id, email) values
  ('00000000-0000-0000-0000-000000000091', 'super@console.test'),
  ('00000000-0000-0000-0000-000000000092', 'claire@console.test');
update public.profiles set is_superadmin = true where id = '00000000-0000-0000-0000-000000000091';
insert into public.organizations (id, name, kind, scan_quota) values
  ('b1000000-0000-0000-0000-00000000000a', 'Atelier Console', 'atelier', 2),
  ('b1000000-0000-0000-0000-00000000000c', 'Tissage Console', 'supplier', 0);
insert into public.memberships (user_id, org_id, role) values
  ('00000000-0000-0000-0000-000000000092', 'b1000000-0000-0000-0000-00000000000a', 'admin');
insert into public.materials (org_id, name) values
  ('b1000000-0000-0000-0000-00000000000a', 'A'), ('b1000000-0000-0000-0000-00000000000a', 'B');
insert into public.usage_counters (org_id, month, scans, input_tokens, output_tokens) values
  ('b1000000-0000-0000-0000-00000000000a', date_trunc('month', now() at time zone 'utc')::date, 2, 1000000, 100000);

set local role authenticated;

-- Admin d'atelier : tout est refusé ----------------------------------------------------------------
select set_config('request.jwt.claims', '{"sub":"00000000-0000-0000-0000-000000000092","role":"authenticated"}', true);
select throws_ok($$select * from public.admin_usage()$$, '42501', 'forbidden', 'l''usage est refusé à un admin d''atelier');
select throws_ok($$select public.admin_set_plan('b1000000-0000-0000-0000-00000000000a', 'pro')$$, '42501', 'forbidden',
  'changer l''offre est refusé à un admin d''atelier');
select is((select count(*)::int from public.platform_settings), 0, 'les réglages de la plateforme sont invisibles');

-- Super-admin ---------------------------------------------------------------------------------------
select set_config('request.jwt.claims', '{"sub":"00000000-0000-0000-0000-000000000091","role":"authenticated"}', true);
select results_eq($$select scans, members, items, cost_usd from public.admin_usage() where name = 'Atelier Console'$$,
  $$values (2, 1, 2, 6.0000::numeric)$$, 'usage du mois : scans, membres, matières, coût (1 M × 4 $ + 0,1 M × 20 $)');
select is((select cost_usd from public.admin_usage((now() - interval '1 month')::date) where name = 'Atelier Console'), 0.0000::numeric,
  'un mois sans scan coûte 0');

select lives_ok($$select public.admin_set_plan('b1000000-0000-0000-0000-00000000000a', 'pro')$$, 'passer à l''offre Pro');
select results_eq($$select plan, scan_quota from public.organizations where id = 'b1000000-0000-0000-0000-00000000000a'$$,
  $$values ('pro'::text, 3000)$$, 'le quota par défaut de l''offre s''applique');
select throws_ok($$select public.admin_set_plan('b1000000-0000-0000-0000-00000000000a', 'custom')$$, '22023', 'quota_required',
  'une offre sur mesure exige un quota');
select lives_ok($$select public.admin_set_plan('b1000000-0000-0000-0000-00000000000a', 'custom', 5000)$$, 'quota sur mesure');

update public.platform_settings set ai_input_usd_per_mtok = 2, ai_output_usd_per_mtok = 10;
select is((select cost_usd from public.admin_usage() where name = 'Atelier Console'), 3.0000::numeric,
  'le coût suit le tarif saisi');

-- Le nouveau quota s'applique tout de suite au scanner (réservation côté serveur).
reset role;
select is((public.reserve_scan('b1000000-0000-0000-0000-00000000000a') ->> 'quota')::int, 5000,
  'le scanner applique immédiatement le nouveau quota');

select * from finish();
rollback;
