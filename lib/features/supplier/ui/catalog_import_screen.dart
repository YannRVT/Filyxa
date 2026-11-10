import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app/theme.dart';
import '../../../l10n/l10n.dart';
import '../../../shared/widgets/auth_widgets.dart';
import '../../auth/data/auth_repository.dart';
import '../../session/data/user_space_repository.dart';
import '../data/catalog_repository.dart';
import '../data/table_reader.dart';
import '../domain/catalog_import.dart';
import 'catalog_screen.dart' show canEditCatalogProvider;
import 'supplier_texts.dart';

/// Import du catalogue : fichier → association des colonnes → aperçu et erreurs → import.
class CatalogImportScreen extends ConsumerStatefulWidget {
  const CatalogImportScreen({super.key, this.initialTable, this.initialFileName});

  /// Pour les tests : tableau déjà lu.
  final TableData? initialTable;
  final String? initialFileName;

  @override
  ConsumerState<CatalogImportScreen> createState() => _CatalogImportScreenState();
}

class _CatalogImportScreenState extends ConsumerState<CatalogImportScreen> {
  late TableData? _table = widget.initialTable;
  late String? _fileName = widget.initialFileName;
  Map<ImportField, int> _mapping = {};
  String? _error;
  bool _running = false;
  int _done = 0;
  ImportResult? _result;

  @override
  void initState() {
    super.initState();
    if (_table != null) _mapping = guessMapping(_table!.headers);
  }

  Future<void> _pick() async {
    final l10n = context.l10n;
    final file = await FilePicker.pickFile(
      type: FileType.custom,
      allowedExtensions: const ['xlsx', 'csv', 'txt'],
    );
    if (file == null) return;
    try {
      final table = readTable(await file.readAsBytes(), file.name);
      if (table.rows.length > kMaxImportRows) {
        setState(() => _error = l10n.importTooMany(table.rows.length));
        return;
      }
      final remembered = ref.read(supplierSettingsProvider).value?.importMapping ?? const {};
      setState(() {
        _table = table;
        _fileName = file.name;
        _mapping = guessMapping(table.headers, remembered: remembered);
        _error = null;
        _result = null;
      });
    } on UnreadableFileException {
      setState(() => _error = l10n.importUnreadable);
    }
  }

  Future<void> _run(ImportAnalysis analysis) async {
    final orgId = ref.read(userSpaceProvider).value?.membership?.organization.id;
    if (orgId == null || _table == null) return;
    final valid = analysis.valid;
    setState(() {
      _running = true;
      _done = 0;
      _error = null;
    });
    final repo = ref.read(catalogRepositoryProvider);
    try {
      final result = await repo.importRows(
        orgId,
        [for (final r in valid) r.payload!],
        [for (final r in valid) r.line],
        onProgress: (done, _) {
          if (mounted) setState(() => _done = done);
        },
      );
      // Mémorise l'association des colonnes pour le prochain import.
      await repo.saveSettings(orgId, mapping: mappingToRemember(_mapping, _table!.headers));
      ref.invalidate(supplierReferencesProvider);
      ref.invalidate(supplierSettingsProvider);
      if (mounted) setState(() => _result = result);
    } on AuthError catch (e) {
      if (mounted) setState(() => _error = context.l10n.failure(e.failure));
    } finally {
      if (mounted) setState(() => _running = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final canEdit = ref.watch(canEditCatalogProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.importTitle),
        leading: BackButton(onPressed: _running ? null : () => context.go('/catalog')),
      ),
      body: ListView(
        padding: const EdgeInsets.all(FxSpace.md),
        children: [
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 820),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: !canEdit
                    ? [MessageBanner.info(l10n.errorEditorsOnly)]
                    : _result != null
                        ? _resultView(l10n)
                        : [
                            _pickCard(l10n),
                            if (_error != null) ...[const SizedBox(height: FxSpace.md), MessageBanner.error(_error!)],
                            if (_table != null) ..._mappingAndPreview(l10n),
                          ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _pickCard(AppLocalizations l10n) => Card(
        child: Padding(
          padding: const EdgeInsets.all(FxSpace.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.importPickHelp, style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: FxSpace.md),
              Wrap(
                spacing: FxSpace.md,
                runSpacing: FxSpace.sm,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  OutlinedButton.icon(
                    onPressed: _running ? null : _pick,
                    icon: const Icon(Icons.upload_file_outlined),
                    label: Text(l10n.importPickFile),
                  ),
                  if (_fileName != null) Text(l10n.importFileName(_fileName!)),
                ],
              ),
            ],
          ),
        ),
      );

  List<Widget> _mappingAndPreview(AppLocalizations l10n) {
    final table = _table!;
    final text = Theme.of(context).textTheme;
    final analysis = analyzeRows(table.rows, _mapping);
    final requiredMissing = ImportField.values.any((f) => f.required && !_mapping.containsKey(f));

    return [
      const SizedBox(height: FxSpace.md),
      Card(
        child: Padding(
          padding: const EdgeInsets.all(FxSpace.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(l10n.importMappingTitle, style: text.titleMedium),
              const SizedBox(height: FxSpace.xs),
              Text(l10n.importMappingIntro, style: text.bodySmall?.copyWith(color: FxColors.inkSoft)),
              const SizedBox(height: FxSpace.md),
              LayoutBuilder(builder: (context, c) {
                final columns = c.maxWidth >= 600 ? 2 : 1;
                final width = (c.maxWidth - (columns - 1) * FxSpace.md) / columns;
                return Wrap(
                  spacing: FxSpace.md,
                  runSpacing: FxSpace.sm,
                  children: [
                    for (final field in ImportField.values)
                      SizedBox(
                        width: width,
                        child: DropdownButtonFormField<int?>(
                          key: ValueKey('map-${field.name}-${_mapping[field]}'),
                          initialValue: _mapping[field],
                          isExpanded: true,
                          decoration: InputDecoration(
                            labelText: '${l10n.importField(field)}${field.required ? ' *' : ''}',
                            errorText: field.required && !_mapping.containsKey(field) ? l10n.errorRequired : null,
                          ),
                          items: [
                            DropdownMenuItem(value: null, child: Text(l10n.importColumnNone)),
                            for (final (i, h) in table.headers.indexed)
                              DropdownMenuItem(value: i, child: Text(h.isEmpty ? '#${i + 1}' : h, overflow: TextOverflow.ellipsis)),
                          ],
                          onChanged: (v) => setState(() {
                            _mapping = {..._mapping}..remove(field);
                            if (v != null) {
                              _mapping.removeWhere((_, col) => col == v);
                              _mapping[field] = v;
                            }
                          }),
                        ),
                      ),
                  ],
                );
              }),
            ],
          ),
        ),
      ),
      const SizedBox(height: FxSpace.md),
      if (!requiredMissing) ...[
        Semantics(
          liveRegion: true,
          child: Text(l10n.importSummary(analysis.valid.length, analysis.invalid.length), style: text.titleMedium),
        ),
        if (analysis.invalid.isNotEmpty) ...[
          const SizedBox(height: FxSpace.sm),
          Card(
            child: ExpansionTile(
              initiallyExpanded: analysis.invalid.length <= 5,
              title: Text(l10n.importErrorsTitle, style: const TextStyle(color: FxColors.error)),
              children: [
                for (final row in analysis.invalid.take(200))
                  ListTile(
                    dense: true,
                    leading: Text(l10n.importLine(row.line), style: text.labelMedium),
                    title: Text(row.issues.map(l10n.issue).join(' · ')),
                  ),
              ],
            ),
          ),
        ],
        const SizedBox(height: FxSpace.md),
        if (_running)
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              LinearProgressIndicator(value: analysis.valid.isEmpty ? null : _done / analysis.valid.length),
              const SizedBox(height: FxSpace.sm),
              Text(l10n.importRunning(_done, analysis.valid.length), textAlign: TextAlign.center),
            ],
          )
        else
          FilledButton.icon(
            onPressed: analysis.valid.isEmpty ? null : () => _run(analysis),
            icon: const Icon(Icons.cloud_upload_outlined),
            label: Text(l10n.importRun(analysis.valid.length)),
          ),
      ],
    ];
  }

  List<Widget> _resultView(AppLocalizations l10n) {
    final r = _result!;
    final text = Theme.of(context).textTheme;
    return [
      Card(
        child: Padding(
          padding: const EdgeInsets.all(FxSpace.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.check_circle_outline, size: 40, color: FxColors.success),
              const SizedBox(height: FxSpace.sm),
              Text(l10n.importDoneTitle, style: text.titleLarge, textAlign: TextAlign.center),
              const SizedBox(height: FxSpace.xs),
              Text(l10n.importDone(r.inserted, r.updated), textAlign: TextAlign.center),
              if (r.serverErrors.isNotEmpty) ...[
                const SizedBox(height: FxSpace.md),
                for (final (line, message) in r.serverErrors.take(50))
                  Text('${l10n.importLine(line)} · ${l10n.importServerRejected(message)}',
                      style: text.bodySmall?.copyWith(color: FxColors.error)),
              ],
              const SizedBox(height: FxSpace.lg),
              FilledButton(onPressed: () => context.go('/catalog'), child: Text(l10n.backToCatalog)),
              const SizedBox(height: FxSpace.sm),
              TextButton(
                onPressed: () => setState(() {
                  _result = null;
                  _table = null;
                  _fileName = null;
                }),
                child: Text(l10n.importAgain),
              ),
            ],
          ),
        ),
      ),
    ];
  }
}
