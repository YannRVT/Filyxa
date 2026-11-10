import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/supabase.dart';
import '../../session/data/user_space_repository.dart';
import '../domain/scan.dart';

class ScanException implements Exception {
  const ScanException(this.failure, {this.usage});

  final ScanFailure failure;
  final ScanUsage? usage;
}

class ScanOutcome {
  const ScanOutcome({required this.prefill, required this.usage, required this.durationMs});

  final ScanPrefill prefill;
  final ScanUsage? usage;
  final int durationMs;
}

class ScannerRepository {
  ScannerRepository(this._client);

  final SupabaseClient _client;

  /// Envoie la photo à analyze-tag et renvoie la fiche pré-remplie.
  Future<ScanOutcome> analyze(Uint8List bytes, String mediaType) async {
    final watch = Stopwatch()..start();
    try {
      final response = await _client.functions.invoke(
        'analyze-tag',
        body: {'imageBase64': base64Encode(bytes), 'mediaType': mediaType},
      );
      final data = (response.data as Map).cast<String, dynamic>();
      return ScanOutcome(
        prefill: ScanPrefill.fromLabel((data['label'] as Map).cast<String, dynamic>()),
        usage: data['usage'] == null ? null : ScanUsage.fromJson((data['usage'] as Map).cast<String, dynamic>()),
        durationMs: watch.elapsedMilliseconds,
      );
    } on FunctionException catch (e) {
      final details = e.details is Map ? (e.details as Map).cast<String, dynamic>() : const <String, dynamic>{};
      final usage = details['usage'] is Map ? ScanUsage.fromJson((details['usage'] as Map).cast<String, dynamic>()) : null;
      throw ScanException(scanFailureOf(details['error'] as String?, status: e.status), usage: usage);
    } catch (e) {
      if (e is ScanException) rethrow;
      throw const ScanException(ScanFailure.network);
    }
  }

  Future<ScanUsage?> usage(String orgId) async {
    final data = await _client.rpc<Map<String, dynamic>?>('current_scan_usage', params: {'p_org': orgId});
    return data == null ? null : ScanUsage.fromJson(data);
  }
}

final scannerRepositoryProvider = Provider<ScannerRepository>(
  (ref) => ScannerRepository(ref.watch(supabaseProvider)),
);

/// Usage du mois de l'atelier connecté.
final scanUsageProvider = FutureProvider<ScanUsage?>((ref) async {
  final orgId = ref.watch(userSpaceProvider).value?.membership?.organization.id;
  if (orgId == null) return null;
  return ref.watch(scannerRepositoryProvider).usage(orgId);
});
