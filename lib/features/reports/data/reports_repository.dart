import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/supabase.dart';
import '../../auth/data/auth_repository.dart';
import '../../session/data/user_space_repository.dart';
import '../domain/error_report.dart';

class ReportsRepository {
  ReportsRepository(this._client);

  final SupabaseClient _client;

  Future<T> _guard<T>(Future<T> Function() action) async {
    try {
      return await action();
    } catch (e) {
      throw AuthError.from(e);
    }
  }

  /// Atelier : signaler une erreur sur la référence liée à une matière.
  Future<void> create({
    required String materialId,
    required ReportField field,
    required String observedValue,
    String? comment,
    bool shareIdentity = false,
  }) =>
      _guard(() => _client.rpc<dynamic>('create_error_report', params: {
            'p_material': materialId,
            'p_field': field.name,
            'p_observed': observedValue,
            'p_comment': comment,
            'p_share_identity': shareIdentity,
          }));

  /// Atelier : signalements d'une matière, du plus récent au plus ancien.
  Future<List<ErrorReport>> forMaterial(String materialId) => _guard(() async {
        final rows = await _client
            .from('error_reports')
            .select(ErrorReport.selectColumns)
            .eq('material_id', materialId)
            .order('created_at', ascending: false);
        return rows.map(ErrorReport.fromJson).toList();
      });

  /// Fournisseur : signalements reçus, ouverts d'abord.
  Future<List<SupplierErrorReport>> forSupplier(String orgId) => _guard(() async {
        final rows = await _client.rpc<List<dynamic>>('supplier_error_reports', params: {'p_org': orgId});
        return rows.cast<Map<String, dynamic>>().map(SupplierErrorReport.fromJson).toList();
      });

  /// Fournisseur : « Corrigé » (message facultatif) ou « Rejeté » (motif obligatoire).
  Future<void> resolve(String reportId, ReportStatus status, String? response) => _guard(
        () => _client.rpc<dynamic>('resolve_error_report', params: {
          'p_report': reportId,
          'p_status': status.name,
          'p_response': response,
        }),
      );

  Future<List<AppNotification>> notifications() => _guard(() async {
        final rows = await _client
            .from('notifications')
            .select(AppNotification.selectColumns)
            .order('created_at', ascending: false)
            .limit(100);
        return rows.map(AppNotification.fromJson).toList();
      });

  Future<void> markAllRead() => _guard(
        () => _client
            .from('notifications')
            .update({'read_at': DateTime.now().toUtc().toIso8601String()})
            .isFilter('read_at', null),
      );

  /// Abonnement en temps réel aux notifications de l'utilisateur. [onChange] est appelé à
  /// chaque notification créée ou modifiée, et au retour de la connexion après une coupure.
  /// Renvoie la fonction qui met fin à l'abonnement.
  void Function() watchNotifications(String userId, {required void Function() onChange}) {
    var connectedOnce = false;
    final channel = _client
        .channel('notifications:$userId')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'notifications',
          filter: PostgresChangeFilter(type: PostgresChangeFilterType.eq, column: 'user_id', value: userId),
          callback: (_) => onChange(),
        )
        .subscribe((status, [_]) {
      if (status != RealtimeSubscribeStatus.subscribed) return;
      // Reconnexion : des notifications ont pu arriver pendant la coupure.
      if (connectedOnce) onChange();
      connectedOnce = true;
    });
    return () => _client.removeChannel(channel);
  }
}

final reportsRepositoryProvider = Provider<ReportsRepository>(
  (ref) => ReportsRepository(ref.watch(supabaseProvider)),
);

final materialReportsProvider = FutureProvider.family<List<ErrorReport>, String>(
  (ref, materialId) => ref.watch(reportsRepositoryProvider).forMaterial(materialId),
);

final supplierReportsProvider = FutureProvider<List<SupplierErrorReport>>((ref) async {
  final orgId = ref.watch(userSpaceProvider).value?.membership?.organization.id;
  if (orgId == null) return const [];
  return ref.watch(reportsRepositoryProvider).forSupplier(orgId);
});

/// Intervalle de relecture des notifications tant que l'app est ouverte.
const kNotificationsRefresh = Duration(minutes: 5);

/// Abonnement en temps réel : chaque notification reçue relit la liste de la cloche.
final notificationsLiveProvider = Provider<void>((ref) {
  final userId = ref.watch(userSpaceProvider.select((s) => s.value?.profile.id));
  if (userId == null) return;
  try {
    final stop = ref.read(reportsRepositoryProvider).watchNotifications(
          userId,
          onChange: () => ref.invalidate(notificationsProvider),
        );
    ref.onDispose(stop);
  } catch (_) {
    // Temps réel indisponible : la relecture de secours (toutes les 5 minutes) prend le relais.
  }
});

final notificationsProvider = FutureProvider<List<AppNotification>>((ref) async {
  // Rechargées à chaque changement d'espace (connexion, organisation)…
  final space = ref.watch(userSpaceProvider).value;
  if (space?.membership == null) return const [];
  final list = await ref.watch(reportsRepositoryProvider).notifications();
  // … dès qu'une notification arrive (temps réel, voir notificationsLiveProvider)
  // et, en secours si le temps réel est coupé, toutes les 5 minutes.
  final timer = Timer(kNotificationsRefresh, ref.invalidateSelf);
  ref.onDispose(timer.cancel);
  return list;
});

/// Non lues : la cloche garde l'abonnement en temps réel actif.
final unreadNotificationsProvider = Provider<int>((ref) {
  ref.watch(notificationsLiveProvider);
  return (ref.watch(notificationsProvider).value ?? const []).where((n) => n.unread).length;
});
