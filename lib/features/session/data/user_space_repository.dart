import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/supabase.dart';
import '../domain/user_space.dart';

class UserSpaceRepository {
  UserSpaceRepository(this._client);

  final SupabaseClient _client;

  Future<UserSpace> load(String userId) async {
    final profileRow = await _client
        .from('profiles')
        .select('id, email, full_name, locale, is_superadmin')
        .eq('id', userId)
        .single();
    final membershipRow = await _client
        .from('memberships')
        .select('role, organizations(id, name, kind)')
        .eq('user_id', userId)
        .maybeSingle();

    Membership? membership;
    if (membershipRow != null && membershipRow['organizations'] != null) {
      membership = Membership(
        organization: Organization.fromJson(membershipRow['organizations'] as Map<String, dynamic>),
        role: MemberRole.parse(membershipRow['role'] as String),
      );
    }
    return UserSpace(profile: Profile.fromJson(profileRow), membership: membership);
  }

  Future<void> updateLocale(String userId, String locale) =>
      _client.from('profiles').update({'locale': locale}).eq('id', userId);
}

final userSpaceRepositoryProvider = Provider<UserSpaceRepository>(
  (ref) => UserSpaceRepository(ref.watch(supabaseProvider)),
);

/// Espace de l'utilisateur connecté ; `null` hors connexion.
final userSpaceProvider = FutureProvider<UserSpace?>((ref) async {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) return null;
  return ref.watch(userSpaceRepositoryProvider).load(userId);
});
