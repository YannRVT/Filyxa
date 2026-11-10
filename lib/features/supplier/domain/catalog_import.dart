import '../../library/domain/catalog.dart';
import '../../library/domain/library_filter.dart' show foldForSearch;
import '../../library/domain/material.dart';

/// Champs importables depuis un fichier fournisseur.
enum ImportField {
  code(required: true),
  name(required: true),
  colorName,
  colorHex,
  composition,
  weight,
  width,
  weave,
  certifications,
  uses,
  stock,
  leadTime;

  const ImportField({this.required = false});

  final bool required;
}

/// Intitulés de colonnes reconnus automatiquement (comparés sans accents ni casse).
const _synonyms = <ImportField, List<String>>{
  ImportField.code: ['code', 'ref', 'reference', 'code article', 'article', 'sku', 'item', 'riferimento', 'codice', 'referencia', 'cod', 'cod articol'],
  ImportField.name: ['nom', 'name', 'designation', 'libelle', 'description', 'descrizione', 'descripcion', 'descricao', 'descriere', 'nome', 'nombre', 'denumire', 'qualite', 'quality', 'tissu', 'fabric'],
  ImportField.colorName: ['coloris', 'couleur', 'color', 'colour', 'colore', 'cor', 'culoare', 'colorway', 'variante'],
  ImportField.colorHex: ['hex', 'code couleur', 'color hex', 'colour hex', 'rgb'],
  ImportField.composition: ['composition', 'compo', 'composizione', 'composicion', 'composicao', 'compozitie', 'content', 'fibre', 'fibres', 'fiber'],
  ImportField.weight: ['grammage', 'poids', 'weight', 'gsm', 'g m2', 'g m', 'grammatura', 'gramaje', 'gramagem', 'gramaj'],
  ImportField.width: ['laize', 'largeur', 'width', 'altezza', 'ancho', 'largura', 'latime', 'cm'],
  ImportField.weave: ['armure', 'weave', 'armatura', 'ligamento', 'debuxo', 'legatura', 'structure'],
  ImportField.certifications: ['certification', 'certifications', 'labels', 'label', 'certificazioni', 'certificaciones', 'certificacoes', 'certificari'],
  ImportField.uses: ['usage', 'usages', 'uses', 'use', 'utilisation', 'usi', 'usos', 'utilizari', 'end use'],
  ImportField.stock: ['stock', 'quantite', 'quantity', 'qty', 'metrage', 'metres', 'meters', 'disponible', 'available', 'giacenza', 'existencias', 'estoque', 'stoc'],
  ImportField.leadTime: ['delai', 'lead time', 'leadtime', 'semaines', 'weeks', 'tempi', 'plazo', 'prazo', 'termen'],
};

/// Association automatique : pour chaque champ, la colonne dont l'intitulé ressemble le plus.
/// Une colonne mémorisée lors d'un import précédent (même intitulé) est prioritaire.
Map<ImportField, int> guessMapping(List<String> headers, {Map<String, dynamic> remembered = const {}}) {
  final folded = headers.map(foldForSearch).toList();
  final mapping = <ImportField, int>{};
  final used = <int>{};

  for (final field in ImportField.values) {
    final previous = remembered[field.name];
    if (previous is String) {
      final i = folded.indexOf(foldForSearch(previous));
      if (i >= 0 && !used.contains(i)) {
        mapping[field] = i;
        used.add(i);
      }
    }
  }
  // Correspondance exacte d'abord, puis intitulé qui contient le synonyme.
  for (final exact in [true, false]) {
    for (final field in ImportField.values) {
      if (mapping.containsKey(field)) continue;
      for (var i = 0; i < folded.length; i++) {
        if (used.contains(i) || folded[i].isEmpty) continue;
        final hit = _synonyms[field]!.any((s) => exact ? folded[i] == s : ' ${folded[i]} '.contains(' $s '));
        if (hit) {
          mapping[field] = i;
          used.add(i);
          break;
        }
      }
    }
  }
  return mapping;
}

/// Mapping à mémoriser : champ → intitulé de colonne.
Map<String, String> mappingToRemember(Map<ImportField, int> mapping, List<String> headers) => {
      for (final e in mapping.entries)
        if (e.value < headers.length) e.key.name: headers[e.value],
    };

/// Motif de rejet d'une ligne, traduit par l'interface.
enum ImportIssueKind {
  missingCode,
  missingName,
  compositionInvalid,
  numberInvalid,
  colorInvalid,
  duplicateCode,
}

class ImportIssue {
  const ImportIssue(this.kind, {this.field, this.value});

  final ImportIssueKind kind;
  final ImportField? field;
  final String? value;
}

/// Ligne du fichier analysée : soit prête à importer, soit rejetée avec ses motifs.
class ImportRow {
  const ImportRow({required this.line, required this.issues, this.payload});

  /// Numéro de ligne dans le fichier (1 = intitulés).
  final int line;
  final List<ImportIssue> issues;

  /// Données envoyées à import_supplier_references si la ligne est valide.
  final Map<String, dynamic>? payload;

  bool get isValid => issues.isEmpty;
}

class ImportAnalysis {
  const ImportAnalysis(this.rows);

  final List<ImportRow> rows;

  List<ImportRow> get valid => rows.where((r) => r.isValid).toList();
  List<ImportRow> get invalid => rows.where((r) => !r.isValid).toList();
}

/// Limite d'un import (critère du plan).
const kMaxImportRows = 5000;

String _cell(List<String> row, int? col) => col == null || col >= row.length ? '' : row[col].trim();

/// Analyse les lignes de données (sans l'intitulé) selon l'association des colonnes.
ImportAnalysis analyzeRows(List<List<String>> dataRows, Map<ImportField, int> mapping) {
  final seen = <String>{};
  final rows = <ImportRow>[];
  for (var i = 0; i < dataRows.length; i++) {
    final row = dataRows[i];
    if (row.every((c) => c.trim().isEmpty)) continue;
    final issues = <ImportIssue>[];
    String get(ImportField f) => _cell(row, mapping[f]);

    final code = get(ImportField.code);
    final name = get(ImportField.name);
    if (code.isEmpty) issues.add(const ImportIssue(ImportIssueKind.missingCode));
    if (name.isEmpty) issues.add(const ImportIssue(ImportIssueKind.missingName));
    final normalizedCode = normalizeReferenceCode(code);
    if (code.isNotEmpty && !seen.add(normalizedCode)) {
      issues.add(ImportIssue(ImportIssueKind.duplicateCode, value: code));
    }

    final compositionText = get(ImportField.composition);
    final composition = compositionText.isEmpty ? const <FiberShare>[] : parseComposition(compositionText);
    if (composition == null || !isCompositionValid(composition)) {
      issues.add(ImportIssue(ImportIssueKind.compositionInvalid, field: ImportField.composition, value: compositionText));
    }

    int? integer(ImportField f, int min, int max) {
      final text = get(f);
      if (text.isEmpty) return null;
      final n = parseNumber(text.replaceAll(RegExp(r'[^0-9,.\-]'), ''));
      if (n == null || n < min || n > max) {
        issues.add(ImportIssue(ImportIssueKind.numberInvalid, field: f, value: text));
        return null;
      }
      return n.round();
    }

    double? decimal(ImportField f, double min, double max) {
      final text = get(f);
      if (text.isEmpty) return null;
      final n = parseNumber(text.replaceAll(RegExp(r'[^0-9,.\-]'), ''));
      if (n == null || n < min || n > max) {
        issues.add(ImportIssue(ImportIssueKind.numberInvalid, field: f, value: text));
        return null;
      }
      return n;
    }

    final weight = integer(ImportField.weight, 1, 2000);
    final width = integer(ImportField.width, 1, 600);
    final stock = decimal(ImportField.stock, 0, 10000000);
    final leadTime = integer(ImportField.leadTime, 0, 104);

    final hexText = get(ImportField.colorHex);
    final hex = hexText.isEmpty ? null : normalizeHex(hexText);
    if (hexText.isNotEmpty && hex == null) {
      issues.add(ImportIssue(ImportIssueKind.colorInvalid, field: ImportField.colorHex, value: hexText));
    }

    rows.add(ImportRow(
      line: i + 2,
      issues: issues,
      payload: issues.isNotEmpty
          ? null
          : {
              'code': code,
              'name': name,
              'color_name': get(ImportField.colorName).isEmpty ? null : get(ImportField.colorName),
              'color_hex': hex,
              'composition': composition!.map((f) => f.toJson()).toList(),
              'weight_gsm': weight,
              'width_cm': width,
              'weave': matchWeave(get(ImportField.weave)),
              'certifications': matchCertifications(get(ImportField.certifications)),
              'uses': matchUses(get(ImportField.uses)),
              'stock_m': stock,
              'lead_time_weeks': leadTime,
            },
    ));
  }
  return ImportAnalysis(rows);
}

/// Même normalisation que la base : « DR 4521-nv » → « DR4521NV ».
String normalizeReferenceCode(String code) => code.toUpperCase().replaceAll(RegExp(r'[^A-Z0-9]'), '');

/// Index fibre : code ISO et libellés dans les 6 langues, sans accents.
final Map<String, String> _fiberIndex = {
  for (final f in fibers) ...{
    foldForSearch(f.code): f.code,
    for (final label in f.labels.values) foldForSearch(label): f.code,
  },
  'elasthanne': 'EL', 'spandex': 'EL', 'lycra': 'EL', 'nylon': 'PA', 'cotton': 'CO', 'laine vierge': 'WO',
  'virgin wool': 'WO', 'wool': 'WO', 'silk': 'SE', 'linen': 'LI', 'flax': 'LI', 'tencel': 'CLY',
  'acrylic': 'PAN', 'polyamide': 'PA', 'polyester': 'PES', 'pl': 'PES', 'pe': 'PES',
};

/// Lit une composition écrite librement :
/// « 62% WO 38% PES », « 62 % laine / 38 % polyester », « Wool 62, Polyester 38 »,
/// « 37,5 % coton biologique, 62,5 % lin ». Renvoie null si une fibre n'est pas reconnue.
List<FiberShare>? parseComposition(String input) {
  var text = input.toLowerCase()
      // Virgule décimale : « 37,5 » → « 37.5 ».
      .replaceAllMapped(RegExp(r'(\d),(\d)'), (m) => '${m[1]}.${m[2]}')
      // Séparateurs entre fibres.
      .replaceAll(RegExp(r'[,;/+&|\-–()]'), ' ')
      .replaceAll('%', ' ')
      // « 62wo » ou « wo62 » : espace entre chiffres et lettres.
      .replaceAllMapped(RegExp(r'(\d)([^\d\s.])'), (m) => '${m[1]} ${m[2]}')
      .replaceAllMapped(RegExp(r'([^\d\s.])(\d)'), (m) => '${m[1]} ${m[2]}');
  final tokens = text.split(RegExp(r'\s+')).where((t) => t.isNotEmpty).toList();
  final numberRe = RegExp(r'^\d+(\.\d+)?$');

  // Fibre citée dans un groupe de mots : « coton biologique » → CO. Exactement une fibre attendue.
  String? fiberFromWords(List<String> words) {
    final folded = words.map(foldForSearch).where((w) => w.isNotEmpty).toList();
    for (var n = folded.length; n > 0; n--) {
      for (var start = 0; start + n <= folded.length; start++) {
        final code = _fiberIndex[folded.sublist(start, start + n).join(' ')];
        if (code != null) return code;
      }
    }
    return null;
  }

  final shares = <FiberShare>[];
  double? pendingPct;
  final pendingWords = <String>[];

  bool flush() {
    if (pendingPct == null) return pendingWords.isEmpty;
    final code = fiberFromWords(pendingWords);
    if (code == null) return false;
    shares.add(FiberShare(code, pendingPct!));
    pendingPct = null;
    pendingWords.clear();
    return true;
  }

  for (final t in tokens) {
    if (numberRe.hasMatch(t)) {
      final n = double.parse(t);
      if (pendingPct != null) {
        if (!flush()) return null;
        pendingPct = n;
      } else if (pendingWords.isNotEmpty) {
        // Format « fibre nombre ».
        pendingPct = n;
        if (!flush()) return null;
      } else {
        pendingPct = n;
      }
    } else {
      pendingWords.add(t);
    }
  }
  if (!flush()) return null;
  if (shares.isEmpty) return null;
  // Regroupe une même fibre citée deux fois.
  final merged = <String, double>{};
  for (final s in shares) {
    merged[s.fiber] = (merged[s.fiber] ?? 0) + s.pct;
  }
  return [for (final e in merged.entries) FiberShare(e.key, e.value)];
}

String? _matchEntry(List<CatalogEntry> list, String text) {
  final t = foldForSearch(text);
  if (t.isEmpty) return null;
  for (final e in list) {
    if (foldForSearch(e.code) == t || e.labels.values.any((l) => foldForSearch(l) == t)) return e.code;
  }
  return null;
}

/// Armure reconnue dans n'importe quelle langue, sinon ignorée.
String? matchWeave(String text) => _matchEntry(weaves, text);

List<String> _split(String text) =>
    text.split(RegExp(r'[,;|/]')).map((s) => s.trim()).where((s) => s.isNotEmpty).toList();

/// Usages reconnus dans n'importe quelle langue ; les autres sont ignorés.
List<String> matchUses(String text) =>
    {for (final part in _split(text)) ?_matchEntry(uses, part)}.toList();

/// Certifications reconnues (GOTS, OEKO-TEX…) ; les autres sont ignorées.
List<String> matchCertifications(String text) {
  final found = <String>{};
  final folded = foldForSearch(text);
  for (final c in certifications) {
    if (' $folded '.contains(' ${foldForSearch(c)} ')) found.add(c);
  }
  return [for (final c in certifications) if (found.contains(c)) c];
}
