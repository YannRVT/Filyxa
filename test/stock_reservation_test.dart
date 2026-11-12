// Phase 20 : réservation et déduction du stock.
import 'package:filyxa/features/library/domain/material.dart';
import 'package:filyxa/features/studio/domain/studio.dart';
import 'package:filyxa/features/studio/ui/production_widgets.dart';
import 'package:filyxa/l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

const _model = StudioModel(
  id: 'veste',
  collectionId: 'c',
  name: 'Veste',
  productType: ProductType.garment,
  prototypeCount: 1,
  colorways: [
    Colorway(id: 'c1', quantity: 100, lines: [
      BomLine(id: 'l1', materialId: 'serge', role: 'main', consumption: 1.0),
      BomLine(id: 'l2', materialId: 'satin', role: 'lining', consumption: 0.5, protoLossPct: 0),
    ]),
  ],
);

final _materials = <String, MaterialItem>{
  'serge': const MaterialItem(id: 'serge', orgId: 'o', name: 'Sergé', atelierStockM: 300),
  'satin': const MaterialItem(id: 'satin', orgId: 'o', name: 'Satin', atelierStockM: 50),
};

const _others = [StockReservation(modelId: 'manteau', materialId: 'satin', meters: 10, modelName: 'Manteau')];

Future<Map<String, double>?> _open(WidgetTester tester, ProductionStep step, Map<String, double> meters) async {
  Map<String, double>? result;
  await tester.pumpWidget(MaterialApp(
    locale: const Locale('fr'),
    localizationsDelegates: const [AppLocalizations.delegate, ...GlobalMaterialLocalizations.delegates],
    supportedLocales: AppLocalizations.supportedLocales,
    home: Builder(
      builder: (context) => Scaffold(
        body: TextButton(
          onPressed: () async => result = await showProductionDialog(context,
              step: step, model: _model, meters: meters, materials: _materials, reservations: _others),
          child: const Text('ouvrir'),
        ),
      ),
    ),
  ));
  await tester.tap(find.text('ouvrir'));
  await tester.pumpAndSettle();
  return Future.value(result);
}

void main() {
  test('besoin à réserver : production + prototypage', () {
    final need = productionNeed(_model);
    expect(need['serge'], closeTo(1.0 * 100 * 1.08 + 1.0 * 1.25, 1e-9)); // 108 + 1,25
    expect(need['satin'], closeTo(0.5 * 100 * 1.08 + 0.5, 1e-9)); // 54 + 0,5
  });

  test('stock disponible : stock atelier − réservations des autres modèles', () {
    expect(availableStock(50, _others), 40);
    expect(availableStock(50, _others, exceptModel: 'manteau'), 50);
    expect(availableStock(null, _others), -10);
  });

  testWidgets('lancement : manque en rouge, « Lancer quand même »', (tester) async {
    await _open(tester, ProductionStep.reserve, productionNeed(_model));
    expect(find.text('Lancer en production'), findsOneWidget);
    expect(find.text('Disponible : 40 m'), findsOneWidget, reason: 'satin : 50 m − 10 m réservés par le Manteau');
    expect(find.text('Manque : 14,5 m'), findsOneWidget);
    expect(find.text('Lancer quand même'), findsOneWidget);
  });

  testWidgets('livraison : déduction proposée, modifiable', (tester) async {
    Map<String, double>? result;
    await tester.pumpWidget(MaterialApp(
      locale: const Locale('fr'),
      localizationsDelegates: const [AppLocalizations.delegate, ...GlobalMaterialLocalizations.delegates],
      supportedLocales: AppLocalizations.supportedLocales,
      home: Builder(
        builder: (context) => Scaffold(
          body: TextButton(
            onPressed: () async => result = await showProductionDialog(context,
                step: ProductionStep.deliver,
                model: _model,
                meters: const {'serge': 109.25},
                materials: _materials,
                reservations: const []),
            child: const Text('ouvrir'),
          ),
        ),
      ),
    ));
    await tester.tap(find.text('ouvrir'));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(TextField, '109,25'), findsOneWidget);
    await tester.enterText(find.byKey(const ValueKey('deliver-serge')), '104,5');
    await tester.tap(find.text('Déduire et livrer'));
    await tester.pumpAndSettle();
    expect(result, {'serge': 104.5});
  });

  testWidgets('fiche matière : réservé, disponible, modèles', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      locale: Locale('fr'),
      localizationsDelegates: [AppLocalizations.delegate, ...GlobalMaterialLocalizations.delegates],
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: ReservationSummary(atelierStock: 50, reservations: _others)),
    ));
    expect(find.text('Réservé : 10 m'), findsOneWidget);
    expect(find.text('Disponible : 40 m'), findsOneWidget);
    expect(find.text('· Manteau : 10 m'), findsOneWidget);
  });
}
