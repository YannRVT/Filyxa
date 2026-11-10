// Edge Function admin-users : organisations et invitations.
//
// POST { action: "create_organization", name, kind }      → super-admin uniquement
//      { action: "invite", orgId, email, role }            → super-admin ou admin de l'organisation
//      { action: "resend_invitation", email }              → public (invitation valable en attente)
//
// L'invitation envoie un code à 6 chiffres par e-mail (modèle « invite » pour un
// nouveau compte, « magic_link » pour un compte existant). Elle est valable 48 h ;
// son acceptation se fait côté client via la fonction SQL accept_invitation().
//
// Utilise SUPABASE_SERVICE_ROLE_KEY, injectée automatiquement par Supabase.

import { createClient } from "@supabase/supabase-js";
import {
  canInvite,
  isAlreadyRegistered,
  isOrgKind,
  isRole,
  normalizeEmail,
  normalizeOrgName,
  type Role,
} from "./rules.ts";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

function json(body: unknown, status = 200) {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...corsHeaders, "Content-Type": "application/json" },
  });
}

// Les messages d'erreur sont des codes stables, traduits par l'application.
const fail = (code: string, status: number) => json({ error: code }, status);

const admin = createClient(
  Deno.env.get("SUPABASE_URL")!,
  Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
  { auth: { persistSession: false, autoRefreshToken: false } },
);

// Envoie un code à 6 chiffres. Un compte jamais confirmé (invité) reçoit le modèle
// « invite » (renvoyable tant qu'il n'est pas confirmé) ; un compte déjà actif
// reçoit un code de connexion (modèle « magic_link »).
async function sendInvitationCode(email: string): Promise<string | null> {
  const { error } = await admin.auth.admin.inviteUserByEmail(email);
  if (!error) return null;
  if (!isAlreadyRegistered(error.message)) return error.message;

  const { error: otpError } = await admin.auth.signInWithOtp({
    email,
    options: { shouldCreateUser: false },
  });
  return otpError?.message ?? null;
}

// Renvoi public d'un code : uniquement si une invitation valable est en attente.
// La réponse est toujours identique, pour ne pas révéler quelles adresses sont invitées.
async function resendInvitation(rawEmail: unknown): Promise<Response> {
  const email = normalizeEmail(rawEmail);
  if (email) {
    const { data: pending } = await admin
      .from("invitations")
      .select("id")
      .eq("email", email)
      .is("accepted_at", null)
      .is("revoked_at", null)
      .gt("expires_at", new Date().toISOString())
      .maybeSingle();
    if (pending) {
      const sendError = await sendInvitationCode(email);
      if (sendError) console.error("Renvoi du code impossible :", sendError);
    }
  }
  return json({ ok: true });
}

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: corsHeaders });
  if (req.method !== "POST") return fail("method_not_allowed", 405);

  // deno-lint-ignore no-explicit-any
  let body: any;
  try {
    body = await req.json();
  } catch {
    return fail("invalid_body", 400);
  }

  // Seule action accessible sans être connecté.
  if (body?.action === "resend_invitation") return resendInvitation(body.email);

  const token = req.headers.get("Authorization")?.replace(/^Bearer\s+/i, "");
  if (!token) return fail("not_authenticated", 401);
  const { data: caller, error: callerError } = await admin.auth.getUser(token);
  if (callerError || !caller.user) return fail("not_authenticated", 401);

  const { data: callerProfile } = await admin
    .from("profiles")
    .select("is_superadmin")
    .eq("id", caller.user.id)
    .single();
  const isSuperadmin = callerProfile?.is_superadmin === true;

  try {
    switch (body.action) {
      case "create_organization": {
        if (!isSuperadmin) return fail("forbidden", 403);
        const name = normalizeOrgName(body.name);
        if (!name) return fail("invalid_org_name", 400);
        if (!isOrgKind(body.kind)) return fail("invalid_org_kind", 400);

        const { data, error } = await admin
          .from("organizations")
          .insert({ name, kind: body.kind, created_by: caller.user.id })
          .select("id, name, kind, plan, scan_quota, created_at")
          .single();
        if (error) throw error;
        return json({ organization: data });
      }

      case "invite": {
        const orgId = typeof body.orgId === "string" ? body.orgId : null;
        const email = normalizeEmail(body.email);
        const role: Role | null = isRole(body.role) ? body.role : null;
        if (!orgId) return fail("invalid_org", 400);
        if (!email) return fail("invalid_email", 400);
        if (!role) return fail("invalid_role", 400);

        const { data: membership } = await admin
          .from("memberships")
          .select("role")
          .eq("org_id", orgId)
          .eq("user_id", caller.user.id)
          .maybeSingle();
        if (!canInvite({ isSuperadmin, roleInOrg: (membership?.role as Role) ?? null })) {
          return fail("forbidden", 403);
        }

        const { data: org } = await admin
          .from("organizations")
          .select("id")
          .eq("id", orgId)
          .maybeSingle();
        if (!org) return fail("invalid_org", 404);

        // V1 : une personne appartient à une seule organisation.
        const { data: invitee } = await admin
          .from("profiles")
          .select("id")
          .eq("email", email)
          .maybeSingle();
        if (invitee) {
          const { count } = await admin
            .from("memberships")
            .select("user_id", { count: "exact", head: true })
            .eq("user_id", invitee.id);
          if ((count ?? 0) > 0) return fail("already_member", 409);
        }

        // Une nouvelle invitation remplace celle encore en attente pour cette adresse.
        await admin
          .from("invitations")
          .update({ revoked_at: new Date().toISOString() })
          .eq("email", email)
          .is("accepted_at", null)
          .is("revoked_at", null);

        const { data: invitation, error: insertError } = await admin
          .from("invitations")
          .insert({ org_id: orgId, email, role, invited_by: caller.user.id })
          .select("id, org_id, email, role, expires_at")
          .single();
        if (insertError) throw insertError;

        const sendError = await sendInvitationCode(email);
        if (sendError) {
          console.error("Envoi du code impossible :", sendError);
          await admin
            .from("invitations")
            .update({ revoked_at: new Date().toISOString() })
            .eq("id", invitation.id);
          return fail("email_not_sent", 502);
        }
        return json({ invitation });
      }

      default:
        return fail("unknown_action", 400);
    }
  } catch (err) {
    console.error(err);
    return fail("internal_error", 500);
  }
});
