import 'package:filyxa/features/library/domain/color_family.dart';
import 'package:filyxa/features/library/domain/library_filter.dart';
import 'package:filyxa/features/library/domain/material.dart';
import 'package:flutter_test/flutter_test.dart';

MaterialItem _m(String id, String name,
        {List<FiberShare> comp = const [], int? gsm, String? weave, String? hex, double? stock,
        List<String> certs = const [], List<String> uses = const [], String? supplier, String? code}) =>
    MaterialItem(
      id: id,
      orgId: 'o',
      name: name,
      supplierName: supplier,
      supplierCode: code,
      colorHex: hex,
      atelierStockM: stock,
      specs: TextileSpecs(composition: comp, weightGsm: gsm, weave: weave, certifications: certs, uses: uses),
    );

final _drap = _m('1', 'Drap laine froide', comp: const [FiberShare('WO', 62), FiberShare('PES', 38)], gsm: 280,
    weave: 'twill', hex: '#2F4A6B', stock: 42.5, certs: const ['RWS'], uses: const ['jacket'], supplier: 'Dormeuil', code: 'DR4521-NV');
final _flanelle = _m('2', 'Flanelle', comp: const [FiberShare('WO', 45), FiberShare('CV', 55)], gsm: 320, weave: 'twill', hex: '#9CA3AF');
final _popeline = _m('3', 'Popeline écrue', comp: const [FiberShare('CO', 100)], gsm: 110, weave: 'plain', hex: '#F2EEE3',
    stock: 0, certs: const ['GOTS'], uses: const ['shirt']);
final _all = [_drap, _flanelle, _popeline];

List<String> ids(LibraryFilter f) => f.apply(_all).map((m) => m.id).toList();

void main() {
  test('sans filtre : tout', () => expect(ids(const LibraryFilter()), ['1', '2', '3']));

  group('recherche', () {
    test('nom, code, fournisseur, insensible aux accents et à la casse', () {
      expect(ids(const LibraryFilter(query: 'ecrue')), ['3']);
      expect(ids(const LibraryFilter(query: 'DR4521')), ['1']);
      expect(ids(const LibraryFilter(query: 'dormeuil')), ['1']);
    });

    test('tous les mots, dans n\'importe quel ordre', () {
      expect(ids(const LibraryFilter(query: 'froide drap')), ['1']);
      expect(ids(const LibraryFilter(query: 'drap popeline')), isEmpty);
    });

    test('par fibre, en code ou en toutes lettres selon la langue', () {
      expect(ids(const LibraryFilter(query: 'laine')), ['1', '2']);
      expect(ids(const LibraryFilter(query: 'PES')), ['1']);
      expect(const LibraryFilter(query: 'wool').apply(_all, lang: 'en').map((m) => m.id), ['1', '2']);
    });
  });

  group('facettes', () {
    test('« Laine ≥ 50 % » ne garde que les matières à 50 % de WO ou plus', () {
      expect(ids(const LibraryFilter(fiber: 'WO', fiberMinPct: 50)), ['1']);
      expect(ids(const LibraryFilter(fiber: 'WO')), ['1', '2']);
    });

    test('grammage : bornes incluses, sans grammage = exclu', () {
      expect(ids(const LibraryFilter(weightMin: 200, weightMax: 320)), ['1', '2']);
      expect(ids(const LibraryFilter(weightMax: 150)), ['3']);
    });

    test('couleur déduite du code couleur', () {
      expect(colorFamilyOf('#2F4A6B'), ColorFamily.blue);
      expect(colorFamilyOf('#F2EEE3'), ColorFamily.white);
      expect(ids(const LibraryFilter(colors: {ColorFamily.blue, ColorFamily.white})), ['1', '3']);
    });

    test('armure, certification, usage : « ou » dans la facette', () {
      expect(ids(const LibraryFilter(weaves: {'twill'})), ['1', '2']);
      expect(ids(const LibraryFilter(certifications: {'GOTS', 'RWS'})), ['1', '3']);
      expect(ids(const LibraryFilter(uses: {'shirt'})), ['3']);
    });

    test('stock atelier strictement positif', () {
      expect(ids(const LibraryFilter(inStockOnly: true)), ['1']);
    });

    test('facettes combinées en « et »', () {
      expect(ids(const LibraryFilter(weaves: {'twill'}, fiber: 'WO', fiberMinPct: 50)), ['1']);
      expect(ids(const LibraryFilter(weaves: {'plain'}, fiber: 'WO')), isEmpty);
    });

    test('effacer les filtres garde la recherche', () {
      const f = LibraryFilter(query: 'drap', weaves: {'twill'}, inStockOnly: true);
      expect(f.activeCount, 2);
      final cleared = f.clearFilters();
      expect(cleared.query, 'drap');
      expect(cleared.activeCount, 0);
    });
  });

  test('5 000 matières filtrées en moins de 100 ms (critère : < 1 s)', () {
    final many = [
      for (var i = 0; i < 5000; i++)
        _m('$i', 'Matière $i ${i.isEven ? 'laine' : 'coton'}',
            comp: i.isEven ? const [FiberShare('WO', 70), FiberShare('PA', 30)] : const [FiberShare('CO', 100)],
            gsm: 100 + i % 400, weave: i % 3 == 0 ? 'twill' : 'plain', hex: i.isEven ? '#2F4A6B' : '#F2EEE3',
            stock: (i % 5).toDouble(), supplier: 'Fournisseur ${i % 40}', code: 'REF-$i'),
    ];
    const filter = LibraryFilter(query: 'laine', fiber: 'WO', fiberMinPct: 50, weightMin: 200, weightMax: 400,
        colors: {ColorFamily.blue}, weaves: {'twill'}, inStockOnly: true);
    final watch = Stopwatch()..start();
    final result = filter.apply(many);
    watch.stop();
    expect(result, isNotEmpty);
    expect(watch.elapsedMilliseconds, lessThan(100));
  });

  test('normalisation pour la recherche', () {
    expect(foldForSearch('Écru-Lin  Ș'), 'ecru lin s');
  });
}
