-- Adds a photo album to each event (list of photo links).
-- Run once in Supabase > SQL Editor before uploading the new admin.html / events.html.
alter table public.events
  add column if not exists photos jsonb not null default '[]'::jsonb;

alter table public.events
  drop constraint if exists events_photos_is_list;
alter table public.events
  add constraint events_photos_is_list
  check (jsonb_typeof(photos) = 'array' and jsonb_array_length(photos) <= 20);
