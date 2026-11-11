// Phase 11 : alertes du Studio (règles reprises de l'ancienne app TissuTech, étendues).
import 'package:filyxa/features/library/domain/catalog_reference.dart';
import 'package:filyxa/features/library/domain/material.dart';
import 'package:filyxa/features/reports/domain/error_report.dart';
import 'package:filyxa/features/reports/ui/report_widgets.dart';
import 'package:filyxa/features/studio/domain/alerts.dart';
import 'package:filyxa/features/studio/domain/studio.dart';
import 'package:filyxa/features/studio/ui/alert_widgets.dart';
import 'package:filyxa/features/supplier/domain/availability.dart';
import 'package:filyxa/l10n/app_localizations.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

MaterialItem _mat(String id, String name, {int? gsm, List<FiberShare> composition = const [], List<String> care = const [],
        List<String> certifications = const [], double? stock, String? ref}) =>
    MaterialItem(
      id: id,
      orgId: 'org',
      name: name,
      atelierStockM: stock,
      supplierReferenceId: ref,
      specs: TextileSpecs(weightGsm: gsm, composition: composition, care: care, certifications: certifications),
    );

// Mêmes matières que les tests de l'ancienne app.
final _wool = _mat('wool', 'Flanelle',
    gsm: 310, composition: const [FiberShare('WO', 98), FiberShare('EL', 2)], care: const ['hand_wash', 'iron_low', 'dryclean_p']);
final _cotton = _mat('cotton', 'Popeline', gsm: 115, care: const ['wash_40', 'iron_high'], certifications: const ['GOTS']);
final _viscose = _mat('viscose', 'Crêpe', gsm: 140, care: const ['wash_30', 'iron_medium']);
final _heavyLining = _mat('satin', 'Satin lourd', gsm: 350, care: const ['wash_30']);
final _interlining = _mat('inter', 'Entoilage', gsm: 60);

final _materials = {for (final m in [_wool, _cotton, _viscose, _heavyLining, _interlining]) m.id: m};

Colorway _cw(List<(String, MaterialItem)> lines, {int quantity = 0, double consumption = 1}) => Colorway(
      id: 'cw',
      quantity: quantity,
      lines: [
        for (final (i, (role, m)) in lines.indexed) BomLine(id: 'l$i', materialId: m.id, role: role, consumption: consumption),
      ],
    );

List<AlertKind> kinds(List<(String, MaterialItem)> lines) => colorwayAlerts(_cw(lines), _materials).map((a) => a.kind).toList();

void main() {
  group('règles reprises de l\'ancienne app', () {
    test('coloris vide : aucune alerte', () => expect(colorwayAlerts(const Colorway(id: 'x'), _materials), isEmpty));

    test('sans tissu principal : information', () {
      expect(kinds([('lining', _cotton)]), [AlertKind.noMain]);
    });

    test('doublure plus lourde que le tissu principal', () {
      expect(kinds([('main', _viscose), ('lining', _heavyLining)]), contains(AlertKind.liningHeavier));
      expect(kinds([('main', _wool), ('lining', _viscose)]), isNot(contains(AlertKind.liningHeavier)));
    });

    test('tissu stretch avec doublure rigide', () {
      expect(kinds([('main', _wool), ('lining', _viscose)]), contains(AlertKind.stretchRigidLining));
    });

    test('thermocollage sur tissu à repassage doux', () {
      expect(kinds([('main', _wool), ('interfacing', _interlining)]), contains(AlertKind.fusingRisky));
      expect(
        colorwayAlerts(_cw([('main', _cotton), ('interfacing', _interlining)]), _materials)
            .where((a) => a.family != AlertFamily.certification),
        isEmpty,
      );
    });

    test('entretiens incompatibles : lavage main + machine', () {
      expect(kinds([('main', _wool), ('contrast', _cotton)]), contains(AlertKind.careMachineConflict));
    });

    test('températures de lavage différentes', () {
      final alerts = colorwayAlerts(_cw([('main', _cotton), ('contrast', _viscose)]), _materials);
      final wash = alerts.singleWhere((a) => a.kind == AlertKind.washTempLimited);
      expect(wash.values['temp'], 30);
      expect(wash.subjects.single.name, 'Crêpe');
    });
  });

  group('règles étendues', () {
    test('rôles d\'une chaussure : la tige joue le tissu principal', () {
      expect(kinds([('upper', _viscose), ('lining', _heavyLining)]), contains(AlertKind.liningHeavier));
    });

    test('entoilage plus lourd que le tissu principal', () {
      final light = _mat('voile', 'Voile', gsm: 40);
      final m = {..._materials, light.id: light};
      final alerts = colorwayAlerts(_cw([('main', light), ('interfacing', _interlining)]), m);
      expect(alerts.map((a) => a.kind), contains(AlertKind.interfacingHeavier));
    });

    test('repassage limité par la matière la plus fragile', () {
      final iron = colorwayAlerts(_cw([('main', _cotton), ('contrast', _viscose)]), _materials)
          .singleWhere((a) => a.kind == AlertKind.ironLimited);
      expect(iron.values['temp'], 150);
    });

    test('sèche-linge interdit pour une matière, autorisé pour une autre', () {
      final a = _mat('a', 'A', care: const ['no_tumble']);
      final b = _mat('b', 'B', care: const ['tumble_low']);
      expect(colorwayAlerts(_cw([('main', a), ('lining', b)]), {'a': a, 'b': b}).map((x) => x.kind), contains(AlertKind.tumbleConflict));
    });

    test('certification du tissu principal non tenue par la doublure', () {
      final alert = colorwayAlerts(_cw([('main', _cotton), ('lining', _viscose)]), _materials)
          .singleWhere((a) => a.kind == AlertKind.certificationGap);
      expect(alert.values['certification'], 'GOTS');
      expect(alert.subjects.single.name, 'Crêpe');
    });

    test('consommation non saisie', () {
      final alerts = colorwayAlerts(_cw([('main', _cotton)], consumption: 0), _materials);
      expect(alerts.map((a) => a.kind), contains(AlertKind.consumptionMissing));
    });

    test('déterministe : mêmes entrées, mêmes alertes, même ordre', () {
      final lines = [('main', _wool), ('lining', _heavyLining), ('interfacing', _interlining), ('contrast', _cotton)];
      final a = colorwayAlerts(_cw(lines), _materials).map((x) => x.toString()).toList();
      final b = colorwayAlerts(_cw(lines), _materials).map((x) => x.toString()).toList();
      expect(a, b);
      expect(a, isNotEmpty);
    });
  });

  group('stock : besoin, puis stock atelier, puis fournisseur', () {
    // Besoin : 1,8 m × 100 pièces × 1,08 = 194,4 m.
    StudioModel model(MaterialItem m) => StudioModel(
          id: 'mod',
          collectionId: 'c',
          name: 'Veste',
          productType: ProductType.garment,
          colorways: [Colorway(id: 'cw', quantity: 100, lines: [BomLine(id: 'l', materialId: m.id, role: 'main', consumption: 1.8)])],
        );
    CatalogReference ref({AvailabilityStatus? status, double? stock, int? lead}) => CatalogReference(
          id: 'r1',
          supplierOrgId: 's',
          supplierName: 'Tissage',
          code: 'T-1',
          name: 'Sergé',
          status: status,
          stockM: stock,
          leadTimeWeeks: lead,
        );
    List<StudioAlert> alertsFor(MaterialItem m, {CatalogReference? reference}) =>
        stockAlerts(model(m), {m.id: m}, {?reference?.id: ?reference});

    test('stock atelier suffisant : aucune alerte', () {
      expect(alertsFor(_mat('m', 'Sergé', stock: 200)), isEmpty);
    });

    test('fiche propre à l\'atelier : stock atelier insuffisant', () {
      final a = alertsFor(_mat('m', 'Sergé', stock: 50)).single;
      expect(a.kind, AlertKind.stockAtelierShort);
      expect(a.values['need'], closeTo(194.4, 1e-9));
      expect(a.values['atelier'], 50);
    });

    test('quantité exacte : le fournisseur couvre ou non le complément', () {
      final m = _mat('m', 'Sergé', stock: 50, ref: 'r1');
      expect(alertsFor(m, reference: ref(status: AvailabilityStatus.available, stock: 340)).single.kind, AlertKind.stockSupplierCovered);
      expect(alertsFor(m, reference: ref(status: AvailabilityStatus.low, stock: 100)).single.kind, AlertKind.stockSupplierShort);
    });

    test('paliers : stock faible, sur commande, rupture, masqué', () {
      final m = _mat('m', 'Sergé', ref: 'r1');
      expect(alertsFor(m, reference: ref(status: AvailabilityStatus.available)).single.kind, AlertKind.stockSupplierCovered);
      expect(alertsFor(m, reference: ref(status: AvailabilityStatus.low)).single.kind, AlertKind.stockSupplierLow);
      expect(alertsFor(m, reference: ref(status: AvailabilityStatus.onOrder, lead: 6)).single.kind, AlertKind.stockSupplierOnOrder);
      expect(alertsFor(m, reference: ref(status: AvailabilityStatus.outOfStock)).single.level, AlertLevel.critical);
      expect(alertsFor(m, reference: ref()).single.kind, AlertKind.stockSupplierHidden);
    });

    test('référence retirée : alerte critique', () {
      expect(alertsFor(_mat('m', 'Sergé', stock: 500, ref: 'r1')).single.kind, AlertKind.referenceRetired);
    });
  });

  group('textes', () {
    late AppLocalizations l10n;
    setUpAll(() async => l10n = await AppLocalizations.delegate.load(const Locale('fr')));

    test('chaque alerte cite les valeurs en cause', () {
      final dry = _mat('dry', 'Satin', care: const ['no_wash', 'dryclean_p']);
      final main = _mat('main', 'Sergé', care: const ['wash_30']);
      final a = colorwayAlerts(_cw([('main', main), ('lining', dry)]), {'dry': dry, 'main': main})
          .singleWhere((x) => x.kind == AlertKind.careMachineConflict);
      expect(l10n.alertTitle(a), 'Entretiens incompatibles');
      expect(
        l10n.alertBody(a, 'fr'),
        'Doublure « Satin » : Ne pas laver, Nettoyage à sec (P). Tissu principal « Sergé » : Lavage 30 °C. '
        "L'étiquette du produit devra imposer l'entretien le plus restrictif.",
      );
    });

    test('stock : besoin, stock atelier et complément chiffrés', () {
      const a = StudioAlert(AlertKind.stockSupplierCovered,
          subjects: [AlertSubject(materialId: 'm', name: 'Sergé')], values: {'need': 194.4, 'atelier': 50.0, 'supplier': 340.0});
      expect(l10n.alertBody(a, 'fr'),
          'Sergé : besoin 194,4 m, stock atelier 50 m. Le complément (144,4 m) est disponible chez le fournisseur (340 m en stock).'.replaceFirst('Sergé', '« Sergé »'));
    });

    test('notifications de stock : texte et modèles concernés', () {
      final n = AppNotification(
        id: 'n',
        kind: NotificationKind.stockOut,
        materialId: 'm',
        data: const {'name': 'Mon sergé', 'code': 'TD-SRG-280', 'models': [{'id': 'mod1', 'name': 'Veste Arno'}]},
        createdAt: DateTime(2026, 11, 11),
      );
      expect(l10n.notificationText(n), 'Mon sergé : rupture chez le fournisseur (TD-SRG-280)');
      expect(n.models.single.id, 'mod1');
    });
  });
}
