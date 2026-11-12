// Phase 10 : Studio — collections, modèles, coloris, besoin.
import 'package:filyxa/features/library/data/materials_repository.dart';
import 'package:filyxa/features/library/domain/material.dart';
import 'package:filyxa/features/session/data/user_space_repository.dart';
import 'package:filyxa/features/session/domain/user_space.dart';
import 'package:filyxa/features/studio/data/studio_repository.dart';
import 'package:filyxa/features/studio/domain/studio.dart';
import 'package:filyxa/features/studio/ui/collection_screen.dart';
import 'package:filyxa/features/studio/ui/model_screen.dart';
import 'package:filyxa/features/studio/ui/studio_screen.dart';
import 'package:filyxa/features/studio/ui/studio_widgets.dart';
import 'package:filyxa/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

/// Dépôt factice : enregistre les écritures, aucune requête réseau.
class _FakeStudio implements StudioRepository {
  _FakeStudio(this.current);

  StudioModel? current;
  final calls = <String>[];

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);

  @override
  Future<StudioModel?> model(String id) async => current;

  @override
  Future<void> updateModel(String id, {String? name, String? reference, double? wastePct, int? prototypeCount}) async =>
      calls.add('model waste=$wastePct');

  @override
  Future<void> updateColorway(String id, {String? name, int? quantity, String? colorHex}) async => calls.add('colorway $id qty=$quantity name=$name');

  @override
  Future<void> updateLine(String id, {double? consumption, String? role, double? protoLossPct}) async =>
      calls.add('line $id cons=$consumption');

  @override
  Future<String> addColorway(String modelId, String name, {String? copyFrom}) async {
    calls.add('add colorway $name from $copyFrom');
    return 'new';
  }
}

const _serge = MaterialItem(id: 'mat1', orgId: 'org', name: 'Sergé laine');
const _doublure = MaterialItem(id: 'mat2', orgId: 'org', name: 'Doublure viscose');

const _veste = StudioModel(
  id: 'mod1',
  collectionId: 'col1',
  name: 'Veste Arno',
  productType: ProductType.garment,
  colorways: [
    Colorway(id: 'cw1', lines: [
      BomLine(id: 'l1', materialId: 'mat1', role: 'main', consumption: 1.8),
      BomLine(id: 'l2', materialId: 'mat2', role: 'Doublure manches', consumption: 0.5),
    ]),
  ],
);

UserSpace _space(MemberRole role) => UserSpace(
      profile: const Profile(id: 'u', email: 'claire@atelier.fr', locale: 'fr', isSuperadmin: false),
      membership: Membership(
        organization: const Organization(id: 'org', name: 'Atelier Démo', kind: OrgKind.atelier),
        role: role,
      ),
    );

Widget _app(
  Widget home, {
  _FakeStudio? repo,
  StudioModel? model = _veste,
  MemberRole role = MemberRole.editor,
  List<StudioCollection> collections = const [],
  List<StudioModel> models = const [],
}) =>
    ProviderScope(
      overrides: [
        userSpaceProvider.overrideWith((ref) async => _space(role)),
        materialsProvider.overrideWith((ref) async => const [_serge, _doublure]),
        modelProvider.overrideWith((ref, id) async => model),
        collectionsProvider.overrideWith((ref) async => collections),
        collectionProvider.overrideWith((ref, id) async => const StudioCollection(id: 'col1', name: 'AH27')),
        collectionModelsProvider.overrideWith((ref, id) async => models),
        customRolesProvider.overrideWith((ref) async => const ['Doublure manches']),
        studioRepositoryProvider.overrideWithValue(repo ?? _FakeStudio(model)),
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
  group('besoin en matière', () {
    test('consommation × quantité × (1 + marge)', () {
      expect(lineRequirement(1.8, 100, 8), closeTo(194.4, 1e-9));
      expect(lineRequirement(1.8, 100, 0), closeTo(180, 1e-9));
      expect(lineRequirement(2, 0, 8), 0);
    });

    test('total par matière, tous coloris confondus', () {
      const m = StudioModel(
        id: 'm',
        collectionId: 'c',
        name: 'M',
        productType: ProductType.garment,
        wastePct: 10,
        colorways: [
          Colorway(id: 'a', quantity: 100, lines: [BomLine(id: '1', materialId: 'x', role: 'main', consumption: 2)]),
          Colorway(id: 'b', quantity: 50, lines: [
            BomLine(id: '2', materialId: 'x', role: 'main', consumption: 2),
            BomLine(id: '3', materialId: 'y', role: 'lining', consumption: 1),
          ]),
        ],
      );
      final totals = requirementsByMaterial(m);
      expect(totals['x'], closeTo(330, 1e-9)); // (200 + 100) × 1,1
      expect(totals['y'], closeTo(55, 1e-9));
    });

    test('les rôles proposés dépendent du type de produit', () {
      expect(ProductType.footwear.roles, containsAll(['upper', 'lining', 'outsole']));
      expect(ProductType.garment.roles, isNot(contains('outsole')));
      expect(ProductType.parse('leather_goods'), ProductType.leatherGoods);
    });
  });

  group('modèle', () {
    testWidgets('un seul coloris : pas d\'onglets, « Décliner en coloris »', (tester) async {
      await _size(tester, const Size(1280, 1400));
      await tester.pumpWidget(_app(const ModelScreen(modelId: 'mod1')));
      await tester.pumpAndSettle();
      expect(find.byType(ChoiceChip), findsNothing);
      expect(find.text('Décliner en coloris'), findsOneWidget);
      expect(find.text('Sergé laine'), findsWidgets);
      // Nomenclature et carte Prototypage citent chacune le rôle.
      expect(find.textContaining('Tissu principal'), findsNWidgets(2));
      expect(find.textContaining('Doublure manches'), findsNWidgets(2), reason: 'rôle libre de l\'atelier');
    });

    testWidgets('deux coloris : onglets, chacun ses matières', (tester) async {
      await _size(tester, const Size(1280, 1400));
      final model = _veste.copyWith(colorways: [
        const Colorway(id: 'cw1', name: 'Marine', lines: [BomLine(id: 'l1', materialId: 'mat1', role: 'main', consumption: 1.8)]),
        const Colorway(id: 'cw2', name: 'Noir', lines: [BomLine(id: 'l3', materialId: 'mat2', role: 'main', consumption: 2)]),
      ]);
      await tester.pumpWidget(_app(const ModelScreen(modelId: 'mod1'), model: model));
      await tester.pumpAndSettle();
      expect(find.widgetWithText(ChoiceChip, 'Marine'), findsOneWidget);
      expect(find.widgetWithText(ChoiceChip, 'Noir'), findsOneWidget);
      expect(find.text('Décliner en coloris'), findsNothing);
      await tester.tap(find.widgetWithText(ChoiceChip, 'Noir'));
      await tester.pumpAndSettle();
      expect(find.widgetWithText(TextField, '2'), findsOneWidget);
    });

    testWidgets('besoin recalculé à chaque frappe, puis enregistré', (tester) async {
      await _size(tester, const Size(1280, 1400));
      final repo = _FakeStudio(_veste);
      await tester.pumpWidget(_app(const ModelScreen(modelId: 'mod1'), repo: repo));
      await tester.pumpAndSettle();

      await tester.enterText(find.widgetWithText(TextField, 'Quantité prévue (pièces)'), '100');
      await tester.pump();
      expect(find.textContaining('Besoin : 194,4 m'), findsOneWidget, reason: '1,8 × 100 × 1,08');
      expect(find.text('194,4 m'), findsOneWidget, reason: 'total par matière');

      await tester.enterText(find.widgetWithText(TextField, 'Marge de perte (%)'), '10');
      await tester.pump();
      expect(find.textContaining('Besoin : 198 m'), findsOneWidget);

      await tester.enterText(find.widgetWithText(TextField, '0,5'), '0,6');
      await tester.pump();
      expect(find.textContaining('Besoin : 66 m'), findsOneWidget);

      expect(repo.calls, isEmpty, reason: 'enregistrement après une pause');
      await tester.pump(kStudioSaveDelay + const Duration(milliseconds: 50));
      expect(repo.calls, containsAll(['colorway cw1 qty=100 name=null', 'model waste=10.0', 'line l2 cons=0.6']));
    });

    testWidgets('décliner : on nomme le coloris actuel et le nouveau', (tester) async {
      await _size(tester, const Size(1280, 1400));
      final repo = _FakeStudio(_veste);
      await tester.pumpWidget(_app(const ModelScreen(modelId: 'mod1'), repo: repo));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Décliner en coloris'));
      await tester.pumpAndSettle();
      await tester.enterText(find.widgetWithText(TextFormField, 'Coloris actuel'), 'Marine');
      await tester.enterText(find.widgetWithText(TextFormField, 'Nouveau coloris'), 'Noir');
      await tester.tap(find.widgetWithText(FilledButton, 'Ajouter'));
      await tester.pumpAndSettle();
      expect(repo.calls, ['colorway cw1 qty=null name=Marine', 'add colorway Noir from cw1']);
    });

    testWidgets('modèle sans matière : action suivante proposée', (tester) async {
      await _size(tester, const Size(1280, 1400));
      const empty = StudioModel(id: 'mod1', collectionId: 'col1', name: 'Derby', productType: ProductType.footwear, colorways: [Colorway(id: 'cw1')]);
      await tester.pumpWidget(_app(const ModelScreen(modelId: 'mod1'), model: empty));
      await tester.pumpAndSettle();
      expect(find.text('Aucune matière dans ce modèle'), findsOneWidget);
      await tester.tap(find.widgetWithText(FilledButton, 'Ajouter une matière'));
      await tester.pumpAndSettle();

      // Rôles d'une chaussure, plus les rôles ajoutés par l'atelier.
      await tester.tap(find.byType(DropdownButtonFormField<String>));
      await tester.pumpAndSettle();
      expect(find.text('Tige'), findsWidgets);
      expect(find.text('Semelle'), findsWidgets);
      expect(find.text('Doublure manches'), findsWidgets);
      expect(find.text('Autre rôle…'), findsWidgets);
      expect(find.text('Tissu principal'), findsNothing);
    });

    testWidgets('Lecteur : consultation sans modification', (tester) async {
      await _size(tester, const Size(1280, 1400));
      await tester.pumpWidget(_app(const ModelScreen(modelId: 'mod1'), role: MemberRole.viewer));
      await tester.pumpAndSettle();
      expect(find.byType(TextField), findsNothing);
      expect(find.text('Décliner en coloris'), findsNothing);
      expect(find.text('Ajouter une matière'), findsNothing);
      expect(find.byType(PopupMenuButton<String>), findsNothing);
      expect(find.text('1,8 m'), findsOneWidget);
    });

    testWidgets('téléphone : sans débordement', (tester) async {
      await _size(tester, const Size(360, 740));
      await tester.pumpWidget(_app(const ModelScreen(modelId: 'mod1')));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  });

  group('alertes', () {
    testWidgets('le modèle affiche ses alertes, chiffrées, et la collection leur nombre', (tester) async {
      await _size(tester, const Size(1280, 1600));
      const laine = MaterialItem(id: 'mat1', orgId: 'org', name: 'Sergé laine', specs: TextileSpecs(weightGsm: 200, care: ['wash_30']));
      const lourde = MaterialItem(id: 'mat2', orgId: 'org', name: 'Satin lourd', specs: TextileSpecs(weightGsm: 350, care: ['no_wash', 'dryclean_p']));
      const model = StudioModel(
        id: 'mod1',
        collectionId: 'col1',
        name: 'Veste Arno',
        productType: ProductType.garment,
        colorways: [
          Colorway(id: 'cw1', quantity: 10, lines: [
            BomLine(id: 'l1', materialId: 'mat1', role: 'main', consumption: 1),
            BomLine(id: 'l2', materialId: 'mat2', role: 'lining', consumption: 1),
          ]),
        ],
      );
      Widget app(Widget home) => ProviderScope(
            overrides: [
              userSpaceProvider.overrideWith((ref) async => _space(MemberRole.editor)),
              materialsProvider.overrideWith((ref) async => const [laine, lourde]),
              modelProvider.overrideWith((ref, id) async => model),
              collectionProvider.overrideWith((ref, id) async => const StudioCollection(id: 'col1', name: 'AH27')),
              collectionModelsProvider.overrideWith((ref, id) async => const [model]),
              studioRepositoryProvider.overrideWithValue(_FakeStudio(model)),
            ],
            child: MaterialApp(
              locale: const Locale('fr'),
              localizationsDelegates: const [AppLocalizations.delegate, ...GlobalMaterialLocalizations.delegates],
              supportedLocales: AppLocalizations.supportedLocales,
              home: home,
            ),
          );

      await tester.pumpWidget(app(const ModelScreen(modelId: 'mod1')));
      await tester.pumpAndSettle();
      expect(find.text('Doublure plus lourde que le tissu principal'), findsOneWidget);
      expect(find.textContaining('Doublure « Satin lourd » (350 g/m²) dépasse Tissu principal « Sergé laine » (200 g/m²)'), findsOneWidget);
      expect(find.text('Entretiens incompatibles'), findsOneWidget);
      expect(find.text('Stock atelier insuffisant'), findsNWidgets(2), reason: 'aucun stock saisi, besoin 10,8 m chacun');

      await tester.pumpWidget(app(const CollectionScreen(collectionId: 'col1')));
      await tester.pumpAndSettle();
      expect(find.text('4 alertes'), findsOneWidget, reason: 'avertissements seulement, sans les informations');
    });
  });

  group('collections', () {
    testWidgets('Studio vide : créer une collection (Éditeur)', (tester) async {
      await tester.pumpWidget(_app(const StudioScreen()));
      await tester.pumpAndSettle();
      expect(find.text('Aucune collection pour le moment'), findsOneWidget);
      expect(find.widgetWithText(FilledButton, 'Nouvelle collection'), findsOneWidget);
    });

    testWidgets('Studio vide : message sans action (Lecteur)', (tester) async {
      await tester.pumpWidget(_app(const StudioScreen(), role: MemberRole.viewer));
      await tester.pumpAndSettle();
      expect(find.textContaining('Les éditeurs de votre atelier'), findsOneWidget);
      expect(find.text('Nouvelle collection'), findsNothing);
    });

    testWidgets('liste des collections avec leur nombre de modèles', (tester) async {
      await _size(tester, const Size(1280, 900));
      await tester.pumpWidget(_app(const StudioScreen(), collections: const [
        StudioCollection(id: 'col1', name: 'AH27', modelCount: 3),
        StudioCollection(id: 'col2', name: 'PE28'),
      ]));
      await tester.pumpAndSettle();
      expect(find.text('3 modèles'), findsOneWidget);
      expect(find.text('Aucun modèle'), findsOneWidget);
    });

    testWidgets('collection vide : ajouter un premier modèle', (tester) async {
      await tester.pumpWidget(_app(const CollectionScreen(collectionId: 'col1')));
      await tester.pumpAndSettle();
      expect(find.text('Cette collection est vide'), findsOneWidget);
      await tester.tap(find.widgetWithText(FilledButton, 'Nouveau modèle'));
      await tester.pumpAndSettle();
      for (final label in ['Vêtement', 'Chaussure', 'Maroquinerie', 'Accessoire']) {
        expect(find.widgetWithText(ChoiceChip, label), findsOneWidget);
      }
    });

    testWidgets('modèles de la collection : type, coloris et matières', (tester) async {
      await _size(tester, const Size(1280, 900));
      await tester.pumpWidget(_app(const CollectionScreen(collectionId: 'col1'), models: [_veste]));
      await tester.pumpAndSettle();
      expect(find.text('Veste Arno'), findsOneWidget);
      expect(find.text('Vêtement · 2 matières'), findsOneWidget, reason: 'un seul coloris : non affiché');
    });
  });

  test('textes des rôles : intégrés traduits, libres tels quels', () async {
    final l10n = await AppLocalizations.delegate.load(const Locale('en'));
    expect(l10n.roleText('outsole'), 'Outsole');
    expect(l10n.roleText('Doublure manches'), 'Doublure manches');
  });
}
