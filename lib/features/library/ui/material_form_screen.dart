import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app/theme.dart';
import '../../../l10n/l10n.dart';
import '../../../shared/widgets/auth_widgets.dart';
import '../../auth/data/auth_repository.dart';
import '../../session/data/user_space_repository.dart';
import '../data/materials_repository.dart';
import '../domain/catalog.dart';
import '../domain/material.dart';
import 'material_detail_screen.dart' show validateStock;
import '../../scanner/domain/scan.dart';
import '../domain/catalog_reference.dart';
import 'reference_widgets.dart';
import 'material_widgets.dart';

/// Création (materialId == null) ou modification d'une matière textile.
class MaterialFormScreen extends ConsumerWidget {
  const MaterialFormScreen({super.key, this.materialId, this.prefill});

  final String? materialId;

  /// Fiche pré-remplie par un scan (création uniquement).
  final ScanPrefill? prefill;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final canEdit = ref.watch(canEditMaterialsProvider);
    final title = materialId == null ? l10n.newMaterialTitle : l10n.editMaterialTitle;
    final back = materialId == null ? '/library' : '/library/$materialId';

    if (!canEdit) {
      return Scaffold(
        appBar: AppBar(title: Text(title), leading: BackButton(onPressed: () => context.go(back))),
        body: Center(child: Padding(
          padding: const EdgeInsets.all(FxSpace.lg),
          child: MessageBanner.info(l10n.errorEditorsOnly),
        )),
      );
    }
    if (materialId == null) return _MaterialForm(title: title, back: back, prefill: prefill);

    final existing = ref.watch(materialProvider(materialId!));
    return existing.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (_, _) => Scaffold(appBar: AppBar(), body: Center(child: MessageBanner.error(l10n.loadingError))),
      data: (m) => m == null
          ? Scaffold(appBar: AppBar(), body: Center(child: MessageBanner.info(l10n.materialNotFound)))
          : _MaterialForm(title: title, back: back, initial: m),
    );
  }
}

class _FiberRow {
  _FiberRow({this.fiber, String pct = ''}) : pct = TextEditingController(text: pct);

  String? fiber;
  final TextEditingController pct;
}

class _MaterialForm extends ConsumerStatefulWidget {
  const _MaterialForm({required this.title, required this.back, this.initial, this.prefill});

  final String title;
  final String back;
  final MaterialItem? initial;
  final ScanPrefill? prefill;

  @override
  ConsumerState<_MaterialForm> createState() => _MaterialFormState();
}

class _MaterialFormState extends ConsumerState<_MaterialForm> {
  final _formKey = GlobalKey<FormState>();
  late final MaterialItem? _m = widget.initial;
  // Valeurs de départ : la matière modifiée ou la fiche pré-remplie par un scan.
  late final MaterialItem? _seed = widget.initial ?? widget.prefill?.material;
  late final Set<String> _uncertain = {...?widget.prefill?.uncertain};
  // Lien fournisseur : référence confirmée au scan, ou lien existant de la matière modifiée.
  late final CatalogReference? _scanReference = widget.prefill?.reference;
  bool _unlinked = false;
  bool get _linked => !_unlinked && (_scanReference != null || (_m?.isLinked ?? false));
  String? get _referenceId => _linked ? (_scanReference?.id ?? _m?.supplierReferenceId) : null;
  late final _price = TextEditingController();
  late final _tags = TextEditingController(text: (_m?.tags ?? const []).join(', '));
  late final _name = TextEditingController(
    text: (_seed?.name ?? '').trim().isEmpty ? widget.prefill?.reference?.name : _seed?.name,
  );
  late final _supplier = TextEditingController(text: _seed?.supplierName);
  late final _code = TextEditingController(text: _seed?.supplierCode);
  late final _colorName = TextEditingController(text: _seed?.colorName);
  late final _colorHex = TextEditingController(text: _seed?.colorHex);
  late final _weight = TextEditingController(text: _seed?.specs.weightGsm?.toString());
  late final _width = TextEditingController(text: _seed?.specs.widthCm?.toString());
  late final _stock = TextEditingController();
  late final _notes = TextEditingController(text: _seed?.notes);
  late String? _weave = _seed?.specs.weave;
  late final Set<String> _care = {...?_seed?.specs.care};
  late final Set<String> _certifications = {...?_seed?.specs.certifications};
  late final Set<String> _uses = {...?_seed?.specs.uses};
  late final List<_FiberRow> _fibers = [];

  // Photo : existante (chemin), nouvelle (octets) ou retirée.
  late String? _photoPath = _m?.photoPath;
  Uint8List? _newPhoto;
  String _newPhotoType = 'image/jpeg';

  bool _busy = false;
  bool _submitted = false;
  String? _error;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_fibers.isEmpty) {
      final lang = langOf(context);
      final stock = _seed?.atelierStockM;
      if (stock != null) _stock.text = formatNumber(stock, lang, decimals: 2);
      final price = _m?.pricePerM;
      if (price != null) _price.text = formatNumber(price, lang, decimals: 2);
      _fibers.addAll([
        for (final f in _seed?.specs.composition ?? const <FiberShare>[])
          _FiberRow(fiber: f.fiber, pct: formatNumber(f.pct, lang)),
      ]);
      if (_fibers.isEmpty) _fibers.add(_FiberRow());
    }
  }

  @override
  void dispose() {
    for (final c in [_name, _supplier, _code, _colorName, _colorHex, _weight, _width, _stock, _notes, _price, _tags]) {
      c.dispose();
    }
    for (final f in _fibers) {
      f.pct.dispose();
    }
    super.dispose();
  }

  List<FiberShare> get _composition => [
        for (final f in _fibers)
          if (f.fiber != null && parseNumber(f.pct.text) != null) FiberShare(f.fiber!, parseNumber(f.pct.text)!),
      ];

  bool get _compositionValid {
    final filled = _fibers.where((f) => f.fiber != null || f.pct.text.trim().isNotEmpty).toList();
    if (filled.any((f) => f.fiber == null || parseNumber(f.pct.text) == null)) return false;
    return isCompositionValid(_composition);
  }

  Future<void> _pickPhoto() async {
    final file = await ImagePicker().pickImage(source: ImageSource.gallery, maxWidth: 1600, imageQuality: 82);
    if (file == null) return;
    final bytes = await file.readAsBytes();
    setState(() {
      _newPhoto = bytes;
      _newPhotoType = file.mimeType ?? (file.name.toLowerCase().endsWith('.png') ? 'image/png' : 'image/jpeg');
    });
  }

  Future<void> _save() async {
    setState(() => _submitted = true);
    final formOk = _formKey.currentState!.validate();
    if (!formOk || (!_linked && !_compositionValid)) return;
    final orgId = ref.read(userSpaceProvider).value?.membership?.organization.id;
    if (orgId == null) return;

    setState(() {
      _busy = true;
      _error = null;
    });
    final repo = ref.read(materialsRepositoryProvider);
    final l10n = context.l10n;
    final previousPhoto = _m?.photoPath;
    String? uploaded;
    try {
      var photoPath = _photoPath;
      if (_newPhoto != null) {
        try {
          uploaded = await repo.uploadPhoto(orgId, _newPhoto!, _newPhotoType);
        } on AuthError {
          throw const _PhotoFailure();
        }
        photoPath = uploaded;
      }
      String? text(TextEditingController c) => c.text.trim().isEmpty ? null : c.text.trim();
      final id = await repo.save(MaterialDraft(
        id: _m?.id,
        orgId: orgId,
        name: _name.text,
        supplierName: text(_supplier),
        supplierCode: text(_code),
        colorName: text(_colorName),
        colorHex: normalizeHex(_colorHex.text),
        photoPath: photoPath,
        atelierStockM: parseNumber(_stock.text),
        notes: text(_notes),
        supplierReferenceId: _referenceId,
        pricePerM: parseNumber(_price.text),
        tags: _tags.text.split(',').map((t) => t.trim()).where((t) => t.isNotEmpty).toSet().toList(),
        specs: TextileSpecs(
          composition: _composition,
          weightGsm: parseNumber(_weight.text)?.round(),
          widthCm: parseNumber(_width.text)?.round(),
          weave: _weave,
          care: sortCare(_care),
          certifications: [for (final c in certifications) if (_certifications.contains(c)) c],
          uses: [for (final u in uses) if (_uses.contains(u.code)) u.code],
        ),
      ));
      // L'ancienne photo n'est plus référencée : on la supprime (sans bloquer).
      if (previousPhoto != null && previousPhoto != photoPath) {
        repo.removePhoto(previousPhoto).ignore();
      }
      ref.invalidate(materialsProvider);
      ref.invalidate(materialProvider(id));
      ref.invalidate(linkedReferencesProvider);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.materialSaved)));
      context.go('/library/$id');
    } on _PhotoFailure {
      if (mounted) setState(() => _error = l10n.photoUploadFailed);
    } on AuthError catch (e) {
      if (uploaded != null) repo.removePhoto(uploaded).ignore();
      if (mounted) setState(() => _error = l10n.failure(e.failure));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  /// Données techniques venant du fournisseur, en lecture seule ; « Délier » pour une fiche existante.
  Widget _supplierDataCard(BuildContext context) {
    final l10n = context.l10n;
    final live = _scanReference ?? ref.watch(linkedReferencesProvider).value?[_m?.supplierReferenceId];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (live != null)
          ReferenceCard(reference: live)
        else if (_m != null) ...[
          MessageBanner.warning(l10n.referenceRetiredBanner),
          const SizedBox(height: FxSpace.sm),
          SupplierDataSummary(material: _m),
        ],
        const SizedBox(height: FxSpace.xs),
        Text(l10n.supplierDataHelp, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: FxColors.inkSoft)),
        if (_m?.isLinked ?? false)
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: _busy ? null : _confirmUnlink,
              icon: const Icon(Icons.link_off, size: 18),
              label: Text(l10n.unlink),
            ),
          ),
      ],
    );
  }

  Future<void> _confirmUnlink() async {
    final l10n = context.l10n;
    final ok = await showDialog<bool>(
      context: context,
      builder: (d) => AlertDialog(
        title: Text(l10n.unlink),
        content: Text(l10n.unlinkConfirmBody),
        actions: [
          TextButton(onPressed: () => Navigator.of(d).pop(false), child: Text(l10n.cancel)),
          FilledButton(onPressed: () => Navigator.of(d).pop(true), child: Text(l10n.unlink)),
        ],
      ),
    );
    if (ok == true) setState(() => _unlinked = true);
  }

  /// Décoration d'un champ, surligné tant qu'il est incertain et non modifié.
  InputDecoration _dec(String label, String field, {Widget? prefixIcon}) {
    if (!_uncertain.contains(field)) return InputDecoration(labelText: label, prefixIcon: prefixIcon);
    final warn = OutlineInputBorder(
      borderRadius: BorderRadius.circular(FxRadius.sm),
      borderSide: const BorderSide(color: FxColors.warning, width: 1.5),
    );
    return InputDecoration(
      labelText: label,
      prefixIcon: prefixIcon,
      helperText: context.l10n.fieldUncertain,
      helperStyle: const TextStyle(color: FxColors.warning),
      enabledBorder: warn,
      suffixIcon: const Icon(Icons.help_outline, color: FxColors.warning, size: 20),
    );
  }

  /// Un champ corrigé à la main n'est plus signalé.
  void _confirm(String field) {
    if (_uncertain.remove(field)) setState(() {});
  }

  // Validateurs -----------------------------------------------------------------
  String? _intRange(String? v, int min, int max) {
    if ((v ?? '').trim().isEmpty) return null;
    final n = parseNumber(v);
    if (n == null || n < min || n > max || n != n.roundToDouble()) {
      return context.l10n.errorNumberRange(min, max);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final lang = langOf(context);
    final text = Theme.of(context).textTheme;

    Widget section(String title, List<Widget> children) => Padding(
          padding: const EdgeInsets.only(bottom: FxSpace.md),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(FxSpace.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(title, style: text.titleMedium),
                  const SizedBox(height: FxSpace.md),
                  ...children,
                ],
              ),
            ),
          ),
        );
    const gap = SizedBox(height: FxSpace.md, width: FxSpace.md);
    Widget pair(Widget a, Widget b) => LayoutBuilder(
          builder: (context, c) => c.maxWidth < 480
              ? Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [a, gap, b])
              : Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Expanded(child: a), gap, Expanded(child: b)]),
        );

    final total = compositionTotal(_composition);
    final existing = ref.watch(materialsProvider).value ?? const <MaterialItem>[];
    final duplicate = (_referenceId == null
            ? null
            : existing.where((x) => x.id != _m?.id && x.supplierReferenceId == _referenceId).firstOrNull) ??
        findDuplicate(existing, supplierCode: _linked ? _scanReference?.code ?? _m?.supplierCode : _code.text, exceptId: _m?.id);
    final previewColor = colorFromHex(_colorHex.text);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        leading: BackButton(onPressed: _busy ? null : () => context.go(widget.back)),
      ),
      body: Form(
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
                    if (widget.prefill != null) ...[
                      MessageBanner.info(l10n.prefillBanner),
                      const SizedBox(height: FxSpace.md),
                    ],
                    if (duplicate != null) ...[
                      MessageBanner.warning(l10n.duplicateFound(duplicate.name)),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton(
                          onPressed: () => context.go('/library/${duplicate.id}'),
                          child: Text(l10n.duplicateOpen),
                        ),
                      ),
                      const SizedBox(height: FxSpace.sm),
                    ],
                    section(l10n.sectionIdentity, [
                      TextFormField(
                        controller: _name,
                        decoration: _dec('${l10n.fieldName} *', 'name'),
                        textInputAction: TextInputAction.next,
                        onChanged: (_) => _confirm('name'),
                        validator: (v) => (v ?? '').trim().isEmpty ? l10n.errorRequired : null,
                      ),
                      if (!_linked) ...[
                      gap,
                      pair(
                        TextFormField(
                          controller: _supplier,
                          decoration: _dec(l10n.fieldSupplier, 'supplier_name'),
                          onChanged: (_) => _confirm('supplier_name'),
                        ),
                        TextFormField(
                          controller: _code,
                          style: FxTheme.mono(size: 15),
                          decoration: _dec(l10n.fieldSupplierCode, 'supplier_code'),
                          onChanged: (_) {
                            _confirm('supplier_code');
                            setState(() {});
                          },
                        ),
                      ),
                      ],
                      if (_linked) ...[gap, _supplierDataCard(context)],
                    ]),
                    if (!_linked) section(l10n.sectionComposition, [
                      if (_uncertain.contains('composition')) ...[
                        MessageBanner.warning(l10n.sectionUncertain),
                        const SizedBox(height: FxSpace.md),
                      ],
                      for (final (i, row) in _fibers.indexed) ...[
                        Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: DropdownButtonFormField<String>(
                                initialValue: row.fiber,
                                isExpanded: true,
                                decoration: InputDecoration(labelText: l10n.fiberLabel),
                                items: [
                                  for (final f in fibers)
                                    DropdownMenuItem(value: f.code, child: Text('${f.label(lang)} (${f.code})')),
                                ],
                                onChanged: (v) => setState(() {
                                  row.fiber = v;
                                  _uncertain.remove('composition');
                                }),
                              ),
                            ),
                            const SizedBox(width: FxSpace.sm),
                            SizedBox(
                              width: 92,
                              child: TextFormField(
                                controller: row.pct,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))],
                                decoration: const InputDecoration(labelText: '%'),
                                onChanged: (_) => setState(() {}),
                              ),
                            ),
                            IconButton(
                              tooltip: l10n.removeFiber,
                              onPressed: _fibers.length == 1
                                  ? null
                                  : () => setState(() => _fibers.removeAt(i).pct.dispose()),
                              icon: const Icon(Icons.close),
                            ),
                          ],
                        ),
                        const SizedBox(height: FxSpace.sm),
                      ],
                      Wrap(
                        alignment: WrapAlignment.spaceBetween,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: FxSpace.sm,
                        children: [
                          TextButton.icon(
                            onPressed: () => setState(() => _fibers.add(_FiberRow())),
                            icon: const Icon(Icons.add),
                            label: Text(l10n.addFiber),
                          ),
                          TechText(
                            l10n.compositionTotal(formatNumber(total, lang)),
                            color: _composition.isEmpty || _compositionValid ? FxColors.inkSoft : FxColors.error,
                          ),
                        ],
                      ),
                      if (_submitted && !_compositionValid)
                        Padding(
                          padding: const EdgeInsets.only(top: FxSpace.sm),
                          child: MessageBanner.error(l10n.compositionMustBe100),
                        ),
                    ]),
                    if (!_linked) section(l10n.sectionTechnical, [
                      pair(
                        TextFormField(
                          controller: _weight,
                          keyboardType: TextInputType.number,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          decoration: _dec(l10n.fieldWeight, 'weight_gsm'),
                          onChanged: (_) => _confirm('weight_gsm'),
                          validator: (v) => _intRange(v, 1, 2000),
                        ),
                        TextFormField(
                          controller: _width,
                          keyboardType: TextInputType.number,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          decoration: _dec(l10n.fieldWidth, 'width_cm'),
                          onChanged: (_) => _confirm('width_cm'),
                          validator: (v) => _intRange(v, 1, 600),
                        ),
                      ),
                      gap,
                      DropdownButtonFormField<String?>(
                        initialValue: _weave,
                        isExpanded: true,
                        decoration: _dec(l10n.fieldWeave, 'weave'),
                        items: [
                          DropdownMenuItem(value: null, child: Text(l10n.noneOption)),
                          for (final w in weaves) DropdownMenuItem(value: w.code, child: Text(w.label(lang))),
                        ],
                        onChanged: (v) => setState(() {
                          _weave = v;
                          _uncertain.remove('weave');
                        }),
                      ),
                    ]),
                    section(l10n.sectionColor, [
                      if (!_linked) pair(
                        TextFormField(
                          controller: _colorName,
                          decoration: _dec(l10n.fieldColorName, 'color_name'),
                          onChanged: (_) => _confirm('color_name'),
                        ),
                        TextFormField(
                          controller: _colorHex,
                          style: FxTheme.mono(size: 15),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(r'[#0-9a-fA-F]')),
                            LengthLimitingTextInputFormatter(7),
                          ],
                          decoration: _dec(
                            l10n.fieldColorHex,
                            'color_hex',
                            prefixIcon: Padding(
                              padding: const EdgeInsets.all(10),
                              child: Container(
                                width: 22,
                                height: 22,
                                decoration: BoxDecoration(
                                  color: previewColor ?? FxColors.white,
                                  borderRadius: BorderRadius.circular(5),
                                  border: Border.all(color: FxColors.lineStrong),
                                ),
                              ),
                            ),
                          ),
                          onChanged: (_) => setState(() => _uncertain.remove('color_hex')),
                          validator: (v) =>
                              (v ?? '').trim().isEmpty || normalizeHex(v) != null ? null : l10n.errorHex,
                        ),
                      ),
                      if (!_linked) gap,
                      _PhotoField(
                        existingPath: _photoPath,
                        newPhoto: _newPhoto,
                        onPick: _busy ? null : _pickPhoto,
                        onRemove: _busy
                            ? null
                            : () => setState(() {
                                  _newPhoto = null;
                                  _photoPath = null;
                                }),
                      ),
                    ]),
                    if (!_linked) section(l10n.sectionCare, [
                      if (_uncertain.contains('care')) ...[
                        MessageBanner.warning(l10n.sectionUncertain),
                        const SizedBox(height: FxSpace.md),
                      ],
                      for (final family in CareFamily.values) ...[
                        DropdownButtonFormField<String?>(
                          initialValue: _care.where((c) => careCode(c)?.family == family).firstOrNull,
                          isExpanded: true,
                          decoration: InputDecoration(labelText: careFamilyLabels[family]![lang]),
                          items: [
                            DropdownMenuItem(value: null, child: Text(l10n.noneOption)),
                            for (final c in careCodes.where((c) => c.family == family))
                              DropdownMenuItem(
                                value: c.code,
                                child: Row(
                                  children: [
                                    CareIcon(c.code, size: 22),
                                    const SizedBox(width: FxSpace.sm),
                                    Expanded(child: Text(c.label(lang), overflow: TextOverflow.ellipsis)),
                                  ],
                                ),
                              ),
                          ],
                          // Une seule valeur par famille.
                          onChanged: (v) => setState(() {
                            _uncertain.remove('care');
                            _care.removeWhere((x) => careCode(x)?.family == family);
                            if (v != null) _care.add(v);
                          }),
                        ),
                        const SizedBox(height: FxSpace.md),
                      ],
                    ]),
                    if (!_linked) section(l10n.sectionUses, [
                      Text(l10n.fieldUses, style: text.labelLarge),
                      const SizedBox(height: FxSpace.xs),
                      Wrap(
                        spacing: FxSpace.sm,
                        runSpacing: FxSpace.sm,
                        children: [
                          for (final u in uses)
                            FilterChip(
                              label: Text(u.label(lang)),
                              selected: _uses.contains(u.code),
                              onSelected: (on) => setState(() => on ? _uses.add(u.code) : _uses.remove(u.code)),
                            ),
                        ],
                      ),
                      gap,
                      Text(l10n.fieldCertifications, style: text.labelLarge),
                      const SizedBox(height: FxSpace.xs),
                      Wrap(
                        spacing: FxSpace.sm,
                        runSpacing: FxSpace.sm,
                        children: [
                          for (final c in certifications)
                            FilterChip(
                              label: Text(c),
                              selected: _certifications.contains(c),
                              onSelected: (on) =>
                                  setState(() => on ? _certifications.add(c) : _certifications.remove(c)),
                            ),
                        ],
                      ),
                    ]),
                    section(l10n.privateLayer, [
                      Text(l10n.privateLayerHelp, style: text.bodySmall?.copyWith(color: FxColors.inkSoft)),
                      gap,
                      pair(
                        TextFormField(
                          controller: _price,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))],
                          decoration: InputDecoration(labelText: l10n.fieldPrice),
                          validator: (v) {
                            if ((v ?? '').trim().isEmpty) return null;
                            final n = parseNumber(v);
                            return n != null && n >= 0 && n <= 100000 ? null : l10n.errorNumberRange(0, 100000);
                          },
                        ),
                        TextFormField(
                          controller: _tags,
                          decoration: InputDecoration(labelText: l10n.fieldTags, hintText: l10n.fieldTagsHint),
                        ),
                      ),
                    ]),
                    section(l10n.sectionStock, [
                      TextFormField(
                        controller: _stock,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))],
                        decoration: InputDecoration(labelText: l10n.fieldStock),
                        validator: (v) => validateStock(v, l10n),
                      ),
                    ]),
                    section(l10n.sectionNotes, [
                      TextFormField(
                        controller: _notes,
                        minLines: 3,
                        maxLines: 8,
                        maxLength: 4000,
                        decoration: InputDecoration(labelText: l10n.sectionNotes),
                      ),
                    ]),
                    if (_error != null) ...[MessageBanner.error(_error!), const SizedBox(height: FxSpace.md)],
                    BusyButton(label: l10n.save, busy: _busy, onPressed: _save),
                    const SizedBox(height: FxSpace.xxl),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PhotoFailure implements Exception {
  const _PhotoFailure();
}

class _PhotoField extends ConsumerWidget {
  const _PhotoField({required this.existingPath, required this.newPhoto, required this.onPick, required this.onRemove});

  final String? existingPath;
  final Uint8List? newPhoto;
  final VoidCallback? onPick;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    Widget? preview;
    if (newPhoto != null) {
      preview = Image.memory(newPhoto!, fit: BoxFit.cover);
    } else if (existingPath != null) {
      final url = ref.watch(photoUrlProvider(existingPath!)).value;
      if (url != null) preview = Image.network(url, fit: BoxFit.cover);
    }
    final hasPhoto = newPhoto != null || existingPath != null;
    return Row(
      children: [
        Container(
          width: 96,
          height: 72,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: FxColors.mintPale,
            borderRadius: BorderRadius.circular(FxRadius.md),
          ),
          child: preview ?? const Icon(Icons.photo_camera_outlined, color: FxColors.emeraldInk),
        ),
        const SizedBox(width: FxSpace.md),
        Expanded(
          child: Wrap(
            spacing: FxSpace.sm,
            runSpacing: FxSpace.sm,
            children: [
              OutlinedButton.icon(
                onPressed: onPick,
                icon: const Icon(Icons.add_photo_alternate_outlined),
                label: Text(hasPhoto ? l10n.photoChange : l10n.photoAdd),
              ),
              if (hasPhoto) TextButton(onPressed: onRemove, child: Text(l10n.photoRemove)),
            ],
          ),
        ),
      ],
    );
  }
}
