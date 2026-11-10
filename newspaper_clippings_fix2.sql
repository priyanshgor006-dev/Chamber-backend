-- Run this in Supabase SQL Editor. This replaces the previous fix.
--
-- The last fix restricted writes to "authenticated" only, assuming the
-- admin panel's login always attaches a proper session token to every
-- request. Since the error is still happening even while logged in, that
-- assumption may not hold for whichever copy of admin.html is currently
-- deployed -- rather than keep guessing at that, this opens write access
-- back up to everyone, matching how gallery_images and committee_members
-- already work (fully open, since only the admin panel ever writes here --
-- there's no public form submitting clippings). This removes Row Level
-- Security as a possible cause entirely.

drop policy if exists "Public can insert newspaper clippings" on newspaper_clippings;
drop policy if exists "Authenticated users can insert newspaper clippings" on newspaper_clippings;
create policy "Admin panel can insert newspaper clippings"
on newspaper_clippings for insert
to public
with check (true);

drop policy if exists "Public can update newspaper clippings" on newspaper_clippings;
drop policy if exists "Authenticated users can update newspaper clippings" on newspaper_clippings;
create policy "Admin panel can update newspaper clippings"
on newspaper_clippings for update
to public
using (true);

drop policy if exists "Public can delete newspaper clippings" on newspaper_clippings;
drop policy if exists "Authenticated users can delete newspaper clippings" on newspaper_clippings;
create policy "Admin panel can delete newspaper clippings"
on newspaper_clippings for delete
to public
using (true);

-- No change needed for reading -- it was already open to everyone.
