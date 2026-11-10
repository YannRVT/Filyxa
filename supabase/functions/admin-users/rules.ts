// Règles pures de l'Edge Function admin-users (testées sans réseau).

export const ROLES = ["admin", "editor", "viewer"] as const;
export type Role = (typeof ROLES)[number];

export const ORG_KINDS = ["atelier", "supplier"] as const;
export type OrgKind = (typeof ORG_KINDS)[number];

const EMAIL_RE = /^[^@\s]+@[^@\s]+\.[^@\s]+$/;

export function normalizeEmail(value: unknown): string | null {
  if (typeof value !== "string") return null;
  const email = value.trim().toLowerCase();
  return EMAIL_RE.test(email) ? email : null;
}

export function normalizeOrgName(value: unknown): string | null {
  if (typeof value !== "string") return null;
  const name = value.trim().replace(/\s+/g, " ");
  return name.length >= 2 && name.length <= 120 ? name : null;
}

export function isRole(value: unknown): value is Role {
  return typeof value === "string" && (ROLES as readonly string[]).includes(value);
}

export function isOrgKind(value: unknown): value is OrgKind {
  return typeof value === "string" && (ORG_KINDS as readonly string[]).includes(value);
}

/** Qui gère les membres d'une organisation (inviter, changer un rôle, retirer) :
 * le super-admin ou un admin de cette organisation. */
export function canManageMembers(caller: { isSuperadmin: boolean; roleInOrg: Role | null }): boolean {
  return caller.isSuperadmin || caller.roleInOrg === "admin";
}

/**
 * Vrai si le changement retirerait le dernier admin de l'organisation.
 * `newRole` vaut `null` quand le membre est retiré.
 */
export function wouldLeaveNoAdmin(change: {
  adminCount: number;
  currentRole: Role;
  newRole: Role | null;
}): boolean {
  return change.currentRole === "admin" && change.newRole !== "admin" && change.adminCount <= 1;
}

/** Supabase signale un compte déjà existant par un message, pas par un code stable. */
export function isAlreadyRegistered(message: string | undefined): boolean {
  return /already|registered|exists/i.test(message ?? "");
}
