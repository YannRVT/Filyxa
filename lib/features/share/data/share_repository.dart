import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/env.dart';
import '../../../core/supabase.dart';
import '../../auth/data/auth_repository.dart';
import '../../session/data/user_space_repository.dart';

/// Ce que partage un lien.
enum ShareScope {
  material,
  model,
  collection;

  static ShareScope parse(String? v) => values.firstWhere((s) => s.name == v, orElse: () => material);
}

/// Validité par défaut d'un lien (jours).
const kShareDefaultDays = 30;

/// Adresse publique d'un lien : PUBLIC_URL (env.json), sinon l'adresse de l'app web.
String shareUrl(String token) {
  final base = Env.publicUrl.isNotEmpty ? Env.publicUrl : (kIsWeb ? Uri.base.origin : 'https://app.filyxa.com');
  return '${base.replaceFirst(RegExp(r'/$'), '')}/s/$token';
}

class ShareLink {
  const ShareLink({
    required this.id,
    required this.token,
    required this.scope,
    required this.targetId,
    required this.lang,
    required this.expiresAt,
    required this.createdAt,
    this.revokedAt,
  });

  factory ShareLink.fromJson(Map<String, dynamic> json) => ShareLink(
        id: json['id'] as String,
        token: json['token'] as String,
        scope: ShareScope.parse(json['scope'] as String?),
        targetId: json['target_id'] as String,
        lang: json['lang'] as String,
        expiresAt: DateTime.parse(json['expires_at'] as String).toLocal(),
        createdAt: DateTime.parse(json['created_at'] as String).toLocal(),
        revokedAt: json['revoked_at'] == null ? null : DateTime.parse(json['revoked_at'] as String).toLocal(),
      );

  static const selectColumns = 'id, token, scope, target_id, lang, expires_at, created_at, revoked_at';

  final String id;
  final String token;
  final ShareScope scope;
  final String targetId;
  final String lang;
  final DateTime expiresAt;
  final DateTime createdAt;
  final DateTime? revokedAt;

  bool isActive(DateTime now) => revokedAt == null && expiresAt.isAfter(now);
  String get url => shareUrl(token);
}

/// Réponse de share_view : statut du lien et contenu public.
class SharedView {
  const SharedView({required this.status, this.lang, this.scope, this.expiresAt, this.organization, this.content = const {}});

  factory SharedView.fromJson(Map<String, dynamic> json) => SharedView(
        status: json['status'] as String,
        lang: json['lang'] as String?,
        scope: json['scope'] == null ? null : ShareScope.parse(json['scope'] as String),
        expiresAt: json['expires_at'] == null ? null : DateTime.parse(json['expires_at'] as String).toLocal(),
        organization: json['organization'] as String?,
        content: (json['content'] as Map<String, dynamic>?) ?? const {},
      );

  /// ok · expired · revoked · not_found
  final String status;
  final String? lang;
  final ShareScope? scope;
  final DateTime? expiresAt;
  final String? organization;
  final Map<String, dynamic> content;
}

class ShareRepository {
  ShareRepository(this._client);

  final SupabaseClient _client;

  Future<T> _guard<T>(Future<T> Function() action) async {
    try {
      return await action();
    } catch (e) {
      throw AuthError.from(e);
    }
  }

  Future<List<ShareLink>> list(String orgId) => _guard(() async {
        final rows = await _client
            .from('share_links')
            .select(ShareLink.selectColumns)
            .eq('org_id', orgId)
            .order('created_at', ascending: false);
        return rows.map(ShareLink.fromJson).toList();
      });

  Future<ShareLink> create(String orgId, ShareScope scope, String targetId, {required String lang, required int days}) =>
      _guard(() async {
        final row = await _client
            .from('share_links')
            .insert({
              'org_id': orgId,
              'scope': scope.name,
              'target_id': targetId,
              'lang': lang,
              'expires_at': DateTime.now().add(Duration(days: days)).toUtc().toIso8601String(),
            })
            .select(ShareLink.selectColumns)
            .single();
        return ShareLink.fromJson(row);
      });

  Future<void> setExpiry(String id, DateTime expiresAt) =>
      _guard(() => _client.from('share_links').update({'expires_at': expiresAt.toUtc().toIso8601String()}).eq('id', id));

  Future<void> revoke(String id) =>
      _guard(() => _client.from('share_links').update({'revoked_at': DateTime.now().toUtc().toIso8601String()}).eq('id', id));

  /// Page publique (sans compte).
  Future<SharedView> view(String token) => _guard(() async {
        final json = await _client.rpc<Map<String, dynamic>>('share_view', params: {'p_token': token});
        return SharedView.fromJson(json);
      });
}

final shareRepositoryProvider = Provider<ShareRepository>((ref) => ShareRepository(ref.watch(supabaseProvider)));

/// Tous les liens de l'atelier (actifs et passés), du plus récent au plus ancien.
final shareLinksProvider = FutureProvider<List<ShareLink>>((ref) async {
  final orgId = ref.watch(userSpaceProvider).value?.membership?.organization.id;
  if (orgId == null) return const [];
  return ref.watch(shareRepositoryProvider).list(orgId);
});

/// Liens actifs d'un élément, le plus récent d'abord.
final targetLinksProvider = Provider.family<List<ShareLink>, (ShareScope, String)>((ref, target) {
  final now = DateTime.now();
  return [
    for (final l in ref.watch(shareLinksProvider).value ?? const <ShareLink>[])
      if (l.scope == target.$1 && l.targetId == target.$2 && l.isActive(now)) l,
  ];
});

final sharedViewProvider = FutureProvider.autoDispose.family<SharedView, String>(
  (ref, token) => ref.watch(shareRepositoryProvider).view(token),
);
