import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app/theme.dart';
import '../../../l10n/l10n.dart';
import '../../../shared/widgets/auth_widgets.dart';
import '../../auth/data/auth_repository.dart';
import '../../library/ui/material_widgets.dart' show TechText;
import '../../supplier/ui/catalog_screen.dart' show canEditCatalogProvider;
import '../data/reports_repository.dart';
import '../domain/error_report.dart';
import 'report_widgets.dart';

/// Fournisseur : signalements reçus des ateliers, à corriger ou rejeter.
class SupplierReportsScreen extends ConsumerStatefulWidget {
  const SupplierReportsScreen({super.key});

  @override
  ConsumerState<SupplierReportsScreen> createState() => _SupplierReportsScreenState();
}

class _SupplierReportsScreenState extends ConsumerState<SupplierReportsScreen> {
  bool _openOnly = true;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final reports = ref.watch(supplierReportsProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.supplierReportsTitle),
        leading: BackButton(onPressed: () => context.go('/catalog')),
      ),
      body: reports.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(FxSpace.lg),
            child: MessageBanner.error(l10n.failure(AuthError.from(e).failure)),
          ),
        ),
        data: (all) {
          final shown = _openOnly ? all.where((r) => r.status == ReportStatus.open).toList() : all;
          return ListView(
            padding: const EdgeInsets.all(FxSpace.md),
            children: [
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 820),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: SegmentedButton<bool>(
                          showSelectedIcon: false,
                          segments: [
                            ButtonSegment(value: true, label: Text(l10n.reportFilterOpen)),
                            ButtonSegment(value: false, label: Text(l10n.reportFilterAll)),
                          ],
                          selected: {_openOnly},
                          onSelectionChanged: (s) => setState(() => _openOnly = s.first),
                        ),
                      ),
                      const SizedBox(height: FxSpace.md),
                      if (shown.isEmpty)
                        Padding(
                          padding: const EdgeInsets.all(FxSpace.xl),
                          child: Text(l10n.supplierReportsEmpty, textAlign: TextAlign.center),
                        ),
                      for (final r in shown) ...[
                        _ReportCard(report: r),
                        const SizedBox(height: FxSpace.sm),
                      ],
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

class _ReportCard extends ConsumerWidget {
  const _ReportCard({required this.report});

  final SupplierErrorReport report;

  Future<void> _resolve(BuildContext context, WidgetRef ref, ReportStatus status) async {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    final response = await showDialog<String>(
      context: context,
      builder: (_) => _ResolveDialog(status: status),
    );
    if (response == null) return;
    try {
      await ref.read(reportsRepositoryProvider).resolve(report.id, status, response.isEmpty ? null : response);
      ref.invalidate(supplierReportsProvider);
    } on AuthError catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.failure(e.failure))));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final text = Theme.of(context).textTheme;
    final r = report;
    final canEdit = ref.watch(canEditCatalogProvider);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(FxSpace.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(r.referenceName, style: text.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                      TechText(r.referenceCode, size: 12, color: FxColors.inkSoft),
                    ],
                  ),
                ),
                ReportStatusChip(status: r.status),
              ],
            ),
            const SizedBox(height: FxSpace.sm),
            Text(l10n.reportFieldLabel(r.field), style: text.labelLarge),
            Text(l10n.reportObservedLine(r.observedValue), style: text.bodyMedium),
            if (r.comment != null) Text(r.comment!, style: text.bodySmall?.copyWith(color: FxColors.inkSoft)),
            if (r.response != null)
              Text(
                r.status == ReportStatus.rejected ? l10n.reportReasonLine(r.response!) : l10n.reportResponseLine(r.response!),
                style: text.bodySmall?.copyWith(fontWeight: FontWeight.w600),
              ),
            const SizedBox(height: FxSpace.xs),
            Text(
              '${r.atelierName ?? l10n.reportAnonymous} · ${formatShortDate(context, r.createdAt)}',
              style: text.labelSmall?.copyWith(color: FxColors.inkSoft),
            ),
            const SizedBox(height: FxSpace.sm),
            Wrap(
              spacing: FxSpace.sm,
              runSpacing: FxSpace.xs,
              children: [
                TextButton.icon(
                  onPressed: () => context.go('/catalog/${r.referenceId}'),
                  icon: const Icon(Icons.open_in_new, size: 18),
                  label: Text(l10n.reportEditReference),
                ),
                if (canEdit && r.status == ReportStatus.open) ...[
                  FilledButton.tonal(
                    onPressed: () => _resolve(context, ref, ReportStatus.fixed),
                    child: Text(l10n.reportMarkFixed),
                  ),
                  OutlinedButton(
                    onPressed: () => _resolve(context, ref, ReportStatus.rejected),
                    child: Text(l10n.reportReject),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// « Corrigé » : message facultatif. « Rejeté » : motif obligatoire.
/// Renvoie le texte saisi (vide possible), ou null si annulé.
class _ResolveDialog extends StatefulWidget {
  const _ResolveDialog({required this.status});

  final ReportStatus status;

  @override
  State<_ResolveDialog> createState() => _ResolveDialogState();
}

class _ResolveDialogState extends State<_ResolveDialog> {
  final _formKey = GlobalKey<FormState>();
  final _text = TextEditingController();

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final reject = widget.status == ReportStatus.rejected;
    return AlertDialog(
      title: Text(reject ? l10n.reportRejectTitle : l10n.reportFixTitle),
      content: SizedBox(
        width: 440,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (!reject) ...[
                Text(l10n.reportFixHelp, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: FxColors.inkSoft)),
                const SizedBox(height: FxSpace.sm),
              ],
              TextFormField(
                controller: _text,
                autofocus: true,
                minLines: 2,
                maxLines: 5,
                maxLength: 2000,
                decoration: InputDecoration(labelText: reject ? l10n.reportRejectReason : l10n.reportFixMessage),
                validator: (v) => reject && (v ?? '').trim().isEmpty ? l10n.errorRequired : null,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(l10n.cancel)),
        FilledButton(
          onPressed: () {
            if (_formKey.currentState?.validate() ?? false) Navigator.of(context).pop(_text.text.trim());
          },
          child: Text(reject ? l10n.reportReject : l10n.reportMarkFixed),
        ),
      ],
    );
  }
}
