// Réponse de démonstration (ANALYZE_TAG_MOCK=true) : permet de tester le parcours
// de scan en local sans clé API ni coût. Jamais activée en production.

import type { ClaudeResult } from "./claude.ts";

export async function mockLabel(): Promise<ClaudeResult> {
  await new Promise((r) => setTimeout(r, 400));
  return {
    model: "mock",
    inputTokens: 0,
    outputTokens: 0,
    label: {
      is_fabric_label: true,
      name: "Sergé laine froide stretch",
      supplier_name: "Tissage Démo",
      supplier_code: "TD-SRG-280",
      composition: [{ fiber: "WO", pct: 62 }, { fiber: "PES", pct: 36 }, { fiber: "EL", pct: 2 }],
      weight_gsm: 280,
      width_cm: 150,
      weave: "twill",
      color_name: "Marine",
      color_hex: "#2F4A6B",
      care: ["wash_30", "no_bleach", "iron_low", "dryclean_p"],
      certifications: ["RWS"],
      uses: ["jacket", "trousers"],
      notes: "Allongement trame 15 % (démonstration).",
      uncertain_fields: ["weight_gsm", "color_hex"],
    },
  };
}
