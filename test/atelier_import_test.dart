// Phase 8 : import de la base atelier et rapprochement automatique.
import 'package:filyxa/features/library/data/materials_repository.dart';
import 'package:filyxa/features/library/domain/atelier_import.dart';
import 'package:filyxa/features/library/domain/catalog_reference.dart';
import 'package:filyxa/features/library/domain/material.dart';
import 'package:filyxa/features/library/ui/atelier_import_screen.dart';
import 'package:filyxa/features/library/ui/library_screen.dart';
import 'package:filyxa/features/library/ui/link_review_screen.dart';
import 'package:filyxa/features/session/data/user_space_repository.dart';
import 'package:filyxa/features/session/domain/user_space.dart';
import 'package:filyxa/features/supplier/data/table_reader.dart';
import 'package:filyxa/features/supplier/domain/availability.dart';
import 'package:filyxa/features/supplier/domain/catalog_import.dart';
import 'package:filyxa/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

/// Dépôt factice : enregistre les appels, aucune requête réseau.
class _FakeRepo implements MaterialsRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);

  List<Map<String, dynamic>>? imported;
  final saved = <MaterialDraft>[];
  final dismissed = <String>[];

  @override
  Future<AtelierImportResult> importRows(
    String orgId,
    List<Map<String, dynamic>> payloads,
    List<int> lines, {
    void Function(int done, int total)? onProgress,
  }) async {
    imported = payloads;
    onProgress?.call(payloads.length, payloads.length);
    return AtelierImportResult(inserted: payloads.length - 1, linked: 1, pending: 1, serverErrors: [(lines.last, 'boom')]);
  }

  @override
  Future<String> save(MaterialDraft draft) async {
    saved.add(draft);
    return draft.id ?? 'new';
  }

  @override
  Future<void> dismissLink(String id) async => dismissed.add(id);
}

const _ref = CatalogReference(
  id: 'r1',
  supplierOrgId: 's',
  supplierName: 'Tissage Démo',
  code: 'TD-SRG-280',
  name: 'Sergé laine froide',
  status: AvailabilityStatus.available,
);
const _proche = CatalogReference(id: 'r2', supplierOrgId: 's', supplierName: 'Tissage Démo', code: 'TD-SRG-281', name: 'Sergé gris');

const _serge = MaterialItem(id: 'm1', orgId: 'org', name: 'Mon sergé', supplierName: 'Tissage Démo', supplierCode: 'TD-SRG', pricePerM: 18, linkPending: true);
const _velours = MaterialItem(id: 'm2', orgId: 'org', name: 'Velours', supplierCode: 'VEL-1', linkPending: true);
const _lin = MaterialItem(id: 'm3', orgId: 'org', name: 'Lin maison');

UserSpace _space(MemberRole role) => UserSpace(
      profile: const Profile(id: 'u', email: 'claire@atelier.fr', locale: 'fr', isSuperadmin: false),
      membership: Membership(
        organization: const Organization(id: 'org', name: 'Atelier Démo', kind: OrgKind.atelier),
        role: role,
      ),
    );

Widget _app(Widget home, {_FakeRepo? repo, List<MaterialItem> items = const [_serge, _velours, _lin], MemberRole role = MemberRole.editor}) =>
    ProviderScope(
      overrides: [
        userSpaceProvider.overrideWith((ref) async => _space(role)),
        materialsProvider.overrideWith((ref) async => items),
        linkedReferencesProvider.overrideWith((ref) async => const {}),
        linkCandidatesProvider.overrideWith((ref, id) async => switch (id) {
              'm1' => const [ReferenceMatch(_ref, 0.8), ReferenceMatch(_proche, 0.6)],
              _ => const <ReferenceMatch>[],
            }),
        if (repo != null) materialsRepositoryProvider.overrideWithValue(repo),
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

const _headers = ['Désignation', 'Fournisseur', 'Réf. fournisseur', 'Coloris', 'Composition', 'Grammage', 'Prix €/m', 'Stock', 'Étiquettes', 'Remarques'];

void main() {
  group('analyse', () {
    test('association automatique des colonnes de la base atelier', () {
      final m = guessAtelierMapping(_headers);
      expect(m[AtelierImportField.name], 0);
      expect(m[AtelierImportField.supplierName], 1);
      expect(m[AtelierImportField.supplierCode], 2);
      expect(m[AtelierImportField.colorName], 3);
      expect(m[AtelierImportField.composition], 4);
      expect(m[AtelierImportField.weight], 5);
      expect(m[AtelierImportField.price], 6);
      expect(m[AtelierImportField.stock], 7);
      expect(m[AtelierImportField.tags], 8);
      expect(m[AtelierImportField.notes], 9);
    });

    test('lignes valides, motifs de rejet et doublons dans le fichier', () {
      final rows = [
        ['Mon sergé', 'Tissage Démo', 'TD-SRG-280', 'Marine', '62% laine 38% polyester', '280', '18,50', '40', 'hiver, AH27', 'Toucher sec'],
        ['', 'X', '1', '', '', '', '', '', '', ''],
        ['Lin', '', '', 'Écru', '100% Lin', '9999', '', '', '', ''],
        ['Autre nom', 'tissage demo', 'td srg 280', '', '', '', '', '', '', ''],
        ['Lin maison', '', '', 'Écru', '', '', '12', '', '', ''],
      ];
      final a = analyzeAtelierRows(rows, guessAtelierMapping(_headers));
      expect(a.valid.length, 2);
      expect(a.invalid.map((r) => r.line), [3, 4, 5]);
      expect(a.invalid[0].issues.single.kind, ImportIssueKind.missingName);
      expect(a.invalid[1].issues.single.kind, ImportIssueKind.numberInvalid);
      expect(a.invalid[2].issues.single.kind, ImportIssueKind.duplicateCode, reason: 'même fournisseur et même code');

      final p = a.valid.first.payload!;
      expect(p['supplier_code'], 'TD-SRG-280');
      expect(p['price_per_m'], 18.5);
      expect(p['atelier_stock_m'], 40);
      expect(p['tags'], ['hiver', 'AH27']);
      expect((p['specs'] as Map)['weight_gsm'], 280);
      expect((p['specs'] as Map)['composition'], [
        {'fiber': 'WO', 'pct': 62.0},
        {'fiber': 'PES', 'pct': 38.0},
      ]);
      // Seul le nom est obligatoire.
      expect(a.valid.last.payload!['supplier_code'], isNull);
    });

    test('5 000 lignes analysées sans peine', () {
      final rows = [for (var i = 0; i < kMaxImportRows; i++) ['Tissu $i', 'Fourn', 'C-$i', '', '', '', '', '', '', '']];
      final a = analyzeAtelierRows(rows, guessAtelierMapping(_headers));
      expect(a.valid.length, kMaxImportRows);
    });
  });

  group('écran d\'import', () {
    const table = TableData(headers: _headers, rows: [
      ['Mon sergé', 'Tissage Démo', 'TD-SRG-280', '', '', '', '', '', '', ''],
      ['Velours', '', 'VEL-1', '', '', '', '', '', '', ''],
      ['Lin', '', '', '', '', '', '', '', '', ''],
      ['', '', '', '', '', 'x', '', '', '', ''],
    ]);

    testWidgets('aperçu puis récapitulatif « importées · reliées · à confirmer · en erreur »', (tester) async {
      await _size(tester, const Size(1024, 2000));
      final repo = _FakeRepo();
      await tester.pumpWidget(_app(const AtelierImportScreen(initialTable: table, initialFileName: 'base.xlsx'), repo: repo));
      await tester.pumpAndSettle();
      expect(find.text('3 lignes prêtes · 1 en erreur'), findsOneWidget);
      expect(find.textContaining('Ligne 5'), findsOneWidget);

      await tester.ensureVisible(find.text('Importer 3 matières'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Importer 3 matières'));
      await tester.pumpAndSettle();

      expect(repo.imported!.length, 3);
      // 2 importées (1 refusée par le serveur), 1 reliée, 1 à confirmer, 1 + 1 en erreur.
      expect(find.text('2 importées · 1 reliées à un fournisseur · 1 à confirmer · 2 en erreur'), findsOneWidget);
      expect(find.text('Confirmer 1 correspondance'), findsOneWidget);
    });

    testWidgets('Lecteur : import refusé', (tester) async {
      await tester.pumpWidget(_app(const AtelierImportScreen(initialTable: table), role: MemberRole.viewer));
      await tester.pumpAndSettle();
      expect(find.textContaining('Importer 3'), findsNothing);
    });

    testWidgets('téléphone : sans débordement', (tester) async {
      await _size(tester, const Size(360, 740));
      await tester.pumpWidget(_app(const AtelierImportScreen(initialTable: table)));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  });

  group('correspondances à confirmer', () {
    testWidgets('TissuTech : rappel des correspondances en attente', (tester) async {
      await _size(tester, const Size(1440, 900));
      await tester.pumpWidget(_app(const LibraryScreen()));
      await tester.pumpAndSettle();
      expect(find.text('2 matières importées ressemblent à des références fournisseur.'), findsOneWidget);
    });

    testWidgets('une par une : lier, puis « Aucune de ces références »', (tester) async {
      await _size(tester, const Size(1024, 1600));
      final repo = _FakeRepo();
      await tester.pumpWidget(_app(const LinkReviewScreen(), repo: repo));
      await tester.pumpAndSettle();

      expect(find.text('1 sur 2'), findsOneWidget);
      expect(find.text('Mon sergé'), findsOneWidget);
      expect(find.text('Autres références proches'), findsOneWidget);
      await tester.tap(find.text('Sergé gris'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Oui, lier cette référence'));
      await tester.pumpAndSettle();
      expect(repo.saved.single.supplierReferenceId, 'r2');
      expect(repo.saved.single.pricePerM, 18, reason: 'la couche privée est conservée');

      expect(find.text('2 sur 2'), findsOneWidget);
      expect(find.text('Aucune référence publiée ne correspond plus à cette matière.'), findsOneWidget);
      await tester.tap(find.text('Aucune de ces références'));
      await tester.pumpAndSettle();
      expect(repo.dismissed, ['m2']);
      expect(find.text('Toutes les correspondances ont été traitées.'), findsOneWidget);
    });

    testWidgets('« Plus tard » : rien n\'est enregistré', (tester) async {
      await _size(tester, const Size(1024, 1600));
      final repo = _FakeRepo();
      await tester.pumpWidget(_app(const LinkReviewScreen(), repo: repo));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Plus tard'));
      await tester.pumpAndSettle();
      expect(find.text('2 sur 2'), findsOneWidget);
      expect(repo.saved, isEmpty);
      expect(repo.dismissed, isEmpty);
    });
  });
}
