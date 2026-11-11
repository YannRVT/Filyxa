-- Filyxa — Phase 11 : notifications du Studio.
--
-- Quand une référence fournisseur change, chaque atelier qui l'utilise dans un
-- modèle (via une matière liée) est prévenu dans l'app :
--   - stock_low       : la référence passe de « disponible » à « stock faible » ;
--   - stock_out       : elle passe en rupture ou « sur commande » ;
--   - reference_updated : ses données techniques changent ;
--   - reference_retired : le fournisseur la retire.
-- Le passage en rupture est notifié dans la même transaction que la mise à jour
-- du fournisseur : bien en deçà des 2 h du critère de succès 8.
-- Rien n'est envoyé si la disponibilité est masquée par le fournisseur, ni en
-- double tant qu'une notification identique n'a pas été lue.

alter table public.notifications drop constraint notifications_kind_check;
alter table public.notifications add constraint notifications_kind_check check (kind in (
  'report_new', 'report_fixed', 'report_rejected',
  'stock_low', 'stock_out', 'reference_updated', 'reference_retired'
));

create index notifications_reference_unread_idx on public.notifications (reference_id, kind)
  where read_at is null;

create or replace function public.notify_reference_change()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_kind text;
  v_mode public.availability_mode;
  v_threshold numeric;
  old_status public.availability_status;
  new_status public.availability_status;
  rec record;
begin
  if old.retired_at is null and new.retired_at is not null then
    v_kind := 'reference_retired';
  elsif new.retired_at is null then
    select coalesce(new.availability_mode, s.availability_mode, 'tiers'),
           coalesce(new.low_stock_threshold_m, s.low_stock_threshold_m, 50)
      into v_mode, v_threshold
    from (select 1) x
    left join public.supplier_settings s on s.org_id = new.supplier_org_id;

    if v_mode <> 'hidden' then
      old_status := public.availability_status_of(old.stock_m, v_threshold, old.lead_time_weeks);
      new_status := public.availability_status_of(new.stock_m, v_threshold, new.lead_time_weeks);
      if new_status in ('out_of_stock', 'on_order') and old_status in ('available', 'low') then
        v_kind := 'stock_out';
      elsif new_status = 'low' and old_status = 'available' then
        v_kind := 'stock_low';
      end if;
    end if;

    if v_kind is null and (
      new.name, new.color_name, new.color_hex, new.composition, new.weight_gsm, new.width_cm,
      new.weave, new.care, new.certifications, new.uses
    ) is distinct from (
      old.name, old.color_name, old.color_hex, old.composition, old.weight_gsm, old.width_cm,
      old.weave, old.care, old.certifications, old.uses
    ) then
      v_kind := 'reference_updated';
    end if;
  end if;

  if v_kind is null then
    return new;
  end if;

  -- Ateliers concernés : matière liée à la référence et utilisée dans au moins un modèle.
  for rec in
    select m.org_id, m.id as material_id, m.name as material_name,
           jsonb_agg(distinct jsonb_build_object('id', md.id, 'name', md.name)) as models
    from public.materials m
    join public.model_materials mm on mm.material_id = m.id
    join public.colorways c on c.id = mm.colorway_id
    join public.models md on md.id = c.model_id
    where m.supplier_reference_id = new.id
    group by m.org_id, m.id, m.name
  loop
    insert into public.notifications (user_id, org_id, kind, material_id, reference_id, data)
    select mb.user_id, rec.org_id, v_kind, rec.material_id, new.id,
           jsonb_build_object('code', new.code, 'name', rec.material_name, 'models', rec.models,
                              'lead_time', new.lead_time_weeks)
    from public.memberships mb
    where mb.org_id = rec.org_id
      and not exists (
        select 1 from public.notifications n
        where n.user_id = mb.user_id and n.reference_id = new.id and n.material_id = rec.material_id
          and n.kind = v_kind and n.read_at is null
      );
  end loop;
  return new;
end;
$$;

create trigger supplier_references_notify after update on public.supplier_references
  for each row execute function public.notify_reference_change();
