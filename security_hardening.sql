-- PROPOSED - NOT YET RUN ON THE LIVE DATABASE.
--
-- Purpose: make every table follow the same rule the events, media_coverage
-- and contact_messages tables already follow:
--   * the public (anon key) can only READ public content
--   * only a logged-in admin (Supabase Auth, role "authenticated") can write
--   * membership applications (personal data) are readable only by the admin
--
-- Why: some older migrations in this repo opened writes to "public"
-- (see migrations/schema/03_newspaper_clippings.sql and
-- migrations/superseded/). The anon key is embedded in every public page, so
-- "public can write" means anyone on the internet can add, edit or delete rows.
--
-- Before running: run checks/list_policies.sql and save the output.
-- After running:  log in to admin.html and add, edit and delete one item in
--                 each tab, and open each public page to confirm it still loads.
-- The admin panel signs in with Supabase Auth (signInWithPassword), so its
-- requests carry the "authenticated" role these policies need.

-- 1) Public content tables: public read, admin-only write.
do $$
declare
  t text;
  p record;
begin
  foreach t in array array[
    'news_posts', 'gallery_images', 'committee_members', 'projects',
    'site_media', 'newspaper_clippings', 'events', 'media_coverage'
  ]
  loop
    if to_regclass('public.' || t) is null then
      raise notice 'skipping %, table not found', t;
      continue;
    end if;

    execute format('alter table public.%I enable row level security', t);

    -- drop every write policy, whoever it was granted to
    for p in
      select policyname from pg_policies
      where schemaname = 'public' and tablename = t and cmd <> 'SELECT'
    loop
      execute format('drop policy %I on public.%I', p.policyname, t);
    end loop;

    -- keep an existing read policy; add one only if there is none
    if not exists (
      select 1 from pg_policies
      where schemaname = 'public' and tablename = t and cmd = 'SELECT'
    ) then
      execute format('create policy %I on public.%I for select to public using (true)',
                     'Public can read ' || t, t);
    end if;

    execute format('create policy %I on public.%I for insert to authenticated with check (true)',
                   'Admin can insert ' || t, t);
    execute format('create policy %I on public.%I for update to authenticated using (true) with check (true)',
                   'Admin can update ' || t, t);
    execute format('create policy %I on public.%I for delete to authenticated using (true)',
                   'Admin can delete ' || t, t);
  end loop;
end $$;

-- 2) Membership applications hold personal data: admin only, for everything.
do $$
declare p record;
begin
  if to_regclass('public.membership_applications') is null then return; end if;
  alter table public.membership_applications enable row level security;
  for p in
    select policyname from pg_policies
    where schemaname = 'public' and tablename = 'membership_applications'
  loop
    execute format('drop policy %I on public.membership_applications', p.policyname);
  end loop;
  create policy "Admin can read membership applications"   on public.membership_applications for select to authenticated using (true);
  create policy "Admin can insert membership applications" on public.membership_applications for insert to authenticated with check (true);
  create policy "Admin can update membership applications" on public.membership_applications for update to authenticated using (true) with check (true);
  create policy "Admin can delete membership applications" on public.membership_applications for delete to authenticated using (true);
end $$;

-- 3) Certificate requests: the public form was removed from the website,
--    so the public should no longer be able to insert. Existing rows are kept.
do $$
declare p record;
begin
  if to_regclass('public.certificate_requests') is null then return; end if;
  for p in
    select policyname from pg_policies
    where schemaname = 'public' and tablename = 'certificate_requests'
      and cmd = 'INSERT' and roles::text not like '%authenticated%'
  loop
    execute format('drop policy %I on public.certificate_requests', p.policyname);
  end loop;
end $$;

-- contact_messages is intentionally left as it is: the public may INSERT a
-- new message (status must be 'New'); only the admin can read, update, delete.
