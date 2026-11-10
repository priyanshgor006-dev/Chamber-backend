-- Run this in Supabase SQL Editor (for a fresh install -- if the table
-- already exists, use newspaper_clippings_fix2.sql instead).
--
-- Clippings are only ever added through the admin panel (there's no public
-- submission form, unlike membership or certificate requests). Follows the
-- same fully-open pattern as gallery_images / committee_members: not
-- sensitive data, so no login-only restriction on writes.

create table if not exists newspaper_clippings (
  id bigint generated always as identity primary key,
  created_at timestamptz not null default now(),
  publication_name text not null,
  clipping_date date,
  caption text,
  image_url text not null
);

alter table newspaper_clippings enable row level security;

create policy "Public can read newspaper clippings"
on newspaper_clippings for select
to public
using (true);

create policy "Admin panel can insert newspaper clippings"
on newspaper_clippings for insert
to public
with check (true);

create policy "Admin panel can update newspaper clippings"
on newspaper_clippings for update
to public
using (true);

create policy "Admin panel can delete newspaper clippings"
on newspaper_clippings for delete
to public
using (true);
