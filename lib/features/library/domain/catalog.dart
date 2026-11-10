/// Vocabulaire normalisé des matières : la base stocke des codes, l'app les traduit.
/// Ainsi une fiche saisie en français s'affiche correctement dans les 6 langues.
library;

/// Entrée de vocabulaire : un code stable et son libellé par langue (fr, en, it, es, pt, ro).
class CatalogEntry {
  const CatalogEntry(this.code, this.labels);

  final String code;
  final Map<String, String> labels;

  String label(String languageCode) => labels[languageCode] ?? labels['fr'] ?? code;
}

Map<String, String> _l(String fr, String en, String it, String es, String pt, String ro) =>
    {'fr': fr, 'en': en, 'it': it, 'es': es, 'pt': pt, 'ro': ro};

CatalogEntry? _find(List<CatalogEntry> list, String? code) {
  for (final e in list) {
    if (e.code == code) return e;
  }
  return null;
}

/// Fibres textiles, codes ISO 2076 / règlement UE 1007/2011.
final fibers = <CatalogEntry>[
  CatalogEntry('CO', _l('Coton', 'Cotton', 'Cotone', 'Algodón', 'Algodão', 'Bumbac')),
  CatalogEntry('LI', _l('Lin', 'Linen', 'Lino', 'Lino', 'Linho', 'In')),
  CatalogEntry('HA', _l('Chanvre', 'Hemp', 'Canapa', 'Cáñamo', 'Cânhamo', 'Cânepă')),
  CatalogEntry('RA', _l('Ramie', 'Ramie', 'Ramié', 'Ramio', 'Rami', 'Ramie')),
  CatalogEntry('WO', _l('Laine', 'Wool', 'Lana', 'Lana', 'Lã', 'Lână')),
  CatalogEntry('WS', _l('Cachemire', 'Cashmere', 'Cashmere', 'Cachemir', 'Caxemira', 'Cașmir')),
  CatalogEntry('WM', _l('Mohair', 'Mohair', 'Mohair', 'Mohair', 'Mohair', 'Mohair')),
  CatalogEntry('WA', _l('Alpaga', 'Alpaca', 'Alpaca', 'Alpaca', 'Alpaca', 'Alpaca')),
  CatalogEntry('SE', _l('Soie', 'Silk', 'Seta', 'Seda', 'Seda', 'Mătase')),
  CatalogEntry('CV', _l('Viscose', 'Viscose', 'Viscosa', 'Viscosa', 'Viscose', 'Viscoză')),
  CatalogEntry('CMD', _l('Modal', 'Modal', 'Modal', 'Modal', 'Modal', 'Modal')),
  CatalogEntry('CLY', _l('Lyocell', 'Lyocell', 'Lyocell', 'Lyocell', 'Lyocell', 'Lyocell')),
  CatalogEntry('CUP', _l('Cupro', 'Cupro', 'Cupro', 'Cupro', 'Cupro', 'Cupro')),
  CatalogEntry('CA', _l('Acétate', 'Acetate', 'Acetato', 'Acetato', 'Acetato', 'Acetat')),
  CatalogEntry('PES', _l('Polyester', 'Polyester', 'Poliestere', 'Poliéster', 'Poliéster', 'Poliester')),
  CatalogEntry('PA', _l('Polyamide', 'Polyamide', 'Poliammide', 'Poliamida', 'Poliamida', 'Poliamidă')),
  CatalogEntry('PAN', _l('Acrylique', 'Acrylic', 'Acrilico', 'Acrílico', 'Acrílico', 'Acril')),
  CatalogEntry('EL', _l('Élasthanne', 'Elastane', 'Elastan', 'Elastano', 'Elastano', 'Elastan')),
  CatalogEntry('PP', _l('Polypropylène', 'Polypropylene', 'Polipropilene', 'Polipropileno', 'Polipropileno', 'Polipropilenă')),
  CatalogEntry('OT', _l('Autres fibres', 'Other fibres', 'Altre fibre', 'Otras fibras', 'Outras fibras', 'Alte fibre')),
];

/// Armures et structures.
final weaves = <CatalogEntry>[
  CatalogEntry('plain', _l('Toile', 'Plain weave', 'Tela', 'Tafetán', 'Tafetá', 'Pânză')),
  CatalogEntry('twill', _l('Sergé', 'Twill', 'Saia', 'Sarga', 'Sarja', 'Diagonal')),
  CatalogEntry('satin', _l('Satin', 'Satin', 'Raso', 'Raso', 'Cetim', 'Satin')),
  CatalogEntry('dobby', _l('Armuré', 'Dobby', 'Operato', 'Labrado', 'Maquineta', 'Dobby')),
  CatalogEntry('jacquard', _l('Jacquard', 'Jacquard', 'Jacquard', 'Jacquard', 'Jacquard', 'Jacquard')),
  CatalogEntry('jersey', _l('Jersey', 'Jersey', 'Jersey', 'Punto jersey', 'Jersey', 'Jerseu')),
  CatalogEntry('rib', _l('Côte', 'Rib knit', 'Costina', 'Canalé', 'Canelado', 'Rips')),
  CatalogEntry('fleece', _l('Molleton', 'Fleece', 'Felpa', 'Muletón', 'Moletão', 'Molton')),
  CatalogEntry('velvet', _l('Velours', 'Velvet', 'Velluto', 'Terciopelo', 'Veludo', 'Catifea')),
  CatalogEntry('corduroy', _l('Velours côtelé', 'Corduroy', 'Velluto a coste', 'Pana', 'Bombazina', 'Reiat')),
  CatalogEntry('crepe', _l('Crêpe', 'Crepe', 'Crêpe', 'Crepé', 'Crepe', 'Crep')),
  CatalogEntry('gauze', _l('Gaze', 'Gauze', 'Garza', 'Gasa', 'Gaze', 'Tifon')),
  CatalogEntry('lace', _l('Dentelle', 'Lace', 'Pizzo', 'Encaje', 'Renda', 'Dantelă')),
  CatalogEntry('nonwoven', _l('Non-tissé', 'Nonwoven', 'Tessuto non tessuto', 'No tejido', 'Não tecido', 'Netesut')),
];

/// Usages recommandés.
final uses = <CatalogEntry>[
  CatalogEntry('shirt', _l('Chemise', 'Shirt', 'Camicia', 'Camisa', 'Camisa', 'Cămașă')),
  CatalogEntry('dress', _l('Robe', 'Dress', 'Abito', 'Vestido', 'Vestido', 'Rochie')),
  CatalogEntry('skirt', _l('Jupe', 'Skirt', 'Gonna', 'Falda', 'Saia', 'Fustă')),
  CatalogEntry('trousers', _l('Pantalon', 'Trousers', 'Pantaloni', 'Pantalón', 'Calças', 'Pantaloni')),
  CatalogEntry('jacket', _l('Veste', 'Jacket', 'Giacca', 'Chaqueta', 'Casaco', 'Sacou')),
  CatalogEntry('coat', _l('Manteau', 'Coat', 'Cappotto', 'Abrigo', 'Sobretudo', 'Palton')),
  CatalogEntry('knitwear', _l('Maille', 'Knitwear', 'Maglieria', 'Punto', 'Malhas', 'Tricotaje')),
  CatalogEntry('lining', _l('Doublure', 'Lining', 'Fodera', 'Forro', 'Forro', 'Căptușeală')),
  CatalogEntry('interlining', _l('Entoilage', 'Interlining', 'Teletta', 'Entretela', 'Entretela', 'Întăritură')),
  CatalogEntry('lingerie', _l('Lingerie', 'Lingerie', 'Intimo', 'Lencería', 'Lingerie', 'Lenjerie')),
  CatalogEntry('sportswear', _l('Sport', 'Sportswear', 'Abbigliamento sportivo', 'Ropa deportiva', 'Desporto', 'Îmbrăcăminte sport')),
  CatalogEntry('footwear', _l('Chaussure', 'Footwear', 'Calzature', 'Calzado', 'Calçado', 'Încălțăminte')),
  CatalogEntry('bags', _l('Maroquinerie', 'Bags & leather goods', 'Pelletteria', 'Marroquinería', 'Marroquinaria', 'Marochinărie')),
  CatalogEntry('accessories', _l('Accessoires', 'Accessories', 'Accessori', 'Accesorios', 'Acessórios', 'Accesorii')),
  CatalogEntry('home', _l('Maison', 'Home', 'Casa', 'Hogar', 'Casa', 'Casă')),
];

/// Labels et certifications : noms propres, identiques dans toutes les langues.
const certifications = <String>[
  'GOTS', 'OEKO-TEX', 'GRS', 'RCS', 'OCS', 'RWS', 'RMS', 'RAF',
  'FSC', 'bluesign', 'EU Ecolabel', 'Cradle to Cradle',
];

String fiberLabel(String code, String lang) => _find(fibers, code)?.label(lang) ?? code;
String weaveLabel(String code, String lang) => _find(weaves, code)?.label(lang) ?? code;
String useLabel(String code, String lang) => _find(uses, code)?.label(lang) ?? code;

/// Familles de symboles d'entretien (ISO 3758) ; une seule valeur par famille.
enum CareFamily { wash, bleach, dry, iron, professional }

class CareCode {
  const CareCode(this.code, this.family, this.labels);

  final String code;
  final CareFamily family;
  final Map<String, String> labels;

  String label(String lang) => labels[lang] ?? labels['fr'] ?? code;
}

Map<String, String> _temp(String fr, String en, String it, String es, String pt, String ro, String t) =>
    _l('$fr $t', '$en $t', '$it $t', '$es $t', '$pt $t', '$ro $t');

final careCodes = <CareCode>[
  CareCode('wash_30', CareFamily.wash, _temp('Lavage', 'Wash', 'Lavaggio', 'Lavado', 'Lavagem', 'Spălare', '30 °C')),
  CareCode('wash_40', CareFamily.wash, _temp('Lavage', 'Wash', 'Lavaggio', 'Lavado', 'Lavagem', 'Spălare', '40 °C')),
  CareCode('wash_60', CareFamily.wash, _temp('Lavage', 'Wash', 'Lavaggio', 'Lavado', 'Lavagem', 'Spălare', '60 °C')),
  CareCode('hand_wash', CareFamily.wash, _l('Lavage à la main', 'Hand wash', 'Lavaggio a mano', 'Lavado a mano', 'Lavagem à mão', 'Spălare manuală')),
  CareCode('no_wash', CareFamily.wash, _l('Ne pas laver', 'Do not wash', 'Non lavare', 'No lavar', 'Não lavar', 'Nu se spală')),
  CareCode('bleach', CareFamily.bleach, _l('Blanchiment autorisé', 'Bleaching allowed', 'Candeggio consentito', 'Se permite lejía', 'Branqueamento permitido', 'Albire permisă')),
  CareCode('no_bleach', CareFamily.bleach, _l('Pas de blanchiment', 'Do not bleach', 'Non candeggiare', 'No usar lejía', 'Não branquear', 'Nu se albește')),
  CareCode('tumble_low', CareFamily.dry, _l('Sèche-linge basse température', 'Tumble dry low', 'Asciugatrice a bassa temperatura', 'Secadora a baja temperatura', 'Máquina de secar a baixa temperatura', 'Uscător la temperatură joasă')),
  CareCode('tumble_normal', CareFamily.dry, _l('Sèche-linge température normale', 'Tumble dry normal', 'Asciugatrice a temperatura normale', 'Secadora a temperatura normal', 'Máquina de secar a temperatura normal', 'Uscător la temperatură normală')),
  CareCode('no_tumble', CareFamily.dry, _l('Pas de sèche-linge', 'Do not tumble dry', 'Non asciugare in asciugatrice', 'No usar secadora', 'Não usar máquina de secar', 'Nu se usucă în uscător')),
  CareCode('iron_low', CareFamily.iron, _l('Repassage doux (110 °C)', 'Iron low (110 °C)', 'Stiro a bassa temperatura (110 °C)', 'Planchado suave (110 °C)', 'Engomar a baixa temperatura (110 °C)', 'Călcare la temperatură joasă (110 °C)')),
  CareCode('iron_medium', CareFamily.iron, _l('Repassage moyen (150 °C)', 'Iron medium (150 °C)', 'Stiro a media temperatura (150 °C)', 'Planchado medio (150 °C)', 'Engomar a média temperatura (150 °C)', 'Călcare la temperatură medie (150 °C)')),
  CareCode('iron_high', CareFamily.iron, _l('Repassage chaud (200 °C)', 'Iron high (200 °C)', 'Stiro ad alta temperatura (200 °C)', 'Planchado fuerte (200 °C)', 'Engomar a alta temperatura (200 °C)', 'Călcare la temperatură ridicată (200 °C)')),
  CareCode('no_iron', CareFamily.iron, _l('Ne pas repasser', 'Do not iron', 'Non stirare', 'No planchar', 'Não engomar', 'Nu se calcă')),
  CareCode('dryclean_p', CareFamily.professional, _l('Nettoyage à sec (P)', 'Dry clean (P)', 'Lavaggio a secco (P)', 'Limpieza en seco (P)', 'Limpeza a seco (P)', 'Curățare chimică (P)')),
  CareCode('dryclean_f', CareFamily.professional, _l('Nettoyage à sec (F)', 'Dry clean (F)', 'Lavaggio a secco (F)', 'Limpieza en seco (F)', 'Limpeza a seco (F)', 'Curățare chimică (F)')),
  CareCode('wet_clean', CareFamily.professional, _l("Nettoyage à l'eau professionnel (W)", 'Professional wet clean (W)', 'Lavaggio ad acqua professionale (W)', 'Limpieza húmeda profesional (W)', 'Limpeza profissional a húmido (W)', 'Curățare profesională umedă (W)')),
  CareCode('no_dryclean', CareFamily.professional, _l('Pas de nettoyage à sec', 'Do not dry clean', 'Non lavare a secco', 'No limpiar en seco', 'Não limpar a seco', 'Nu se curăță chimic')),
];

final careFamilyLabels = <CareFamily, Map<String, String>>{
  CareFamily.wash: _l('Lavage', 'Washing', 'Lavaggio', 'Lavado', 'Lavagem', 'Spălare'),
  CareFamily.bleach: _l('Blanchiment', 'Bleaching', 'Candeggio', 'Blanqueo', 'Branqueamento', 'Albire'),
  CareFamily.dry: _l('Séchage', 'Drying', 'Asciugatura', 'Secado', 'Secagem', 'Uscare'),
  CareFamily.iron: _l('Repassage', 'Ironing', 'Stiratura', 'Planchado', 'Engomar', 'Călcare'),
  CareFamily.professional: _l('Entretien professionnel', 'Professional care', 'Manutenzione professionale', 'Limpieza profesional', 'Limpeza profissional', 'Curățare profesională'),
};

CareCode? careCode(String code) {
  for (final c in careCodes) {
    if (c.code == code) return c;
  }
  return null;
}

/// Ordre d'affichage normalisé des symboles d'entretien (lavage → professionnel).
List<String> sortCare(Iterable<String> codes) => [...codes]
  ..sort((a, b) => (careCode(a)?.family.index ?? 99).compareTo(careCode(b)?.family.index ?? 99));
