import 'catalog.dart';
import 'color_family.dart';
import 'material.dart';

/// Bornes du filtre de grammage (g/m²).
const kWeightMin = 0;
const kWeightMax = 800;

/// Recherche et filtres de TissuTech. Immuable ; vide = tout afficher.
/// Les filtres d'une même facette se combinent en « ou », les facettes entre elles en « et ».
class LibraryFilter {
  const LibraryFilter({
    this.query = '',
    this.fiber,
    this.fiberMinPct = 0,
    this.weightMin,
    this.weightMax,
    this.colors = const {},
    this.weaves = const {},
    this.certifications = const {},
    this.uses = const {},
    this.inStockOnly = false,
  });

  final String query;

  /// Fibre exigée (code ISO 2076) avec un pourcentage minimum.
  final String? fiber;
  final double fiberMinPct;
  final int? weightMin;
  final int? weightMax;
  final Set<ColorFamily> colors;
  final Set<String> weaves;
  final Set<String> certifications;
  final Set<String> uses;

  /// Stock atelier strictement positif.
  final bool inStockOnly;

  bool get isEmpty => query.trim().isEmpty && activeCount == 0;

  /// Nombre de filtres actifs, hors recherche texte.
  int get activeCount =>
      (fiber != null ? 1 : 0) +
      (weightMin != null || weightMax != null ? 1 : 0) +
      colors.length +
      weaves.length +
      certifications.length +
      uses.length +
      (inStockOnly ? 1 : 0);

  LibraryFilter copyWith({
    String? query,
    String? Function()? fiber,
    double? fiberMinPct,
    int? Function()? weightMin,
    int? Function()? weightMax,
    Set<ColorFamily>? colors,
    Set<String>? weaves,
    Set<String>? certifications,
    Set<String>? uses,
    bool? inStockOnly,
  }) =>
      LibraryFilter(
        query: query ?? this.query,
        fiber: fiber != null ? fiber() : this.fiber,
        fiberMinPct: fiberMinPct ?? this.fiberMinPct,
        weightMin: weightMin != null ? weightMin() : this.weightMin,
        weightMax: weightMax != null ? weightMax() : this.weightMax,
        colors: colors ?? this.colors,
        weaves: weaves ?? this.weaves,
        certifications: certifications ?? this.certifications,
        uses: uses ?? this.uses,
        inStockOnly: inStockOnly ?? this.inStockOnly,
      );

  /// Garde la recherche, retire tous les filtres.
  LibraryFilter clearFilters() => LibraryFilter(query: query);

  bool matches(MaterialItem m, {String lang = 'fr'}) {
    final specs = m.specs;
    if (fiber != null) {
      final pct = specs.composition.where((f) => f.fiber == fiber).fold<double>(0, (s, f) => s + f.pct);
      // Sans minimum : la fibre doit être présente.
      if (pct <= 0 || pct + 1e-9 < fiberMinPct) return false;
    }
    if (weightMin != null || weightMax != null) {
      final w = specs.weightGsm;
      if (w == null) return false;
      if (weightMin != null && w < weightMin!) return false;
      if (weightMax != null && w > weightMax!) return false;
    }
    if (colors.isNotEmpty && !colors.contains(colorFamilyOf(m.colorHex))) return false;
    if (weaves.isNotEmpty && !weaves.contains(specs.weave)) return false;
    if (certifications.isNotEmpty && !specs.certifications.any(certifications.contains)) return false;
    if (uses.isNotEmpty && !specs.uses.any(uses.contains)) return false;
    if (inStockOnly && (m.atelierStockM ?? 0) <= 0) return false;
    return _matchesQuery(m, lang);
  }

  bool _matchesQuery(MaterialItem m, String lang) {
    final terms = foldForSearch(query).split(' ').where((t) => t.isNotEmpty);
    if (terms.isEmpty) return true;
    final haystack = foldForSearch([
      m.name,
      m.supplierName,
      m.supplierCode,
      m.colorName,
      for (final f in m.specs.composition) ...[f.fiber, fiberLabel(f.fiber, lang)],
    ].whereType<String>().join(' '));
    // Tous les mots doivent apparaître, dans n'importe quel ordre.
    return terms.every(haystack.contains);
  }

  List<MaterialItem> apply(List<MaterialItem> items, {String lang = 'fr'}) =>
      isEmpty ? items : [for (final m in items) if (matches(m, lang: lang)) m];
}

const _accents = {
  'à': 'a', 'â': 'a', 'ä': 'a', 'á': 'a', 'ã': 'a', 'ă': 'a',
  'ç': 'c', 'é': 'e', 'è': 'e', 'ê': 'e', 'ë': 'e',
  'î': 'i', 'ï': 'i', 'í': 'i', 'ì': 'i',
  'ô': 'o', 'ö': 'o', 'ó': 'o', 'ò': 'o', 'õ': 'o',
  'ù': 'u', 'û': 'u', 'ü': 'u', 'ú': 'u',
  'ñ': 'n', 'ș': 's', 'ş': 's', 'ț': 't', 'ţ': 't', 'œ': 'oe', 'æ': 'ae',
};

/// Minuscules, sans accents ni ponctuation : « Écru-Lin » → « ecru lin ».
String foldForSearch(String input) {
  final lower = input.toLowerCase();
  final buffer = StringBuffer();
  for (final rune in lower.runes) {
    final ch = String.fromCharCode(rune);
    buffer.write(_accents[ch] ?? ch);
  }
  return buffer.toString().replaceAll(RegExp(r'[^a-z0-9%#]+'), ' ').trim();
}
