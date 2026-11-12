import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app/theme.dart';
import '../../../l10n/l10n.dart';
import '../../../shared/widgets/auth_widgets.dart';
import '../../auth/data/auth_repository.dart';
import '../../export/export_screen.dart';
import '../../library/data/materials_repository.dart';
import '../../library/domain/material.dart';
import '../../library/ui/material_widgets.dart';
import '../../share/data/share_repository.dart';
import '../../share/ui/share_widgets.dart';
import '../data/studio_repository.dart';
import '../domain/studio.dart';
import 'alert_widgets.dart';
import 'planning_widgets.dart';
import 'production_widgets.dart';
import 'prototype_widgets.dart';
import 'size_widgets.dart';
import 'studio_widgets.dart';

/// Délai avant l'enregistrement d'une saisie (le calcul, lui, est immédiat).
const kStudioSaveDelay = Duration(milliseconds: 600);

/// Modèle : coloris, matières par rôle, consommation, quantités et besoin.
class ModelScreen extends ConsumerStatefulWidget {
  const ModelScreen({super.key, required this.modelId});

  final String modelId;

  @override
  ConsumerState<ModelScreen> createState() => _ModelScreenState();
}

class _ModelScreenState extends ConsumerState<ModelScreen> {
  /// Copie de travail : les saisies s'y appliquent aussitôt, le besoin est recalculé à chaque frappe.
  StudioModel? _model;
  int _tab = 0;
  String? _error;

  final _controllers = <String, TextEditingController>{};
  final _pending = <String, Timer>{};
  final _saves = <String, Future<void> Function()>{};

  @override
  void dispose() {
    // Les saisies en attente partent quand même.
    for (final key in _pending.keys.toList()) {
      _pending.remove(key)?.cancel();
      _saves.remove(key)?.call();
    }
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  StudioRepository get _repo => ref.read(studioRepositoryProvider);

  TextEditingController _controller(String key, String initial) =>
      _controllers.putIfAbsent(key, () => TextEditingController(text: initial));

  /// Enregistre après une pause dans la saisie.
  void _schedule(String key, Future<void> Function() save) {
    _pending.remove(key)?.cancel();
    _saves[key] = save;
    _pending[key] = Timer(kStudioSaveDelay, () {
      _pending.remove(key);
      _run(_saves.remove(key)!);
    });
  }

  Future<void> _flush() async {
    final saves = [for (final key in _pending.keys.toList()) _saves.remove(key)];
    for (final t in _pending.values) {
      t.cancel();
    }
    _pending.clear();
    for (final s in saves) {
      if (s != null) await _run(s);
    }
  }

  Future<void> _run(Future<void> Function() action) async {
    try {
      await action();
      if (mounted && _error != null) setState(() => _error = null);
    } on AuthError catch (e) {
      if (mounted) setState(() => _error = context.l10n.failure(e.failure));
    }
  }

  /// Après un changement de structure (coloris, lignes) : relecture du modèle.
  Future<void> _structural(Future<void> Function() action) async {
    await _flush();
    try {
      await action();
      final fresh = await _repo.model(widget.modelId);
      ref.invalidate(modelProvider(widget.modelId));
      if (fresh != null) ref.invalidate(collectionModelsProvider(fresh.collectionId));
      ref.invalidate(customRolesProvider);
      if (!mounted) return;
      setState(() {
        _model = fresh;
        _error = null;
        if (fresh != null) _tab = _tab.clamp(0, fresh.colorways.length - 1);
      });
    } on AuthError catch (e) {
      if (mounted) setState(() => _error = context.l10n.failure(e.failure));
    }
  }

  // Saisies ---------------------------------------------------------------------------------------

  void _setWaste(String text) {
    final v = parseNumber(text);
    if (v == null || v < 0 || v > 100) return;
    setState(() => _model = _model!.copyWith(wastePct: v));
    _schedule('waste', () => _repo.updateModel(widget.modelId, wastePct: v));
  }

  void _setQuantity(Colorway c, String text) {
    final v = text.trim().isEmpty ? 0 : int.tryParse(text.trim());
    if (v == null || v < 0 || v > 10000000) return;
    _replaceColorway(c.id, (x) => x.copyWith(quantity: v));
    _schedule('qty-${c.id}', () => _repo.updateColorway(c.id, quantity: v));
  }

  void _setConsumption(Colorway c, BomLine l, String text) {
    final v = text.trim().isEmpty ? 0.0 : parseNumber(text);
    if (v == null || v < 0 || v > 1000) return;
    _replaceColorway(
      c.id,
      (x) => x.copyWith(lines: [for (final y in x.lines) y.id == l.id ? y.copyWith(consumption: v) : y]),
    );
    _schedule('line-${l.id}', () => _repo.updateLine(l.id, consumption: v));
  }

  void _replaceColorway(String id, Colorway Function(Colorway) change) => setState(() {
        _model = _model!.copyWith(colorways: [for (final c in _model!.colorways) c.id == id ? change(c) : c]);
      });

  // Actions ---------------------------------------------------------------------------------------

  Future<void> _addColorway() async {
    final m = _model!;
    final current = m.colorways[_tab];
    final input = await showDialog<(String?, String)>(
      context: context,
      builder: (_) => _ColorwayDialog(
        // Premier déclinaison : on nomme aussi le coloris existant.
        askCurrent: !m.hasVariants && (current.name ?? '').trim().isEmpty,
        copyFromName: context.l10n.colorwayName(current, _tab),
      ),
    );
    if (input == null) return;
    final (currentName, newName) = input;
    await _structural(() async {
      if (currentName != null) await _repo.updateColorway(current.id, name: currentName);
      await _repo.addColorway(m.id, newName, copyFrom: current.id);
    });
    if (mounted && _model != null) setState(() => _tab = _model!.colorways.length - 1);
  }

  Future<void> _deleteColorway(Colorway c) async {
    final l10n = context.l10n;
    if (!await confirmDelete(context, title: l10n.deleteColorway, body: l10n.colorwayName(c, _tab))) return;
    await _structural(() => _repo.deleteColorway(c.id));
  }

  Future<void> _addLine(Colorway c) async {
    final input = await showAddMaterialDialog(context, type: _model!.productType);
    if (input == null) return;
    await _structural(
      () => _repo.addLine(c.id, materialId: input.materialId, role: input.role, consumption: input.consumption),
    );
  }

  Future<void> _setStatus(ModelStatus status) async {
    final m = _model!;
    // Lancement en production : réservation confirmée ; livraison : déduction confirmée.
    final step = status == ModelStatus.inProduction && m.status != ModelStatus.inProduction
        ? ProductionStep.reserve
        : status == ModelStatus.delivered && m.status == ModelStatus.inProduction
            ? ProductionStep.deliver
            : null;
    if (step != null) {
      await _flush();
      final materials = {for (final x in ref.read(materialsProvider).value ?? const <MaterialItem>[]) x.id: x};
      final List<StockReservation> reservations;
      try {
        reservations = await _repo.reservations(materialIds: m.materialIds);
      } on AuthError catch (e) {
        if (mounted) setState(() => _error = context.l10n.failure(e.failure));
        return;
      }
      if (!mounted) return;
      final need = step == ProductionStep.reserve
          ? productionNeed(m)
          : {for (final r in reservations.where((r) => r.modelId == m.id)) r.materialId: r.meters};
      final confirmed = await showProductionDialog(
        context,
        step: step,
        model: m,
        meters: need,
        materials: materials,
        reservations: reservations,
      );
      if (confirmed == null) return;
      await _structural(() => step == ProductionStep.reserve
          ? _repo.startProduction(m.id, confirmed)
          : _repo.deliverModel(m.id, confirmed));
      ref.invalidate(materialsProvider);
      ref.invalidate(hasProProvider);
      return;
    }
    await _structural(() => _repo.setStatus(widget.modelId, status));
    // Un refus « offre Pro » vient peut-être d'un changement d'offre : relecture du verrou.
    ref.invalidate(hasProProvider);
  }

  Future<void> _setDeadline(ModelStatus stage, DateTime? date) async {
    await _structural(() => _repo.setDeadline(widget.modelId, stage, date));
    ref.invalidate(hasProProvider);
  }

  Future<void> _setSizeChart(String? chartId) async {
    await _structural(() => _repo.setModelSizeChart(widget.modelId, chartId));
    ref.invalidate(hasProProvider);
  }

  /// Quantité d'une taille : la quantité du coloris devient la somme de ses tailles.
  void _setSizeQuantity(Colorway c, String size, int quantity) {
    final current = _model!.colorways.firstWhere((x) => x.id == c.id);
    final sizes = {...current.sizeQuantities, size: quantity};
    _replaceColorway(c.id, (x) => x.copyWith(sizeQuantities: sizes, quantity: sizes.values.fold<int>(0, (a, b) => a + b)));
    _schedule('size-${c.id}-$size', () => _repo.setSizeQuantity(c.id, size, quantity));
  }

  void _setBaseSize(String size) {
    setState(() => _model = _model!.copyWith(baseSize: size));
    _schedule('base', () => _repo.updateGrading(widget.modelId, baseSize: size));
  }

  void _setGradePct(double pct) {
    setState(() => _model = _model!.copyWith(gradePct: pct));
    _schedule('grade', () => _repo.updateGrading(widget.modelId, gradePct: pct));
  }

  void _setSizeGrade(String size, double? pct) {
    final grades = {..._model!.sizeGrades};
    pct == null ? grades.remove(size) : grades[size] = pct;
    setState(() => _model = _model!.copyWith(sizeGrades: grades));
    _schedule('grade-$size', () => _repo.setSizeGrade(widget.modelId, size, pct));
  }

  void _setPrototypeCount(int count) {
    setState(() => _model = _model!.copyWith(prototypeCount: count));
    _schedule('proto-count', () => _repo.updateModel(widget.modelId, prototypeCount: count));
  }

  void _setProtoLoss(BomLine line, double pct) {
    final first = _model!.colorways.first;
    _replaceColorway(first.id, (c) => c.copyWith(lines: [for (final l in c.lines) l.id == line.id ? l.copyWith(protoLossPct: pct) : l]));
    _schedule('proto-loss-${line.id}', () => _repo.updateLine(line.id, protoLossPct: pct));
  }

  Future<void> _rename() async {
    final l10n = context.l10n;
    final name = await showNameDialog(context,
        title: l10n.rename, label: l10n.modelName, initial: _model!.name, confirm: l10n.save, maxLength: 120);
    if (name == null || name == _model!.name) return;
    await _structural(() => _repo.updateModel(widget.modelId, name: name));
  }

  Future<void> _delete() async {
    final l10n = context.l10n;
    final m = _model!;
    if (!await confirmDelete(context, title: l10n.deleteModelTitle(m.name), body: l10n.deleteModelBody)) return;
    try {
      await _repo.deleteModel(m.id);
      ref.invalidate(collectionModelsProvider(m.collectionId));
      ref.invalidate(collectionsProvider);
      if (mounted) context.go('/studio/collections/${m.collectionId}');
    } on AuthError catch (e) {
      if (mounted) setState(() => _error = l10n.failure(e.failure));
    }
  }

  // Affichage -------------------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final loaded = ref.watch(modelProvider(widget.modelId));
    _model ??= loaded.value;
    final m = _model;
    final canEdit = ref.watch(canEditStudioProvider);

    if (m == null) {
      return Scaffold(
        appBar: AppBar(leading: BackButton(onPressed: () => context.go('/studio'))),
        body: loaded.isLoading
            ? const Center(child: CircularProgressIndicator())
            : Center(child: Text(l10n.failure(AuthError.from(loaded.error ?? 'not_found').failure))),
      );
    }

    final colorway = m.colorways[_tab.clamp(0, m.colorways.length - 1)];
    final materials = {for (final x in ref.watch(materialsProvider).value ?? const <MaterialItem>[]) x.id: x};

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () async {
          await _flush();
          if (context.mounted) context.go('/studio/collections/${m.collectionId}');
        }),
        title: Text(m.name),
        actions: [
          ShareButton(scope: ShareScope.model, targetId: m.id),
          IconButton(
            tooltip: l10n.exportDossier,
            icon: const Icon(Icons.picture_as_pdf_outlined),
            onPressed: () async {
              await _flush();
              if (context.mounted) {
                openModelExport(context, ref, _model!,
                    shareUrl: ref.read(targetLinksProvider((ShareScope.model, m.id))).firstOrNull?.url);
              }
            },
          ),
          if (canEdit)
            PopupMenuButton<String>(
              onSelected: (v) => v == 'rename' ? _rename() : _delete(),
              itemBuilder: (_) => [
                PopupMenuItem(value: 'rename', child: Text(l10n.rename)),
                PopupMenuItem(value: 'delete', child: Text(l10n.delete, style: const TextStyle(color: FxColors.error))),
              ],
            ),
          const SizedBox(width: FxSpace.sm),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(FxSpace.md),
        children: [
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 960),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _header(m, canEdit),
                  if (_error != null) ...[const SizedBox(height: FxSpace.md), MessageBanner.error(_error!)],
                  const SizedBox(height: FxSpace.md),
                  ModelDeadlinesCard(model: m, onChanged: _setDeadline),
                  const SizedBox(height: FxSpace.md),
                  ModelSizesCard(
                    model: m,
                    onChartChanged: _setSizeChart,
                    onQuantity: _setSizeQuantity,
                    onBaseSize: _setBaseSize,
                    onGradePct: _setGradePct,
                    onSizeGrade: _setSizeGrade,
                  ),
                  const SizedBox(height: FxSpace.md),
                  AlertsPanel(alerts: watchModelAlerts(ref, m)),
                  const SizedBox(height: FxSpace.md),
                  _colorwayBar(m, canEdit),
                  const SizedBox(height: FxSpace.md),
                  _colorwayPanel(m, colorway, materials, canEdit),
                  if (m.materialIds.isNotEmpty) ...[
                    const SizedBox(height: FxSpace.md),
                    PrototypingCard(model: m, materials: materials, onCount: _setPrototypeCount, onLoss: _setProtoLoss),
                    const SizedBox(height: FxSpace.lg),
                    _requirements(m, materials),
                  ],
                  const SizedBox(height: FxSpace.xxl),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _header(StudioModel m, bool canEdit) {
    final l10n = context.l10n;
    final lang = langOf(context);
    final text = Theme.of(context).textTheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(FxSpace.md),
        child: Wrap(
          spacing: FxSpace.lg,
          runSpacing: FxSpace.md,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            ModelStatusControl(status: m.status, onChanged: _setStatus),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(productTypeIcon(m.productType), color: FxColors.petrol),
                const SizedBox(width: FxSpace.sm),
                Text(
                  [l10n.productTypeLabel(m.productType), if ((m.reference ?? '').isNotEmpty) m.reference!].join(' · '),
                  style: text.titleSmall,
                ),
              ],
            ),
            if (canEdit)
              SizedBox(
                width: 200,
                child: TextField(
                  key: const ValueKey('waste'),
                  controller: _controller('waste', formatNumber(m.wastePct, lang, decimals: 2)),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))],
                  decoration: InputDecoration(labelText: l10n.wasteLabel, isDense: true),
                  onChanged: _setWaste,
                ),
              )
            else
              Text('${l10n.wasteLabel} : ${formatNumber(m.wastePct, lang, decimals: 2)}', style: text.bodyMedium),
          ],
        ),
      ),
    );
  }

  /// Onglets de coloris dès le deuxième ; avant, un simple bouton pour décliner.
  Widget _colorwayBar(StudioModel m, bool canEdit) {
    final l10n = context.l10n;
    if (!m.hasVariants) {
      return canEdit
          ? Align(
              alignment: Alignment.centerLeft,
              child: OutlinedButton.icon(
                onPressed: _addColorway,
                icon: const Icon(Icons.palette_outlined, size: 18),
                label: Text(l10n.declineColorways),
              ),
            )
          : const SizedBox.shrink();
    }
    return Wrap(
      spacing: FxSpace.sm,
      runSpacing: FxSpace.xs,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        for (final (i, c) in m.colorways.indexed)
          ChoiceChip(
            label: Text(l10n.colorwayName(c, i)),
            selected: i == _tab,
            onSelected: (_) => setState(() => _tab = i),
          ),
        if (canEdit)
          TextButton.icon(
            onPressed: _addColorway,
            icon: const Icon(Icons.add, size: 18),
            label: Text(l10n.addColorway),
          ),
      ],
    );
  }

  Widget _colorwayPanel(StudioModel m, Colorway c, Map<String, MaterialItem> materials, bool canEdit) {
    final l10n = context.l10n;
    final text = Theme.of(context).textTheme;
    return Card(
      key: ValueKey('colorway-${c.id}'),
      child: Padding(
        padding: const EdgeInsets.all(FxSpace.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                // Avec une grille, la quantité est la somme des tailles (tableau Tailles).
                if (canEdit && m.sizeChartId == null)
                  SizedBox(
                    width: 220,
                    child: TextField(
                      key: ValueKey('qty-${c.id}'),
                      controller: _controller('qty-${c.id}', c.quantity == 0 ? '' : '${c.quantity}'),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: InputDecoration(labelText: l10n.quantityLabel, isDense: true),
                      onChanged: (v) => _setQuantity(c, v),
                    ),
                  )
                else
                  Text('${l10n.quantityLabel} : ${c.quantity}', style: text.bodyMedium),
                const Spacer(),
                if (canEdit && m.hasVariants)
                  IconButton(
                    tooltip: l10n.deleteColorway,
                    onPressed: () => _deleteColorway(c),
                    icon: const Icon(Icons.delete_outline),
                  ),
              ],
            ),
            const SizedBox(height: FxSpace.md),
            if (c.lines.isEmpty)
              _emptyLines(c, canEdit)
            else ...[
              for (final l in c.lines) _lineRow(m, c, l, materials[l.materialId], canEdit),
              if (canEdit)
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: () => _addLine(c),
                    icon: const Icon(Icons.add, size: 18),
                    label: Text(l10n.addMaterial),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _emptyLines(Colorway c, bool canEdit) {
    final l10n = context.l10n;
    final text = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(FxSpace.lg),
      decoration: BoxDecoration(color: FxColors.mintPale, borderRadius: BorderRadius.circular(FxRadius.md)),
      child: Column(
        children: [
          Text(l10n.modelEmptyTitle, style: text.titleMedium, textAlign: TextAlign.center),
          const SizedBox(height: FxSpace.xs),
          Text(canEdit ? l10n.modelEmptyEditor : l10n.modelEmptyViewer,
              textAlign: TextAlign.center, style: text.bodyMedium?.copyWith(color: FxColors.inkSoft)),
          if (canEdit) ...[
            const SizedBox(height: FxSpace.md),
            FilledButton.icon(
              onPressed: () => _addLine(c),
              icon: const Icon(Icons.add),
              label: Text(l10n.addMaterial),
            ),
          ],
        ],
      ),
    );
  }

  Widget _lineRow(StudioModel m, Colorway c, BomLine l, MaterialItem? material, bool canEdit) {
    final l10n = context.l10n;
    final lang = langOf(context);
    final text = Theme.of(context).textTheme;
    final need = colorwayLineRequirement(m, c, l);
    return Padding(
      key: ValueKey('line-${l.id}'),
      padding: const EdgeInsets.only(bottom: FxSpace.sm),
      child: Row(
        children: [
          SizedBox(
            width: 40,
            height: 40,
            child: material == null
                ? const Icon(Icons.help_outline, color: FxColors.inkSoft)
                : MaterialVisual(material: material, iconSize: 16),
          ),
          const SizedBox(width: FxSpace.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(material?.name ?? l10n.materialMissing, style: text.titleSmall, maxLines: 1, overflow: TextOverflow.ellipsis),
                Text(
                  [l10n.roleText(l.role), l10n.requirementLine(formatNumber(need, lang, decimals: 2))].join(' · '),
                  style: text.bodySmall?.copyWith(color: FxColors.inkSoft),
                ),
              ],
            ),
          ),
          const SizedBox(width: FxSpace.sm),
          if (canEdit) ...[
            SizedBox(
              width: 130,
              child: TextField(
                key: ValueKey('cons-${l.id}'),
                controller: _controller('line-${l.id}', l.consumption == 0 ? '' : formatNumber(l.consumption, lang, decimals: 3)),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))],
                decoration: InputDecoration(labelText: l10n.consumptionLabel, isDense: true),
                onChanged: (v) => _setConsumption(c, l, v),
              ),
            ),
            IconButton(
              tooltip: l10n.removeLine,
              onPressed: () => _structural(() => _repo.deleteLine(l.id)),
              icon: const Icon(Icons.close),
            ),
          ] else
            Text('${formatNumber(l.consumption, lang, decimals: 3)} m', style: text.bodyMedium),
        ],
      ),
    );
  }

  Widget _requirements(StudioModel m, Map<String, MaterialItem> materials) {
    final l10n = context.l10n;
    final lang = langOf(context);
    final text = Theme.of(context).textTheme;
    final totals = requirementsByMaterial(m);
    // Offre Pro : le besoin de prototypage s'affiche à part, puis le total.
    final proto = (ref.watch(hasProProvider).value ?? false) ? prototypeRequirements(m) : const <String, double>{};
    String meters(double v) => l10n.stockMeters(formatNumber(v, lang, decimals: 2));
    Widget? split(String id) => proto.isEmpty
        ? null
        : Text(l10n.requirementSplit(meters(totals[id] ?? 0), meters(proto[id] ?? 0)),
            style: text.bodySmall?.copyWith(color: FxColors.inkSoft));
    double total(String id) => (totals[id] ?? 0) + (proto[id] ?? 0);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(FxSpace.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l10n.requirementTitle, style: text.titleMedium),
            Text(
                m.graded
                    ? l10n.requirementFormulaGraded(formatNumber(m.wastePct, lang, decimals: 2))
                    : l10n.requirementFormula(formatNumber(m.wastePct, lang, decimals: 2)),
                style: text.bodySmall?.copyWith(color: FxColors.inkSoft)),
            const SizedBox(height: FxSpace.sm),
            for (final e in totals.entries)
              if (m.graded)
                ExpansionTile(
                  key: ValueKey('need-${e.key}'),
                  tilePadding: EdgeInsets.zero,
                  title: Text(materials[e.key]?.name ?? l10n.materialMissing, style: text.bodyMedium),
                  subtitle: split(e.key) ?? Text(l10n.requirementBySize, style: text.bodySmall?.copyWith(color: FxColors.inkSoft)),
                  trailing: TechText(meters(total(e.key)), size: 14),
                  children: [
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: RequirementDetailTable(model: m, materialId: e.key),
                    ),
                  ],
                )
              else
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(materials[e.key]?.name ?? l10n.materialMissing, style: text.bodyMedium),
                            ?split(e.key),
                          ],
                        ),
                      ),
                      TechText(meters(total(e.key)), size: 14),
                    ],
                  ),
                ),
          ],
        ),
      ),
    );
  }
}

/// Nommer le nouveau coloris (et le coloris actuel s'il n'a pas encore de nom).
class _ColorwayDialog extends StatefulWidget {
  const _ColorwayDialog({required this.askCurrent, required this.copyFromName});

  final bool askCurrent;
  final String copyFromName;

  @override
  State<_ColorwayDialog> createState() => _ColorwayDialogState();
}

class _ColorwayDialogState extends State<_ColorwayDialog> {
  final _formKey = GlobalKey<FormState>();
  final _current = TextEditingController();
  final _new = TextEditingController();

  @override
  void dispose() {
    _current.dispose();
    _new.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    String? required(String? v) => (v ?? '').trim().isEmpty ? l10n.errorRequired : null;
    return AlertDialog(
      title: Text(l10n.addColorway),
      content: SizedBox(
        width: 420,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (widget.askCurrent)
                TextFormField(
                  controller: _current,
                  autofocus: true,
                  maxLength: 60,
                  decoration: InputDecoration(labelText: l10n.colorwayCurrent, hintText: l10n.colorwayNameHint),
                  validator: required,
                ),
              TextFormField(
                controller: _new,
                autofocus: !widget.askCurrent,
                maxLength: 60,
                decoration: InputDecoration(labelText: l10n.colorwayNew, hintText: l10n.colorwayNameHint),
                validator: required,
              ),
              Text(
                l10n.colorwayCopyHelp(widget.askCurrent && _current.text.trim().isNotEmpty ? _current.text.trim() : widget.copyFromName),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: FxColors.inkSoft),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(l10n.cancel)),
        FilledButton(
          onPressed: () {
            if (_formKey.currentState?.validate() ?? false) {
              Navigator.of(context).pop((widget.askCurrent ? _current.text.trim() : null, _new.text.trim()));
            }
          },
          child: Text(l10n.add),
        ),
      ],
    );
  }
}
