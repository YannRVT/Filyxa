// Phase 15 : statuts du modèle et verrou de l'offre Pro.
import 'package:filyxa/features/auth/domain/auth_rules.dart';
import 'package:filyxa/features/studio/data/studio_repository.dart';
import 'package:filyxa/features/studio/domain/studio.dart';
import 'package:filyxa/features/studio/ui/studio_widgets.dart';
import 'package:filyxa/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

Widget _app(Widget child, {required bool pro, bool canEdit = true}) => ProviderScope(
      overrides: [
        hasProProvider.overrideWith((ref) async => pro),
        canEditStudioProvider.overrideWithValue(canEdit),
      ],
      child: MaterialApp(
        locale: const Locale('fr'),
        localizationsDelegates: const [AppLocalizations.delegate, ...GlobalMaterialLocalizations.delegates],
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: Center(child: child)),
      ),
    );

void main() {
  group('règles', () {
    test('lecture du statut, Idée par défaut', () {
      expect(ModelStatus.parse('in_production'), ModelStatus.inProduction);
      expect(ModelStatus.parse(null), ModelStatus.idea);
      expect(StudioModel.fromJson(const {'id': 'm', 'collection_id': 'c', 'name': 'Veste'}).status, ModelStatus.idea);
    });

    test('retour en arrière permis, sauf depuis Livré', () {
      expect(ModelStatus.validated.nextChoices, containsAll([ModelStatus.idea, ModelStatus.inProduction, ModelStatus.abandoned]));
      expect(ModelStatus.abandoned.nextChoices, contains(ModelStatus.prototype));
      expect(ModelStatus.delivered.nextChoices, isEmpty);
    });

    test('seuls Prototype, Validé et En production sont actifs', () {
      expect([for (final s in ModelStatus.values) if (s.isActive) s],
          [ModelStatus.prototype, ModelStatus.validated, ModelStatus.inProduction]);
    });

    test('refus serveur « offre Pro »', () {
      expect(classifyFailure(message: 'pro_required', code: '42501'), AuthFailure.proRequired);
    });
  });

  group('interface', () {
    testWidgets('hors Pro : statut verrouillé avec la mention', (tester) async {
      ModelStatus? changed;
      await tester.pumpWidget(_app(ModelStatusControl(status: ModelStatus.idea, onChanged: (s) => changed = s), pro: false));
      await tester.pumpAndSettle();
      expect(find.text('Disponible avec l\'offre Pro'), findsOneWidget);
      expect(find.byIcon(Icons.lock_outline), findsOneWidget);
      await tester.tap(find.text('Idée'));
      await tester.pumpAndSettle();
      expect(find.text('Prototype'), findsNothing);
      expect(changed, isNull);
    });

    testWidgets('Pro : l\'Éditeur choisit le statut', (tester) async {
      ModelStatus? changed;
      await tester.pumpWidget(_app(ModelStatusControl(status: ModelStatus.validated, onChanged: (s) => changed = s), pro: true));
      await tester.pumpAndSettle();
      expect(find.text('Disponible avec l\'offre Pro'), findsNothing);
      await tester.tap(find.text('Validé'));
      await tester.pumpAndSettle();
      expect(find.text('Abandonné'), findsOneWidget);
      await tester.tap(find.text('En production'));
      await tester.pumpAndSettle();
      expect(changed, ModelStatus.inProduction);
    });

    testWidgets('Pro : le Lecteur voit le statut sans pouvoir le changer', (tester) async {
      await tester.pumpWidget(_app(ModelStatusControl(status: ModelStatus.prototype, onChanged: (_) {}), pro: true, canEdit: false));
      await tester.pumpAndSettle();
      expect(find.text('Prototype'), findsOneWidget);
      expect(find.byType(PopupMenuButton<ModelStatus>), findsNothing);
    });

    testWidgets('Livré : plus de choix', (tester) async {
      await tester.pumpWidget(_app(ModelStatusControl(status: ModelStatus.delivered, onChanged: (_) {}), pro: true));
      await tester.pumpAndSettle();
      expect(find.text('Livré'), findsOneWidget);
      expect(find.byType(PopupMenuButton<ModelStatus>), findsNothing);
    });
  });
}
