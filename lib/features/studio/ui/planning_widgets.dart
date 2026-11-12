import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app/theme.dart';
import '../../../l10n/l10n.dart';
import '../../reports/ui/report_widgets.dart' show formatShortDate;
import '../data/studio_repository.dart';
import '../domain/studio.dart';
import 'cost_widgets.dart' show lowCoefficientText;
import 'studio_widgets.dart';

/// Date du jour, remplaçable dans les tests.
final todayProvider = Provider<DateTime>((ref) => DateTime.now());

/// Mention « Disponible avec l'offre Pro ».
class ProLockedNote extends StatelessWidget {
  const ProLockedNote({super.key});

  @override
  Widget build(BuildContext context) => Row(
        children: [
          const Icon(Icons.lock_outline, size: 16, color: FxColors.inkSoft),
          const SizedBox(width: FxSpace.sm),
          Expanded(
            child: Text(context.l10n.proLocked,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: FxColors.inkSoft)),
          ),
        ],
      );
}

/// Échéances d'un modèle : une date par étape, en rouge quand elle est dépassée.
class ModelDeadlinesCard extends ConsumerWidget {
  const ModelDeadlinesCard({super.key, required this.model, required this.onChanged});

  final StudioModel model;
  final void Function(ModelStatus stage, DateTime? date) onChanged;

  Future<void> _pick(BuildContext context, ModelStatus stage) async {
    final now = DateTime.now();
    final current = model.deadlines[stage];
    final picked = await showDatePicker(
      context: context,
      initialDate: current ?? now,
      firstDate: DateTime(now.year - 2),
      lastDate: DateTime(now.year + 5),
      helpText: context.l10n.modelStatusText(stage),
    );
    if (picked != null) onChanged(stage, picked);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final text = Theme.of(context).textTheme;
    final pro = ref.watch(hasProProvider).value ?? false;
    final canEdit = pro && ref.watch(canEditStudioProvider);
    final today = ref.watch(todayProvider);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(FxSpace.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l10n.deadlinesTitle, style: text.titleSmall),
            Text(l10n.deadlineHelp, style: text.bodySmall?.copyWith(color: FxColors.inkSoft)),
            const SizedBox(height: FxSpace.sm),
            if (!pro) ...[const ProLockedNote(), const SizedBox(height: FxSpace.sm)],
            for (final stage in ModelStatus.stages)
              _DeadlineRow(
                stage: stage,
                date: model.deadlines[stage],
                overdue: model.isOverdue(stage, today),
                reached: model.reached(stage),
                onPick: canEdit ? () => _pick(context, stage) : null,
                onClear: canEdit && model.deadlines[stage] != null ? () => onChanged(stage, null) : null,
              ),
          ],
        ),
      ),
    );
  }
}

class _DeadlineRow extends StatelessWidget {
  const _DeadlineRow({
    required this.stage,
    required this.date,
    required this.overdue,
    required this.reached,
    this.onPick,
    this.onClear,
  });

  final ModelStatus stage;
  final DateTime? date;
  final bool overdue;
  final bool reached;
  final VoidCallback? onPick;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final text = Theme.of(context).textTheme;
    final color = overdue ? FxColors.error : (reached ? FxColors.inkSoft : FxColors.ink);
    final label = date == null ? l10n.deadlineNone : formatShortDate(context, date!);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(reached ? Icons.check_circle : Icons.circle_outlined, size: 16, color: modelStatusColor(stage)),
          const SizedBox(width: FxSpace.sm),
          Expanded(child: Text(l10n.modelStatusText(stage), style: text.bodyMedium)),
          if (overdue) ...[
            Text(l10n.deadlineOverdueTag, style: text.labelSmall?.copyWith(color: FxColors.error)),
            const SizedBox(width: FxSpace.sm),
          ],
          onPick == null
              ? Text(label, style: text.bodyMedium?.copyWith(color: color))
              : TextButton.icon(
                  onPressed: onPick,
                  icon: Icon(Icons.event_outlined, size: 16, color: color),
                  label: Text(label, style: TextStyle(color: color)),
                ),
          if (onClear != null)
            IconButton(
              tooltip: l10n.deadlineClear,
              onPressed: onClear,
              icon: const Icon(Icons.close, size: 16),
            ),
        ],
      ),
    );
  }
}

/// Planning de la collection : modèles regroupés par statut, triés par prochaine échéance.
class CollectionPlanning extends ConsumerWidget {
  const CollectionPlanning({super.key, required this.models});

  final List<StudioModel> models;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final text = Theme.of(context).textTheme;
    final pro = ref.watch(hasProProvider).value ?? false;
    final today = ref.watch(todayProvider);
    final hasDeadlines = models.any((m) => m.deadlines.isNotEmpty);

    int byNext(StudioModel a, StudioModel b) {
      final da = a.nextDeadline?.date;
      final db = b.nextDeadline?.date;
      if (da == null && db == null) return a.name.compareTo(b.name);
      if (da == null) return 1;
      if (db == null) return -1;
      return da.compareTo(db);
    }

    return ListView(
      padding: const EdgeInsets.all(FxSpace.md),
      children: [
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 820),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (!pro) ...[const ProLockedNote(), const SizedBox(height: FxSpace.md)],
                if (!hasDeadlines)
                  Padding(
                    padding: const EdgeInsets.only(bottom: FxSpace.md),
                    child: Text(l10n.planningEmpty, style: text.bodyMedium?.copyWith(color: FxColors.inkSoft)),
                  ),
                for (final status in ModelStatus.values)
                  if (models.any((m) => m.status == status)) ...[
                    Padding(
                      padding: const EdgeInsets.only(top: FxSpace.sm, bottom: FxSpace.xs),
                      child: ModelStatusChip(status: status),
                    ),
                    for (final m in models.where((m) => m.status == status).toList()..sort(byNext))
                      _PlanningRow(model: m, today: today, lowCoefficient: lowCoefficientText(context, ref, m)),
                  ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _PlanningRow extends StatelessWidget {
  const _PlanningRow({required this.model, required this.today, this.lowCoefficient});

  final StudioModel model;
  final DateTime today;

  /// Alerte « coefficient sous le minimum » (Admins et Éditeurs).
  final String? lowCoefficient;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final text = Theme.of(context).textTheme;
    final next = model.nextDeadline;
    final overdue = next != null && model.isOverdue(next.stage, today);
    final color = overdue ? FxColors.error : FxColors.inkSoft;
    return Card(
      margin: const EdgeInsets.only(bottom: FxSpace.xs),
      child: ListTile(
        dense: true,
        title: Text(model.name, style: text.titleSmall),
        subtitle: Text(
          [
            next == null
                ? l10n.planningNoDeadline
                : l10n.planningNext(l10n.modelStatusText(next.stage), formatShortDate(context, next.date)),
            ?lowCoefficient,
          ].join('\n'),
          style: text.bodySmall?.copyWith(color: lowCoefficient != null ? FxColors.error : color),
        ),
        trailing: overdue
            ? Text(l10n.deadlineOverdueTag, style: text.labelMedium?.copyWith(color: FxColors.error))
            : const Icon(Icons.chevron_right, color: FxColors.inkSoft),
        onTap: () => context.go('/studio/models/${model.id}'),
      ),
    );
  }
}
