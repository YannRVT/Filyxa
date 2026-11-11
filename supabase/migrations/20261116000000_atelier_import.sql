-- Filyxa — Phase 8 : import de la base atelier et rapprochement automatique.
--
-- Un Éditeur importe un fichier Excel ou CSV. Chaque ligne crée une matière, ou
-- met à jour celle qui existe déjà (même fournisseur et même code, ou à défaut
-- même nom et même coloris) : un import relancé ne duplique rien.
-- Chaque matière importée est ensuite rapprochée des catalogues publiés :
--   - correspondance sûre (code identique, fournisseur concordant, une seule
--     candidate) → liée directement ;
--   - correspondance possible → marquée « à confirmer » (link_review = pending),
--     traitée une par une dans l'app ;
--   - « Aucune de ces références » → link_review = dismissed, plus proposée.

alter table public.materials
  add column link_review text check (link_review in ('pending', 'dismissed'));

create index materials_link_review_idx on public.materials (org_id)
  where link_review = 'pending';

-- Recherche d'une matière existante par code normalisé.
create index materials_code_normalized_idx on public.materials
  (org_id, upper(regexp_replace(coalesce(supplier_code, ''), '[^A-Za-z0-9]', '', 'g')));

-- Une matière qui devient liée n'a plus de correspondance à confirmer.
create or replace function public.materials_clear_link_review()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  if new.supplier_reference_id is not null then
    new.link_review := null;
  end if;
  return new;
end;
$$;

create trigger materials_clear_link_review before insert or update of supplier_reference_id on public.materials
  for each row execute function public.materials_clear_link_review();

-- Fournisseur concordant : noms proches (sans casse), ou l'un contenu dans l'autre.
create or replace function public.supplier_names_agree(a text, b text)
returns boolean
language sql
immutable
set search_path = ''
as $$
  select coalesce(a, '') <> '' and coalesce(b, '') <> '' and (
    lower(a) = lower(b)
    or position(lower(a) in lower(b)) > 0
    or position(lower(b) in lower(a)) > 0
    or extensions.similarity(lower(a), lower(b)) >= 0.5
  );
$$;

-- Import d'un lot de lignes (5 000 au plus). Renvoie les compteurs et les
-- lignes refusées : { inserted, updated, linked, pending, errors: [{row, error}] }.
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
          atelier_stock_m, notes, price_per_m, tags, created_by
        ) values (
          p_org, v_name, v_supplier, v_code, v_color,
          nullif(upper(rec ->> 'color_hex'), ''),
          (rec ->> 'atelier_stock_m')::numeric,
          nullif(rec ->> 'notes', ''),
          (rec ->> 'price_per_m')::numeric,
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
          price_per_m     = coalesce((rec ->> 'price_per_m')::numeric, price_per_m),
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

revoke execute on function public.import_atelier_materials(uuid, jsonb) from public, anon;
grant execute on function public.import_atelier_materials(uuid, jsonb) to authenticated;
revoke execute on function public.supplier_names_agree(text, text) from public, anon;
grant execute on function public.supplier_names_agree(text, text) to authenticated;
