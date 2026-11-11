// Phase 9 : signalements d'erreur et notifications.
import 'package:filyxa/features/library/data/materials_repository.dart';
import 'package:filyxa/features/library/domain/catalog_reference.dart';
import 'package:filyxa/features/library/domain/material.dart';
import 'package:filyxa/features/library/ui/material_detail_screen.dart';
import 'package:filyxa/features/reports/data/reports_repository.dart';
import 'package:filyxa/features/reports/domain/error_report.dart';
import 'package:filyxa/features/reports/ui/notifications_screen.dart';
import 'package:filyxa/features/reports/ui/supplier_reports_screen.dart';
import 'package:filyxa/features/session/data/user_space_repository.dart';
import 'package:filyxa/features/session/domain/user_space.dart';
import 'package:filyxa/features/supplier/domain/availability.dart';
import 'package:filyxa/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

/// Dépôt factice : enregistre les appels, aucune requête réseau.
class _FakeReports implements ReportsRepository {
  final created = <Map<String, Object?>>[];
  final resolved = <(String, ReportStatus, String?)>[];
  var markedRead = 0;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);

  @override
  Future<void> create({
    required String materialId,
    required ReportField field,
    required String observedValue,
    String? comment,
    bool shareIdentity = false,
  }) async =>
      created.add({'material': materialId, 'field': field, 'value': observedValue, 'comment': comment, 'share': shareIdentity});

  @override
  Future<void> resolve(String reportId, ReportStatus status, String? response) async =>
      resolved.add((reportId, status, response));

  @override
  Future<void> markAllRead() async => markedRead++;
}

const _ref = CatalogReference(
  id: 'r1',
  supplierOrgId: 's',
  supplierName: 'Tissage Démo',
  code: 'TD-SRG-280',
  name: 'Sergé laine froide',
  status: AvailabilityStatus.available,
);
const _linked = MaterialItem(id: 'm1', orgId: 'org', name: 'Mon sergé', supplierReferenceId: 'r1');

final _reports = [
  ErrorReport(
    id: 'e1',
    field: ReportField.weight,
    observedValue: '300 g/m²',
    status: ReportStatus.rejected,
    response: 'Mesure faite après lavage.',
    createdAt: DateTime(2026, 11, 10),
  ),
  ErrorReport(id: 'e2', field: ReportField.composition, observedValue: '60 % WO', status: ReportStatus.open, createdAt: DateTime(2026, 11, 11)),
];

final _supplierReports = [
  SupplierErrorReport(
    id: 'e2',
    referenceId: 'r1',
    referenceCode: 'TD-SRG-280',
    referenceName: 'Sergé laine froide',
    field: ReportField.composition,
    observedValue: '60 % WO',
    comment: 'Étiquette de l\'échantillon',
    status: ReportStatus.open,
    createdAt: DateTime(2026, 11, 11),
  ),
  SupplierErrorReport(
    id: 'e3',
    referenceId: 'r1',
    referenceCode: 'TD-SRG-280',
    referenceName: 'Sergé laine froide',
    field: ReportField.width,
    observedValue: '148 cm',
    atelierName: 'Atelier Démo',
    status: ReportStatus.open,
    createdAt: DateTime(2026, 11, 9),
  ),
  SupplierErrorReport(
    id: 'e1',
    referenceId: 'r1',
    referenceCode: 'TD-SRG-280',
    referenceName: 'Sergé laine froide',
    field: ReportField.weight,
    observedValue: '300 g/m²',
    status: ReportStatus.fixed,
    createdAt: DateTime(2026, 11, 1),
  ),
];

UserSpace _space(MemberRole role, {OrgKind kind = OrgKind.atelier}) => UserSpace(
      profile: const Profile(id: 'u', email: 'claire@atelier.fr', locale: 'fr', isSuperadmin: false),
      membership: Membership(organization: Organization(id: 'org', name: 'Org', kind: kind), role: role),
    );

Widget _app(
  Widget home, {
  required _FakeReports repo,
  MemberRole role = MemberRole.editor,
  OrgKind kind = OrgKind.atelier,
  List<AppNotification> notifications = const [],
}) =>
    ProviderScope(
      overrides: [
        userSpaceProvider.overrideWith((ref) async => _space(role, kind: kind)),
        materialsProvider.overrideWith((ref) async => const [_linked]),
        materialProvider.overrideWith((ref, id) async => id == 'm1' ? _linked : null),
        linkedReferencesProvider.overrideWith((ref) async => const {'r1': _ref}),
        materialReportsProvider.overrideWith((ref, id) async => _reports),
        supplierReportsProvider.overrideWith((ref) async => _supplierReports),
        notificationsProvider.overrideWith((ref) async => notifications),
        reportsRepositoryProvider.overrideWithValue(repo),
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
  group('atelier', () {
    testWidgets('fiche liée : statut des signalements et motif du rejet', (tester) async {
      await _size(tester, const Size(1440, 1400));
      await tester.pumpWidget(_app(const MaterialDetailScreen(materialId: 'm1'), repo: _FakeReports()));
      await tester.pumpAndSettle();
      expect(find.text('SIGNALEMENTS'), findsOneWidget);
      expect(find.text('Rejeté'), findsOneWidget);
      expect(find.text('Motif : Mesure faite après lavage.'), findsOneWidget);
      expect(find.text('Ouvert'), findsOneWidget);
      expect(find.text('Signaler une erreur'), findsOneWidget);
    });

    testWidgets('signaler : champ et valeur obligatoires, identité non partagée par défaut', (tester) async {
      await _size(tester, const Size(1440, 1400));
      final repo = _FakeReports();
      await tester.pumpWidget(_app(const MaterialDetailScreen(materialId: 'm1'), repo: repo));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Signaler une erreur'));
      await tester.tap(find.text('Signaler une erreur'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Envoyer'));
      await tester.pumpAndSettle();
      expect(find.text('Champ obligatoire'), findsNWidgets(2));
      expect(repo.created, isEmpty);

      await tester.tap(find.byType(DropdownButtonFormField<ReportField>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Grammage (g/m²)').last);
      await tester.pumpAndSettle();
      await tester.enterText(find.widgetWithText(TextFormField, 'Valeur constatée'), '300 g/m²');
      await tester.tap(find.text('Envoyer'));
      await tester.pumpAndSettle();

      expect(repo.created.single, {'material': 'm1', 'field': ReportField.weight, 'value': '300 g/m²', 'comment': null, 'share': false});
      expect(find.text('Signalement envoyé au fournisseur.'), findsOneWidget);
    });

    testWidgets('Lecteur : voit les statuts, ne signale pas', (tester) async {
      await _size(tester, const Size(1440, 1400));
      await tester.pumpWidget(_app(const MaterialDetailScreen(materialId: 'm1'), repo: _FakeReports(), role: MemberRole.viewer));
      await tester.pumpAndSettle();
      expect(find.text('Rejeté'), findsOneWidget);
      expect(find.text('Signaler une erreur'), findsNothing);
    });
  });

  group('fournisseur', () {
    testWidgets('signalements ouverts, atelier anonyme sauf partage', (tester) async {
      await _size(tester, const Size(1024, 1200));
      await tester.pumpWidget(_app(const SupplierReportsScreen(), repo: _FakeReports(), kind: OrgKind.supplier, role: MemberRole.admin));
      await tester.pumpAndSettle();
      expect(find.text('Constaté : 60 % WO'), findsOneWidget);
      expect(find.textContaining('Atelier anonyme'), findsOneWidget);
      expect(find.textContaining('Atelier Démo'), findsOneWidget);
      expect(find.text('Constaté : 300 g/m²'), findsNothing, reason: 'filtre « Ouverts »');

      await tester.tap(find.text('Tous'));
      await tester.pumpAndSettle();
      expect(find.text('Constaté : 300 g/m²'), findsOneWidget);
    });

    testWidgets('rejeter exige un motif ; corriger avec un message facultatif', (tester) async {
      await _size(tester, const Size(1024, 1200));
      final repo = _FakeReports();
      await tester.pumpWidget(_app(const SupplierReportsScreen(), repo: repo, kind: OrgKind.supplier, role: MemberRole.admin));
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(OutlinedButton, 'Rejeter').first);
      await tester.pumpAndSettle();
      await tester.tap(find.descendant(of: find.byType(AlertDialog), matching: find.text('Rejeter')));
      await tester.pumpAndSettle();
      expect(find.text('Champ obligatoire'), findsOneWidget);
      await tester.enterText(find.widgetWithText(TextFormField, 'Motif du rejet'), 'Composition certifiée.');
      await tester.tap(find.descendant(of: find.byType(AlertDialog), matching: find.text('Rejeter')));
      await tester.pumpAndSettle();
      expect(repo.resolved.single, ('e2', ReportStatus.rejected, 'Composition certifiée.'));

      await tester.tap(find.text('Marquer corrigé').last);
      await tester.pumpAndSettle();
      await tester.tap(find.descendant(of: find.byType(AlertDialog), matching: find.text('Marquer corrigé')));
      await tester.pumpAndSettle();
      expect(repo.resolved.last, ('e3', ReportStatus.fixed, null));
    });

    testWidgets('Lecteur fournisseur : pas de traitement', (tester) async {
      await tester.pumpWidget(_app(const SupplierReportsScreen(), repo: _FakeReports(), kind: OrgKind.supplier, role: MemberRole.viewer));
      await tester.pumpAndSettle();
      expect(find.text('Rejeter'), findsNothing);
      expect(find.text('Marquer corrigé'), findsNothing);
    });
  });

  group('notifications', () {
    final notifications = [
      AppNotification(
        id: 'n1',
        kind: NotificationKind.reportRejected,
        materialId: 'm1',
        data: const {'name': 'Mon sergé', 'field': 'weight', 'response': 'Mesure faite après lavage.'},
        createdAt: DateTime(2026, 11, 11),
      ),
      AppNotification(
        id: 'n2',
        kind: NotificationKind.reportFixed,
        materialId: 'm1',
        data: const {'name': 'Mon sergé', 'field': 'composition'},
        createdAt: DateTime(2026, 11, 10),
        readAt: DateTime(2026, 11, 10),
      ),
    ];

    testWidgets('cloche : nombre de non lues', (tester) async {
      await tester.pumpWidget(_app(const Scaffold(body: NotificationBell()), repo: _FakeReports(), notifications: notifications));
      await tester.pumpAndSettle();
      expect(find.byTooltip('Notifications (1 non lue)'), findsOneWidget);
      expect(find.text('1'), findsOneWidget);
    });

    testWidgets('liste : réponse du fournisseur, puis marquées lues', (tester) async {
      final repo = _FakeReports();
      await tester.pumpWidget(_app(const NotificationsScreen(), repo: repo, notifications: notifications));
      await tester.pumpAndSettle();
      expect(find.text('Mon sergé : signalement sur « Grammage (g/m²) » rejeté'), findsOneWidget);
      expect(find.textContaining('Motif : Mesure faite après lavage.'), findsOneWidget);
      expect(find.text('Mon sergé : le fournisseur a corrigé « Composition »'), findsOneWidget);
      expect(repo.markedRead, 1);
    });
  });
}
