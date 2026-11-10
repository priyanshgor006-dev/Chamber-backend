-- Run this in Supabase SQL Editor.

create table if not exists certificate_requests (
  id bigint generated always as identity primary key,
  created_at timestamptz not null default now(),
  certificate_type text not null,
  full_name text not null,
  business_name text,
  phone text not null,
  email text not null,
  purpose text,
  status text not null default 'Pending',
  office_notes text
);

alter table certificate_requests
  add constraint certificate_requests_status_check
  check (status in ('Pending', 'Issued', 'Rejected'));

alter table certificate_requests enable row level security;

-- Anyone can submit a request (the public form needs this, no login required).
create policy "Public can insert certificate requests"
on certificate_requests for insert
to anon
with check (true);

-- Only logged-in admins (same login as the rest of the admin panel) can
-- read or update requests -- same pattern as membership_applications.
create policy "Authenticated users can read certificate requests"
on certificate_requests for select
to authenticated
using (true);

create policy "Authenticated users can update certificate requests"
on certificate_requests for update
to authenticated
using (true);
