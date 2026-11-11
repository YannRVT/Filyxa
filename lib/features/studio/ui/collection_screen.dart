import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app/theme.dart';
import '../../../l10n/l10n.dart';
import '../../../shared/widgets/auth_widgets.dart';
import '../../auth/data/auth_repository.dart';
import '../../export/export_screen.dart';
import '../../share/data/share_repository.dart';
import '../../share/ui/share_widgets.dart';
import '../data/studio_repository.dart';
import '../domain/studio.dart';
import '../domain/alerts.dart';
import 'alert_widgets.dart';
import 'studio_widgets.dart';

/// Collection : ses modèles, et l'ajout d'un modèle.
class CollectionScreen extends ConsumerWidget {
  const CollectionScreen({super.key, required this.collectionId});

  final String collectionId;

  Future<void> _newModel(BuildContext context, WidgetRef ref) async {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    final input = await showNewModelDialog(context);
    if (input == null) return;
    try {
      final id = await ref
          .read(studioRepositoryProvider)
          .createModel(collectionId, name: input.name, type: input.type, reference: input.reference);
      ref.invalidate(collectionModelsProvider(collectionId));
      ref.invalidate(collectionsProvider);
      if (context.mounted) context.go('/studio/models/$id');
    } on AuthError catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.failure(e.failure))));
    }
  }

  Future<void> _rename(BuildContext context, WidgetRef ref, StudioCollection c) async {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    final name = await showNameDialog(context,
        title: l10n.rename, label: l10n.studioCollectionName, initial: c.name, confirm: l10n.save);
    if (name == null || name == c.name) return;
    try {
      await ref.read(studioRepositoryProvider).renameCollection(c.id, name);
      ref.invalidate(collectionProvider(c.id));
      ref.invalidate(collectionsProvider);
    } on AuthError catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.failure(e.failure))));
    }
  }

  Future<void> _delete(BuildContext context, WidgetRef ref, StudioCollection c) async {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    if (!await confirmDelete(context, title: l10n.deleteCollectionTitle(c.name), body: l10n.deleteCollectionBody)) return;
    try {
      await ref.read(studioRepositoryProvider).deleteCollection(c.id);
      ref.invalidate(collectionsProvider);
      if (context.mounted) context.go('/studio');
    } on AuthError catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.failure(e.failure))));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final canEdit = ref.watch(canEditStudioProvider);
    final collection = ref.watch(collectionProvider(collectionId)).value;
    final models = ref.watch(collectionModelsProvider(collectionId));
    final narrow = MediaQuery.sizeOf(context).width < FxBreakpoints.tablet;
    final hasAny = models.value?.isNotEmpty ?? false;

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => context.go('/studio')),
        title: Text(collection?.name ?? ''),
        actions: [
          if (canEdit && hasAny)
            narrow
                ? IconButton.filled(
                    tooltip: l10n.studioNewModel,
                    onPressed: () => _newModel(context, ref),
                    icon: const Icon(Icons.add),
                  )
                : FilledButton.icon(
                    onPressed: () => _newModel(context, ref),
                    icon: const Icon(Icons.add, size: 18),
                    label: Text(l10n.studioNewModel),
                  ),
          if (collection != null) ShareButton(scope: ShareScope.collection, targetId: collection.id),
          if (hasAny && collection != null)
            IconButton(
              tooltip: l10n.exportDossier,
              icon: const Icon(Icons.picture_as_pdf_outlined),
              onPressed: () => openCollectionExport(context, ref, collection,
                  shareUrl: ref.read(targetLinksProvider((ShareScope.collection, collection.id))).firstOrNull?.url),
            ),
          if (canEdit && collection != null)
            PopupMenuButton<String>(
              onSelected: (v) => v == 'rename' ? _rename(context, ref, collection) : _delete(context, ref, collection),
              itemBuilder: (_) => [
                PopupMenuItem(value: 'rename', child: Text(l10n.rename)),
                PopupMenuItem(value: 'delete', child: Text(l10n.delete, style: const TextStyle(color: FxColors.error))),
              ],
            ),
          const SizedBox(width: FxSpace.sm),
        ],
      ),
      body: models.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(FxSpace.lg),
            child: MessageBanner.error(l10n.failure(AuthError.from(e).failure)),
          ),
        ),
        data: (list) => list.isEmpty
            ? StudioEmptyState(
                icon: Icons.checkroom_outlined,
                title: l10n.collectionEmptyTitle,
                body: canEdit ? l10n.collectionEmptyEditor : l10n.collectionEmptyViewer,
                action: canEdit
                    ? FilledButton.icon(
                        onPressed: () => _newModel(context, ref),
                        icon: const Icon(Icons.add),
                        label: Text(l10n.studioNewModel),
                      )
                    : null,
              )
            : ListView.separated(
                padding: const EdgeInsets.all(FxSpace.md),
                itemCount: list.length,
                separatorBuilder: (_, _) => const SizedBox(height: FxSpace.sm),
                itemBuilder: (_, i) => Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 820),
                    child: _ModelCard(model: list[i]),
                  ),
                ),
              ),
      ),
    );
  }
}

class _ModelCard extends ConsumerWidget {
  const _ModelCard({required this.model});

  final StudioModel model;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final text = Theme.of(context).textTheme;
    final m = model;
    // Alertes qui demandent une action (critiques et avertissements).
    final alerts = watchModelAlerts(ref, m).where((e) => e.alert.level != AlertLevel.info).toList();
    final worst = alerts.isEmpty ? null : alerts.first.alert.level;
    final details = [
      l10n.productTypeLabel(m.productType),
      if ((m.reference ?? '').isNotEmpty) m.reference!,
      if (m.hasVariants) l10n.colorwayCount(m.colorways.length),
      l10n.bomLineCount(m.materialIds.length),
    ];
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.go('/studio/models/${m.id}'),
        child: Padding(
          padding: const EdgeInsets.all(FxSpace.md),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(color: FxColors.mintPale, borderRadius: BorderRadius.circular(FxRadius.md)),
                child: Icon(productTypeIcon(m.productType), color: FxColors.petrol),
              ),
              const SizedBox(width: FxSpace.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(m.name, style: text.titleMedium, maxLines: 1, overflow: TextOverflow.ellipsis),
                    Text(details.join(' · '), style: text.bodySmall?.copyWith(color: FxColors.inkSoft)),
                  ],
                ),
              ),
              if (worst != null) ...[
                Icon(alertStyle(worst).$1, color: alertStyle(worst).$2, size: 18),
                const SizedBox(width: 4),
                Text(l10n.alertsCount(alerts.length), style: text.labelMedium?.copyWith(color: alertStyle(worst).$2)),
                const SizedBox(width: FxSpace.sm),
              ],
              const Icon(Icons.chevron_right, color: FxColors.inkSoft),
            ],
          ),
        ),
      ),
    );
  }
}
