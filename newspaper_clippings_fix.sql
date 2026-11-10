-- Run this in Supabase SQL Editor to fix the "row violates row-level
-- security policy" error when publishing a clipping from the admin panel.
--
-- What went wrong: the admin panel now requires login, so when you save a
-- record it acts as a logged-in admin ("authenticated"), not as an
-- anonymous visitor ("anon"). The clippings table's write rules only ever
-- allowed "anon" to add/edit/delete rows -- there's no public form that
-- submits a clipping (unlike membership or certificate requests, which
-- visitors submit themselves), so that was simply the wrong rule from the
-- start. This replaces it with the correct one: only a logged-in admin can
-- add, edit, or delete clippings. Reading them (for the public News page)
-- stays open to everyone, logged in or not.

drop policy if exists "Public can insert newspaper clippings" on newspaper_clippings;
drop policy if exists "Public can update newspaper clippings" on newspaper_clippings;
drop policy if exists "Public can delete newspaper clippings" on newspaper_clippings;

create policy "Authenticated users can insert newspaper clippings"
on newspaper_clippings for insert
to authenticated
with check (true);

create policy "Authenticated users can update newspaper clippings"
on newspaper_clippings for update
to authenticated
using (true);

create policy "Authenticated users can delete newspaper clippings"
on newspaper_clippings for delete
to authenticated
using (true);

-- No change needed for reading -- "Public can read newspaper clippings"
-- (to anon) already lets the News page show clippings without logging in.
