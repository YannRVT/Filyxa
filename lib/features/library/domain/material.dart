import 'catalog.dart';

/// Part d'une fibre dans la composition (code ISO 2076 + pourcentage).
class FiberShare {
  const FiberShare(this.fiber, this.pct);

  factory FiberShare.fromJson(Map<String, dynamic> json) =>
      FiberShare(json['fiber'] as String, (json['pct'] as num).toDouble());

  final String fiber;
  final double pct;

  Map<String, dynamic> toJson() => {'fiber': fiber, 'pct': pct};

  @override
  bool operator ==(Object other) => other is FiberShare && other.fiber == fiber && other.pct == pct;

  @override
  int get hashCode => Object.hash(fiber, pct);
}

class TextileSpecs {
  const TextileSpecs({
    this.composition = const [],
    this.weightGsm,
    this.widthCm,
    this.weave,
    this.care = const [],
    this.certifications = const [],
    this.uses = const [],
  });

  factory TextileSpecs.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const TextileSpecs();
    List<String> strings(String key) => (json[key] as List<dynamic>? ?? const []).cast<String>();
    return TextileSpecs(
      composition: (json['composition'] as List<dynamic>? ?? const [])
          .map((e) => FiberShare.fromJson(e as Map<String, dynamic>))
          .toList(),
      weightGsm: json['weight_gsm'] as int?,
      widthCm: json['width_cm'] as int?,
      weave: json['weave'] as String?,
      care: strings('care'),
      certifications: strings('certifications'),
      uses: strings('uses'),
    );
  }

  final List<FiberShare> composition;
  final int? weightGsm;
  final int? widthCm;
  final String? weave;
  final List<String> care;
  final List<String> certifications;
  final List<String> uses;

  Map<String, dynamic> toJson() => {
        'composition': composition.map((f) => f.toJson()).toList(),
        'weight_gsm': weightGsm,
        'width_cm': widthCm,
        'weave': weave,
        'care': care,
        'certifications': certifications,
        'uses': uses,
      };
}

class MaterialItem {
  const MaterialItem({
    required this.id,
    required this.orgId,
    required this.name,
    this.supplierName,
    this.supplierCode,
    this.colorName,
    this.colorHex,
    this.photoPath,
    this.atelierStockM,
    this.notes,
    this.specs = const TextileSpecs(),
    this.updatedAt,
  });

  factory MaterialItem.fromJson(Map<String, dynamic> json) {
    final rawSpecs = json['textile_specs'];
    return MaterialItem(
      id: json['id'] as String,
      orgId: json['org_id'] as String,
      name: json['name'] as String,
      supplierName: json['supplier_name'] as String?,
      supplierCode: json['supplier_code'] as String?,
      colorName: json['color_name'] as String?,
      colorHex: json['color_hex'] as String?,
      photoPath: json['photo_path'] as String?,
      atelierStockM: (json['atelier_stock_m'] as num?)?.toDouble(),
      notes: json['notes'] as String?,
      specs: TextileSpecs.fromJson(
        rawSpecs is List ? (rawSpecs.isEmpty ? null : rawSpecs.first as Map<String, dynamic>) : rawSpecs as Map<String, dynamic>?,
      ),
      updatedAt: json['updated_at'] == null ? null : DateTime.parse(json['updated_at'] as String).toLocal(),
    );
  }

  final String id;
  final String orgId;
  final String name;
  final String? supplierName;
  final String? supplierCode;
  final String? colorName;
  final String? colorHex;
  final String? photoPath;
  final double? atelierStockM;
  final String? notes;
  final TextileSpecs specs;
  final DateTime? updatedAt;
}

/// Données saisies dans le formulaire, envoyées à `save_textile_material`.
class MaterialDraft {
  const MaterialDraft({
    this.id,
    required this.orgId,
    required this.name,
    this.supplierName,
    this.supplierCode,
    this.colorName,
    this.colorHex,
    this.photoPath,
    this.atelierStockM,
    this.notes,
    this.specs = const TextileSpecs(),
  });

  final String? id;
  final String orgId;
  final String name;
  final String? supplierName;
  final String? supplierCode;
  final String? colorName;
  final String? colorHex;
  final String? photoPath;
  final double? atelierStockM;
  final String? notes;
  final TextileSpecs specs;

  Map<String, dynamic> toPayload() => {
        if (id != null) 'id': id,
        'org_id': orgId,
        'name': name.trim(),
        'supplier_name': supplierName,
        'supplier_code': supplierCode,
        'color_name': colorName,
        'color_hex': colorHex?.toUpperCase(),
        'photo_path': photoPath,
        'atelier_stock_m': atelierStockM,
        'notes': notes,
        'specs': specs.toJson(),
      };
}

// Règles et mise en forme ---------------------------------------------------------

/// Total des pourcentages d'une composition.
double compositionTotal(List<FiberShare> composition) =>
    composition.fold(0, (sum, f) => sum + f.pct);

/// Une composition est valide si elle est vide ou totalise 100 % (à 0,5 près),
/// sans fibre en double ni pourcentage nul.
bool isCompositionValid(List<FiberShare> composition) {
  if (composition.isEmpty) return true;
  if (composition.any((f) => f.pct <= 0)) return false;
  if (composition.map((f) => f.fiber).toSet().length != composition.length) return false;
  return (compositionTotal(composition) - 100).abs() <= 0.5;
}

/// Nombre avec la virgule ou le point selon la langue, sans zéro inutile :
/// « 62 », « 2,5 », « 42,75 ».
String formatNumber(double value, String lang, {int decimals = 1}) {
  var text = value.toStringAsFixed(decimals);
  if (text.contains('.')) text = text.replaceFirst(RegExp(r'\.?0+$'), '');
  return lang == 'en' ? text : text.replaceAll('.', ',');
}

/// Lit un nombre saisi avec une virgule ou un point ; `null` si vide ou invalide.
double? parseNumber(String? text) {
  final t = (text ?? '').trim().replaceAll(' ', '').replaceAll(',', '.');
  if (t.isEmpty) return null;
  return double.tryParse(t);
}

/// Composition en codes, pour la police d'étiquette : « 62 % WO · 38 % PES ».
String compositionCodes(List<FiberShare> composition, String lang) => composition
    .map((f) => '${formatNumber(f.pct, lang)} % ${f.fiber}')
    .join(' · ');

/// Composition en toutes lettres : « 62 % Laine, 38 % Polyester ».
String compositionLabel(List<FiberShare> composition, String lang) => composition
    .map((f) => '${formatNumber(f.pct, lang)} % ${fiberLabel(f.fiber, lang)}')
    .join(', ');

final _hexRe = RegExp(r'^#?[0-9a-fA-F]{6}$');

/// Normalise « 2f4a6b » ou « #2F4A6B » en « #2F4A6B » ; `null` si invalide.
String? normalizeHex(String? input) {
  final t = (input ?? '').trim();
  if (!_hexRe.hasMatch(t)) return null;
  return '#${t.replaceFirst('#', '').toUpperCase()}';
}
