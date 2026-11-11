import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../l10n/app_localizations.dart';
import '../../shared/care/care_pictograms.dart';
import '../library/domain/catalog.dart';
import '../library/domain/material.dart';
import '../studio/domain/alerts.dart';
import '../studio/domain/studio.dart';
import '../studio/ui/alert_widgets.dart' show AlertTexts;
import '../studio/ui/studio_widgets.dart' show StudioTexts;

// Charte Filyxa (DESIGN.md).
const _petrol = PdfColor.fromInt(0xFF064E49);
const _emerald = PdfColor.fromInt(0xFF0D9488);
const _mintPale = PdfColor.fromInt(0xFFEAF7F4);
const _ink = PdfColor.fromInt(0xFF1B2B29);
const _muted = PdfColor.fromInt(0xFF556B68);
const _line = PdfColor.fromInt(0xFFD9E6E3);
const _warning = PdfColor.fromInt(0xFFB45309);

/// Polices de la charte (Montserrat, Source Sans 3), avec repli hors ligne.
class PdfFonts {
  const PdfFonts(this.body, this.bold, this.title, this.mono);

  /// Polices PDF standard : sans réseau (tests, hors ligne).
  factory PdfFonts.standard() => PdfFonts(pw.Font.helvetica(), pw.Font.helveticaBold(), pw.Font.helveticaBold(), pw.Font.courier());

  static Future<PdfFonts> load() async {
    try {
      return PdfFonts(
        await PdfGoogleFonts.sourceSans3Regular(),
        await PdfGoogleFonts.sourceSans3SemiBold(),
        await PdfGoogleFonts.montserratSemiBold(),
        await PdfGoogleFonts.jetBrainsMonoRegular(),
      );
    } catch (_) {
      return PdfFonts.standard();
    }
  }

  final pw.Font body;
  final pw.Font bold;
  final pw.Font title;
  final pw.Font mono;

  pw.ThemeData get theme => pw.ThemeData.withFont(base: body, bold: bold);
}

/// Contexte commun d'un export : langue choisie, polices, date et lien partagé éventuel.
class PdfContext {
  const PdfContext({
    required this.l10n,
    required this.lang,
    required this.fonts,
    required this.date,
    this.symbolSvg,
    this.shareUrl,
    this.compress = true,
  });

  final AppLocalizations l10n;
  final String lang;
  final PdfFonts fonts;
  final DateTime date;

  /// Symbole Filyxa (SVG) pour l'en-tête.
  final String? symbolSvg;

  /// Lien partagé (phase 13) : imprimé en QR code.
  final String? shareUrl;

  /// false : contenu lisible en clair (tests).
  final bool compress;

  String get today =>
      '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';

  String number(double v, {int decimals = 1}) => formatNumber(v, lang, decimals: decimals);
}

PdfColor? _pdfColor(String? hex) {
  final v = int.tryParse((hex ?? '').replaceFirst('#', ''), radix: 16);
  return hex == null || v == null ? null : PdfColor.fromInt(0xFF000000 | v);
}

pw.Widget _header(PdfContext c, String kind) => pw.Container(
      padding: const pw.EdgeInsets.only(bottom: 8),
      margin: const pw.EdgeInsets.only(bottom: 14),
      decoration: const pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide(color: _emerald, width: 1.5))),
      child: pw.Row(
        children: [
          if (c.symbolSvg != null) ...[pw.SvgImage(svg: c.symbolSvg!, width: 16, height: 16), pw.SizedBox(width: 6)],
          pw.Text('Filyxa', style: pw.TextStyle(font: c.fonts.title, fontSize: 13, color: _petrol)),
          pw.Spacer(),
          pw.Text('$kind · ${c.l10n.pdfEditedOn(c.today)}', style: const pw.TextStyle(fontSize: 8.5, color: _muted)),
        ],
      ),
    );

pw.Widget _footer(PdfContext c, pw.Context ctx) => pw.Container(
      margin: const pw.EdgeInsets.only(top: 10),
      padding: const pw.EdgeInsets.only(top: 6),
      decoration: const pw.BoxDecoration(border: pw.Border(top: pw.BorderSide(color: _line, width: 0.5))),
      child: pw.Row(
        children: [
          pw.Expanded(child: pw.Text(c.l10n.pdfCompositionNote, style: const pw.TextStyle(fontSize: 6.5, color: _muted))),
          pw.SizedBox(width: 12),
          pw.Text(c.l10n.pdfPage(ctx.pageNumber, ctx.pagesCount), style: const pw.TextStyle(fontSize: 7, color: _muted)),
        ],
      ),
    );

pw.Widget _label(String text) => pw.Padding(
      padding: const pw.EdgeInsets.only(top: 12, bottom: 4),
      child: pw.Text(text.toUpperCase(), style: const pw.TextStyle(fontSize: 7.5, color: _muted, letterSpacing: 1.1)),
    );

pw.Widget _row(PdfContext c, String label, String? value, {bool metric = false}) => pw.Container(
      padding: const pw.EdgeInsets.symmetric(vertical: 3.5),
      decoration: const pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide(color: _line, width: 0.5))),
      child: pw.Row(children: [
        pw.SizedBox(width: 110, child: pw.Text(label, style: const pw.TextStyle(fontSize: 9, color: _muted))),
        pw.Expanded(
          child: pw.Text((value ?? '').isEmpty ? '-' : value!, style: pw.TextStyle(fontSize: 9.5, font: metric ? c.fonts.mono : null)),
        ),
      ]),
    );

pw.Widget _care(PdfContext c, List<String> care, {double size = 24, bool labels = true}) => pw.Wrap(
      spacing: labels ? 8 : 3,
      runSpacing: 5,
      children: [
        for (final code in sortCare(care))
          if (careSvg(code).isNotEmpty)
            pw.SizedBox(
              width: labels ? 62 : size,
              child: pw.Column(children: [
                pw.SvgImage(svg: careSvg(code), width: size, height: size),
                if (labels)
                  pw.Padding(
                    padding: const pw.EdgeInsets.only(top: 2),
                    child: pw.Text(careCode(code)?.label(c.lang) ?? code,
                        textAlign: pw.TextAlign.center, style: const pw.TextStyle(fontSize: 6.2, color: _muted)),
                  ),
              ]),
            ),
      ],
    );

pw.Widget _qr(PdfContext c) => pw.Column(children: [
      pw.BarcodeWidget(barcode: pw.Barcode.qrCode(), data: c.shareUrl!, width: 70, height: 70, color: _ink),
      pw.SizedBox(height: 3),
      pw.Text(c.shareUrl!, style: const pw.TextStyle(fontSize: 5.5, color: _muted)),
    ]);

String _composition(PdfContext c, List<FiberShare> composition) => composition.isEmpty
    ? c.l10n.pdfNotSet
    : composition.map((f) => '${c.number(f.pct)} % ${fiberLabel(f.fiber, c.lang)}').join(' · ');

String? _supplier(MaterialItem m) {
  final parts = [m.supplierName, m.supplierCode].whereType<String>().where((s) => s.trim().isNotEmpty);
  return parts.isEmpty ? null : parts.join(' · ');
}

/// Fiche matière A4 : données techniques, entretien, certifications. Jamais de prix, notes ni stock atelier.
Future<Uint8List> buildMaterialSheet(MaterialItem m, PdfContext c, {Uint8List? photo}) async {
  final l10n = c.l10n;
  final s = m.specs;
  final doc = pw.Document(title: '${l10n.pdfMaterialSheet} — ${m.name}', author: 'Filyxa', compress: c.compress);
  final swatchColor = _pdfColor(m.colorHex) ?? _mintPale;
  doc.addPage(pw.Page(
    pageFormat: PdfPageFormat.a4,
    margin: const pw.EdgeInsets.all(36),
    theme: c.fonts.theme,
    build: (ctx) => pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _header(c, l10n.pdfMaterialSheet),
        pw.Text(m.name, style: pw.TextStyle(font: c.fonts.title, fontSize: 21, color: _ink)),
        if (_supplier(m) != null)
          pw.Text(_supplier(m)!, style: pw.TextStyle(fontSize: 10, color: _muted, font: c.fonts.mono)),
        if (m.isLinked)
          pw.Padding(
            padding: const pw.EdgeInsets.only(top: 4),
            child: pw.Text(l10n.pdfSupplierData, style: const pw.TextStyle(fontSize: 8, color: _emerald)),
          ),
        pw.SizedBox(height: 14),
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Container(
              width: 150,
              height: 150,
              decoration: pw.BoxDecoration(
                color: swatchColor,
                border: pw.Border.all(color: _line, width: 0.5),
                image: photo == null ? null : pw.DecorationImage(image: pw.MemoryImage(photo), fit: pw.BoxFit.cover),
              ),
            ),
            pw.SizedBox(width: 20),
            pw.Expanded(
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  _label(l10n.colComposition),
                  pw.Text(_composition(c, s.composition), style: const pw.TextStyle(fontSize: 10.5)),
                  _label(l10n.pdfMaterialSheet),
                  _row(c, l10n.fieldWeight, s.weightGsm == null ? null : '${s.weightGsm} g/m²', metric: true),
                  _row(c, l10n.fieldWidth, s.widthCm == null ? null : '${s.widthCm} cm', metric: true),
                  _row(c, l10n.fieldWeave, s.weave == null ? null : weaveLabel(s.weave!, c.lang)),
                  _row(c, l10n.fieldColorName, [m.colorName, m.colorHex].whereType<String>().join(' · ')),
                  _row(c, l10n.fieldSupplier, m.supplierName),
                  _row(c, l10n.fieldSupplierCode, m.supplierCode, metric: true),
                ],
              ),
            ),
          ],
        ),
        _label('${l10n.sectionCare} (ISO 3758)'),
        s.care.isEmpty ? pw.Text(l10n.pdfNotSet, style: const pw.TextStyle(fontSize: 10)) : _care(c, s.care),
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Expanded(
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  _label(l10n.fieldCertifications),
                  pw.Text(s.certifications.isEmpty ? '-' : s.certifications.join(' · '), style: const pw.TextStyle(fontSize: 10)),
                  _label(l10n.fieldUses),
                  pw.Text(s.uses.isEmpty ? '-' : s.uses.map((u) => useLabel(u, c.lang)).join(' · '),
                      style: const pw.TextStyle(fontSize: 10)),
                ],
              ),
            ),
            if (c.shareUrl != null) ...[pw.SizedBox(width: 20), pw.Padding(padding: const pw.EdgeInsets.only(top: 16), child: _qr(c))],
          ],
        ),
        pw.Spacer(),
        _footer(c, ctx),
      ],
    ),
  ));
  return doc.save();
}

/// Dossier matières d'un ou plusieurs modèles (collection : sommaire puis un modèle par page).
/// Matières par rôle, consommation, besoin, entretien et alertes ; sans prix, notes ni stock atelier.
Future<Uint8List> buildDossier(
  List<StudioModel> models,
  Map<String, MaterialItem> materials,
  PdfContext c, {
  String? collectionName,
}) async {
  final l10n = c.l10n;
  final kind = collectionName == null ? l10n.pdfModelDossier : l10n.pdfCollectionDossier;
  final doc = pw.Document(title: '$kind — ${collectionName ?? models.first.name}', author: 'Filyxa', compress: c.compress);

  pw.Widget title(String text, {double size = 18}) =>
      pw.Text(text, style: pw.TextStyle(font: c.fonts.title, fontSize: size, color: _ink));

  pw.Widget cell(String text, {bool metric = false, bool bold = false, pw.TextAlign align = pw.TextAlign.left}) => pw.Padding(
        padding: const pw.EdgeInsets.symmetric(horizontal: 3, vertical: 4),
        child: pw.Text(text,
            textAlign: align,
            style: pw.TextStyle(fontSize: 8, font: metric ? c.fonts.mono : (bold ? c.fonts.bold : null), color: _ink)),
      );

  pw.Widget head(String text, {pw.TextAlign align = pw.TextAlign.left}) => pw.Padding(
        padding: const pw.EdgeInsets.symmetric(horizontal: 3, vertical: 4),
        child: pw.Text(text.toUpperCase(), textAlign: align, style: const pw.TextStyle(fontSize: 6.5, color: _muted, letterSpacing: 0.6)),
      );

  List<pw.Widget> modelSection(StudioModel m) {
    final alerts = [
      for (final cw in m.colorways)
        for (final a in colorwayAlerts(cw, materials)) (colorway: m.hasVariants ? cw : null, alert: a),
    ];
    final totals = requirementsByMaterial(m);
    return [
      title(m.name),
      pw.Text(
        [
          l10n.productTypeLabel(m.productType),
          if ((m.reference ?? '').isNotEmpty) m.reference!,
          '${l10n.wasteLabel} : ${c.number(m.wastePct, decimals: 2)}',
        ].join(' · '),
        style: const pw.TextStyle(fontSize: 9.5, color: _muted),
      ),
      for (final (i, cw) in m.colorways.indexed) ...[
        if (m.hasVariants || cw.quantity > 0)
          _label([if (m.hasVariants) l10n.colorwayName(cw, i), '${l10n.quantityLabel} : ${cw.quantity}'].join(' · ')),
        if (cw.lines.isEmpty)
          pw.Text(l10n.modelEmptyTitle, style: const pw.TextStyle(fontSize: 9, color: _muted))
        else
          pw.Table(
            border: const pw.TableBorder(horizontalInside: pw.BorderSide(color: _line, width: 0.5)),
            columnWidths: const {
              0: pw.FlexColumnWidth(1.3),
              1: pw.FlexColumnWidth(2.4),
              2: pw.FlexColumnWidth(2.2),
              3: pw.FlexColumnWidth(0.8),
              4: pw.FlexColumnWidth(1.7),
              5: pw.FlexColumnWidth(0.9),
              6: pw.FlexColumnWidth(0.9),
            },
            children: [
              pw.TableRow(
                decoration: const pw.BoxDecoration(color: _mintPale),
                children: [
                  head(l10n.bomRoleLabel),
                  head(l10n.pdfMaterial),
                  head(l10n.colComposition),
                  head('g/m²', align: pw.TextAlign.right),
                  head(l10n.sectionCare),
                  head(l10n.pdfConsumption, align: pw.TextAlign.right),
                  head(l10n.pdfNeed, align: pw.TextAlign.right),
                ],
              ),
              for (final line in cw.lines)
                () {
                  final mat = materials[line.materialId];
                  return pw.TableRow(
                    verticalAlignment: pw.TableCellVerticalAlignment.middle,
                    children: [
                      cell(l10n.roleText(line.role), bold: true),
                      pw.Padding(
                        padding: const pw.EdgeInsets.symmetric(horizontal: 3, vertical: 4),
                        child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                          pw.Text(mat?.name ?? l10n.materialMissing, style: const pw.TextStyle(fontSize: 8)),
                          if (mat != null && _supplier(mat) != null)
                            pw.Text(_supplier(mat)!, style: pw.TextStyle(fontSize: 6.5, color: _muted, font: c.fonts.mono)),
                        ]),
                      ),
                      cell(mat == null ? '-' : _composition(c, mat.specs.composition)),
                      cell(mat?.specs.weightGsm?.toString() ?? '-', metric: true, align: pw.TextAlign.right),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(3),
                        child: mat == null ? pw.SizedBox() : _care(c, mat.specs.care, size: 12, labels: false),
                      ),
                      cell('${c.number(line.consumption, decimals: 3)} m', metric: true, align: pw.TextAlign.right),
                      cell('${c.number(lineRequirement(line.consumption, cw.quantity, m.wastePct))} m',
                          metric: true, align: pw.TextAlign.right),
                    ],
                  );
                }(),
            ],
          ),
      ],
      if (totals.isNotEmpty) ...[
        _label(l10n.requirementTitle),
        for (final e in totals.entries)
          _row(c, materials[e.key]?.name ?? l10n.materialMissing, '${c.number(e.value)} m', metric: true),
        pw.Padding(
          padding: const pw.EdgeInsets.only(top: 3),
          child: pw.Text(l10n.requirementFormula(c.number(m.wastePct, decimals: 2)),
              style: const pw.TextStyle(fontSize: 7, color: _muted)),
        ),
      ],
      if (alerts.isNotEmpty) ...[
        _label(l10n.alertsTitle),
        for (final (:colorway, :alert) in alerts)
          pw.Container(
            margin: const pw.EdgeInsets.only(bottom: 4),
            padding: const pw.EdgeInsets.only(left: 6),
            decoration: const pw.BoxDecoration(border: pw.Border(left: pw.BorderSide(color: _warning, width: 2))),
            child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
              pw.Text(
                [if (colorway != null) l10n.colorwayName(colorway, colorway.position), l10n.alertTitle(alert)].join(' · '),
                style: pw.TextStyle(fontSize: 8.5, font: c.fonts.bold),
              ),
              pw.Text(l10n.alertBody(alert, c.lang), style: const pw.TextStyle(fontSize: 7.5, color: _muted)),
            ]),
          ),
      ],
    ];
  }

  doc.addPage(pw.MultiPage(
    pageFormat: PdfPageFormat.a4,
    margin: const pw.EdgeInsets.fromLTRB(32, 32, 32, 28),
    theme: c.fonts.theme,
    header: (ctx) => _header(c, kind),
    footer: (ctx) => _footer(c, ctx),
    build: (ctx) => [
      if (collectionName != null) ...[
        pw.Row(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
          pw.Expanded(child: title(collectionName, size: 24)),
          if (c.shareUrl != null) _qr(c),
        ]),
        _label(l10n.pdfContents),
        for (final m in models)
          _row(c, m.name, [l10n.productTypeLabel(m.productType), if ((m.reference ?? '').isNotEmpty) m.reference!].join(' · ')),
        for (final m in models) ...[pw.NewPage(), ...modelSection(m)],
      ] else ...[
        if (c.shareUrl != null) pw.Align(alignment: pw.Alignment.topRight, child: _qr(c)),
        ...modelSection(models.single),
      ],
    ],
  ));
  return doc.save();
}
