import '../../library/domain/material.dart';
import 'availability.dart';

/// Réglages de disponibilité d'un fournisseur.
class SupplierSettings {
  const SupplierSettings({
    this.mode = AvailabilityMode.tiers,
    this.lowStockThresholdM = kDefaultLowStockThresholdM,
    this.importMapping = const {},
  });

  factory SupplierSettings.fromJson(Map<String, dynamic>? json) => json == null
      ? const SupplierSettings()
      : SupplierSettings(
          mode: AvailabilityMode.parse(json['availability_mode'] as String?) ?? AvailabilityMode.tiers,
          lowStockThresholdM: (json['low_stock_threshold_m'] as num?)?.toDouble() ?? kDefaultLowStockThresholdM,
          importMapping: (json['import_mapping'] as Map<String, dynamic>? ?? const {}).cast<String, dynamic>(),
        );

  final AvailabilityMode mode;
  final double lowStockThresholdM;

  /// Champ → intitulé de colonne du dernier fichier importé.
  final Map<String, dynamic> importMapping;
}

/// Référence du catalogue, vue par le fournisseur (avec le stock brut).
class SupplierReference {
  const SupplierReference({
    required this.id,
    required this.code,
    required this.name,
    this.colorName,
    this.colorHex,
    this.specs = const TextileSpecs(),
    this.stockM,
    this.leadTimeWeeks,
    this.mode,
    this.lowStockThresholdM,
    this.retiredAt,
    this.updatedAt,
  });

  factory SupplierReference.fromJson(Map<String, dynamic> json) => SupplierReference(
        id: json['id'] as String,
        code: json['code'] as String,
        name: json['name'] as String,
        colorName: json['color_name'] as String?,
        colorHex: json['color_hex'] as String?,
        specs: TextileSpecs.fromJson(json),
        stockM: (json['stock_m'] as num?)?.toDouble(),
        leadTimeWeeks: json['lead_time_weeks'] as int?,
        mode: AvailabilityMode.parse(json['availability_mode'] as String?),
        lowStockThresholdM: (json['low_stock_threshold_m'] as num?)?.toDouble(),
        retiredAt: json['retired_at'] == null ? null : DateTime.parse(json['retired_at'] as String).toLocal(),
        updatedAt: json['updated_at'] == null ? null : DateTime.parse(json['updated_at'] as String).toLocal(),
      );

  final String id;
  final String code;
  final String name;
  final String? colorName;
  final String? colorHex;
  final TextileSpecs specs;
  final double? stockM;
  final int? leadTimeWeeks;

  /// Réglages propres à la référence (null = réglage général du fournisseur).
  final AvailabilityMode? mode;
  final double? lowStockThresholdM;
  final DateTime? retiredAt;
  final DateTime? updatedAt;

  bool get isRetired => retiredAt != null;

  AvailabilityMode effectiveMode(SupplierSettings s) => mode ?? s.mode;

  AvailabilityStatus status(SupplierSettings s) => availabilityStatusOf(
        stockM: stockM,
        thresholdM: lowStockThresholdM ?? s.lowStockThresholdM,
        leadTimeWeeks: leadTimeWeeks,
      );
}
