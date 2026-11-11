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

final notificationsProvider = FutureProvider<List<AppNotification>>((ref) async {
  // Rechargées à chaque changement d'espace (connexion, organisation).
  final space = ref.watch(userSpaceProvider).value;
  if (space?.membership == null) return const [];
  return ref.watch(reportsRepositoryProvider).notifications();
});

final unreadNotificationsProvider = Provider<int>(
  (ref) => (ref.watch(notificationsProvider).value ?? const []).where((n) => n.unread).length,
);
