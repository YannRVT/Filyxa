import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app/theme.dart';
import '../../../l10n/l10n.dart';
import '../../../shared/widgets/auth_widgets.dart';
import '../../library/domain/material.dart';
import '../../library/ui/material_widgets.dart' show langOf;
import '../domain/studio.dart';

enum ProductionStep { reserve, deliver }

/// Confirmation du lancement en production (réservation) ou de la livraison (déduction).
/// Renvoie les mètres confirmés par matière, ou null si l'utilisateur annule.
Future<Map<String, double>?> showProductionDialog(
  BuildContext context, {
  required ProductionStep step,
  required StudioModel model,
  required Map<String, double> meters,
  required Map<String, MaterialItem> materials,
  required List<StockReservation> reservations,
}) =>
    showDialog<Map<String, double>>(
      context: context,
      builder: (_) => _ProductionDialog(step: step, model: model, meters: meters, materials: materials, reservations: reservations),
    );

class _ProductionDialog extends StatefulWidget {
  const _ProductionDialog({
    required this.step,
    required this.model,
    required this.meters,
    required this.materials,
    required this.reservations,
  });

  final ProductionStep step;
  final StudioModel model;
  final Map<String, double> meters;
  final Map<String, MaterialItem> materials;
  final List<StockReservation> reservations;

  @override
  State<_ProductionDialog> createState() => _ProductionDialogState();
}

class _ProductionDialogState extends State<_ProductionDialog> {
  late final Map<String, double> _meters = {...widget.meters};
  final _controllers = <String, TextEditingController>{};
  final _invalid = <String>{};

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final lang = langOf(context);
    final text = Theme.of(context).textTheme;
    String m(double v) => l10n.stockMeters(formatNumber(v, lang, decimals: 2));
    final reserve = widget.step == ProductionStep.reserve;
    var anyShortage = false;

    final rows = <Widget>[];
    for (final MapEntry(key: id, value: need) in _meters.entries) {
      final material = widget.materials[id];
      final available = availableStock(
        material?.atelierStockM,
        widget.reservations.where((r) => r.materialId == id),
        exceptModel: widget.model.id,
      );
      final shortage = reserve ? need - available : 0.0;
      if (shortage > 0.005) anyShortage = true;
      rows.add(Padding(
        padding: const EdgeInsets.symmetric(vertical: FxSpace.xs),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(material?.name ?? l10n.materialMissing, style: text.bodyMedium),
                  Text(
                    reserve
                        ? l10n.productionAvailable(m(available))
                        : l10n.productionStock(m(material?.atelierStockM ?? 0)),
                    style: text.bodySmall?.copyWith(color: FxColors.inkSoft),
                  ),
                  if (shortage > 0.005)
                    Text(l10n.productionShortage(m(shortage)), style: text.bodySmall?.copyWith(color: FxColors.error)),
                ],
              ),
            ),
            const SizedBox(width: FxSpace.sm),
            if (reserve)
              Text(m(need), style: text.titleSmall?.copyWith(color: shortage > 0.005 ? FxColors.error : null))
            else
              SizedBox(
                width: 120,
                child: TextField(
                  key: ValueKey('deliver-$id'),
                  controller: _controllers.putIfAbsent(id, () => TextEditingController(text: formatNumber(need, lang, decimals: 2))),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))],
                  decoration: InputDecoration(
                    suffixText: 'm',
                    isDense: true,
                    labelText: l10n.productionUsed,
                    errorText: _invalid.contains(id) ? '' : null,
                  ),
                  // Champ vidé : 0 m consommé. Saisie illisible : livraison bloquée.
                  onChanged: (v) {
                    final x = v.trim().isEmpty ? 0.0 : parseNumber(v);
                    setState(() {
                      if (x != null && x >= 0) {
                        _meters[id] = x;
                        _invalid.remove(id);
                      } else {
                        _invalid.add(id);
                      }
                    });
                  },
                ),
              ),
          ],
        ),
      ));
    }

    return AlertDialog(
      title: Text(reserve ? l10n.productionReserveTitle : l10n.productionDeliverTitle),
      content: SizedBox(
        width: 480,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(reserve ? l10n.productionReserveBody : l10n.productionDeliverBody,
                  style: text.bodySmall?.copyWith(color: FxColors.inkSoft)),
              const SizedBox(height: FxSpace.sm),
              if (_meters.isEmpty) Text(l10n.productionNoMaterial, style: text.bodyMedium),
              ...rows,
              if (anyShortage) ...[const SizedBox(height: FxSpace.sm), MessageBanner.error(l10n.productionShortageNote)],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(l10n.cancel)),
        FilledButton(
          onPressed: _invalid.isEmpty ? () => Navigator.of(context).pop(_meters) : null,
          child: Text(reserve
              ? (anyShortage ? l10n.productionLaunchAnyway : l10n.productionLaunch)
              : l10n.productionDeliver),
        ),
      ],
    );
  }
}

/// Fiche matière : stock atelier, réservé et disponible, avec les modèles qui réservent.
class ReservationSummary extends StatelessWidget {
  const ReservationSummary({super.key, required this.atelierStock, required this.reservations});

  final double? atelierStock;
  final List<StockReservation> reservations;

  @override
  Widget build(BuildContext context) {
    if (reservations.isEmpty) return const SizedBox.shrink();
    final l10n = context.l10n;
    final lang = langOf(context);
    final text = Theme.of(context).textTheme;
    String m(double v) => l10n.stockMeters(formatNumber(v, lang, decimals: 2));
    final reserved = reservations.fold<double>(0, (sum, r) => sum + r.meters);
    final available = availableStock(atelierStock, reservations);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: FxSpace.xs),
        Text(l10n.stockReserved(m(reserved)), style: text.bodySmall),
        Text(
          l10n.stockAvailable(m(available)),
          style: text.bodyMedium?.copyWith(
            color: available < 0 ? FxColors.error : null,
            fontWeight: FontWeight.w600,
          ),
        ),
        for (final r in reservations)
          Text('· ${r.modelName} : ${m(r.meters)}', style: text.bodySmall?.copyWith(color: FxColors.inkSoft)),
      ],
    );
  }
}
