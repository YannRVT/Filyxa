import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/supabase.dart';
import '../../auth/data/auth_repository.dart';
import '../../session/domain/user_space.dart';

class PendingInvitation {
  const PendingInvitation({required this.email, required this.expiresAt});

  final String email;
  final DateTime expiresAt;

  bool get isExpired => expiresAt.isBefore(DateTime.now());
}

class AdminOrganization {
  const AdminOrganization({
    required this.organization,
    required this.memberCount,
    required this.createdAt,
    this.pendingInvitation,
  });

  final Organization organization;
  final int memberCount;
  final DateTime createdAt;

  /// Dernière invitation ni acceptée ni révoquée, s'il y en a une.
  final PendingInvitation? pendingInvitation;

  factory AdminOrganization.fromJson(Map<String, dynamic> json) {
    final counts = json['memberships'] as List<dynamic>? ?? const [];
    final invitations = (json['invitations'] as List<dynamic>? ?? const [])
        .cast<Map<String, dynamic>>()
        .where((i) => i['accepted_at'] == null && i['revoked_at'] == null)
        .map((i) => PendingInvitation(
              email: i['email'] as String,
              expiresAt: DateTime.parse(i['expires_at'] as String).toLocal(),
            ))
        .toList()
      ..sort((a, b) => b.expiresAt.compareTo(a.expiresAt));
    return AdminOrganization(
      organization: Organization.fromJson(json),
      memberCount: counts.isEmpty ? 0 : (counts.first as Map<String, dynamic>)['count'] as int,
      createdAt: DateTime.parse(json['created_at'] as String).toLocal(),
      pendingInvitation: invitations.isEmpty ? null : invitations.first,
    );
  }
}

class AdminRepository {
  AdminRepository(this._client);

  final SupabaseClient _client;

  Future<T> _guard<T>(Future<T> Function() action) async {
    try {
      return await action();
    } catch (e) {
      throw AuthError.from(e);
    }
  }

  Future<List<AdminOrganization>> listOrganizations() => _guard(() async {
        final rows = await _client
            .from('organizations')
            .select('id, name, kind, created_at, memberships(count), '
                'invitations(email, expires_at, accepted_at, revoked_at)')
            .order('created_at', ascending: false);
        return rows.map(AdminOrganization.fromJson).toList();
      });

  Future<Map<String, dynamic>> _call(Map<String, dynamic> body) async {
    final response = await _client.functions.invoke('admin-users', body: body);
    return (response.data as Map).cast<String, dynamic>();
  }

  /// Crée l'atelier puis invite son premier admin. Si l'invitation échoue,
  /// l'atelier existe : l'invitation peut être renvoyée depuis la console.
  Future<void> createAtelierWithAdmin({required String name, required String adminEmail}) =>
      _guard(() async {
        final created = await _call({
          'action': 'create_organization',
          'name': name,
          'kind': OrgKind.atelier.name,
        });
        final orgId = (created['organization'] as Map)['id'] as String;
        await _call({
          'action': 'invite',
          'orgId': orgId,
          'email': adminEmail,
          'role': MemberRole.admin.name,
        });
      });

  Future<void> invite({required String orgId, required String email, required MemberRole role}) =>
      _guard(() => _call({'action': 'invite', 'orgId': orgId, 'email': email, 'role': role.name}));
}

final adminRepositoryProvider = Provider<AdminRepository>(
  (ref) => AdminRepository(ref.watch(supabaseProvider)),
);

final adminOrganizationsProvider = FutureProvider<List<AdminOrganization>>(
  (ref) => ref.watch(adminRepositoryProvider).listOrganizations(),
);
