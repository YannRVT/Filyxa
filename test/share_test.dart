// Phase 13 : lien partagé public.
import 'package:filyxa/app/redirect.dart';
import 'package:filyxa/features/library/data/materials_repository.dart';
import 'package:filyxa/features/session/data/user_space_repository.dart';
import 'package:filyxa/features/session/domain/user_space.dart';
import 'package:filyxa/features/share/data/share_repository.dart';
import 'package:filyxa/features/share/ui/share_widgets.dart';
import 'package:filyxa/features/share/ui/shared_view_screen.dart';
import 'package:filyxa/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

class _FakeShare implements ShareRepository {
  final created = <(ShareScope, String, String, int)>[];

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);

  @override
  Future<ShareLink> create(String orgId, ShareScope scope, String targetId, {required String lang, required int days}) async {
    created.add((scope, targetId, lang, days));
    return ShareLink(
      id: 'new',
      token: 'tok',
      scope: scope,
      targetId: targetId,
      lang: lang,
      expiresAt: DateTime.now().add(Duration(days: days)),
      createdAt: DateTime.now(),
    );
  }
}

const _material = {
  'id': 'mat1',
  'name': 'Sergé laine froide',
  'supplier_name': 'Tissage Démo',
  'supplier_code': 'TD-SRG-280',
  'color_name': 'Marine',
  'color_hex': '#2F4A6B',
  'linked': true,
  'composition': [
    {'fiber': 'WO', 'pct': 62},
    {'fiber': 'PES', 'pct': 38},
  ],
  'weight_gsm': 280,
  'width_cm': 150,
  'weave': 'twill',
  'care': ['wash_30', 'iron_low'],
  'certifications': ['RWS'],
  'uses': ['jacket'],
};

final _collection = SharedView(
  status: 'ok',
  lang: 'en',
  scope: ShareScope.collection,
  organization: 'Atelier Démo',
  expiresAt: DateTime(2026, 12, 11),
  content: const {
    'id': 'col1',
    'name': 'AH27',
    'models': [
      {
        'id': 'mod1',
        'name': 'Veste Arno',
        'reference': 'VA-01',
        'product_type': 'garment',
        'waste_pct': 8,
        'colorways': [
          {
            'id': 'cw1',
            'name': null,
            'position': 0,
            'quantity': 120,
            'lines': [
              {'role': 'main', 'consumption': 1.8, 'material': _material},
            ],
          },
        ],
      },
    ],
  },
);

Widget _app(Widget home, {SharedView? view, _FakeShare? repo, List<ShareLink> links = const [], Locale locale = const Locale('fr')}) =>
    ProviderScope(
      overrides: [
        if (view != null) sharedViewProvider.overrideWith((ref, token) async => view),
        userSpaceProvider.overrideWith((ref) async => UserSpace(
              profile: const Profile(id: 'u', email: 'c@a.fr', locale: 'fr', isSuperadmin: false),
              membership: Membership(
                organization: const Organization(id: 'org', name: 'Atelier Démo', kind: OrgKind.atelier),
                role: MemberRole.editor,
              ),
            )),
        materialsProvider.overrideWith((ref) async => const []),
        shareLinksProvider.overrideWith((ref) async => links),
        if (repo != null) shareRepositoryProvider.overrideWithValue(repo),
      ],
      child: MaterialApp(
        locale: locale,
        localizationsDelegates: const [AppLocalizations.delegate, ...GlobalMaterialLocalizations.delegates],
        supportedLocales: AppLocalizations.supportedLocales,
        home: home,
      ),
    );

Future<void> _phone(WidgetTester tester) async {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
}

void main() {
  group('accès', () {
    String? go(String location, {bool loggedIn = false}) => decideRedirect(RedirectInput(
          location: location,
          loggedIn: loggedIn,
          status: SpaceStatus.ready,
          isSuperadmin: false,
          isSupplier: false,
        ));

    test('la page publique s\'ouvre sans compte, et connecté', () {
      expect(go('/s/abc'), isNull);
      expect(go('/s/abc', loggedIn: true), isNull);
      expect(go('/library'), '/login');
    });

    test('adresse publique du lien', () {
      expect(shareUrl('abc'), endsWith('/s/abc'));
    });
  });

  group('page publique', () {
    testWidgets('collection sur téléphone, dans la langue du lien (et non celle du navigateur)', (tester) async {
      await _phone(tester);
      await tester.pumpWidget(_app(const SharedViewScreen(token: 't'), view: _collection));
      await tester.pumpAndSettle();
      expect(find.text('Shared by Atelier Démo'), findsOneWidget);
      expect(find.text('AH27'), findsOneWidget);
      expect(find.text('Veste Arno'), findsOneWidget);
      expect(find.text('Garment · VA-01'), findsOneWidget);
      expect(find.text('Sergé laine froide'), findsOneWidget);
      expect(find.textContaining('62 % Wool'), findsOneWidget);
      expect(find.textContaining('MAIN FABRIC'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('fiche matière', (tester) async {
      await _phone(tester);
      await tester.pumpWidget(_app(
        const SharedViewScreen(token: 't'),
        view: SharedView(status: 'ok', lang: 'fr', scope: ShareScope.material, expiresAt: DateTime(2026, 12, 1), content: _material),
      ));
      await tester.pumpAndSettle();
      expect(find.text('Sergé laine froide'), findsOneWidget);
      expect(find.textContaining('280 g/m²'), findsOneWidget);
      expect(find.text('Données fournisseur'), findsOneWidget);
    });

    testWidgets('lien expiré : explication', (tester) async {
      await tester.pumpWidget(_app(
        const SharedViewScreen(token: 't'),
        view: SharedView(status: 'expired', lang: 'it', expiresAt: DateTime(2026, 10, 1)),
      ));
      await tester.pumpAndSettle();
      expect(find.text('Questo link è scaduto'), findsOneWidget);
      expect(find.textContaining('01/10/2026'), findsOneWidget);
    });

    testWidgets('lien révoqué, lien inconnu', (tester) async {
      await tester.pumpWidget(_app(const SharedViewScreen(token: 't'), view: const SharedView(status: 'revoked', lang: 'fr')));
      await tester.pumpAndSettle();
      expect(find.text('Ce lien a été révoqué'), findsOneWidget);

      await tester.pumpWidget(_app(const SharedViewScreen(token: 'x'), view: const SharedView(status: 'not_found')));
      await tester.pumpAndSettle();
      expect(find.text('Lien introuvable'), findsOneWidget);
    });
  });

  group('gestion des liens', () {
    testWidgets('créer un lien : langue choisie, 30 jours par défaut', (tester) async {
      final repo = _FakeShare();
      await tester.pumpWidget(_app(
        const Scaffold(body: ShareDialog(scope: ShareScope.model, targetId: 'mod1')),
        repo: repo,
      ));
      await tester.pumpAndSettle();
      expect(find.text('Aucun lien actif.'), findsOneWidget);
      await tester.tap(find.byType(DropdownButtonFormField<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Português').last);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Créer le lien'));
      await tester.pumpAndSettle();
      expect(repo.created.single, (ShareScope.model, 'mod1', 'pt', 30));
    });

    testWidgets('liens actifs : adresse, langue, expiration, révoquer', (tester) async {
      final link = ShareLink(
        id: 'l1',
        token: 'abc123',
        scope: ShareScope.material,
        targetId: 'mat1',
        lang: 'ro',
        expiresAt: DateTime(2099, 1, 15),
        createdAt: DateTime(2026, 11, 11),
      );
      final expired = ShareLink(
        id: 'l2',
        token: 'old',
        scope: ShareScope.material,
        targetId: 'mat1',
        lang: 'fr',
        expiresAt: DateTime(2020, 1, 1),
        createdAt: DateTime(2019, 12, 1),
      );
      await tester.pumpWidget(_app(const ShareLinksScreen(), links: [link, expired]));
      await tester.pumpAndSettle();
      expect(find.textContaining('/s/abc123'), findsOneWidget);
      expect(find.textContaining('/s/old'), findsNothing, reason: 'les liens expirés ne sont pas listés');
      expect(find.text('Română · Expire le 15/01/2099'), findsOneWidget);
      expect(find.text('Révoquer'), findsOneWidget);
      expect(find.text('Modifier l\'expiration'), findsOneWidget);
    });
  });
}
