-- Tests des échéances et de la notification de retard (phase 16).
begin;
create extension if not exists pgtap with schema extensions;
select plan(12);

insert into auth.users (id, email) values
  ('00000000-0000-0000-0000-0000000000d2', 'claire@echeance.test'),
  ('00000000-0000-0000-0000-0000000000d3', 'lea@echeance.test');
insert into public.organizations (id, name, kind, plan) values
  ('d0000000-0000-0000-0000-00000000000a', 'Atelier Échéance', 'atelier', 'pro'),
  ('d0000000-0000-0000-0000-00000000000b', 'Atelier Essentiel', 'atelier', 'essential');
insert into public.memberships (user_id, org_id, role) values
  ('00000000-0000-0000-0000-0000000000d2', 'd0000000-0000-0000-0000-00000000000a', 'editor'),
  ('00000000-0000-0000-0000-0000000000d3', 'd0000000-0000-0000-0000-00000000000a', 'viewer');
insert into public.collections (id, org_id, name) values
  ('d3000000-0000-0000-0000-000000000001', 'd0000000-0000-0000-0000-00000000000a', 'AH27'),
  ('d3000000-0000-0000-0000-000000000002', 'd0000000-0000-0000-0000-00000000000b', 'PE28');
insert into public.models (id, collection_id, name, product_type, status) values
  ('d4000000-0000-0000-0000-000000000001', 'd3000000-0000-0000-0000-000000000001', 'Veste Arno', 'garment', 'prototype'),
  ('d4000000-0000-0000-0000-000000000002', 'd3000000-0000-0000-0000-000000000001', 'Jupe Lina', 'garment', 'abandoned');
insert into public.models (id, collection_id, name, product_type) values
  ('d4000000-0000-0000-0000-000000000003', 'd3000000-0000-0000-0000-000000000002', 'Sac Ola', 'leather_goods');

set local role authenticated;
select set_config('request.jwt.claims', '{"sub":"00000000-0000-0000-0000-0000000000d2","role":"authenticated"}', true);
select lives_ok($$insert into public.model_deadlines (model_id, stage, due_date) values
  ('d4000000-0000-0000-0000-000000000001', 'prototype', '2026-11-01'),
  ('d4000000-0000-0000-0000-000000000001', 'validated', '2026-11-10'),
  ('d4000000-0000-0000-0000-000000000001', 'delivered', '2027-03-01'),
  ('d4000000-0000-0000-0000-000000000002', 'validated', '2026-11-01')$$, 'l''Éditeur fixe les échéances');
select is((select org_id from public.model_deadlines where stage = 'delivered'), 'd0000000-0000-0000-0000-00000000000a'::uuid,
  'l''organisation est reprise du modèle');
select throws_ok($$insert into public.model_deadlines (model_id, stage, due_date) values
  ('d4000000-0000-0000-0000-000000000001', 'idea', '2026-11-01')$$, '23514', null, 'Idée n''a pas d''échéance');

select set_config('request.jwt.claims', '{"sub":"00000000-0000-0000-0000-0000000000d3","role":"authenticated"}', true);
select throws_ok($$insert into public.model_deadlines (model_id, stage, due_date) values
  ('d4000000-0000-0000-0000-000000000001', 'in_production', '2026-12-01')$$, '42501', null, 'le Lecteur ne fixe pas d''échéance');
select is((select count(*)::int from public.model_deadlines), 4, 'le Lecteur consulte les échéances de son atelier');
reset role;

-- Hors Pro : refusé.
select throws_ok($$insert into public.model_deadlines (model_id, stage, due_date) values
  ('d4000000-0000-0000-0000-000000000003', 'prototype', '2026-11-01')$$, '42501', 'pro_required', 'hors Pro, pas d''échéance');

-- Le 11/11 : seule l'échéance « Validé » du 10/11 est dépassée (Prototype est atteint, Jupe abandonnée).
select is(public.notify_overdue_deadlines('2026-11-11'), 1, 'une seule échéance dépassée');
select results_eq($$select count(*)::int, min(data ->> 'stage'), min(data ->> 'name') from public.notifications where kind = 'deadline_overdue'$$,
  $$values (2, 'validated'::text, 'Veste Arno'::text)$$, 'chaque membre est prévenu, avec le modèle et l''étape');
select is(public.notify_overdue_deadlines('2026-11-12'), 0, 'une seule notification par échéance');

-- Nouvelle date : la notification est réarmée.
update public.model_deadlines set due_date = '2026-11-15' where stage = 'validated';
select is(public.notify_overdue_deadlines('2026-11-14'), 0, 'pas encore dépassée');
select is(public.notify_overdue_deadlines('2026-11-16'), 1, 'nouvelle date dépassée : nouvelle notification');

-- Suppression d'un modèle : ses échéances partent avec lui.
delete from public.models where id = 'd4000000-0000-0000-0000-000000000001';
select is((select count(*)::int from public.model_deadlines where model_id = 'd4000000-0000-0000-0000-000000000001'), 0,
  'les échéances suivent la suppression du modèle');

select * from finish();
rollback;
