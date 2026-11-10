-- Contact Us messages: run once in Supabase -> SQL Editor.
-- Anyone can SEND a message from the Contact Us page,
-- but only the logged-in admin can READ, update or delete messages.

create table if not exists contact_messages (
  id uuid primary key default gen_random_uuid(),
  created_at timestamptz not null default now(),
  name text not null check (char_length(name) between 1 and 120),
  email text not null check (char_length(email) between 3 and 200),
  phone text check (char_length(phone) <= 20),
  subject text check (char_length(subject) <= 100),
  message text not null check (char_length(message) between 1 and 2000),
  status text not null default 'New' check (status in ('New', 'Replied'))
);

alter table contact_messages enable row level security;

drop policy if exists "Public can send contact messages" on contact_messages;
drop policy if exists "Admin can read contact messages" on contact_messages;
drop policy if exists "Admin can update contact messages" on contact_messages;
drop policy if exists "Admin can delete contact messages" on contact_messages;

-- Visitors can only add a new message (always as "New"); they cannot read anything.
create policy "Public can send contact messages" on contact_messages
  for insert to anon, authenticated with check (status = 'New');
create policy "Admin can read contact messages" on contact_messages
  for select to authenticated using (true);
create policy "Admin can update contact messages" on contact_messages
  for update to authenticated using (true);
create policy "Admin can delete contact messages" on contact_messages
  for delete to authenticated using (true);
