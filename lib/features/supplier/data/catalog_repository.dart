import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/supabase.dart';
import '../../auth/data/auth_repository.dart';
import '../../session/data/user_space_repository.dart';
import '../domain/availability.dart';
import '../domain/supplier_reference.dart';

const kReferencesPageSize = 1000;
const kImportBatchSize = 500;

const _select = 'id, code, name, color_name, color_hex, composition, weight_gsm, width_cm, weave, '
    'care, certifications, uses, stock_m, lead_time_weeks, availability_mode, '
    'low_stock_threshold_m, retired_at, updated_at';

/// Résultat d'un import envoyé au serveur.
class ImportResult {
  const ImportResult({this.inserted = 0, this.updated = 0, this.serverErrors = const []});

  final int inserted;
  final int updated;

  /// Lignes refusées par le serveur : (numéro de ligne du fichier, message).
  final List<(int, String)> serverErrors;
}

class CatalogRepository {
  CatalogRepository(this._client);

  final SupabaseClient _client;

  Future<T> _guard<T>(Future<T> Function() action) async {
    try {
      return await action();
    } catch (e) {
      throw AuthError.from(e);
    }
  }

  /// Toutes les références du fournisseur (retirées comprises), par pages de 1 000.
  Future<List<SupplierReference>> list(String orgId) => _guard(() async {
        final all = <SupplierReference>[];
        for (var from = 0;; from += kReferencesPageSize) {
          final rows = await _client
              .from('supplier_references')
              .select(_select)
              .eq('supplier_org_id', orgId)
              .order('code')
              .range(from, from + kReferencesPageSize - 1);
          all.addAll(rows.map(SupplierReference.fromJson));
          if (rows.length < kReferencesPageSize) return all;
        }
      });

  Future<SupplierReference?> get(String id) => _guard(() async {
        final row = await _client.from('supplier_references').select(_select).eq('id', id).maybeSingle();
        return row == null ? null : SupplierReference.fromJson(row);
      });

  Future<SupplierSettings> settings(String orgId) => _guard(() async {
        final row = await _client
            .from('supplier_settings')
            .select('availability_mode, low_stock_threshold_m, import_mapping')
            .eq('org_id', orgId)
            .maybeSingle();
        return SupplierSettings.fromJson(row);
      });

  Future<void> saveSettings(String orgId, {AvailabilityMode? mode, double? thresholdM, Map<String, String>? mapping}) =>
      _guard(() async {
        final current = await settings(orgId);
        await _client.from('supplier_settings').upsert({
          'org_id': orgId,
          'availability_mode': (mode ?? current.mode).name,
          'low_stock_threshold_m': thresholdM ?? current.lowStockThresholdM,
          'import_mapping': mapping ?? current.importMapping,
        });
      });

  /// Envoie les lignes valides par lots ; [lines] donne le numéro de ligne du fichier
  /// de chaque payload, pour rapporter les refus du serveur.
  Future<ImportResult> importRows(
    String orgId,
    List<Map<String, dynamic>> payloads,
    List<int> lines, {
    void Function(int done, int total)? onProgress,
  }) =>
      _guard(() async {
        var inserted = 0, updated = 0;
        final errors = <(int, String)>[];
        for (var start = 0; start < payloads.length; start += kImportBatchSize) {
          final end = (start + kImportBatchSize).clamp(0, payloads.length);
          final result = await _client.rpc<Map<String, dynamic>>(
            'import_supplier_references',
            params: {'p_org': orgId, 'p_rows': payloads.sublist(start, end)},
          );
          inserted += result['inserted'] as int;
          updated += result['updated'] as int;
          for (final e in (result['errors'] as List<dynamic>).cast<Map<String, dynamic>>()) {
            errors.add((lines[start + (e['row'] as int) - 1], e['error'] as String));
          }
          onProgress?.call(end, payloads.length);
        }
        return ImportResult(inserted: inserted, updated: updated, serverErrors: errors);
      });

  /// Réglages propres à une référence : mode d'affichage, seuil, délai (null = réglage général).
  Future<void> updateAvailability(
    String id, {
    required AvailabilityMode? mode,
    required double? thresholdM,
    required int? leadTimeWeeks,
  }) =>
      _guard(() => _client.from('supplier_references').update({
            'availability_mode': mode?.name,
            'low_stock_threshold_m': thresholdM,
            'lead_time_weeks': leadTimeWeeks,
          }).eq('id', id));

  Future<void> setRetired(String id, bool retired) => _guard(() => _client
      .from('supplier_references')
      .update({'retired_at': retired ? DateTime.now().toUtc().toIso8601String() : null})
      .eq('id', id));
}

final catalogRepositoryProvider = Provider<CatalogRepository>(
  (ref) => CatalogRepository(ref.watch(supabaseProvider)),
);

String? _supplierOrgId(Ref ref) => ref.watch(userSpaceProvider).value?.membership?.organization.id;

final supplierReferencesProvider = FutureProvider<List<SupplierReference>>((ref) async {
  final orgId = _supplierOrgId(ref);
  if (orgId == null) return const [];
  return ref.watch(catalogRepositoryProvider).list(orgId);
});

final supplierReferenceProvider = FutureProvider.family<SupplierReference?, String>(
  (ref, id) => ref.watch(catalogRepositoryProvider).get(id),
);

final supplierSettingsProvider = FutureProvider<SupplierSettings>((ref) async {
  final orgId = _supplierOrgId(ref);
  if (orgId == null) return const SupplierSettings();
  return ref.watch(catalogRepositoryProvider).settings(orgId);
});
