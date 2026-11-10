// Prompt, schéma JSON et nettoyage de la lecture d'étiquette.
// Les codes doivent rester identiques à lib/features/library/domain/catalog.dart
// (vérifié par test/supplier/../catalog_sync_test.dart côté Flutter).

export const MEDIA_TYPES = ["image/jpeg", "image/png", "image/webp"] as const;
export type MediaType = (typeof MEDIA_TYPES)[number];

/// Fibres, codes ISO 2076 / règlement UE 1007/2011.
export const FIBER_CODES = [
  "CO", "LI", "HA", "RA", "WO", "WS", "WM", "WA", "SE", "CV", "CMD", "CLY", "CUP", "CA",
  "PES", "PA", "PAN", "EL", "PP", "OT",
] as const;

export const WEAVE_CODES = [
  "plain", "twill", "satin", "dobby", "jacquard", "jersey", "rib", "fleece", "velvet",
  "corduroy", "crepe", "gauze", "lace", "nonwoven",
] as const;

export const USE_CODES = [
  "shirt", "dress", "skirt", "trousers", "jacket", "coat", "knitwear", "lining", "interlining",
  "lingerie", "sportswear", "footwear", "bags", "accessories", "home",
] as const;

export const CERTIFICATIONS = [
  "GOTS", "OEKO-TEX", "GRS", "RCS", "OCS", "RWS", "RMS", "RAF", "FSC", "bluesign",
  "EU Ecolabel", "Cradle to Cradle",
] as const;

export const CARE_CODES = [
  "wash_30", "wash_40", "wash_60", "hand_wash", "no_wash",
  "bleach", "no_bleach",
  "tumble_low", "tumble_normal", "no_tumble",
  "iron_low", "iron_medium", "iron_high", "no_iron",
  "dryclean_p", "dryclean_f", "wet_clean", "no_dryclean",
] as const;

/// Famille ISO 3758 de chaque symbole : une seule valeur par famille.
const CARE_FAMILY: Record<string, string> = Object.fromEntries(
  CARE_CODES.map((c) => [
    c,
    c.includes("wash") && !c.startsWith("wet") ? "wash"
      : c.includes("bleach") ? "bleach"
      : c.includes("tumble") ? "dry"
      : c.includes("iron") ? "iron"
      : "professional",
  ]),
);

/// Champs que l'IA peut signaler comme incertains (noms du formulaire Filyxa).
export const UNCERTAIN_FIELDS = [
  "name", "supplier_name", "supplier_code", "composition", "weight_gsm", "width_cm",
  "weave", "color_name", "color_hex", "care", "certifications",
] as const;

const nullableString = { type: ["string", "null"] };
const nullableInteger = { type: ["integer", "null"] };

export const LABEL_SCHEMA = {
  type: "object",
  additionalProperties: false,
  required: [
    "is_fabric_label", "name", "supplier_name", "supplier_code", "composition", "weight_gsm",
    "width_cm", "weave", "color_name", "color_hex", "care", "certifications", "uses",
    "notes", "uncertain_fields",
  ],
  properties: {
    is_fabric_label: { type: "boolean" },
    name: nullableString,
    supplier_name: nullableString,
    supplier_code: nullableString,
    composition: {
      type: "array",
      items: {
        type: "object",
        additionalProperties: false,
        required: ["fiber", "pct"],
        properties: {
          fiber: { type: "string", enum: FIBER_CODES },
          pct: { type: "number" },
        },
      },
    },
    weight_gsm: nullableInteger,
    width_cm: nullableInteger,
    weave: { anyOf: [{ type: "string", enum: WEAVE_CODES }, { type: "null" }] },
    color_name: nullableString,
    color_hex: nullableString,
    care: { type: "array", items: { type: "string", enum: CARE_CODES } },
    certifications: { type: "array", items: { type: "string", enum: CERTIFICATIONS } },
    uses: { type: "array", items: { type: "string", enum: USE_CODES } },
    notes: nullableString,
    uncertain_fields: { type: "array", items: { type: "string", enum: UNCERTAIN_FIELDS } },
  },
};

export const SYSTEM_PROMPT = `Tu es l'assistant technique d'un atelier de mode. On te montre la photo de l'étiquette d'un échantillon de tissu, d'une étiquette de rouleau ou d'une fiche technique fournisseur. Extrais les informations dans le schéma JSON fourni.

Règles :
- N'invente rien. Un champ absent ou illisible vaut null (ou une liste vide). Si une valeur est lue mais douteuse (flou, reflet, texte partiel, chiffre ambigu), renseigne-la et ajoute le nom du champ dans uncertain_fields.
- is_fabric_label = false si l'image ne montre ni étiquette ni fiche textile ; laisse alors les autres champs vides.
- supplier_name : le fabricant ou tisseur (logo, raison sociale). supplier_code : le code article / référence qualité (souvent « Art. », « Ref. », « Quality », « Codice », « Artículo »), recopié exactement, sans le coloris s'il est séparé.
- composition : codes de fibres ISO 2076 de la liste (laine/wool/lana/WV = WO, coton/cotton = CO, élasthanne/elastane/spandex/lycra/EA = EL, polyamide/nylon = PA, polyester/PL = PES, lin/linen = LI, soie/silk = SE, viscose/rayon = CV, cachemire = WS, lyocell/tencel = CLY…). Fibre absente de la liste : OT. Pourcentages tels qu'indiqués ; s'il y a plusieurs parties (extérieur / doublure), ne garde que l'étoffe principale et mentionne le reste dans notes.
- weight_gsm : grammage en g/m². Convertis si besoin (oz/yd² × 33,906 ; g/ml ÷ laize en mètres ; momme × 4,306). width_cm : laize utile en centimètres (pouces × 2,54).
- weave : armure parmi les codes de la liste (twill = sergé/saia, plain = toile/popeline/tela, satin, dobby = armuré, jersey, rib = côte, corduroy = velours côtelé…) ; null si non indiquée et non visible.
- color_name : nom du coloris tel qu'écrit. color_hex : estimation #RRGGBB de la couleur de l'échantillon visible ; si seul un nom de couleur est écrit, estime raisonnablement et marque color_hex comme incertain.
- care : symboles ou mentions d'entretien traduits en codes ISO 3758 de la liste, au plus un par famille (lavage, blanchiment, séchage, repassage, nettoyage professionnel).
- certifications : uniquement celles de la liste, quand le sigle ou le logo est visible ; un numéro de certificat éventuel va dans notes.
- name : le nom commercial s'il est indiqué, sinon un nom descriptif court dans la langue de l'étiquette (ex. « Sergé de laine stretch »).
- uses : 2 à 4 usages plausibles d'après la matière et le grammage.
- notes : informations utiles non couvertes (allongement, finition, traitement, deuxième partie de composition), sinon null.`;

export const USER_PROMPT = "Analyse cette étiquette ou fiche technique textile.";

export interface CleanLabel {
  is_fabric_label: boolean;
  name: string | null;
  supplier_name: string | null;
  supplier_code: string | null;
  composition: { fiber: string; pct: number }[];
  weight_gsm: number | null;
  width_cm: number | null;
  weave: string | null;
  color_name: string | null;
  color_hex: string | null;
  care: string[];
  certifications: string[];
  uses: string[];
  notes: string | null;
  uncertain_fields: string[];
}

const text = (v: unknown, max: number) =>
  typeof v === "string" && v.trim() ? v.trim().slice(0, max) : null;

const within = (v: unknown, min: number, max: number) =>
  typeof v === "number" && Number.isFinite(v) && v >= min && v <= max ? Math.round(v) : null;

function inList<T extends string>(list: readonly T[], v: unknown): v is T {
  return typeof v === "string" && (list as readonly string[]).includes(v);
}

/// Bornes, formats et cohérence, appliqués à toute réponse de l'IA.
/// Une composition qui ne totalise pas 100 % est conservée mais signalée incertaine.
// deno-lint-ignore no-explicit-any
export function sanitize(raw: any): CleanLabel {
  const uncertain = new Set<string>(
    (raw?.uncertain_fields ?? []).filter((f: unknown) => inList(UNCERTAIN_FIELDS, f)),
  );

  // Composition : codes connus, pourcentages bornés, fibres en double regroupées.
  const merged = new Map<string, number>();
  for (const c of raw?.composition ?? []) {
    if (!inList(FIBER_CODES, c?.fiber)) continue;
    const pct = Math.round(Math.min(100, Math.max(0, Number(c.pct) || 0)) * 10) / 10;
    if (pct <= 0) continue;
    merged.set(c.fiber, (merged.get(c.fiber) ?? 0) + pct);
  }
  const composition = [...merged].map(([fiber, pct]) => ({ fiber, pct }));
  const total = composition.reduce((s, c) => s + c.pct, 0);
  if (composition.length > 0 && Math.abs(total - 100) > 0.5) uncertain.add("composition");

  // Entretien : codes connus, un seul par famille (le premier lu).
  const seenFamilies = new Set<string>();
  const care: string[] = [];
  for (const c of raw?.care ?? []) {
    if (!inList(CARE_CODES, c) || seenFamilies.has(CARE_FAMILY[c])) continue;
    seenFamilies.add(CARE_FAMILY[c]);
    care.push(c);
  }

  const hex = typeof raw?.color_hex === "string" ? raw.color_hex.trim() : "";
  return {
    is_fabric_label: raw?.is_fabric_label === true,
    name: text(raw?.name, 160),
    supplier_name: text(raw?.supplier_name, 160),
    supplier_code: text(raw?.supplier_code, 80),
    composition,
    weight_gsm: within(raw?.weight_gsm, 1, 2000),
    width_cm: within(raw?.width_cm, 1, 600),
    weave: inList(WEAVE_CODES, raw?.weave) ? raw.weave : null,
    color_name: text(raw?.color_name, 80),
    color_hex: /^#?[0-9a-fA-F]{6}$/.test(hex) ? `#${hex.replace("#", "").toUpperCase()}` : null,
    care,
    certifications: [...new Set<string>((raw?.certifications ?? []).filter((c: unknown) => inList(CERTIFICATIONS, c)))],
    uses: [...new Set<string>((raw?.uses ?? []).filter((u: unknown) => inList(USE_CODES, u)))],
    notes: text(raw?.notes, 2000),
    uncertain_fields: [...uncertain],
  };
}
