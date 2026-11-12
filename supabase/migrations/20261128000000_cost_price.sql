-- Filyxa — Phase 21 : coût de revient (et confidentialité des prix).
--
-- Le prix des matières et tous les coûts sont réservés aux Admins et aux Éditeurs :
-- le prix quitte la table des matières (lisible par les Lecteurs) pour une table à
-- part, protégée par ses propres règles d'accès. C'est un changement par rapport à
-- la V1, où le Lecteur voyait le prix.
--
-- Coût de revient d'un modèle (calculé dans l'app) : matières (prix × besoin, pertes
-- incluses) + lignes de coût (fournitures, façon, frais ; par pièce ou forfait pour
-- le modèle). Les lignes de coût sont réservées à l'offre Pro.

create table public.material_prices (
  material_id  uuid primary key references public.materials (id) on delete cascade,
  org_id       uuid not null references public.organizations (id) on delete cascade,
  price_per_m  numeric(10, 2) not null check (price_per_m >= 0),
  updated_at   timestamptz not null default now()
);

create or replace function public.material_prices_inherit_org()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  select org_id into new.org_id from public.materials where id = new.material_id;
  if new.org_id is null then
    raise exception 'parent_not_found' using errcode = 'P0002';
  end if;
  new.updated_at := now();
  return new;
end;
$$;

create trigger material_prices_inherit_org before insert or update on public.material_prices
  for each row execute function public.material_prices_inherit_org();

alter table public.material_prices enable row level security;
create policy "material_prices: éditeurs" on public.material_prices
  for all to authenticated
  using (org_id in (select public.my_org_ids('editor')))
  with check (org_id in (select public.my_org_ids('editor')));
revoke all on public.material_prices from anon, authenticated;
grant select, insert, update, delete on public.material_prices to authenticated;
grant all on public.material_prices to service_role;

insert into public.material_prices (material_id, org_id, price_per_m)
select id, org_id, price_per_m from public.materials where price_per_m is not null;

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
      atelier_stock_m, notes, tags, supplier_reference_id, linked_at, created_by
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

  -- Prix : couche privée lisible par les Admins et les Éditeurs seulement.
  if payload ? 'price_per_m' then
    if nullif(payload ->> 'price_per_m', '') is null then
      delete from public.material_prices where material_id = v_id;
    else
      insert into public.material_prices (material_id, price_per_m) values (v_id, (payload ->> 'price_per_m')::numeric)
      on conflict (material_id) do update set price_per_m = excluded.price_per_m;
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


create or replace function public.import_atelier_materials(p_org uuid, p_rows jsonb)
returns jsonb
language plpgsql
security invoker
set search_path = ''
as $$
declare
  rec jsonb;
  idx integer := 0;
  inserted integer := 0;
  updated integer := 0;
  linked integer := 0;
  pending integer := 0;
  errors jsonb := '[]'::jsonb;
  v_id uuid;
  v_linked boolean;
  v_review text;
  v_name text;
  v_supplier text;
  v_code text;
  v_code_norm text;
  v_color text;
  v_specs jsonb;
  v_tags text[];
  best record;
  cand record;
  exact_count integer;
  candidates integer;
  -- Issue de la ligne, comptée seulement si elle passe en entier.
  v_new boolean;
  v_outcome text;
begin
  if not public.has_role(p_org, 'editor') then
    raise exception 'forbidden' using errcode = '42501';
  end if;
  if jsonb_typeof(p_rows) <> 'array' or jsonb_array_length(p_rows) > 5000 then
    raise exception 'too_many_rows' using errcode = '22023';
  end if;

  for rec in select * from jsonb_array_elements(p_rows) loop
    idx := idx + 1;
    begin
      v_name      := btrim(rec ->> 'name');
      v_supplier  := nullif(btrim(rec ->> 'supplier_name'), '');
      v_code      := nullif(btrim(rec ->> 'supplier_code'), '');
      v_code_norm := upper(regexp_replace(coalesce(v_code, ''), '[^A-Za-z0-9]', '', 'g'));
      v_color     := nullif(btrim(rec ->> 'color_name'), '');
      v_specs     := coalesce(rec -> 'specs', '{}'::jsonb);
      v_tags      := coalesce(array(select jsonb_array_elements_text(rec -> 'tags')), '{}');

      -- Matière déjà présente : même code (et fournisseur compatible), sinon même nom et coloris sans code.
      v_id := null;
      v_outcome := null;
      select m.id, m.supplier_reference_id is not null, m.link_review
        into v_id, v_linked, v_review
      from public.materials m
      where m.org_id = p_org
        and (
          (v_code_norm <> ''
           and upper(regexp_replace(coalesce(m.supplier_code, ''), '[^A-Za-z0-9]', '', 'g')) = v_code_norm
           and (v_supplier is null or m.supplier_name is null or public.supplier_names_agree(m.supplier_name, v_supplier)))
          or
          (v_code_norm = '' and m.supplier_code is null
           and lower(m.name) = lower(v_name)
           and lower(coalesce(m.color_name, '')) = lower(coalesce(v_color, '')))
        )
      order by m.created_at, m.id
      limit 1;

      if v_id is null then
        insert into public.materials (
          org_id, name, supplier_name, supplier_code, color_name, color_hex,
          atelier_stock_m, notes, tags, created_by
        ) values (
          p_org, v_name, v_supplier, v_code, v_color,
          nullif(upper(rec ->> 'color_hex'), ''),
          (rec ->> 'atelier_stock_m')::numeric,
          nullif(rec ->> 'notes', ''),
          v_tags,
          auth.uid()
        )
        returning id into v_id;
        v_linked := false;
        v_review := null;
        v_new := true;
      else
        -- Couche privée : les valeurs du fichier remplacent, les cellules vides gardent l'existant.
        update public.materials set
          name            = v_name,
          atelier_stock_m = coalesce((rec ->> 'atelier_stock_m')::numeric, atelier_stock_m),
          notes           = coalesce(nullif(rec ->> 'notes', ''), notes),
          tags            = case when cardinality(v_tags) > 0 then v_tags else tags end,
          -- Données techniques : seulement pour une fiche propre à l'atelier.
          supplier_name   = case when v_linked then supplier_name else coalesce(v_supplier, supplier_name) end,
          supplier_code   = case when v_linked then supplier_code else coalesce(v_code, supplier_code) end,
          color_name      = case when v_linked then color_name else coalesce(v_color, color_name) end,
          color_hex       = case when v_linked then color_hex else coalesce(nullif(upper(rec ->> 'color_hex'), ''), color_hex) end,
          updated_at      = now()
        where id = v_id;
        v_new := false;
      end if;

      -- Prix : couche privée à part ; une cellule vide garde l'existant.
      if nullif(rec ->> 'price_per_m', '') is not null then
        insert into public.material_prices (material_id, price_per_m) values (v_id, (rec ->> 'price_per_m')::numeric)
        on conflict (material_id) do update set price_per_m = excluded.price_per_m;
      end if;

      if not v_linked then
        insert into public.textile_specs (material_id, composition, weight_gsm, width_cm, weave, care, certifications, uses)
        values (
          v_id,
          coalesce(v_specs -> 'composition', '[]'::jsonb),
          (v_specs ->> 'weight_gsm')::integer,
          (v_specs ->> 'width_cm')::integer,
          nullif(v_specs ->> 'weave', ''),
          '{}',
          coalesce(array(select jsonb_array_elements_text(v_specs -> 'certifications')), '{}'),
          coalesce(array(select jsonb_array_elements_text(v_specs -> 'uses')), '{}')
        )
        on conflict (material_id) do update set
          composition    = case when jsonb_array_length(excluded.composition) > 0
                                then excluded.composition else public.textile_specs.composition end,
          weight_gsm     = coalesce(excluded.weight_gsm, public.textile_specs.weight_gsm),
          width_cm       = coalesce(excluded.width_cm, public.textile_specs.width_cm),
          weave          = coalesce(excluded.weave, public.textile_specs.weave),
          certifications = case when cardinality(excluded.certifications) > 0
                                then excluded.certifications else public.textile_specs.certifications end,
          uses           = case when cardinality(excluded.uses) > 0
                                then excluded.uses else public.textile_specs.uses end;

        -- Rapprochement, sauf si l'atelier a déjà répondu « Aucune de ces références ».
        if v_code_norm <> '' and v_review is distinct from 'dismissed' then
          -- Un seul passage sur les catalogues : compte des candidates et meilleure proposition.
          exact_count := 0;
          candidates := 0;
          for cand in
            select m.id, m.score, c.supplier_name
            from public.match_supplier_references(v_code, v_supplier) m
            join public.supplier_catalog c on c.id = m.id
            order by m.score desc, m.id
          loop
            candidates := candidates + 1;
            if cand.score >= 1 then exact_count := exact_count + 1; end if;
            if candidates = 1 then best := cand; end if;
          end loop;

          if candidates = 0 then
            update public.materials set link_review = null where id = v_id and link_review = 'pending';
          elsif exact_count = 1 and best.score >= 1 and public.supplier_names_agree(best.supplier_name, v_supplier) then
            -- Correspondance sûre : lien et copie des données publiées.
            update public.materials set supplier_reference_id = best.id, linked_at = now()
            where id = v_id;
            perform set_config('filyxa.sync', 'on', true);
            update public.materials m set
              supplier_name = c.supplier_name, supplier_code = c.code,
              color_name = c.color_name, color_hex = c.color_hex
            from public.supplier_catalog c
            where m.id = v_id and c.id = best.id;
            update public.textile_specs s set
              composition = c.composition, weight_gsm = c.weight_gsm, width_cm = c.width_cm,
              weave = c.weave, care = c.care, certifications = c.certifications, uses = c.uses
            from public.supplier_catalog c
            where s.material_id = v_id and c.id = best.id;
            perform set_config('filyxa.sync', 'off', true);
            v_outcome := 'linked';
          else
            update public.materials set link_review = 'pending' where id = v_id;
            v_outcome := 'pending';
          end if;
        end if;
      end if;
    if v_new then inserted := inserted + 1; else updated := updated + 1; end if;
      if v_outcome = 'linked' then linked := linked + 1;
      elsif v_outcome = 'pending' then pending := pending + 1; end if;
    exception when others then
      errors := errors || jsonb_build_object('row', idx, 'error', sqlerrm);
    end;
  end loop;

  return jsonb_build_object(
    'inserted', inserted, 'updated', updated, 'linked', linked, 'pending', pending, 'errors', errors
  );
end;
$$;


alter table public.materials drop column price_per_m;

-- Lignes de coût d'un modèle : fournitures, façon, frais annexes.
create type public.cost_kind as enum ('supply', 'labor', 'overhead');

create table public.model_costs (
  id          uuid primary key default gen_random_uuid(),
  model_id    uuid not null references public.models (id) on delete cascade,
  org_id      uuid not null references public.organizations (id) on delete cascade,
  kind        public.cost_kind not null,
  label       text not null check (char_length(btrim(label)) between 1 and 80),
  unit_price  numeric(12, 2) not null default 0 check (unit_price >= 0),
  -- Quantité par pièce (ou 1 pour un forfait).
  quantity    numeric(10, 3) not null default 1 check (quantity >= 0),
  -- piece : par pièce ; model : forfait pour tout le modèle, réparti sur les pièces.
  per         text not null default 'piece' check (per in ('piece', 'model')),
  position    integer not null default 0,
  created_at  timestamptz not null default now()
);
create index model_costs_model_idx on public.model_costs (model_id, position);

create or replace function public.model_costs_guard()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_org uuid;
begin
  if tg_op = 'DELETE' then
    if not exists (select 1 from public.models where id = old.model_id) then
      return old;
    end if;
    v_org := old.org_id;
  else
    select org_id into v_org from public.models where id = new.model_id;
    if v_org is null then
      raise exception 'parent_not_found' using errcode = 'P0002';
    end if;
    new.org_id := v_org;
  end if;
  if not public.has_pro(v_org) then
    raise exception 'pro_required' using errcode = '42501';
  end if;
  return case when tg_op = 'DELETE' then old else new end;
end;
$$;

create trigger model_costs_guard before insert or update or delete on public.model_costs
  for each row execute function public.model_costs_guard();

alter table public.model_costs enable row level security;
create policy "model_costs: éditeurs" on public.model_costs
  for all to authenticated
  using (org_id in (select public.my_org_ids('editor')))
  with check (org_id in (select public.my_org_ids('editor')));
revoke all on public.model_costs from anon, authenticated;
grant select, insert, update, delete on public.model_costs to authenticated;
grant all on public.model_costs to service_role;
