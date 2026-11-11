-- Tests des signalements d'erreur et des notifications (phase 9).
begin;
create extension if not exists pgtap with schema extensions;
select plan(17);

insert into auth.users (id, email) values
  ('00000000-0000-0000-0000-0000000000d1', 'marco@signal.test'),
  ('00000000-0000-0000-0000-0000000000d2', 'claire@signal.test'),
  ('00000000-0000-0000-0000-0000000000d3', 'lea@signal.test'),
  ('00000000-0000-0000-0000-0000000000d4', 'paul@signal.test');
insert into public.organizations (id, name, kind) values
  ('90000000-0000-0000-0000-00000000000c', 'Tissage Signal', 'supplier'),
  ('90000000-0000-0000-0000-00000000000a', 'Atelier Signal', 'atelier'),
  ('90000000-0000-0000-0000-00000000000b', 'Atelier Autre', 'atelier');
insert into public.memberships (user_id, org_id, role) values
  ('00000000-0000-0000-0000-0000000000d1', '90000000-0000-0000-0000-00000000000c', 'admin'),
  ('00000000-0000-0000-0000-0000000000d2', '90000000-0000-0000-0000-00000000000a', 'editor'),
  ('00000000-0000-0000-0000-0000000000d3', '90000000-0000-0000-0000-00000000000a', 'viewer'),
  ('00000000-0000-0000-0000-0000000000d4', '90000000-0000-0000-0000-00000000000b', 'admin');
insert into public.supplier_references (id, supplier_org_id, code, name, weight_gsm) values
  ('a0000000-0000-0000-0000-000000000001', '90000000-0000-0000-0000-00000000000c', 'TS-1', 'Sergé', 280);
insert into public.materials (id, org_id, name, supplier_reference_id) values
  ('b0000000-0000-0000-0000-000000000001', '90000000-0000-0000-0000-00000000000a', 'Mon sergé', 'a0000000-0000-0000-0000-000000000001'),
  ('b0000000-0000-0000-0000-000000000002', '90000000-0000-0000-0000-00000000000a', 'Fiche maison', null);

set local role authenticated;

-- Atelier ---------------------------------------------------------------------------------
select set_config('request.jwt.claims', '{"sub":"00000000-0000-0000-0000-0000000000d3","role":"authenticated"}', true);
select throws_ok($$select public.create_error_report('b0000000-0000-0000-0000-000000000001', 'weight', '300 g/m²')$$,
  '42501', 'forbidden', 'un Lecteur ne signale pas');

select set_config('request.jwt.claims', '{"sub":"00000000-0000-0000-0000-0000000000d2","role":"authenticated"}', true);
select throws_ok($$select public.create_error_report('b0000000-0000-0000-0000-000000000002', 'weight', '300')$$,
  '22023', 'material_not_linked', 'on ne signale que sur une matière liée');
select throws_ok($$select public.create_error_report('b0000000-0000-0000-0000-000000000001', 'weight', '  ')$$,
  '23514', null, 'la valeur constatée est obligatoire');
select set_config('test.report', public.create_error_report(
  'b0000000-0000-0000-0000-000000000001', 'weight', '300 g/m²', 'Pesé sur 3 échantillons')::text, false);
select set_config('test.shared', public.create_error_report(
  'b0000000-0000-0000-0000-000000000001', 'composition', '60 % WO', null, true)::text, false);
select is((select count(*)::int from public.error_reports), 2, 'l''atelier voit ses signalements');
select throws_ok($$insert into public.error_reports (reference_id, supplier_org_id, atelier_org_id, field, observed_value)
  values ('a0000000-0000-0000-0000-000000000001', '90000000-0000-0000-0000-00000000000c', '90000000-0000-0000-0000-00000000000a', 'name', 'x')$$,
  '42501', null, 'pas d''écriture directe dans la table');

select set_config('request.jwt.claims', '{"sub":"00000000-0000-0000-0000-0000000000d4","role":"authenticated"}', true);
select is((select count(*)::int from public.error_reports), 0, 'un autre atelier ne voit rien');
select is((select count(*)::int from public.supplier_error_reports('90000000-0000-0000-0000-00000000000c')), 0,
  'un atelier ne lit pas les signalements du fournisseur');

-- Fournisseur ------------------------------------------------------------------------------
select set_config('request.jwt.claims', '{"sub":"00000000-0000-0000-0000-0000000000d1","role":"authenticated"}', true);
select is((select count(*)::int from public.notifications where kind = 'report_new'), 2, 'le fournisseur est notifié');
select is((select count(*)::int from public.error_reports), 0, 'le fournisseur ne lit pas la table brute');
select results_eq($$select field::text, atelier_name from public.supplier_error_reports('90000000-0000-0000-0000-00000000000c')
  order by field$$,
  $$values ('composition'::text, 'Atelier Signal'::text), ('weight'::text, null::text)$$,
  'nom de l''atelier masqué, sauf s''il a choisi de le partager');
select throws_ok(format($$select public.resolve_error_report(%L, 'rejected', '')$$, current_setting('test.report')),
  '22023', 'reason_required', 'un rejet exige un motif');
select lives_ok(format($$select public.resolve_error_report(%L, 'fixed', 'Merci, corrigé.')$$, current_setting('test.report')),
  'le fournisseur passe le signalement à « Corrigé »');
select throws_ok(format($$select public.resolve_error_report(%L, 'rejected', 'non')$$, current_setting('test.report')),
  '22023', 'report_already_resolved', 'un signalement traité ne change plus');
select lives_ok(format($$select public.resolve_error_report(%L, 'rejected', 'Mesure faite après lavage.')$$, current_setting('test.shared')),
  'rejet avec motif');

-- Atelier : statut et notifications -----------------------------------------------------------
select set_config('request.jwt.claims', '{"sub":"00000000-0000-0000-0000-0000000000d3","role":"authenticated"}', true);
select results_eq($$select status::text, response from public.error_reports order by field$$,
  $$values ('rejected'::text, 'Mesure faite après lavage.'::text), ('fixed'::text, 'Merci, corrigé.'::text)$$,
  'l''atelier voit le statut et la réponse');
select results_eq($$select kind, data ->> 'name' from public.notifications order by kind$$,
  $$values ('report_fixed'::text, 'Mon sergé'::text), ('report_rejected'::text, 'Mon sergé'::text)$$,
  'chaque membre de l''atelier reçoit une notification');
update public.notifications set read_at = now();
select is((select count(*)::int from public.notifications where read_at is null), 0, 'les notifications se marquent lues');

select * from finish();
rollback;
