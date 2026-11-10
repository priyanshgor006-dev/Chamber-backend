-- Run this AFTER the table-creation SQL you already ran.

-- Allow admin.html (and anyone with the anon key) to read applications
create policy "public read membership applications" on membership_applications
  for select using (true);

-- Allow admin.html to update status / membership_no / receipt_no / office_notes
create policy "public update membership applications" on membership_applications
  for update using (true) with check (true);
