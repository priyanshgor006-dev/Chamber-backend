-- Run once in Supabase -> SQL Editor (paste everything, click Run).
-- 1) Creates the "media_coverage" table for the new Media page
--    (YouTube videos and news articles about the Chamber).
-- 2) Everyone can read it; only the logged-in admin can add, edit or delete.

create table if not exists media_coverage (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  media_type text not null default 'YouTube video',
  url text not null,
  source_name text,
  published_date date,
  thumbnail_url text,
  description text,
  created_at timestamptz not null default now()
);

alter table media_coverage enable row level security;

drop policy if exists "Public can read media coverage" on media_coverage;
drop policy if exists "Admin can insert media coverage" on media_coverage;
drop policy if exists "Admin can update media coverage" on media_coverage;
drop policy if exists "Admin can delete media coverage" on media_coverage;

create policy "Public can read media coverage" on media_coverage for select to public using (true);
create policy "Admin can insert media coverage" on media_coverage for insert to authenticated with check (true);
create policy "Admin can update media coverage" on media_coverage for update to authenticated using (true);
create policy "Admin can delete media coverage" on media_coverage for delete to authenticated using (true);
