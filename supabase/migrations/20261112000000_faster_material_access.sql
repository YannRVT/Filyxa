-- Filyxa — Phase 4 : lecture des matières plus rapide.
--
-- Les règles de lecture appelaient has_role() pour chaque ligne. Avec des milliers
-- de matières, le chargement dépassait 2 s. On calcule une seule fois la liste des
-- organisations de l'utilisateur (sous-requête évaluée une fois par requête).

create or replace function public.my_org_ids(min_role public.member_role)
returns setof uuid
language sql
stable
security definer
set search_path = ''
as $$
  select m.org_id
  from public.memberships m
  where m.user_id = (select auth.uid())
    and public.role_rank(m.role) >= public.role_rank(min_role);
$$;

revoke execute on function public.my_org_ids(public.member_role) from public, anon;
grant execute on function public.my_org_ids(public.member_role) to authenticated, service_role;

drop policy "materials: lecture membres" on public.materials;
create policy "materials: lecture membres" on public.materials
  for select to authenticated
  using (org_id in (select public.my_org_ids('viewer')));

drop policy "textile_specs: lecture membres" on public.textile_specs;
create policy "textile_specs: lecture membres" on public.textile_specs
  for select to authenticated
  using (material_id in (
    select m.id from public.materials m
    where m.org_id in (select public.my_org_ids('viewer'))
  ));
