// Phase 25 : import atelier mémorisé.
import 'package:filyxa/features/library/domain/atelier_import.dart';
import 'package:filyxa/features/supplier/domain/catalog_import.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // Premier import : intitulés maison, associés à la main par l'atelier.
  const first = ['Désignation', 'Fourn.', 'Réf. four', 'Coloris', 'Qté atelier', 'PU'];
  final chosen = {
    AtelierImportField.name: 0,
    AtelierImportField.supplierName: 1,
    AtelierImportField.supplierCode: 2,
    AtelierImportField.colorName: 3,
    AtelierImportField.stock: 4,
    AtelierImportField.price: 5,
  };

  test('l\'association retenue : champ → intitulé de colonne', () {
    expect(mappingToRemember(chosen, first), {
      'name': 'Désignation',
      'supplierName': 'Fourn.',
      'supplierCode': 'Réf. four',
      'colorName': 'Coloris',
      'stock': 'Qté atelier',
      'price': 'PU',
    });
  });

  test('deuxième import : association reprise d\'office, même dans un autre ordre', () {
    final remembered = mappingToRemember(chosen, first);
    const second = ['PU', 'Désignation', 'Coloris', 'Réf. four', 'Fourn.', 'Qté atelier'];
    final mapping = guessAtelierMapping(second, remembered: remembered);
    expect(mapping[AtelierImportField.name], 1);
    expect(mapping[AtelierImportField.price], 0);
    expect(mapping[AtelierImportField.stock], 5);
    expect(mapping[AtelierImportField.supplierCode], 3);
  });

  test('colonne absente ignorée sans erreur, colonne nouvelle devinée', () {
    final remembered = mappingToRemember(chosen, first);
    const third = ['Désignation', 'Fourn.', 'Réf. four', 'Coloris', 'Grammage'];
    final mapping = guessAtelierMapping(third, remembered: remembered);
    expect(mapping.containsKey(AtelierImportField.price), isFalse);
    expect(mapping.containsKey(AtelierImportField.stock), isFalse);
    expect(mapping[AtelierImportField.weight], 4, reason: 'deviné comme en V1');
    expect(mapping[AtelierImportField.name], 0);
  });
}
