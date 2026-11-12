import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app/theme.dart';
import '../../../l10n/l10n.dart';
import '../../library/data/materials_repository.dart';
import '../../library/domain/library_filter.dart' show foldForSearch;
import '../../library/domain/material.dart';
import '../../library/ui/material_widgets.dart';
import '../data/studio_repository.dart';
import '../domain/studio.dart';

extension StudioTexts on AppLocalizations {
  String modelStatusText(ModelStatus s) => switch (s) {
        ModelStatus.idea => modelStatusIdea,
        ModelStatus.prototype => modelStatusPrototype,
        ModelStatus.validated => modelStatusValidated,
        ModelStatus.inProduction => modelStatusInProduction,
        ModelStatus.delivered => modelStatusDelivered,
        ModelStatus.abandoned => modelStatusAbandoned,
      };

  String productTypeLabel(ProductType t) => switch (t) {
        ProductType.garment => productGarment,
        ProductType.footwear => productFootwear,
        ProductType.leatherGoods => productLeatherGoods,
        ProductType.accessory => productAccessory,
      };

  /// Rôle intégré traduit, ou rôle libre tel que saisi par l'atelier.
  String roleText(String role) => switch (role) {
        'main' => role_main,
        'lining' => role_lining,
        'interfacing' => role_interfacing,
        'contrast' => role_contrast,
        'pocketing' => role_pocketing,
        'rib' => role_rib,
        'upper' => role_upper,
        'sock_lining' => role_sock_lining,
        'insole' => role_insole,
        'outsole' => role_outsole,
        'reinforcement' => role_reinforcement,
        'exterior' => role_exterior,
        'gusset' => role_gusset,
        'strap' => role_strap,
        'trim' => role_trim,
        _ => role,
      };

  String colorwayName(Colorway c, int index) => (c.name ?? '').trim().isEmpty ? colorwayDefault(index + 1) : c.name!;
}

IconData productTypeIcon(ProductType t) => switch (t) {
      ProductType.garment => Icons.checkroom_outlined,
      ProductType.footwear => Icons.hiking_outlined,
      ProductType.leatherGoods => Icons.shopping_bag_outlined,
      ProductType.accessory => Icons.watch_outlined,
    };

/// État vide qui guide vers l'action suivante (US-43).
class StudioEmptyState extends StatelessWidget {
  const StudioEmptyState({super.key, required this.icon, required this.title, required this.body, this.action});

  final IconData icon;
  final String title;
  final String body;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(FxSpace.lg),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 460),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  padding: const EdgeInsets.all(FxSpace.md),
                  decoration: BoxDecoration(color: FxColors.mintPale, borderRadius: BorderRadius.circular(FxRadius.lg)),
                  child: Icon(icon, size: 36, color: FxColors.petrol),
                ),
              ),
              const SizedBox(height: FxSpace.md),
              Text(title, style: text.titleLarge, textAlign: TextAlign.center),
              const SizedBox(height: FxSpace.sm),
              Text(body, textAlign: TextAlign.center, style: text.bodyMedium?.copyWith(color: FxColors.inkSoft)),
              if (action != null) ...[const SizedBox(height: FxSpace.lg), action!],
            ],
          ),
        ),
      ),
    );
  }
}

/// Saisie d'un nom (collection, renommage) ; renvoie le nom ou null.
Future<String?> showNameDialog(
  BuildContext context, {
  required String title,
  required String label,
  required String confirm,
  String? hint,
  String? initial,
  int maxLength = 80,
}) =>
    showDialog<String>(
      context: context,
      builder: (_) => _NameDialog(title: title, label: label, confirm: confirm, hint: hint, initial: initial, maxLength: maxLength),
    );

class _NameDialog extends StatefulWidget {
  const _NameDialog({required this.title, required this.label, required this.confirm, this.hint, this.initial, required this.maxLength});

  final String title;
  final String label;
  final String confirm;
  final String? hint;
  final String? initial;
  final int maxLength;

  @override
  State<_NameDialog> createState() => _NameDialogState();
}

class _NameDialogState extends State<_NameDialog> {
  final _formKey = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.initial);

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) Navigator.of(context).pop(_name.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AlertDialog(
      title: Text(widget.title),
      content: SizedBox(
        width: 400,
        child: Form(
          key: _formKey,
          child: TextFormField(
            controller: _name,
            autofocus: true,
            maxLength: widget.maxLength,
            decoration: InputDecoration(labelText: widget.label, hintText: widget.hint),
            validator: (v) => (v ?? '').trim().isEmpty ? l10n.errorRequired : null,
            onFieldSubmitted: (_) => _submit(),
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(l10n.cancel)),
        FilledButton(onPressed: _submit, child: Text(widget.confirm)),
      ],
    );
  }
}

/// Confirmation d'une suppression définitive.
Future<bool> confirmDelete(BuildContext context, {required String title, required String body}) async {
  final l10n = context.l10n;
  return await showDialog<bool>(
        context: context,
        builder: (d) => AlertDialog(
          title: Text(title),
          content: Text(body),
          actions: [
            TextButton(onPressed: () => Navigator.of(d).pop(false), child: Text(l10n.cancel)),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: FxColors.error),
              onPressed: () => Navigator.of(d).pop(true),
              child: Text(l10n.delete),
            ),
          ],
        ),
      ) ??
      false;
}

/// Nouveau modèle : nom, type de produit, référence facultative.
class NewModelInput {
  const NewModelInput(this.name, this.type, this.reference);

  final String name;
  final ProductType type;
  final String reference;
}

Future<NewModelInput?> showNewModelDialog(BuildContext context) =>
    showDialog<NewModelInput>(context: context, builder: (_) => const _NewModelDialog());

class _NewModelDialog extends StatefulWidget {
  const _NewModelDialog();

  @override
  State<_NewModelDialog> createState() => _NewModelDialogState();
}

class _NewModelDialogState extends State<_NewModelDialog> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _reference = TextEditingController();
  ProductType _type = ProductType.garment;

  @override
  void dispose() {
    _name.dispose();
    _reference.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AlertDialog(
      title: Text(l10n.studioNewModel),
      content: SizedBox(
        width: 440,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _name,
                autofocus: true,
                maxLength: 120,
                decoration: InputDecoration(labelText: l10n.modelName),
                validator: (v) => (v ?? '').trim().isEmpty ? l10n.errorRequired : null,
              ),
              Text(l10n.modelType, style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(height: FxSpace.xs),
              Wrap(
                spacing: FxSpace.sm,
                runSpacing: FxSpace.xs,
                children: [
                  for (final t in ProductType.values)
                    ChoiceChip(
                      avatar: Icon(productTypeIcon(t), size: 18),
                      label: Text(l10n.productTypeLabel(t)),
                      selected: _type == t,
                      onSelected: (_) => setState(() => _type = t),
                    ),
                ],
              ),
              const SizedBox(height: FxSpace.md),
              TextFormField(
                controller: _reference,
                maxLength: 60,
                decoration: InputDecoration(labelText: l10n.modelReference),
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
              Navigator.of(context).pop(NewModelInput(_name.text.trim(), _type, _reference.text.trim()));
            }
          },
          child: Text(l10n.create),
        ),
      ],
    );
  }
}

/// Matière à ajouter à un coloris.
class NewLineInput {
  const NewLineInput(this.materialId, this.role, this.consumption);

  final String materialId;
  final String role;
  final double consumption;
}

Future<NewLineInput?> showAddMaterialDialog(BuildContext context, {required ProductType type}) =>
    showDialog<NewLineInput>(context: context, builder: (_) => _AddMaterialDialog(type: type));

class _AddMaterialDialog extends ConsumerStatefulWidget {
  const _AddMaterialDialog({required this.type});

  final ProductType type;

  @override
  ConsumerState<_AddMaterialDialog> createState() => _AddMaterialDialogState();
}

class _AddMaterialDialogState extends ConsumerState<_AddMaterialDialog> {
  static const _other = '\u0000other';

  final _formKey = GlobalKey<FormState>();
  final _search = TextEditingController();
  final _customRole = TextEditingController();
  final _consumption = TextEditingController();
  String? _materialId;
  late String _role = widget.type.roles.first;

  @override
  void dispose() {
    _search.dispose();
    _customRole.dispose();
    _consumption.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final text = Theme.of(context).textTheme;
    final all = ref.watch(materialsProvider).value ?? const <MaterialItem>[];
    final q = foldForSearch(_search.text);
    final results = q.isEmpty
        ? all
        : all.where((m) => foldForSearch('${m.name} ${m.supplierName ?? ''} ${m.supplierCode ?? ''} ${m.colorName ?? ''}').contains(q)).toList();
    final custom = ref.watch(customRolesProvider).value ?? const <String>[];
    final roles = [...widget.type.roles, ...custom];

    return AlertDialog(
      title: Text(l10n.addMaterial),
      content: SizedBox(
        width: 520,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (all.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: FxSpace.md),
                  child: Text(l10n.pickMaterialLibraryEmpty),
                )
              else ...[
                TextField(
                  controller: _search,
                  decoration: InputDecoration(hintText: l10n.pickMaterialSearch, prefixIcon: const Icon(Icons.search)),
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: FxSpace.sm),
                SizedBox(
                  height: 220,
                  child: results.isEmpty
                      ? Center(child: Text(l10n.pickMaterialEmpty))
                      : ListView.builder(
                          itemCount: results.length,
                          itemBuilder: (_, i) {
                            final m = results[i];
                            final selected = m.id == _materialId;
                            return ListTile(
                              dense: true,
                              selected: selected,
                              selectedTileColor: FxColors.mintPale,
                              leading: SizedBox(width: 36, height: 36, child: MaterialVisual(material: m, iconSize: 16)),
                              title: Text(m.name, maxLines: 1, overflow: TextOverflow.ellipsis),
                              subtitle: supplierLine(m) == null ? null : Text(supplierLine(m)!, maxLines: 1, overflow: TextOverflow.ellipsis),
                              trailing: selected ? const Icon(Icons.check_circle, color: FxColors.emeraldInk) : null,
                              onTap: () => setState(() => _materialId = m.id),
                            );
                          },
                        ),
                ),
                const SizedBox(height: FxSpace.md),
                DropdownButtonFormField<String>(
                  initialValue: _role,
                  isExpanded: true,
                  decoration: InputDecoration(labelText: l10n.bomRoleLabel),
                  items: [
                    for (final r in roles) DropdownMenuItem(value: r, child: Text(l10n.roleText(r))),
                    DropdownMenuItem(value: _other, child: Text(l10n.roleOther)),
                  ],
                  onChanged: (v) => setState(() => _role = v ?? _role),
                ),
                if (_role == _other)
                  TextFormField(
                    controller: _customRole,
                    autofocus: true,
                    maxLength: 60,
                    decoration: InputDecoration(labelText: l10n.roleCustom),
                    validator: (v) => (v ?? '').trim().isEmpty ? l10n.errorRequired : null,
                  ),
                const SizedBox(height: FxSpace.sm),
                TextFormField(
                  controller: _consumption,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))],
                  decoration: InputDecoration(labelText: l10n.consumptionLabel),
                  validator: (v) {
                    if ((v ?? '').trim().isEmpty) return null;
                    final n = parseNumber(v);
                    return n != null && n >= 0 && n <= 1000 ? null : l10n.errorNumberRange(0, 1000);
                  },
                ),
                if (_materialId == null)
                  Padding(
                    padding: const EdgeInsets.only(top: FxSpace.sm),
                    child: Text(l10n.pickMaterial, style: text.bodySmall?.copyWith(color: FxColors.inkSoft)),
                  ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(l10n.cancel)),
        FilledButton(
          onPressed: _materialId == null
              ? null
              : () {
                  if (!(_formKey.currentState?.validate() ?? false)) return;
                  final role = _role == _other ? _customRole.text.trim() : _role;
                  Navigator.of(context).pop(NewLineInput(_materialId!, role, parseNumber(_consumption.text) ?? 0));
                },
          child: Text(l10n.add),
        ),
      ],
    );
  }
}

/// Couleur constante de chaque statut, dans toute l'app.
Color modelStatusColor(ModelStatus s) => switch (s) {
      ModelStatus.idea => FxColors.slate,
      ModelStatus.prototype => FxColors.info,
      ModelStatus.validated => FxColors.success,
      ModelStatus.inProduction => FxColors.warning,
      ModelStatus.delivered => FxColors.petrol,
      ModelStatus.abandoned => FxColors.error,
    };

/// Pastille du statut d'un modèle.
class ModelStatusChip extends StatelessWidget {
  const ModelStatusChip({super.key, required this.status, this.locked = false});

  final ModelStatus status;
  final bool locked;

  @override
  Widget build(BuildContext context) {
    final color = locked ? FxColors.inkSoft : modelStatusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: FxSpace.sm, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        border: Border.all(color: color.withValues(alpha: 0.4)),
        borderRadius: BorderRadius.circular(FxRadius.sm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(locked ? Icons.lock_outline : Icons.circle, size: locked ? 14 : 8, color: color),
          const SizedBox(width: 6),
          Text(context.l10n.modelStatusText(status), style: Theme.of(context).textTheme.labelMedium?.copyWith(color: color)),
        ],
      ),
    );
  }
}

/// Statut d'un modèle : modifiable par un Éditeur en offre Pro ; sinon verrouillé
/// avec la mention « Disponible avec l'offre Pro ».
class ModelStatusControl extends ConsumerWidget {
  const ModelStatusControl({super.key, required this.status, required this.onChanged});

  final ModelStatus status;
  final ValueChanged<ModelStatus> onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final pro = ref.watch(hasProProvider).value ?? false;
    final canEdit = ref.watch(canEditStudioProvider);
    final text = Theme.of(context).textTheme;
    if (!pro) {
      return Wrap(
        spacing: FxSpace.sm,
        runSpacing: FxSpace.xs,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          ModelStatusChip(status: status, locked: true),
          Text(l10n.proLocked, style: text.bodySmall?.copyWith(color: FxColors.inkSoft)),
        ],
      );
    }
    final choices = status.nextChoices;
    if (!canEdit || choices.isEmpty) {
      return Tooltip(
        message: choices.isEmpty ? l10n.modelStatusFinal : '',
        child: ModelStatusChip(status: status),
      );
    }
    return PopupMenuButton<ModelStatus>(
      tooltip: l10n.modelStatusLabel,
      onSelected: onChanged,
      itemBuilder: (_) => [
        for (final s in choices)
          PopupMenuItem(
            value: s,
            child: Row(children: [
              Icon(Icons.circle, size: 10, color: modelStatusColor(s)),
              const SizedBox(width: FxSpace.sm),
              Text(l10n.modelStatusText(s)),
            ]),
          ),
      ],
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ModelStatusChip(status: status),
          const Icon(Icons.arrow_drop_down, color: FxColors.inkSoft),
        ],
      ),
    );
  }
}
