-- Run once in Supabase -> SQL Editor.
-- Your existing "events" table is kept as it is (no data touched).
-- 1) adds one optional column for a "more details / registration" link
-- 2) makes events readable by everyone, but only the logged-in admin can
--    add, edit or delete them.

alter table events add column if not exists link_url text;

alter table events enable row level security;

do $$
declare p record;
begin
  for p in
    select policyname from pg_policies
    where schemaname = 'public' and tablename = 'events' and cmd <> 'SELECT'
  loop
    execute format('drop policy %I on events', p.policyname);
  end loop;

  if not exists (
    select 1 from pg_policies
    where schemaname = 'public' and tablename = 'events' and cmd = 'SELECT'
  ) then
    create policy "Public can read events" on events for select to public using (true);
  end if;
end $$;

create policy "Admin can insert events" on events for insert to authenticated with check (true);
create policy "Admin can update events" on events for update to authenticated using (true);
create policy "Admin can delete events" on events for delete to authenticated using (true);
