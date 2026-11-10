import 'package:filyxa/features/library/data/materials_repository.dart';
import 'package:filyxa/features/library/domain/material.dart';
import 'package:filyxa/features/library/ui/library_filters.dart';
import 'package:filyxa/features/library/ui/library_screen.dart';
import 'package:filyxa/features/session/data/user_space_repository.dart';
import 'package:filyxa/features/session/domain/user_space.dart';
import 'package:filyxa/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

const _items = [
  MaterialItem(id: '1', orgId: 'o', name: 'Drap laine froide', colorHex: '#2F4A6B', atelierStockM: 42.5,
      specs: TextileSpecs(composition: [FiberShare('WO', 62), FiberShare('PES', 38)], weightGsm: 280, weave: 'twill')),
  MaterialItem(id: '2', orgId: 'o', name: 'Flanelle grise',
      specs: TextileSpecs(composition: [FiberShare('WO', 45), FiberShare('CV', 55)], weightGsm: 320, weave: 'twill')),
  MaterialItem(id: '3', orgId: 'o', name: 'Popeline écrue',
      specs: TextileSpecs(composition: [FiberShare('CO', 100)], weightGsm: 110, weave: 'plain')),
];

final _space = UserSpace(
  profile: const Profile(id: 'u', email: 'c@a.fr', locale: 'fr', isSuperadmin: false),
  membership: const Membership(
      organization: Organization(id: 'o', name: 'A', kind: OrgKind.atelier), role: MemberRole.editor),
);

Future<ProviderContainer> _pump(WidgetTester tester, Size size) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final container = ProviderContainer(overrides: [
    userSpaceProvider.overrideWith((ref) async => _space),
    materialsProvider.overrideWith((ref) async => _items),
  ]);
  addTearDown(container.dispose);
  await tester.pumpWidget(UncontrolledProviderScope(
    container: container,
    child: const MaterialApp(
      locale: Locale('fr'),
      localizationsDelegates: [AppLocalizations.delegate, ...GlobalMaterialLocalizations.delegates],
      supportedLocales: AppLocalizations.supportedLocales,
      home: LibraryScreen(),
    ),
  ));
  await tester.pumpAndSettle();
  return container;
}

void main() {
  testWidgets('la recherche filtre instantanément et compte les résultats', (tester) async {
    await _pump(tester, const Size(1440, 900));
    await tester.enterText(find.byType(TextField).first, 'popeline');
    await tester.pump();
    expect(find.text('Popeline écrue'), findsOneWidget);
    expect(find.text('Drap laine froide'), findsNothing);
    expect(find.text('1 résultat'), findsOneWidget);
  });

  testWidgets('« Laine ≥ 50 % » : puce amovible, puis retrait', (tester) async {
    final container = await _pump(tester, const Size(1440, 900));
    container.read(libraryFilterProvider.notifier).update((f) => f.copyWith(fiber: () => 'WO', fiberMinPct: 50));
    await tester.pumpAndSettle();
    expect(find.text('Laine ≥ 50 %'), findsOneWidget);
    expect(find.text('Drap laine froide'), findsOneWidget);
    expect(find.text('Flanelle grise'), findsNothing);

    await tester.tap(find.byTooltip('Retirer le filtre Laine ≥ 50 %'));
    await tester.pumpAndSettle();
    expect(find.text('Flanelle grise'), findsOneWidget);
  });

  testWidgets('aucun résultat : effacer les filtres et la recherche', (tester) async {
    await _pump(tester, const Size(1440, 900));
    await tester.enterText(find.byType(TextField).first, 'introuvable');
    await tester.pump();
    expect(find.text('Aucun résultat'), findsWidgets);
    await tester.tap(find.widgetWithText(OutlinedButton, 'Effacer les filtres'));
    await tester.pumpAndSettle();
    expect(find.text('Drap laine froide'), findsOneWidget);
  });

  testWidgets('les filtres sont conservés au retour d\'une fiche', (tester) async {
    final container = await _pump(tester, const Size(1440, 900));
    await tester.enterText(find.byType(TextField).first, 'drap');
    container.read(libraryFilterProvider.notifier).update((f) => f.copyWith(weaves: {'twill'}));
    await tester.pumpAndSettle();

    // Départ vers une fiche puis retour : l'écran est reconstruit.
    await tester.pumpWidget(UncontrolledProviderScope(container: container, child: const SizedBox()));
    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: const MaterialApp(
        locale: Locale('fr'),
        localizationsDelegates: [AppLocalizations.delegate, ...GlobalMaterialLocalizations.delegates],
        supportedLocales: AppLocalizations.supportedLocales,
        home: LibraryScreen(),
      ),
    ));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(TextField, 'drap'), findsOneWidget);
    expect(find.text('Sergé'), findsWidgets);
    expect(find.text('Flanelle grise'), findsNothing);
  });

  testWidgets('téléphone : filtres dans une feuille, sans débordement', (tester) async {
    await _pump(tester, const Size(360, 740));
    await tester.tap(find.text('Filtres'));
    await tester.pumpAndSettle();
    expect(find.text('Toutes les fibres'), findsOneWidget);
    await tester.ensureVisible(find.text('En stock à l\'atelier'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('En stock à l\'atelier'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Afficher les résultats'));
    await tester.pumpAndSettle();
    expect(find.text('Drap laine froide'), findsOneWidget);
    expect(find.text('Popeline écrue'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
