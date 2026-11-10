-- Tests du catalogue fournisseur (phase 5).
begin;
create extension if not exists pgtap with schema extensions;
select plan(16);

insert into auth.users (id, email) values
  ('00000000-0000-0000-0000-0000000000c1', 'marco@tisseur.test'),
  ('00000000-0000-0000-0000-0000000000c2', 'lecteur@tisseur.test'),
  ('00000000-0000-0000-0000-0000000000a1', 'claire@atelier.test'),
  ('00000000-0000-0000-0000-0000000000d1', 'sansorg@x.test');
insert into public.organizations (id, name, kind) values
  ('30000000-0000-0000-0000-00000000000c', 'Tisseur Biella', 'supplier'),
  ('30000000-0000-0000-0000-00000000000a', 'Atelier A', 'atelier');
insert into public.memberships (user_id, org_id, role) values
  ('00000000-0000-0000-0000-0000000000c1', '30000000-0000-0000-0000-00000000000c', 'admin'),
  ('00000000-0000-0000-0000-0000000000c2', '30000000-0000-0000-0000-00000000000c', 'viewer'),
  ('00000000-0000-0000-0000-0000000000a1', '30000000-0000-0000-0000-00000000000a', 'admin');

set local role authenticated;

-- Fournisseur : import -----------------------------------------------------------
select set_config('request.jwt.claims', '{"sub":"00000000-0000-0000-0000-0000000000c1","role":"authenticated"}', true);
select is(
  public.import_supplier_references('30000000-0000-0000-0000-00000000000c', '[
    {"code":"DR4521-NV","name":"Drap laine froide","stock_m":340,"weight_gsm":280,
     "composition":[{"fiber":"WO","pct":62},{"fiber":"PES","pct":38}]},
    {"code":"FL-300","name":"Flanelle","stock_m":12},
    {"code":"","name":"Sans code"},
    {"code":"BAD-1","name":"Composition fausse","composition":[{"fiber":"WO","pct":40}]}
  ]'::jsonb) - 'errors',
  '{"inserted":2,"updated":0}'::jsonb,
  'import : 2 lignes valides importées');
select is(
  jsonb_array_length(public.import_supplier_references('30000000-0000-0000-0000-00000000000c',
    '[{"code":"","name":"x"},{"code":"Y","name":"y","weight_gsm":99999}]'::jsonb) -> 'errors'),
  2, 'import : les lignes invalides sont listées avec leur motif');
select is(
  public.import_supplier_references('30000000-0000-0000-0000-00000000000c',
    '[{"code":"dr 4521 nv","name":"Drap laine froide","stock_m":20}]'::jsonb) - 'errors',
  '{"inserted":0,"updated":1}'::jsonb,
  'réimport : mise à jour par code normalisé, sans doublon');
select is((select count(*)::int from public.supplier_references where code_normalized = 'DR4521NV'), 1,
  'une seule référence DR4521NV');
select is((select weight_gsm from public.supplier_references where code_normalized = 'DR4521NV'), 280,
  'réimport : un champ absent du fichier ne vide pas la valeur existante');
select throws_ok(
  $$insert into public.supplier_references (supplier_org_id, code, name)
    values ('30000000-0000-0000-0000-00000000000a', 'X', 'Intrus')$$,
  '42501', null, 'un atelier ne peut pas avoir de catalogue');

insert into public.supplier_settings (org_id, availability_mode, low_stock_threshold_m)
values ('30000000-0000-0000-0000-00000000000c', 'tiers', 50);

-- Lecteur du fournisseur ------------------------------------------------------------
select set_config('request.jwt.claims', '{"sub":"00000000-0000-0000-0000-0000000000c2","role":"authenticated"}', true);
select throws_ok(
  $$select public.import_supplier_references('30000000-0000-0000-0000-00000000000c', '[{"code":"Z","name":"z"}]'::jsonb)$$,
  '42501', null, 'un Lecteur fournisseur ne peut pas importer');

-- Atelier : stock brut invisible, catalogue publié lisible ----------------------------
select set_config('request.jwt.claims', '{"sub":"00000000-0000-0000-0000-0000000000a1","role":"authenticated"}', true);
select is((select count(*)::int from public.supplier_references), 0, 'un atelier ne lit pas le stock brut');
select is((select count(*)::int from public.supplier_settings), 0, 'ni les réglages du fournisseur');
select results_eq(
  $$select availability_status::text, stock_m from public.supplier_catalog where code_normalized = 'DR4521NV'$$,
  $$values ('low'::text, null::numeric)$$,
  'paliers : 20 m sous le seuil de 50 m = stock faible, quantité masquée');
select throws_ok(
  $$select public.import_supplier_references('30000000-0000-0000-0000-00000000000c', '[{"code":"Z","name":"z"}]'::jsonb)$$,
  '42501', null, 'un atelier ne peut pas importer dans un catalogue fournisseur');

-- Réglages du fournisseur appliqués à la vue -----------------------------------------
reset role;
update public.supplier_references set availability_mode = 'exact' where code_normalized = 'DR4521NV';
update public.supplier_references set availability_mode = 'hidden' where code_normalized = 'FL300';
set local role authenticated;
select results_eq(
  $$select availability_status::text, stock_m from public.supplier_catalog where code_normalized = 'DR4521NV'$$,
  $$values ('low'::text, 20.00::numeric)$$,
  'quantité exacte affichée quand le fournisseur le choisit');
select results_eq(
  $$select availability_status::text from public.supplier_catalog where code_normalized = 'FL300'$$,
  $$values (null::text)$$,
  'disponibilité masquée quand le fournisseur le choisit');

reset role;
update public.supplier_references set stock_m = 0, lead_time_weeks = 6 where code_normalized = 'DR4521NV';
update public.supplier_references set retired_at = now() where code_normalized = 'FL300';
set local role authenticated;
select results_eq(
  $$select availability_status::text from public.supplier_catalog where code_normalized = 'DR4521NV'$$,
  $$values ('on_order'::text)$$,
  'stock nul avec délai = sur commande');
select is((select count(*)::int from public.supplier_catalog where code_normalized = 'FL300'), 0,
  'une référence retirée n''est plus publiée');

-- Compte sans organisation ---------------------------------------------------------------
select set_config('request.jwt.claims', '{"sub":"00000000-0000-0000-0000-0000000000d1","role":"authenticated"}', true);
select is((select count(*)::int from public.supplier_catalog), 0, 'sans atelier, aucun catalogue visible');

select * from finish();
rollback;
