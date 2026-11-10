-- Removes the time from all events (keeps only the date), so no time is shown.
update public.events
set event_date = ((event_date at time zone 'Asia/Kolkata')::date)::timestamp at time zone 'Asia/Kolkata';
