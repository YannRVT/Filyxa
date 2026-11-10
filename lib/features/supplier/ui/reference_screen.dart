import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app/theme.dart';
import '../../../l10n/l10n.dart';
import '../../../shared/widgets/auth_widgets.dart';
import '../../auth/data/auth_repository.dart';
import '../../library/domain/catalog.dart';
import '../../library/domain/material.dart';
import '../../library/ui/material_widgets.dart';
import '../data/catalog_repository.dart';
import '../domain/availability.dart';
import '../domain/supplier_reference.dart';
import 'catalog_screen.dart' show canEditCatalogProvider;
import 'supplier_texts.dart';

/// Fiche d'une référence côté fournisseur : données, stock, ce que voient les ateliers,
/// réglages de disponibilité propres et retrait du catalogue.
class ReferenceScreen extends ConsumerWidget {
  const ReferenceScreen({super.key, required this.referenceId});

  final String referenceId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final reference = ref.watch(supplierReferenceProvider(referenceId));
    final settings = ref.watch(supplierSettingsProvider).value ?? const SupplierSettings();
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => context.go('/catalog')),
        title: Text(reference.value?.code ?? l10n.navCatalog),
      ),
      body: reference.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => Center(child: MessageBanner.error(l10n.loadingError)),
        data: (r) => r == null
            ? Center(child: MessageBanner.info(l10n.materialNotFound))
            : _ReferenceBody(reference: r, settings: settings),
      ),
    );
  }
}

class _ReferenceBody extends ConsumerStatefulWidget {
  const _ReferenceBody({required this.reference, required this.settings});

  final SupplierReference reference;
  final SupplierSettings settings;

  @override
  ConsumerState<_ReferenceBody> createState() => _ReferenceBodyState();
}

class _ReferenceBodyState extends ConsumerState<_ReferenceBody> {
  late AvailabilityMode? _mode = widget.reference.mode;
  late final _threshold = TextEditingController(
    text: widget.reference.lowStockThresholdM == null ? '' : formatNumber(widget.reference.lowStockThresholdM!, 'fr'),
  );
  late final _leadTime = TextEditingController(text: widget.reference.leadTimeWeeks?.toString() ?? '');
  final _formKey = GlobalKey<FormState>();
  bool _busy = false;

  @override
  void dispose() {
    _threshold.dispose();
    _leadTime.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _busy = true);
    try {
      await ref.read(catalogRepositoryProvider).updateAvailability(
            widget.reference.id,
            mode: _mode,
            thresholdM: parseNumber(_threshold.text),
            leadTimeWeeks: parseNumber(_leadTime.text)?.round(),
          );
      ref.invalidate(supplierReferenceProvider(widget.reference.id));
      ref.invalidate(supplierReferencesProvider);
      messenger.showSnackBar(SnackBar(content: Text(l10n.settingsSaved)));
    } on AuthError catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.failure(e.failure))));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _toggleRetired() async {
    final l10n = context.l10n;
    final r = widget.reference;
    if (!r.isRetired) {
      final ok = await showDialog<bool>(
        context: context,
        builder: (d) => AlertDialog(
          title: Text(l10n.retireConfirmTitle(r.code)),
          content: Text(l10n.retireConfirmBody),
          actions: [
            TextButton(onPressed: () => Navigator.of(d).pop(false), child: Text(l10n.cancel)),
            FilledButton(onPressed: () => Navigator.of(d).pop(true), child: Text(l10n.referenceRetire)),
          ],
        ),
      );
      if (ok != true) return;
    }
    if (!mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    try {
      await ref.read(catalogRepositoryProvider).setRetired(r.id, !r.isRetired);
      ref.invalidate(supplierReferenceProvider(r.id));
      ref.invalidate(supplierReferencesProvider);
      messenger.showSnackBar(SnackBar(content: Text(r.isRetired ? l10n.referenceRestored : l10n.referenceRetired)));
    } on AuthError catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.failure(e.failure))));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final lang = langOf(context);
    final text = Theme.of(context).textTheme;
    final r = widget.reference;
    final s = widget.settings;
    final canEdit = ref.watch(canEditCatalogProvider);

    final effectiveMode = _mode ?? s.mode;
    final status = availabilityStatusOf(
      stockM: r.stockM,
      thresholdM: parseNumber(_threshold.text) ?? s.lowStockThresholdM,
      leadTimeWeeks: parseNumber(_leadTime.text)?.round(),
    );
    final stockText = r.stockM == null ? null : l10n.stockMeters(formatNumber(r.stockM!, lang, decimals: 2));

    return ListView(
      padding: const EdgeInsets.all(FxSpace.md),
      children: [
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(r.name, style: text.headlineSmall),
                TechText(r.code, size: 14, color: FxColors.inkSoft),
                if (r.isRetired) ...[
                  const SizedBox(height: FxSpace.sm),
                  MessageBanner.info(l10n.referenceRetired),
                ],
                const SizedBox(height: FxSpace.md),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(FxSpace.md),
                    child: Wrap(
                      spacing: FxSpace.xl,
                      runSpacing: FxSpace.md,
                      children: [
                        for (final (label, value) in <(String, String)>[
                          if (r.specs.composition.isNotEmpty) (l10n.colComposition, compositionCodes(r.specs.composition, lang)),
                          if (r.specs.weightGsm != null) (l10n.detailWeight, '${r.specs.weightGsm} g/m²'),
                          if (r.specs.widthCm != null) (l10n.detailWidth, '${r.specs.widthCm} cm'),
                          if (r.specs.weave != null) (l10n.fieldWeave, weaveLabel(r.specs.weave!, lang)),
                          (l10n.stockLabel, stockText ?? '—'),
                        ])
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
                ),
                const SizedBox(height: FxSpace.md),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(FxSpace.md),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(l10n.referenceAvailabilityTitle, style: text.titleMedium),
                          const SizedBox(height: FxSpace.sm),
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  l10n.whatAteliersSee(''),
                                  style: text.bodySmall?.copyWith(color: FxColors.inkSoft),
                                ),
                              ),
                              const SizedBox(width: FxSpace.sm),
                              Flexible(
                                child: AvailabilityPill(
                                  status: effectiveMode == AvailabilityMode.hidden ? null : status,
                                  leadTimeWeeks: parseNumber(_leadTime.text)?.round(),
                                  stockM: effectiveMode == AvailabilityMode.exact ? stockText : null,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: FxSpace.md),
                          DropdownButtonFormField<AvailabilityMode?>(
                            initialValue: _mode,
                            isExpanded: true,
                            decoration: InputDecoration(labelText: l10n.availabilitySettingsTitle),
                            items: [
                              DropdownMenuItem(value: null, child: Text(l10n.modeDefault(l10n.mode(s.mode)))),
                              for (final m in AvailabilityMode.values)
                                DropdownMenuItem(value: m, child: Text(l10n.mode(m))),
                            ],
                            onChanged: canEdit ? (v) => setState(() => _mode = v) : null,
                          ),
                          const SizedBox(height: FxSpace.md),
                          TextFormField(
                            controller: _threshold,
                            enabled: canEdit,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))],
                            decoration: InputDecoration(
                              labelText: l10n.thresholdLabel,
                              helperText: l10n.modeDefault('${formatNumber(s.lowStockThresholdM, lang)} m'),
                            ),
                            onChanged: (_) => setState(() {}),
                          ),
                          const SizedBox(height: FxSpace.md),
                          TextFormField(
                            controller: _leadTime,
                            enabled: canEdit,
                            keyboardType: TextInputType.number,
                            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                            decoration: InputDecoration(labelText: l10n.leadTimeLabel, helperText: l10n.leadTimeHelp),
                            validator: (v) {
                              final n = parseNumber(v);
                              return (v ?? '').isEmpty || (n != null && n >= 0 && n <= 104)
                                  ? null
                                  : l10n.errorNumberRange(0, 104);
                            },
                            onChanged: (_) => setState(() {}),
                          ),
                          if (canEdit) ...[
                            const SizedBox(height: FxSpace.md),
                            BusyButton(label: l10n.save, busy: _busy, onPressed: _save),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
                if (canEdit) ...[
                  const SizedBox(height: FxSpace.md),
                  OutlinedButton.icon(
                    onPressed: _toggleRetired,
                    icon: Icon(r.isRetired ? Icons.unarchive_outlined : Icons.archive_outlined),
                    label: Text(r.isRetired ? l10n.referenceRestore : l10n.referenceRetire),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}
