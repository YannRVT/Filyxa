import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app/theme.dart';
import '../../../l10n/l10n.dart';
import '../../../shared/widgets/auth_widgets.dart';
import '../../auth/data/auth_repository.dart';
import '../data/materials_repository.dart';
import '../domain/catalog.dart';
import '../domain/material.dart';
import '../../supplier/ui/supplier_texts.dart';
import 'material_widgets.dart';
import 'reference_widgets.dart';

class MaterialDetailScreen extends ConsumerWidget {
  const MaterialDetailScreen({super.key, required this.materialId});

  final String materialId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final material = ref.watch(materialProvider(materialId));
    final canEdit = ref.watch(canEditMaterialsProvider);
    final item = material.value;

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => context.go('/library')),
        title: Text(item?.name ?? l10n.navLibrary, overflow: TextOverflow.ellipsis),
        actions: [
          if (canEdit && item != null) ...[
            IconButton(
              tooltip: l10n.edit,
              icon: const Icon(Icons.edit_outlined),
              onPressed: () => context.go('/library/${item.id}/edit'),
            ),
            PopupMenuButton<String>(
              onSelected: (_) => _delete(context, ref, item),
              itemBuilder: (_) => [
                PopupMenuItem(
                  value: 'delete',
                  child: Text(l10n.delete, style: const TextStyle(color: FxColors.error)),
                ),
              ],
            ),
          ],
          const SizedBox(width: FxSpace.sm),
        ],
      ),
      body: material.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => Center(child: Padding(
          padding: const EdgeInsets.all(FxSpace.lg),
          child: MessageBanner.error(l10n.loadingError),
        )),
        data: (m) => m == null
            ? Center(child: Padding(
                padding: const EdgeInsets.all(FxSpace.lg),
                child: MessageBanner.info(l10n.materialNotFound),
              ))
            : _DetailBody(material: m, canEdit: canEdit),
      ),
    );
  }

  Future<void> _delete(BuildContext context, WidgetRef ref, MaterialItem m) async {
    final l10n = context.l10n;
    final ok = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.deleteMaterialTitle(m.name)),
        content: Text(l10n.deleteMaterialBody),
        actions: [
          TextButton(onPressed: () => Navigator.of(dialogContext).pop(false), child: Text(l10n.cancel)),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: FxColors.error),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    try {
      await ref.read(materialsRepositoryProvider).delete(m);
      ref.invalidate(materialsProvider);
      if (context.mounted) context.go('/library');
      messenger.showSnackBar(SnackBar(content: Text(l10n.materialDeleted)));
    } on AuthError catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.failure(e.failure))));
    }
  }
}

class _DetailBody extends StatelessWidget {
  const _DetailBody({required this.material, required this.canEdit});

  final MaterialItem material;
  final bool canEdit;

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 900;
    final visual = AspectRatio(aspectRatio: 4 / 3, child: MaterialVisual(material: material, radius: FxRadius.lg, iconSize: 48));
    final stock = _StockCard(material: material, canEdit: canEdit);
    final info = _InfoColumn(material: material, canEdit: canEdit);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(FxSpace.md),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: wide
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(width: 380, child: Column(children: [visual, const SizedBox(height: FxSpace.md), stock])),
                    const SizedBox(width: FxSpace.lg),
                    Expanded(child: info),
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [visual, const SizedBox(height: FxSpace.md), info, const SizedBox(height: FxSpace.md), stock],
                ),
        ),
      ),
    );
  }
}

class _InfoColumn extends ConsumerWidget {
  const _InfoColumn({required this.material, required this.canEdit});

  final MaterialItem material;
  final bool canEdit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final linked = ref.watch(linkedReferencesProvider);
    final refs = linked.value;
    final reference = material.isLinked && refs != null ? refs[material.supplierReferenceId] : null;
    // Liée mais absente du catalogue publié (une fois chargé) = retirée par le fournisseur.
    final retired = material.isLinked && linked.hasValue && reference == null;
    final lang = langOf(context);
    final text = Theme.of(context).textTheme;
    final specs = material.specs;
    final supplier = supplierLine(material);

    Widget section(String title, Widget child) => Padding(
          padding: const EdgeInsets.only(top: FxSpace.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title.toUpperCase(), style: text.labelSmall?.copyWith(color: FxColors.inkSoft, letterSpacing: 0.6)),
              const SizedBox(height: FxSpace.sm),
              child,
            ],
          ),
        );

    final specRows = <(String, String)>[
      if (specs.weightGsm != null) (l10n.detailWeight, '${specs.weightGsm} g/m²'),
      if (specs.widthCm != null) (l10n.detailWidth, '${specs.widthCm} cm'),
      if (specs.weave != null) (l10n.fieldWeave, weaveLabel(specs.weave!, lang)),
      if (material.colorName != null) (l10n.fieldColorName, material.colorName!),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(material.name, style: text.headlineSmall),
        if (supplier != null) ...[
          const SizedBox(height: FxSpace.xs),
          TechText(supplier, size: 14, color: FxColors.inkSoft),
        ],
        if (material.isLinked) ...[
          const SizedBox(height: FxSpace.sm),
          Wrap(
            spacing: FxSpace.sm,
            runSpacing: FxSpace.xs,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.link, size: 16, color: FxColors.emeraldInk),
                  const SizedBox(width: 4),
                  Text(l10n.supplierData, style: text.labelMedium?.copyWith(color: FxColors.emeraldInk)),
                ],
              ),
              if (reference != null)
                AvailabilityPill(
                  status: reference.status,
                  leadTimeWeeks: reference.leadTimeWeeks,
                  stockM: reference.stockM == null
                      ? null
                      : l10n.stockMeters(formatNumber(reference.stockM!, lang, decimals: 2)),
                ),
            ],
          ),
          if (retired) ...[
            const SizedBox(height: FxSpace.sm),
            MessageBanner.warning(l10n.referenceRetiredBanner),
          ],
        ] else if (canEdit) ...[
          const SizedBox(height: FxSpace.sm),
          OutlinedButton.icon(
            onPressed: () => _link(context, ref),
            icon: const Icon(Icons.link, size: 18),
            label: Text(l10n.linkToSupplier),
          ),
        ],
        if (specs.composition.isNotEmpty)
          section(
            l10n.sectionComposition,
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TechText(compositionCodes(specs.composition, lang), size: 18),
                const SizedBox(height: 2),
                Text(compositionLabel(specs.composition, lang), style: text.bodyMedium?.copyWith(color: FxColors.inkSoft)),
              ],
            ),
          ),
        if (specRows.isNotEmpty)
          section(
            l10n.sectionTechnical,
            Wrap(
              spacing: FxSpace.xl,
              runSpacing: FxSpace.md,
              children: [
                for (final (label, value) in specRows)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(label, style: text.bodySmall?.copyWith(color: FxColors.inkSoft)),
                      TechText(value, size: 15),
                    ],
                  ),
              ],
            ),
          ),
        if (specs.care.isNotEmpty)
          section(
            l10n.sectionCare,
            LayoutBuilder(
              builder: (context, constraints) => Wrap(
                spacing: FxSpace.md,
                runSpacing: FxSpace.sm,
                children: [
                  for (final code in sortCare(specs.care))
                    ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: constraints.maxWidth),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CareIcon(code, size: 30),
                          const SizedBox(width: 6),
                          Flexible(child: Text(careCode(code)?.label(lang) ?? code, style: text.bodySmall)),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        if (specs.certifications.isNotEmpty || specs.uses.isNotEmpty)
          section(
            l10n.sectionUses,
            Wrap(
              spacing: FxSpace.sm,
              runSpacing: FxSpace.sm,
              children: [
                for (final c in specs.certifications) TagChip(c),
                for (final u in specs.uses) TagChip(useLabel(u, lang)),
              ],
            ),
          ),
        if (material.pricePerM != null || material.tags.isNotEmpty)
          section(
            l10n.privateLayer,
            Wrap(
              spacing: FxSpace.sm,
              runSpacing: FxSpace.sm,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                if (material.pricePerM != null)
                  TechText(l10n.priceValue(formatNumber(material.pricePerM!, lang, decimals: 2)), size: 15),
                for (final t in material.tags) TagChip(t),
              ],
            ),
          ),
        if (material.notes != null && material.notes!.trim().isNotEmpty)
          section(l10n.sectionNotes, Text(material.notes!, style: text.bodyMedium)),
      ],
    );
  }

  /// Lien après coup : recherche dans les catalogues publiés, puis confirmation.
  Future<void> _link(BuildContext context, WidgetRef ref) async {
    final l10n = context.l10n;
    final reference = await showLinkDialog(context);
    if (reference == null || !context.mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    final m = material;
    try {
      await ref.read(materialsRepositoryProvider).save(MaterialDraft(
            id: m.id,
            orgId: m.orgId,
            name: m.name,
            photoPath: m.photoPath,
            atelierStockM: m.atelierStockM,
            notes: m.notes,
            pricePerM: m.pricePerM,
            tags: m.tags,
            supplierReferenceId: reference.id,
          ));
      ref.invalidate(materialProvider(m.id));
      ref.invalidate(materialsProvider);
      ref.invalidate(linkedReferencesProvider);
      messenger.showSnackBar(SnackBar(content: Text(l10n.linkedDone)));
    } on AuthError catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.failure(e.failure))));
    }
  }
}

class _StockCard extends ConsumerWidget {
  const _StockCard({required this.material, required this.canEdit});

  final MaterialItem material;
  final bool canEdit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final lang = langOf(context);
    final text = Theme.of(context).textTheme;
    final stock = material.atelierStockM;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(FxSpace.md),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(top: 2),
              child: Icon(Icons.inventory_2_outlined, color: FxColors.emeraldInk),
            ),
            const SizedBox(width: FxSpace.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.colStock, style: text.bodySmall?.copyWith(color: FxColors.inkSoft)),
                  Text(
                    stock == null ? l10n.noneOption : l10n.stockMeters(formatNumber(stock, lang, decimals: 2)),
                    style: text.titleMedium?.copyWith(fontFeatures: const [FontFeature.tabularFigures()]),
                  ),
                  if (canEdit)
                    TextButton(
                      style: TextButton.styleFrom(padding: EdgeInsets.zero, alignment: Alignment.centerLeft),
                      onPressed: () => _edit(context, ref),
                      child: Text(l10n.editStock),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _edit(BuildContext context, WidgetRef ref) async {
    final l10n = context.l10n;
    final lang = langOf(context);
    final controller = TextEditingController(
      text: material.atelierStockM == null ? '' : formatNumber(material.atelierStockM!, lang, decimals: 2),
    );
    final formKey = GlobalKey<FormState>();
    final result = await showDialog<(bool, double?)>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.editStock),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: controller,
            autofocus: true,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))],
            decoration: InputDecoration(labelText: l10n.fieldStock),
            validator: (v) => validateStock(v, l10n),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(dialogContext).pop(), child: Text(l10n.cancel)),
          FilledButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.of(dialogContext).pop((true, parseNumber(controller.text)));
              }
            },
            child: Text(l10n.save),
          ),
        ],
      ),
    );
    controller.dispose();
    if (result == null || !context.mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    try {
      await ref.read(materialsRepositoryProvider).updateStock(material.id, result.$2);
      ref.invalidate(materialProvider(material.id));
      ref.invalidate(materialsProvider);
      messenger.showSnackBar(SnackBar(content: Text(l10n.stockUpdated)));
    } on AuthError catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.failure(e.failure))));
    }
  }
}

/// Stock atelier : vide (non renseigné) ou un nombre entre 0 et 100 000 m.
String? validateStock(String? value, AppLocalizations l10n) {
  if ((value ?? '').trim().isEmpty) return null;
  final n = parseNumber(value);
  if (n == null || n < 0 || n > 100000) return l10n.errorNumberRange(0, 100000);
  return null;
}
