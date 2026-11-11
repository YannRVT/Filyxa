import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app/theme.dart';
import '../../../l10n/l10n.dart';
import '../../supplier/ui/supplier_texts.dart';
import '../data/materials_repository.dart';
import '../domain/catalog.dart';
import '../domain/catalog_reference.dart';
import '../domain/material.dart';
import 'material_widgets.dart';

/// Référence publiée d'un fournisseur : identité, données techniques et disponibilité.
class ReferenceCard extends StatelessWidget {
  const ReferenceCard({super.key, required this.reference, this.selected = false, this.onTap});

  final CatalogReference reference;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final lang = langOf(context);
    final text = Theme.of(context).textTheme;
    final r = reference;
    final color = colorFromHex(r.colorHex);
    final facts = [
      if (r.specs.composition.isNotEmpty) compositionCodes(r.specs.composition, lang),
      if (r.specs.weightGsm != null) '${r.specs.weightGsm} g/m²',
      if (r.specs.widthCm != null) '${r.specs.widthCm} cm',
      if (r.specs.weave != null) weaveLabel(r.specs.weave!, lang),
    ];
    return Material(
      color: selected ? FxColors.mintPale : FxColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(FxRadius.md),
        side: BorderSide(color: selected ? FxColors.emeraldInk : FxColors.line, width: selected ? 2 : 1),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(FxRadius.md),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(FxSpace.md),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color ?? FxColors.mintPale,
                  borderRadius: BorderRadius.circular(FxRadius.sm),
                  border: Border.all(color: FxColors.line),
                ),
                child: color == null ? const Icon(Icons.texture, color: FxColors.emeraldInk, size: 20) : null,
              ),
              const SizedBox(width: FxSpace.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(r.name, style: text.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                    TechText('${r.supplierName} · ${r.code}', size: 12, color: FxColors.inkSoft),
                    if (facts.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      TechText(facts.join(' · '), size: 12),
                    ],
                    const SizedBox(height: 6),
                    AvailabilityPill(
                      status: r.status,
                      leadTimeWeeks: r.leadTimeWeeks,
                      stockM: r.stockM == null ? null : l10n.stockMeters(formatNumber(r.stockM!, lang, decimals: 2)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Dernières valeurs connues d'une matière dont la référence a été retirée.
class SupplierDataSummary extends StatelessWidget {
  const SupplierDataSummary({super.key, required this.material});

  final MaterialItem material;

  @override
  Widget build(BuildContext context) {
    final lang = langOf(context);
    final m = material;
    final facts = [
      if (m.specs.composition.isNotEmpty) compositionCodes(m.specs.composition, lang),
      if (m.specs.weightGsm != null) '${m.specs.weightGsm} g/m²',
      if (m.specs.widthCm != null) '${m.specs.widthCm} cm',
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (supplierLine(m) != null) TechText(supplierLine(m)!, size: 13, color: FxColors.inkSoft),
        if (facts.isNotEmpty) TechText(facts.join(' · '), size: 13),
      ],
    );
  }
}

/// Résultat de la confirmation : référence choisie, ou aucune.
class MatchChoice {
  const MatchChoice(this.reference);

  final CatalogReference? reference;
}

/// « C'est bien cette référence ? » : la meilleure proposition, puis les autres.
/// Renvoie null si la feuille est fermée sans choix.
Future<MatchChoice?> showMatchSheet(BuildContext context, List<ReferenceMatch> matches) {
  return showModalBottomSheet<MatchChoice>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => _MatchSheet(matches: matches),
  );
}

class _MatchSheet extends StatefulWidget {
  const _MatchSheet({required this.matches});

  final List<ReferenceMatch> matches;

  @override
  State<_MatchSheet> createState() => _MatchSheetState();
}

class _MatchSheetState extends State<_MatchSheet> {
  late CatalogReference _selected = widget.matches.first.reference;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final text = Theme.of(context).textTheme;
    final others = widget.matches.skip(1).toList();
    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.85),
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.fromLTRB(FxSpace.md, 0, FxSpace.md, FxSpace.md),
          children: [
            Text(l10n.matchTitle, style: text.titleLarge),
            const SizedBox(height: FxSpace.xs),
            Text(l10n.matchIntro(_selected.supplierName), style: text.bodyMedium?.copyWith(color: FxColors.inkSoft)),
            const SizedBox(height: FxSpace.md),
            ReferenceCard(
              reference: widget.matches.first.reference,
              selected: _selected.id == widget.matches.first.reference.id,
              onTap: () => setState(() => _selected = widget.matches.first.reference),
            ),
            if (others.isNotEmpty) ...[
              const SizedBox(height: FxSpace.md),
              Text(l10n.matchOthers, style: text.labelLarge),
              const SizedBox(height: FxSpace.sm),
              for (final m in others) ...[
                ReferenceCard(
                  reference: m.reference,
                  selected: _selected.id == m.reference.id,
                  onTap: () => setState(() => _selected = m.reference),
                ),
                const SizedBox(height: FxSpace.sm),
              ],
            ],
            const SizedBox(height: FxSpace.md),
            FilledButton.icon(
              onPressed: () => Navigator.of(context).pop(MatchChoice(_selected)),
              icon: const Icon(Icons.link),
              label: Text(l10n.matchConfirm),
            ),
            const SizedBox(height: FxSpace.sm),
            OutlinedButton(
              onPressed: () => Navigator.of(context).pop(const MatchChoice(null)),
              child: Text(l10n.matchNone),
            ),
          ],
        ),
      ),
    );
  }
}

/// Recherche d'une référence publiée pour lier une fiche après coup.
Future<CatalogReference?> showLinkDialog(BuildContext context) {
  return showDialog<CatalogReference>(context: context, builder: (_) => const _LinkDialog());
}

class _LinkDialog extends ConsumerStatefulWidget {
  const _LinkDialog();

  @override
  ConsumerState<_LinkDialog> createState() => _LinkDialogState();
}

class _LinkDialogState extends ConsumerState<_LinkDialog> {
  final _query = TextEditingController();
  List<CatalogReference>? _results;
  CatalogReference? _selected;
  int _generation = 0;

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  Future<void> _search(String q) async {
    final generation = ++_generation;
    final results = await ref.read(materialsRepositoryProvider).searchCatalog(q);
    // Ignore les réponses d'une recherche dépassée.
    if (mounted && generation == _generation) setState(() => _results = results);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AlertDialog(
      title: Text(l10n.linkToSupplier),
      content: SizedBox(
        width: 520,
        height: 420,
        child: Column(
          children: [
            TextField(
              controller: _query,
              autofocus: true,
              decoration: InputDecoration(hintText: l10n.linkSearchHint, prefixIcon: const Icon(Icons.search)),
              onChanged: _search,
            ),
            const SizedBox(height: FxSpace.md),
            Expanded(
              child: _results == null
                  ? const SizedBox.shrink()
                  : _results!.isEmpty
                      ? Center(child: Text(l10n.linkSearchEmpty))
                      : ListView.separated(
                          itemCount: _results!.length,
                          separatorBuilder: (_, _) => const SizedBox(height: FxSpace.sm),
                          itemBuilder: (_, i) => ReferenceCard(
                            reference: _results![i],
                            selected: _selected?.id == _results![i].id,
                            onTap: () => setState(() => _selected = _results![i]),
                          ),
                        ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(l10n.cancel)),
        FilledButton(
          onPressed: _selected == null ? null : () => Navigator.of(context).pop(_selected),
          child: Text(l10n.linkConfirm),
        ),
      ],
    );
  }
}
