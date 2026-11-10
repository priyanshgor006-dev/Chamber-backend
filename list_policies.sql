-- Read-only. Run in Supabase -> SQL Editor to see the access rules that are
-- actually live. The migration files in this repo are the history of what was
-- run; this query is the source of truth for the current state.

-- 1) Is Row Level Security switched on for each table?
select c.relname as table_name, c.relrowsecurity as rls_enabled
from pg_class c
join pg_namespace n on n.oid = c.relnamespace
where n.nspname = 'public' and c.relkind = 'r'
order by c.relname;

-- 2) Every policy: who (roles) may do what (cmd) on which table.
select tablename, policyname, cmd, roles, qual as using_expr, with_check
from pg_policies
where schemaname = 'public'
order by tablename, cmd, policyname;
