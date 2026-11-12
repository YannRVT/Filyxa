// Phase 21 : coût de revient. Cinq modèles de référence calculés à la main (au centime près).
import 'package:filyxa/features/library/data/materials_repository.dart';
import 'package:filyxa/features/library/domain/material.dart';
import 'package:filyxa/features/studio/data/studio_repository.dart';
import 'package:filyxa/features/studio/domain/studio.dart';
import 'package:filyxa/features/studio/ui/cost_widgets.dart';
import 'package:filyxa/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

double _ct(double v) => (v * 100).roundToDouble() / 100;

BomLine _line(String m, double c, {double proto = 25}) =>
    BomLine(id: '$m$c', materialId: m, role: 'main', consumption: c, protoLossPct: proto);

StudioModel _model({
  List<Colorway> colorways = const [],
  List<CostLine> costs = const [],
  double waste = 8,
  int prototypes = 0,
  List<String> sizes = const [],
  String? base,
}) =>
    StudioModel(
      id: 'm',
      collectionId: 'c',
      name: 'Veste',
      productType: ProductType.garment,
      wastePct: waste,
      prototypeCount: prototypes,
      sizeChartId: sizes.isEmpty ? null : 'chart',
      sizes: sizes,
      baseSize: base,
      costs: costs,
      colorways: colorways,
    );

CostLine _cost(CostKind k, double price, {double qty = 1, bool flat = false}) =>
    CostLine(id: '$k$price', kind: k, label: k.name, unitPrice: price, quantity: qty, perModel: flat);

void main() {
  group('cinq modèles de référence', () {
    test('1. matières seules', () {
      // Sergé 1,80 m × 100 × 1,08 = 194,4 m × 18 € = 3 499,20 € → 34,99 € / pièce
      final c = modelCost(
        _model(colorways: [Colorway(id: 'c', quantity: 100, lines: [_line('serge', 1.8)])]),
        {'serge': 18},
      );
      expect(_ct(c.materials), 3499.20);
      expect(_ct(c.perPiece!), 34.99);
    });

    test('2. matières + fournitures + façon + frais par pièce', () {
      // Matières : sergé 1,5 × 200 × 1,08 = 324 m × 12 € = 3 888 € ; doublure 1 × 200 × 1,08 = 216 m × 6 € = 1 296 €
      // Par pièce : 5 boutons × 0,40 € = 2 € ; façon 22 € ; étiquettes 0,80 € → 24,80 €
      // Total = 5 184 + 24,80 × 200 = 10 144 € → 50,72 € / pièce
      final c = modelCost(
        _model(
          colorways: [Colorway(id: 'c', quantity: 200, lines: [_line('serge', 1.5), _line('doublure', 1.0)])],
          costs: [_cost(CostKind.supply, 0.40, qty: 5), _cost(CostKind.labor, 22), _cost(CostKind.overhead, 0.80)],
        ),
        {'serge': 12, 'doublure': 6},
      );
      expect(_ct(c.total), 10144.00);
      expect(_ct(c.perPiece!), 50.72);
    });

    test('3. forfait réparti sur les pièces, deux coloris', () {
      // Marine 60 pièces, Sable 40 ; toile 1 m × 1,08 × 10 € = 10,80 € / pièce.
      // Matières = 100 × 10,80 = 1 080 € ; façon 15 € / pièce ; patronage forfait 600 € → 6 € / pièce.
      // Total = 1 080 + 1 500 + 600 = 3 180 € → 31,80 € / pièce, et 31,80 € pour chaque coloris.
      final c = modelCost(
        _model(
          colorways: [
            Colorway(id: 'marine', quantity: 60, lines: [_line('toile', 1)]),
            Colorway(id: 'sable', quantity: 40, lines: [_line('toile', 1)]),
          ],
          costs: [_cost(CostKind.labor, 15), _cost(CostKind.overhead, 600, flat: true)],
        ),
        {'toile': 10},
      );
      expect(_ct(c.total), 3180.00);
      expect(_ct(c.perPiece!), 31.80);
      expect(_ct(c.byColorway['marine']!), 31.80);
      expect(_ct(c.byColorway['sable']!), 31.80);
    });

    test('4. tailles graduées et prototypage à part', () {
      // Base M, ±4 % ; S ×10, M ×20, L ×10 ; 2 m en M ; marge 8 % ; 20 € / m.
      // Mètres = 2 × (0,96×10 + 20 + 1,04×10) × 1,08 = 2 × 40 × 1,08 = 86,4 m → 1 728 €
      // Prototypage : 2 prototypes × 2 m × 1,25 = 5 m → 100 €, hors coût de production.
      final c = modelCost(
        _model(
          sizes: const ['S', 'M', 'L'],
          base: 'M',
          prototypes: 2,
          colorways: [Colorway(id: 'c', quantity: 40, lines: [_line('drap', 2)], sizeQuantities: const {'S': 10, 'M': 20, 'L': 10})],
        ),
        {'drap': 20},
      );
      expect(_ct(c.materials), 1728.00);
      expect(_ct(c.prototyping), 100.00);
      expect(_ct(c.perPiece!), 43.20);
    });

    test('5. matière sans prix : coût incomplet', () {
      final c = modelCost(
        _model(colorways: [Colorway(id: 'c', quantity: 10, lines: [_line('serge', 1), _line('satin', 1)])]),
        {'serge': 10, 'satin': null},
      );
      expect(c.complete, isFalse);
      expect(c.missingPrices, {'satin'});
      expect(_ct(c.materials), 108.00);
    });
  });

  test('prix lu dans la couche privée (absent pour un Lecteur)', () {
    Map<String, dynamic> row(Object? prices) =>
        {'id': 'm', 'org_id': 'o', 'name': 'Sergé', 'material_prices': prices, 'textile_specs': null};
    expect(MaterialItem.fromJson(row({'price_per_m': 18.5})).pricePerM, 18.5);
    expect(MaterialItem.fromJson(row(null)).pricePerM, isNull);
  });

  group('carte Coût de revient', () {
    final model = _model(
      colorways: [Colorway(id: 'c', quantity: 100, lines: [_line('serge', 1), _line('satin', 1)])],
      costs: [_cost(CostKind.labor, 20)],
    );
    Widget app({required bool canEdit}) => ProviderScope(
          overrides: [
            hasProProvider.overrideWith((ref) async => true),
            canEditStudioProvider.overrideWithValue(canEdit),
            materialsProvider.overrideWith((ref) async => const [
                  MaterialItem(id: 'serge', orgId: 'o', name: 'Sergé', pricePerM: 10),
                  MaterialItem(id: 'satin', orgId: 'o', name: 'Satin'),
                ]),
          ],
          child: MaterialApp(
            locale: const Locale('fr'),
            localizationsDelegates: const [AppLocalizations.delegate, ...GlobalMaterialLocalizations.delegates],
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(
              body: SingleChildScrollView(
                child: ModelCostCard(
                  model: model,
                  materials: const {'satin': MaterialItem(id: 'satin', orgId: 'o', name: 'Satin')},
                  onAdd: (_) {},
                  onUpdate: (_) {},
                  onDelete: (_) {},
                ),
              ),
            ),
          ),
        );

    testWidgets('Éditeur : coût par pièce en euros, mention « incomplet »', (tester) async {
      await tester.pumpWidget(app(canEdit: true));
      await tester.pumpAndSettle();
      // Sergé 1 × 100 × 1,08 × 10 € = 1 080 € ; façon 20 € × 100 → 3 080 € → 30,80 € / pièce
      expect(find.textContaining(RegExp(r'30,80\s€ / pièce')), findsWidgets);
      expect(find.textContaining('Coût incomplet : sans prix pour Satin.'), findsOneWidget);
      expect(find.text('Façon · labor'), findsOneWidget);
    });

    testWidgets('Lecteur : aucun coût affiché', (tester) async {
      await tester.pumpWidget(app(canEdit: false));
      await tester.pumpAndSettle();
      expect(find.text('Coût de revient'), findsNothing);
    });
  });
}
