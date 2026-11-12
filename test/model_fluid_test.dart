// Phase 23 : modèle plus fluide — rôle modifiable sur place, sélecteur de couleur.
import 'package:filyxa/features/studio/data/studio_repository.dart';
import 'package:filyxa/features/studio/domain/studio.dart';
import 'package:filyxa/features/studio/ui/studio_widgets.dart';
import 'package:filyxa/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

Widget _app(Widget child) => ProviderScope(
      overrides: [customRolesProvider.overrideWith((ref) async => const ['Doublure manches'])],
      child: MaterialApp(
        locale: const Locale('fr'),
        localizationsDelegates: const [AppLocalizations.delegate, ...GlobalMaterialLocalizations.delegates],
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: Center(child: child)),
      ),
    );

void main() {
  test('changer le rôle conserve consommation, perte de prototypage et position', () {
    const line = BomLine(id: 'l', materialId: 'm', role: 'main', consumption: 1.8, position: 3, protoLossPct: 40);
    final changed = line.copyWith(role: 'lining');
    expect([changed.role, changed.consumption, changed.position, changed.protoLossPct], ['lining', 1.8, 3, 40]);
  });

  testWidgets('menu du rôle : rôles du type de produit, rôles libres, « Autre »', (tester) async {
    String? chosen;
    await tester.pumpWidget(_app(RoleMenuButton(type: ProductType.garment, role: 'main', onChanged: (r) => chosen = r)));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Changer le rôle'));
    await tester.pumpAndSettle();
    expect(find.text('Doublure manches'), findsOneWidget);
    await tester.tap(find.text('Doublure'));
    await tester.pumpAndSettle();
    expect(chosen, 'lining');
  });

  testWidgets('sélecteur de couleur : palette et saisie libre', (tester) async {
    String? picked;
    await tester.pumpWidget(_app(Builder(
      builder: (context) => TextButton(
        onPressed: () async => picked = await showColorPicker(context),
        child: const Text('ouvrir'),
      ),
    )));
    await tester.tap(find.text('ouvrir'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('swatch-#2F4A6B')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Enregistrer'));
    await tester.pumpAndSettle();
    expect(picked, '#2F4A6B');

    await tester.tap(find.text('ouvrir'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const ValueKey('color-hex')), 'a1b2c3');
    await tester.pump();
    await tester.tap(find.text('Enregistrer'));
    await tester.pumpAndSettle();
    expect(picked, '#A1B2C3');
  });

  testWidgets('code couleur invalide : enregistrement impossible', (tester) async {
    await tester.pumpWidget(_app(Builder(
      builder: (context) => TextButton(onPressed: () => showColorPicker(context), child: const Text('ouvrir')),
    )));
    await tester.tap(find.text('ouvrir'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const ValueKey('color-hex')), '#12');
    await tester.pump();
    final save = tester.widget<FilledButton>(find.widgetWithText(FilledButton, 'Enregistrer'));
    expect(save.onPressed, isNull);
  });
}
