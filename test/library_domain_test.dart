import 'package:filyxa/app/locale.dart';
import 'package:filyxa/features/library/domain/catalog.dart';
import 'package:filyxa/features/library/domain/material.dart';
import 'package:filyxa/shared/care/care_pictograms.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('composition', () {
    test('valide : vide ou 100 % sans doublon', () {
      expect(isCompositionValid(const []), isTrue);
      expect(isCompositionValid(const [FiberShare('WO', 62), FiberShare('PES', 38)]), isTrue);
      expect(isCompositionValid(const [FiberShare('CO', 97), FiberShare('EL', 2.5), FiberShare('OT', 0.5)]), isTrue);
    });

    test('invalide : total différent de 100, doublon ou pourcentage nul', () {
      expect(isCompositionValid(const [FiberShare('WO', 60), FiberShare('PES', 30)]), isFalse);
      expect(isCompositionValid(const [FiberShare('WO', 50), FiberShare('WO', 50)]), isFalse);
      expect(isCompositionValid(const [FiberShare('WO', 100), FiberShare('EL', 0)]), isFalse);
    });

    test('affichage en codes et en toutes lettres, selon la langue', () {
      const c = [FiberShare('WO', 62), FiberShare('PES', 37.5), FiberShare('EL', 0.5)];
      expect(compositionCodes(c, 'fr'), '62 % WO · 37,5 % PES · 0,5 % EL');
      expect(compositionCodes(c, 'en'), '62 % WO · 37.5 % PES · 0.5 % EL');
      expect(compositionLabel(c, 'it'), '62 % Lana, 37,5 % Poliestere, 0,5 % Elastan');
      expect(compositionLabel(c, 'ro'), '62 % Lână, 37,5 % Poliester, 0,5 % Elastan');
    });
  });

  test('nombres affichés sans zéro inutile', () {
    expect(formatNumber(42.5, 'fr', decimals: 2), '42,5');
    expect(formatNumber(42.75, 'fr', decimals: 2), '42,75');
    expect(formatNumber(120, 'fr', decimals: 2), '120');
    expect(formatNumber(0.5, 'en'), '0.5');
  });

  test('saisie des nombres : virgule ou point, vide = non renseigné', () {
    expect(parseNumber('42,5'), 42.5);
    expect(parseNumber(' 1 200.75 '), 1200.75);
    expect(parseNumber(''), isNull);
    expect(parseNumber('abc'), isNull);
  });

  test('couleur : normalisation #RRGGBB', () {
    expect(normalizeHex('2f4a6b'), '#2F4A6B');
    expect(normalizeHex('#2F4A6B'), '#2F4A6B');
    expect(normalizeHex('#2F4A6'), isNull);
    expect(normalizeHex('bleu'), isNull);
  });

  group('vocabulaire normalisé', () {
    test('chaque entrée est traduite dans les 6 langues', () {
      for (final entry in [...fibers, ...weaves, ...uses]) {
        for (final lang in supportedLanguages.keys) {
          expect(entry.labels[lang], isNotNull, reason: '${entry.code} / $lang');
          expect(entry.labels[lang]!.trim(), isNotEmpty);
        }
      }
      for (final c in careCodes) {
        for (final lang in supportedLanguages.keys) {
          expect(c.labels[lang], isNotNull, reason: '${c.code} / $lang');
        }
      }
    });

    test('les codes sont uniques', () {
      for (final list in [fibers, weaves, uses]) {
        final codes = list.map((e) => e.code).toList();
        expect(codes.toSet().length, codes.length);
      }
    });

    test('chaque symbole d\'entretien a son pictogramme', () {
      for (final c in careCodes) {
        expect(careSvg(c.code), isNotEmpty, reason: c.code);
      }
    });

    test('les symboles s\'affichent dans l\'ordre normalisé', () {
      expect(sortCare(['dryclean_p', 'iron_low', 'wash_30']), ['wash_30', 'iron_low', 'dryclean_p']);
    });

    test('un code inconnu reste lisible', () {
      expect(fiberLabel('XYZ', 'fr'), 'XYZ');
      expect(weaveLabel('twill', 'pt'), 'Sarja');
    });
  });

  test('lecture depuis la base (avec caractéristiques textiles)', () {
    final m = MaterialItem.fromJson({
      'id': 'm1',
      'org_id': 'o1',
      'name': 'Drap laine froide',
      'supplier_name': 'Dormeuil',
      'supplier_code': 'DR4521',
      'color_hex': '#2F4A6B',
      'atelier_stock_m': 42.5,
      'updated_at': '2026-11-10T10:00:00Z',
      'textile_specs': {
        'composition': [
          {'fiber': 'WO', 'pct': 62},
          {'fiber': 'PES', 'pct': 38},
        ],
        'weight_gsm': 280,
        'width_cm': 150,
        'weave': 'twill',
        'care': ['wash_30'],
        'certifications': ['RWS'],
        'uses': ['jacket'],
      },
    });
    expect(m.specs.composition, const [FiberShare('WO', 62), FiberShare('PES', 38)]);
    expect(m.specs.weightGsm, 280);
    expect(m.atelierStockM, 42.5);
    final payload = MaterialDraft(orgId: 'o1', name: ' Drap ', colorHex: '#2f4a6b', specs: m.specs).toPayload();
    expect(payload['name'], 'Drap');
    expect(payload['color_hex'], '#2F4A6B');
    expect((payload['specs'] as Map)['weave'], 'twill');
  });
}
