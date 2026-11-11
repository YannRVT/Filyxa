import '../../library/domain/catalog_reference.dart';
import '../../library/domain/material.dart';
import '../../supplier/domain/availability.dart';
import 'studio.dart';

/// Les quatre familles d'alertes du Studio.
enum AlertFamily { care, technical, certification, stock }

/// Gravité, de la plus forte à la plus faible (ordre d'affichage).
enum AlertLevel { critical, warning, info }

enum AlertKind {
  // Technique
  noMain,
  liningHeavier,
  stretchRigidLining,
  interfacingHeavier,
  fusingRisky,
  consumptionMissing,
  // Entretien
  careMachineConflict,
  washTempLimited,
  ironLimited,
  tumbleConflict,
  // Certifications
  certificationGap,
  // Stock
  referenceRetired,
  stockAtelierShort,
  stockSupplierCovered,
  stockSupplierShort,
  stockSupplierLow,
  stockSupplierOnOrder,
  stockSupplierOut,
  stockSupplierHidden,
}

/// Matière citée par une alerte, avec son rôle dans le modèle.
class AlertSubject {
  const AlertSubject({required this.materialId, required this.name, this.role, this.care = const [], this.gsm});

  final String materialId;
  final String name;

  /// Code de rôle intégré ou rôle libre (null pour les alertes de stock, tous rôles confondus).
  final String? role;

  /// Codes d'entretien ISO 3758 cités par les alertes d'entretien.
  final List<String> care;
  final int? gsm;

  @override
  bool operator ==(Object other) => other is AlertSubject && other.materialId == materialId && other.role == role;

  @override
  int get hashCode => Object.hash(materialId, role);
}

/// Alerte déterministe : même modèle → mêmes alertes, dans le même ordre.
/// Les textes sont composés à l'affichage, à partir des valeurs en cause.
class StudioAlert {
  const StudioAlert(this.kind, {this.subjects = const [], this.others = const [], this.values = const {}});

  final AlertKind kind;

  /// Matières en cause.
  final List<AlertSubject> subjects;

  /// Matières de comparaison (le tissu principal, les matières qui se lavent en machine…).
  final List<AlertSubject> others;

  /// Valeurs citées : temp, need, atelier, supplier, leadTime, certification.
  final Map<String, Object> values;

  AlertFamily get family => switch (kind) {
        AlertKind.noMain ||
        AlertKind.liningHeavier ||
        AlertKind.stretchRigidLining ||
        AlertKind.interfacingHeavier ||
        AlertKind.fusingRisky ||
        AlertKind.consumptionMissing =>
          AlertFamily.technical,
        AlertKind.careMachineConflict || AlertKind.washTempLimited || AlertKind.ironLimited || AlertKind.tumbleConflict =>
          AlertFamily.care,
        AlertKind.certificationGap => AlertFamily.certification,
        _ => AlertFamily.stock,
      };

  AlertLevel get level => switch (kind) {
        AlertKind.referenceRetired || AlertKind.stockSupplierOut => AlertLevel.critical,
        AlertKind.liningHeavier ||
        AlertKind.interfacingHeavier ||
        AlertKind.fusingRisky ||
        AlertKind.careMachineConflict ||
        AlertKind.stockAtelierShort ||
        AlertKind.stockSupplierShort ||
        AlertKind.stockSupplierLow ||
        AlertKind.stockSupplierOnOrder =>
          AlertLevel.warning,
        _ => AlertLevel.info,
      };

  @override
  String toString() => 'StudioAlert($kind, ${subjects.map((s) => s.name).join(', ')}, $values)';
}

/// Rôles qui jouent le « tissu principal », la doublure et l'entoilage selon le type de produit.
const mainRoles = {'main', 'upper', 'exterior'};
const liningRoles = {'lining', 'sock_lining'};
const interfacingRoles = {'interfacing'};

/// Fibres élastiques (codes ISO 2076).
const _stretchFibers = {'EL', 'ED'};

/// Température maximale de lavage en machine (°C) ; 0 = pas de lavage en machine ; null = non renseignée.
int? maxWashTemp(Iterable<String> care) {
  if (care.contains('no_wash') || care.contains('hand_wash')) return 0;
  if (care.contains('wash_60')) return 60;
  if (care.contains('wash_40')) return 40;
  if (care.contains('wash_30')) return 30;
  return null;
}

/// Température maximale de repassage (°C) ; 0 = ne pas repasser ; null = non renseignée.
int? maxIronTemp(Iterable<String> care) {
  if (care.contains('no_iron')) return 0;
  if (care.contains('iron_low')) return 110;
  if (care.contains('iron_medium')) return 150;
  if (care.contains('iron_high')) return 200;
  return null;
}

bool _isStretch(MaterialItem m) => m.specs.composition.any((f) => _stretchFibers.contains(f.fiber) && f.pct > 0);

/// Alertes d'un coloris : entretien, technique, certifications.
List<StudioAlert> colorwayAlerts(Colorway colorway, Map<String, MaterialItem> materials) {
  final items = [
    for (final l in colorway.lines)
      if (materials[l.materialId] case final m?) (line: l, material: m),
  ];
  if (items.isEmpty) return const [];

  AlertSubject subject(({BomLine line, MaterialItem material}) i) => AlertSubject(
        materialId: i.material.id,
        name: i.material.name,
        role: i.line.role,
        care: i.material.specs.care,
        gsm: i.material.specs.weightGsm,
      );

  final alerts = <StudioAlert>[];
  final mains = items.where((i) => mainRoles.contains(i.line.role)).toList();
  final linings = items.where((i) => liningRoles.contains(i.line.role)).toList();
  final interfacings = items.where((i) => interfacingRoles.contains(i.line.role)).toList();

  // Technique ---------------------------------------------------------------------------------
  if (mains.isEmpty) alerts.add(const StudioAlert(AlertKind.noMain));

  for (final main in mains) {
    final mainGsm = main.material.specs.weightGsm;
    for (final lining in linings) {
      final gsm = lining.material.specs.weightGsm;
      if (mainGsm != null && gsm != null && gsm > mainGsm) {
        alerts.add(StudioAlert(AlertKind.liningHeavier, subjects: [subject(lining)], others: [subject(main)]));
      }
      if (_isStretch(main.material) && !_isStretch(lining.material)) {
        alerts.add(StudioAlert(AlertKind.stretchRigidLining, subjects: [subject(lining)], others: [subject(main)]));
      }
    }
    for (final inter in interfacings) {
      final gsm = inter.material.specs.weightGsm;
      if (mainGsm != null && gsm != null && gsm > mainGsm) {
        alerts.add(StudioAlert(AlertKind.interfacingHeavier, subjects: [subject(inter)], others: [subject(main)]));
      }
    }
    // Le thermocollage se fait généralement entre 130 et 160 °C.
    final iron = maxIronTemp(main.material.specs.care);
    if (interfacings.isNotEmpty && iron != null && iron <= 110) {
      alerts.add(StudioAlert(
        AlertKind.fusingRisky,
        subjects: [subject(main)],
        others: [for (final i in interfacings) subject(i)],
        values: {'temp': iron},
      ));
    }
  }

  final noConsumption = [for (final i in items) if (i.line.consumption <= 0) subject(i)];
  if (noConsumption.isNotEmpty) alerts.add(StudioAlert(AlertKind.consumptionMissing, subjects: noConsumption));

  // Entretien : le produit fini suit le composant le plus fragile. -----------------------------
  final washes = [
    for (final i in items)
      if (maxWashTemp(i.material.specs.care) case final t?) (item: i, temp: t),
  ];
  final machine = washes.where((w) => w.temp > 0).toList();
  final notMachine = washes.where((w) => w.temp == 0).toList();
  if (machine.isNotEmpty && notMachine.isNotEmpty) {
    alerts.add(StudioAlert(
      AlertKind.careMachineConflict,
      subjects: [for (final w in notMachine) subject(w.item)],
      others: [for (final w in machine) subject(w.item)],
    ));
  } else if (machine.map((w) => w.temp).toSet().length > 1) {
    final lowest = machine.reduce((a, b) => a.temp <= b.temp ? a : b);
    alerts.add(StudioAlert(
      AlertKind.washTempLimited,
      subjects: [for (final w in machine) if (w.temp == lowest.temp) subject(w.item)],
      others: [for (final w in machine) if (w.temp != lowest.temp) subject(w.item)],
      values: {'temp': lowest.temp},
    ));
  }

  final irons = [
    for (final i in items)
      if (maxIronTemp(i.material.specs.care) case final t?) (item: i, temp: t),
  ];
  if (irons.map((w) => w.temp).toSet().length > 1) {
    final lowest = irons.reduce((a, b) => a.temp <= b.temp ? a : b);
    alerts.add(StudioAlert(
      AlertKind.ironLimited,
      subjects: [for (final w in irons) if (w.temp == lowest.temp) subject(w.item)],
      others: [for (final w in irons) if (w.temp != lowest.temp) subject(w.item)],
      values: {'temp': lowest.temp},
    ));
  }

  final noTumble = [for (final i in items) if (i.material.specs.care.contains('no_tumble')) subject(i)];
  final tumble = [
    for (final i in items)
      if (i.material.specs.care.any((c) => c == 'tumble_low' || c == 'tumble_normal')) subject(i),
  ];
  if (noTumble.isNotEmpty && tumble.isNotEmpty) {
    alerts.add(StudioAlert(AlertKind.tumbleConflict, subjects: noTumble, others: tumble));
  }

  // Certifications : une certification du tissu principal ne vaut que si toutes les matières l'ont.
  final mainCerts = {for (final m in mains) ...m.material.specs.certifications}.toList()..sort();
  for (final cert in mainCerts) {
    final missing = [for (final i in items) if (!i.material.specs.certifications.contains(cert)) subject(i)];
    if (missing.isNotEmpty) {
      alerts.add(StudioAlert(
        AlertKind.certificationGap,
        subjects: missing,
        others: [for (final m in mains) if (m.material.specs.certifications.contains(cert)) subject(m)],
        values: {'certification': cert},
      ));
    }
  }
  return alerts;
}

/// Alertes de stock du modèle : besoin total comparé au stock atelier, puis au stock fournisseur.
/// [references] : références publiées par identifiant (une référence absente a été retirée).
List<StudioAlert> stockAlerts(StudioModel model, Map<String, MaterialItem> materials, Map<String, CatalogReference> references) {
  final alerts = <StudioAlert>[];
  for (final MapEntry(key: id, value: need) in requirementsByMaterial(model).entries) {
    final m = materials[id];
    if (m == null || need <= 0) continue;
    final atelier = m.atelierStockM ?? 0;
    final s = AlertSubject(materialId: m.id, name: m.name);
    final values = <String, Object>{'need': need, 'atelier': atelier};

    if (m.isLinked && references[m.supplierReferenceId] == null) {
      alerts.add(StudioAlert(AlertKind.referenceRetired, subjects: [s], values: values));
      continue;
    }
    if (atelier >= need) continue;
    final short = need - atelier;
    if (!m.isLinked) {
      alerts.add(StudioAlert(AlertKind.stockAtelierShort, subjects: [s], values: values));
      continue;
    }
    final ref = references[m.supplierReferenceId]!;
    final exact = ref.stockM;
    if (exact != null) values['supplier'] = exact;
    if (ref.leadTimeWeeks != null) values['leadTime'] = ref.leadTimeWeeks!;
    final kind = switch (ref.status) {
      null => AlertKind.stockSupplierHidden,
      AvailabilityStatus.outOfStock => AlertKind.stockSupplierOut,
      AvailabilityStatus.onOrder => AlertKind.stockSupplierOnOrder,
      // Quantité exacte publiée : on compare au complément ; sinon on s'en tient au palier.
      AvailabilityStatus.low || AvailabilityStatus.available when exact != null =>
        exact >= short ? AlertKind.stockSupplierCovered : AlertKind.stockSupplierShort,
      AvailabilityStatus.low => AlertKind.stockSupplierLow,
      AvailabilityStatus.available => AlertKind.stockSupplierCovered,
    };
    alerts.add(StudioAlert(kind, subjects: [s], values: values));
  }
  return alerts;
}

/// Toutes les alertes d'un modèle, coloris par coloris puis stock, triées par gravité (ordre stable).
List<({Colorway? colorway, StudioAlert alert})> modelAlerts(
  StudioModel model,
  Map<String, MaterialItem> materials,
  Map<String, CatalogReference> references,
) {
  final all = [
    for (final c in model.colorways)
      for (final a in colorwayAlerts(c, materials)) (colorway: model.hasVariants ? c : null, alert: a),
    for (final a in stockAlerts(model, materials, references)) (colorway: null, alert: a),
  ];
  return [
    for (final level in AlertLevel.values) ...all.where((e) => e.alert.level == level),
  ];
}
