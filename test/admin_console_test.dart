// Phase 14 : console super-admin — offres, quotas et usage.
import 'package:filyxa/app/redirect.dart';
import 'package:filyxa/features/admin/data/admin_repository.dart';
import 'package:filyxa/features/admin/ui/admin_screen.dart';
import 'package:filyxa/features/session/data/user_space_repository.dart';
import 'package:filyxa/features/session/domain/user_space.dart';
import 'package:filyxa/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

class _FakeAdmin implements AdminRepository {
  final plans = <(String, String, int?)>[];

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);

  @override
  Future<void> setPlan(String orgId, String plan, int? quota) async => plans.add((orgId, plan, quota));
}

final _orgs = [
  AdminOrganization(
    organization: const Organization(id: 'a', name: 'Atelier Démo', kind: OrgKind.atelier),
    memberCount: 3,
    createdAt: DateTime(2026, 11, 1),
  ),
  AdminOrganization(
    organization: const Organization(id: 's', name: 'Tissage Démo', kind: OrgKind.supplier),
    memberCount: 1,
    createdAt: DateTime(2026, 11, 1),
  ),
];

const _usage = {
  'a': OrgUsage(orgId: 'a', plan: 'pilot', scanQuota: 300, scans: 250, members: 3, items: 212, inputTokens: 1000000, outputTokens: 100000, costUsd: 6),
  's': OrgUsage(orgId: 's', plan: 'pilot', scanQuota: 300, members: 1, items: 3),
};

Widget _app(_FakeAdmin repo) => ProviderScope(
      overrides: [
        userSpaceProvider.overrideWith((ref) async => const UserSpace(
              profile: Profile(id: 'su', email: 'super@filyxa.local', locale: 'fr', isSuperadmin: true),
            )),
        adminOrganizationsProvider.overrideWith((ref) async => _orgs),
        adminUsageProvider.overrideWith((ref) async => _usage),
        aiPricingProvider.overrideWith((ref) async => const AiPricing(inputPerMtok: 4, outputPerMtok: 20)),
        adminRepositoryProvider.overrideWithValue(repo),
      ],
      child: MaterialApp(
        locale: const Locale('fr'),
        localizationsDelegates: const [AppLocalizations.delegate, ...GlobalMaterialLocalizations.delegates],
        supportedLocales: AppLocalizations.supportedLocales,
        home: const AdminScreen(),
      ),
    );

void main() {
  test('la console est réservée au super-admin', () {
    String? go({required bool superadmin}) => decideRedirect(RedirectInput(
          location: '/admin',
          loggedIn: true,
          status: SpaceStatus.ready,
          isSuperadmin: superadmin,
          isSupplier: false,
        ));
    expect(go(superadmin: false), '/library');
    expect(go(superadmin: true), isNull);
  });

  testWidgets('usage du mois : scans face au quota, contenu, jetons et coût', (tester) async {
    tester.view.physicalSize = const Size(1280, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(_app(_FakeAdmin()));
    await tester.pumpAndSettle();
    expect(find.text('250 / 300 scans'), findsOneWidget);
    expect(find.textContaining('212 matières'), findsOneWidget);
    expect(find.textContaining('3 références'), findsOneWidget);
    expect(find.textContaining(RegExp(r'Coût IA estimé : 6,00\s\$')), findsOneWidget);
    expect(find.textContaining(RegExp(r'toutes organisations : 6,00\s\$')), findsOneWidget);
    expect(find.textContaining(RegExp(r'4,00\s\$ / 20,00\s\$')), findsOneWidget);
  });

  testWidgets('changer l\'offre : quota par défaut proposé, appel serveur', (tester) async {
    tester.view.physicalSize = const Size(1280, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final repo = _FakeAdmin();
    await tester.pumpWidget(_app(repo));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Modifier l\'offre').first);
    await tester.pumpAndSettle();
    await tester.tap(find.byType(DropdownButtonFormField<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Pro · 3000').last);
    await tester.pumpAndSettle();
    expect(find.widgetWithText(TextField, '3000'), findsOneWidget);
    await tester.tap(find.text('Enregistrer'));
    await tester.pumpAndSettle();
    expect(repo.plans.single, ('a', 'pro', 3000));
    expect(find.textContaining('s\'applique dès maintenant'), findsOneWidget);
  });
}
