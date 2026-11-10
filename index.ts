// Supabase Edge Function: notify-membership
// Deploy with: supabase functions deploy notify-membership
// Set secrets:
//   supabase secrets set RESEND_API_KEY=your_resend_api_key
//   supabase secrets set CHAMBER_NOTIFY_EMAIL=Infoatccifb@gmail.com
//   supabase secrets set RESEND_FROM_EMAIL=onboarding@resend.dev
//   supabase secrets set WEBHOOK_SHARED_SECRET=pick-any-random-string
//
// Triggered by a Supabase Database Webhook on membership_applications INSERT
// (set up in the dashboard -- see the accompanying instructions). The
// webhook sends the newly inserted row; this function emails a summary of
// it to the Chamber's notification address via Resend.

import { serve } from "https://deno.land/std@0.168.0/http/server.ts";

const RESEND_API_KEY = Deno.env.get("RESEND_API_KEY")!;
const CHAMBER_NOTIFY_EMAIL = Deno.env.get("CHAMBER_NOTIFY_EMAIL")!;
const RESEND_FROM_EMAIL = Deno.env.get("RESEND_FROM_EMAIL") ?? "onboarding@resend.dev";
// Supabase lets a Database Webhook send a custom header -- this checks it
// matches, so a random person who finds this function's URL can't trigger
// fake notification emails. It is not meant to hide the URL, only to make
// sure the request actually came from your own webhook.
const WEBHOOK_SHARED_SECRET = Deno.env.get("WEBHOOK_SHARED_SECRET")!;

function escapeHtml(value: unknown): string {
  return String(value ?? "").replace(/[&<>"']/g, (c) =>
    ({ "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;", "'": "&#39;" }[c] as string)
  );
}

function field(label: string, value: unknown): string {
  const text = value === null || value === undefined || String(value).trim() === "" ? "Not provided" : escapeHtml(value);
  return `<tr><td style="padding:4px 12px 4px 0;color:#6b7280;white-space:nowrap;vertical-align:top">${label}</td><td style="padding:4px 0">${text}</td></tr>`;
}

function documentLink(label: string, url: unknown): string {
  const safe = typeof url === "string" && url.trim() ? url.trim() : "";
  if (!safe) return "";
  return `<li><a href="${escapeHtml(safe)}" style="color:#6b1f2a">${label}</a></li>`;
}

serve(async (req) => {
  try {
    if (req.headers.get("x-webhook-secret") !== WEBHOOK_SHARED_SECRET) {
      return new Response(JSON.stringify({ error: "Unauthorized" }), {
        status: 401,
        headers: { "Content-Type": "application/json" },
      });
    }

    const payload = await req.json();
    // Supabase Database Webhooks send { type, table, record, old_record, schema }
    const application = payload.record;
    if (!application) {
      return new Response(JSON.stringify({ error: "No application record in payload." }), {
        status: 400,
        headers: { "Content-Type": "application/json" },
      });
    }

    const documents = [
      documentLink("Certificate", application.doc_certificate_url),
      documentLink("PAN", application.doc_pan_url),
      documentLink("Registration", application.doc_registration_url),
      documentLink("GST", application.doc_gst_url),
      documentLink("Address Proof", application.doc_address_proof_url),
      documentLink("Partnership Deed", application.doc_partnership_deed_url),
      documentLink("Photo", application.doc_photo_url),
      documentLink("Payment Receipt", application.doc_payment_receipt_url),
    ]
      .filter(Boolean)
      .join("");

    const html = `
      <div style="font-family:-apple-system,Segoe UI,Roboto,Helvetica,Arial,sans-serif;max-width:600px;margin:0 auto">
        <h2 style="color:#6b1f2a;margin-bottom:4px">New Membership Application</h2>
        <p style="color:#6b7280;margin-top:0">A new application was just submitted on the Chamber website.</p>
        <table style="width:100%;border-collapse:collapse;font-size:14px;margin-top:16px">
          ${field("Organization", application.organization_name)}
          ${field("Category", application.membership_category)}
          ${field("Organization Type", application.organization_type)}
          ${field("Mobile", application.mobile)}
          ${field("Email", application.email)}
          ${field("Phone", application.phone)}
          ${field("Registered Address", application.registered_address)}
        </table>
        ${
          documents
            ? `<h3 style="color:#6b1f2a;font-size:14px;margin-top:24px">Uploaded Documents</h3><ul style="font-size:14px;padding-left:18px">${documents}</ul>`
            : ""
        }
        <p style="color:#6b7280;font-size:12px;margin-top:28px">
          Review and approve or reject this application in the
          <a href="https://YOUR-NETLIFY-SITE.netlify.app/admin.html" style="color:#6b1f2a">admin panel</a>.
        </p>
      </div>
    `;

    const response = await fetch("https://api.resend.com/emails", {
      method: "POST",
      headers: {
        Authorization: `Bearer ${RESEND_API_KEY}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        from: RESEND_FROM_EMAIL,
        to: CHAMBER_NOTIFY_EMAIL,
        subject: `New membership application: ${application.organization_name || "Untitled"}`,
        html,
      }),
    });

    if (!response.ok) {
      const errorText = await response.text();
      throw new Error(`Resend request failed: ${errorText}`);
    }

    return new Response(JSON.stringify({ ok: true }), {
      status: 200,
      headers: { "Content-Type": "application/json" },
    });
  } catch (err) {
    return new Response(JSON.stringify({ error: String(err) }), {
      status: 500,
      headers: { "Content-Type": "application/json" },
    });
  }
});
