-- Filyxa — Phase 7 : matière liée à une référence fournisseur.
--
-- Une matière peut être liée à une référence du catalogue publié. Ses données
-- techniques (fournisseur, code, coloris, composition, grammage, laize, armure,
-- entretien, certifications, usages) viennent alors du fournisseur :
--   - copiées au moment du lien, puis tenues à jour par un déclencheur à chaque
--     modification de la référence ;
--   - non modifiables par l'atelier ;
--   - conservées telles quelles si le fournisseur retire la référence.
-- L'atelier garde sa couche privée : nom, prix négocié, étiquettes, notes,
-- photo, stock atelier.

create extension if not exists pg_trgm with schema extensions;

alter table public.materials
  add column supplier_reference_id uuid references public.supplier_references (id) on delete set null,
  add column linked_at timestamptz,
  add column price_per_m numeric(10, 2) check (price_per_m is null or price_per_m >= 0),
  add column tags text[] not null default '{}';

create index materials_supplier_reference_idx on public.materials (supplier_reference_id)
  where supplier_reference_id is not null;

-- Garde : les caractéristiques d'une matière liée ne s'écrivent que par la
-- synchronisation avec le fournisseur (drapeau de session filyxa.sync).
create or replace function public.textile_specs_guard_linked()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  if coalesce(current_setting('filyxa.sync', true), '') <> 'on'
     and exists (select 1 from public.materials m
                 where m.id = new.material_id and m.supplier_reference_id is not null) then
    raise exception 'linked_material_readonly' using errcode = '42501';
  end if;
  return new;
end;
$$;

create trigger textile_specs_guard before insert or update on public.textile_specs
  for each row execute function public.textile_specs_guard_linked();

-- Copie les données d'une référence vers une matière liée (création, lien, mise à jour).
create or replace function public.copy_reference_to_material(p_material uuid, p_reference uuid)
returns void
language plpgsql
security definer
set search_path = ''
as $$
declare
  r public.supplier_references;
  supplier text;
begin
  select * into r from public.supplier_references where id = p_reference;
  if not found then return; end if;
  select name into supplier from public.organizations where id = r.supplier_org_id;

  perform set_config('filyxa.sync', 'on', true);
  update public.materials set
    supplier_name = supplier,
    supplier_code = r.code,
    color_name    = r.color_name,
    color_hex     = r.color_hex
  where id = p_material;

  insert into public.textile_specs (material_id, composition, weight_gsm, width_cm, weave, care, certifications, uses)
  values (p_material, r.composition, r.weight_gsm, r.width_cm, r.weave, r.care, r.certifications, r.uses)
  on conflict (material_id) do update set
    composition = excluded.composition, weight_gsm = excluded.weight_gsm, width_cm = excluded.width_cm,
    weave = excluded.weave, care = excluded.care, certifications = excluded.certifications, uses = excluded.uses;
  perform set_config('filyxa.sync', 'off', true);
end;
$$;

-- Interne : appelée uniquement par la synchronisation (déclencheur), jamais par un utilisateur.
revoke execute on function public.copy_reference_to_material(uuid, uuid) from public, anon, authenticated;
grant execute on function public.copy_reference_to_material(uuid, uuid) to service_role;

-- Toute modification du fournisseur est répercutée sur les matières liées.
-- Une référence retirée garde ses dernières valeurs chez les ateliers.
create or replace function public.sync_linked_materials()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
declare
  m uuid;
begin
  if new.retired_at is not null then return new; end if;
  for m in select id from public.materials where supplier_reference_id = new.id loop
    perform public.copy_reference_to_material(m, new.id);
  end loop;
  return new;
end;
$$;

create trigger supplier_references_sync after update on public.supplier_references
  for each row execute function public.sync_linked_materials();

-- Enregistrement d'une matière (création ou modification), avec lien optionnel.
-- payload.supplier_reference_id : référence à lier (doit être publiée et visible) ;
-- null pour une fiche propre à l'atelier. Pour une matière liée, les données
-- techniques du payload sont ignorées : elles viennent du fournisseur.
create or replace function public.save_textile_material(payload jsonb)
returns uuid
language plpgsql
security invoker
set search_path = ''
as $$
declare
  v_id uuid := nullif(payload ->> 'id', '')::uuid;
  v_ref uuid := nullif(payload ->> 'supplier_reference_id', '')::uuid;
  v_previous_ref uuid;
  specs jsonb := coalesce(payload -> 'specs', '{}'::jsonb);
begin
  -- La référence doit être publiée (visible dans le catalogue de l'utilisateur).
  if v_ref is not null and not exists (select 1 from public.supplier_catalog c where c.id = v_ref) then
    raise exception 'reference_not_available' using errcode = 'P0002';
  end if;

  if v_id is null then
    insert into public.materials (
      org_id, name, supplier_name, supplier_code, color_name, color_hex, photo_path,
      atelier_stock_m, notes, price_per_m, tags, supplier_reference_id, linked_at, created_by
    ) values (
      (payload ->> 'org_id')::uuid,
      btrim(payload ->> 'name'),
      nullif(btrim(payload ->> 'supplier_name'), ''),
      nullif(btrim(payload ->> 'supplier_code'), ''),
      nullif(btrim(payload ->> 'color_name'), ''),
      nullif(upper(payload ->> 'color_hex'), ''),
      nullif(payload ->> 'photo_path', ''),
      (payload ->> 'atelier_stock_m')::numeric,
      nullif(payload ->> 'notes', ''),
      (payload ->> 'price_per_m')::numeric,
      coalesce(array(select jsonb_array_elements_text(payload -> 'tags')), '{}'),
      v_ref,
      case when v_ref is not null then now() end,
      auth.uid()
    )
    returning id into v_id;
  else
    select supplier_reference_id into v_previous_ref from public.materials where id = v_id;
    update public.materials set
      name                  = btrim(payload ->> 'name'),
      photo_path            = nullif(payload ->> 'photo_path', ''),
      atelier_stock_m       = (payload ->> 'atelier_stock_m')::numeric,
      notes                 = nullif(payload ->> 'notes', ''),
      price_per_m           = (payload ->> 'price_per_m')::numeric,
      tags                  = coalesce(array(select jsonb_array_elements_text(payload -> 'tags')), '{}'),
      supplier_reference_id = v_ref,
      linked_at             = case when v_ref is null then null
                                   when v_ref is distinct from v_previous_ref then now()
                                   else linked_at end,
      -- Fiche propre à l'atelier : l'atelier saisit lui-même ces champs.
      supplier_name = case when v_ref is null then nullif(btrim(payload ->> 'supplier_name'), '') else supplier_name end,
      supplier_code = case when v_ref is null then nullif(btrim(payload ->> 'supplier_code'), '') else supplier_code end,
      color_name    = case when v_ref is null then nullif(btrim(payload ->> 'color_name'), '') else color_name end,
      color_hex     = case when v_ref is null then nullif(upper(payload ->> 'color_hex'), '') else color_hex end
    where id = v_id;
    if not found then
      raise exception 'material_not_found' using errcode = 'P0002';
    end if;
  end if;

  if v_ref is not null then
    -- Données techniques recopiées depuis le catalogue publié (droits de l'appelant).
    perform set_config('filyxa.sync', 'on', true);
    update public.materials m set
      supplier_name = c.supplier_name, supplier_code = c.code,
      color_name = c.color_name, color_hex = c.color_hex
    from public.supplier_catalog c
    where m.id = v_id and c.id = v_ref;
    insert into public.textile_specs (material_id, composition, weight_gsm, width_cm, weave, care, certifications, uses)
    select v_id, c.composition, c.weight_gsm, c.width_cm, c.weave, c.care, c.certifications, c.uses
    from public.supplier_catalog c where c.id = v_ref
    on conflict (material_id) do update set
      composition = excluded.composition, weight_gsm = excluded.weight_gsm, width_cm = excluded.width_cm,
      weave = excluded.weave, care = excluded.care, certifications = excluded.certifications, uses = excluded.uses;
    perform set_config('filyxa.sync', 'off', true);
  else
    insert into public.textile_specs (
      material_id, composition, weight_gsm, width_cm, weave, care, certifications, uses
    ) values (
      v_id,
      coalesce(specs -> 'composition', '[]'::jsonb),
      (specs ->> 'weight_gsm')::integer,
      (specs ->> 'width_cm')::integer,
      nullif(specs ->> 'weave', ''),
      coalesce(array(select jsonb_array_elements_text(specs -> 'care')), '{}'),
      coalesce(array(select jsonb_array_elements_text(specs -> 'certifications')), '{}'),
      coalesce(array(select jsonb_array_elements_text(specs -> 'uses')), '{}')
    )
    on conflict (material_id) do update set
      composition    = excluded.composition,
      weight_gsm     = excluded.weight_gsm,
      width_cm       = excluded.width_cm,
      weave          = excluded.weave,
      care           = excluded.care,
      certifications = excluded.certifications,
      uses           = excluded.uses;
  end if;

  return v_id;
end;
$$;

-- Rapprochement d'un échantillon scanné avec les catalogues publiés.
-- Code identique (sans espaces, tirets ni casse) = score 1 ; code tronqué ou
-- complété = 0,8 ; sinon ressemblance du code (70 %) et du nom de fournisseur (30 %).
-- Les 5 meilleures au-dessus de 0,35.
create or replace function public.match_supplier_references(p_code text, p_supplier text default null)
returns table (id uuid, score real)
language sql
stable
security invoker
set search_path = ''
as $$
  with input as (
    select upper(regexp_replace(coalesce(p_code, ''), '[^A-Za-z0-9]', '', 'g')) as code,
           lower(coalesce(p_supplier, '')) as supplier
  ),
  scored as (
    select c.id,
      case
        when i.code <> '' and c.code_normalized = i.code then 1.0::real
        else greatest(
          -- Code tronqué ou complété (au moins 4 caractères en commun au début).
          case when length(i.code) >= 4
                    and (starts_with(c.code_normalized, i.code) or starts_with(i.code, c.code_normalized))
               then 0.8 else 0 end,
          0.7 * extensions.similarity(c.code_normalized, i.code)
            + 0.3 * case when i.supplier = '' then 0
                         else extensions.similarity(lower(c.supplier_name), i.supplier) end
        )::real
      end as score
    from public.supplier_catalog c, input i
    where i.code <> ''
  )
  select id, score from scored where score >= 0.35 order by score desc, id limit 5;
$$;

revoke execute on function public.match_supplier_references(text, text) from public, anon;
grant execute on function public.match_supplier_references(text, text) to authenticated;
