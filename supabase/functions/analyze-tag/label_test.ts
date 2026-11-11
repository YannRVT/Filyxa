import { assertEquals } from "jsr:@std/assert@1";
import { LABEL_SCHEMA, sanitize } from "./label.ts";

Deno.test("sanitize : codes inconnus écartés, bornes appliquées, couleur normalisée", () => {
  const clean = sanitize({
    is_fabric_label: true,
    name: "  Drap  ",
    supplier_code: "DR4521",
    composition: [{ fiber: "WO", pct: 62 }, { fiber: "XX", pct: 10 }, { fiber: "PES", pct: 38 }],
    weight_gsm: 280.4,
    width_cm: 9999,
    weave: "sergé",
    color_hex: "2f4a6b",
    care: ["wash_30", "wash_40", "iron_low", "made_up"],
    certifications: ["GOTS", "Inconnu", "GOTS"],
    uses: ["jacket", "spaceship"],
    uncertain_fields: ["weight_gsm", "pirate"],
  });
  assertEquals(clean.name, "Drap");
  assertEquals(clean.composition, [{ fiber: "WO", pct: 62 }, { fiber: "PES", pct: 38 }]);
  assertEquals(clean.weight_gsm, 280);
  assertEquals(clean.width_cm, null);
  assertEquals(clean.weave, null, "armure hors liste écartée");
  assertEquals(clean.color_hex, "#2F4A6B");
  assertEquals(clean.care, ["wash_30", "iron_low"], "un seul symbole par famille");
  assertEquals(clean.certifications, ["GOTS"]);
  assertEquals(clean.uses, ["jacket"]);
  assertEquals(clean.uncertain_fields, ["weight_gsm"]);
});

Deno.test("sanitize : composition qui ne fait pas 100 % signalée incertaine", () => {
  const clean = sanitize({ is_fabric_label: true, composition: [{ fiber: "WO", pct: 60 }] });
  assertEquals(clean.uncertain_fields.includes("composition"), true);
});

Deno.test("sanitize : fibre citée deux fois regroupée", () => {
  const clean = sanitize({ is_fabric_label: true, composition: [{ fiber: "CO", pct: 50 }, { fiber: "CO", pct: 50 }] });
  assertEquals(clean.composition, [{ fiber: "CO", pct: 100 }]);
});

Deno.test("sanitize : réponse vide ou absurde → pas une étiquette", () => {
  assertEquals(sanitize(null).is_fabric_label, false);
  assertEquals(sanitize({ is_fabric_label: "yes" }).is_fabric_label, false);
});

Deno.test("schéma : tous les champs sont requis (sortie structurée stricte)", () => {
  assertEquals(LABEL_SCHEMA.required.sort(), Object.keys(LABEL_SCHEMA.properties).sort());
});
