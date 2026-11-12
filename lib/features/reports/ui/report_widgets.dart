import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app/theme.dart';
import '../../../l10n/l10n.dart';
import '../../../shared/widgets/auth_widgets.dart';
import '../../auth/data/auth_repository.dart';
import '../../studio/domain/studio.dart';
import '../../studio/ui/studio_widgets.dart' show StudioTexts;
import '../data/reports_repository.dart';
import '../domain/error_report.dart';

extension ReportTexts on AppLocalizations {
  String reportFieldLabel(ReportField f) => switch (f) {
        ReportField.name => importFieldName,
        ReportField.color => fieldColorName,
        ReportField.composition => colComposition,
        ReportField.weight => fieldWeight,
        ReportField.width => fieldWidth,
        ReportField.weave => fieldWeave,
        ReportField.care => sectionCare,
        ReportField.certifications => fieldCertifications,
        ReportField.uses => fieldUses,
        ReportField.availability => reportFieldAvailability,
        ReportField.other => reportFieldOther,
      };

  String reportStatusLabel(ReportStatus s) => switch (s) {
        ReportStatus.open => reportStatusOpen,
        ReportStatus.fixed => reportStatusFixed,
        ReportStatus.rejected => reportStatusRejected,
      };

  String notificationText(AppNotification n) {
    final field = reportFieldLabel(n.field);
    final name = (n.data['name'] as String?) ?? '';
    return switch (n.kind) {
      NotificationKind.reportNew => notifReportNew((n.data['code'] as String?) ?? '', field),
      NotificationKind.reportFixed => notifReportFixed(name, field),
      NotificationKind.reportRejected => notifReportRejected(name, field),
      NotificationKind.stockLow => notifStockLow(name, (n.data['code'] as String?) ?? ''),
      NotificationKind.stockOut => notifStockOut(name, (n.data['code'] as String?) ?? ''),
      NotificationKind.referenceUpdated => notifReferenceUpdated(name, (n.data['code'] as String?) ?? ''),
      NotificationKind.referenceRetired => notifReferenceRetired(name, (n.data['code'] as String?) ?? ''),
      NotificationKind.deadlineOverdue => notifDeadlineOverdue(
          name,
          modelStatusText(ModelStatus.parse(n.data['stage'] as String?)),
          DateFormat.yMMMd(localeName).format(DateTime.tryParse((n.data['due_date'] as String?) ?? '') ?? n.createdAt),
        ),
    };
  }
}

String formatShortDate(BuildContext context, DateTime d) =>
    DateFormat.yMMMd(Localizations.localeOf(context).toLanguageTag()).format(d);

/// Pastille de statut d'un signalement.
class ReportStatusChip extends StatelessWidget {
  const ReportStatusChip({super.key, required this.status});

  final ReportStatus status;

  @override
  Widget build(BuildContext context) {
    final (fg, bg) = switch (status) {
      ReportStatus.open => (FxColors.info, FxColors.infoBg),
      ReportStatus.fixed => (FxColors.success, FxColors.successBg),
      ReportStatus.rejected => (FxColors.error, FxColors.errorBg),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(999)),
      child: Text(
        context.l10n.reportStatusLabel(status),
        style: TextStyle(color: fg, fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }
}

/// Formulaire de signalement ; renvoie true si le signalement est envoyé.
Future<bool> showReportDialog(BuildContext context, {required String materialId}) async =>
    await showDialog<bool>(context: context, builder: (_) => _ReportDialog(materialId: materialId)) ?? false;

class _ReportDialog extends ConsumerStatefulWidget {
  const _ReportDialog({required this.materialId});

  final String materialId;

  @override
  ConsumerState<_ReportDialog> createState() => _ReportDialogState();
}

class _ReportDialogState extends ConsumerState<_ReportDialog> {
  final _formKey = GlobalKey<FormState>();
  final _observed = TextEditingController();
  final _comment = TextEditingController();
  ReportField? _field;
  bool _share = false;
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _observed.dispose();
    _comment.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref.read(reportsRepositoryProvider).create(
            materialId: widget.materialId,
            field: _field!,
            observedValue: _observed.text.trim(),
            comment: _comment.text.trim().isEmpty ? null : _comment.text.trim(),
            shareIdentity: _share,
          );
      ref.invalidate(materialReportsProvider(widget.materialId));
      if (mounted) Navigator.of(context).pop(true);
    } on AuthError catch (e) {
      if (mounted) setState(() => _error = context.l10n.failure(e.failure));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final text = Theme.of(context).textTheme;
    return AlertDialog(
      title: Text(l10n.reportTitle),
      content: SizedBox(
        width: 480,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(l10n.reportIntro, style: text.bodySmall?.copyWith(color: FxColors.inkSoft)),
                const SizedBox(height: FxSpace.md),
                DropdownButtonFormField<ReportField>(
                  initialValue: _field,
                  isExpanded: true,
                  decoration: InputDecoration(labelText: l10n.reportField),
                  items: [
                    for (final f in ReportField.values)
                      DropdownMenuItem(value: f, child: Text(l10n.reportFieldLabel(f))),
                  ],
                  validator: (v) => v == null ? l10n.errorRequired : null,
                  onChanged: (v) => setState(() => _field = v),
                ),
                const SizedBox(height: FxSpace.sm),
                TextFormField(
                  controller: _observed,
                  maxLength: 500,
                  decoration: InputDecoration(labelText: l10n.reportObserved, hintText: l10n.reportObservedHint),
                  validator: (v) => (v ?? '').trim().isEmpty ? l10n.errorRequired : null,
                ),
                TextFormField(
                  controller: _comment,
                  minLines: 2,
                  maxLines: 5,
                  maxLength: 2000,
                  decoration: InputDecoration(labelText: l10n.reportComment),
                ),
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  controlAffinity: ListTileControlAffinity.leading,
                  value: _share,
                  onChanged: _busy ? null : (v) => setState(() => _share = v ?? false),
                  title: Text(l10n.reportShareIdentity, style: text.bodyMedium),
                ),
                if (_error != null) ...[const SizedBox(height: FxSpace.sm), MessageBanner.error(_error!)],
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: _busy ? null : () => Navigator.of(context).pop(false), child: Text(l10n.cancel)),
        FilledButton(onPressed: _busy ? null : _send, child: Text(l10n.reportSend)),
      ],
    );
  }
}

/// Signalements d'une matière liée, avec leur statut et la réponse du fournisseur.
class MaterialReportsSection extends ConsumerWidget {
  const MaterialReportsSection({super.key, required this.materialId, required this.canReport});

  final String materialId;
  final bool canReport;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final text = Theme.of(context).textTheme;
    final reports = ref.watch(materialReportsProvider(materialId)).value ?? const <ErrorReport>[];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final r in reports)
          Padding(
            padding: const EdgeInsets.only(bottom: FxSpace.sm),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(FxSpace.sm),
              decoration: BoxDecoration(
                border: Border.all(color: FxColors.line),
                borderRadius: BorderRadius.circular(FxRadius.sm),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(l10n.reportFieldLabel(r.field), style: text.titleSmall),
                      ),
                      ReportStatusChip(status: r.status),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(l10n.reportObservedLine(r.observedValue), style: text.bodySmall),
                  if (r.comment != null) Text(r.comment!, style: text.bodySmall?.copyWith(color: FxColors.inkSoft)),
                  if (r.response != null)
                    Text(
                      r.status == ReportStatus.rejected ? l10n.reportReasonLine(r.response!) : l10n.reportResponseLine(r.response!),
                      style: text.bodySmall?.copyWith(fontWeight: FontWeight.w600),
                    ),
                  Text(formatShortDate(context, r.createdAt), style: text.labelSmall?.copyWith(color: FxColors.inkSoft)),
                ],
              ),
            ),
          ),
        if (canReport)
          OutlinedButton.icon(
            onPressed: () async {
              final messenger = ScaffoldMessenger.of(context);
              final sent = await showReportDialog(context, materialId: materialId);
              if (sent) messenger.showSnackBar(SnackBar(content: Text(l10n.reportSent)));
            },
            icon: const Icon(Icons.flag_outlined, size: 18),
            label: Text(l10n.reportAction),
          ),
      ],
    );
  }
}
