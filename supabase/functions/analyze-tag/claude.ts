// Lecture d'étiquette par Claude : sortie JSON structurée stricte.

import Anthropic from "@anthropic-ai/sdk";
import { LABEL_SCHEMA, type MediaType, SYSTEM_PROMPT, USER_PROMPT } from "./label.ts";

// Secrets optionnels : CLAUDE_MODEL (défaut claude-opus-5-5) et CLAUDE_FAST=true
// (mode rapide d'Opus 5.5, facturé le double, pour tenir l'objectif des 7 s).
const MODEL = Deno.env.get("CLAUDE_MODEL")?.trim() || "claude-opus-5-5";
const FAST = Deno.env.get("CLAUDE_FAST") === "true" && MODEL === "claude-opus-5-5";

/// Erreur renvoyée à l'application avec un code stable (traduit par l'app).
export class AnalyzeError extends Error {
  constructor(public status: number, public code: string, public consumed = true) {
    super(code);
  }
}

export interface ClaudeResult {
  // deno-lint-ignore no-explicit-any
  label: any;
  model: string;
  inputTokens: number;
  outputTokens: number;
}

let client: Anthropic | null = null;

export async function analyzeWithClaude(imageBase64: string, mediaType: MediaType): Promise<ClaudeResult> {
  client ??= new Anthropic(); // lit ANTHROPIC_API_KEY
  const supportsFallback = !MODEL.includes("haiku");
  const request = (fast: boolean) =>
    client!.beta.messages.create({
      model: MODEL,
      max_tokens: 16000,
      // Repli serveur en cas de refus (pas disponible sur Haiku).
      ...(supportsFallback ? { fallbacks: "default" } : {}),
      betas: supportsFallback ? ["server-side-fallback-2026-07-01"] : [],
      ...(fast ? { speed: "fast" } : {}),
      // Opus 5.5 : la réflexion ne se désactive pas ; un effort bas suffit pour une lecture d'étiquette.
      output_config: {
        effort: "low",
        format: { type: "json_schema", schema: LABEL_SCHEMA },
      },
      // Le prompt ne change jamais : mis en cache pendant une série de scans.
      system: [{ type: "text", text: SYSTEM_PROMPT, cache_control: { type: "ephemeral" } }],
      messages: [{
        role: "user",
        content: [
          { type: "image", source: { type: "base64", media_type: mediaType, data: imageBase64 } },
          { type: "text", text: USER_PROMPT },
        ],
      }],
    // deno-lint-ignore no-explicit-any
    } as any);

  try {
    // Le mode rapide a sa propre limite de débit : en cas de saturation, vitesse normale.
    const response = await request(FAST).catch((err) => {
      if (FAST && err instanceof Anthropic.RateLimitError) return request(false);
      throw err;
    });
    const usage = response.usage;
    console.log(JSON.stringify({
      event: "claude_usage",
      model: response.model,
      speed: usage.speed,
      input_tokens: usage.input_tokens,
      cache_read_input_tokens: usage.cache_read_input_tokens,
      output_tokens: usage.output_tokens,
    }));

    if (response.stop_reason === "refusal") throw new AnalyzeError(422, "analysis_refused");
    if (response.stop_reason === "max_tokens") throw new AnalyzeError(502, "analysis_incomplete");
    // deno-lint-ignore no-explicit-any
    const textBlock = response.content.find((b: any) => b.type === "text");
    if (!textBlock || textBlock.type !== "text") throw new AnalyzeError(502, "analysis_empty");
    return {
      label: JSON.parse(textBlock.text),
      model: response.model,
      inputTokens: (usage.input_tokens ?? 0) + (usage.cache_read_input_tokens ?? 0) + (usage.cache_creation_input_tokens ?? 0),
      outputTokens: usage.output_tokens ?? 0,
    };
  } catch (err) {
    if (err instanceof AnalyzeError) throw err;
    if (err instanceof SyntaxError) throw new AnalyzeError(502, "analysis_unreadable");
    // Pannes du service : le scan n'a pas eu lieu, il est rendu à l'atelier.
    if (err instanceof Anthropic.RateLimitError) throw new AnalyzeError(429, "ai_busy", false);
    if (err instanceof Anthropic.AuthenticationError || err instanceof Anthropic.PermissionDeniedError) {
      console.error("Claude : clé ANTHROPIC_API_KEY invalide, absente ou sans accès");
      throw new AnalyzeError(500, "ai_misconfigured", false);
    }
    if (err instanceof Anthropic.APIConnectionError) throw new AnalyzeError(502, "ai_unavailable", false);
    if (err instanceof Anthropic.APIError) {
      console.error("Claude : erreur API", err.status, err.message);
      throw new AnalyzeError(502, "ai_unavailable", false);
    }
    throw err;
  }
}
