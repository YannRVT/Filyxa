import 'package:material_ui/material_ui.dart';

import '../../../app/theme.dart';
import '../../../l10n/l10n.dart';
import '../domain/availability.dart';
import '../domain/catalog_import.dart';

extension SupplierTexts on AppLocalizations {
  String status(AvailabilityStatus s, {int? leadTimeWeeks}) => switch (s) {
        AvailabilityStatus.available => statusAvailable,
        AvailabilityStatus.low => statusLow,
        AvailabilityStatus.onOrder => leadTimeWeeks == null ? statusOnOrder : statusOnOrderWeeks(leadTimeWeeks),
        AvailabilityStatus.outOfStock => statusOutOfStock,
      };

  String mode(AvailabilityMode m) => switch (m) {
        AvailabilityMode.exact => modeExact,
        AvailabilityMode.tiers => modeTiers,
        AvailabilityMode.hidden => modeHidden,
      };

  String modeHelp(AvailabilityMode m) => switch (m) {
        AvailabilityMode.exact => modeExactHelp,
        AvailabilityMode.tiers => modeTiersHelp,
        AvailabilityMode.hidden => modeHiddenHelp,
      };

  String importField(ImportField f) => switch (f) {
        ImportField.code => fieldSupplierCode,
        ImportField.name => importFieldName,
        ImportField.colorName => fieldColorName,
        ImportField.colorHex => fieldColorHex,
        ImportField.composition => colComposition,
        ImportField.weight => fieldWeight,
        ImportField.width => fieldWidth,
        ImportField.weave => fieldWeave,
        ImportField.certifications => fieldCertifications,
        ImportField.uses => fieldUses,
        ImportField.stock => importFieldStock,
        ImportField.leadTime => leadTimeLabel,
      };

  String issue(ImportIssue i) => switch (i.kind) {
        ImportIssueKind.missingCode => issueMissingCode,
        ImportIssueKind.missingName => issueMissingName,
        ImportIssueKind.compositionInvalid => issueComposition(i.value ?? ''),
        ImportIssueKind.numberInvalid => issueNumber(i.field == null ? '' : importField(i.field!), i.value ?? ''),
        ImportIssueKind.colorInvalid => issueColor(i.value ?? ''),
        ImportIssueKind.duplicateCode => issueDuplicate(i.value ?? ''),
      };
}

/// Pastille de disponibilité, couleurs constantes dans toute l'app (DESIGN.md).
class AvailabilityPill extends StatelessWidget {
  const AvailabilityPill({super.key, required this.status, this.leadTimeWeeks, this.stockM});

  /// null = disponibilité masquée par le fournisseur.
  final AvailabilityStatus? status;
  final int? leadTimeWeeks;

  /// Quantité exacte, quand le fournisseur l'expose.
  final String? stockM;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final s = status;
    final (fg, bg) = switch (s) {
      AvailabilityStatus.available => (FxColors.success, FxColors.successBg),
      AvailabilityStatus.low => (FxColors.warning, FxColors.warningBg),
      AvailabilityStatus.onOrder => (FxColors.slate, const Color(0xFFEEF1F4)),
      AvailabilityStatus.outOfStock => (FxColors.error, FxColors.errorBg),
      null => (FxColors.inkSoft, FxColors.cloud),
    };
    final label = s == null ? l10n.statusHidden : l10n.status(s, leadTimeWeeks: leadTimeWeeks);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(999)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 7, height: 7, decoration: BoxDecoration(color: fg, shape: BoxShape.circle)),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              stockM == null ? label : '$label · $stockM',
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: fg, fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
