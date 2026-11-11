// Phase 12 : export PDF (fiche matière, dossier d'un modèle ou d'une collection).
import 'dart:convert';

import 'package:filyxa/features/export/pdf_documents.dart';
import 'package:filyxa/features/library/domain/material.dart';
import 'package:filyxa/features/studio/domain/studio.dart';
import 'package:filyxa/l10n/app_localizations.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

const _serge = MaterialItem(
  id: 'mat1',
  orgId: 'org',
  name: 'Serge laine froide',
  supplierName: 'Tissage Demo',
  supplierCode: 'TD-SRG-280',
  colorName: 'Marine',
  colorHex: '#2F4A6B',
  atelierStockM: 42.5,
  pricePerM: 24.5,
  notes: 'Prix negocie, ne pas diffuser',
  tags: ['interne'],
  specs: TextileSpecs(
    composition: [FiberShare('WO', 62), FiberShare('PES', 38)],
    weightGsm: 280,
    widthCm: 150,
    weave: 'twill',
    care: ['wash_30', 'iron_low'],
    certifications: ['RWS'],
    uses: ['jacket'],
  ),
);
const _doublure = MaterialItem(id: 'mat2', orgId: 'org', name: 'Doublure viscose', specs: TextileSpecs(weightGsm: 90, care: ['wash_40']));
final _materials = {_serge.id: _serge, _doublure.id: _doublure};

StudioModel _model(int i) => StudioModel(
      id: 'm$i',
      collectionId: 'c',
      name: 'Modele $i',
      productType: ProductType.garment,
      colorways: [
        Colorway(id: 'a$i', name: 'Marine', quantity: 100, lines: const [
          BomLine(id: 'l1', materialId: 'mat1', role: 'main', consumption: 1.8),
          BomLine(id: 'l2', materialId: 'mat2', role: 'lining', consumption: 1.2),
        ]),
        Colorway(id: 'b$i', name: 'Noir', position: 1, quantity: 50, lines: const [
          BomLine(id: 'l3', materialId: 'mat1', role: 'main', consumption: 1.8),
        ]),
      ],
    );

PdfContext _ctx(String lang, {String? shareUrl}) => PdfContext(
      l10n: lookupAppLocalizations(Locale(lang)),
      lang: lang,
      fonts: PdfFonts.standard(),
      date: DateTime(2026, 11, 11),
      shareUrl: shareUrl,
      compress: false,
    );

/// Texte du PDF (non compressé) : chaque mot est écrit par un opérateur « [(mot)]TJ ».
String _text(List<int> bytes) {
  final raw = latin1.decode(bytes, allowInvalid: true);
  final words = RegExp(r'\[\((.*?)\)\]TJ').allMatches(raw).map((m) => m.group(1)!);
  return '${raw.substring(0, 8)} ${words.join(' ')}';
}

void main() {
  test('fiche matière : PDF A4 sans prix, notes, étiquettes ni stock atelier', () async {
    final pdf = _text(await buildMaterialSheet(_serge, _ctx('fr')));
    expect(pdf, startsWith('%PDF'));
    expect(pdf, contains('Serge laine froide'));
    expect(pdf, contains('TD-SRG-280'));
    expect(pdf, contains('280 g/m'));
    expect(pdf, isNot(contains('Prix negocie')));
    expect(pdf, isNot(contains('24,5')));
    expect(pdf, isNot(contains('42,5')));
    expect(pdf, isNot(contains('interne')));
  });

  test('la langue du PDF est celle choisie à l\'export', () async {
    final en = _text(await buildMaterialSheet(_serge, _ctx('en')));
    final it = _text(await buildMaterialSheet(_serge, _ctx('it')));
    expect(en, contains('Material sheet'));
    expect(en, contains('Wool'));
    expect(it, contains('Scheda materiale'));
    expect(it, isNot(contains('Material sheet')));
  });

  test('dossier d\'un modèle : rôles, consommation, besoin, alertes', () async {
    final pdf = _text(await buildDossier([_model(1)], _materials, _ctx('fr')));
    expect(pdf, contains('Modele 1'));
    expect(pdf, contains('Tissu principal'));
    expect(pdf, contains('194,4 m'), reason: '1,8 × 100 × 1,08');
    expect(pdf, contains('291,6 m'), reason: 'total sergé, deux coloris');
    expect(pdf, isNot(contains('Prix negocie')));
  });

  test('dossier d\'une collection de 20 modèles en moins de 10 s', () async {
    final watch = Stopwatch()..start();
    final bytes = await buildDossier([for (var i = 0; i < 20; i++) _model(i)], _materials, _ctx('fr'), collectionName: 'AH27');
    watch.stop();
    expect(bytes.length, greaterThan(1000));
    expect(watch.elapsed, lessThan(const Duration(seconds: 10)));
    expect(_text(bytes), contains('SOMMAIRE'));
  });

  test('QR code vers le lien partagé quand il existe', () async {
    final pdf = _text(await buildMaterialSheet(_serge, _ctx('fr', shareUrl: 'https://filyxa.app/s/abc')));
    expect(pdf, contains('https://filyxa.app/s/abc'));
  });
}
