import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app/theme.dart';
import '../../../l10n/l10n.dart';
import '../../../shared/widgets/auth_widgets.dart';
import '../../library/data/materials_repository.dart';
import '../../library/domain/material.dart';
import '../../library/ui/material_widgets.dart' show langOf;
import '../data/studio_repository.dart';
import '../domain/studio.dart';
import 'planning_widgets.dart' show ProLockedNote;
import 'studio_widgets.dart';

/// Montant en euros, au format de la langue de l'interface.
String formatEuro(BuildContext context, double value) =>
    NumberFormat.simpleCurrency(locale: Localizations.localeOf(context).toLanguageTag(), name: 'EUR').format(value);

extension CostTexts on AppLocalizations {
  String costKindLabel(CostKind k) => switch (k) {
        CostKind.supply => costKindSupply,
        CostKind.labor => costKindLabor,
        CostKind.overhead => costKindOverhead,
      };
}

/// Prix au mètre des matières de l'atelier (null : sans prix, ou Lecteur).
Map<String, double?> watchPrices(WidgetRef ref) =>
    {for (final m in ref.watch(materialsProvider).value ?? const <MaterialItem>[]) m.id: m.pricePerM};

/// Coût de revient d'un modèle (Admins et Éditeurs ; jamais pour un Lecteur).
class ModelCostCard extends ConsumerWidget {
  const ModelCostCard({
    super.key,
    required this.model,
    required this.materials,
    required this.onAdd,
    required this.onUpdate,
    required this.onDelete,
    this.onTargetPrice,
  });

  final StudioModel model;
  final Map<String, MaterialItem> materials;
  final ValueChanged<CostLine> onAdd;
  final ValueChanged<CostLine> onUpdate;
  final ValueChanged<CostLine> onDelete;

  /// Prix de vente visé ; null : effacé.
  final ValueChanged<double?>? onTargetPrice;

  Future<void> _edit(BuildContext context, [CostLine? line]) async {
    final result = await showDialog<CostLine>(
      context: context,
      builder: (_) => _CostLineDialog(line: line, position: model.costs.length),
    );
    if (result == null) return;
    line == null ? onAdd(result) : onUpdate(result);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!ref.watch(canEditStudioProvider)) return const SizedBox.shrink();
    final l10n = context.l10n;
    final text = Theme.of(context).textTheme;
    final pro = ref.watch(hasProProvider).value ?? false;
    final cost = modelCost(model, watchPrices(ref));
    String eur(double v) => formatEuro(context, v);
    final perPiece = cost.perPiece;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(FxSpace.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(child: Text(l10n.costTitle, style: text.titleMedium)),
                if (perPiece != null)
                  Text(l10n.costPerPiece(eur(perPiece)), style: text.titleSmall?.copyWith(color: FxColors.petrol)),
              ],
            ),
            if (!pro) ...[const SizedBox(height: FxSpace.sm), const ProLockedNote()],
            if (!cost.complete) ...[
              const SizedBox(height: FxSpace.sm),
              MessageBanner.error(l10n.costIncomplete(
                  cost.missingPrices.map((id) => materials[id]?.name ?? l10n.materialMissing).join(', '))),
            ],
            const SizedBox(height: FxSpace.sm),
            _row(context, l10n.costMaterials, eur(cost.materials)),
            for (final c in model.costs)
              _row(
                context,
                '${l10n.costKindLabel(c.kind)} · ${c.label}',
                c.perModel ? l10n.costFlat(eur(c.amount)) : l10n.costPerPieceShort(eur(c.amount)),
                onTap: pro ? () => _edit(context, c) : null,
                onDelete: pro ? () => onDelete(c) : null,
              ),
            if (pro)
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: () => _edit(context),
                  icon: const Icon(Icons.add, size: 18),
                  label: Text(l10n.costAdd),
                ),
              ),
            const Divider(),
            _row(context, l10n.costTotal(model.pieces), eur(cost.total), bold: true),
            if (model.hasVariants)
              for (final (i, c) in model.colorways.indexed)
                if (cost.byColorway[c.id] != null)
                  _row(context, l10n.colorwayName(c, i), l10n.costPerPieceShort(eur(cost.byColorway[c.id]!))),
            _row(context, l10n.costPrototyping, eur(cost.prototyping)),
            const Divider(),
            if (pro)
              _TargetPriceField(price: model.targetPrice, onChanged: (v) => onTargetPrice?.call(v))
            else if (model.targetPrice != null)
              _row(context, l10n.costTargetPrice, eur(model.targetPrice!)),
            const SizedBox(height: FxSpace.sm),
            CoefficientLine(cost: cost, targetPrice: model.targetPrice),
          ],
        ),
      ),
    );
  }

  Widget _row(BuildContext context, String label, String value,
      {bool bold = false, VoidCallback? onTap, VoidCallback? onDelete}) {
    final text = Theme.of(context).textTheme;
    final style = bold ? text.titleSmall : text.bodyMedium;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Expanded(child: Text(label, style: style)),
            Text(value, style: style?.copyWith(fontFeatures: const [FontFeature.tabularFigures()])),
            if (onDelete != null)
              IconButton(
                tooltip: context.l10n.delete,
                visualDensity: VisualDensity.compact,
                onPressed: onDelete,
                icon: const Icon(Icons.close, size: 16),
              ),
          ],
        ),
      ),
    );
  }
}

class _CostLineDialog extends StatefulWidget {
  const _CostLineDialog({this.line, required this.position});

  final CostLine? line;
  final int position;

  @override
  State<_CostLineDialog> createState() => _CostLineDialogState();
}

class _CostLineDialogState extends State<_CostLineDialog> {
  late CostKind _kind = widget.line?.kind ?? CostKind.supply;
  late bool _perModel = widget.line?.perModel ?? false;
  late final _label = TextEditingController(text: widget.line?.label ?? '');
  late final _price = TextEditingController();
  late final _quantity = TextEditingController();
  String? _error;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final lang = langOf(context);
    if (_price.text.isEmpty && widget.line != null) _price.text = formatNumber(widget.line!.unitPrice, lang, decimals: 2);
    if (_quantity.text.isEmpty) _quantity.text = formatNumber(widget.line?.quantity ?? 1, lang, decimals: 3);
  }

  @override
  void dispose() {
    _label.dispose();
    _price.dispose();
    _quantity.dispose();
    super.dispose();
  }

  void _submit() {
    final l10n = context.l10n;
    final price = parseNumber(_price.text);
    final quantity = parseNumber(_quantity.text);
    if (_label.text.trim().isEmpty || price == null || price < 0 || quantity == null || quantity < 0) {
      setState(() => _error = l10n.errorRequired);
      return;
    }
    Navigator.of(context).pop(CostLine(
      id: widget.line?.id ?? '',
      kind: _kind,
      label: _label.text.trim(),
      unitPrice: price,
      quantity: quantity,
      perModel: _perModel,
      position: widget.line?.position ?? widget.position,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final decimal = [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))];
    return AlertDialog(
      title: Text(widget.line == null ? l10n.costAdd : l10n.costEdit),
      content: SizedBox(
        width: 420,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SegmentedButton<CostKind>(
                segments: [for (final k in CostKind.values) ButtonSegment(value: k, label: Text(l10n.costKindLabel(k)))],
                selected: {_kind},
                onSelectionChanged: (v) => setState(() => _kind = v.first),
              ),
              const SizedBox(height: FxSpace.sm),
              TextField(controller: _label, maxLength: 80, decoration: InputDecoration(labelText: l10n.costLabel)),
              TextField(
                key: const ValueKey('cost-price'),
                controller: _price,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: decimal,
                decoration: InputDecoration(labelText: l10n.costUnitPrice, suffixText: '€'),
              ),
              TextField(
                key: const ValueKey('cost-quantity'),
                controller: _quantity,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: decimal,
                decoration: InputDecoration(labelText: _perModel ? l10n.costQuantityFlat : l10n.costQuantity),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: _perModel,
                onChanged: (v) => setState(() => _perModel = v),
                title: Text(l10n.costPerModelSwitch),
              ),
              if (_error != null) MessageBanner.error(_error!),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(l10n.cancel)),
        FilledButton(onPressed: _submit, child: Text(l10n.save)),
      ],
    );
  }
}

/// Coût de la collection : somme des modèles, prototypage à part (Admins et Éditeurs).
class CollectionCostSummary extends ConsumerWidget {
  const CollectionCostSummary({super.key, required this.models});

  final List<StudioModel> models;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!ref.watch(canEditStudioProvider) || !(ref.watch(hasProProvider).value ?? false)) return const SizedBox.shrink();
    final l10n = context.l10n;
    final text = Theme.of(context).textTheme;
    final prices = watchPrices(ref);
    final costs = [for (final m in models) modelCost(m, prices)];
    if (costs.every((c) => c.total == 0 && c.prototyping == 0)) return const SizedBox.shrink();
    final total = costs.fold<double>(0, (sum, c) => sum + c.total);
    final proto = costs.fold<double>(0, (sum, c) => sum + c.prototyping);
    final complete = costs.every((c) => c.complete);
    return Card(
      color: FxColors.mintPale,
      child: Padding(
        padding: const EdgeInsets.all(FxSpace.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.collectionCost(formatEuro(context, total)), style: text.titleSmall),
            Text(l10n.collectionCostPrototyping(formatEuro(context, proto)), style: text.bodySmall),
            if (!complete) Text(l10n.costIncompleteShort, style: text.bodySmall?.copyWith(color: FxColors.error)),
          ],
        ),
      ),
    );
  }
}

/// Coefficient obtenu, comparé au minimum de l'atelier ; sinon ce qui manque pour le calculer.
class CoefficientLine extends ConsumerWidget {
  const CoefficientLine({super.key, required this.cost, required this.targetPrice});

  final ModelCost cost;
  final double? targetPrice;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final lang = langOf(context);
    final text = Theme.of(context).textTheme;
    final min = ref.watch(minCoefficientProvider).value ?? kDefaultMinCoefficient;
    final coef = coefficient(cost, targetPrice);
    if (coef == null) {
      return Text(
        targetPrice == null || targetPrice! <= 0 ? l10n.coefficientNeedPrice : l10n.coefficientIncomplete,
        style: text.bodySmall?.copyWith(color: FxColors.inkSoft),
      );
    }
    final value = formatNumber(coef, lang, decimals: 2);
    if (coef < min) return MessageBanner.error(l10n.coefficientLow(value, formatNumber(min, lang, decimals: 2)));
    return Text(l10n.coefficientValue(value), style: text.titleSmall?.copyWith(color: FxColors.success));
  }
}

/// Coefficient sous le minimum : texte de l'alerte, ou null (Lecteurs exclus).
String? lowCoefficientText(BuildContext context, WidgetRef ref, StudioModel model) {
  if (!ref.watch(canEditStudioProvider)) return null;
  final min = ref.watch(minCoefficientProvider).value ?? kDefaultMinCoefficient;
  final coef = coefficient(modelCost(model, watchPrices(ref)), model.targetPrice);
  if (coef == null || coef >= min) return null;
  final lang = langOf(context);
  return context.l10n.coefficientLow(formatNumber(coef, lang, decimals: 2), formatNumber(min, lang, decimals: 2));
}

class _TargetPriceField extends StatefulWidget {
  const _TargetPriceField({required this.price, required this.onChanged});

  final double? price;
  final ValueChanged<double?> onChanged;

  @override
  State<_TargetPriceField> createState() => _TargetPriceFieldState();
}

class _TargetPriceFieldState extends State<_TargetPriceField> {
  TextEditingController? _controller;

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lang = langOf(context);
    _controller ??= TextEditingController(text: widget.price == null ? '' : formatNumber(widget.price!, lang, decimals: 2));
    return Align(
      alignment: Alignment.centerLeft,
      child: SizedBox(
        width: 220,
        child: TextField(
          key: const ValueKey('target-price'),
          controller: _controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))],
          decoration: InputDecoration(labelText: context.l10n.costTargetPrice, suffixText: '€', isDense: true),
          onChanged: (v) {
            if (v.trim().isEmpty) return widget.onChanged(null);
            final x = parseNumber(v);
            if (x != null && x >= 0) widget.onChanged(x);
          },
        ),
      ),
    );
  }
}
