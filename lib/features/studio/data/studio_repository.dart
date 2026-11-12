import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/supabase.dart';
import '../../auth/data/auth_repository.dart';
import '../../library/data/materials_repository.dart' show canEditMaterialsProvider;
import '../../session/data/user_space_repository.dart';
import '../domain/studio.dart';

class StudioRepository {
  StudioRepository(this._client);

  final SupabaseClient _client;

  Future<T> _guard<T>(Future<T> Function() action) async {
    try {
      return await action();
    } catch (e) {
      throw AuthError.from(e);
    }
  }

  // Collections -------------------------------------------------------------------------------

  Future<List<StudioCollection>> collections(String orgId) => _guard(() async {
        final rows = await _client
            .from('collections')
            .select(StudioCollection.selectColumns)
            .eq('org_id', orgId)
            .order('updated_at', ascending: false);
        return rows.map(StudioCollection.fromJson).toList();
      });

  Future<StudioCollection?> collection(String id) => _guard(() async {
        final row = await _client.from('collections').select(StudioCollection.selectColumns).eq('id', id).maybeSingle();
        return row == null ? null : StudioCollection.fromJson(row);
      });

  Future<String> createCollection(String orgId, String name) => _guard(() async {
        final row = await _client.from('collections').insert({'org_id': orgId, 'name': name.trim()}).select('id').single();
        return row['id'] as String;
      });

  Future<void> renameCollection(String id, String name) =>
      _guard(() => _client.from('collections').update({'name': name.trim()}).eq('id', id));

  Future<void> deleteCollection(String id) => _guard(() => _client.from('collections').delete().eq('id', id));

  // Modèles -------------------------------------------------------------------------------------

  Future<List<StudioModel>> models(String collectionId) => _guard(() async {
        final rows = await _client
            .from('models')
            .select(StudioModel.selectColumns)
            .eq('collection_id', collectionId)
            .order('created_at');
        return rows.map(StudioModel.fromJson).toList();
      });

  Future<StudioModel?> model(String id) => _guard(() async {
        final row = await _client.from('models').select(StudioModel.selectColumns).eq('id', id).maybeSingle();
        return row == null ? null : StudioModel.fromJson(row);
      });

  Future<String> createModel(String collectionId, {required String name, required ProductType type, String? reference}) =>
      _guard(() async {
        final row = await _client
            .from('models')
            .insert({
              'collection_id': collectionId,
              'name': name.trim(),
              'product_type': type.code,
              'reference': (reference ?? '').trim().isEmpty ? null : reference!.trim(),
            })
            .select('id')
            .single();
        return row['id'] as String;
      });

  Future<void> updateModel(String id, {String? name, String? reference, double? wastePct, int? prototypeCount}) => _guard(
        () => _client.from('models').update({
          'name': ?name?.trim(),
          if (reference != null) 'reference': reference.trim().isEmpty ? null : reference.trim(),
          'waste_pct': ?wastePct,
          'prototype_count': ?prototypeCount,
        }).eq('id', id),
      );

  /// Changement de statut (offre Pro, contrôlé par le serveur).
  Future<void> setStatus(String id, ModelStatus status) =>
      _guard(() => _client.from('models').update({'status': status.code}).eq('id', id));

  /// Fixe (ou efface, si [date] est null) l'échéance d'une étape.
  Future<void> setDeadline(String modelId, ModelStatus stage, DateTime? date) => _guard(() async {
        if (date == null) {
          await _client.from('model_deadlines').delete().eq('model_id', modelId).eq('stage', stage.code);
        } else {
          final day = '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
          await _client
              .from('model_deadlines')
              .upsert({'model_id': modelId, 'stage': stage.code, 'due_date': day}, onConflict: 'model_id,stage');
        }
      });

  // Tailles ------------------------------------------------------------------------------------

  /// Grilles fournies par Filyxa puis grilles de l'atelier.
  Future<List<SizeChart>> sizeCharts() => _guard(() async {
        final rows = await _client
            .from('size_charts')
            .select(SizeChart.selectColumns)
            .order('org_id', nullsFirst: true)
            .order('position')
            .order('created_at');
        return rows.map(SizeChart.fromJson).toList();
      });

  Future<void> createSizeChart(String orgId, String name, List<String> sizes) => _guard(() async {
        final last = await _client.from('size_charts').select('position').eq('org_id', orgId).order('position', ascending: false).limit(1);
        await _client.from('size_charts').insert({
          'org_id': orgId,
          'name': name.trim(),
          'sizes': sizes,
          'position': last.isEmpty ? 0 : (last.first['position'] as int) + 1,
        });
      });

  Future<void> updateSizeChart(String id, String name, List<String> sizes) =>
      _guard(() => _client.from('size_charts').update({'name': name.trim(), 'sizes': sizes}).eq('id', id));

  Future<void> deleteSizeChart(String id) => _guard(() => _client.from('size_charts').delete().eq('id', id));

  /// Choisit (ou retire) la grille d'un modèle ; le serveur efface les quantités devenues sans objet.
  Future<void> setModelSizeChart(String modelId, String? chartId) =>
      _guard(() => _client.from('models').update({'size_chart_id': chartId}).eq('id', modelId));

  Future<void> updateGrading(String modelId, {String? baseSize, double? gradePct}) => _guard(() => _client
      .from('models')
      .update({'base_size': ?baseSize, 'grade_pct': ?gradePct}).eq('id', modelId));

  /// Écart propre à une taille ; null : retour à l'écart du modèle.
  Future<void> setSizeGrade(String modelId, String size, double? gradePct) => _guard(() async {
        if (gradePct == null) {
          await _client.from('model_size_grades').delete().eq('model_id', modelId).eq('size', size);
        } else {
          await _client
              .from('model_size_grades')
              .upsert({'model_id': modelId, 'size': size, 'grade_pct': gradePct}, onConflict: 'model_id,size');
        }
      });

  Future<void> setSizeQuantity(String colorwayId, String size, int quantity) => _guard(() => _client
      .from('colorway_size_quantities')
      .upsert({'colorway_id': colorwayId, 'size': size, 'quantity': quantity}, onConflict: 'colorway_id,size'));

  // Coûts ----------------------------------------------------------------------------------------

  Map<String, dynamic> _costRow(CostLine c) => {
        'kind': c.kind.name,
        'label': c.label.trim(),
        'unit_price': c.unitPrice,
        'quantity': c.quantity,
        'per': c.perModel ? 'model' : 'piece',
      };

  Future<void> addCost(String modelId, CostLine line) =>
      _guard(() => _client.from('model_costs').insert({..._costRow(line), 'model_id': modelId, 'position': line.position}));

  Future<void> updateCost(CostLine line) => _guard(() => _client.from('model_costs').update(_costRow(line)).eq('id', line.id));

  Future<void> deleteCost(String id) => _guard(() => _client.from('model_costs').delete().eq('id', id));

  /// Prix de vente visé ; null : effacé.
  Future<void> setTargetPrice(String modelId, double? price) => _guard(() async {
        if (price == null) {
          await _client.from('model_prices').delete().eq('model_id', modelId);
        } else {
          await _client.from('model_prices').upsert({'model_id': modelId, 'target_price': price}, onConflict: 'model_id');
        }
      });

  Future<double> minCoefficient(String orgId) => _guard(() async {
        final row = await _client.from('organizations').select('min_coefficient').eq('id', orgId).maybeSingle();
        return (row?['min_coefficient'] as num?)?.toDouble() ?? kDefaultMinCoefficient;
      });

  Future<void> setMinCoefficient(String orgId, double value) =>
      _guard(() => _client.rpc<void>('set_min_coefficient', params: {'p_org': orgId, 'p_value': value}));

  // Réservations ---------------------------------------------------------------------------------

  List<Map<String, dynamic>> _lines(Map<String, double> meters) => [
        for (final e in meters.entries) {'material_id': e.key, 'meters': double.parse(e.value.toStringAsFixed(3))},
      ];

  /// Réserve les mètres confirmés et passe le modèle « En production ».
  Future<void> startProduction(String modelId, Map<String, double> meters) =>
      _guard(() => _client.rpc<void>('start_production', params: {'p_model': modelId, 'p_lines': _lines(meters)}));

  /// Déduit les mètres consommés du stock atelier et passe le modèle « Livré ».
  Future<void> deliverModel(String modelId, Map<String, double> meters) =>
      _guard(() => _client.rpc<void>('deliver_model', params: {'p_model': modelId, 'p_lines': _lines(meters)}));

  Future<List<StockReservation>> reservations({String? modelId, Iterable<String>? materialIds}) => _guard(() async {
        var query = _client.from('stock_reservations').select(StockReservation.selectColumns);
        if (modelId != null) query = query.eq('model_id', modelId);
        if (materialIds != null) query = query.inFilter('material_id', materialIds.toList());
        final rows = await query;
        return rows.map(StockReservation.fromJson).toList();
      });

  /// Vrai si l'organisation a accès aux fonctionnalités Pro (relu à chaque ouverture d'écran).
  Future<bool> hasPro(String orgId) => _guard(() async {
        final result = await _client.rpc<bool>('has_pro', params: {'p_org': orgId});
        return result;
      });

  Future<void> deleteModel(String id) => _guard(() => _client.from('models').delete().eq('id', id));

  // Coloris -------------------------------------------------------------------------------------

  /// Nouveau coloris ; [copyFrom] recopie la nomenclature d'un coloris existant.
  Future<String> addColorway(String modelId, String name, {String? copyFrom}) => _guard(() async {
        final id = await _client.rpc<String>('add_colorway', params: {
          'p_model': modelId,
          'p_name': name,
          'p_copy_from': copyFrom,
        });
        return id;
      });

  Future<void> updateColorway(String id, {String? name, int? quantity, String? colorHex}) => _guard(
        () => _client.from('colorways').update({
          if (name != null) 'name': name.trim().isEmpty ? null : name.trim(),
          'quantity': ?quantity,
          'color_hex': ?colorHex,
        }).eq('id', id),
      );

  Future<void> deleteColorway(String id) => _guard(() => _client.from('colorways').delete().eq('id', id));

  // Nomenclature --------------------------------------------------------------------------------

  Future<void> addLine(String colorwayId, {required String materialId, required String role, required double consumption}) =>
      _guard(() async {
        final last = await _client
            .from('model_materials')
            .select('position')
            .eq('colorway_id', colorwayId)
            .order('position', ascending: false)
            .limit(1);
        final position = last.isEmpty ? 0 : (last.first['position'] as int) + 1;
        await _client.from('model_materials').insert({
          'colorway_id': colorwayId,
          'material_id': materialId,
          'role': role.trim(),
          'consumption': consumption,
          'position': position,
        });
      });

  Future<void> updateLine(String id, {double? consumption, String? role, double? protoLossPct}) => _guard(
        () => _client.from('model_materials').update({
          'consumption': ?consumption,
          'proto_loss_pct': ?protoLossPct,
          if (role != null) 'role': role.trim(),
        }).eq('id', id),
      );

  Future<void> deleteLine(String id) => _guard(() => _client.from('model_materials').delete().eq('id', id));

  /// Rôles libres déjà utilisés par l'atelier (proposés à nouveau).
  Future<List<String>> customRoles(String orgId) => _guard(() async {
        final rows = await _client.from('model_materials').select('role').eq('org_id', orgId).limit(1000);
        final roles = {for (final r in rows) r['role'] as String}..removeAll(builtInRoles);
        return roles.toList()..sort();
      });
}

final studioRepositoryProvider = Provider<StudioRepository>(
  (ref) => StudioRepository(ref.watch(supabaseProvider)),
);

String? _orgId(Ref ref) => ref.watch(userSpaceProvider).value?.membership?.organization.id;

final collectionsProvider = FutureProvider<List<StudioCollection>>((ref) async {
  final orgId = _orgId(ref);
  if (orgId == null) return const [];
  return ref.watch(studioRepositoryProvider).collections(orgId);
});

final collectionProvider = FutureProvider.family<StudioCollection?, String>(
  (ref, id) => ref.watch(studioRepositoryProvider).collection(id),
);

final collectionModelsProvider = FutureProvider.family<List<StudioModel>, String>(
  (ref, collectionId) => ref.watch(studioRepositoryProvider).models(collectionId),
);

final modelProvider = FutureProvider.family<StudioModel?, String>(
  (ref, id) => ref.watch(studioRepositoryProvider).model(id),
);

final customRolesProvider = FutureProvider<List<String>>((ref) async {
  final orgId = _orgId(ref);
  if (orgId == null) return const [];
  return ref.watch(studioRepositoryProvider).customRoles(orgId);
});

/// Réservations qui pèsent sur une matière (fiche matière).
final materialReservationsProvider = FutureProvider.autoDispose.family<List<StockReservation>, String>(
  (ref, materialId) => ref.watch(studioRepositoryProvider).reservations(materialIds: [materialId]),
);

/// Coefficient minimal de l'atelier.
final minCoefficientProvider = FutureProvider.autoDispose<double>((ref) async {
  final orgId = _orgId(ref);
  if (orgId == null) return kDefaultMinCoefficient;
  return ref.watch(studioRepositoryProvider).minCoefficient(orgId);
});

final sizeChartsProvider = FutureProvider<List<SizeChart>>((ref) {
  ref.watch(userSpaceProvider);
  return ref.watch(studioRepositoryProvider).sizeCharts();
});

/// Accès aux fonctionnalités Pro : relu à chaque ouverture d'écran, pour qu'un
/// changement d'offre fait par le super-admin s'applique sans reconnexion.
final hasProProvider = FutureProvider.autoDispose<bool>((ref) async {
  final orgId = _orgId(ref);
  if (orgId == null) return false;
  return ref.watch(studioRepositoryProvider).hasPro(orgId);
});

/// Mêmes droits que TissuTech : les Éditeurs modifient, les Lecteurs consultent.
final canEditStudioProvider = Provider<bool>((ref) => ref.watch(canEditMaterialsProvider));
