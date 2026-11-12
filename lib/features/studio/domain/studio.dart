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
  const BomLine({required this.id, required this.materialId, required this.role, this.consumption = 0, this.position = 0});

  factory BomLine.fromJson(Map<String, dynamic> json) => BomLine(
        id: json['id'] as String,
        materialId: json['material_id'] as String,
        role: json['role'] as String,
        consumption: (json['consumption'] as num?)?.toDouble() ?? 0,
        position: json['position'] as int? ?? 0,
      );

  final String id;
  final String materialId;
  final String role;

  /// Mètres par pièce.
  final double consumption;
  final int position;

  BomLine copyWith({double? consumption, String? role}) =>
      BomLine(id: id, materialId: materialId, role: role ?? this.role, consumption: consumption ?? this.consumption, position: position);
}

class Colorway {
  const Colorway({required this.id, this.name, this.colorHex, this.quantity = 0, this.position = 0, this.lines = const []});

  factory Colorway.fromJson(Map<String, dynamic> json) => Colorway(
        id: json['id'] as String,
        name: json['name'] as String?,
        colorHex: json['color_hex'] as String?,
        quantity: json['quantity'] as int? ?? 0,
        position: json['position'] as int? ?? 0,
        lines: [
          for (final l in (json['model_materials'] as List<dynamic>? ?? const []).cast<Map<String, dynamic>>()) BomLine.fromJson(l),
        ]..sort((a, b) => a.position != b.position ? a.position.compareTo(b.position) : a.id.compareTo(b.id)),
      );

  final String id;

  /// null pour le coloris par défaut non nommé.
  final String? name;
  final String? colorHex;

  /// Pièces prévues.
  final int quantity;
  final int position;
  final List<BomLine> lines;

  Colorway copyWith({int? quantity, List<BomLine>? lines}) => Colorway(
        id: id,
        name: name,
        colorHex: colorHex,
        quantity: quantity ?? this.quantity,
        position: position,
        lines: lines ?? this.lines,
      );
}

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
        deadlines: {
          for (final d in (json['model_deadlines'] as List<dynamic>? ?? const []).cast<Map<String, dynamic>>())
            ModelStatus.parse(d['stage'] as String?): DateTime.parse(d['due_date'] as String),
        },
        colorways: [
          for (final c in (json['colorways'] as List<dynamic>? ?? const []).cast<Map<String, dynamic>>()) Colorway.fromJson(c),
        ]..sort((a, b) => a.position != b.position ? a.position.compareTo(b.position) : a.id.compareTo(b.id)),
      );

  static const selectColumns = 'id, collection_id, name, reference, product_type, waste_pct, status, model_deadlines(stage, due_date), '
      'colorways(id, name, color_hex, quantity, position, model_materials(id, material_id, role, consumption, position))';

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
  final List<Colorway> colorways;

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

  StudioModel copyWith({double? wastePct, ModelStatus? status, Map<ModelStatus, DateTime>? deadlines, List<Colorway>? colorways}) =>
      StudioModel(
        id: id,
        collectionId: collectionId,
        name: name,
        reference: reference,
        productType: productType,
        wastePct: wastePct ?? this.wastePct,
        status: status ?? this.status,
        deadlines: deadlines ?? this.deadlines,
        colorways: colorways ?? this.colorways,
      );
}

/// Besoin d'une ligne : consommation × quantité × (1 + marge).
double lineRequirement(double consumption, int quantity, double wastePct) =>
    consumption * quantity * (1 + wastePct / 100);

/// Besoin total par matière, tous coloris confondus (mètres), dans l'ordre d'apparition.
Map<String, double> requirementsByMaterial(StudioModel model) {
  final totals = <String, double>{};
  for (final c in model.colorways) {
    for (final l in c.lines) {
      totals[l.materialId] = (totals[l.materialId] ?? 0) + lineRequirement(l.consumption, c.quantity, model.wastePct);
    }
  }
  return totals;
}
