/// Type de produit d'un modèle : il détermine les rôles de matières proposés.
enum ProductType {
  garment('garment', ['main', 'lining', 'interfacing', 'contrast', 'pocketing', 'rib']),
  footwear('footwear', ['upper', 'lining', 'sock_lining', 'insole', 'outsole', 'reinforcement']),
  leatherGoods('leather_goods', ['exterior', 'lining', 'gusset', 'strap', 'reinforcement']),
  accessory('accessory', ['main', 'lining', 'interfacing', 'trim']);

  const ProductType(this.code, this.roles);

  /// Valeur en base.
  final String code;

  /// Rôles intégrés, dans l'ordre proposé.
  final List<String> roles;

  static ProductType parse(String? v) => values.firstWhere((t) => t.code == v, orElse: () => garment);
}

/// Tous les rôles intégrés (codes traduits à l'affichage) ; les autres sont des rôles libres.
final Set<String> builtInRoles = {for (final t in ProductType.values) ...t.roles};

/// Marge de perte par défaut d'un nouveau modèle (en %).
const kDefaultWastePct = 8.0;

class StudioCollection {
  const StudioCollection({required this.id, required this.name, this.modelCount = 0, this.updatedAt});

  factory StudioCollection.fromJson(Map<String, dynamic> json) {
    final models = json['models'];
    return StudioCollection(
      id: json['id'] as String,
      name: json['name'] as String,
      modelCount: models is List && models.isNotEmpty ? (models.first['count'] as int? ?? 0) : 0,
      updatedAt: json['updated_at'] == null ? null : DateTime.parse(json['updated_at'] as String).toLocal(),
    );
  }

  static const selectColumns = 'id, name, updated_at, models(count)';

  final String id;
  final String name;
  final int modelCount;
  final DateTime? updatedAt;
}

/// Ligne de nomenclature : une matière d'un coloris, avec son rôle et sa consommation par pièce.
class BomLine {
  const BomLine({
    required this.id,
    required this.materialId,
    required this.role,
    this.consumption = 0,
    this.position = 0,
    this.protoLossPct = kDefaultProtoLossPct,
  });

  factory BomLine.fromJson(Map<String, dynamic> json) => BomLine(
        id: json['id'] as String,
        materialId: json['material_id'] as String,
        role: json['role'] as String,
        consumption: (json['consumption'] as num?)?.toDouble() ?? 0,
        position: json['position'] as int? ?? 0,
        protoLossPct: (json['proto_loss_pct'] as num?)?.toDouble() ?? kDefaultProtoLossPct,
      );

  final String id;
  final String materialId;
  final String role;

  /// Mètres par pièce (taille de base quand le modèle a une grille).
  final double consumption;
  final int position;

  /// Perte de prototypage de la ligne, en % (tests de colle, tests matière, sublimation…).
  final double protoLossPct;

  BomLine copyWith({double? consumption, String? role, double? protoLossPct}) => BomLine(
        id: id,
        materialId: materialId,
        role: role ?? this.role,
        consumption: consumption ?? this.consumption,
        position: position,
        protoLossPct: protoLossPct ?? this.protoLossPct,
      );
}

/// Grille de tailles : fournie par Filyxa ([code]) ou créée par l'atelier ([name]).
class SizeChart {
  const SizeChart({required this.id, required this.sizes, this.orgId, this.code, this.name});

  factory SizeChart.fromJson(Map<String, dynamic> json) => SizeChart(
        id: json['id'] as String,
        orgId: json['org_id'] as String?,
        code: json['code'] as String?,
        name: json['name'] as String?,
        sizes: (json['sizes'] as List<dynamic>).cast<String>(),
      );

  static const selectColumns = 'id, org_id, code, name, sizes, position';

  final String id;
  final String? orgId;
  final String? code;
  final String? name;
  final List<String> sizes;

  bool get builtIn => orgId == null;
}

/// Tailles saisies « XS, S, M » : nettoyées, sans vide.
List<String> parseSizes(String text) =>
    [for (final s in text.split(RegExp(r'[,;\n]'))) if (s.trim().isNotEmpty) s.trim()];

class Colorway {
  const Colorway({
    required this.id,
    this.name,
    this.colorHex,
    this.quantity = 0,
    this.position = 0,
    this.lines = const [],
    this.sizeQuantities = const {},
  });

  factory Colorway.fromJson(Map<String, dynamic> json) => Colorway(
        id: json['id'] as String,
        name: json['name'] as String?,
        colorHex: json['color_hex'] as String?,
        quantity: json['quantity'] as int? ?? 0,
        position: json['position'] as int? ?? 0,
        sizeQuantities: {
          for (final q in (json['colorway_size_quantities'] as List<dynamic>? ?? const []).cast<Map<String, dynamic>>())
            q['size'] as String: q['quantity'] as int? ?? 0,
        },
        lines: [
          for (final l in (json['model_materials'] as List<dynamic>? ?? const []).cast<Map<String, dynamic>>()) BomLine.fromJson(l),
        ]..sort((a, b) => a.position != b.position ? a.position.compareTo(b.position) : a.id.compareTo(b.id)),
      );

  final String id;

  /// null pour le coloris par défaut non nommé.
  final String? name;
  final String? colorHex;

  /// Pièces prévues (somme des tailles quand le modèle a une grille).
  final int quantity;
  final int position;
  final List<BomLine> lines;

  /// Quantités par taille (modèle avec grille).
  final Map<String, int> sizeQuantities;

  Colorway copyWith({int? quantity, List<BomLine>? lines, Map<String, int>? sizeQuantities}) => Colorway(
        id: id,
        name: name,
        colorHex: colorHex,
        quantity: quantity ?? this.quantity,
        sizeQuantities: sizeQuantities ?? this.sizeQuantities,
        position: position,
        lines: lines ?? this.lines,
      );
}

/// Perte de prototypage par défaut (%).
const kDefaultProtoLossPct = 25.0;

/// Écart de consommation par taille, par défaut (%).
const kDefaultGradePct = 4.0;

/// Avancement d'un modèle (offre Pro). On revient en arrière, sauf depuis Livré.
enum ModelStatus {
  idea('idea'),
  prototype('prototype'),
  validated('validated'),
  inProduction('in_production'),
  delivered('delivered'),
  abandoned('abandoned');

  const ModelStatus(this.code);

  final String code;

  static ModelStatus parse(String? code) =>
      ModelStatus.values.firstWhere((s) => s.code == code, orElse: () => ModelStatus.idea);

  /// Prototype, Validé et En production déclenchent les alertes de stock et de fiche fournisseur.
  bool get isActive => this == prototype || this == validated || this == inProduction;

  /// Rang d'avancement ; Abandonné est hors échelle.
  int? get rank => switch (this) {
        idea => 0,
        prototype => 1,
        validated => 2,
        inProduction => 3,
        delivered => 4,
        abandoned => null,
      };

  /// Étapes qui reçoivent une échéance (date à laquelle le modèle doit les atteindre).
  static const stages = [prototype, validated, inProduction, delivered];

  /// Statuts vers lesquels on peut passer depuis celui-ci.
  List<ModelStatus> get nextChoices =>
      this == delivered ? const [] : [for (final s in ModelStatus.values) if (s != this) s];
}

class StudioModel {
  const StudioModel({
    required this.id,
    required this.collectionId,
    required this.name,
    required this.productType,
    this.reference,
    this.wastePct = kDefaultWastePct,
    this.status = ModelStatus.idea,
    this.deadlines = const {},
    this.sizeChartId,
    this.sizes = const [],
    this.baseSize,
    this.gradePct = kDefaultGradePct,
    this.sizeGrades = const {},
    this.prototypeCount = 1,
    this.colorways = const [],
  });

  factory StudioModel.fromJson(Map<String, dynamic> json) => StudioModel(
        id: json['id'] as String,
        collectionId: json['collection_id'] as String,
        name: json['name'] as String,
        reference: json['reference'] as String?,
        productType: ProductType.parse(json['product_type'] as String?),
        wastePct: (json['waste_pct'] as num?)?.toDouble() ?? kDefaultWastePct,
        status: ModelStatus.parse(json['status'] as String?),
        sizeChartId: json['size_chart_id'] as String?,
        sizes: ((json['size_charts'] as Map<String, dynamic>?)?['sizes'] as List<dynamic>? ?? const []).cast<String>(),
        baseSize: json['base_size'] as String?,
        prototypeCount: json['prototype_count'] as int? ?? 1,
        gradePct: (json['grade_pct'] as num?)?.toDouble() ?? kDefaultGradePct,
        sizeGrades: {
          for (final g in (json['model_size_grades'] as List<dynamic>? ?? const []).cast<Map<String, dynamic>>())
            g['size'] as String: (g['grade_pct'] as num).toDouble(),
        },
        deadlines: {
          for (final d in (json['model_deadlines'] as List<dynamic>? ?? const []).cast<Map<String, dynamic>>())
            ModelStatus.parse(d['stage'] as String?): DateTime.parse(d['due_date'] as String),
        },
        colorways: [
          for (final c in (json['colorways'] as List<dynamic>? ?? const []).cast<Map<String, dynamic>>()) Colorway.fromJson(c),
        ]..sort((a, b) => a.position != b.position ? a.position.compareTo(b.position) : a.id.compareTo(b.id)),
      );

  static const selectColumns = 'id, collection_id, name, reference, product_type, waste_pct, status, prototype_count, model_deadlines(stage, due_date), '
      'size_chart_id, base_size, grade_pct, size_charts(sizes), model_size_grades(size, grade_pct), colorways(id, name, color_hex, quantity, position, colorway_size_quantities(size, quantity), model_materials(id, material_id, role, consumption, position, proto_loss_pct))';

  final String id;
  final String collectionId;
  final String name;
  final String? reference;
  final ProductType productType;

  /// Marge de perte en %.
  final double wastePct;
  final ModelStatus status;

  /// Échéance de chaque étape (date, sans heure).
  final Map<ModelStatus, DateTime> deadlines;

  /// Grille de tailles ; null : quantité par coloris, comme en V1.
  final String? sizeChartId;

  /// Tailles de la grille, dans l'ordre (vide sans grille).
  final List<String> sizes;

  /// Taille de base choisie ; null : la taille du milieu de la grille.
  final String? baseSize;

  /// Écart de consommation par taille d'écart avec la base, en %.
  final double gradePct;

  /// Écarts propres à une taille (écart total par rapport à la base, en %).
  final Map<String, double> sizeGrades;

  /// Nombre de prototypes (taille de base, premier coloris).
  final int prototypeCount;
  final List<Colorway> colorways;

  /// Taille de base effective.
  String? get effectiveBaseSize =>
      sizes.isEmpty ? null : (baseSize != null && sizes.contains(baseSize) ? baseSize : sizes[(sizes.length - 1) ~/ 2]);

  /// Écart de consommation d'une taille par rapport à la base, en %.
  double sizeGrade(String size) {
    final own = sizeGrades[size];
    if (own != null) return own;
    final base = effectiveBaseSize;
    if (base == null) return 0;
    return (sizes.indexOf(size) - sizes.indexOf(base)) * gradePct;
  }

  /// Le besoin tient compte des tailles (grille choisie).
  bool get graded => sizeChartId != null && sizes.isNotEmpty;

  /// Étape déjà atteinte (ou dépassée) par le modèle.
  bool reached(ModelStatus stage) => status == ModelStatus.delivered || (status.rank ?? -1) >= (stage.rank ?? 99);

  /// Échéance dépassée : date passée, étape non atteinte, modèle ni livré ni abandonné.
  bool isOverdue(ModelStatus stage, DateTime today) {
    final due = deadlines[stage];
    if (due == null || status == ModelStatus.abandoned || reached(stage)) return false;
    return due.isBefore(DateTime(today.year, today.month, today.day));
  }

  /// Prochaine échéance à tenir : la première étape non atteinte qui a une date.
  ({ModelStatus stage, DateTime date})? get nextDeadline {
    if (status == ModelStatus.abandoned || status == ModelStatus.delivered) return null;
    for (final stage in ModelStatus.stages) {
      final due = deadlines[stage];
      if (due != null && !reached(stage)) return (stage: stage, date: due);
    }
    return null;
  }

  /// Un seul coloris : pas de déclinaisons affichées.
  bool get hasVariants => colorways.length > 1;

  /// Matières distinctes utilisées, tous coloris confondus.
  Set<String> get materialIds => {for (final c in colorways) for (final l in c.lines) l.materialId};

  StudioModel copyWith({
    double? wastePct,
    ModelStatus? status,
    Map<ModelStatus, DateTime>? deadlines,
    String? baseSize,
    double? gradePct,
    Map<String, double>? sizeGrades,
    int? prototypeCount,
    List<Colorway>? colorways,
  }) =>
      StudioModel(
        id: id,
        collectionId: collectionId,
        name: name,
        reference: reference,
        productType: productType,
        wastePct: wastePct ?? this.wastePct,
        status: status ?? this.status,
        deadlines: deadlines ?? this.deadlines,
        sizeChartId: sizeChartId,
        sizes: sizes,
        baseSize: baseSize ?? this.baseSize,
        gradePct: gradePct ?? this.gradePct,
        sizeGrades: sizeGrades ?? this.sizeGrades,
        prototypeCount: prototypeCount ?? this.prototypeCount,
        colorways: colorways ?? this.colorways,
      );
}

/// Besoin d'une ligne : consommation × quantité × (1 + marge).
double lineRequirement(double consumption, int quantity, double wastePct) =>
    consumption * quantity * (1 + wastePct / 100);

/// Besoin d'une ligne pour un coloris : par taille avec la gradation si le modèle a une grille,
/// sinon consommation × quantité × (1 + marge), comme en V1.
double colorwayLineRequirement(StudioModel model, Colorway colorway, BomLine line) {
  if (!model.graded) return lineRequirement(line.consumption, colorway.quantity, model.wastePct);
  var total = 0.0;
  for (final size in model.sizes) {
    total += sizeRequirement(model, colorway, line, size);
  }
  return total;
}

/// Besoin d'une ligne pour une taille : consommation de base × (1 + écart) × quantité × (1 + marge).
double sizeRequirement(StudioModel model, Colorway colorway, BomLine line, String size) =>
    line.consumption * (1 + model.sizeGrade(size) / 100) * (colorway.sizeQuantities[size] ?? 0) * (1 + model.wastePct / 100);

/// Besoin total par matière, tous coloris confondus (mètres), dans l'ordre d'apparition.
Map<String, double> requirementsByMaterial(StudioModel model) {
  final totals = <String, double>{};
  for (final c in model.colorways) {
    for (final l in c.lines) {
      totals[l.materialId] = (totals[l.materialId] ?? 0) + colorwayLineRequirement(model, c, l);
    }
  }
  return totals;
}

/// Détail du besoin d'une matière : par coloris, puis par taille (mètres).
Map<String, Map<String, double>> requirementDetail(StudioModel model, String materialId) {
  final detail = <String, Map<String, double>>{};
  for (final c in model.colorways) {
    for (final l in c.lines.where((l) => l.materialId == materialId)) {
      final row = detail.putIfAbsent(c.id, () => {});
      for (final size in model.sizes) {
        row[size] = (row[size] ?? 0) + sizeRequirement(model, c, l, size);
      }
    }
  }
  return detail;
}

/// Besoin de prototypage par matière (mètres) : nombre de prototypes × consommation de base
/// × (1 + perte de prototypage), sur les lignes du premier coloris.
Map<String, double> prototypeRequirements(StudioModel model) {
  final totals = <String, double>{};
  if (model.colorways.isEmpty) return totals;
  for (final l in model.colorways.first.lines) {
    totals[l.materialId] = (totals[l.materialId] ?? 0) + model.prototypeCount * l.consumption * (1 + l.protoLossPct / 100);
  }
  return totals;
}
