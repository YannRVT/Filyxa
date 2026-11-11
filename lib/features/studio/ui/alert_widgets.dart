import 'package:material_ui/material_ui.dart';

import '../../../app/theme.dart';
import '../../../l10n/l10n.dart';
import '../../library/domain/catalog.dart';
import '../../library/domain/material.dart';
import '../domain/alerts.dart';
import '../domain/studio.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../library/data/materials_repository.dart';
import 'studio_widgets.dart';

/// Textes des alertes, composés à partir des valeurs en cause.
extension AlertTexts on AppLocalizations {
  String alertFamilyLabel(AlertFamily f) => switch (f) {
    AlertFamily.care => alertFamilyCare,
    AlertFamily.technical => alertFamilyTechnical,
    AlertFamily.certification => alertFamilyCertification,
    AlertFamily.stock => alertFamilyStock,
  };

  /// « Doublure « Satin lourd » » (+ grammage si demandé).
  String _subject(AlertSubject s, {bool gsm = false}) {
    final name = s.role == null ? alertQuoted(s.name) : '${roleText(s.role!)} ${alertQuoted(s.name)}';
    return gsm && s.gsm != null ? '$name (${s.gsm} g/m²)' : name;
  }

  String _subjects(List<AlertSubject> list, {bool gsm = false}) => list.map((s) => _subject(s, gsm: gsm)).join(', ');

  /// « Doublure « Satin » : Ne pas laver, Nettoyage à sec (P). Tissu principal « Sergé » : Lavage 30 °C »
  String _careDetails(List<AlertSubject> list, Set<CareFamily> families, String lang) => [
    for (final s in list)
      '${_subject(s)} : ${sortCare(s.care).where((c) => families.contains(careCode(c)?.family)).map((c) => careCode(c)!.label(lang)).join(', ')}',
  ].join('. ');

  String _iron(int temp) => temp == 0 ? alertNoIron : '$temp °C';

  String _m(Object? v, String lang) => stockMeters(formatNumber((v as num?)?.toDouble() ?? 0, lang, decimals: 1));

  String alertTitle(StudioAlert a) => switch (a.kind) {
    AlertKind.noMain => alertNoMainTitle,
    AlertKind.liningHeavier => alertLiningHeavierTitle,
    AlertKind.stretchRigidLining => alertStretchTitle,
    AlertKind.interfacingHeavier => alertInterfacingHeavierTitle,
    AlertKind.fusingRisky => alertFusingTitle,
    AlertKind.consumptionMissing => alertConsumptionTitle,
    AlertKind.careMachineConflict => alertCareConflictTitle,
    AlertKind.washTempLimited => alertWashTitle(a.values['temp'] as int),
    AlertKind.ironLimited => alertIronTitle(_iron(a.values['temp'] as int)),
    AlertKind.tumbleConflict => alertTumbleTitle,
    AlertKind.certificationGap => alertCertTitle(a.values['certification'] as String),
    AlertKind.referenceRetired => alertRetiredTitle,
    AlertKind.stockAtelierShort => alertAtelierShortTitle,
    AlertKind.stockSupplierCovered => alertCoveredTitle,
    AlertKind.stockSupplierShort => alertSupplierShortTitle,
    AlertKind.stockSupplierLow => alertSupplierLowTitle,
    AlertKind.stockSupplierOnOrder => alertOnOrderTitle,
    AlertKind.stockSupplierOut => alertOutTitle,
    AlertKind.stockSupplierHidden => alertHiddenTitle,
  };

  String alertBody(StudioAlert a, String lang) {
    final v = a.values;
    final material = a.subjects.isEmpty ? '' : _subjects(a.subjects);
    final need = _m(v['need'], lang);
    final atelier = _m(v['atelier'], lang);
    final missing = _m(((v['need'] as num?) ?? 0) - ((v['atelier'] as num?) ?? 0), lang);
    const washFamilies = {CareFamily.wash, CareFamily.professional};
    return switch (a.kind) {
      AlertKind.noMain => alertNoMainBody,
      AlertKind.liningHeavier => alertLiningHeavierBody(
        _subjects(a.subjects, gsm: true),
        _subjects(a.others, gsm: true),
      ),
      AlertKind.stretchRigidLining => alertStretchBody(_subjects(a.others), _subjects(a.subjects)),
      AlertKind.interfacingHeavier => alertInterfacingHeavierBody(
        _subjects(a.subjects, gsm: true),
        _subjects(a.others, gsm: true),
      ),
      AlertKind.fusingRisky => alertFusingBody(_subjects(a.subjects), _iron(v['temp'] as int)),
      AlertKind.consumptionMissing => alertConsumptionBody(_subjects(a.subjects)),
      AlertKind.careMachineConflict => alertCareConflictBody(
        _careDetails([...a.subjects, ...a.others], washFamilies, lang),
      ),
      AlertKind.washTempLimited => alertLimitBody(_careDetails([...a.subjects, ...a.others], washFamilies, lang)),
      AlertKind.ironLimited => alertLimitBody(_careDetails([...a.subjects, ...a.others], {CareFamily.iron}, lang)),
      AlertKind.tumbleConflict => alertLimitBody(_careDetails([...a.subjects, ...a.others], {CareFamily.dry}, lang)),
      AlertKind.certificationGap => alertCertBody(
        _subjects(a.others),
        v['certification'] as String,
        _subjects(a.subjects),
      ),
      AlertKind.referenceRetired => alertRetiredBody(material, need, atelier),
      AlertKind.stockAtelierShort => alertAtelierShortBody(material, need, atelier, missing),
      AlertKind.stockSupplierCovered =>
        v['supplier'] == null
            ? alertCoveredBody(material, need, atelier, missing)
            : alertCoveredBodyExact(material, need, atelier, missing, _m(v['supplier'], lang)),
      AlertKind.stockSupplierShort => alertSupplierShortBody(material, missing, atelier, _m(v['supplier'], lang)),
      AlertKind.stockSupplierLow => alertSupplierLowBody(material, missing, atelier),
      AlertKind.stockSupplierOnOrder => alertOnOrderBody(material, missing, atelier, (v['leadTime'] as int?) ?? 0),
      AlertKind.stockSupplierOut => alertOutBody(material, missing, atelier),
      AlertKind.stockSupplierHidden => alertHiddenBody(material, missing, atelier),
    };
  }
}

(IconData, Color, Color) alertStyle(AlertLevel level) => switch (level) {
  AlertLevel.critical => (Icons.error_outline, FxColors.error, FxColors.errorBg),
  AlertLevel.warning => (Icons.warning_amber_rounded, FxColors.warning, FxColors.warningBg),
  AlertLevel.info => (Icons.info_outline, FxColors.info, FxColors.infoBg),
};

/// Alertes d'un modèle : gravité, famille, coloris concerné, puis l'explication chiffrée.
class AlertsPanel extends StatelessWidget {
  const AlertsPanel({super.key, required this.alerts});

  final List<({Colorway? colorway, StudioAlert alert})> alerts;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final lang = Localizations.localeOf(context).languageCode;
    final text = Theme.of(context).textTheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(FxSpace.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Text(l10n.alertsTitle, style: text.titleMedium),
                const SizedBox(width: FxSpace.sm),
                if (alerts.isNotEmpty)
                  Text(l10n.alertsCount(alerts.length), style: text.bodySmall?.copyWith(color: FxColors.inkSoft)),
              ],
            ),
            const SizedBox(height: FxSpace.sm),
            if (alerts.isEmpty)
              Row(
                children: [
                  const Icon(Icons.check_circle_outline, color: FxColors.success, size: 20),
                  const SizedBox(width: FxSpace.sm),
                  Expanded(child: Text(l10n.alertsNone, style: text.bodyMedium)),
                ],
              ),
            for (final (:colorway, :alert) in alerts)
              Builder(
                builder: (context) {
                  final (icon, fg, bg) = alertStyle(alert.level);
                  final tags = [
                    l10n.alertFamilyLabel(alert.family),
                    if (colorway != null) l10n.colorwayName(colorway, colorway.position),
                  ];
                  return Container(
                    margin: const EdgeInsets.only(bottom: FxSpace.sm),
                    padding: const EdgeInsets.all(FxSpace.sm),
                    decoration: BoxDecoration(
                      color: bg,
                      borderRadius: BorderRadius.circular(FxRadius.sm),
                      border: Border(left: BorderSide(color: fg, width: 3)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(icon, color: fg, size: 20),
                        const SizedBox(width: FxSpace.sm),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                tags.join(' · ').toUpperCase(),
                                style: text.labelSmall?.copyWith(color: fg, letterSpacing: 0.5),
                              ),
                              Text(l10n.alertTitle(alert), style: text.titleSmall),
                              const SizedBox(height: 2),
                              Text(l10n.alertBody(alert, lang), style: text.bodySmall),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}

/// Alertes d'un modèle avec les données du moment (matières, références publiées).
/// Tant que les références ne sont pas chargées, les alertes de stock sont tenues en attente
/// (une référence absente passerait pour retirée).
List<({Colorway? colorway, StudioAlert alert})> watchModelAlerts(WidgetRef ref, StudioModel model) {
  final materials = {for (final m in ref.watch(materialsProvider).value ?? const <MaterialItem>[]) m.id: m};
  final refs = ref.watch(linkedReferencesProvider);
  return [
    for (final e in modelAlerts(model, materials, refs.value ?? const {}))
      if (refs.hasValue || e.alert.family != AlertFamily.stock) e,
  ];
}
