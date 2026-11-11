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

class StudioModel {
  const StudioModel({
    required this.id,
    required this.collectionId,
    required this.name,
    required this.productType,
    this.reference,
    this.wastePct = kDefaultWastePct,
    this.colorways = const [],
  });

  factory StudioModel.fromJson(Map<String, dynamic> json) => StudioModel(
        id: json['id'] as String,
        collectionId: json['collection_id'] as String,
        name: json['name'] as String,
        reference: json['reference'] as String?,
        productType: ProductType.parse(json['product_type'] as String?),
        wastePct: (json['waste_pct'] as num?)?.toDouble() ?? kDefaultWastePct,
        colorways: [
          for (final c in (json['colorways'] as List<dynamic>? ?? const []).cast<Map<String, dynamic>>()) Colorway.fromJson(c),
        ]..sort((a, b) => a.position != b.position ? a.position.compareTo(b.position) : a.id.compareTo(b.id)),
      );

  static const selectColumns = 'id, collection_id, name, reference, product_type, waste_pct, '
      'colorways(id, name, color_hex, quantity, position, model_materials(id, material_id, role, consumption, position))';

  final String id;
  final String collectionId;
  final String name;
  final String? reference;
  final ProductType productType;

  /// Marge de perte en %.
  final double wastePct;
  final List<Colorway> colorways;

  /// Un seul coloris : pas de déclinaisons affichées.
  bool get hasVariants => colorways.length > 1;

  /// Matières distinctes utilisées, tous coloris confondus.
  Set<String> get materialIds => {for (final c in colorways) for (final l in c.lines) l.materialId};

  StudioModel copyWith({double? wastePct, List<Colorway>? colorways}) => StudioModel(
        id: id,
        collectionId: collectionId,
        name: name,
        reference: reference,
        productType: productType,
        wastePct: wastePct ?? this.wastePct,
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
