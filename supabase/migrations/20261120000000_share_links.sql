-- Filyxa — Phase 13 : lien partagé public (lecture seule, sans compte).
--
-- Un Éditeur partage une fiche matière, un modèle ou une collection avec un
-- façonnier. Le lien est valable 30 jours par défaut, modifiable et révocable.
-- La page publique lit share_view(token), seule fonction ouverte aux visiteurs
-- sans compte : elle ne renvoie jamais les prix, les notes, les étiquettes ni le
-- stock atelier (ces champs ne sont pas sélectionnés).

create type public.share_scope as enum ('material', 'model', 'collection');

create table public.share_links (
  id          uuid primary key default gen_random_uuid(),
  org_id      uuid not null references public.organizations (id) on delete cascade,
  -- 64 caractères hexadécimaux aléatoires (deux UUID v4) : non devinable.
  token       text not null unique default replace(gen_random_uuid()::text || gen_random_uuid()::text, '-', ''),
  scope       public.share_scope not null,
  target_id   uuid not null,
  -- Langue de la page publique, choisie à la création.
  lang        text not null default 'fr' check (lang in ('fr', 'en', 'it', 'es', 'pt', 'ro')),
  expires_at  timestamptz not null default now() + interval '30 days',
  revoked_at  timestamptz,
  created_by  uuid references auth.users (id) on delete set null,
  created_at  timestamptz not null default now()
);

create index share_links_org_idx on public.share_links (org_id, created_at desc);
create index share_links_target_idx on public.share_links (scope, target_id);

-- La cible doit appartenir à l'organisation du lien.
create or replace function public.share_links_check_target()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  if not exists (
    select 1 from public.materials where new.scope = 'material' and id = new.target_id and org_id = new.org_id
    union all
    select 1 from public.models where new.scope = 'model' and id = new.target_id and org_id = new.org_id
    union all
    select 1 from public.collections where new.scope = 'collection' and id = new.target_id and org_id = new.org_id
  ) then
    raise exception 'share_target_not_found' using errcode = 'P0002';
  end if;
  return new;
end;
$$;

create trigger share_links_check_target before insert or update of scope, target_id, org_id on public.share_links
  for each row execute function public.share_links_check_target();

alter table public.share_links enable row level security;

create policy "share_links: lecture membres" on public.share_links
  for select to authenticated using (org_id in (select public.my_org_ids('viewer')));
create policy "share_links: écriture éditeurs" on public.share_links
  for all to authenticated
  using (org_id in (select public.my_org_ids('editor')))
  with check (org_id in (select public.my_org_ids('editor')));

revoke all on public.share_links from anon, authenticated;
grant select, insert, delete on public.share_links to authenticated;
-- Seules l'expiration et la révocation se modifient.
grant update (expires_at, revoked_at) on public.share_links to authenticated;
grant all on public.share_links to service_role;

-- Données publiques d'une matière : techniques uniquement.
create or replace function public.share_material_json(p_material uuid)
returns jsonb
language sql
stable
security definer
set search_path = ''
as $$
  select jsonb_build_object(
    'id', m.id,
    'name', m.name,
    'supplier_name', m.supplier_name,
    'supplier_code', m.supplier_code,
    'color_name', m.color_name,
    'color_hex', m.color_hex,
    'linked', m.supplier_reference_id is not null,
    'composition', coalesce(s.composition, '[]'::jsonb),
    'weight_gsm', s.weight_gsm,
    'width_cm', s.width_cm,
    'weave', s.weave,
    'care', to_jsonb(coalesce(s.care, '{}')),
    'certifications', to_jsonb(coalesce(s.certifications, '{}')),
    'uses', to_jsonb(coalesce(s.uses, '{}'))
  )
  from public.materials m
  left join public.textile_specs s on s.material_id = m.id
  where m.id = p_material;
$$;

create or replace function public.share_model_json(p_model uuid)
returns jsonb
language sql
stable
security definer
set search_path = ''
as $$
  select jsonb_build_object(
    'id', md.id,
    'name', md.name,
    'reference', md.reference,
    'product_type', md.product_type,
    'waste_pct', md.waste_pct,
    'colorways', coalesce((
      select jsonb_agg(jsonb_build_object(
        'id', c.id,
        'name', c.name,
        'position', c.position,
        'quantity', c.quantity,
        'lines', coalesce((
          select jsonb_agg(jsonb_build_object(
            'role', mm.role,
            'consumption', mm.consumption,
            'material', public.share_material_json(mm.material_id)
          ) order by mm.position, mm.id)
          from public.model_materials mm where mm.colorway_id = c.id
        ), '[]'::jsonb)
      ) order by c.position, c.id)
      from public.colorways c where c.model_id = md.id
    ), '[]'::jsonb)
  )
  from public.models md
  where md.id = p_model;
$$;

-- Page publique : statut du lien, puis contenu toujours à jour.
create or replace function public.share_view(p_token text)
returns jsonb
language plpgsql
stable
security definer
set search_path = ''
as $$
declare
  l public.share_links;
  v_content jsonb;
begin
  select * into l from public.share_links where token = p_token;
  if not found then
    return jsonb_build_object('status', 'not_found');
  end if;
  if l.revoked_at is not null then
    return jsonb_build_object('status', 'revoked', 'lang', l.lang);
  end if;
  if l.expires_at <= now() then
    return jsonb_build_object('status', 'expired', 'lang', l.lang, 'expires_at', l.expires_at);
  end if;

  v_content := case l.scope
    when 'material' then public.share_material_json(l.target_id)
    when 'model' then public.share_model_json(l.target_id)
    else (
      select jsonb_build_object(
        'id', col.id,
        'name', col.name,
        'models', coalesce((
          select jsonb_agg(public.share_model_json(md.id) order by md.created_at, md.id)
          from public.models md where md.collection_id = col.id
        ), '[]'::jsonb)
      )
      from public.collections col where col.id = l.target_id
    )
  end;
  if v_content is null then
    return jsonb_build_object('status', 'not_found');
  end if;

  return jsonb_build_object(
    'status', 'ok',
    'scope', l.scope,
    'lang', l.lang,
    'expires_at', l.expires_at,
    'organization', (select name from public.organizations where id = l.org_id),
    'content', v_content
  );
end;
$$;

revoke execute on function public.share_material_json(uuid) from public, anon, authenticated;
revoke execute on function public.share_model_json(uuid) from public, anon, authenticated;
revoke execute on function public.share_view(text) from public;
grant execute on function public.share_view(text) to anon, authenticated;
