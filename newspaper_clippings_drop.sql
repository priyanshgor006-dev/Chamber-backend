-- Run this FIRST in Supabase SQL Editor to remove the table completely
-- (including the test row and all its policies), so we can rebuild it
-- clean. This only affects the newspaper_clippings table -- nothing else
-- on your site is touched.

drop table if exists newspaper_clippings;
