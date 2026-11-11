import '../../supplier/domain/availability.dart';
import 'material.dart';

/// Référence du catalogue publié d'un fournisseur, telle que la voit un atelier
/// (vue supplier_catalog : disponibilité selon la règle du fournisseur).
class CatalogReference {
  const CatalogReference({
    required this.id,
    required this.supplierOrgId,
    required this.supplierName,
    required this.code,
    required this.name,
    this.colorName,
    this.colorHex,
    this.specs = const TextileSpecs(),
    this.leadTimeWeeks,
    this.status,
    this.stockM,
  });

  factory CatalogReference.fromJson(Map<String, dynamic> json) => CatalogReference(
        id: json['id'] as String,
        supplierOrgId: json['supplier_org_id'] as String,
        supplierName: json['supplier_name'] as String,
        code: json['code'] as String,
        name: json['name'] as String,
        colorName: json['color_name'] as String?,
        colorHex: json['color_hex'] as String?,
        specs: TextileSpecs.fromJson(json),
        leadTimeWeeks: json['lead_time_weeks'] as int?,
        status: AvailabilityStatus.parse(json['availability_status'] as String?),
        stockM: (json['stock_m'] as num?)?.toDouble(),
      );

  static const selectColumns = 'id, supplier_org_id, supplier_name, code, name, color_name, color_hex, '
      'composition, weight_gsm, width_cm, weave, care, certifications, uses, lead_time_weeks, '
      'availability_status, stock_m';

  final String id;
  final String supplierOrgId;
  final String supplierName;
  final String code;
  final String name;
  final String? colorName;
  final String? colorHex;
  final TextileSpecs specs;
  final int? leadTimeWeeks;

  /// null = disponibilité masquée par le fournisseur.
  final AvailabilityStatus? status;

  /// Quantité exacte, seulement si le fournisseur l'expose.
  final double? stockM;
}

/// Proposition de rapprochement au scan (1 = code identique).
class ReferenceMatch {
  const ReferenceMatch(this.reference, this.score);

  final CatalogReference reference;
  final double score;
}
