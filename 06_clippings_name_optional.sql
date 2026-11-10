-- Newspaper clippings: the newspaper name is now optional.
-- Run once in Supabase -> SQL Editor. Existing clippings are not changed.
alter table newspaper_clippings alter column publication_name drop not null;
