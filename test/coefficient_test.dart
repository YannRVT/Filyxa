// Phase 22 : prix de vente visé et coefficient.
import 'package:filyxa/features/library/data/materials_repository.dart';
import 'package:filyxa/features/library/domain/material.dart';
import 'package:filyxa/features/studio/data/studio_repository.dart';
import 'package:filyxa/features/studio/domain/studio.dart';
import 'package:filyxa/features/studio/ui/cost_widgets.dart';
import 'package:filyxa/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

// Coût : 1 m × 100 × 1,08 × 10 € = 1 080 € + façon 20 € × 100 = 3 080 € → 30,80 € / pièce.
StudioModel _model({double? target, bool missingPrice = false}) => StudioModel(
      id: 'm',
      collectionId: 'c',
      name: 'Veste',
      productType: ProductType.garment,
      targetPrice: target,
      prototypeCount: 0,
      costs: const [CostLine(id: 'f', kind: CostKind.labor, label: 'Façon', unitPrice: 20)],
      colorways: [
        Colorway(id: 'c', quantity: 100, lines: [
          const BomLine(id: 'l', materialId: 'serge', role: 'main', consumption: 1),
          if (missingPrice) const BomLine(id: 'l2', materialId: 'satin', role: 'lining', consumption: 1),
        ]),
      ],
    );

Widget _app(Widget child) => ProviderScope(
      overrides: [
        hasProProvider.overrideWith((ref) async => true),
        canEditStudioProvider.overrideWithValue(true),
        minCoefficientProvider.overrideWith((ref) async => 2.5),
        materialsProvider.overrideWith((ref) async => const [
              MaterialItem(id: 'serge', orgId: 'o', name: 'Sergé', pricePerM: 10),
              MaterialItem(id: 'satin', orgId: 'o', name: 'Satin'),
            ]),
      ],
      child: MaterialApp(
        locale: const Locale('fr'),
        localizationsDelegates: const [AppLocalizations.delegate, ...GlobalMaterialLocalizations.delegates],
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: SingleChildScrollView(child: child)),
      ),
    );

Widget _card(StudioModel m, {ValueChanged<double?>? onTarget}) => ModelCostCard(
      model: m,
      materials: const {},
      onAdd: (_) {},
      onUpdate: (_) {},
      onDelete: (_) {},
      onTargetPrice: onTarget,
    );

void main() {
  test('coefficient = prix de vente ÷ coût par pièce', () {
    final cost = modelCost(_model(), {'serge': 10});
    expect(coefficient(cost, 92.4), closeTo(3.0, 1e-9));
    expect(coefficient(cost, null), isNull);
    expect(coefficient(modelCost(_model(missingPrice: true), {'serge': 10, 'satin': null}), 92.4), isNull);
  });

  testWidgets('sous le minimum : alerte avec le coefficient et le minimum', (tester) async {
    await tester.pumpWidget(_app(_card(_model(target: 64.68))));
    await tester.pumpAndSettle();
    expect(find.text('Coefficient 2,1 < 2,5'), findsOneWidget);
  });

  testWidgets('au-dessus : coefficient affiché', (tester) async {
    await tester.pumpWidget(_app(_card(_model(target: 92.4))));
    await tester.pumpAndSettle();
    expect(find.text('Coefficient : 3'), findsOneWidget);
  });

  testWidgets('sans prix de vente, ou coût incomplet : ce qui manque', (tester) async {
    double? typed;
    await tester.pumpWidget(_app(_card(_model(), onTarget: (v) => typed = v)));
    await tester.pumpAndSettle();
    expect(find.textContaining('Saisissez un prix de vente visé'), findsOneWidget);
    await tester.enterText(find.byKey(const ValueKey('target-price')), '80');
    expect(typed, 80);

    await tester.pumpWidget(_app(_card(_model(target: 90, missingPrice: true))));
    await tester.pumpAndSettle();
    expect(find.textContaining('le coût est incomplet'), findsOneWidget);
  });

  test('prix de vente lu dans la couche privée', () {
    final m = StudioModel.fromJson(const {
      'id': 'm',
      'collection_id': 'c',
      'name': 'Veste',
      'model_prices': {'target_price': 120},
    });
    expect(m.targetPrice, 120);
  });
}
