import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app/theme.dart';
import '../../../l10n/l10n.dart';
import '../../../shared/widgets/auth_widgets.dart';
import '../../library/domain/library_filter.dart' show foldForSearch;
import '../../library/domain/material.dart';
import '../../library/ui/material_widgets.dart';
import '../../members/data/members_repository.dart';
import '../../session/domain/user_space.dart';
import '../../reports/data/reports_repository.dart';
import '../../reports/domain/error_report.dart';
import '../../reports/ui/notifications_screen.dart';
import '../data/catalog_repository.dart';
import '../domain/availability.dart';
import '../domain/supplier_reference.dart';
import 'supplier_texts.dart';

final canEditCatalogProvider = Provider<bool>(
  (ref) => ref.watch(currentRoleProvider)?.atLeast(MemberRole.editor) ?? false,
);

/// Catalogue du fournisseur : ses références, leur stock et ce qu'en voient les ateliers.
class CatalogScreen extends ConsumerStatefulWidget {
  const CatalogScreen({super.key});

  @override
  ConsumerState<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends ConsumerState<CatalogScreen> {
  String _query = '';
  bool _showRetired = false;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final refs = ref.watch(supplierReferencesProvider);
    final settings = ref.watch(supplierSettingsProvider).value ?? const SupplierSettings();
    final canEdit = ref.watch(canEditCatalogProvider);
    final narrow = MediaQuery.sizeOf(context).width < FxBreakpoints.tablet;
    final total = refs.value?.where((r) => !r.isRetired).length;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.navCatalog),
            if (total != null && total > 0)
              Text(l10n.referenceCount(total),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: FxColors.inkSoft)),
          ],
        ),
        actions: [
          _ReportsButton(narrow: narrow),
          IconButton(
            tooltip: l10n.catalogSettings,
            icon: const Icon(Icons.tune),
            onPressed: () => context.go('/catalog/settings'),
          ),
          if (canEdit && (refs.value?.isNotEmpty ?? false)) ...[
            const SizedBox(width: FxSpace.xs),
            narrow
                ? IconButton.filled(
                    tooltip: l10n.catalogImport,
                    onPressed: () => context.go('/catalog/import'),
                    icon: const Icon(Icons.upload_file_outlined),
                  )
                : FilledButton.icon(
                    onPressed: () => context.go('/catalog/import'),
                    icon: const Icon(Icons.upload_file_outlined, size: 18),
                    label: Text(l10n.catalogImport),
                  ),
          ],
          const NotificationBell(),
          const SizedBox(width: FxSpace.sm),
        ],
      ),
      body: refs.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => Center(child: Padding(
          padding: const EdgeInsets.all(FxSpace.lg),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            MessageBanner.error(l10n.loadingError),
            const SizedBox(height: FxSpace.md),
            FilledButton(onPressed: () => ref.invalidate(supplierReferencesProvider), child: Text(l10n.retry)),
          ]),
        )),
        data: (items) {
          if (items.isEmpty) return _EmptyCatalog(canEdit: canEdit);
          final q = foldForSearch(_query);
          final visible = items.where((r) {
            if (r.isRetired && !_showRetired) return false;
            if (q.isEmpty) return true;
            return foldForSearch('${r.code} ${r.name} ${r.colorName ?? ''}').contains(q);
          }).toList();

          return ListView(
            padding: const EdgeInsets.all(FxSpace.md),
            children: [
              TextField(
                onChanged: (v) => setState(() => _query = v),
                decoration: InputDecoration(hintText: l10n.searchHint, prefixIcon: const Icon(Icons.search)),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(l10n.showRetired),
                value: _showRetired,
                onChanged: (v) => setState(() => _showRetired = v),
              ),
              if (visible.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(FxSpace.lg),
                  child: Text(l10n.noResultsTitle, textAlign: TextAlign.center),
                )
              else
                Card(
                  child: Column(
                    children: [
                      for (final (i, r) in visible.indexed) ...[
                        if (i > 0) const Divider(),
                        _ReferenceTile(reference: r, settings: settings),
                      ],
                    ],
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _ReferenceTile extends StatelessWidget {
  const _ReferenceTile({required this.reference, required this.settings});

  final SupplierReference reference;
  final SupplierSettings settings;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final lang = langOf(context);
    final text = Theme.of(context).textTheme;
    final r = reference;
    final color = colorFromHex(r.colorHex);
    return ListTile(
      onTap: () => context.go('/catalog/${r.id}'),
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: color ?? FxColors.mintPale,
          borderRadius: BorderRadius.circular(FxRadius.sm),
        ),
        child: color == null ? const Icon(Icons.texture, size: 18, color: FxColors.emeraldInk) : null,
      ),
      title: Row(
        children: [
          Flexible(child: Text(r.name, overflow: TextOverflow.ellipsis)),
          if (r.isRetired) ...[
            const SizedBox(width: FxSpace.sm),
            Text(l10n.retiredBadge, style: text.labelSmall?.copyWith(color: FxColors.warning)),
          ],
        ],
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TechText(
            [r.code, if (r.specs.composition.isNotEmpty) compositionCodes(r.specs.composition, lang)].join(' · '),
            size: 12,
            color: FxColors.inkSoft,
            maxLines: 1,
          ),
          const SizedBox(height: 4),
          Wrap(
            spacing: FxSpace.sm,
            runSpacing: 4,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              AvailabilityPill(status: r.status(settings), leadTimeWeeks: r.leadTimeWeeks),
              Text(
                '${l10n.stockLabel} : ${r.stockM == null ? '—' : l10n.stockMeters(formatNumber(r.stockM!, lang, decimals: 2))}',
                style: text.bodySmall?.copyWith(fontFeatures: const [FontFeature.tabularFigures()]),
              ),
              if (r.effectiveMode(settings) != AvailabilityMode.tiers)
                Text('(${l10n.mode(r.effectiveMode(settings))})', style: text.bodySmall?.copyWith(color: FxColors.inkSoft)),
            ],
          ),
        ],
      ),
      isThreeLine: true,
      trailing: const Icon(Icons.chevron_right),
    );
  }
}

class _EmptyCatalog extends StatelessWidget {
  const _EmptyCatalog({required this.canEdit});

  final bool canEdit;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final text = Theme.of(context).textTheme;
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(FxSpace.lg),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 460),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.inventory_2_outlined, size: 40, color: FxColors.petrol),
              const SizedBox(height: FxSpace.md),
              Text(l10n.catalogEmptyTitle, style: text.titleLarge, textAlign: TextAlign.center),
              const SizedBox(height: FxSpace.sm),
              Text(l10n.catalogEmptyBody, textAlign: TextAlign.center,
                  style: text.bodyMedium?.copyWith(color: FxColors.inkSoft)),
              if (canEdit) ...[
                const SizedBox(height: FxSpace.lg),
                FilledButton.icon(
                  onPressed: () => context.go('/catalog/import'),
                  icon: const Icon(Icons.upload_file_outlined),
                  label: Text(l10n.catalogImport),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Accès aux signalements des ateliers, avec le nombre de signalements ouverts.
class _ReportsButton extends ConsumerWidget {
  const _ReportsButton({required this.narrow});

  final bool narrow;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final open = (ref.watch(supplierReportsProvider).value ?? const [])
        .where((r) => r.status == ReportStatus.open)
        .length;
    final label = l10n.supplierReportsButton(open);
    final icon = Badge(
      isLabelVisible: narrow && open > 0,
      label: Text('$open'),
      child: const Icon(Icons.flag_outlined),
    );
    return narrow
        ? IconButton(tooltip: label, onPressed: () => context.go('/catalog/reports'), icon: icon)
        : TextButton.icon(onPressed: () => context.go('/catalog/reports'), icon: icon, label: Text(label));
  }
}
