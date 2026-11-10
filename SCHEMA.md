# Table reference

Columns below are the ones the code reads and writes. Types are given where a
migration in this repo defines them. Where the table was created in the
Supabase dashboard, the type column says "dashboard" and the real type should
be confirmed with `supabase db dump --schema public`.

## news_posts (dashboard)
`id`, `title`, `category`, `author`, `published_at`, `image_url`, `body`,
`title_gu` text, `body_gu` text, `sort_order` integer, `created_at`

## newspaper_clippings
| Column | Type |
|---|---|
| `id` | bigint identity, primary key |
| `created_at` | timestamptz, default now() |
| `publication_name` | text, optional |
| `clipping_date` | date |
| `caption` | text |
| `image_url` | text, required (image or PDF) |
| `sort_order` | integer |

## media_coverage
| Column | Type |
|---|---|
| `id` | uuid, primary key |
| `title` | text, required |
| `media_type` | text, default 'YouTube video' |
| `url` | text, required |
| `source_name` | text |
| `published_date` | date |
| `thumbnail_url` | text |
| `description` | text |
| `sort_order` | integer |
| `created_at` | timestamptz |

## events (dashboard)
`id`, `title`, `event_date` timestamptz (stored as midnight IST; no time is
shown), `location`, `image_url`, `link_url` text, `description`,
`photos` jsonb array of URLs (max 20), `hidden`

## gallery_images (dashboard)
`id`, `image_url`, `caption`, `event_name`, `sort_order` integer, `created_at`

## committee_members (dashboard)
`id`, `name`, `designation`, `business_name`, `phone`, `email`, `photo_url`,
`sort_order` integer

## projects (dashboard)
`id`, `title`, `status` ('In Progress' | 'Upcoming' | 'Completed'),
`start_date`, `target_date`, `image_url`, `description`, `sort_order` integer,
`created_at`

## site_media (dashboard)
`id`, `type` ('logo' | 'hero'), `sort_order`, `caption`, `title`, `image_url`,
`active` boolean

## contact_messages
| Column | Type |
|---|---|
| `id` | uuid, primary key |
| `created_at` | timestamptz |
| `name` | text, 1-120 chars |
| `email` | text, 3-200 chars |
| `phone` | text, up to 20 chars |
| `subject` | text, up to 100 chars |
| `message` | text, 1-2000 chars |
| `status` | 'New' or 'Replied' |

## membership_applications (dashboard)
Personal data. Columns used by the admin panel include `id`, `created_at`,
`organization_name`, `nature_of_business`, `business_activity_details`,
`membership_category`, `mobile`, `email`, `status`
('Pending' | 'Approved' | 'Rejected'), `membership_no`, `receipt_no`,
`office_notes`, `joined_on` date, `due_date` date, `last_renewed_on` date,
`left_on` date, and document links `doc_certificate_url`, `doc_pan_url`,
`doc_registration_url`, `doc_gst_url`, `doc_address_proof_url`,
`doc_partnership_deed_url`, `doc_photo_url`, `doc_payment_receipt_url`.

## Legacy tables
- `certificate_requests`: the certificate feature was removed from the site.
- `directory_members`: the member directory was removed from the site.

The admin panel still contains code for both.
