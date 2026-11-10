import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app/theme.dart';
import '../../../l10n/l10n.dart';
import '../domain/catalog.dart';
import '../domain/color_family.dart';
import '../domain/library_filter.dart';
import 'material_widgets.dart';

/// Recherche et filtres de TissuTech. Global à l'app : ils sont conservés quand
/// on ouvre une fiche puis qu'on revient à la liste.
class LibraryFilterController extends Notifier<LibraryFilter> {
  @override
  LibraryFilter build() => const LibraryFilter();

  void update(LibraryFilter Function(LibraryFilter) change) => state = change(state);

  void setQuery(String query) => state = state.copyWith(query: query);

  void clearFilters() => state = state.clearFilters();

  void clearAll() => state = const LibraryFilter();
}

final libraryFilterProvider =
    NotifierProvider<LibraryFilterController, LibraryFilter>(LibraryFilterController.new);

Set<T> _toggle<T>(Set<T> set, T value) =>
    set.contains(value) ? ({...set}..remove(value)) : {...set, value};

/// Un filtre actif, affiché en puce amovible.
class ActiveFilter {
  const ActiveFilter(this.label, this.remove);

  final String label;
  final LibraryFilter Function(LibraryFilter) remove;
}

List<ActiveFilter> activeFilters(LibraryFilter f, AppLocalizations l10n, String lang) => [
      if (f.fiber != null)
        ActiveFilter(
          f.fiberMinPct > 0
              ? l10n.chipFiberMin(fiberLabel(f.fiber!, lang), f.fiberMinPct.round())
              : fiberLabel(f.fiber!, lang),
          (x) => x.copyWith(fiber: () => null, fiberMinPct: 0),
        ),
      if (f.weightMin != null || f.weightMax != null)
        ActiveFilter(
          f.weightMin != null && f.weightMax != null
              ? l10n.chipWeightRange(f.weightMin!, f.weightMax!)
              : f.weightMin != null
                  ? l10n.chipWeightMin(f.weightMin!)
                  : l10n.chipWeightMax(f.weightMax!),
          (x) => x.copyWith(weightMin: () => null, weightMax: () => null),
        ),
      for (final c in f.colors) ActiveFilter(c.label(lang), (x) => x.copyWith(colors: _toggle(x.colors, c))),
      for (final w in f.weaves) ActiveFilter(weaveLabel(w, lang), (x) => x.copyWith(weaves: _toggle(x.weaves, w))),
      for (final c in f.certifications)
        ActiveFilter(c, (x) => x.copyWith(certifications: _toggle(x.certifications, c))),
      for (final u in f.uses) ActiveFilter(useLabel(u, lang), (x) => x.copyWith(uses: _toggle(x.uses, u))),
      if (f.inStockOnly) ActiveFilter(l10n.filterInStock, (x) => x.copyWith(inStockOnly: false)),
    ];

/// Panneau des facettes : fibre avec % minimum, grammage, couleur, armure,
/// certifications, usages, stock atelier.
class FilterPanel extends ConsumerWidget {
  const FilterPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final lang = langOf(context);
    final text = Theme.of(context).textTheme;
    final f = ref.watch(libraryFilterProvider);
    final ctrl = ref.read(libraryFilterProvider.notifier);

    Widget title(String label) => Padding(
          padding: const EdgeInsets.only(top: FxSpace.lg, bottom: FxSpace.sm),
          child: Text(label.toUpperCase(),
              style: text.labelSmall?.copyWith(color: FxColors.inkSoft, letterSpacing: 0.6)),
        );
    Widget chips(List<Widget> children) =>
        Wrap(spacing: FxSpace.xs + 2, runSpacing: FxSpace.xs + 2, children: children);

    final weightValues = RangeValues(
      (f.weightMin ?? kWeightMin).toDouble(),
      (f.weightMax ?? kWeightMax).toDouble(),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        title(l10n.filterFiber),
        DropdownButtonFormField<String?>(
          initialValue: f.fiber,
          isExpanded: true,
          decoration: InputDecoration(labelText: l10n.filterFiber),
          items: [
            DropdownMenuItem(value: null, child: Text(l10n.filterFiberAny)),
            for (final fiber in fibers)
              DropdownMenuItem(value: fiber.code, child: Text('${fiber.label(lang)} (${fiber.code})')),
          ],
          onChanged: (v) => ctrl.update((x) => x.copyWith(fiber: () => v, fiberMinPct: v == null ? 0 : x.fiberMinPct)),
        ),
        if (f.fiber != null) ...[
          const SizedBox(height: FxSpace.sm),
          Text(l10n.filterFiberMin(f.fiberMinPct.round()), style: text.bodySmall),
          Slider(
            value: f.fiberMinPct,
            max: 100,
            divisions: 20,
            label: '${f.fiberMinPct.round()} %',
            onChanged: (v) => ctrl.update((x) => x.copyWith(fiberMinPct: v)),
          ),
        ],
        title(l10n.filterWeight),
        Text(
          '${weightValues.start.round()} – ${weightValues.end.round()}${weightValues.end >= kWeightMax ? '+' : ''} g/m²',
          style: FxTheme.mono(size: 13),
        ),
        RangeSlider(
          values: weightValues,
          max: kWeightMax.toDouble(),
          divisions: kWeightMax ~/ 10,
          labels: RangeLabels('${weightValues.start.round()}', '${weightValues.end.round()}'),
          onChanged: (r) => ctrl.update((x) => x.copyWith(
                weightMin: () => r.start <= kWeightMin ? null : r.start.round(),
                weightMax: () => r.end >= kWeightMax ? null : r.end.round(),
              )),
        ),
        title(l10n.filterColor),
        chips([
          for (final c in ColorFamily.values)
            FilterChip(
              avatar: CircleAvatar(backgroundColor: c.swatch, radius: 8),
              label: Text(c.label(lang)),
              selected: f.colors.contains(c),
              onSelected: (_) => ctrl.update((x) => x.copyWith(colors: _toggle(x.colors, c))),
            ),
        ]),
        title(l10n.fieldWeave),
        chips([
          for (final w in weaves)
            FilterChip(
              label: Text(w.label(lang)),
              selected: f.weaves.contains(w.code),
              onSelected: (_) => ctrl.update((x) => x.copyWith(weaves: _toggle(x.weaves, w.code))),
            ),
        ]),
        title(l10n.fieldCertifications),
        chips([
          for (final c in certifications)
            FilterChip(
              label: Text(c),
              selected: f.certifications.contains(c),
              onSelected: (_) => ctrl.update((x) => x.copyWith(certifications: _toggle(x.certifications, c))),
            ),
        ]),
        title(l10n.fieldUses),
        chips([
          for (final u in uses)
            FilterChip(
              label: Text(u.label(lang)),
              selected: f.uses.contains(u.code),
              onSelected: (_) => ctrl.update((x) => x.copyWith(uses: _toggle(x.uses, u.code))),
            ),
        ]),
        const SizedBox(height: FxSpace.md),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(l10n.filterInStock),
          value: f.inStockOnly,
          onChanged: (v) => ctrl.update((x) => x.copyWith(inStockOnly: v)),
        ),
        if (f.activeCount > 0) ...[
          const SizedBox(height: FxSpace.sm),
          OutlinedButton(onPressed: ctrl.clearFilters, child: Text(l10n.clearFilters)),
        ],
      ],
    );
  }
}
