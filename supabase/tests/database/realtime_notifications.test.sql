-- Tests des notifications en temps réel (phase 24).
begin;
create extension if not exists pgtap with schema extensions;
select plan(2);

select ok(exists (select 1 from pg_publication_tables where pubname = 'supabase_realtime' and tablename = 'notifications'),
  'les notifications sont diffusées en temps réel');
-- Le temps réel applique les règles d'accès : la règle de lecture ne laisse voir que ses propres notifications.
select ok(exists (select 1 from pg_policies where tablename = 'notifications' and cmd = 'SELECT' and qual like '%auth.uid()%'),
  'chacun ne reçoit que ses notifications');

select * from finish();
rollback;
