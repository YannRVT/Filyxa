import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app/theme.dart';
import '../../../l10n/l10n.dart';
import '../../../shared/widgets/auth_widgets.dart';
import '../data/materials_repository.dart';
import '../domain/catalog.dart';
import '../domain/material.dart';
import 'library_filters.dart';
import 'material_widgets.dart';

enum LibraryView { gallery, table }

class LibraryViewController extends Notifier<LibraryView> {
  @override
  LibraryView build() => LibraryView.gallery;

  void set(LibraryView view) => state = view;
}

final libraryViewProvider = NotifierProvider<LibraryViewController, LibraryView>(LibraryViewController.new);

/// TissuTech : la bibliothèque de matières de l'atelier, en galerie ou en tableau.
class LibraryScreen extends ConsumerWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final materials = ref.watch(materialsProvider);
    final canEdit = ref.watch(canEditMaterialsProvider);
    final view = ref.watch(libraryViewProvider);
    final count = materials.value?.length;
    final narrow = MediaQuery.sizeOf(context).width < FxBreakpoints.tablet;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.navLibrary),
            if (count != null && count > 0)
              Text(
                l10n.materialCount(count),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: FxColors.inkSoft),
              ),
          ],
        ),
        actions: [
          if (count != null && count > 0)
            SegmentedButton<LibraryView>(
              showSelectedIcon: false,
              segments: [
                ButtonSegment(
                  value: LibraryView.gallery,
                  icon: const Icon(Icons.grid_view_outlined, size: 18),
                  tooltip: l10n.viewGallery,
                  label: narrow ? null : Text(l10n.viewGallery),
                ),
                ButtonSegment(
                  value: LibraryView.table,
                  icon: const Icon(Icons.table_rows_outlined, size: 18),
                  tooltip: l10n.viewTable,
                  label: narrow ? null : Text(l10n.viewTable),
                ),
              ],
              selected: {view},
              onSelectionChanged: (s) => ref.read(libraryViewProvider.notifier).set(s.first),
            ),
          if (canEdit && count != null && count > 0) ...[
            const SizedBox(width: FxSpace.sm),
            narrow
                ? IconButton.filled(
                    tooltip: l10n.libraryNew,
                    onPressed: () => context.go('/library/new'),
                    icon: const Icon(Icons.add),
                  )
                : FilledButton.icon(
                    onPressed: () => context.go('/library/new'),
                    icon: const Icon(Icons.add, size: 18),
                    label: Text(l10n.libraryNew),
                  ),
          ],
          const SizedBox(width: FxSpace.md),
        ],
      ),
      body: materials.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(FxSpace.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                MessageBanner.error(l10n.loadingError),
                const SizedBox(height: FxSpace.md),
                FilledButton(onPressed: () => ref.invalidate(materialsProvider), child: Text(l10n.retry)),
              ],
            ),
          ),
        ),
        data: (items) {
          if (items.isEmpty) return _EmptyLibrary(canEdit: canEdit);
          return _FilteredLibrary(items: items, view: view);
        },
      ),
    );
  }
}

/// Recherche, filtres (panneau latéral sur grand écran, feuille sur téléphone)
/// et résultats.
class _FilteredLibrary extends ConsumerStatefulWidget {
  const _FilteredLibrary({required this.items, required this.view});

  final List<MaterialItem> items;
  final LibraryView view;

  @override
  ConsumerState<_FilteredLibrary> createState() => _FilteredLibraryState();
}

class _FilteredLibraryState extends ConsumerState<_FilteredLibrary> {
  late final _search = TextEditingController(text: ref.read(libraryFilterProvider).query);

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _openFilters(BuildContext context) {
    final l10n = context.l10n;
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.85,
        maxChildSize: 0.95,
        builder: (_, controller) => Column(
          children: [
            Expanded(
              child: ListView(
                controller: controller,
                padding: const EdgeInsets.fromLTRB(FxSpace.md, 0, FxSpace.md, FxSpace.md),
                children: const [FilterPanel()],
              ),
            ),
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.all(FxSpace.md),
                child: SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () => Navigator.of(sheetContext).pop(),
                    child: Text(l10n.showResults),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final lang = langOf(context);
    final filter = ref.watch(libraryFilterProvider);
    final ctrl = ref.read(libraryFilterProvider.notifier);
    final results = filter.apply(widget.items, lang: lang);
    final chips = activeFilters(filter, l10n, lang);

    return LayoutBuilder(builder: (context, constraints) {
      final sidePanel = constraints.maxWidth >= 1000;

      final searchRow = Row(
        children: [
          Expanded(
            child: TextField(
              controller: _search,
              onChanged: ctrl.setQuery,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: l10n.searchHint,
                prefixIcon: const Icon(Icons.search),
                suffixIcon: filter.query.isEmpty
                    ? null
                    : IconButton(
                        tooltip: l10n.clearSearch,
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          _search.clear();
                          ctrl.setQuery('');
                        },
                      ),
              ),
            ),
          ),
          if (!sidePanel) ...[
            const SizedBox(width: FxSpace.sm),
            Badge(
              isLabelVisible: filter.activeCount > 0,
              label: Text('${filter.activeCount}'),
              backgroundColor: FxColors.emeraldInk,
              child: OutlinedButton.icon(
                onPressed: () => _openFilters(context),
                icon: const Icon(Icons.tune, size: 18),
                label: Text(l10n.filtersButton),
              ),
            ),
          ],
        ],
      );

      final header = Padding(
        padding: const EdgeInsets.fromLTRB(FxSpace.md, FxSpace.sm, FxSpace.md, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            searchRow,
            if (chips.isNotEmpty) ...[
              const SizedBox(height: FxSpace.sm),
              Wrap(
                spacing: FxSpace.xs + 2,
                runSpacing: FxSpace.xs + 2,
                children: [
                  for (final chip in chips)
                    InputChip(
                      label: Text(chip.label),
                      deleteButtonTooltipMessage: l10n.removeFilter(chip.label),
                      onDeleted: () => ctrl.update(chip.remove),
                    ),
                  TextButton(onPressed: ctrl.clearFilters, child: Text(l10n.clearFilters)),
                ],
              ),
            ],
            if (!filter.isEmpty) ...[
              const SizedBox(height: FxSpace.xs),
              Semantics(
                liveRegion: true,
                child: Text(
                  l10n.resultCount(results.length),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: FxColors.inkSoft),
                ),
              ),
            ],
          ],
        ),
      );

      final Widget body = results.isEmpty
          ? _NoResults(onClear: () {
              _search.clear();
              ctrl.clearAll();
            })
          : RefreshIndicator(
              onRefresh: () => ref.refresh(materialsProvider.future),
              child: widget.view == LibraryView.gallery ? _Gallery(items: results) : _MaterialTable(items: results),
            );

      final main = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [header, Expanded(child: body)],
      );
      if (!sidePanel) return main;
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 300,
            decoration: const BoxDecoration(border: Border(right: BorderSide(color: FxColors.line))),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(FxSpace.md, 0, FxSpace.md, FxSpace.lg),
              children: const [FilterPanel()],
            ),
          ),
          Expanded(child: main),
        ],
      );
    });
  }
}

class _NoResults extends StatelessWidget {
  const _NoResults({required this.onClear});

  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final text = Theme.of(context).textTheme;
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(FxSpace.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.search_off, size: 36, color: FxColors.inkSoft),
            const SizedBox(height: FxSpace.sm),
            Text(l10n.noResultsTitle, style: text.titleMedium),
            const SizedBox(height: FxSpace.xs),
            Text(l10n.noResultsBody, textAlign: TextAlign.center, style: text.bodyMedium?.copyWith(color: FxColors.inkSoft)),
            const SizedBox(height: FxSpace.md),
            OutlinedButton(onPressed: onClear, child: Text(l10n.clearFilters)),
          ],
        ),
      ),
    );
  }
}

class _EmptyLibrary extends StatelessWidget {
  const _EmptyLibrary({required this.canEdit});

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
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  padding: const EdgeInsets.all(FxSpace.md),
                  decoration: BoxDecoration(
                    color: FxColors.mintPale,
                    borderRadius: BorderRadius.circular(FxRadius.lg),
                  ),
                  child: const Icon(Icons.texture, size: 36, color: FxColors.petrol),
                ),
              ),
              const SizedBox(height: FxSpace.md),
              Text(l10n.libraryEmptyTitle, style: text.titleLarge, textAlign: TextAlign.center),
              const SizedBox(height: FxSpace.sm),
              Text(
                canEdit ? l10n.libraryEmptyBody : l10n.libraryEmptyViewer,
                textAlign: TextAlign.center,
                style: text.bodyMedium?.copyWith(color: FxColors.inkSoft),
              ),
              if (canEdit) ...[
                const SizedBox(height: FxSpace.lg),
                FilledButton.icon(
                  onPressed: () => context.go('/scan'),
                  icon: const Icon(Icons.document_scanner_outlined),
                  label: Text(l10n.actionScanSample),
                ),
                const SizedBox(height: FxSpace.sm),
                OutlinedButton.icon(
                  onPressed: () => context.go('/library/import'),
                  icon: const Icon(Icons.upload_file_outlined),
                  label: Text(l10n.actionImportExcel),
                ),
                const SizedBox(height: FxSpace.sm),
                TextButton.icon(
                  onPressed: () => context.go('/library/new'),
                  icon: const Icon(Icons.edit_outlined),
                  label: Text(l10n.actionCreateManual),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _Gallery extends StatelessWidget {
  const _Gallery({required this.items});

  final List<MaterialItem> items;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(FxSpace.md),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 260,
        mainAxisExtent: 286,
        crossAxisSpacing: FxSpace.md,
        mainAxisSpacing: FxSpace.md,
      ),
      itemCount: items.length,
      itemBuilder: (context, i) => _MaterialCard(material: items[i]),
    );
  }
}

class _MaterialCard extends StatelessWidget {
  const _MaterialCard({required this.material});

  final MaterialItem material;

  @override
  Widget build(BuildContext context) {
    final lang = langOf(context);
    final text = Theme.of(context).textTheme;
    final supplier = supplierLine(material);
    final specs = material.specs;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.go('/library/${material.id}'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: 150, child: MaterialVisual(material: material, radius: 0)),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    material.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: text.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  if (supplier != null)
                    Text(
                      supplier,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: text.bodySmall?.copyWith(color: FxColors.inkSoft),
                    ),
                  const SizedBox(height: 6),
                  if (specs.composition.isNotEmpty)
                    TechText(compositionCodes(specs.composition, lang), size: 12, maxLines: 1),
                  if (specs.weightGsm != null || specs.weave != null)
                    TechText(
                      [
                        if (specs.weightGsm != null) '${specs.weightGsm} g/m²',
                        if (specs.weave != null) weaveLabel(specs.weave!, lang),
                      ].join(' · '),
                      size: 12,
                      color: FxColors.inkSoft,
                      maxLines: 1,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MaterialTable extends StatelessWidget {
  const _MaterialTable({required this.items});

  final List<MaterialItem> items;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final lang = langOf(context);
    final text = Theme.of(context).textTheme;
    final header = text.labelSmall?.copyWith(color: FxColors.inkSoft, letterSpacing: 0.4);
    DataColumn col(String label, {bool numeric = false}) =>
        DataColumn(label: Text(label.toUpperCase(), style: header), numeric: numeric);

    return ListView(
      padding: const EdgeInsets.all(FxSpace.md),
      children: [
        Card(
          clipBehavior: Clip.antiAlias,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              showCheckboxColumn: false,
              headingRowColor: const WidgetStatePropertyAll(Color(0xFFF7FBFA)),
              headingRowHeight: 40,
              dataRowMinHeight: 52,
              dataRowMaxHeight: 60,
              columnSpacing: 28,
              columns: [
                col(l10n.colMaterial),
                col(l10n.colReference),
                col(l10n.colComposition),
                col(l10n.colWeight, numeric: true),
                col(l10n.colWidth, numeric: true),
                col(l10n.colStock, numeric: true),
              ],
              rows: [
                for (final m in items)
                  DataRow(
                    onSelectChanged: (_) => context.go('/library/${m.id}'),
                    cells: [
                      DataCell(Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox.square(dimension: 32, child: MaterialVisual(material: m, radius: 6, iconSize: 16)),
                          const SizedBox(width: 10),
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 220),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(m.name, maxLines: 1, overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontWeight: FontWeight.w600)),
                                if (m.supplierName != null)
                                  Text(m.supplierName!, maxLines: 1, overflow: TextOverflow.ellipsis,
                                      style: text.bodySmall?.copyWith(color: FxColors.inkSoft)),
                              ],
                            ),
                          ),
                        ],
                      )),
                      DataCell(TechText(m.supplierCode ?? '—')),
                      DataCell(TechText(
                        m.specs.composition.isEmpty ? '—' : compositionCodes(m.specs.composition, lang),
                      )),
                      DataCell(_Num(m.specs.weightGsm?.toString())),
                      DataCell(_Num(m.specs.widthCm == null ? null : '${m.specs.widthCm} cm')),
                      DataCell(_Num(m.atelierStockM == null
                          ? null
                          : l10n.stockMeters(formatNumber(m.atelierStockM!, lang, decimals: 2)))),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _Num extends StatelessWidget {
  const _Num(this.value);

  final String? value;

  @override
  Widget build(BuildContext context) => Text(
        value ?? '—',
        style: const TextStyle(fontFeatures: [FontFeature.tabularFigures()]),
      );
}
