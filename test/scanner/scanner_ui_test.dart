import 'package:filyxa/features/library/data/materials_repository.dart';
import 'package:filyxa/features/library/domain/material.dart';
import 'package:filyxa/features/library/ui/material_form_screen.dart';
import 'package:filyxa/features/scanner/data/scanner_repository.dart';
import 'package:filyxa/features/scanner/domain/scan.dart';
import 'package:filyxa/features/scanner/ui/scanner_screen.dart';
import 'package:filyxa/features/session/data/user_space_repository.dart';
import 'package:filyxa/features/session/domain/user_space.dart';
import 'package:filyxa/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

UserSpace _space(MemberRole role) => UserSpace(
      profile: const Profile(id: 'u', email: 'c@a.fr', locale: 'fr', isSuperadmin: false),
      membership: Membership(organization: const Organization(id: 'o', name: 'A', kind: OrgKind.atelier), role: role),
    );

Widget _app(Widget home, {MemberRole role = MemberRole.editor, ScanUsage? usage, List<MaterialItem> materials = const []}) =>
    ProviderScope(
      overrides: [
        userSpaceProvider.overrideWith((ref) async => _space(role)),
        scanUsageProvider.overrideWith((ref) async => usage),
        materialsProvider.overrideWith((ref) async => materials),
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
  group('scanner', () {
    testWidgets('Éditeur : photo, import et saisie à la main, usage du mois', (tester) async {
      await tester.pumpWidget(_app(const ScannerScreen(), usage: const ScanUsage(scans: 12, quota: 300)));
      await tester.pumpAndSettle();
      expect(find.text('Prendre une photo'), findsOneWidget);
      expect(find.text('Importer une photo'), findsOneWidget);
      expect(find.text('Saisir à la main'), findsOneWidget);
      expect(find.text('12 / 300 scans ce mois-ci'), findsOneWidget);
    });

    testWidgets('Lecteur : pas de scan', (tester) async {
      await tester.pumpWidget(_app(const ScannerScreen(), role: MemberRole.viewer));
      await tester.pumpAndSettle();
      expect(find.text('Prendre une photo'), findsNothing);
      expect(find.textContaining('réservée aux éditeurs'), findsOneWidget);
    });

    testWidgets('80 % : avertissement pour l\'admin', (tester) async {
      await tester.pumpWidget(_app(const ScannerScreen(), role: MemberRole.admin, usage: const ScanUsage(scans: 250, quota: 300)));
      await tester.pumpAndSettle();
      expect(find.textContaining('83 % du quota'), findsOneWidget);
    });

    testWidgets('80 % : pas d\'avertissement pour un Éditeur', (tester) async {
      await tester.pumpWidget(_app(const ScannerScreen(), role: MemberRole.editor, usage: const ScanUsage(scans: 250, quota: 300)));
      await tester.pumpAndSettle();
      expect(find.textContaining('% du quota'), findsNothing);
    });

    testWidgets('100 % : scan bloqué, saisie à la main possible', (tester) async {
      await tester.pumpWidget(_app(const ScannerScreen(), usage: const ScanUsage(scans: 300, quota: 300)));
      await tester.pumpAndSettle();
      expect(find.textContaining('Quota mensuel de scans atteint'), findsOneWidget);
      expect(tester.widget<FilledButton>(find.widgetWithText(FilledButton, 'Prendre une photo')).onPressed, isNull);
      expect(tester.widget<TextButton>(find.widgetWithText(TextButton, 'Saisir à la main')).onPressed, isNotNull);
    });

    testWidgets('téléphone : sans débordement', (tester) async {
      await _size(tester, const Size(360, 740));
      await tester.pumpWidget(_app(const ScannerScreen(), role: MemberRole.admin, usage: const ScanUsage(scans: 250, quota: 300)));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  });

  group('fiche pré-remplie', () {
    const prefill = ScanPrefill(
      material: MaterialItem(
        id: '',
        orgId: '',
        name: 'Sergé laine froide',
        supplierCode: 'TD-SRG-280',
        specs: TextileSpecs(composition: [FiberShare('WO', 62), FiberShare('PES', 38)], weightGsm: 280, weave: 'twill'),
      ),
      uncertain: {'weight_gsm'},
    );

    testWidgets('valeurs reprises, champ incertain signalé, signalement retiré après correction', (tester) async {
      await _size(tester, const Size(1024, 2600));
      await tester.pumpWidget(_app(const MaterialFormScreen(prefill: prefill)));
      await tester.pumpAndSettle();
      expect(find.textContaining('pré-remplie par le scan'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, 'Sergé laine froide'), findsOneWidget);
      expect(find.text('Total : 100 %'), findsOneWidget);
      expect(find.text('Lu avec peu de certitude : à vérifier'), findsOneWidget);

      await tester.enterText(find.widgetWithText(TextFormField, 'Grammage (g/m²)'), '285');
      await tester.pump();
      expect(find.text('Lu avec peu de certitude : à vérifier'), findsNothing);
    });

    testWidgets('doublon : avertissement et lien vers la fiche existante', (tester) async {
      await _size(tester, const Size(1024, 2600));
      await tester.pumpWidget(_app(
        const MaterialFormScreen(prefill: prefill),
        materials: const [MaterialItem(id: 'm9', orgId: 'o', name: 'Sergé déjà là', supplierCode: 'td srg 280')],
      ));
      await tester.pumpAndSettle();
      expect(find.textContaining('existe déjà : « Sergé déjà là »'), findsOneWidget);
      expect(find.text('Ouvrir la fiche existante'), findsOneWidget);
    });
  });
}
