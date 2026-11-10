# BCCIF website backend

Backend for the website of the **Bhuj Chamber of Commerce and Industries Federation (BCCIF)**.

There is no custom server. The site is static HTML pages that talk straight to
**Supabase** (Postgres + REST + Auth) from the browser. This repo holds
everything that is not a public page:

| Folder | What it is |
|---|---|
| `supabase/migrations/schema/` | SQL that creates or changes tables and access rules, in the order it was run |
| `supabase/migrations/data/` | SQL that loads or fixes data (past events) |
| `supabase/migrations/superseded/` | Older SQL kept for history. Do not run on a fresh install |
| `supabase/functions/notify-membership/` | One Supabase Edge Function (Deno) that emails the Chamber |
| `supabase/checks/` | Read-only query that lists the live access rules |
| `supabase/proposed/` | Security hardening SQL that has **not** been run yet |
| `admin/admin.html` | The admin panel (single file, no build step) |
| `docs/` | Table reference and security review |

The public pages (home, about, news, events and so on) are not in this repo.

## Architecture

```
Visitor's browser ── static HTML/CSS/JS (GitHub Pages or Netlify)
        │
        ├── Supabase REST (anon key)      read public content, send a contact message
        ├── Cloudinary                    photo delivery and resizing
        └── Google Fonts, Wikimedia Commons, YouTube, Google Maps

Admin's browser ── admin/admin.html
        ├── Supabase Auth (email + password)  → role "authenticated"
        ├── Supabase REST                     create, edit, delete content
        └── Cloudinary unsigned upload        photos and PDF clippings

Supabase Database Webhook (membership_applications INSERT)
        └── Edge Function notify-membership → Resend → email to the Chamber
```

- **Database rules:** access is controlled by Postgres Row Level Security (RLS).
  The intended model is "public reads, logged-in admin writes".
- **Keys:** the Supabase anon key is in the pages and in `admin.html`. That is
  normal for Supabase; it is safe only as long as the RLS rules are right.
  There is no service-role key or other secret anywhere in this repo.
- **Libraries:** `supabase-js` v2 from jsDelivr is the only library. The home
  page calls the REST API with `fetch` and does not load it.

## Tables

See [`docs/SCHEMA.md`](docs/SCHEMA.md). In short:

| Table | Used for |
|---|---|
| `news_posts` | News articles (English, optional Gujarati) |
| `newspaper_clippings` | Press clippings (image or PDF) |
| `media_coverage` | YouTube videos and coverage |
| `events` | Seminars, with a photo album per event |
| `gallery_images` | Photo gallery |
| `committee_members` | Committee page and home page strip |
| `projects` | Community projects |
| `site_media` | Logo and home page carousel photos |
| `contact_messages` | Messages from the Contact page |
| `membership_applications` | Members and applications (admin only) |
| `certificate_requests`, `directory_members` | Features removed from the site; tables are legacy |

## Important limits of this repo

1. **The base tables are not created here.** `news_posts`, `gallery_images`,
   `committee_members`, `projects`, `site_media`, `events` and
   `membership_applications` were created earlier in the Supabase dashboard.
   Their `create table` SQL is not in this repo, so the migrations alone will
   not rebuild the database. To capture the real schema, run
   `supabase db dump --schema public` and commit the result.
2. **The migrations are history, not proof of the current state.** Some were
   later replaced by others. Run `supabase/checks/list_policies.sql` to see the
   rules that are live now.
3. **Security needs a review before launch.** See
   [`docs/SECURITY.md`](docs/SECURITY.md).

## Setting up the Edge Function

```
supabase functions deploy notify-membership
supabase secrets set RESEND_API_KEY=...  CHAMBER_NOTIFY_EMAIL=...  WEBHOOK_SHARED_SECRET=...
```

Then add a Database Webhook in the Supabase dashboard on
`membership_applications` INSERT that calls the function with the header
`x-webhook-secret: <WEBHOOK_SHARED_SECRET>`. Secret names are in `.env.example`.

The public online membership form has since been removed from the site, so this
function now fires only when an admin adds a member from the admin panel.

## Running the admin panel

Open `admin/admin.html` in a browser, or host it. Sign in with a user created
under Supabase → Authentication. Photo uploads go to Cloudinary through an
unsigned upload preset set near the top of the upload code.
