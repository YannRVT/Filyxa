-- Filyxa — Phase 25 : import atelier mémorisé.
--
-- L'association des colonnes du dernier import atelier est enregistrée pour
-- l'atelier (partagée par tous ses Éditeurs) et proposée d'office au prochain
-- import, comme pour l'import fournisseur.

create table public.atelier_settings (
  org_id          uuid primary key references public.organizations (id) on delete cascade,
  -- Champ d'import → intitulé de colonne du dernier fichier.
  import_mapping  jsonb not null default '{}'::jsonb check (jsonb_typeof(import_mapping) = 'object'),
  updated_at      timestamptz not null default now()
);

create trigger atelier_settings_touch before update on public.atelier_settings
  for each row execute function public.touch_updated_at();

alter table public.atelier_settings enable row level security;
create policy "atelier_settings: lecture membres" on public.atelier_settings
  for select to authenticated using (org_id in (select public.my_org_ids('viewer')));
create policy "atelier_settings: écriture éditeurs" on public.atelier_settings
  for all to authenticated
  using (org_id in (select public.my_org_ids('editor')))
  with check (org_id in (select public.my_org_ids('editor')));
revoke all on public.atelier_settings from anon, authenticated;
grant select, insert, update on public.atelier_settings to authenticated;
grant all on public.atelier_settings to service_role;
