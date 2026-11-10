import 'dart:convert';
import 'dart:typed_data';

import 'package:csv/csv.dart';
import 'package:excel/excel.dart';

/// Tableau lu depuis un fichier : intitulés + lignes de données (textes).
class TableData {
  const TableData({required this.headers, required this.rows});

  final List<String> headers;
  final List<List<String>> rows;
}

class UnreadableFileException implements Exception {
  const UnreadableFileException();
}

/// Lit un fichier .xlsx (première feuille) ou .csv/.txt (séparateur détecté).
/// La première ligne non vide donne les intitulés.
TableData readTable(Uint8List bytes, String fileName) {
  final lower = fileName.toLowerCase();
  final List<List<String>> raw;
  try {
    raw = lower.endsWith('.xlsx') ? _readXlsx(bytes) : _readCsv(bytes);
  } catch (_) {
    throw const UnreadableFileException();
  }
  final nonEmpty = raw.where((r) => r.any((c) => c.trim().isNotEmpty)).toList();
  if (nonEmpty.isEmpty) throw const UnreadableFileException();
  final headers = nonEmpty.first.map((h) => h.trim()).toList();
  final width = headers.length;
  final rows = [
    for (final r in nonEmpty.skip(1)) [for (var i = 0; i < width; i++) i < r.length ? r[i] : ''],
  ];
  return TableData(headers: headers, rows: rows);
}

List<List<String>> _readXlsx(Uint8List bytes) {
  final book = Excel.decodeBytes(bytes);
  final sheet = book.tables.values.firstWhere((t) => t.maxRows > 0, orElse: () => book.tables.values.first);
  return [
    for (final row in sheet.rows)
      [
        for (final cell in row)
          switch (cell?.value) {
            null => '',
            TextCellValue(:final value) => value.toString(),
            IntCellValue(:final value) => '$value',
            DoubleCellValue(:final value) =>
              value == value.roundToDouble() ? value.toStringAsFixed(0) : '$value',
            final other => other.toString(),
          },
      ],
  ];
}

List<List<String>> _readCsv(Uint8List bytes) {
  var text = utf8.decode(bytes, allowMalformed: true);
  if (text.startsWith('\uFEFF')) text = text.substring(1);
  final firstLine = text.split(RegExp(r'\r?\n')).firstWhere((l) => l.trim().isNotEmpty, orElse: () => '');
  // Séparateur le plus fréquent sur la première ligne (Excel français : point-virgule).
  final delimiter = [';', '\t', ','].reduce(
    (best, d) => firstLine.split(d).length > firstLine.split(best).length ? d : best,
  );
  final rows = Csv(fieldDelimiter: delimiter, lineDelimiter: '\n', autoDetect: false).decode(text.replaceAll('\r\n', '\n'));
  return [for (final r in rows) [for (final c in r) c?.toString() ?? '']];
}
