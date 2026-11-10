-- Industry 4.0 and Startups seminar was held on 13 August 2026.
update public.events
set event_date = ('2026-08-13'::date)::timestamp at time zone 'Asia/Kolkata'
where title = 'Seminar on Industry 4.0 and Startups';
