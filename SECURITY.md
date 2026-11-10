# Security review notes

Written from the SQL in this repo. The live database was not inspected, so
each point needs to be confirmed with `supabase/checks/list_policies.sql`.

## How access is meant to work
- Public pages use the Supabase **anon key**, which is visible to anyone.
- The admin panel signs in with **Supabase Auth** (`signInWithPassword`), so
  its requests run as the `authenticated` role.
- Row Level Security decides what each role can do. The anon key is only as
  safe as these rules.

## Tables that already follow "public reads, admin writes"
- `events` (`schema/04`), `media_coverage` (`schema/05`)
- `contact_messages` (`schema/08`): public may insert a 'New' message only;
  admin reads, updates and deletes.

## Open items to check before launch

1. **`newspaper_clippings` may be writable by anyone.**
   `schema/03` grants insert, update and delete `to public`. With the anon key
   in every page, anyone could add, change or delete clippings.

2. **`gallery_images`, `committee_members`, and possibly `news_posts`,
   `projects`, `site_media` may be the same.** Comments in the older SQL
   describe gallery and committee as "fully open". Their policies were set in
   the dashboard and are not in this repo.

3. **`membership_applications` holds personal data.**
   `superseded/membership_policies_open_read_update.sql` once allowed anyone to
   read and update it. Later code comments say this was tightened to
   `authenticated`, but that SQL is not in this repo. Confirm no `SELECT` or
   `UPDATE` policy on this table is granted to `public` or `anon`.

4. **`certificate_requests` still allows public insert** (`schema/02`), although
   the form was removed from the site.

5. **Cloudinary unsigned upload preset.** The cloud name and preset are in
   `admin.html`, so anyone who reads the file can upload to the account.
   Consider restricting the preset (allowed formats, size, folder) or moving to
   signed uploads through an Edge Function.

6. **`admin.html` is protected only by the login and the RLS rules.** If it is
   hosted publicly, the page itself is visible to everyone; that is acceptable
   only when items 1-4 are closed.

## Proposed fix
`supabase/proposed/security_hardening.sql` closes items 1-4 by applying the
same pattern `events` already uses. It has **not** been run. Run the checks
query first, run the script, then test every admin tab and every public page.
