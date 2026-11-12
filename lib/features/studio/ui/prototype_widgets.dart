import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app/theme.dart';
import '../../../l10n/l10n.dart';
import '../../library/domain/material.dart';
import '../../library/ui/material_widgets.dart' show langOf;
import '../data/studio_repository.dart';
import '../domain/studio.dart';
import 'planning_widgets.dart' show ProLockedNote;
import 'studio_widgets.dart';

/// Prototypage : nombre de prototypes et perte de prototypage de chaque matière (premier coloris).
class PrototypingCard extends ConsumerStatefulWidget {
  const PrototypingCard({
    super.key,
    required this.model,
    required this.materials,
    required this.onCount,
    required this.onLoss,
  });

  final StudioModel model;
  final Map<String, MaterialItem> materials;
  final ValueChanged<int> onCount;
  final void Function(BomLine line, double pct) onLoss;

  @override
  ConsumerState<PrototypingCard> createState() => _PrototypingCardState();
}

class _PrototypingCardState extends ConsumerState<PrototypingCard> {
  final _controllers = <String, TextEditingController>{};

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  TextEditingController _controller(String key, String initial) =>
      _controllers.putIfAbsent(key, () => TextEditingController(text: initial));

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final lang = langOf(context);
    final text = Theme.of(context).textTheme;
    final m = widget.model;
    final pro = ref.watch(hasProProvider).value ?? false;
    final canEdit = pro && ref.watch(canEditStudioProvider);
    final lines = m.colorways.isEmpty ? const <BomLine>[] : m.colorways.first.lines;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(FxSpace.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l10n.prototypingTitle, style: text.titleSmall),
            Text(l10n.prototypingHelp, style: text.bodySmall?.copyWith(color: FxColors.inkSoft)),
            const SizedBox(height: FxSpace.sm),
            if (!pro) ...[const ProLockedNote(), const SizedBox(height: FxSpace.sm)],
            if (canEdit)
              Align(
                alignment: Alignment.centerLeft,
                child: SizedBox(
                  width: 200,
                  child: TextField(
                    key: const ValueKey('proto-count'),
                    controller: _controller('count', '${m.prototypeCount}'),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(4)],
                    decoration: InputDecoration(labelText: l10n.prototypeCountLabel, isDense: true),
                    onChanged: (v) {
                      final n = int.tryParse(v);
                      if (n != null && n <= 1000) widget.onCount(n);
                    },
                  ),
                ),
              )
            else
              Text('${l10n.prototypeCountLabel} : ${m.prototypeCount}', style: text.bodyMedium),
            const SizedBox(height: FxSpace.sm),
            for (final l in lines)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${widget.materials[l.materialId]?.name ?? l10n.materialMissing} · ${l10n.roleText(l.role)}',
                        style: text.bodyMedium,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (canEdit)
                      SizedBox(
                        width: 150,
                        child: TextField(
                          key: ValueKey('proto-loss-${l.id}'),
                          controller: _controller('loss-${l.id}', formatNumber(l.protoLossPct, lang, decimals: 2)),
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))],
                          decoration: InputDecoration(labelText: l10n.protoLossLabel, isDense: true),
                          onChanged: (v) {
                            final pct = parseNumber(v);
                            if (pct != null && pct >= 0 && pct <= 500) widget.onLoss(l, pct);
                          },
                        ),
                      )
                    else
                      Text('${l10n.protoLossLabel} : ${formatNumber(l.protoLossPct, lang, decimals: 2)}', style: text.bodySmall),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
