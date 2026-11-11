import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:printing/printing.dart';

import '../../app/theme.dart';
import '../../l10n/l10n.dart';
import '../library/data/materials_repository.dart';
import '../library/domain/material.dart';
import '../studio/data/studio_repository.dart';
import '../studio/domain/studio.dart';
import 'pdf_documents.dart';

/// Langues proposées pour le PDF, avec leur nom dans leur propre langue.
const pdfLanguages = {'fr': 'Français', 'en': 'English', 'it': 'Italiano', 'es': 'Español', 'pt': 'Português', 'ro': 'Română'};

/// Génère un PDF dans une langue donnée (indépendante de celle de l'interface).
typedef PdfBuilder = Future<Uint8List> Function(PdfContext context);

/// Aperçu du PDF avec choix de la langue, impression, partage et téléchargement
/// (iOS, Android et Web, via le paquet printing).
class ExportScreen extends StatefulWidget {
  const ExportScreen({super.key, required this.title, required this.fileName, required this.build, this.shareUrl});

  final String title;

  /// Nom du fichier sans extension.
  final String fileName;
  final PdfBuilder build;
  final String? shareUrl;

  @override
  State<ExportScreen> createState() => _ExportScreenState();
}

class _ExportScreenState extends State<ExportScreen> {
  String? _lang;
  PdfFonts? _fonts;
  String? _symbol;

  Future<Uint8List> _generate(String lang) async {
    _fonts ??= await PdfFonts.load();
    _symbol ??= await rootBundle.loadString('assets/brand/filyxa-symbol.svg').catchError((_) => '');
    return widget.build(PdfContext(
      l10n: lookupAppLocalizations(Locale(lang)),
      lang: lang,
      fonts: _fonts!,
      date: DateTime.now(),
      symbolSvg: (_symbol ?? '').isEmpty ? null : _symbol,
      shareUrl: widget.shareUrl,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final uiLang = Localizations.localeOf(context).languageCode;
    final lang = _lang ?? (pdfLanguages.containsKey(uiLang) ? uiLang : 'fr');
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          Tooltip(
            message: l10n.pdfLanguage,
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: lang,
                icon: const Icon(Icons.translate, size: 18),
                items: [
                  for (final e in pdfLanguages.entries) DropdownMenuItem(value: e.key, child: Text(e.value)),
                ],
                onChanged: (v) => setState(() => _lang = v),
              ),
            ),
          ),
          const SizedBox(width: FxSpace.md),
        ],
      ),
      body: PdfPreview(
        key: ValueKey(lang),
        build: (_) => _generate(lang),
        pdfFileName: '${widget.fileName}-$lang.pdf',
        canChangeOrientation: false,
        canChangePageFormat: false,
        canDebug: false,
        loadingWidget: const Center(child: CircularProgressIndicator()),
        onError: (_, _) => Center(child: Text(l10n.pdfGenerationError)),
      ),
    );
  }
}

String slug(String s) => s
    .toLowerCase()
    .replaceAll(RegExp(r'[àâä]'), 'a')
    .replaceAll(RegExp(r'[éèêë]'), 'e')
    .replaceAll(RegExp(r'[îï]'), 'i')
    .replaceAll(RegExp(r'[ôö]'), 'o')
    .replaceAll(RegExp(r'[ùûü]'), 'u')
    .replaceAll('ç', 'c')
    .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
    .replaceAll(RegExp(r'^-|-$'), '');

/// Fiche matière A4 (photo si disponible).
void openMaterialExport(BuildContext context, WidgetRef ref, MaterialItem material, {String? shareUrl}) {
  final repo = ref.read(materialsRepositoryProvider);
  Navigator.of(context).push(MaterialPageRoute(
    builder: (_) => ExportScreen(
      title: context.l10n.pdfMaterialSheet,
      fileName: 'fiche-${slug(material.name)}',
      shareUrl: shareUrl,
      build: (c) async {
        Uint8List? photo;
        if (material.photoPath != null) {
          try {
            photo = await repo.downloadPhoto(material.photoPath!);
          } catch (_) {
            // La fiche reste exportable sans photo.
          }
        }
        return buildMaterialSheet(material, c, photo: photo);
      },
    ),
  ));
}

/// Dossier matières d'un modèle.
void openModelExport(BuildContext context, WidgetRef ref, StudioModel model, {String? shareUrl}) {
  final materials = {for (final m in ref.read(materialsProvider).value ?? const <MaterialItem>[]) m.id: m};
  Navigator.of(context).push(MaterialPageRoute(
    builder: (_) => ExportScreen(
      title: context.l10n.pdfModelDossier,
      fileName: 'dossier-${slug(model.name)}',
      shareUrl: shareUrl,
      build: (c) => buildDossier([model], materials, c),
    ),
  ));
}

/// Dossier matières d'une collection : tous ses modèles.
void openCollectionExport(BuildContext context, WidgetRef ref, StudioCollection collection, {String? shareUrl}) {
  final materials = {for (final m in ref.read(materialsProvider).value ?? const <MaterialItem>[]) m.id: m};
  final repo = ref.read(studioRepositoryProvider);
  Navigator.of(context).push(MaterialPageRoute(
    builder: (_) => ExportScreen(
      title: context.l10n.pdfCollectionDossier,
      fileName: 'dossier-${slug(collection.name)}',
      shareUrl: shareUrl,
      build: (c) async => buildDossier(await repo.models(collection.id), materials, c, collectionName: collection.name),
    ),
  ));
}
