import 'package:filyxa/app/app_shell.dart';
import 'package:filyxa/features/session/data/user_space_repository.dart';
import 'package:filyxa/features/session/domain/user_space.dart';
import 'package:filyxa/features/supplier/data/catalog_repository.dart';
import 'package:filyxa/features/supplier/data/table_reader.dart';
import 'package:filyxa/features/supplier/domain/availability.dart';
import 'package:filyxa/features/supplier/domain/supplier_reference.dart';
import 'package:filyxa/features/supplier/ui/catalog_import_screen.dart';
import 'package:filyxa/features/supplier/ui/catalog_screen.dart';
import 'package:filyxa/features/supplier/ui/reference_screen.dart';
import 'package:filyxa/features/supplier/ui/supplier_settings_screen.dart';
import 'package:filyxa/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

const _refs = [
  SupplierReference(id: 'r1', code: 'TD-SRG-280', name: 'Sergé laine froide', stockM: 340, leadTimeWeeks: 4),
  SupplierReference(id: 'r2', code: 'TD-POP-110', name: 'Popeline coton bio', stockM: 22),
  SupplierReference(id: 'r3', code: 'TD-VEL-320', name: 'Velours côtelé', stockM: 0, leadTimeWeeks: 6, mode: AvailabilityMode.exact),
  SupplierReference(id: 'r4', code: 'OLD-1', name: 'Ancienne toile', stockM: 10, retiredAt: null),
];

UserSpace _space(MemberRole role) => UserSpace(
      profile: const Profile(id: 'u', email: 'marco@t.test', locale: 'fr', isSuperadmin: false),
      membership: Membership(
        organization: const Organization(id: 'sup', name: 'Tissage', kind: OrgKind.supplier),
        role: role,
      ),
    );

Widget _app(Widget home, {MemberRole role = MemberRole.admin, List<SupplierReference> refs = _refs}) => ProviderScope(
      overrides: [
        userSpaceProvider.overrideWith((ref) async => _space(role)),
        supplierReferencesProvider.overrideWith((ref) async => refs),
        supplierReferenceProvider.overrideWith((ref, id) async => refs.where((r) => r.id == id).firstOrNull),
        supplierSettingsProvider.overrideWith((ref) async => const SupplierSettings()),
      ],
      child: MaterialApp(
        locale: const Locale('fr'),
        localizationsDelegates: const [AppLocalizations.delegate, ...GlobalMaterialLocalizations.delegates],
        supportedLocales: AppLocalizations.supportedLocales,
        home: home,
      ),
    );

Future<void> _size(WidgetTester tester, Size size) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
}

void main() {
  testWidgets('catalogue : statut calculé selon le stock et le seuil (50 m)', (tester) async {
    await _size(tester, const Size(1440, 900));
    await tester.pumpWidget(_app(const CatalogScreen()));
    await tester.pumpAndSettle();
    expect(find.text('4 références'), findsOneWidget);
    expect(find.text('Disponible'), findsOneWidget);
    expect(find.text('Stock faible'), findsNWidgets(2), reason: '22 m et 10 m');
    expect(find.text('Sur commande · 6 sem.'), findsOneWidget);
    expect(find.text('Importer un fichier'), findsOneWidget);
  });

  testWidgets('catalogue vide : invitation à importer', (tester) async {
    await tester.pumpWidget(_app(const CatalogScreen(), refs: const []));
    await tester.pumpAndSettle();
    expect(find.text('Votre catalogue est vide'), findsOneWidget);
    expect(find.text('Importer un fichier'), findsOneWidget);
  });

  testWidgets('Lecteur fournisseur : pas d\'import', (tester) async {
    await tester.pumpWidget(_app(const CatalogScreen(), role: MemberRole.viewer, refs: const []));
    await tester.pumpAndSettle();
    expect(find.text('Importer un fichier'), findsNothing);
  });

  testWidgets('import : colonnes associées, lignes prêtes et lignes en erreur', (tester) async {
    await _size(tester, const Size(1280, 2200));
    const table = TableData(
      headers: ['Codice articolo', 'Descrizione', 'Composizione', 'Giacenza'],
      rows: [
        ['A1', 'Saia lana', '62% lana 38% poliestere', '340'],
        ['', 'Senza codice', '', ''],
        ['A3', 'Composizione errata', '60% lana', ''],
      ],
    );
    await tester.pumpWidget(_app(const CatalogImportScreen(initialTable: table, initialFileName: 'catalogo.xlsx')));
    await tester.pumpAndSettle();
    expect(find.text('Fichier : catalogo.xlsx'), findsOneWidget);
    expect(find.text('1 lignes prêtes · 2 en erreur'), findsOneWidget);
    expect(find.text('Ligne 3'), findsOneWidget);
    expect(find.text('Code article manquant'), findsOneWidget);
    expect(find.textContaining('Composition illisible'), findsOneWidget);
    expect(find.text('Importer 1 référence'), findsOneWidget);
  });

  testWidgets('import : code et désignation obligatoires', (tester) async {
    await _size(tester, const Size(1280, 2200));
    const table = TableData(headers: ['Colonne A', 'Colonne B'], rows: [['x', 'y']]);
    await tester.pumpWidget(_app(const CatalogImportScreen(initialTable: table)));
    await tester.pumpAndSettle();
    expect(find.text('Champ obligatoire'), findsNWidgets(2));
    expect(find.textContaining('Importer'), findsWidgets);
    expect(find.textContaining('lignes prêtes'), findsNothing);
  });

  testWidgets('fiche référence : ce que voient les ateliers selon le mode', (tester) async {
    await _size(tester, const Size(1024, 1600));
    await tester.pumpWidget(_app(const ReferenceScreen(referenceId: 'r3')));
    await tester.pumpAndSettle();
    expect(find.text('Sur commande · 6 sem. · 0 m'), findsOneWidget, reason: 'mode exact');
    expect(find.text('Retirer du catalogue'), findsOneWidget);
  });

  testWidgets('réglages : les trois modes avec leur explication', (tester) async {
    await tester.pumpWidget(_app(const SupplierSettingsScreen()));
    await tester.pumpAndSettle();
    expect(find.text('Quantité exacte'), findsOneWidget);
    expect(find.text('Paliers'), findsOneWidget);
    expect(find.textContaining('ne voient pas la disponibilité'), findsOneWidget);
  });

  for (final size in const [Size(360, 740)]) {
    testWidgets('téléphone : catalogue, import et fiche sans débordement', (tester) async {
      await _size(tester, size);
      for (final screen in [
        const CatalogScreen(),
        const CatalogImportScreen(initialTable: TableData(headers: ['Code', 'Nom'], rows: [['A', 'B']])),
        const ReferenceScreen(referenceId: 'r1'),
        const SupplierSettingsScreen(),
      ]) {
        await tester.pumpWidget(_app(screen));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull, reason: '$screen');
      }
    });
  }

  testWidgets('navigation fournisseur : Catalogue et Compte, sans Scanner', (tester) async {
    await _size(tester, const Size(390, 844));
    final router = GoRouter(initialLocation: '/catalog', routes: [
      StatefulShellRoute.indexedStack(
        builder: (_, _, shell) => AppShell(navigationShell: shell, supplier: true),
        branches: [
          for (final p in ['/library', '/studio', '/scan', '/suppliers', '/account', '/catalog'])
            StatefulShellBranch(routes: [GoRoute(path: p, builder: (_, _) => Text('page $p'))]),
        ],
      ),
    ]);
    await tester.pumpWidget(MaterialApp.router(
      locale: const Locale('fr'),
      localizationsDelegates: const [AppLocalizations.delegate, ...GlobalMaterialLocalizations.delegates],
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: router,
    ));
    await tester.pumpAndSettle();
    expect(find.text('Catalogue'), findsOneWidget);
    expect(find.text('Compte'), findsOneWidget);
    expect(find.text('TissuTech'), findsNothing);
    expect(find.bySemanticsLabel('Scanner'), findsNothing);
    await tester.tap(find.text('Compte'));
    await tester.pumpAndSettle();
    expect(find.text('page /account'), findsOneWidget);
  });
}
