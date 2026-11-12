-- Filyxa — Phase 24 : notifications en temps réel.
--
-- La cloche s'abonne aux nouvelles notifications de l'utilisateur au lieu de se
-- relire toutes les 5 minutes. Les règles d'accès s'appliquent aussi au temps
-- réel : chacun ne reçoit que ses propres notifications.

do $$
begin
  if not exists (select 1 from pg_publication where pubname = 'supabase_realtime') then
    create publication supabase_realtime;
  end if;
end;
$$;

alter publication supabase_realtime add table public.notifications;
