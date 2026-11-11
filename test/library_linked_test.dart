// Phase 7 : matière liée à une référence fournisseur.
import 'package:filyxa/features/library/data/materials_repository.dart';
import 'package:filyxa/features/library/domain/catalog_reference.dart';
import 'package:filyxa/features/library/domain/material.dart';
import 'package:filyxa/features/library/ui/material_detail_screen.dart';
import 'package:filyxa/features/library/ui/material_form_screen.dart';
import 'package:filyxa/features/library/ui/reference_widgets.dart';
import 'package:filyxa/features/scanner/domain/scan.dart';
import 'package:filyxa/features/session/data/user_space_repository.dart';
import 'package:filyxa/features/session/domain/user_space.dart';
import 'package:filyxa/features/supplier/domain/availability.dart';
import 'package:filyxa/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

const _ref = CatalogReference(
  id: 'r1',
  supplierOrgId: 's',
  supplierName: 'Dormeuil',
  code: 'DR4521',
  name: 'Drap laine froide',
  colorName: 'Marine',
  colorHex: '#2F4A6B',
  specs: TextileSpecs(composition: [FiberShare('WO', 100)], weightGsm: 280, widthCm: 150),
  status: AvailabilityStatus.low,
);
const _proche = CatalogReference(
  id: 'r2',
  supplierOrgId: 's',
  supplierName: 'Dormeuil',
  code: 'DR4522',
  name: 'Drap laine gris',
  stockM: 120,
  status: AvailabilityStatus.available,
);

const _linked = MaterialItem(
  id: 'm1',
  orgId: 'org',
  name: 'Drap laine froide',
  supplierName: 'Dormeuil',
  supplierCode: 'DR4521',
  specs: TextileSpecs(composition: [FiberShare('WO', 100)], weightGsm: 280, widthCm: 150),
  supplierReferenceId: 'r1',
  pricePerM: 24.5,
  tags: ['hiver'],
);
const _own = MaterialItem(id: 'm2', orgId: 'org', name: 'Popeline chemise');

UserSpace _space(MemberRole role) => UserSpace(
      profile: const Profile(id: 'u', email: 'claire@atelier.fr', locale: 'fr', isSuperadmin: false),
      membership: Membership(
        organization: const Organization(id: 'org', name: 'Atelier Démo', kind: OrgKind.atelier),
        role: role,
      ),
    );

Widget _app(Widget home, {Map<String, CatalogReference> published = const {'r1': _ref}, List<MaterialItem> items = const [_linked, _own]}) =>
    ProviderScope(
      overrides: [
        userSpaceProvider.overrideWith((ref) async => _space(MemberRole.editor)),
        materialsProvider.overrideWith((ref) async => items),
        materialProvider.overrideWith((ref, id) async => items.where((m) => m.id == id).firstOrNull),
        linkedReferencesProvider.overrideWith((ref) async => published),
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
  group('« C\'est bien cette référence ? »', () {
    Future<MatchChoice?> open(WidgetTester tester, Future<void> Function() act) async {
      MatchChoice? choice;
      var closed = false;
      await tester.pumpWidget(_app(Builder(
        builder: (context) => Scaffold(
          body: TextButton(
            onPressed: () async {
              choice = await showMatchSheet(context, const [ReferenceMatch(_ref, 1), ReferenceMatch(_proche, 0.6)]);
              closed = true;
            },
            child: const Text('ouvrir'),
          ),
        ),
      )));
      await tester.tap(find.text('ouvrir'));
      await tester.pumpAndSettle();
      await act();
      await tester.pumpAndSettle();
      expect(closed, isTrue);
      return choice;
    }

    testWidgets('meilleure proposition, références proches, disponibilité', (tester) async {
      await _size(tester, const Size(800, 1200));
      await open(tester, () async {
        expect(find.text("C'est bien cette référence ?"), findsOneWidget);
        expect(find.text('Autres références proches'), findsOneWidget);
        expect(find.text('Stock faible'), findsOneWidget);
        expect(find.textContaining('120'), findsOneWidget);
        await tester.tap(find.text('Oui, lier cette référence'));
      }).then((c) => expect(c?.reference?.id, 'r1'));
    });

    testWidgets('choisir une référence proche', (tester) async {
      await _size(tester, const Size(800, 1200));
      final choice = await open(tester, () async {
        await tester.tap(find.text('Drap laine gris'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Oui, lier cette référence'));
      });
      expect(choice?.reference?.id, 'r2');
    });

    testWidgets('« Aucune de ces références » : rien n\'est lié', (tester) async {
      await _size(tester, const Size(800, 1200));
      final choice = await open(tester, () => tester.tap(find.text('Aucune de ces références')));
      expect(choice, isNotNull);
      expect(choice!.reference, isNull);
    });
  });

  group('fiche liée', () {
    testWidgets('détail : données fournisseur, pastille et couche privée', (tester) async {
      await _size(tester, const Size(1440, 1200));
      await tester.pumpWidget(_app(const MaterialDetailScreen(materialId: 'm1')));
      await tester.pumpAndSettle();
      expect(find.text('Données fournisseur'), findsOneWidget);
      expect(find.text('Stock faible'), findsOneWidget);
      expect(find.text('INFORMATIONS DE L\'ATELIER'), findsOneWidget);
      expect(find.text('hiver'), findsOneWidget);
      expect(find.text('Lier à une référence fournisseur'), findsNothing);
      expect(find.textContaining('Référence retirée'), findsNothing);
    });

    testWidgets('détail : référence retirée, dernières valeurs conservées', (tester) async {
      await _size(tester, const Size(1440, 1200));
      await tester.pumpWidget(_app(const MaterialDetailScreen(materialId: 'm1'), published: const {}));
      await tester.pumpAndSettle();
      expect(find.text('Référence retirée par le fournisseur. Les dernières valeurs connues sont conservées.'), findsOneWidget);
      expect(find.textContaining('280'), findsWidgets);
    });

    testWidgets('détail : fiche propre à l\'atelier, liable après coup', (tester) async {
      await _size(tester, const Size(1440, 1200));
      await tester.pumpWidget(_app(const MaterialDetailScreen(materialId: 'm2')));
      await tester.pumpAndSettle();
      expect(find.text('Lier à une référence fournisseur'), findsOneWidget);
      expect(find.text('Données fournisseur'), findsNothing);
    });

    testWidgets('formulaire : champs techniques non modifiables, couche privée modifiable', (tester) async {
      await _size(tester, const Size(1024, 2400));
      await tester.pumpWidget(_app(const MaterialFormScreen(materialId: 'm1')));
      await tester.pumpAndSettle();
      expect(find.text('Tenues à jour par le fournisseur, non modifiables ici.'), findsOneWidget);
      expect(find.text('Composition'), findsNothing);
      expect(find.widgetWithText(TextFormField, 'Grammage (g/m²)'), findsNothing);
      expect(find.widgetWithText(TextFormField, 'Prix négocié (€/m)'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, 'Étiquettes'), findsOneWidget);
      expect(find.text('Délier la référence'), findsOneWidget);
    });

    testWidgets('formulaire : délier rend les champs techniques modifiables', (tester) async {
      await _size(tester, const Size(1024, 2400));
      await tester.pumpWidget(_app(const MaterialFormScreen(materialId: 'm1')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Délier la référence'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, 'Délier la référence'));
      await tester.pumpAndSettle();
      expect(find.text('Composition'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, 'Grammage (g/m²)'), findsOneWidget);
    });

    testWidgets('scan confirmé : la fiche affiche la référence liée', (tester) async {
      await _size(tester, const Size(1024, 2400));
      final prefill = const ScanPrefill(material: MaterialItem(id: '', orgId: 'org', name: '')).linkedTo(_ref);
      await tester.pumpWidget(_app(MaterialFormScreen(prefill: prefill), items: const [_own]));
      await tester.pumpAndSettle();
      expect(find.widgetWithText(TextFormField, 'Drap laine froide'), findsOneWidget);
      expect(find.text('Stock faible'), findsOneWidget);
      expect(find.text('Composition'), findsNothing);
      // Lien neuf : rien à délier, « Aucune de ces références » se fait dans la feuille.
      expect(find.text('Délier la référence'), findsNothing);
    });
  });
}
