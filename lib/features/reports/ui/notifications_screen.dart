import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app/theme.dart';
import '../../../l10n/l10n.dart';
import '../../../shared/widgets/auth_widgets.dart';
import '../../auth/data/auth_repository.dart';
import '../../library/data/materials_repository.dart';
import '../data/reports_repository.dart';
import '../domain/error_report.dart';
import 'report_widgets.dart';

/// Cloche avec le nombre de notifications non lues.
class NotificationBell extends ConsumerWidget {
  const NotificationBell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unread = ref.watch(unreadNotificationsProvider);
    return IconButton(
      tooltip: context.l10n.notificationsTooltip(unread),
      onPressed: () => context.push('/notifications'),
      icon: Badge(
        isLabelVisible: unread > 0,
        label: Text(unread > 99 ? '99+' : '$unread'),
        child: Icon(unread > 0 ? Icons.notifications : Icons.notifications_outlined),
      ),
    );
  }
}

/// Liste des notifications ; ouvrir la page les marque comme lues.
class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  /// Non lues à l'ouverture, mises en avant pendant la visite.
  Set<String>? _freshIds;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _markRead());
  }

  Future<void> _markRead() async {
    final list = await ref.read(notificationsProvider.future);
    if (!mounted) return;
    setState(() => _freshIds = {for (final n in list) if (n.unread) n.id});
    if (_freshIds!.isEmpty) return;
    try {
      await ref.read(reportsRepositoryProvider).markAllRead();
      ref.invalidate(notificationsProvider);
    } on AuthError {
      // Sans gravité : elles resteront non lues jusqu'à la prochaine visite.
    }
  }

  void _open(AppNotification n) {
    switch (n.kind) {
      case NotificationKind.reportNew:
        context.go('/catalog/reports');
      case NotificationKind.reportFixed || NotificationKind.reportRejected:
        if (n.materialId == null) return;
        ref.invalidate(materialReportsProvider(n.materialId!));
        ref.invalidate(materialProvider(n.materialId!));
        context.go('/library/${n.materialId}');
      case NotificationKind.stockLow ||
            NotificationKind.stockOut ||
            NotificationKind.referenceUpdated ||
            NotificationKind.referenceRetired:
        // Un seul modèle concerné : on l'ouvre ; sinon, la fiche de la matière.
        ref.invalidate(linkedReferencesProvider);
        if (n.models.length == 1) {
          context.go('/studio/models/${n.models.single.id}');
        } else if (n.materialId != null) {
          ref.invalidate(materialProvider(n.materialId!));
          context.go('/library/${n.materialId}');
        }
      case NotificationKind.deadlineOverdue:
        final modelId = n.data['model_id'] as String?;
        if (modelId != null) context.go('/studio/models/$modelId');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final text = Theme.of(context).textTheme;
    final notifications = ref.watch(notificationsProvider);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.notificationsTitle)),
      body: notifications.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(FxSpace.lg),
            child: MessageBanner.error(l10n.failure(AuthError.from(e).failure)),
          ),
        ),
        data: (list) => list.isEmpty
            ? Center(child: Text(l10n.notificationsEmpty))
            : ListView.separated(
                padding: const EdgeInsets.symmetric(vertical: FxSpace.sm),
                itemCount: list.length,
                separatorBuilder: (_, _) => const Divider(height: 1),
                itemBuilder: (_, i) {
                  final n = list[i];
                  final fresh = n.unread || (_freshIds?.contains(n.id) ?? false);
                  final (icon, color) = switch (n.kind) {
                    NotificationKind.reportNew => (Icons.flag_outlined, FxColors.info),
                    NotificationKind.reportFixed => (Icons.check_circle_outline, FxColors.success),
                    NotificationKind.reportRejected => (Icons.block, FxColors.error),
                    NotificationKind.stockLow => (Icons.inventory_2_outlined, FxColors.warning),
                    NotificationKind.stockOut => (Icons.remove_shopping_cart_outlined, FxColors.error),
                    NotificationKind.referenceUpdated => (Icons.edit_note, FxColors.info),
                    NotificationKind.referenceRetired => (Icons.link_off, FxColors.error),
                    NotificationKind.deadlineOverdue => (Icons.event_busy_outlined, FxColors.error),
                  };
                  final response = n.data['response'] as String?;
                  return Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 720),
                      child: ListTile(
                        tileColor: fresh ? FxColors.mintPale : null,
                        leading: Icon(icon, color: color),
                        title: Text(
                          l10n.notificationText(n),
                          style: fresh ? const TextStyle(fontWeight: FontWeight.w600) : null,
                        ),
                        subtitle: Text([
                          if (n.models.isNotEmpty) l10n.notifUsedIn(n.models.map((m) => m.name).join(', ')),
                          if (response != null)
                            n.kind == NotificationKind.reportRejected
                                ? l10n.reportReasonLine(response)
                                : l10n.reportResponseLine(response),
                          formatShortDate(context, n.createdAt),
                        ].join('\n'), style: text.bodySmall),
                        onTap: () => _open(n),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
