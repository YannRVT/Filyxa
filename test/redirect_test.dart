import 'package:filyxa/app/redirect.dart';
import 'package:flutter_test/flutter_test.dart';

String? go(String location, {bool loggedIn = true, SpaceStatus status = SpaceStatus.ready, bool superadmin = false, bool supplier = false}) =>
    decideRedirect(RedirectInput(
      location: location,
      loggedIn: loggedIn,
      status: status,
      isSuperadmin: superadmin,
      isSupplier: supplier,
    ));

void main() {
  group('hors connexion', () {
    test('les écrans privés renvoient vers la connexion', () {
      expect(go('/library', loggedIn: false), '/login');
      expect(go('/admin', loggedIn: false), '/login');
    });

    test('connexion, invitation et réinitialisation restent accessibles', () {
      expect(go('/login', loggedIn: false), isNull);
      expect(go('/invite', loggedIn: false), isNull);
      expect(go('/reset', loggedIn: false), isNull);
    });
  });

  group('connecté', () {
    test('un parcours d\'invitation ou de réinitialisation en cours n\'est pas interrompu', () {
      expect(go('/invite', status: SpaceStatus.noOrganization), isNull);
      expect(go('/reset', status: SpaceStatus.loading), isNull);
    });

    test('pendant le chargement de l\'espace : écran d\'attente', () {
      expect(go('/library', status: SpaceStatus.loading), '/splash');
      expect(go('/splash', status: SpaceStatus.loading), isNull);
      expect(go('/library', status: SpaceStatus.error), '/splash');
    });

    test('sans organisation : écran dédié, sauf pour le super-admin', () {
      expect(go('/library', status: SpaceStatus.noOrganization), '/no-organization');
      expect(go('/library', status: SpaceStatus.noOrganization, superadmin: true), '/admin');
      expect(go('/admin', status: SpaceStatus.noOrganization, superadmin: true), isNull);
      expect(go('/account', status: SpaceStatus.noOrganization, superadmin: true), isNull);
    });

    test('espace prêt : la connexion et l\'attente mènent à TissuTech', () {
      expect(go('/login'), '/library');
      expect(go('/splash'), '/library');
      expect(go('/no-organization'), '/library');
      expect(go('/studio'), isNull);
    });

    test('la console super-admin est refusée aux autres comptes', () {
      expect(go('/admin'), '/library');
      expect(go('/admin', superadmin: true), isNull);
    });
  });

  group('fournisseur', () {
    test('arrive sur son catalogue', () {
      expect(go('/login', supplier: true), '/catalog');
      expect(go('/splash', supplier: true), '/catalog');
    });

    test('n\'accède pas aux écrans atelier', () {
      expect(go('/library', supplier: true), '/catalog');
      expect(go('/library/m1', supplier: true), '/catalog');
      expect(go('/scan', supplier: true), '/catalog');
      expect(go('/catalog/import', supplier: true), isNull);
      expect(go('/account/members', supplier: true), isNull);
    });

    test('un atelier n\'accède pas au catalogue fournisseur', () {
      expect(go('/catalog'), '/library');
      expect(go('/catalog/settings'), '/library');
    });
  });
}
