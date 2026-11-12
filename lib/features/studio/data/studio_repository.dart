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

  Future<void> updateModel(String id, {String? name, String? reference, double? wastePct}) => _guard(
        () => _client.from('models').update({
          'name': ?name?.trim(),
          if (reference != null) 'reference': reference.trim().isEmpty ? null : reference.trim(),
          'waste_pct': ?wastePct,
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

  Future<void> updateColorway(String id, {String? name, int? quantity}) => _guard(
        () => _client.from('colorways').update({
          if (name != null) 'name': name.trim().isEmpty ? null : name.trim(),
          'quantity': ?quantity,
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

  Future<void> updateLine(String id, {double? consumption, String? role}) => _guard(
        () => _client.from('model_materials').update({
          'consumption': ?consumption,
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

/// Accès aux fonctionnalités Pro : relu à chaque ouverture d'écran, pour qu'un
/// changement d'offre fait par le super-admin s'applique sans reconnexion.
final hasProProvider = FutureProvider.autoDispose<bool>((ref) async {
  final orgId = _orgId(ref);
  if (orgId == null) return false;
  return ref.watch(studioRepositoryProvider).hasPro(orgId);
});

/// Mêmes droits que TissuTech : les Éditeurs modifient, les Lecteurs consultent.
final canEditStudioProvider = Provider<bool>((ref) => ref.watch(canEditMaterialsProvider));
