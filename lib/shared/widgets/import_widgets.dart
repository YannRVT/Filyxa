import 'package:material_ui/material_ui.dart';

import '../../app/theme.dart';
import '../../features/supplier/domain/catalog_import.dart';
import '../../features/supplier/ui/supplier_texts.dart';
import '../../l10n/l10n.dart';

/// Association des colonnes d'un fichier aux champs (import catalogue ou atelier).
class ColumnMappingCard<F extends Enum> extends StatelessWidget {
  const ColumnMappingCard({
    super.key,
    required this.fields,
    required this.headers,
    required this.mapping,
    required this.isRequired,
    required this.label,
    required this.intro,
    required this.onChanged,
  });

  final List<F> fields;
  final List<String> headers;
  final Map<F, int> mapping;
  final bool Function(F) isRequired;
  final String Function(F) label;
  final String intro;
  final ValueChanged<Map<F, int>> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final text = Theme.of(context).textTheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(FxSpace.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l10n.importMappingTitle, style: text.titleMedium),
            const SizedBox(height: FxSpace.xs),
            Text(intro, style: text.bodySmall?.copyWith(color: FxColors.inkSoft)),
            const SizedBox(height: FxSpace.md),
            LayoutBuilder(builder: (context, c) {
              final columns = c.maxWidth >= 600 ? 2 : 1;
              final width = (c.maxWidth - (columns - 1) * FxSpace.md) / columns;
              return Wrap(
                spacing: FxSpace.md,
                runSpacing: FxSpace.sm,
                children: [
                  for (final field in fields)
                    SizedBox(
                      width: width,
                      child: DropdownButtonFormField<int?>(
                        key: ValueKey('map-${field.name}-${mapping[field]}'),
                        initialValue: mapping[field],
                        isExpanded: true,
                        decoration: InputDecoration(
                          labelText: '${label(field)}${isRequired(field) ? ' *' : ''}',
                          errorText: isRequired(field) && !mapping.containsKey(field) ? l10n.errorRequired : null,
                        ),
                        items: [
                          DropdownMenuItem(value: null, child: Text(l10n.importColumnNone)),
                          for (final (i, h) in headers.indexed)
                            DropdownMenuItem(value: i, child: Text(h.isEmpty ? '#${i + 1}' : h, overflow: TextOverflow.ellipsis)),
                        ],
                        onChanged: (v) {
                          final next = {...mapping}..remove(field);
                          if (v != null) {
                            next.removeWhere((_, col) => col == v);
                            next[field] = v;
                          }
                          onChanged(next);
                        },
                      ),
                    ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }
}

/// Aperçu de l'import : lignes prêtes, lignes en erreur avec leur motif, puis lancement.
class ImportPreview extends StatelessWidget {
  const ImportPreview({
    super.key,
    required this.analysis,
    required this.running,
    required this.done,
    required this.runLabel,
    required this.onRun,
  });

  final ImportAnalysis analysis;
  final bool running;
  final int done;
  final String runLabel;
  final VoidCallback onRun;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final text = Theme.of(context).textTheme;
    final valid = analysis.valid.length;
    final invalid = analysis.invalid;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          liveRegion: true,
          child: Text(l10n.importSummary(valid, invalid.length), style: text.titleMedium),
        ),
        if (invalid.isNotEmpty) ...[
          const SizedBox(height: FxSpace.sm),
          Card(
            child: ExpansionTile(
              initiallyExpanded: invalid.length <= 5,
              title: Text(l10n.importErrorsTitle, style: const TextStyle(color: FxColors.error)),
              children: [
                for (final row in invalid.take(200))
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
        if (running)
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              LinearProgressIndicator(value: valid == 0 ? null : done / valid),
              const SizedBox(height: FxSpace.sm),
              Text(l10n.importRunning(done, valid), textAlign: TextAlign.center),
            ],
          )
        else
          FilledButton.icon(
            onPressed: valid == 0 ? null : onRun,
            icon: const Icon(Icons.cloud_upload_outlined),
            label: Text(runLabel),
          ),
      ],
    );
  }
}
