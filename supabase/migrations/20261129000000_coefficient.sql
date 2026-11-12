-- Filyxa — Phase 22 : prix de vente visé et coefficient.
--
-- Coefficient = prix de vente visé ÷ coût par pièce (calculé dans l'app). Sous le
-- coefficient minimal de l'atelier (2,5 par défaut, réglé par l'Admin), le modèle
-- est signalé. Réservé à l'offre Pro ; le prix de vente n'est lu que par les Admins
-- et les Éditeurs, comme les coûts.

alter table public.organizations
  add column min_coefficient numeric(5, 2) not null default 2.5 check (min_coefficient between 1 and 20);

-- Prix de vente visé : couche privée à part (même règle que les prix des matières).
create table public.model_prices (
  model_id      uuid primary key references public.models (id) on delete cascade,
  org_id        uuid not null references public.organizations (id) on delete cascade,
  target_price  numeric(12, 2) not null check (target_price >= 0)
);

create or replace function public.model_prices_guard()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  select org_id into new.org_id from public.models where id = new.model_id;
  if new.org_id is null then
    raise exception 'parent_not_found' using errcode = 'P0002';
  end if;
  if not public.has_pro(new.org_id) then
    raise exception 'pro_required' using errcode = '42501';
  end if;
  return new;
end;
$$;

create trigger model_prices_guard before insert or update on public.model_prices
  for each row execute function public.model_prices_guard();

alter table public.model_prices enable row level security;
create policy "model_prices: éditeurs" on public.model_prices
  for all to authenticated
  using (org_id in (select public.my_org_ids('editor')))
  with check (org_id in (select public.my_org_ids('editor')));
revoke all on public.model_prices from anon, authenticated;
grant select, insert, update, delete on public.model_prices to authenticated;
grant all on public.model_prices to service_role;

-- Coefficient minimal : l'Admin de l'atelier, en offre Pro.
create or replace function public.set_min_coefficient(p_org uuid, p_value numeric)
returns void
language plpgsql
security definer
set search_path = ''
as $$
begin
  if p_org not in (select public.my_org_ids('admin')) then
    raise exception 'forbidden' using errcode = '42501';
  end if;
  if not public.has_pro(p_org) then
    raise exception 'pro_required' using errcode = '42501';
  end if;
  update public.organizations set min_coefficient = p_value where id = p_org;
end;
$$;
revoke execute on function public.set_min_coefficient(uuid, numeric) from public, anon;
grant execute on function public.set_min_coefficient(uuid, numeric) to authenticated;
