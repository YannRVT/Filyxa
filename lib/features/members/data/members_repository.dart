import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/supabase.dart';
import '../../auth/data/auth_repository.dart';
import '../../session/data/user_space_repository.dart';
import '../../session/domain/user_space.dart';
import '../domain/member.dart';

class MembersRepository {
  MembersRepository(this._client);

  final SupabaseClient _client;

  Future<T> _guard<T>(Future<T> Function() action) async {
    try {
      return await action();
    } catch (e) {
      throw AuthError.from(e);
    }
  }

  Future<List<Member>> listMembers(String orgId) => _guard(() async {
        final memberships = await _client
            .from('memberships')
            .select('user_id, role, created_at')
            .eq('org_id', orgId);
        if (memberships.isEmpty) return const [];
        final ids = memberships.map((m) => m['user_id'] as String).toList();
        final profiles = await _client
            .from('profiles')
            .select('id, email, full_name')
            .inFilter('id', ids);
        final byId = {for (final p in profiles) p['id'] as String: p};
        return sortMembers([
          for (final m in memberships)
            Member(
              userId: m['user_id'] as String,
              email: byId[m['user_id']]?['email'] as String? ?? '',
              fullName: byId[m['user_id']]?['full_name'] as String?,
              role: MemberRole.parse(m['role'] as String),
              joinedAt: DateTime.parse(m['created_at'] as String).toLocal(),
            ),
        ]);
      });

  /// Invitations en attente (ni acceptées ni annulées) ; lisibles par les admins uniquement.
  Future<List<Invitation>> listPendingInvitations(String orgId) => _guard(() async {
        final rows = await _client
            .from('invitations')
            .select('id, email, role, expires_at')
            .eq('org_id', orgId)
            .isFilter('accepted_at', null)
            .isFilter('revoked_at', null)
            .order('created_at', ascending: false);
        return [
          for (final r in rows)
            Invitation(
              id: r['id'] as String,
              email: r['email'] as String,
              role: MemberRole.parse(r['role'] as String),
              expiresAt: DateTime.parse(r['expires_at'] as String).toLocal(),
            ),
        ];
      });

  Future<void> _call(Map<String, dynamic> body) =>
      _guard(() => _client.functions.invoke('admin-users', body: body));

  Future<void> invite(String orgId, String email, MemberRole role) =>
      _call({'action': 'invite', 'orgId': orgId, 'email': email, 'role': role.name});

  Future<void> setRole(String orgId, String userId, MemberRole role) =>
      _call({'action': 'set_role', 'orgId': orgId, 'userId': userId, 'role': role.name});

  Future<void> remove(String orgId, String userId) =>
      _call({'action': 'remove_member', 'orgId': orgId, 'userId': userId});

  Future<void> revokeInvitation(String invitationId) =>
      _call({'action': 'revoke_invitation', 'invitationId': invitationId});
}

final membersRepositoryProvider = Provider<MembersRepository>(
  (ref) => MembersRepository(ref.watch(supabaseProvider)),
);

/// Rôle de l'utilisateur connecté dans son organisation (`null` sans organisation).
final currentRoleProvider = Provider<MemberRole?>(
  (ref) => ref.watch(userSpaceProvider).value?.membership?.role,
);

/// Membres et invitations de l'organisation de l'utilisateur connecté.
final membersProvider = FutureProvider<MembersOverview>((ref) async {
  final membership = ref.watch(userSpaceProvider).value?.membership;
  if (membership == null) return const MembersOverview(members: [], invitations: []);
  final repo = ref.watch(membersRepositoryProvider);
  final orgId = membership.organization.id;
  final isAdmin = membership.role == MemberRole.admin;
  final results = await Future.wait([
    repo.listMembers(orgId),
    if (isAdmin) repo.listPendingInvitations(orgId),
  ]);
  return MembersOverview(
    members: results[0] as List<Member>,
    invitations: isAdmin ? results[1] as List<Invitation> : const [],
  );
});
