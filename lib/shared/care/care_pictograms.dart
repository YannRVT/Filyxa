/// Pictogrammes d'entretien ISO 3758 en SVG (viewBox 40×40).
///
/// Source unique utilisée par l'interface (flutter_svg) et par l'export PDF.
String careSvg(String code, {String color = '#1B2B29'}) {
  final body = _bodies[code];
  if (body == null) return '';
  return '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 40 40" '
      'fill="none" stroke="$color" stroke-width="2" stroke-linejoin="round" '
      'stroke-linecap="round">$body</svg>'
      .replaceAll('CURRENT', color);
}

const _cross = '<path d="M5 5 L35 35 M35 5 L5 35"/>';

const _tub = '<path d="M4 13 L8 34 H32 L36 13"/>'
    '<path d="M4 13 Q8 9 12 13 T20 13 T28 13 T36 13"/>';

String _num(String n) =>
    '<text x="20" y="29" font-size="11" font-family="Helvetica" '
    'text-anchor="middle" fill="CURRENT" stroke="none">$n</text>';

const _triangle = '<path d="M20 5 L36 34 H4 Z"/>';

const _square = '<rect x="5" y="5" width="30" height="30"/>';
const _tumbleCircle = '<circle cx="20" cy="20" r="11"/>';

const _iron = '<path d="M5 31 H35 L33 19 Q31 12 23 12 H13 L10 19 Z"/>';

String _dots(int n, {double y = 24}) {
  const spacing = 6.0;
  final start = 20 - (n - 1) * spacing / 2;
  return [
    for (var i = 0; i < n; i++)
      '<circle cx="${start + i * spacing}" cy="$y" r="1.6" fill="CURRENT" stroke="none"/>',
  ].join();
}

const _circle = '<circle cx="20" cy="20" r="15"/>';

String _letter(String l) =>
    '<text x="20" y="25" font-size="14" font-family="Helvetica" '
    'text-anchor="middle" fill="CURRENT" stroke="none">$l</text>';

final _bodies = <String, String>{
  'wash_30': _tub + _num('30'),
  'wash_40': _tub + _num('40'),
  'wash_60': _tub + _num('60'),
  'hand_wash': '$_tub<path d="M14 25 V19 M17 25 V17.5 M20 25 V18 M23 25 V19.5 M13 25 Q19 30 26 23"/>',
  'no_wash': _tub + _cross,
  'bleach': _triangle,
  'no_bleach': _triangle + _cross,
  'tumble_low': _square + _tumbleCircle + _dots(1, y: 20),
  'tumble_normal': _square + _tumbleCircle + _dots(2, y: 20),
  'no_tumble': _square + _tumbleCircle + _cross,
  'iron_low': _iron + _dots(1),
  'iron_medium': _iron + _dots(2),
  'iron_high': _iron + _dots(3),
  'no_iron': _iron + _cross,
  'dryclean_p': _circle + _letter('P'),
  'dryclean_f': _circle + _letter('F'),
  'wet_clean': _circle + _letter('W'),
  'no_dryclean': _circle + _cross,
};
