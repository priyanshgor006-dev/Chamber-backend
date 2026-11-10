-- 1) Removes the non-seminar items that past_events.sql added (meetings, felicitations, awards etc.).
--    Only these exact titles are removed; events you added yourself are not touched.
delete from public.events where title in (
 'Honour for Municipality Office-bearers and Development Meeting',
 'Felicitation of the Chamber President by MP Vinod Chavda',
 'Courtesy Meeting with the District Collector',
 'Budget Suggestions Presented to the MP',
 'Meeting with the Chief Minister on Land Measurement Issues',
 'Meeting with Prime Minister Narendra Modi',
 'Traders'' Meeting on Boycott of Turkey and Azerbaijan',
 'Meeting with the Collector on Emergency Preparedness',
 'Yashgatha Gujarati Award to Anil Gor',
 'Meeting with Chief Minister Bhupendra Patel',
 'Madhapar Vepari Association Get-together',
 'Dialogue with Non-Resident Kutchis',
 'Air India Bhuj–London Flight Launch',
 'Meeting with the US Consul'
);

-- 2) Adds the meeting with the Airport Authority (24 April 2024).
insert into public.events (title, event_date, location, description, photos)
select $t$Meeting with the Airport Authority on Bhuj Airport$t$,
       ('2024-04-24'::date)::timestamp at time zone 'Asia/Kolkata',
       'Bhuj Airport',
       $d$A team of the Global Kutch Federation and the Chamber held a two-hour meeting with Bhuj Airport Director Navinkumar Sagar and officers of Air India. They discussed the renovation of the airport, being done at a cost of about ₹10.75 crore, after which the terminal will be able to handle around 1,200 passengers instead of 500. Other issues raised included a direct Bhuj–Delhi flight, international cargo, facilities for passengers and fair taxi fares from the airport, which the officers agreed to take up with the RTO.$d$,
       '[]'::jsonb
where not exists (select 1 from public.events where title = 'Meeting with the Airport Authority on Bhuj Airport');

-- 3) Makes sure no event has a time (date only).
update public.events
set event_date = ((event_date at time zone 'Asia/Kolkata')::date)::timestamp at time zone 'Asia/Kolkata';
