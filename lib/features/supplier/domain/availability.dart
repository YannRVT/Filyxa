/// Disponibilité d'une référence fournisseur, telle que montrée aux ateliers.
library;

enum AvailabilityMode {
  exact,
  tiers,
  hidden;

  static AvailabilityMode? parse(String? v) =>
      AvailabilityMode.values.where((m) => m.name == v).firstOrNull;
}

enum AvailabilityStatus {
  available,
  low,
  onOrder,
  outOfStock;

  static AvailabilityStatus? parse(String? v) => switch (v) {
        'available' => available,
        'low' => low,
        'on_order' => onOrder,
        'out_of_stock' => outOfStock,
        _ => null,
      };
}

/// Même règle que la base (availability_status_of) : stock au-dessus du seuil →
/// disponible ; stock positif → faible ; sinon sur commande si un délai est donné.
AvailabilityStatus availabilityStatusOf({double? stockM, required double thresholdM, int? leadTimeWeeks}) {
  if (stockM != null && stockM > thresholdM) return AvailabilityStatus.available;
  if (stockM != null && stockM > 0) return AvailabilityStatus.low;
  if (leadTimeWeeks != null) return AvailabilityStatus.onOrder;
  return AvailabilityStatus.outOfStock;
}

const kDefaultLowStockThresholdM = 50.0;
