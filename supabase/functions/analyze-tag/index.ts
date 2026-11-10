// Edge Function analyze-tag : lecture d'une photo d'étiquette d'échantillon par Claude.
//
// POST { imageBase64, mediaType: "image/jpeg" | "image/png" | "image/webp" }
//   → 200 { label, model, duration_ms, usage: { scans, quota } }
//   → 4xx/5xx { error: <code stable>, usage? }
//
// Réservé aux Éditeurs et Admins d'un atelier. Chaque analyse est comptée sur le
// quota mensuel de l'atelier ; une panne du service IA rend le scan réservé.
// La clé ANTHROPIC_API_KEY ne quitte jamais le serveur.
// ANALYZE_TAG_MOCK=true (développement local uniquement) : réponse de démonstration
// sans appel à l'IA.

import { createClient } from "@supabase/supabase-js";
import { AnalyzeError, analyzeWithClaude } from "./claude.ts";
import { MEDIA_TYPES, type MediaType, sanitize } from "./label.ts";
import { mockLabel } from "./mock.ts";

const MAX_BASE64_LENGTH = 7_000_000; // ≈ 5 Mo d'image
const MOCK = Deno.env.get("ANALYZE_TAG_MOCK") === "true";

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

const admin = createClient(
  Deno.env.get("SUPABASE_URL")!,
  Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
  { auth: { persistSession: false, autoRefreshToken: false } },
);

/// Usage du mois lu directement (droits d'administration) : { scans, quota }.
async function currentUsage(orgId: string) {
  const month = new Date().toISOString().slice(0, 7) + "-01";
  const [{ data: counter }, { data: org }] = await Promise.all([
    admin.from("usage_counters").select("scans").eq("org_id", orgId).eq("month", month).maybeSingle(),
    admin.from("organizations").select("scan_quota").eq("id", orgId).single(),
  ]);
  return { scans: counter?.scans ?? 0, quota: org?.scan_quota ?? 0 };
}

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: corsHeaders });
  if (req.method !== "POST") return json({ error: "method_not_allowed" }, 405);

  // Appelant : Éditeur ou Admin d'un atelier.
  const token = req.headers.get("Authorization")?.replace(/^Bearer\s+/i, "");
  if (!token) return json({ error: "not_authenticated" }, 401);
  const { data: caller } = await admin.auth.getUser(token);
  if (!caller?.user) return json({ error: "not_authenticated" }, 401);
  const { data: membership } = await admin
    .from("memberships")
    .select("org_id, role, organizations(kind)")
    .eq("user_id", caller.user.id)
    .maybeSingle();
  // deno-lint-ignore no-explicit-any
  const kind = (membership?.organizations as any)?.kind;
  if (!membership || kind !== "atelier" || !["admin", "editor"].includes(membership.role)) {
    return json({ error: "forbidden" }, 403);
  }
  const orgId = membership.org_id as string;

  let imageBase64: string;
  let mediaType: MediaType;
  try {
    const body = await req.json();
    imageBase64 = String(body.imageBase64 ?? "").replace(/^data:[^,]+,/, "").replace(/\s/g, "");
    mediaType = body.mediaType;
  } catch {
    return json({ error: "invalid_body" }, 400);
  }
  if (!imageBase64) return json({ error: "image_missing" }, 400);
  if (!MEDIA_TYPES.includes(mediaType)) return json({ error: "image_format" }, 415);
  if (imageBase64.length > MAX_BASE64_LENGTH) return json({ error: "image_too_large" }, 413);

  // Réservation du scan sur le quota du mois (atomique).
  const { data: usage, error: quotaError } = await admin.rpc("reserve_scan", { p_org: orgId });
  if (quotaError) {
    if (/quota_exceeded/.test(quotaError.message)) {
      return json({ error: "quota_exceeded", usage: await currentUsage(orgId) }, 429);
    }
    console.error("reserve_scan", quotaError);
    return json({ error: "internal_error" }, 500);
  }

  const started = performance.now();
  const elapsed = () => Math.round(performance.now() - started);
  const imageKb = Math.round((imageBase64.length * 3) / 4 / 1024);
  try {
    const result = MOCK ? await mockLabel() : await analyzeWithClaude(imageBase64, mediaType);
    await admin.rpc("record_scan_tokens", {
      p_org: orgId, p_input: result.inputTokens, p_output: result.outputTokens,
    });
    const label = sanitize(result.label);
    console.log(JSON.stringify({ event: "analyze", model: result.model, duration_ms: elapsed(), image_kb: imageKb }));
    if (!label.is_fabric_label) return json({ error: "not_a_label", usage }, 422);
    return json({ label, model: result.model, duration_ms: elapsed(), usage });
  } catch (err) {
    console.log(JSON.stringify({ event: "analyze_failed", duration_ms: elapsed(), image_kb: imageKb }));
    if (err instanceof AnalyzeError) {
      if (!err.consumed) await admin.rpc("release_scan", { p_org: orgId });
      return json({ error: err.code, usage }, err.status);
    }
    console.error(err);
    await admin.rpc("release_scan", { p_org: orgId });
    return json({ error: "internal_error" }, 500);
  }
});
