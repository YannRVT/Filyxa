import 'package:filyxa/app/app_shell.dart';
import 'package:filyxa/l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

/// Coquille de navigation réelle, avec des pages vides à la place des sections.
Widget _shellApp({Locale locale = const Locale('fr')}) {
  GoRoute page(String path) =>
      GoRoute(path: path, builder: (_, _) => Scaffold(body: Text('page $path')));
  final router = GoRouter(
    initialLocation: '/library',
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (_, _, shell) => AppShell(navigationShell: shell),
        branches: [
          for (final path in ['/library', '/studio', '/scan', '/suppliers', '/account'])
            StatefulShellBranch(routes: [page(path)]),
        ],
      ),
    ],
  );
  return MaterialApp.router(
    locale: locale,
    localizationsDelegates: const [AppLocalizations.delegate, ...GlobalMaterialLocalizations.delegates],
    supportedLocales: AppLocalizations.supportedLocales,
    routerConfig: router,
  );
}

Future<void> _setSize(WidgetTester tester, Size size) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
}

void main() {
  testWidgets('téléphone : onglets en bas, Scanner central sans libellé visible', (tester) async {
    await _setSize(tester, const Size(390, 844));
    await tester.pumpWidget(_shellApp());
    await tester.pumpAndSettle();

    for (final label in ['TissuTech', 'Studio', 'Fournisseurs', 'Compte']) {
      expect(find.text(label), findsOneWidget, reason: label);
    }
    expect(find.bySemanticsLabel('Scanner'), findsOneWidget);
    expect(find.byType(Image), findsNothing, reason: 'pas de logo sur téléphone');

    await tester.tap(find.bySemanticsLabel('Scanner'));
    await tester.pumpAndSettle();
    expect(find.text('page /scan'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('ordinateur : barre latérale avec logo et libellés', (tester) async {
    await _setSize(tester, const Size(1440, 900));
    await tester.pumpWidget(_shellApp());
    await tester.pumpAndSettle();

    expect(find.bySemanticsLabel('Filyxa'), findsOneWidget);
    for (final label in ['TissuTech', 'Studio', 'Fournisseurs', 'Compte', 'Scanner']) {
      expect(find.text(label), findsOneWidget, reason: label);
    }
    await tester.tap(find.text('Studio'));
    await tester.pumpAndSettle();
    expect(find.text('page /studio'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('tablette : barre latérale réduite aux icônes', (tester) async {
    await _setSize(tester, const Size(800, 1000));
    await tester.pumpWidget(_shellApp());
    await tester.pumpAndSettle();

    expect(find.text('Studio'), findsNothing);
    expect(find.byTooltip('Studio'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('la navigation suit la langue choisie (roumain)', (tester) async {
    await _setSize(tester, const Size(390, 844));
    await tester.pumpWidget(_shellApp(locale: const Locale('ro')));
    await tester.pumpAndSettle();

    expect(find.text('Furnizori'), findsOneWidget);
    expect(find.text('Cont'), findsOneWidget);
  });
}
