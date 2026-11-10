import 'dart:io';

import 'package:filyxa/features/library/domain/catalog.dart';
import 'package:filyxa/features/library/domain/material.dart';
import 'package:filyxa/features/scanner/domain/scan.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('fiche pré-remplie depuis la réponse de l\'IA', () {
    final p = ScanPrefill.fromLabel({
      'name': 'Sergé laine froide',
      'supplier_name': 'Tissage Démo',
      'supplier_code': 'TD-SRG-280',
      'composition': [
        {'fiber': 'WO', 'pct': 62},
        {'fiber': 'PES', 'pct': 38},
      ],
      'weight_gsm': 280,
      'width_cm': 150,
      'weave': 'twill',
      'color_name': 'Marine',
      'color_hex': '#2F4A6B',
      'care': ['wash_30'],
      'certifications': ['RWS'],
      'uses': ['jacket'],
      'notes': null,
      'uncertain_fields': ['weight_gsm'],
    });
    expect(p.material.name, 'Sergé laine froide');
    expect(p.material.specs.composition, const [FiberShare('WO', 62), FiberShare('PES', 38)]);
    expect(p.material.specs.weave, 'twill');
    expect(p.uncertain, {'weight_gsm'});
  });

  test('quota : avertissement à 80 %, blocage à 100 %', () {
    expect(const ScanUsage(scans: 239, quota: 300).isWarning, isFalse);
    expect(const ScanUsage(scans: 240, quota: 300).isWarning, isTrue);
    expect(const ScanUsage(scans: 300, quota: 300).isWarning, isFalse);
    expect(const ScanUsage(scans: 300, quota: 300).isExhausted, isTrue);
  });

  test('codes d\'erreur du serveur', () {
    expect(scanFailureOf('not_a_label', status: 422), ScanFailure.notALabel);
    expect(scanFailureOf('quota_exceeded', status: 429), ScanFailure.quotaExceeded);
    expect(scanFailureOf('ai_busy', status: 429), ScanFailure.aiUnavailable);
    expect(scanFailureOf('analysis_refused', status: 422), ScanFailure.refused);
    expect(scanFailureOf(null), ScanFailure.network);
    expect(scanFailureOf('???', status: 500), ScanFailure.generic);
  });

  test('doublon : même code article, écriture différente', () {
    const existing = [MaterialItem(id: 'm1', orgId: 'o', name: 'Drap', supplierCode: 'DR4521-NV')];
    expect(findDuplicate(existing, supplierCode: 'dr 4521 nv')?.id, 'm1');
    expect(findDuplicate(existing, supplierCode: 'dr 4521 nv', exceptId: 'm1'), isNull);
    expect(findDuplicate(existing, supplierCode: ''), isNull);
  });

  test('les codes envoyés à l\'IA sont ceux de l\'app (fibres, armures, usages, entretien, certifications)', () {
    final ts = File('supabase/functions/analyze-tag/label.ts').readAsStringSync();
    List<String> codes(String constant) {
      final block = RegExp('export const $constant = \\[([^\\]]*)\\]').firstMatch(ts)!.group(1)!;
      return RegExp('"([^"]+)"').allMatches(block).map((m) => m.group(1)!).toList();
    }
    expect(codes('FIBER_CODES'), fibers.map((e) => e.code).toList());
    expect(codes('WEAVE_CODES'), weaves.map((e) => e.code).toList());
    expect(codes('USE_CODES'), uses.map((e) => e.code).toList());
    expect(codes('CARE_CODES'), careCodes.map((e) => e.code).toList());
    expect(codes('CERTIFICATIONS'), certifications);
  });
}
