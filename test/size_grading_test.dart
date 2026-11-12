// Phase 18 : gradation — besoin par taille. Cinq modèles de référence calculés à la main.
import 'package:filyxa/features/studio/data/studio_repository.dart';
import 'package:filyxa/features/studio/domain/studio.dart';
import 'package:filyxa/features/studio/ui/size_widgets.dart';
import 'package:filyxa/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

const _alpha = ['XS', 'S', 'M', 'L', 'XL', 'XXL'];

StudioModel _model({
  List<String> sizes = _alpha,
  String? base,
  double grade = 4,
  Map<String, double> own = const {},
  double waste = 8,
  required List<Colorway> colorways,
}) =>
    StudioModel(
      id: 'm',
      collectionId: 'c',
      name: 'Modèle',
      productType: ProductType.garment,
      sizeChartId: sizes.isEmpty ? null : 'chart',
      sizes: sizes,
      baseSize: base,
      gradePct: grade,
      sizeGrades: own,
      wastePct: waste,
      colorways: colorways,
    );

BomLine _line(String material, double consumption) =>
    BomLine(id: '$material-$consumption', materialId: material, role: 'main', consumption: consumption);

/// Arrondi au centimètre.
double _cm(double meters) => (meters * 100).roundToDouble() / 100;

void main() {
  group('écart par taille', () {
    test('taille du milieu par défaut, ±4 % par taille', () {
      final m = _model(colorways: const []);
      expect(m.effectiveBaseSize, 'M', reason: '6 tailles : indice (6 - 1) ~/ 2 = 2, soit M');
      expect([for (final s in _alpha) m.sizeGrade(s)], [-8, -4, 0, 4, 8, 12]);
    });

    test('taille de base choisie et écart propre à une taille', () {
      final m = _model(base: 'M', own: {'XXL': 15}, colorways: const []);
      expect([for (final s in _alpha) m.sizeGrade(s)], [-8, -4, 0, 4, 8, 15]);
    });
  });

  group('cinq modèles de référence (au centimètre près)', () {
    test('1. veste XS–XXL, base M, +4 %, marge 8 %', () {
      // 1,80 m en M. Quantités XS 10, S 20, M 30, L 30, XL 20, XXL 10.
      // Σ (1 + écart) × qté = 0,92×10 + 0,96×20 + 1×30 + 1,04×30 + 1,08×20 + 1,12×10 = 122,4
      // Besoin = 1,80 × 122,4 × 1,08 = 237,9456 → 237,95 m
      final m = _model(base: 'M', colorways: [
        Colorway(id: 'c', lines: [_line('serge', 1.8)], sizeQuantities: const {'XS': 10, 'S': 20, 'M': 30, 'L': 30, 'XL': 20, 'XXL': 10}),
      ]);
      expect(_cm(requirementsByMaterial(m)['serge']!), 237.95);
    });

    test('2. pantalon 34–48, base 40, +3 %, marge 10 %, deux coloris', () {
      // 1,20 m en 40. Écarts 34 −9 %, 36 −6 %, 38 −3 %, 40 0, 42 +3 %, 44 +6 %, 46 +9 %, 48 +12 %.
      // Marine : 38 ×15, 40 ×25, 42 ×15 → 0,97×15 + 1×25 + 1,03×15 = 55
      // Sable  : 36 ×5, 44 ×5        → 0,94×5 + 1,06×5 = 10
      // Besoin = 1,20 × (55 + 10) × 1,10 = 85,80 m
      final m = _model(
        sizes: const ['34', '36', '38', '40', '42', '44', '46', '48'],
        base: '40',
        grade: 3,
        waste: 10,
        colorways: [
          Colorway(id: 'marine', lines: [_line('drap', 1.2)], sizeQuantities: const {'38': 15, '40': 25, '42': 15}),
          Colorway(id: 'sable', lines: [_line('drap', 1.2)], sizeQuantities: const {'36': 5, '44': 5}),
        ],
      );
      expect(_cm(requirementsByMaterial(m)['drap']!), 85.80);
      final detail = requirementDetail(m, 'drap');
      expect(_cm(detail['marine']!['38']!), _cm(1.2 * 0.97 * 15 * 1.1)); // 19,206 → 19,21
      expect(_cm(detail['marine']!['38']!), 19.21);
    });

    test('3. chaussure 35–46, base 39, +2,5 %, écart propre en 46, marge 5 %', () {
      // Tige 0,35 m en 39. 37 ×12 → −5 % ; 39 ×20 → 0 ; 41 ×12 → +5 % ; 46 ×4 → écart propre +20 %.
      // Σ = 0,95×12 + 20 + 1,05×12 + 1,2×4 = 11,4 + 20 + 12,6 + 4,8 = 48,8
      // Besoin = 0,35 × 48,8 × 1,05 = 17,934 → 17,93 m
      final m = _model(
        sizes: const ['35', '36', '37', '38', '39', '40', '41', '42', '43', '44', '45', '46'],
        base: '39',
        grade: 2.5,
        own: const {'46': 20},
        waste: 5,
        colorways: [
          Colorway(id: 'c', lines: [_line('cuir', 0.35)], sizeQuantities: const {'37': 12, '39': 20, '41': 12, '46': 4}),
        ],
      );
      expect(_cm(requirementsByMaterial(m)['cuir']!), 17.93);
    });

    test('4. taille unique : pas d\'écart', () {
      // 0,60 m × 50 × 1,08 = 32,40 m
      final m = _model(sizes: const ['TU'], colorways: [
        Colorway(id: 'c', lines: [_line('toile', 0.6)], sizeQuantities: const {'TU': 50}),
      ]);
      expect(_cm(requirementsByMaterial(m)['toile']!), 32.40);
    });

    test('5. sans grille : calcul de la V1 (quantité par coloris)', () {
      // 1,50 m × 120 × 1,08 = 194,40 m
      final m = _model(sizes: const [], colorways: [
        Colorway(id: 'c', quantity: 120, lines: [_line('lin', 1.5)]),
      ]);
      expect(m.graded, isFalse);
      expect(_cm(requirementsByMaterial(m)['lin']!), 194.40);
    });
  });

  test('10 matières, 6 tailles, 3 coloris : recalcul bien en dessous de 1 s', () {
    final m = _model(colorways: [
      for (var c = 0; c < 3; c++)
        Colorway(
          id: 'c$c',
          lines: [for (var i = 0; i < 10; i++) _line('mat$i', 0.5 + i / 10)],
          sizeQuantities: {for (final s in _alpha) s: 25},
        ),
    ]);
    final watch = Stopwatch()..start();
    for (var i = 0; i < 100; i++) {
      requirementsByMaterial(m);
    }
    expect(requirementsByMaterial(m).length, 10);
    expect(watch.elapsedMilliseconds / 100, lessThan(10), reason: 'temps moyen d\'un recalcul, en ms');
  });

  test('lecture de la gradation renvoyée par le serveur', () {
    final m = StudioModel.fromJson(const {
      'id': 'm',
      'collection_id': 'c',
      'name': 'Veste',
      'size_chart_id': 'chart',
      'size_charts': {'sizes': ['S', 'M', 'L']},
      'base_size': 'M',
      'grade_pct': 5,
      'model_size_grades': [
        {'size': 'L', 'grade_pct': 7.5},
      ],
    });
    expect(m.sizes, ['S', 'M', 'L']);
    expect([m.sizeGrade('S'), m.sizeGrade('M'), m.sizeGrade('L')], [-5, 0, 7.5]);
  });

  testWidgets('tableau : ligne des écarts, base, saisie de l\'écart du modèle', (tester) async {
    final m = _model(base: 'M', own: {'XXL': 15}, colorways: const [Colorway(id: 'c', name: 'Marine')]);
    double? grade;
    await tester.pumpWidget(ProviderScope(
      overrides: [
        hasProProvider.overrideWith((ref) async => true),
        canEditStudioProvider.overrideWithValue(true),
        sizeChartsProvider.overrideWith((ref) async => const [SizeChart(id: 'chart', code: 'alpha', sizes: _alpha)]),
      ],
      child: MaterialApp(
        locale: const Locale('fr'),
        localizationsDelegates: const [AppLocalizations.delegate, ...GlobalMaterialLocalizations.delegates],
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: SingleChildScrollView(
            child: ModelSizesCard(model: m, onChartChanged: (_) {}, onQuantity: (_, _, _) {}, onGradePct: (v) => grade = v),
          ),
        ),
      ),
    ));
    await tester.pumpAndSettle();
    expect(find.text('base'), findsOneWidget);
    expect(find.text('-8 %'), findsOneWidget);
    expect(find.text('+15 %'), findsOneWidget);
    await tester.enterText(find.byKey(const ValueKey('grade')), '5');
    expect(grade, 5);
  });
}
