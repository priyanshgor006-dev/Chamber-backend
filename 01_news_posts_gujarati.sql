-- Run this in Supabase SQL Editor.
-- Adds optional Gujarati fields, filled in manually by the admin --
-- no machine translation involved. If left empty, the public site
-- simply falls back to the English title/body.

alter table news_posts
  add column if not exists title_gu text,
  add column if not exists body_gu text;
