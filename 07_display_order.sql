-- Lets the admin panel set the display order (the up/down arrows).
-- Run once in Supabase -> SQL Editor BEFORE uploading the new pages.
-- Adds an empty "sort_order" number column; nothing else changes.
-- Items without an order keep showing newest first.

alter table news_posts          add column if not exists sort_order integer;
alter table media_coverage      add column if not exists sort_order integer;
alter table gallery_images      add column if not exists sort_order integer;
alter table newspaper_clippings add column if not exists sort_order integer;
alter table projects            add column if not exists sort_order integer;
alter table committee_members   add column if not exists sort_order integer;
