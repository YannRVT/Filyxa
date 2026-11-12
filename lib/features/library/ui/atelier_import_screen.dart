import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app/theme.dart';
import '../../../l10n/l10n.dart';
import '../../../shared/widgets/auth_widgets.dart';
import '../../../shared/widgets/import_widgets.dart';
import '../../auth/data/auth_repository.dart';
import '../../session/data/user_space_repository.dart';
import '../../supplier/data/table_reader.dart';
import '../../supplier/domain/catalog_import.dart';
import '../../supplier/ui/supplier_texts.dart';
import '../data/materials_repository.dart';
import '../domain/atelier_import.dart';

/// Import de la base atelier : fichier → association des colonnes → aperçu et erreurs
/// → import → récapitulatif avec rapprochement des catalogues fournisseurs.
class AtelierImportScreen extends ConsumerStatefulWidget {
  const AtelierImportScreen({super.key, this.initialTable, this.initialFileName});

  /// Pour les tests : tableau déjà lu.
  final TableData? initialTable;
  final String? initialFileName;

  @override
  ConsumerState<AtelierImportScreen> createState() => _AtelierImportScreenState();
}

class _AtelierImportScreenState extends ConsumerState<AtelierImportScreen> {
  late TableData? _table = widget.initialTable;
  late String? _fileName = widget.initialFileName;
  Map<AtelierImportField, int> _mapping = {};
  String? _error;
  bool _running = false;
  int _done = 0;
  AtelierImportResult? _result;

  /// Lignes refusées avant envoi (rapportées dans le récapitulatif).
  int _clientErrors = 0;

  @override
  void initState() {
    super.initState();
    if (_table != null) {
      _mapping = guessAtelierMapping(_table!.headers, remembered: ref.read(atelierImportMappingProvider).value ?? const {});
    }
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
      // Association du dernier import proposée d'office ; colonnes nouvelles devinées.
      final remembered = await ref.read(atelierImportMappingProvider.future).catchError((_) => const <String, dynamic>{});
      if (!mounted) return;
      setState(() {
        _table = table;
        _fileName = file.name;
        _mapping = guessAtelierMapping(table.headers, remembered: remembered);
        _error = null;
        _result = null;
      });
    } on UnreadableFileException {
      setState(() => _error = l10n.importUnreadable);
    }
  }

  Future<void> _run(ImportAnalysis analysis) async {
    final orgId = ref.read(userSpaceProvider).value?.membership?.organization.id;
    if (orgId == null) return;
    final valid = analysis.valid;
    setState(() {
      _running = true;
      _done = 0;
      _error = null;
    });
    try {
      final result = await ref.read(materialsRepositoryProvider).importRows(
        orgId,
        [for (final r in valid) r.payload!],
        [for (final r in valid) r.line],
        onProgress: (done, _) {
          if (mounted) setState(() => _done = done);
        },
      );
      // Mémorise l'association des colonnes pour le prochain import (sans gravité si elle échoue).
      final table = _table;
      if (table != null) {
        try {
          await ref.read(materialsRepositoryProvider).saveAtelierImportMapping(orgId, mappingToRemember(_mapping, table.headers));
          ref.invalidate(atelierImportMappingProvider);
        } catch (_) {
          // L'import lui-même a réussi ; l'association sera simplement redevinée.
        }
      }
      ref.invalidate(materialsProvider);
      ref.invalidate(linkedReferencesProvider);
      if (mounted) {
        setState(() {
          _result = result;
          _clientErrors = analysis.invalid.length;
        });
      }
    } on AuthError catch (e) {
      if (mounted) setState(() => _error = context.l10n.failure(e.failure));
    } finally {
      if (mounted) setState(() => _running = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final canEdit = ref.watch(canEditMaterialsProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.atelierImportTitle),
        leading: BackButton(onPressed: _running ? null : () => context.go('/library')),
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
                        ? [_resultCard(l10n)]
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
              Text(l10n.atelierImportHelp, style: Theme.of(context).textTheme.bodyMedium),
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
    final analysis = analyzeAtelierRows(table.rows, _mapping);
    final requiredMissing = AtelierImportField.values.any((f) => f.required && !_mapping.containsKey(f));
    return [
      const SizedBox(height: FxSpace.md),
      ColumnMappingCard<AtelierImportField>(
        fields: AtelierImportField.values,
        headers: table.headers,
        mapping: _mapping,
        isRequired: (f) => f.required,
        label: l10n.atelierImportField,
        intro: l10n.atelierImportMappingIntro,
        onChanged: (m) => setState(() => _mapping = m),
      ),
      const SizedBox(height: FxSpace.md),
      if (!requiredMissing)
        ImportPreview(
          analysis: analysis,
          running: _running,
          done: _done,
          runLabel: l10n.atelierImportRun(analysis.valid.length),
          onRun: () => _run(analysis),
        ),
    ];
  }

  Widget _resultCard(AppLocalizations l10n) {
    final r = _result!;
    final text = Theme.of(context).textTheme;
    final errors = _clientErrors + r.serverErrors.length;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(FxSpace.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.check_circle_outline, size: 40, color: FxColors.success),
            const SizedBox(height: FxSpace.sm),
            Text(l10n.importDoneTitle, style: text.titleLarge, textAlign: TextAlign.center),
            const SizedBox(height: FxSpace.xs),
            Semantics(
              liveRegion: true,
              child: Text(
                l10n.atelierImportDone(r.imported,r.linked, r.pending, errors),
                style: text.titleMedium,
                textAlign: TextAlign.center,
              ),
            ),
            Text(
              l10n.atelierImportDetail(r.inserted, r.updated),
              style: text.bodySmall?.copyWith(color: FxColors.inkSoft),
              textAlign: TextAlign.center,
            ),
            if (r.serverErrors.isNotEmpty) ...[
              const SizedBox(height: FxSpace.md),
              for (final (line, message) in r.serverErrors.take(50))
                Text('${l10n.importLine(line)} · ${l10n.importServerRejected(message)}',
                    style: text.bodySmall?.copyWith(color: FxColors.error)),
            ],
            const SizedBox(height: FxSpace.lg),
            if (r.pending > 0) ...[
              FilledButton.icon(
                onPressed: () => context.go('/library/links'),
                icon: const Icon(Icons.link),
                label: Text(l10n.reviewLinksAction(r.pending)),
              ),
              const SizedBox(height: FxSpace.sm),
              OutlinedButton(onPressed: () => context.go('/library'), child: Text(l10n.backToLibrary)),
            ] else
              FilledButton(onPressed: () => context.go('/library'), child: Text(l10n.backToLibrary)),
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
    );
  }
}
