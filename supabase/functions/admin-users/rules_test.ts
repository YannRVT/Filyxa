import { assertEquals } from "jsr:@std/assert@1";
import {
  canInvite,
  isAlreadyRegistered,
  isOrgKind,
  isRole,
  normalizeEmail,
  normalizeOrgName,
} from "./rules.ts";

Deno.test("normalizeEmail met en minuscules et rejette les adresses invalides", () => {
  assertEquals(normalizeEmail("  Claire@Atelier.FR "), "claire@atelier.fr");
  assertEquals(normalizeEmail("claire@atelier"), null);
  assertEquals(normalizeEmail("pas un email"), null);
  assertEquals(normalizeEmail(42), null);
});

Deno.test("normalizeOrgName compacte les espaces et borne la longueur", () => {
  assertEquals(normalizeOrgName("  Maison   Lune "), "Maison Lune");
  assertEquals(normalizeOrgName("A"), null);
  assertEquals(normalizeOrgName("x".repeat(121)), null);
});

Deno.test("isRole et isOrgKind n'acceptent que les valeurs connues", () => {
  assertEquals(isRole("editor"), true);
  assertEquals(isRole("member"), false);
  assertEquals(isOrgKind("supplier"), true);
  assertEquals(isOrgKind("client"), false);
});

Deno.test("canInvite : super-admin ou admin de l'organisation uniquement", () => {
  assertEquals(canInvite({ isSuperadmin: true, roleInOrg: null }), true);
  assertEquals(canInvite({ isSuperadmin: false, roleInOrg: "admin" }), true);
  assertEquals(canInvite({ isSuperadmin: false, roleInOrg: "editor" }), false);
  assertEquals(canInvite({ isSuperadmin: false, roleInOrg: null }), false);
});

Deno.test("isAlreadyRegistered reconnaît les messages Supabase", () => {
  assertEquals(isAlreadyRegistered("A user with this email address has already been registered"), true);
  assertEquals(isAlreadyRegistered("Rate limit exceeded"), false);
});
