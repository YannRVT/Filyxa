import 'dart:convert';
import 'dart:typed_data';

import 'package:excel/excel.dart';
import 'package:filyxa/features/supplier/data/table_reader.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('CSV Excel français : point-virgule, BOM, guillemets, virgule décimale', () {
    const csv = '﻿Code;Désignation;Composition;Stock\r\n'
        'DR4521;"Drap laine; froide";"62% WO, 38% PES";340,5\r\n'
        '\r\n'
        'FL300;Flanelle;100% WO;12\r\n';
    final t = readTable(Uint8List.fromList(utf8.encode(csv)), 'catalogue.csv');
    expect(t.headers, ['Code', 'Désignation', 'Composition', 'Stock']);
    expect(t.rows.length, 2);
    expect(t.rows.first, ['DR4521', 'Drap laine; froide', '62% WO, 38% PES', '340,5']);
  });

  test('CSV à virgules', () {
    const csv = 'code,name,stock\nA1,Toile,10\nA2,Satin,\n';
    final t = readTable(Uint8List.fromList(utf8.encode(csv)), 'export.csv');
    expect(t.headers, ['code', 'name', 'stock']);
    expect(t.rows[1], ['A2', 'Satin', '']);
  });

  test('Excel .xlsx : première feuille, nombres sans « .0 »', () {
    final book = Excel.createExcel();
    final sheet = book[book.getDefaultSheet()!];
    sheet.appendRow([TextCellValue('Code'), TextCellValue('Nom'), TextCellValue('Grammage'), TextCellValue('Stock')]);
    sheet.appendRow([TextCellValue('DR4521'), TextCellValue('Drap'), IntCellValue(280), DoubleCellValue(340.5)]);
    sheet.appendRow([TextCellValue('FL300'), TextCellValue('Flanelle'), DoubleCellValue(320.0), null]);
    final bytes = Uint8List.fromList(book.encode()!);
    final t = readTable(bytes, 'Catalogue.XLSX');
    expect(t.headers, ['Code', 'Nom', 'Grammage', 'Stock']);
    expect(t.rows[0], ['DR4521', 'Drap', '280', '340.5']);
    expect(t.rows[1], ['FL300', 'Flanelle', '320', '']);
  });

  test('fichier illisible ou vide', () {
    expect(() => readTable(Uint8List.fromList([0, 1, 2, 3]), 'x.xlsx'), throwsA(isA<UnreadableFileException>()));
    expect(() => readTable(Uint8List(0), 'vide.csv'), throwsA(isA<UnreadableFileException>()));
  });
}
