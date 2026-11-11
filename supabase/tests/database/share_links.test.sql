-- Tests du lien partagé public (phase 13).
begin;
create extension if not exists pgtap with schema extensions;
select plan(14);

insert into auth.users (id, email) values
  ('00000000-0000-0000-0000-0000000000a1', 'claire@partage.test'),
  ('00000000-0000-0000-0000-0000000000a2', 'lea@partage.test'),
  ('00000000-0000-0000-0000-0000000000a3', 'paul@partage.test');
insert into public.organizations (id, name, kind) values
  ('a1000000-0000-0000-0000-00000000000a', 'Atelier Partage', 'atelier'),
  ('a1000000-0000-0000-0000-00000000000b', 'Atelier Autre', 'atelier');
insert into public.memberships (user_id, org_id, role) values
  ('00000000-0000-0000-0000-0000000000a1', 'a1000000-0000-0000-0000-00000000000a', 'editor'),
  ('00000000-0000-0000-0000-0000000000a2', 'a1000000-0000-0000-0000-00000000000a', 'viewer'),
  ('00000000-0000-0000-0000-0000000000a3', 'a1000000-0000-0000-0000-00000000000b', 'admin');
insert into public.materials (id, org_id, name, supplier_code, atelier_stock_m, notes, price_per_m, tags) values
  ('a2000000-0000-0000-0000-000000000001', 'a1000000-0000-0000-0000-00000000000a', 'Sergé', 'TD-1', 42.5,
   'SECRET-NOTE', 24.5, '{SECRET-TAG}');
insert into public.textile_specs (material_id, weight_gsm, care) values ('a2000000-0000-0000-0000-000000000001', 280, '{wash_30}');
insert into public.collections (id, org_id, name) values ('a3000000-0000-0000-0000-000000000001', 'a1000000-0000-0000-0000-00000000000a', 'AH27');
insert into public.models (id, collection_id, name, product_type)
  values ('a4000000-0000-0000-0000-000000000001', 'a3000000-0000-0000-0000-000000000001', 'Veste Arno', 'garment');
insert into public.model_materials (colorway_id, material_id, role, consumption)
select id, 'a2000000-0000-0000-0000-000000000001', 'main', 1.8 from public.colorways where model_id = 'a4000000-0000-0000-0000-000000000001';

set local role authenticated;

-- Création --------------------------------------------------------------------------------------
select set_config('request.jwt.claims', '{"sub":"00000000-0000-0000-0000-0000000000a2","role":"authenticated"}', true);
select throws_ok($$insert into public.share_links (org_id, scope, target_id)
  values ('a1000000-0000-0000-0000-00000000000a', 'material', 'a2000000-0000-0000-0000-000000000001')$$,
  '42501', null, 'un Lecteur ne crée pas de lien');

select set_config('request.jwt.claims', '{"sub":"00000000-0000-0000-0000-0000000000a1","role":"authenticated"}', true);
insert into public.share_links (id, org_id, scope, target_id, lang) values
  ('a5000000-0000-0000-0000-000000000001', 'a1000000-0000-0000-0000-00000000000a', 'collection', 'a3000000-0000-0000-0000-000000000001', 'pt'),
  ('a5000000-0000-0000-0000-000000000002', 'a1000000-0000-0000-0000-00000000000a', 'material', 'a2000000-0000-0000-0000-000000000001', 'fr');
select ok((select length(token) = 64 and expires_at > now() + interval '29 days'
  from public.share_links where id = 'a5000000-0000-0000-0000-000000000001'), 'jeton de 64 caractères, valable 30 jours par défaut');
select throws_ok($$insert into public.share_links (org_id, scope, target_id)
  values ('a1000000-0000-0000-0000-00000000000a', 'model', 'a2000000-0000-0000-0000-000000000001')$$,
  'P0002', 'share_target_not_found', 'la cible doit exister dans l''atelier');
select set_config('test.token', (select token from public.share_links where id = 'a5000000-0000-0000-0000-000000000001'), false);
select set_config('test.token_mat', (select token from public.share_links where id = 'a5000000-0000-0000-0000-000000000002'), false);

-- Visiteur sans compte -------------------------------------------------------------------------------
set local role anon;
select set_config('request.jwt.claims', '{"role":"anon"}', true);
select is((public.share_view(current_setting('test.token')) ->> 'status'), 'ok', 'le lien s''ouvre sans compte');
select is((public.share_view(current_setting('test.token')) ->> 'lang'), 'pt', 'dans la langue choisie à la création');
select is((public.share_view(current_setting('test.token')) #>> '{content,models,0,colorways,0,lines,0,material,weight_gsm}'), '280',
  'collection : modèles, coloris et matières à jour');
select ok(position('SECRET' in public.share_view(current_setting('test.token'))::text) = 0
  and position('42.5' in public.share_view(current_setting('test.token'))::text) = 0
  and position('24.5' in public.share_view(current_setting('test.token'))::text) = 0,
  'ni prix, ni notes, ni étiquettes, ni stock atelier dans la réponse');
select ok(not (public.share_view(current_setting('test.token_mat')) -> 'content') ?| array['price_per_m', 'notes', 'tags', 'atelier_stock_m'],
  'fiche matière : champs privés absents');
select is((public.share_view('inconnu') ->> 'status'), 'not_found', 'jeton inconnu');
select throws_ok($$select * from public.share_links$$, '42501', null, 'un visiteur ne lit pas la table des liens');
select throws_ok($$select public.share_material_json('a2000000-0000-0000-0000-000000000001')$$, '42501', null,
  'les fonctions internes ne sont pas ouvertes aux visiteurs');

-- Expiration et révocation -----------------------------------------------------------------------------
set local role authenticated;
select set_config('request.jwt.claims', '{"sub":"00000000-0000-0000-0000-0000000000a1","role":"authenticated"}', true);
update public.share_links set expires_at = now() - interval '1 day' where id = 'a5000000-0000-0000-0000-000000000001';
update public.share_links set revoked_at = now() where id = 'a5000000-0000-0000-0000-000000000002';
set local role anon;
select is((public.share_view(current_setting('test.token')) ->> 'status'), 'expired', 'lien expiré');
select is((public.share_view(current_setting('test.token_mat')) ->> 'status'), 'revoked', 'lien révoqué');

-- Autre atelier --------------------------------------------------------------------------------------------
set local role authenticated;
select set_config('request.jwt.claims', '{"sub":"00000000-0000-0000-0000-0000000000a3","role":"authenticated"}', true);
select is((select count(*)::int from public.share_links), 0, 'un autre atelier ne voit pas les liens');

select * from finish();
rollback;
