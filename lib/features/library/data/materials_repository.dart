import 'dart:math';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/supabase.dart';
import '../../auth/data/auth_repository.dart';
import '../../members/data/members_repository.dart';
import '../../session/data/user_space_repository.dart';
import '../../session/domain/user_space.dart';
import '../domain/material.dart';

const _bucket = 'material-photos';
const _select = 'id, org_id, name, supplier_name, supplier_code, color_name, color_hex, '
    'photo_path, atelier_stock_m, notes, updated_at, '
    'textile_specs(composition, weight_gsm, width_cm, weave, care, certifications, uses)';

class MaterialsRepository {
  MaterialsRepository(this._client);

  final SupabaseClient _client;

  Future<T> _guard<T>(Future<T> Function() action) async {
    try {
      return await action();
    } catch (e) {
      throw AuthError.from(e);
    }
  }

  Future<List<MaterialItem>> list(String orgId) => _guard(() async {
        final rows = await _client
            .from('materials')
            .select(_select)
            .eq('org_id', orgId)
            .order('updated_at', ascending: false);
        return rows.map(MaterialItem.fromJson).toList();
      });

  Future<MaterialItem?> get(String id) => _guard(() async {
        final row = await _client.from('materials').select(_select).eq('id', id).maybeSingle();
        return row == null ? null : MaterialItem.fromJson(row);
      });

  /// Création ou modification atomique ; renvoie l'identifiant de la matière.
  Future<String> save(MaterialDraft draft) => _guard(() async {
        final id = await _client.rpc<String>(
          'save_textile_material',
          params: {'payload': draft.toPayload()},
        );
        return id;
      });

  Future<void> updateStock(String id, double? meters) => _guard(
        () => _client.from('materials').update({'atelier_stock_m': meters}).eq('id', id),
      );

  Future<void> delete(MaterialItem material) => _guard(() async {
        await _client.from('materials').delete().eq('id', material.id);
        final photo = material.photoPath;
        if (photo != null) await _client.storage.from(_bucket).remove([photo]);
      });

  /// Envoie une photo dans le dossier de l'organisation et renvoie son chemin.
  Future<String> uploadPhoto(String orgId, Uint8List bytes, String contentType) => _guard(() async {
        final ext = switch (contentType) { 'image/png' => 'png', 'image/webp' => 'webp', _ => 'jpg' };
        final stamp = DateTime.now().microsecondsSinceEpoch.toRadixString(36);
        final salt = Random.secure().nextInt(1 << 32).toRadixString(36);
        final path = '$orgId/$stamp$salt.$ext';
        await _client.storage.from(_bucket).uploadBinary(
              path,
              bytes,
              fileOptions: FileOptions(contentType: contentType, upsert: false),
            );
        return path;
      });

  Future<void> removePhoto(String path) =>
      _guard(() => _client.storage.from(_bucket).remove([path]));

  /// Lien temporaire (1 h) vers une photo du bucket privé.
  Future<String> photoUrl(String path) =>
      _guard(() => _client.storage.from(_bucket).createSignedUrl(path, 3600));
}

final materialsRepositoryProvider = Provider<MaterialsRepository>(
  (ref) => MaterialsRepository(ref.watch(supabaseProvider)),
);

/// Vrai si l'utilisateur peut créer et modifier des matières (Éditeur ou Admin).
final canEditMaterialsProvider = Provider<bool>(
  (ref) => ref.watch(currentRoleProvider)?.atLeast(MemberRole.editor) ?? false,
);

/// Matières de l'atelier de l'utilisateur connecté, les plus récentes d'abord.
final materialsProvider = FutureProvider<List<MaterialItem>>((ref) async {
  final orgId = ref.watch(userSpaceProvider).value?.membership?.organization.id;
  if (orgId == null) return const [];
  return ref.watch(materialsRepositoryProvider).list(orgId);
});

final materialProvider = FutureProvider.family<MaterialItem?, String>(
  (ref, id) => ref.watch(materialsRepositoryProvider).get(id),
);

final photoUrlProvider = FutureProvider.family<String, String>(
  (ref, path) => ref.watch(materialsRepositoryProvider).photoUrl(path),
);
