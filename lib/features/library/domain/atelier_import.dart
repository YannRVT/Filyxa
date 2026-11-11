import '../../supplier/domain/catalog_import.dart';
import 'library_filter.dart' show foldForSearch;
import 'material.dart';

/// Champs importables depuis la base existante d'un atelier.
enum AtelierImportField {
  name(required: true),
  supplierName,
  supplierCode,
  colorName,
  colorHex,
  composition,
  weight,
  width,
  weave,
  certifications,
  uses,
  stock,
  price,
  tags,
  notes;

  const AtelierImportField({this.required = false});

  final bool required;
}

/// Intitulés reconnus : ceux du catalogue fournisseur, plus ceux propres à l'atelier.
final Map<AtelierImportField, List<String>> _synonyms = {
  AtelierImportField.name: [
    'nom', 'name', 'matiere', 'tissu', 'fabric', 'designation', 'libelle', 'description', 'nome', 'nombre', 'denumire',
    'descrizione', 'descripcion', 'descricao', 'descriere', 'qualite', 'quality',
  ],
  AtelierImportField.supplierName: [
    'fournisseur', 'supplier', 'fabricant', 'tisseur', 'mill', 'vendor', 'marque', 'fornitore', 'proveedor',
    'fornecedor', 'furnizor',
  ],
  AtelierImportField.supplierCode: catalogSynonyms[ImportField.code]!,
  AtelierImportField.colorName: catalogSynonyms[ImportField.colorName]!,
  AtelierImportField.colorHex: catalogSynonyms[ImportField.colorHex]!,
  AtelierImportField.composition: catalogSynonyms[ImportField.composition]!,
  AtelierImportField.weight: catalogSynonyms[ImportField.weight]!,
  AtelierImportField.width: catalogSynonyms[ImportField.width]!,
  AtelierImportField.weave: catalogSynonyms[ImportField.weave]!,
  AtelierImportField.certifications: catalogSynonyms[ImportField.certifications]!,
  AtelierImportField.uses: catalogSynonyms[ImportField.uses]!,
  AtelierImportField.stock: [...catalogSynonyms[ImportField.stock]!, 'stock atelier', 'en stock'],
  AtelierImportField.price: ['prix', 'price', 'tarif', 'cout', 'cost', 'eur', 'prezzo', 'precio', 'preco', 'pret', 'prix m'],
  AtelierImportField.tags: ['etiquettes', 'etiquette', 'tags', 'tag', 'mots cles', 'categorie', 'category', 'collection', 'saison', 'season'],
  AtelierImportField.notes: ['notes', 'note', 'remarques', 'remarque', 'commentaire', 'commentaires', 'comment', 'comments', 'observations'],
};

Map<AtelierImportField, int> guessAtelierMapping(List<String> headers, {Map<String, dynamic> remembered = const {}}) =>
    guessColumns(headers, AtelierImportField.values, _synonyms, remembered: remembered);

/// Clé d'une matière dans le fichier : fournisseur + code, ou nom + coloris sans code.
/// Deux lignes de même clé décriraient la même matière.
String atelierRowKey({required String name, String? supplier, String? code, String? color}) {
  final c = normalizeReferenceCode(code ?? '');
  return c.isNotEmpty
      ? 'code:${foldForSearch(supplier ?? '')}|$c'
      : 'name:${foldForSearch(name)}|${foldForSearch(color ?? '')}';
}

String _cell(List<String> row, int? col) => col == null || col >= row.length ? '' : row[col].trim();

/// Analyse les lignes de données (sans l'intitulé) selon l'association des colonnes.
/// Les payloads valides sont envoyés à `import_atelier_materials`.
ImportAnalysis analyzeAtelierRows(List<List<String>> dataRows, Map<AtelierImportField, int> mapping) {
  final seen = <String>{};
  final rows = <ImportRow>[];
  for (var i = 0; i < dataRows.length; i++) {
    final row = dataRows[i];
    if (row.every((c) => c.trim().isEmpty)) continue;
    final issues = <ImportIssue>[];
    String get(AtelierImportField f) => _cell(row, mapping[f]);
    String? opt(AtelierImportField f) => get(f).isEmpty ? null : get(f);

    final name = get(AtelierImportField.name);
    if (name.isEmpty) issues.add(const ImportIssue(ImportIssueKind.missingName));

    final key = atelierRowKey(
      name: name,
      supplier: opt(AtelierImportField.supplierName),
      code: opt(AtelierImportField.supplierCode),
      color: opt(AtelierImportField.colorName),
    );
    if (name.isNotEmpty && !seen.add(key)) {
      issues.add(ImportIssue(ImportIssueKind.duplicateCode, value: opt(AtelierImportField.supplierCode) ?? name));
    }

    final compositionText = get(AtelierImportField.composition);
    final composition = compositionText.isEmpty ? const <FiberShare>[] : parseComposition(compositionText);
    if (composition == null || !isCompositionValid(composition)) {
      issues.add(ImportIssue(ImportIssueKind.compositionInvalid, field: AtelierImportField.composition, value: compositionText));
    }

    num? number(AtelierImportField f, num min, num max) {
      final text = get(f);
      if (text.isEmpty) return null;
      final n = parseNumber(text.replaceAll(RegExp(r'[^0-9,.\-]'), ''));
      if (n == null || n < min || n > max) {
        issues.add(ImportIssue(ImportIssueKind.numberInvalid, field: f, value: text));
        return null;
      }
      return n;
    }

    final weight = number(AtelierImportField.weight, 1, 2000)?.round();
    final width = number(AtelierImportField.width, 1, 600)?.round();
    final stock = number(AtelierImportField.stock, 0, 99999999);
    final price = number(AtelierImportField.price, 0, 100000);

    final hexText = get(AtelierImportField.colorHex);
    final hex = hexText.isEmpty ? null : normalizeHex(hexText);
    if (hexText.isNotEmpty && hex == null) {
      issues.add(ImportIssue(ImportIssueKind.colorInvalid, field: AtelierImportField.colorHex, value: hexText));
    }

    final tags = get(AtelierImportField.tags)
        .split(RegExp(r'[,;|]'))
        .map((t) => t.trim())
        .where((t) => t.isNotEmpty)
        .toSet()
        .toList();
    final notes = get(AtelierImportField.notes);

    rows.add(ImportRow(
      line: i + 2,
      issues: issues,
      payload: issues.isNotEmpty
          ? null
          : {
              'name': name,
              'supplier_name': opt(AtelierImportField.supplierName),
              'supplier_code': opt(AtelierImportField.supplierCode),
              'color_name': opt(AtelierImportField.colorName),
              'color_hex': hex,
              'atelier_stock_m': stock,
              'price_per_m': price,
              'tags': tags,
              'notes': notes.isEmpty ? null : (notes.length > 4000 ? notes.substring(0, 4000) : notes),
              'specs': {
                'composition': composition!.map((f) => f.toJson()).toList(),
                'weight_gsm': weight,
                'width_cm': width,
                'weave': matchWeave(get(AtelierImportField.weave)),
                'certifications': matchCertifications(get(AtelierImportField.certifications)),
                'uses': matchUses(get(AtelierImportField.uses)),
              },
            },
    ));
  }
  return ImportAnalysis(rows);
}
