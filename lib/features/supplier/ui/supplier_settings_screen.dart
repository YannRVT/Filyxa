import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app/theme.dart';
import '../../../l10n/l10n.dart';
import '../../../shared/widgets/auth_widgets.dart';
import '../../auth/data/auth_repository.dart';
import '../../library/domain/material.dart';
import '../../session/data/user_space_repository.dart';
import '../data/catalog_repository.dart';
import '../domain/availability.dart';
import '../domain/supplier_reference.dart';
import 'catalog_screen.dart' show canEditCatalogProvider;
import 'supplier_texts.dart';

/// Réglage général : ce que les ateliers voient du stock, et seuil de stock faible.
class SupplierSettingsScreen extends ConsumerWidget {
  const SupplierSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final settings = ref.watch(supplierSettingsProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.availabilitySettingsTitle),
        leading: BackButton(onPressed: () => context.go('/catalog')),
      ),
      body: settings.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => Center(child: MessageBanner.error(l10n.loadingError)),
        data: (s) => _SettingsForm(initial: s),
      ),
    );
  }
}

class _SettingsForm extends ConsumerStatefulWidget {
  const _SettingsForm({required this.initial});

  final SupplierSettings initial;

  @override
  ConsumerState<_SettingsForm> createState() => _SettingsFormState();
}

class _SettingsFormState extends ConsumerState<_SettingsForm> {
  late AvailabilityMode _mode = widget.initial.mode;
  late final _threshold = TextEditingController(text: formatNumber(widget.initial.lowStockThresholdM, 'fr'));
  final _formKey = GlobalKey<FormState>();
  bool _busy = false;

  @override
  void dispose() {
    _threshold.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final orgId = ref.read(userSpaceProvider).value?.membership?.organization.id;
    if (orgId == null) return;
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _busy = true);
    try {
      await ref.read(catalogRepositoryProvider).saveSettings(orgId, mode: _mode, thresholdM: parseNumber(_threshold.text));
      ref.invalidate(supplierSettingsProvider);
      messenger.showSnackBar(SnackBar(content: Text(l10n.settingsSaved)));
    } on AuthError catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.failure(e.failure))));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final canEdit = ref.watch(canEditCatalogProvider);
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(FxSpace.md),
        children: [
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(l10n.availabilitySettingsIntro, style: Theme.of(context).textTheme.bodyMedium),
                  const SizedBox(height: FxSpace.md),
                  Card(
                    child: RadioGroup<AvailabilityMode>(
                      groupValue: _mode,
                      onChanged: (m) {
                        if (canEdit && m != null) setState(() => _mode = m);
                      },
                      child: Column(
                        children: [
                          for (final m in AvailabilityMode.values)
                            RadioListTile<AvailabilityMode>(
                              value: m,
                              enabled: canEdit,
                              title: Text(l10n.mode(m)),
                              subtitle: Text(l10n.modeHelp(m)),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: FxSpace.md),
                  TextFormField(
                    controller: _threshold,
                    enabled: canEdit,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))],
                    decoration: InputDecoration(labelText: l10n.thresholdLabel, helperText: l10n.thresholdHelp, helperMaxLines: 2),
                    validator: (v) {
                      final n = parseNumber(v);
                      return n != null && n >= 0 && n <= 100000 ? null : l10n.errorNumberRange(0, 100000);
                    },
                  ),
                  if (canEdit) ...[
                    const SizedBox(height: FxSpace.lg),
                    BusyButton(label: l10n.save, busy: _busy, onPressed: _save),
                  ] else ...[
                    const SizedBox(height: FxSpace.md),
                    MessageBanner.info(l10n.errorEditorsOnly),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
