import 'dart:ui' show Color;

import 'package:material_ui/material_ui.dart' show HSLColor;

import 'material.dart' show normalizeHex;

/// Familles du nuancier de filtrage, déduites du code couleur de la matière.
enum ColorFamily {
  white(Color(0xFFF2EEE3), {'fr': 'Blancs & écrus', 'en': 'Whites & ecru', 'it': 'Bianchi & écru', 'es': 'Blancos y crudos', 'pt': 'Brancos e crus', 'ro': 'Albe & ecru'}),
  grey(Color(0xFF9CA3AF), {'fr': 'Gris', 'en': 'Greys', 'it': 'Grigi', 'es': 'Grises', 'pt': 'Cinzentos', 'ro': 'Gri'}),
  black(Color(0xFF1C1917), {'fr': 'Noirs', 'en': 'Blacks', 'it': 'Neri', 'es': 'Negros', 'pt': 'Pretos', 'ro': 'Negre'}),
  brown(Color(0xFF8B5E3C), {'fr': 'Bruns & camels', 'en': 'Browns & camels', 'it': 'Marroni & cammello', 'es': 'Marrones y camel', 'pt': 'Castanhos e camelo', 'ro': 'Maro & camel'}),
  red(Color(0xFFC0392B), {'fr': 'Rouges', 'en': 'Reds', 'it': 'Rossi', 'es': 'Rojos', 'pt': 'Vermelhos', 'ro': 'Roșii'}),
  orange(Color(0xFFE67E22), {'fr': 'Orangés', 'en': 'Oranges', 'it': 'Arancioni', 'es': 'Naranjas', 'pt': 'Laranjas', 'ro': 'Portocalii'}),
  yellow(Color(0xFFD4A017), {'fr': 'Jaunes & ocres', 'en': 'Yellows & ochres', 'it': 'Gialli & ocra', 'es': 'Amarillos y ocres', 'pt': 'Amarelos e ocres', 'ro': 'Galbene & ocru'}),
  green(Color(0xFF4F7942), {'fr': 'Verts', 'en': 'Greens', 'it': 'Verdi', 'es': 'Verdes', 'pt': 'Verdes', 'ro': 'Verzi'}),
  blue(Color(0xFF2E5A88), {'fr': 'Bleus', 'en': 'Blues', 'it': 'Blu', 'es': 'Azules', 'pt': 'Azuis', 'ro': 'Albastre'}),
  purple(Color(0xFF6B4C9A), {'fr': 'Violets', 'en': 'Purples', 'it': 'Viola', 'es': 'Morados', 'pt': 'Roxos', 'ro': 'Violete'}),
  pink(Color(0xFFE8A0B4), {'fr': 'Roses', 'en': 'Pinks', 'it': 'Rosa', 'es': 'Rosas', 'pt': 'Cor-de-rosa', 'ro': 'Roz'});

  const ColorFamily(this.swatch, this.labels);

  final Color swatch;
  final Map<String, String> labels;

  String label(String lang) => labels[lang] ?? labels['fr']!;
}

/// Famille de couleur d'un code #RRGGBB (null si pas de couleur).
ColorFamily? colorFamilyOf(String? hex) {
  final normalized = normalizeHex(hex);
  if (normalized == null) return null;
  final color = Color(0xFF000000 | int.parse(normalized.substring(1), radix: 16));
  final hsl = HSLColor.fromColor(color);
  final h = hsl.hue, s = hsl.saturation, l = hsl.lightness;

  if (l > 0.85 && s < 0.5) return ColorFamily.white;
  if (l < 0.15) return ColorFamily.black;
  if (s < 0.15) return l > 0.75 ? ColorFamily.white : ColorFamily.grey;
  // Teintes chaudes peu lumineuses ou désaturées : bruns, camels, écrus.
  if (h >= 15 && h < 50 && (l < 0.45 || s < 0.45)) {
    return l > 0.75 ? ColorFamily.white : ColorFamily.brown;
  }
  if (h < 15 || h >= 345) return l > 0.7 ? ColorFamily.pink : ColorFamily.red;
  if (h < 35) return ColorFamily.orange;
  if (h < 65) return ColorFamily.yellow;
  if (h < 170) return ColorFamily.green;
  if (h < 255) return ColorFamily.blue;
  if (h < 300) return ColorFamily.purple;
  return ColorFamily.pink;
}
