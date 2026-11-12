import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app/theme.dart';
import '../../../l10n/l10n.dart';
import '../../../shared/widgets/auth_widgets.dart';
import '../../auth/data/auth_repository.dart';
import '../../library/domain/material.dart' show formatNumber, parseNumber;
import '../../library/ui/material_widgets.dart' show langOf;
import '../../members/data/members_repository.dart' show currentRoleProvider;
import '../../session/data/user_space_repository.dart';
import '../../session/domain/user_space.dart';
import '../data/studio_repository.dart';
import '../domain/studio.dart';
import 'planning_widgets.dart' show ProLockedNote;
import 'studio_widgets.dart';

extension SizeTexts on AppLocalizations {
  String sizeChartTitle(SizeChart c) => switch (c.code) {
        'alpha' => sizeChartAlpha,
        'eu' => sizeChartEu,
        'shoes' => sizeChartShoes,
        'one' => sizeChartOne,
        _ => c.name ?? '',
      };
}

/// Compte › Grilles de tailles : celles de Filyxa et celles de l'atelier (modifiées par l'Admin).
class SizeChartsScreen extends ConsumerWidget {
  const SizeChartsScreen({super.key});

  Future<void> _edit(BuildContext context, WidgetRef ref, [SizeChart? chart]) async {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    final result = await showDialog<(String, List<String>)>(
      context: context,
      builder: (_) => _SizeChartDialog(chart: chart),
    );
    if (result == null) return;
    try {
      final repo = ref.read(studioRepositoryProvider);
      if (chart == null) {
        final orgId = (await ref.read(userSpaceProvider.future))?.membership?.organization.id;
        if (orgId == null) return;
        await repo.createSizeChart(orgId, result.$1, result.$2);
      } else {
        await repo.updateSizeChart(chart.id, result.$1, result.$2);
      }
      ref.invalidate(sizeChartsProvider);
    } on AuthError catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.failure(e.failure))));
    }
  }

  Future<void> _delete(BuildContext context, WidgetRef ref, SizeChart chart) async {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    if (!await confirmDelete(context, title: l10n.sizeChartDeleteTitle, body: l10n.sizeChartTitle(chart))) return;
    try {
      await ref.read(studioRepositoryProvider).deleteSizeChart(chart.id);
      ref.invalidate(sizeChartsProvider);
    } on AuthError catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.failure(e.failure))));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final text = Theme.of(context).textTheme;
    final charts = ref.watch(sizeChartsProvider);
    final pro = ref.watch(hasProProvider).value ?? false;
    final isAdmin = pro && (ref.watch(currentRoleProvider)?.atLeast(MemberRole.admin) ?? false);

    Widget tile(SizeChart c) => Card(
          margin: const EdgeInsets.only(bottom: FxSpace.sm),
          child: ListTile(
            title: Text(l10n.sizeChartTitle(c), style: text.titleSmall),
            subtitle: Text(c.sizes.join(' · '), style: text.bodySmall?.copyWith(color: FxColors.inkSoft)),
            trailing: !c.builtIn && isAdmin
                ? Row(mainAxisSize: MainAxisSize.min, children: [
                    IconButton(
                      tooltip: l10n.sizeChartEdit,
                      onPressed: () => _edit(context, ref, c),
                      icon: const Icon(Icons.edit_outlined),
                    ),
                    IconButton(
                      tooltip: l10n.delete,
                      onPressed: () => _delete(context, ref, c),
                      icon: const Icon(Icons.delete_outline, color: FxColors.error),
                    ),
                  ])
                : null,
          ),
        );

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.sizeChartsTitle),
        leading: BackButton(onPressed: () => context.go('/account')),
        actions: [
          if (isAdmin)
            Padding(
              padding: const EdgeInsets.only(right: FxSpace.sm),
              child: FilledButton.icon(
                onPressed: () => _edit(context, ref),
                icon: const Icon(Icons.add, size: 18),
                label: Text(l10n.sizeChartNew),
              ),
            ),
        ],
      ),
      body: charts.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: MessageBanner.error(l10n.failure(AuthError.from(e).failure))),
        data: (all) {
          final mine = all.where((c) => !c.builtIn).toList();
          return ListView(
            padding: const EdgeInsets.all(FxSpace.md),
            children: [
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 720),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (!pro) ...[const ProLockedNote(), const SizedBox(height: FxSpace.md)],
                      Text(l10n.sizeChartsBuiltIn, style: text.titleSmall),
                      const SizedBox(height: FxSpace.sm),
                      for (final c in all.where((c) => c.builtIn)) tile(c),
                      const SizedBox(height: FxSpace.md),
                      Text(l10n.sizeChartsMine, style: text.titleSmall),
                      const SizedBox(height: FxSpace.sm),
                      if (mine.isEmpty)
                        Text(l10n.sizeChartsMineEmpty, style: text.bodySmall?.copyWith(color: FxColors.inkSoft)),
                      for (final c in mine) tile(c),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SizeChartDialog extends StatefulWidget {
  const _SizeChartDialog({this.chart});

  final SizeChart? chart;

  @override
  State<_SizeChartDialog> createState() => _SizeChartDialogState();
}

class _SizeChartDialogState extends State<_SizeChartDialog> {
  late final _name = TextEditingController(text: widget.chart?.name ?? '');
  late final _sizes = TextEditingController(text: widget.chart?.sizes.join(', ') ?? '');
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    _sizes.dispose();
    super.dispose();
  }

  void _submit() {
    final l10n = context.l10n;
    final sizes = parseSizes(_sizes.text);
    if (_name.text.trim().isEmpty) {
      setState(() => _error = l10n.errorRequired);
      return;
    }
    if (sizes.isEmpty || sizes.toSet().length != sizes.length || sizes.any((s) => s.length > 12)) {
      setState(() => _error = l10n.sizeErrorInvalid);
      return;
    }
    Navigator.of(context).pop((_name.text.trim(), sizes));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AlertDialog(
      title: Text(widget.chart == null ? l10n.sizeChartNew : l10n.sizeChartEdit),
      content: SizedBox(
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(controller: _name, maxLength: 60, decoration: InputDecoration(labelText: l10n.sizeChartName)),
            TextField(controller: _sizes, decoration: InputDecoration(labelText: l10n.sizeChartSizes, hintText: 'XS, S, M, L')),
            if (_error != null) ...[const SizedBox(height: FxSpace.sm), MessageBanner.error(_error!)],
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(l10n.cancel)),
        FilledButton(onPressed: _submit, child: Text(l10n.save)),
      ],
    );
  }
}

/// Tailles d'un modèle : choix de la grille et tableau tailles × coloris avec totaux.
class ModelSizesCard extends ConsumerStatefulWidget {
  const ModelSizesCard({
    super.key,
    required this.model,
    required this.onChartChanged,
    required this.onQuantity,
    this.onBaseSize,
    this.onGradePct,
    this.onSizeGrade,
  });

  final StudioModel model;
  final ValueChanged<String?> onChartChanged;
  final void Function(Colorway colorway, String size, int quantity) onQuantity;
  final ValueChanged<String>? onBaseSize;
  final ValueChanged<double>? onGradePct;

  /// Écart propre à une taille ; null : retour à l'écart du modèle.
  final void Function(String size, double? gradePct)? onSizeGrade;

  @override
  ConsumerState<ModelSizesCard> createState() => _ModelSizesCardState();
}

class _ModelSizesCardState extends ConsumerState<ModelSizesCard> {
  final _controllers = <String, TextEditingController>{};

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _choose(String? chartId) async {
    final l10n = context.l10n;
    final m = widget.model;
    if (chartId == m.sizeChartId) return;
    final hasQuantities = m.colorways.any((c) => c.sizeQuantities.values.any((q) => q > 0));
    // Sans grille, les quantités par coloris (V1) seront remplacées par la somme des tailles.
    final hasColorwayQuantities = m.sizeChartId == null && chartId != null && m.colorways.any((c) => c.quantity > 0);
    if (hasQuantities || hasColorwayQuantities) {
      final ok = await showDialog<bool>(
        context: context,
        builder: (d) => AlertDialog(
          title: Text(l10n.sizeChartChangeTitle),
          content: Text(hasColorwayQuantities ? l10n.sizeChartFromColorwaysBody : l10n.sizeChartChangeBody),
          actions: [
            TextButton(onPressed: () => Navigator.of(d).pop(false), child: Text(l10n.cancel)),
            FilledButton(onPressed: () => Navigator.of(d).pop(true), child: Text(l10n.sizeChartChange)),
          ],
        ),
      );
      if (ok != true) return;
    }
    if (!mounted) return;
    // Les champs encore affichés utilisent ces contrôleurs : on les libère après la
    // reconstruction, une fois remplacés.
    final old = _controllers.values.toList();
    setState(_controllers.clear);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      for (final c in old) {
        c.dispose();
      }
    });
    widget.onChartChanged(chartId);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final text = Theme.of(context).textTheme;
    final m = widget.model;
    final pro = ref.watch(hasProProvider).value ?? false;
    final canEdit = pro && ref.watch(canEditStudioProvider);
    final charts = ref.watch(sizeChartsProvider).value ?? const <SizeChart>[];
    final chart = charts.where((c) => c.id == m.sizeChartId).firstOrNull;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(FxSpace.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l10n.sizesTitle, style: text.titleSmall),
            const SizedBox(height: FxSpace.sm),
            if (!pro) ...[const ProLockedNote(), const SizedBox(height: FxSpace.sm)],
            if (canEdit)
              Align(
                alignment: Alignment.centerLeft,
                child: SizedBox(
                  width: 320,
                  child: DropdownButtonFormField<String?>(
                    key: ValueKey('chart-${m.sizeChartId}'),
                    initialValue: m.sizeChartId,
                    isExpanded: true,
                    decoration: InputDecoration(labelText: l10n.sizeChartLabel, isDense: true),
                    items: [
                      DropdownMenuItem<String?>(value: null, child: Text(l10n.sizeChartNone)),
                      for (final c in charts) DropdownMenuItem<String?>(value: c.id, child: Text(l10n.sizeChartTitle(c))),
                    ],
                    onChanged: _choose,
                  ),
                ),
              )
            else
              Text('${l10n.sizeChartLabel} : ${chart == null ? l10n.sizeChartNone : l10n.sizeChartTitle(chart)}',
                  style: text.bodyMedium),
            if (chart != null) ...[
              const SizedBox(height: FxSpace.md),
              _grading(m, chart, canEdit),
              const SizedBox(height: FxSpace.md),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: _table(m, chart, canEdit),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Taille de base et écart par taille.
  Widget _grading(StudioModel m, SizeChart chart, bool canEdit) {
    final l10n = context.l10n;
    final lang = langOf(context);
    final text = Theme.of(context).textTheme;
    final base = m.effectiveBaseSize ?? chart.sizes.first;
    if (!canEdit) {
      return Text(l10n.gradingSummary(base, formatNumber(m.gradePct, lang, decimals: 2)), style: text.bodyMedium);
    }
    return Wrap(
      spacing: FxSpace.md,
      runSpacing: FxSpace.sm,
      children: [
        SizedBox(
          width: 160,
          child: DropdownButtonFormField<String>(
            key: ValueKey('base-$base-${chart.id}'),
            initialValue: base,
            decoration: InputDecoration(labelText: l10n.baseSizeLabel, isDense: true),
            items: [for (final s in chart.sizes) DropdownMenuItem(value: s, child: Text(s))],
            onChanged: (v) => v == null ? null : widget.onBaseSize?.call(v),
          ),
        ),
        SizedBox(
          width: 200,
          child: TextField(
            key: const ValueKey('grade'),
            controller: _controllers.putIfAbsent('grade', () => TextEditingController(text: formatNumber(m.gradePct, lang, decimals: 2))),
            keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
            inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[-0-9.,]'))],
            decoration: InputDecoration(labelText: l10n.gradePctLabel, isDense: true),
            onChanged: (v) {
              final pct = parseNumber(v);
              if (pct != null && pct >= -50 && pct <= 50) widget.onGradePct?.call(pct);
            },
          ),
        ),
      ],
    );
  }

  Future<void> _editGrade(String size, double? current) async {
    final l10n = context.l10n;
    final lang = langOf(context);
    final controller = TextEditingController(text: current == null ? '' : formatNumber(current, lang, decimals: 2));
    final result = await showDialog<(bool, double?)>(
      context: context,
      builder: (d) => AlertDialog(
        title: Text(l10n.sizeGradeTitle(size)),
        content: TextField(
          controller: controller,
          autofocus: true,
          keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
          inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[-0-9.,]'))],
          decoration: InputDecoration(labelText: l10n.sizeGradeLabel, helperText: l10n.sizeGradeHelp),
        ),
        actions: [
          if (current != null) TextButton(onPressed: () => Navigator.of(d).pop((true, null)), child: Text(l10n.sizeGradeReset)),
          TextButton(onPressed: () => Navigator.of(d).pop(), child: Text(l10n.cancel)),
          FilledButton(
            onPressed: () {
              final v = parseNumber(controller.text);
              if (v != null && v >= -90 && v <= 300) Navigator.of(d).pop((true, v));
            },
            child: Text(l10n.save),
          ),
        ],
      ),
    );
    controller.dispose();
    if (result != null && result.$1) widget.onSizeGrade?.call(size, result.$2);
  }

  Widget _table(StudioModel m, SizeChart chart, bool canEdit) {
    final l10n = context.l10n;
    final text = Theme.of(context).textTheme;
    final bold = text.labelLarge;
    int sizeTotal(String s) => m.colorways.fold(0, (sum, c) => sum + (c.sizeQuantities[s] ?? 0));
    int rowTotal(Colorway c) => chart.sizes.fold(0, (sum, s) => sum + (c.sizeQuantities[s] ?? 0));
    final grand = m.colorways.fold(0, (sum, c) => sum + rowTotal(c));

    Widget cell(Widget child, {double width = 72}) =>
        SizedBox(width: width, child: Padding(padding: const EdgeInsets.all(4), child: Center(child: child)));

    Widget field(Colorway c, String size) {
      final key = '${c.id}|$size';
      final qty = c.sizeQuantities[size] ?? 0;
      if (!canEdit) return Text('$qty', style: text.bodyMedium);
      final controller = _controllers.putIfAbsent(key, () => TextEditingController(text: qty == 0 ? '' : '$qty'));
      return TextField(
        key: ValueKey('size-$key'),
        controller: controller,
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(7)],
        decoration: const InputDecoration(isDense: true, hintText: '0'),
        onChanged: (v) => widget.onQuantity(c, size, int.tryParse(v) ?? 0),
      );
    }

    Widget gradeCell(String size) {
      final lang = langOf(context);
      final own = m.sizeGrades.containsKey(size);
      final pct = m.sizeGrade(size);
      final label = size == m.effectiveBaseSize ? l10n.baseSizeTag : '${pct > 0 ? '+' : ''}${formatNumber(pct, lang, decimals: 1)} %';
      final style = text.bodySmall?.copyWith(color: own ? FxColors.emeraldInk : FxColors.inkSoft, fontWeight: own ? FontWeight.w600 : null);
      if (!canEdit || size == m.effectiveBaseSize) return Text(label, style: style);
      return InkWell(
        key: ValueKey('grade-$size'),
        onTap: () => _editGrade(size, own ? pct : null),
        child: Padding(padding: const EdgeInsets.symmetric(vertical: 4), child: Text(label, style: style)),
      );
    }

    return Table(
      defaultColumnWidth: const IntrinsicColumnWidth(),
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      border: const TableBorder(horizontalInside: BorderSide(color: FxColors.line)),
      children: [
        TableRow(children: [
          cell(const SizedBox(), width: 140),
          for (final s in chart.sizes) cell(Text(s, style: bold)),
          cell(Text(l10n.totalLabel, style: bold)),
        ]),
        TableRow(children: [
          SizedBox(width: 140, child: Text(l10n.gradeRowLabel, style: text.bodySmall?.copyWith(color: FxColors.inkSoft))),
          for (final s in chart.sizes) cell(gradeCell(s)),
          cell(const SizedBox()),
        ]),
        for (final (i, c) in m.colorways.indexed)
          TableRow(children: [
            SizedBox(
              width: 140,
              child: Text(l10n.colorwayName(c, i), style: text.bodyMedium, overflow: TextOverflow.ellipsis),
            ),
            for (final s in chart.sizes) cell(field(c, s)),
            cell(Text('${rowTotal(c)}', style: bold)),
          ]),
        TableRow(children: [
          SizedBox(width: 140, child: Text(l10n.totalLabel, style: bold)),
          for (final s in chart.sizes) cell(Text('${sizeTotal(s)}', style: bold)),
          cell(Text('$grand', style: bold)),
        ]),
      ],
    );
  }
}

/// Besoin d'une matière détaillé par coloris (lignes) et par taille (colonnes), en mètres.
class RequirementDetailTable extends StatelessWidget {
  const RequirementDetailTable({super.key, required this.model, required this.materialId});

  final StudioModel model;
  final String materialId;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final lang = langOf(context);
    final text = Theme.of(context).textTheme;
    final bold = text.labelMedium;
    final detail = requirementDetail(model, materialId);
    String m(double v) => formatNumber(v, lang, decimals: 2);
    Widget cell(String s, {TextStyle? style, double width = 64}) =>
        SizedBox(width: width, child: Padding(padding: const EdgeInsets.all(4), child: Text(s, style: style, textAlign: TextAlign.right)));
    final rows = [
      for (final (i, c) in model.colorways.indexed)
        if (detail.containsKey(c.id)) (l10n.colorwayName(c, i), detail[c.id]!),
    ];
    double col(String s) => rows.fold(0, (sum, r) => sum + (r.$2[s] ?? 0));
    double row(Map<String, double> r) => r.values.fold(0, (a, b) => a + b);
    return Table(
      defaultColumnWidth: const IntrinsicColumnWidth(),
      border: const TableBorder(horizontalInside: BorderSide(color: FxColors.line)),
      children: [
        TableRow(children: [
          cell('', width: 120),
          for (final s in model.sizes) cell(s, style: bold),
          cell(l10n.totalLabel, style: bold, width: 80),
        ]),
        for (final r in rows)
          TableRow(children: [
            SizedBox(width: 120, child: Padding(padding: const EdgeInsets.all(4), child: Text(r.$1, style: text.bodySmall))),
            for (final s in model.sizes) cell(m(r.$2[s] ?? 0), style: text.bodySmall),
            cell(m(row(r.$2)), style: bold, width: 80),
          ]),
        if (rows.length > 1)
          TableRow(children: [
            SizedBox(width: 120, child: Padding(padding: const EdgeInsets.all(4), child: Text(l10n.totalLabel, style: bold))),
            for (final s in model.sizes) cell(m(col(s)), style: bold),
            cell(m(rows.fold(0.0, (a, r) => a + row(r.$2))), style: bold, width: 80),
          ]),
      ],
    );
  }
}
