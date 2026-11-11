// Banc d'essai de lecture d'étiquettes (critères de la phase 6 : < 7 s, ≥ 90 % des champs).
//
// Les photos restent hors du dépôt (données fournisseurs). Pour chaque photo
// <nom>.jpg|png|webp, un fichier <nom>.truth.json donne les valeurs attendues :
//   { "supplier_code": "DR4521", "composition": [{"fiber":"WO","pct":62},{"fiber":"PES","pct":38}],
//     "weight_gsm": 280, "width_cm": 150, "care": ["wash_30","iron_low"] }
// Seuls les champs présents dans le fichier sont notés.
//
//   deno run -A tools/label-eval/eval.ts --init <dossier>   # crée les .truth.json vides à compléter
//   ANTHROPIC_API_KEY=… deno run -A tools/label-eval/eval.ts <dossier>
//
// Chaque photo est envoyée à Claude (coût réel) avec le prompt et le schéma de production.

import { analyzeWithClaude } from "../../supabase/functions/analyze-tag/claude.ts";
import { type MediaType, sanitize } from "../../supabase/functions/analyze-tag/label.ts";
import { encodeBase64 } from "jsr:@std/encoding@1/base64";

const FIELDS = ["supplier_code", "composition", "weight_gsm", "width_cm", "care"] as const;
const TYPES: Record<string, MediaType> = { jpg: "image/jpeg", jpeg: "image/jpeg", png: "image/png", webp: "image/webp" };

const args = Deno.args;
const init = args[0] === "--init";
const dir = init ? args[1] : args[0];
if (!dir) {
  console.error("Usage : deno run -A tools/label-eval/eval.ts [--init] <dossier de photos>");
  Deno.exit(1);
}

const photos = [...Deno.readDirSync(dir)]
  .filter((e) => e.isFile && TYPES[e.name.split(".").pop()!.toLowerCase()])
  .map((e) => e.name)
  .sort();

if (init) {
  for (const p of photos) {
    const truth = `${dir}/${p.replace(/\.[^.]+$/, "")}.truth.json`;
    try {
      Deno.statSync(truth);
    } catch {
      Deno.writeTextFileSync(truth, JSON.stringify({ supplier_code: null, composition: [], weight_gsm: null, width_cm: null, care: [] }, null, 2));
    }
  }
  console.log(`${photos.length} fichiers .truth.json prêts à compléter dans ${dir}`);
  Deno.exit(0);
}

// deno-lint-ignore no-explicit-any
const same = (field: string, got: any, want: any): boolean => {
  const norm = (v: string | null) => (v ?? "").toUpperCase().replace(/[^A-Z0-9]/g, "");
  if (field === "supplier_code") return norm(got) === norm(want);
  if (field === "composition") {
    const key = (c: { fiber: string; pct: number }[]) =>
      [...(c ?? [])].sort((a, b) => a.fiber.localeCompare(b.fiber)).map((x) => `${x.fiber}${x.pct}`).join(",");
    return key(got) === key(want);
  }
  if (field === "care") return [...(got ?? [])].sort().join(",") === [...(want ?? [])].sort().join(",");
  return got === want;
};

let correct = 0, total = 0;
const times: number[] = [];
const perField: Record<string, [number, number]> = Object.fromEntries(FIELDS.map((f) => [f, [0, 0]]));

for (const p of photos) {
  const base = p.replace(/\.[^.]+$/, "");
  let truth: Record<string, unknown>;
  try {
    truth = JSON.parse(Deno.readTextFileSync(`${dir}/${base}.truth.json`));
  } catch {
    console.log(`– ${p} : pas de .truth.json, ignorée`);
    continue;
  }
  const bytes = Deno.readFileSync(`${dir}/${p}`);
  const started = performance.now();
  const result = await analyzeWithClaude(encodeBase64(bytes), TYPES[p.split(".").pop()!.toLowerCase()]);
  const ms = Math.round(performance.now() - started);
  times.push(ms);
  const label = sanitize(result.label) as unknown as Record<string, unknown>;
  const misses: string[] = [];
  for (const f of FIELDS) {
    if (!(f in truth)) continue;
    const ok = same(f, label[f], truth[f]);
    perField[f][1]++;
    total++;
    if (ok) {
      perField[f][0]++;
      correct++;
    } else misses.push(`${f}: lu ${JSON.stringify(label[f])}, attendu ${JSON.stringify(truth[f])}`);
  }
  console.log(`${misses.length ? "✗" : "✓"} ${p} (${ms} ms)${misses.length ? "\n    " + misses.join("\n    ") : ""}`);
}

times.sort((a, b) => a - b);
const p90 = times[Math.min(times.length - 1, Math.ceil(times.length * 0.9) - 1)] ?? 0;
console.log(`\nChamps corrects : ${correct}/${total} (${total ? Math.round((correct / total) * 100) : 0} %) — critère ≥ 90 %`);
for (const f of FIELDS) console.log(`  ${f} : ${perField[f][0]}/${perField[f][1]}`);
console.log(`Durée IA, 9 scans sur 10 sous : ${p90} ms — critère < 7 000 ms (hors envoi de la photo en 4G)`);
