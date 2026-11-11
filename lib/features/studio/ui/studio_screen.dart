import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app/theme.dart';
import '../../../l10n/l10n.dart';
import '../../../shared/widgets/auth_widgets.dart';
import '../../auth/data/auth_repository.dart';
import '../../reports/ui/notifications_screen.dart';
import '../../session/data/user_space_repository.dart';
import '../data/studio_repository.dart';
import '../domain/studio.dart';
import 'studio_widgets.dart';

/// Studio : liste des collections de l'atelier.
class StudioScreen extends ConsumerWidget {
  const StudioScreen({super.key});

  Future<void> _create(BuildContext context, WidgetRef ref) async {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    final name = await showNameDialog(
      context,
      title: l10n.studioNewCollection,
      label: l10n.studioCollectionName,
      hint: l10n.studioCollectionHint,
      confirm: l10n.create,
    );
    final orgId = ref.read(userSpaceProvider).value?.membership?.organization.id;
    if (name == null || orgId == null) return;
    try {
      final id = await ref.read(studioRepositoryProvider).createCollection(orgId, name);
      ref.invalidate(collectionsProvider);
      if (context.mounted) context.go('/studio/collections/$id');
    } on AuthError catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.failure(e.failure))));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final canEdit = ref.watch(canEditStudioProvider);
    final collections = ref.watch(collectionsProvider);
    final narrow = MediaQuery.sizeOf(context).width < FxBreakpoints.tablet;
    final hasAny = collections.value?.isNotEmpty ?? false;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.navStudio),
        actions: [
          if (canEdit && hasAny)
            narrow
                ? IconButton.filled(
                    tooltip: l10n.studioNewCollection,
                    onPressed: () => _create(context, ref),
                    icon: const Icon(Icons.add),
                  )
                : FilledButton.icon(
                    onPressed: () => _create(context, ref),
                    icon: const Icon(Icons.add, size: 18),
                    label: Text(l10n.studioNewCollection),
                  ),
          const NotificationBell(),
          const SizedBox(width: FxSpace.sm),
        ],
      ),
      body: collections.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(FxSpace.lg),
            child: MessageBanner.error(l10n.failure(AuthError.from(e).failure)),
          ),
        ),
        data: (list) => list.isEmpty
            ? StudioEmptyState(
                icon: Icons.layers_outlined,
                title: l10n.studioEmptyTitle,
                body: canEdit ? l10n.studioEmptyEditor : l10n.studioEmptyViewer,
                action: canEdit
                    ? FilledButton.icon(
                        onPressed: () => _create(context, ref),
                        icon: const Icon(Icons.add),
                        label: Text(l10n.studioNewCollection),
                      )
                    : null,
              )
            : LayoutBuilder(builder: (context, c) {
                final columns = (c.maxWidth / 300).floor().clamp(1, 4);
                return GridView.builder(
                  padding: const EdgeInsets.all(FxSpace.md),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: columns,
                    mainAxisSpacing: FxSpace.md,
                    crossAxisSpacing: FxSpace.md,
                    mainAxisExtent: 112,
                  ),
                  itemCount: list.length,
                  itemBuilder: (_, i) => _CollectionCard(collection: list[i]),
                );
              }),
      ),
    );
  }
}

class _CollectionCard extends StatelessWidget {
  const _CollectionCard({required this.collection});

  final StudioCollection collection;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final text = Theme.of(context).textTheme;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.go('/studio/collections/${collection.id}'),
        child: Padding(
          padding: const EdgeInsets.all(FxSpace.md),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(color: FxColors.mintPale, borderRadius: BorderRadius.circular(FxRadius.md)),
                child: const Icon(Icons.layers_outlined, color: FxColors.petrol),
              ),
              const SizedBox(width: FxSpace.md),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(collection.name, style: text.titleMedium, maxLines: 1, overflow: TextOverflow.ellipsis),
                    Text(l10n.studioModelCount(collection.modelCount), style: text.bodySmall?.copyWith(color: FxColors.inkSoft)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: FxColors.inkSoft),
            ],
          ),
        ),
      ),
    );
  }
}
