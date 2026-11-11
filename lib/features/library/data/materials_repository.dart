import 'dart:math';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/supabase.dart';
import '../../auth/data/auth_repository.dart';
import '../../members/data/members_repository.dart';
import '../../session/data/user_space_repository.dart';
import '../../session/domain/user_space.dart';
import '../domain/catalog_reference.dart';
import '../domain/material.dart';

const _bucket = 'material-photos';

/// Lignes envoyées par appel au serveur lors d'un import atelier.
const kAtelierImportBatchSize = 250;

/// Bilan d'un import atelier.
class AtelierImportResult {
  const AtelierImportResult({
    this.inserted = 0,
    this.updated = 0,
    this.linked = 0,
    this.pending = 0,
    this.serverErrors = const [],
  });

  final int inserted;
  final int updated;

  /// Reliées automatiquement à une référence fournisseur.
  final int linked;

  /// Correspondances à confirmer.
  final int pending;

  /// (ligne du fichier, message) des lignes refusées par le serveur.
  final List<(int, String)> serverErrors;

  int get imported => inserted + updated;
}

/// Taille des pages de chargement (limite du serveur : 1 000 lignes).
const kMaterialsPageSize = 1000;
const _select = 'id, org_id, name, supplier_name, supplier_code, color_name, color_hex, '
    'photo_path, atelier_stock_m, notes, updated_at, supplier_reference_id, linked_at, price_per_m, tags, link_review, '
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

  /// Toutes les matières de l'atelier. Le serveur renvoie au plus 1 000 lignes
  /// par requête : on charge par pages jusqu'à la dernière.
  Future<List<MaterialItem>> list(String orgId) => _guard(() async {
        final all = <MaterialItem>[];
        for (var from = 0;; from += kMaterialsPageSize) {
          final rows = await _client
              .from('materials')
              .select(_select)
              .eq('org_id', orgId)
              .order('updated_at', ascending: false)
              .order('id')
              .range(from, from + kMaterialsPageSize - 1);
          all.addAll(rows.map(MaterialItem.fromJson));
          if (rows.length < kMaterialsPageSize) return all;
        }
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

  /// Références publiées, par identifiant (celles qui manquent ont été retirées).
  Future<Map<String, CatalogReference>> catalogReferences(Iterable<String> ids) => _guard(() async {
        final unique = ids.toSet().toList();
        final result = <String, CatalogReference>{};
        for (var i = 0; i < unique.length; i += 200) {
          final rows = await _client
              .from('supplier_catalog')
              .select(CatalogReference.selectColumns)
              .inFilter('id', unique.sublist(i, (i + 200).clamp(0, unique.length)));
          for (final r in rows) {
            final ref = CatalogReference.fromJson(r);
            result[ref.id] = ref;
          }
        }
        return result;
      });

  /// Rapprochement d'un code article lu sur une étiquette avec les catalogues publiés.
  Future<List<ReferenceMatch>> match(String? code, String? supplier) => _guard(() async {
        if ((code ?? '').trim().isEmpty) return const [];
        final rows = await _client.rpc<List<dynamic>>(
          'match_supplier_references',
          params: {'p_code': code, 'p_supplier': supplier},
        );
        final scores = {for (final r in rows.cast<Map<String, dynamic>>()) r['id'] as String: (r['score'] as num).toDouble()};
        final refs = await catalogReferences(scores.keys);
        return [
          for (final id in scores.keys)
            if (refs[id] != null) ReferenceMatch(refs[id]!, scores[id]!),
        ];
      });

  /// Recherche dans les catalogues publiés (code ou désignation), pour lier une fiche après coup.
  Future<List<CatalogReference>> searchCatalog(String query) => _guard(() async {
        final q = query.trim().replaceAll(RegExp(r'[%,()]'), ' ');
        if (q.length < 2) return const [];
        final rows = await _client
            .from('supplier_catalog')
            .select(CatalogReference.selectColumns)
            .or('code.ilike.%$q%,name.ilike.%$q%,supplier_name.ilike.%$q%')
            .order('code')
            .limit(20);
        return rows.map(CatalogReference.fromJson).toList();
      });

  /// Import de la base atelier par lots ; [lines] donne le numéro de ligne du fichier
  /// de chaque payload, pour rapporter les refus du serveur.
  Future<AtelierImportResult> importRows(
    String orgId,
    List<Map<String, dynamic>> payloads,
    List<int> lines, {
    void Function(int done, int total)? onProgress,
  }) =>
      _guard(() async {
        var result = const AtelierImportResult();
        for (var start = 0; start < payloads.length; start += kAtelierImportBatchSize) {
          final end = (start + kAtelierImportBatchSize).clamp(0, payloads.length);
          final r = await _client.rpc<Map<String, dynamic>>(
            'import_atelier_materials',
            params: {'p_org': orgId, 'p_rows': payloads.sublist(start, end)},
          );
          result = AtelierImportResult(
            inserted: result.inserted + (r['inserted'] as int),
            updated: result.updated + (r['updated'] as int),
            linked: result.linked + (r['linked'] as int),
            pending: result.pending + (r['pending'] as int),
            serverErrors: [
              ...result.serverErrors,
              for (final e in (r['errors'] as List<dynamic>).cast<Map<String, dynamic>>())
                (lines[start + (e['row'] as int) - 1], e['error'] as String),
            ],
          );
          onProgress?.call(end, payloads.length);
        }
        return result;
      });

  /// « Aucune de ces références » : la correspondance n'est plus proposée.
  Future<void> dismissLink(String id) => _guard(
        () => _client.from('materials').update({'link_review': 'dismissed'}).eq('id', id),
      );

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
  /// Photo d'une matière (export PDF).
  Future<Uint8List> downloadPhoto(String path) => _guard(() => _client.storage.from(_bucket).download(path));

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

/// Références publiées liées aux matières de l'atelier (disponibilité en direct).
/// Une matière liée absente de cette table a été retirée par son fournisseur.
final linkedReferencesProvider = FutureProvider<Map<String, CatalogReference>>((ref) async {
  final materials = await ref.watch(materialsProvider.future);
  final ids = [for (final m in materials) if (m.supplierReferenceId != null) m.supplierReferenceId!];
  if (ids.isEmpty) return const {};
  return ref.watch(materialsRepositoryProvider).catalogReferences(ids);
});

/// Matières dont une correspondance fournisseur attend confirmation (après un import).
final pendingLinksProvider = Provider<List<MaterialItem>>((ref) {
  final all = ref.watch(materialsProvider).value ?? const <MaterialItem>[];
  return [for (final m in all) if (m.linkPending && !m.isLinked) m]..sort((a, b) => a.name.compareTo(b.name));
});

/// Références proposées pour une matière à confirmer (recalculées à l'ouverture).
final linkCandidatesProvider = FutureProvider.autoDispose.family<List<ReferenceMatch>, String>((ref, id) async {
  final m = (await ref.watch(materialsProvider.future)).where((x) => x.id == id).firstOrNull;
  if (m == null) return const [];
  return ref.watch(materialsRepositoryProvider).match(m.supplierCode, m.supplierName);
});

final materialProvider = FutureProvider.family<MaterialItem?, String>(
  (ref, id) => ref.watch(materialsRepositoryProvider).get(id),
);

final photoUrlProvider = FutureProvider.family<String, String>(
  (ref, path) => ref.watch(materialsRepositoryProvider).photoUrl(path),
);
