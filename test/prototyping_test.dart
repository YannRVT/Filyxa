// Phase 19 : prototypage.
import 'package:filyxa/features/library/domain/material.dart';
import 'package:filyxa/features/studio/data/studio_repository.dart';
import 'package:filyxa/features/studio/domain/studio.dart';
import 'package:filyxa/features/studio/ui/prototype_widgets.dart';
import 'package:filyxa/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

const _lines = [
  BomLine(id: 'l1', materialId: 'serge', role: 'main', consumption: 1.8),
  BomLine(id: 'l2', materialId: 'satin', role: 'lining', consumption: 1.2, protoLossPct: 40),
];

StudioModel _model({int count = 2}) => StudioModel(
      id: 'm',
      collectionId: 'c',
      name: 'Veste',
      productType: ProductType.garment,
      prototypeCount: count,
      colorways: const [
        Colorway(id: 'c1', quantity: 100, lines: _lines),
        Colorway(id: 'c2', quantity: 50, lines: _lines),
      ],
    );

Widget _app(Widget child, {bool pro = true}) => ProviderScope(
      overrides: [
        hasProProvider.overrideWith((ref) async => pro),
        canEditStudioProvider.overrideWithValue(true),
      ],
      child: MaterialApp(
        locale: const Locale('fr'),
        localizationsDelegates: const [AppLocalizations.delegate, ...GlobalMaterialLocalizations.delegates],
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: SingleChildScrollView(child: child)),
      ),
    );

void main() {
  test('besoin de prototypage : prototypes × consommation de base × (1 + perte), premier coloris seulement', () {
    final proto = prototypeRequirements(_model());
    expect(proto['serge'], closeTo(2 * 1.8 * 1.25, 1e-9)); // 4,50 m
    expect(proto['satin'], closeTo(2 * 1.2 * 1.40, 1e-9)); // 3,36 m
    expect(prototypeRequirements(_model(count: 0)).values, everyElement(0));
  });

  test('séparé du besoin de production', () {
    final production = requirementsByMaterial(_model());
    expect(production['serge'], closeTo(1.8 * 150 * 1.08, 1e-9));
  });

  test('perte de prototypage : 25 % par défaut', () {
    expect(BomLine.fromJson(const {'id': 'l', 'material_id': 'm', 'role': 'main'}).protoLossPct, 25);
  });

  testWidgets('carte Prototypage : nombre et perte par matière', (tester) async {
    int? count;
    (String, double)? loss;
    await tester.pumpWidget(_app(PrototypingCard(
      model: _model(),
      materials: const {},
      onCount: (n) => count = n,
      onLoss: (l, p) => loss = (l.id, p),
    )));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const ValueKey('proto-count')), '3');
    expect(count, 3);
    await tester.enterText(find.byKey(const ValueKey('proto-loss-l1')), '40');
    expect(loss, ('l1', 40));
  });

  testWidgets('hors Pro : lecture seule', (tester) async {
    await tester.pumpWidget(_app(
      PrototypingCard(model: _model(), materials: const <String, MaterialItem>{}, onCount: (_) {}, onLoss: (_, _) {}),
      pro: false,
    ));
    await tester.pumpAndSettle();
    expect(find.text('Disponible avec l\'offre Pro'), findsOneWidget);
    expect(find.byType(TextField), findsNothing);
  });
}
