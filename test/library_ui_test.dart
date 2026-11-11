import 'package:filyxa/features/library/data/materials_repository.dart';
import 'package:filyxa/features/library/domain/material.dart';
import 'package:filyxa/features/library/ui/library_screen.dart';
import 'package:filyxa/features/library/ui/material_detail_screen.dart';
import 'package:filyxa/features/library/ui/material_form_screen.dart';
import 'package:filyxa/features/session/data/user_space_repository.dart';
import 'package:filyxa/features/session/domain/user_space.dart';
import 'package:filyxa/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

const _drap = MaterialItem(
  id: 'm1',
  orgId: 'org',
  name: 'Drap laine froide',
  supplierName: 'Dormeuil',
  supplierCode: 'DR4521',
  colorName: 'Marine',
  colorHex: '#2F4A6B',
  atelierStockM: 42.5,
  notes: 'Toucher sec.',
  specs: TextileSpecs(
    composition: [FiberShare('WO', 62), FiberShare('PES', 38)],
    weightGsm: 280,
    widthCm: 150,
    weave: 'twill',
    care: ['iron_low', 'wash_30'],
    certifications: ['RWS'],
    uses: ['jacket'],
  ),
);
const _popeline = MaterialItem(
  id: 'm2',
  orgId: 'org',
  name: 'Popeline chemise',
  specs: TextileSpecs(composition: [FiberShare('CO', 100)], weightGsm: 110),
);

UserSpace _space(MemberRole role) => UserSpace(
      profile: const Profile(id: 'u', email: 'claire@atelier.fr', locale: 'fr', isSuperadmin: false),
      membership: Membership(
        organization: const Organization(id: 'org', name: 'Atelier Démo', kind: OrgKind.atelier),
        role: role,
      ),
    );

Widget _app(Widget home, {MemberRole role = MemberRole.editor, List<MaterialItem> items = const [_drap, _popeline], Locale locale = const Locale('fr')}) =>
    ProviderScope(
      overrides: [
        userSpaceProvider.overrideWith((ref) async => _space(role)),
        materialsProvider.overrideWith((ref) async => items),
        materialProvider.overrideWith((ref, id) async => items.where((m) => m.id == id).firstOrNull),
      ],
      child: MaterialApp(
        locale: locale,
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
  group('TissuTech vide', () {
    testWidgets('Éditeur : scanner, importer ou saisir à la main', (tester) async {
      await tester.pumpWidget(_app(const LibraryScreen(), items: const []));
      await tester.pumpAndSettle();
      expect(find.text('Votre TissuTech est vide'), findsOneWidget);
      expect(find.text('Scanner un échantillon'), findsOneWidget);
      expect(find.text('Importer un fichier Excel'), findsOneWidget);
      expect(find.text('Saisir à la main'), findsOneWidget);
    });

    testWidgets('Lecteur : message sans action', (tester) async {
      await tester.pumpWidget(_app(const LibraryScreen(), items: const [], role: MemberRole.viewer));
      await tester.pumpAndSettle();
      expect(find.textContaining('Les éditeurs de votre atelier'), findsOneWidget);
      expect(find.text('Scanner un échantillon'), findsNothing);
      expect(find.text('Saisir à la main'), findsNothing);
    });
  });

  for (final size in const [Size(360, 740), Size(1440, 900)]) {
    testWidgets('galerie puis tableau (${size.width.toInt()} px)', (tester) async {
      await _size(tester, size);
      await tester.pumpWidget(_app(const LibraryScreen()));
      await tester.pumpAndSettle();

      expect(find.text('2 matières'), findsOneWidget);
      expect(find.text('Drap laine froide'), findsOneWidget);
      expect(find.text('62 % WO · 38 % PES'), findsOneWidget);
      expect(tester.takeException(), isNull);

      await tester.tap(find.byTooltip('Tableau'));
      await tester.pumpAndSettle();
      expect(find.text('DR4521'), findsOneWidget);
      expect(find.text('42,5 m'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('Lecteur : pas de bouton « Nouvelle matière »', (tester) async {
    await _size(tester, const Size(1440, 900));
    await tester.pumpWidget(_app(const LibraryScreen(), role: MemberRole.viewer));
    await tester.pumpAndSettle();
    expect(find.text('Nouvelle matière'), findsNothing);
  });

  group('fiche', () {
    for (final size in const [Size(360, 740), Size(1440, 900)]) {
      testWidgets('caractéristiques, entretien et stock (${size.width.toInt()} px)', (tester) async {
        await _size(tester, size);
        await tester.pumpWidget(_app(const MaterialDetailScreen(materialId: 'm1')));
        await tester.pumpAndSettle();

        expect(find.text('62 % WO · 38 % PES'), findsOneWidget);
        expect(find.text('62 % Laine, 38 % Polyester'), findsOneWidget);
        expect(find.text('280 g/m²'), findsOneWidget);
        expect(find.text('Sergé'), findsOneWidget);
        expect(find.text('Lavage 30 °C'), findsOneWidget);
        expect(find.text('Repassage doux (110 °C)'), findsOneWidget);
        expect(find.text('42,5 m'), findsOneWidget);
        expect(find.text('Modifier le stock'), findsOneWidget);
        expect(find.byTooltip('Modifier'), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    }

    testWidgets('la même fiche s\'affiche en anglais (codes normalisés)', (tester) async {
      await tester.pumpWidget(_app(const MaterialDetailScreen(materialId: 'm1'), locale: const Locale('en')));
      await tester.pumpAndSettle();
      expect(find.text('62 % Wool, 38 % Polyester'), findsOneWidget);
      expect(find.text('Twill'), findsOneWidget);
      expect(find.text('Wash 30 °C'), findsOneWidget);
      expect(find.text('42.5 m'), findsOneWidget);
    });

    testWidgets('Lecteur : ni modification ni stock éditable', (tester) async {
      await tester.pumpWidget(_app(const MaterialDetailScreen(materialId: 'm1'), role: MemberRole.viewer));
      await tester.pumpAndSettle();
      expect(find.text('Modifier le stock'), findsNothing);
      expect(find.byTooltip('Modifier'), findsNothing);
    });

    testWidgets('matière introuvable', (tester) async {
      await tester.pumpWidget(_app(const MaterialDetailScreen(materialId: 'inconnue')));
      await tester.pumpAndSettle();
      expect(find.textContaining('n\'existe plus'), findsOneWidget);
    });
  });

  group('formulaire', () {
    testWidgets('nom obligatoire et composition à 100 %', (tester) async {
      await _size(tester, const Size(1024, 2400));
      await tester.pumpWidget(_app(const MaterialFormScreen()));
      await tester.pumpAndSettle();

      // Une fibre à 60 % seulement.
      await tester.tap(find.byType(DropdownButtonFormField<String>).first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Laine (WO)').last);
      await tester.pumpAndSettle();
      await tester.enterText(find.widgetWithText(TextFormField, '%'), '60');
      await tester.pump();
      expect(find.text('Total : 60 %'), findsOneWidget);

      await tester.ensureVisible(find.text('Enregistrer'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Enregistrer'));
      await tester.pumpAndSettle();
      expect(find.text('Champ obligatoire'), findsOneWidget);
      expect(find.textContaining('Le total doit faire 100 %'), findsOneWidget);
    });

    testWidgets('couleur et nombres hors bornes refusés', (tester) async {
      await _size(tester, const Size(1024, 2400));
      await tester.pumpWidget(_app(const MaterialFormScreen()));
      await tester.pumpAndSettle();
      await tester.enterText(find.widgetWithText(TextFormField, 'Couleur (#RRGGBB)'), '#12');
      await tester.enterText(find.widgetWithText(TextFormField, 'Grammage (g/m²)'), '5000');
      await tester.ensureVisible(find.text('Enregistrer'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Enregistrer'));
      await tester.pumpAndSettle();
      expect(find.textContaining('Format #RRGGBB'), findsOneWidget);
      expect(find.text('Nombre entre 1 et 2000'), findsOneWidget);
    });

    testWidgets('modification : les valeurs existantes sont reprises', (tester) async {
      await _size(tester, const Size(1024, 2400));
      await tester.pumpWidget(_app(const MaterialFormScreen(materialId: 'm1')));
      await tester.pumpAndSettle();
      expect(find.text('Modifier la matière'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, 'Drap laine froide'), findsOneWidget);
      expect(find.text('Total : 100 %'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, '42,5'), findsOneWidget);
    });

    testWidgets('Lecteur : formulaire refusé', (tester) async {
      await tester.pumpWidget(_app(const MaterialFormScreen(), role: MemberRole.viewer));
      await tester.pumpAndSettle();
      expect(find.text('Enregistrer'), findsNothing);
      expect(find.textContaining('réservée aux éditeurs'), findsOneWidget);
    });

    testWidgets('pas de débordement sur téléphone', (tester) async {
      await _size(tester, const Size(360, 740));
      await tester.pumpWidget(_app(const MaterialFormScreen(materialId: 'm1')));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  });
}
