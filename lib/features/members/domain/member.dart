import '../../session/domain/user_space.dart';

class Member {
  const Member({
    required this.userId,
    required this.email,
    required this.role,
    required this.joinedAt,
    this.fullName,
  });

  final String userId;
  final String email;
  final String? fullName;
  final MemberRole role;
  final DateTime joinedAt;

  String get displayName =>
      (fullName != null && fullName!.trim().isNotEmpty) ? fullName!.trim() : email.split('@').first;
}

class Invitation {
  const Invitation({
    required this.id,
    required this.email,
    required this.role,
    required this.expiresAt,
  });

  final String id;
  final String email;
  final MemberRole role;
  final DateTime expiresAt;

  bool isExpiredAt(DateTime now) => expiresAt.isBefore(now);
}

class MembersOverview {
  const MembersOverview({required this.members, required this.invitations});

  final List<Member> members;
  final List<Invitation> invitations;
}

/// Admins d'abord, puis Éditeurs, puis Lecteurs ; ordre alphabétique dans chaque rôle.
List<Member> sortMembers(List<Member> members) => [...members]
  ..sort((a, b) {
    final byRole = b.role.rank.compareTo(a.role.rank);
    if (byRole != 0) return byRole;
    return a.displayName.toLowerCase().compareTo(b.displayName.toLowerCase());
  });

/// Nombre d'admins : un atelier doit toujours en garder au moins un.
int adminCount(List<Member> members) => members.where((m) => m.role == MemberRole.admin).length;

/// Vrai si ce changement de rôle (ou ce retrait, `newRole == null`) laisserait l'atelier sans admin.
bool wouldLeaveNoAdmin(List<Member> members, Member target, MemberRole? newRole) =>
    target.role == MemberRole.admin && newRole != MemberRole.admin && adminCount(members) <= 1;
