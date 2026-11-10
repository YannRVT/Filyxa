import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app/theme.dart';
import '../../../shared/care/care_pictograms.dart';
import '../data/materials_repository.dart';
import '../domain/catalog.dart';
import '../domain/material.dart';

String langOf(BuildContext context) => Localizations.localeOf(context).languageCode;

Color? colorFromHex(String? hex) {
  final normalized = normalizeHex(hex);
  if (normalized == null) return null;
  return Color(0xFF000000 | int.parse(normalized.substring(1), radix: 16));
}

/// La matière d'abord : photo, sinon aplat du coloris, sinon motif neutre.
class MaterialVisual extends ConsumerWidget {
  const MaterialVisual({super.key, required this.material, this.radius = FxRadius.md, this.iconSize = 28});

  final MaterialItem material;
  final double radius;
  final double iconSize;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final color = colorFromHex(material.colorHex);
    final fallback = Container(
      color: color ?? FxColors.mintPale,
      alignment: Alignment.center,
      child: color == null ? Icon(Icons.texture, color: FxColors.emeraldInk, size: iconSize) : null,
    );
    final path = material.photoPath;
    Widget child = fallback;
    if (path != null) {
      final url = ref.watch(photoUrlProvider(path)).value;
      if (url != null) {
        child = Image.network(
          url,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => fallback,
          loadingBuilder: (_, image, progress) => progress == null ? image : fallback,
        );
      }
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: Semantics(image: true, label: material.colorName ?? material.name, child: child),
    );
  }
}

/// Pictogramme d'entretien ISO 3758 avec son libellé en infobulle.
class CareIcon extends StatelessWidget {
  const CareIcon(this.code, {super.key, this.size = 28});

  final String code;
  final double size;

  @override
  Widget build(BuildContext context) {
    final svg = careSvg(code);
    final label = careCode(code)?.label(langOf(context)) ?? code;
    return Tooltip(
      message: label,
      child: Semantics(
        label: label,
        child: svg.isEmpty
            ? SizedBox.square(dimension: size)
            : SvgPicture.string(svg, width: size, height: size),
      ),
    );
  }
}

/// Texte technique en police d'étiquette (codes, compositions).
class TechText extends StatelessWidget {
  const TechText(this.text, {super.key, this.size = 13, this.color, this.maxLines});

  final String text;
  final double size;
  final Color? color;
  final int? maxLines;

  @override
  Widget build(BuildContext context) => Text(
        text,
        maxLines: maxLines,
        overflow: maxLines == null ? null : TextOverflow.ellipsis,
        style: FxTheme.mono(size: size, color: color),
      );
}

class TagChip extends StatelessWidget {
  const TagChip(this.label, {super.key});

  final String label;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: FxColors.mintPale,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(label, style: const TextStyle(color: FxColors.petrol, fontSize: 13, fontWeight: FontWeight.w500)),
      );
}

/// « Dormeuil · DR4521 », ou null si rien n'est renseigné.
String? supplierLine(MaterialItem m) {
  final parts = [m.supplierName, m.supplierCode].whereType<String>().where((s) => s.trim().isNotEmpty);
  return parts.isEmpty ? null : parts.join(' · ');
}
