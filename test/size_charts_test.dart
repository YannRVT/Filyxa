// Phase 17 : grilles de tailles et quantités par taille et par coloris.
import 'package:filyxa/features/members/data/members_repository.dart';
import 'package:filyxa/features/session/domain/user_space.dart';
import 'package:filyxa/features/studio/data/studio_repository.dart';
import 'package:filyxa/features/studio/domain/studio.dart';
import 'package:filyxa/features/studio/ui/size_widgets.dart';
import 'package:filyxa/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

const _alpha = SizeChart(id: 'alpha', code: 'alpha', sizes: ['XS', 'S', 'M', 'L', 'XL', 'XXL']);
const _kids = SizeChart(id: 'kids', orgId: 'org', name: 'Enfant', sizes: ['4A', '6A', '8A']);

Widget _app(Widget child, {bool screen = false, bool pro = true, bool canEdit = true, MemberRole role = MemberRole.editor}) => ProviderScope(
      overrides: [
        hasProProvider.overrideWith((ref) async => pro),
        canEditStudioProvider.overrideWithValue(canEdit),
        currentRoleProvider.overrideWithValue(role),
        sizeChartsProvider.overrideWith((ref) async => const [_alpha, _kids]),
      ],
      child: MaterialApp(
        locale: const Locale('fr'),
        localizationsDelegates: const [AppLocalizations.delegate, ...GlobalMaterialLocalizations.delegates],
        supportedLocales: AppLocalizations.supportedLocales,
        home: screen ? child : Scaffold(body: SingleChildScrollView(child: child)),
      ),
    );

StudioModel _model({String? chart, List<Colorway>? colorways}) => StudioModel(
      id: 'm',
      collectionId: 'c',
      name: 'Veste',
      productType: ProductType.garment,
      sizeChartId: chart,
      colorways: colorways ??
          const [
            Colorway(id: 'c1', name: 'Marine', sizeQuantities: {'4A': 10, '6A': 20}),
            Colorway(id: 'c2', name: 'Sable', sizeQuantities: {'8A': 5}),
          ],
    );

void main() {
  test('saisie des tailles : nettoyées, dans l\'ordre', () {
    expect(parseSizes(' XS, S ;M,,\nL '), ['XS', 'S', 'M', 'L']);
  });

  test('lecture des quantités par taille', () {
    final c = Colorway.fromJson(const {
      'id': 'c',
      'quantity': 30,
      'colorway_size_quantities': [
        {'size': 'S', 'quantity': 10},
        {'size': 'M', 'quantity': 20},
      ],
    });
    expect(c.sizeQuantities, {'S': 10, 'M': 20});
  });

  testWidgets('tableau tailles × coloris avec totaux', (tester) async {
    await tester.pumpWidget(_app(ModelSizesCard(model: _model(chart: 'kids'), onChartChanged: (_) {}, onQuantity: (_, _, _) {})));
    await tester.pumpAndSettle();
    for (final s in ['4A', '6A', '8A']) {
      expect(find.descendant(of: find.byType(Table), matching: find.text(s)), findsOneWidget);
    }
    expect(find.text('30'), findsOneWidget, reason: 'total Marine');
    expect(find.text('35'), findsOneWidget, reason: 'total général');
    expect(find.text('Total'), findsNWidgets(2));
  });

  testWidgets('saisir une quantité', (tester) async {
    (String, String, int)? got;
    await tester.pumpWidget(_app(ModelSizesCard(
      model: _model(chart: 'kids'),
      onChartChanged: (_) {},
      onQuantity: (c, s, q) => got = (c.id, s, q),
    )));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const ValueKey('size-c2|4A')), '12');
    expect(got, ('c2', '4A', 12));
  });

  testWidgets('changer de grille avec des quantités : confirmation', (tester) async {
    String? chosen = 'none';
    await tester.pumpWidget(_app(ModelSizesCard(model: _model(chart: 'kids'), onChartChanged: (id) => chosen = id, onQuantity: (_, _, _) {})));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Enfant'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('XS–XXL').last);
    await tester.pumpAndSettle();
    expect(find.text('Changer de grille ?'), findsOneWidget);
    await tester.tap(find.text('Changer'));
    await tester.pumpAndSettle();
    expect(chosen, 'alpha');
  });

  testWidgets('sans grille : rien à saisir par taille (comme en V1)', (tester) async {
    await tester.pumpWidget(_app(ModelSizesCard(model: _model(), onChartChanged: (_) {}, onQuantity: (_, _, _) {})));
    await tester.pumpAndSettle();
    expect(find.text('Sans grille (quantité par coloris)'), findsOneWidget);
    expect(find.byType(Table), findsNothing);
  });

  testWidgets('hors Pro : lecture seule et mention', (tester) async {
    await tester.pumpWidget(_app(ModelSizesCard(model: _model(chart: 'kids'), onChartChanged: (_) {}, onQuantity: (_, _, _) {}), pro: false));
    await tester.pumpAndSettle();
    expect(find.text('Disponible avec l\'offre Pro'), findsOneWidget);
    expect(find.byType(TextField), findsNothing);
    expect(find.text('35'), findsOneWidget, reason: 'les données restent lisibles');
  });

  group('grilles de l\'atelier', () {
    testWidgets('Admin : grilles fournies, grille de l\'atelier modifiable', (tester) async {
      await tester.pumpWidget(_app(const SizeChartsScreen(), screen: true, role: MemberRole.admin));
      await tester.pumpAndSettle();
      expect(find.text('XS–XXL'), findsOneWidget);
      expect(find.text('Enfant'), findsOneWidget);
      expect(find.text('Nouvelle grille'), findsOneWidget);
      expect(find.byTooltip('Modifier la grille'), findsOneWidget, reason: 'seule la grille de l\'atelier');
      await tester.tap(find.text('Nouvelle grille'));
      await tester.pumpAndSettle();
      await tester.enterText(find.widgetWithText(TextField, 'Nom de la grille'), 'Bébé');
      await tester.enterText(find.widgetWithText(TextField, 'Tailles, dans l\'ordre, séparées par des virgules'), '3M, 3M');
      await tester.tap(find.text('Enregistrer'));
      await tester.pumpAndSettle();
      expect(find.textContaining('distinctes'), findsOneWidget);
    });

    testWidgets('Éditeur : consultation seule', (tester) async {
      await tester.pumpWidget(_app(const SizeChartsScreen(), screen: true));
      await tester.pumpAndSettle();
      expect(find.text('Nouvelle grille'), findsNothing);
      expect(find.byTooltip('Modifier la grille'), findsNothing);
    });
  });
}
