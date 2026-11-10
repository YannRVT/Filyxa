/// Rôle d'un membre dans son organisation.
enum MemberRole {
  admin,
  editor,
  viewer;

  static MemberRole parse(String value) =>
      MemberRole.values.firstWhere((r) => r.name == value, orElse: () => MemberRole.viewer);

  int get rank => switch (this) { admin => 3, editor => 2, viewer => 1 };

  /// Vrai si ce rôle donne au moins les droits de [other].
  bool atLeast(MemberRole other) => rank >= other.rank;
}

enum OrgKind {
  atelier,
  supplier;

  static OrgKind parse(String value) =>
      OrgKind.values.firstWhere((k) => k.name == value, orElse: () => OrgKind.atelier);
}

class Organization {
  const Organization({required this.id, required this.name, required this.kind});

  factory Organization.fromJson(Map<String, dynamic> json) => Organization(
        id: json['id'] as String,
        name: json['name'] as String,
        kind: OrgKind.parse(json['kind'] as String),
      );

  final String id;
  final String name;
  final OrgKind kind;
}

class Profile {
  const Profile({
    required this.id,
    required this.email,
    required this.locale,
    required this.isSuperadmin,
    this.fullName,
  });

  factory Profile.fromJson(Map<String, dynamic> json) => Profile(
        id: json['id'] as String,
        email: json['email'] as String,
        fullName: json['full_name'] as String?,
        locale: json['locale'] as String? ?? 'fr',
        isSuperadmin: json['is_superadmin'] as bool? ?? false,
      );

  final String id;
  final String email;
  final String? fullName;
  final String locale;
  final bool isSuperadmin;

  /// Nom affiché : le nom saisi, sinon la partie locale de l'e-mail.
  String get displayName =>
      (fullName != null && fullName!.trim().isNotEmpty) ? fullName!.trim() : email.split('@').first;

  /// Initiales pour l'avatar.
  String get initials {
    final parts = displayName.split(RegExp(r'[\s._-]+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }
}

class Membership {
  const Membership({required this.organization, required this.role});

  final Organization organization;
  final MemberRole role;
}

/// Espace de l'utilisateur connecté : son profil et son organisation (une seule en V1).
class UserSpace {
  const UserSpace({required this.profile, this.membership});

  final Profile profile;
  final Membership? membership;

  bool get hasOrganization => membership != null;
}
