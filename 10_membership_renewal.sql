-- Membership renewal: run once in Supabase -> SQL Editor.
-- Adds joining date, due date, last renewed date and left date to members.
-- Existing members: joining date = the date they were added, due date = one year later.
-- (Patron / Lifetime members get no due date, because they never need to renew.)

alter table membership_applications add column if not exists joined_on date;
alter table membership_applications add column if not exists due_date date;
alter table membership_applications add column if not exists last_renewed_on date;
alter table membership_applications add column if not exists left_on date;

update membership_applications
set joined_on = created_at::date
where status = 'Approved' and joined_on is null;

update membership_applications
set due_date = (joined_on + interval '1 year')::date
where status = 'Approved' and due_date is null
  and coalesce(membership_category, '') !~* '(lifetime|patron)';
