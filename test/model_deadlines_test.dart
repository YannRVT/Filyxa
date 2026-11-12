// Phase 16 : échéances, planning de collection et notification de retard.
import 'package:filyxa/features/reports/domain/error_report.dart';
import 'package:filyxa/features/reports/ui/report_widgets.dart';
import 'package:filyxa/features/studio/data/studio_repository.dart';
import 'package:filyxa/features/studio/domain/studio.dart';
import 'package:filyxa/features/studio/ui/planning_widgets.dart';
import 'package:filyxa/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

final _today = DateTime(2026, 11, 12);

StudioModel _model(String name, ModelStatus status, Map<ModelStatus, DateTime> deadlines) =>
    StudioModel(id: name, collectionId: 'c', name: name, productType: ProductType.garment, status: status, deadlines: deadlines);

Widget _app(Widget child, {bool pro = true, bool canEdit = true}) => ProviderScope(
      overrides: [
        hasProProvider.overrideWith((ref) async => pro),
        canEditStudioProvider.overrideWithValue(canEdit),
        todayProvider.overrideWithValue(_today),
      ],
      child: MaterialApp(
        locale: const Locale('fr'),
        localizationsDelegates: const [AppLocalizations.delegate, ...GlobalMaterialLocalizations.delegates],
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: child),
      ),
    );

void main() {
  group('règles', () {
    final m = _model('Veste', ModelStatus.prototype, {
      ModelStatus.prototype: DateTime(2026, 11, 1),
      ModelStatus.validated: DateTime(2026, 11, 10),
      ModelStatus.delivered: DateTime(2027, 3, 1),
    });

    test('une étape atteinte n\'est jamais en retard', () {
      expect(m.reached(ModelStatus.prototype), isTrue);
      expect(m.isOverdue(ModelStatus.prototype, _today), isFalse);
    });

    test('date passée et étape non atteinte : en retard', () {
      expect(m.isOverdue(ModelStatus.validated, _today), isTrue);
      expect(m.isOverdue(ModelStatus.validated, DateTime(2026, 11, 10)), isFalse, reason: 'le jour même, pas encore en retard');
      expect(m.isOverdue(ModelStatus.delivered, _today), isFalse);
    });

    test('prochaine échéance : première étape non atteinte', () {
      expect(m.nextDeadline?.stage, ModelStatus.validated);
      expect(_model('X', ModelStatus.abandoned, m.deadlines).nextDeadline, isNull);
      expect(_model('X', ModelStatus.delivered, m.deadlines).nextDeadline, isNull);
      expect(_model('X', ModelStatus.abandoned, m.deadlines).isOverdue(ModelStatus.validated, _today), isFalse);
    });

    test('lecture des échéances renvoyées par le serveur', () {
      final parsed = StudioModel.fromJson(const {
        'id': 'm',
        'collection_id': 'c',
        'name': 'Veste',
        'model_deadlines': [
          {'stage': 'in_production', 'due_date': '2027-01-15'},
        ],
      });
      expect(parsed.deadlines, {ModelStatus.inProduction: DateTime(2027, 1, 15)});
    });

    testWidgets('texte de la notification de retard', (tester) async {
      late AppLocalizations l10n;
      await tester.pumpWidget(_app(Builder(builder: (context) {
        l10n = AppLocalizations.of(context);
        return const SizedBox();
      })));
      final n = AppNotification.fromJson({
        'id': 'n',
        'kind': 'deadline_overdue',
        'data': {'model_id': 'm', 'name': 'Veste Arno', 'stage': 'validated', 'due_date': '2026-11-10'},
        'created_at': '2026-11-11T08:00:00Z',
      });
      expect(n.kind, NotificationKind.deadlineOverdue);
      expect(l10n.notificationText(n), 'Échéance dépassée : Veste Arno — Validé prévu le 10 nov. 2026');
    });
  });

  group('échéances du modèle', () {
    final m = _model('Veste', ModelStatus.prototype, {ModelStatus.validated: DateTime(2026, 11, 10)});

    testWidgets('dépassée : en rouge avec la mention ; effacer', (tester) async {
      (ModelStatus, DateTime?)? changed;
      await tester.pumpWidget(_app(ModelDeadlinesCard(model: m, onChanged: (s, d) => changed = (s, d))));
      await tester.pumpAndSettle();
      expect(find.text('En retard'), findsOneWidget);
      expect(find.text('Aucune échéance'), findsNWidgets(3));
      await tester.tap(find.byTooltip('Effacer l\'échéance'));
      expect(changed, (ModelStatus.validated, null));
    });

    testWidgets('fixer une date', (tester) async {
      (ModelStatus, DateTime?)? changed;
      await tester.pumpWidget(_app(ModelDeadlinesCard(model: m, onChanged: (s, d) => changed = (s, d))));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Aucune échéance').first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      expect(changed?.$1, ModelStatus.prototype);
      expect(changed?.$2, isNotNull);
    });

    testWidgets('hors Pro : lecture seule et mention', (tester) async {
      await tester.pumpWidget(_app(ModelDeadlinesCard(model: m, onChanged: (_, _) {}), pro: false));
      await tester.pumpAndSettle();
      expect(find.text('Disponible avec l\'offre Pro'), findsOneWidget);
      expect(find.byType(TextButton), findsNothing);
    });

    testWidgets('Lecteur : lecture seule', (tester) async {
      await tester.pumpWidget(_app(ModelDeadlinesCard(model: m, onChanged: (_, _) {}), canEdit: false));
      await tester.pumpAndSettle();
      expect(find.byType(TextButton), findsNothing);
      expect(find.text('En retard'), findsOneWidget);
    });
  });

  testWidgets('planning : regroupé par statut, trié par prochaine échéance, retards en rouge', (tester) async {
    final models = [
      _model('Pantalon', ModelStatus.prototype, {ModelStatus.validated: DateTime(2026, 12, 20)}),
      _model('Veste', ModelStatus.prototype, {ModelStatus.validated: DateTime(2026, 11, 10)}),
      _model('Chemise', ModelStatus.prototype, const {}),
      _model('Robe', ModelStatus.inProduction, {ModelStatus.delivered: DateTime(2027, 2, 1)}),
    ];
    await tester.pumpWidget(_app(CollectionPlanning(models: models)));
    await tester.pumpAndSettle();
    final order = [for (final n in ['Veste', 'Pantalon', 'Chemise', 'Robe']) tester.getTopLeft(find.text(n)).dy];
    expect(order, [...order]..sort(), reason: 'Veste (en retard) puis Pantalon, Chemise sans échéance, puis En production');
    expect(find.text('En retard'), findsOneWidget);
    expect(find.text('Sans échéance'), findsOneWidget);
    expect(find.text('Validé prévu le 10 nov. 2026'), findsOneWidget);
    expect(find.text('Prototype'), findsOneWidget);
    expect(find.text('En production'), findsOneWidget);
  });
}
