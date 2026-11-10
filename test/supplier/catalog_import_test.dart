import 'package:filyxa/features/library/domain/material.dart';
import 'package:filyxa/features/supplier/domain/availability.dart';
import 'package:filyxa/features/supplier/domain/catalog_import.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('composition écrite librement', () {
    final cases = <String, List<FiberShare>>{
      '62% WO 38% PES': const [FiberShare('WO', 62), FiberShare('PES', 38)],
      '62 % laine / 38 % polyester': const [FiberShare('WO', 62), FiberShare('PES', 38)],
      'Wool 62, Polyester 38': const [FiberShare('WO', 62), FiberShare('PES', 38)],
      '37,5% coton biologique, 62,5% lin': const [FiberShare('CO', 37.5), FiberShare('LI', 62.5)],
      '100% Cotton': const [FiberShare('CO', 100)],
      '97%CO 3%EA': const [],
      '95 % lana vergine 5 % elastan': const [FiberShare('WO', 95), FiberShare('EL', 5)],
      '70% Lână, 30% Mătase': const [FiberShare('WO', 70), FiberShare('SE', 30)],
    };
    cases.forEach((input, expected) {
      test(input, () {
        final parsed = parseComposition(input);
        if (expected.isEmpty) {
          expect(parsed, isNull, reason: 'fibre inconnue EA');
        } else {
          expect(parsed, expected);
        }
      });
    });

    test('texte sans pourcentage : refusé', () {
      expect(parseComposition('laine et soie'), isNull);
    });
  });

  test('association automatique des colonnes (intitulés dans plusieurs langues)', () {
    final headers = ['Codice articolo', 'Descrizione', 'Composizione', 'Grammatura g/m2', 'Altezza cm', 'Giacenza', 'Colore'];
    final m = guessMapping(headers);
    expect(m[ImportField.code], 0);
    expect(m[ImportField.name], 1);
    expect(m[ImportField.composition], 2);
    expect(m[ImportField.weight], 3);
    expect(m[ImportField.width], 4);
    expect(m[ImportField.stock], 5);
    expect(m[ImportField.colorName], 6);
  });

  test('l\'association mémorisée est prioritaire', () {
    final headers = ['Ref interne', 'Code', 'Qualité'];
    final m = guessMapping(headers, remembered: const {'code': 'Ref interne', 'name': 'Qualité'});
    expect(m[ImportField.code], 0);
    expect(m[ImportField.name], 2);
    expect(mappingToRemember(m, headers), {'code': 'Ref interne', 'name': 'Qualité'});
  });

  group('analyse des lignes', () {
    final mapping = {
      ImportField.code: 0, ImportField.name: 1, ImportField.composition: 2, ImportField.weight: 3,
      ImportField.stock: 4, ImportField.weave: 5, ImportField.certifications: 6, ImportField.colorHex: 7,
    };

    test('lignes valides et lignes rejetées avec leur motif', () {
      final analysis = analyzeRows([
        ['DR4521', 'Drap laine froide', '62% WO 38% PES', '280', '340,5', 'Sergé', 'RWS, Oeko-Tex', '#2f4a6b'],
        ['', 'Sans code', '', '', '', '', '', ''],
        ['X1', 'Compo fausse', '60% WO', '', '', '', '', ''],
        ['X2', 'Grammage fou', '', '99999', '', '', '', ''],
        ['dr-4521', 'Doublon', '', '', '', '', '', ''],
        ['', '', '', '', '', '', '', ''],
        ['X3', 'Couleur', '', '', '', '', '', 'bleu'],
      ], mapping);

      expect(analysis.rows.length, 6, reason: 'la ligne vide est ignorée');
      expect(analysis.valid.length, 1);
      final ok = analysis.valid.single.payload!;
      expect(ok['stock_m'], 340.5);
      expect(ok['weave'], 'twill');
      expect(ok['certifications'], ['OEKO-TEX', 'RWS']);
      expect(ok['color_hex'], '#2F4A6B');

      final kinds = {for (final r in analysis.invalid) r.line: r.issues.map((i) => i.kind).toList()};
      expect(kinds[3], [ImportIssueKind.missingCode]);
      expect(kinds[4], [ImportIssueKind.compositionInvalid]);
      expect(kinds[5], [ImportIssueKind.numberInvalid]);
      expect(kinds[6], [ImportIssueKind.duplicateCode]);
      expect(kinds[8], [ImportIssueKind.colorInvalid]);
    });

    test('500 lignes analysées en moins d\'une seconde', () {
      final rows = [for (var i = 0; i < 500; i++) ['REF-$i', 'Tissu $i', '62% WO 38% PES', '280', '${i * 2}', 'twill', '', '']];
      final watch = Stopwatch()..start();
      final analysis = analyzeRows(rows, mapping);
      expect(watch.elapsedMilliseconds, lessThan(1000));
      expect(analysis.valid.length, 500);
    });
  });

  test('code normalisé comme en base', () {
    expect(normalizeReferenceCode('dr 4521-nv'), 'DR4521NV');
  });

  test('statut de disponibilité', () {
    expect(availabilityStatusOf(stockM: 340, thresholdM: 50), AvailabilityStatus.available);
    expect(availabilityStatusOf(stockM: 20, thresholdM: 50), AvailabilityStatus.low);
    expect(availabilityStatusOf(stockM: 0, thresholdM: 50, leadTimeWeeks: 6), AvailabilityStatus.onOrder);
    expect(availabilityStatusOf(stockM: null, thresholdM: 50), AvailabilityStatus.outOfStock);
  });
}
