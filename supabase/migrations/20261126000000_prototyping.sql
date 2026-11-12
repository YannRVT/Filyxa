-- Filyxa — Phase 19 : prototypage.
--
-- Le prototypage consomme de la matière à part (tests de colle, tests matière,
-- sublimation avec marge sur les côtés). Pour chaque matière du premier coloris :
--   besoin de prototypage = nombre de prototypes × consommation de base
--                           × (1 + perte de prototypage de la ligne).
-- Il s'affiche à côté du besoin de production. Réservé à l'offre Pro.

alter table public.models
  add column prototype_count integer not null default 1 check (prototype_count between 0 and 1000);
alter table public.model_materials
  add column proto_loss_pct numeric(5, 2) not null default 25 check (proto_loss_pct between 0 and 500);

create or replace function public.prototyping_guard()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_changed boolean;
begin
  if tg_table_name = 'models' then
    v_changed := new.prototype_count is distinct from old.prototype_count;
  else
    v_changed := new.proto_loss_pct is distinct from old.proto_loss_pct;
  end if;
  if v_changed and not public.has_pro(new.org_id) then
    raise exception 'pro_required' using errcode = '42501';
  end if;
  return new;
end;
$$;

create trigger models_prototyping_guard before update of prototype_count on public.models
  for each row execute function public.prototyping_guard();
create trigger model_materials_prototyping_guard before update of proto_loss_pct on public.model_materials
  for each row execute function public.prototyping_guard();
