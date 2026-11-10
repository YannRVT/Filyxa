/// Décision de redirection du routeur, isolée pour être testée sans Flutter.
library;

/// Écrans accessibles sans être connecté.
const publicPaths = {'/login', '/invite', '/reset'};

/// Parcours qui ouvrent une session avant d'être terminés (code vérifié,
/// mot de passe encore à choisir) : on ne les interrompt pas.
const sessionFlowPaths = {'/invite', '/reset'};

enum SpaceStatus { loading, error, noOrganization, ready }

class RedirectInput {
  const RedirectInput({
    required this.location,
    required this.loggedIn,
    required this.status,
    this.isSuperadmin = false,
    this.isSupplier = false,
  });

  final String location;
  final bool loggedIn;
  final SpaceStatus status;
  final bool isSuperadmin;

  /// Organisation fournisseur : Catalogue et Compte uniquement.
  final bool isSupplier;
}

/// Écrans réservés aux ateliers.
const atelierRoots = ['/library', '/studio', '/scan', '/suppliers'];

String? decideRedirect(RedirectInput input) {
  final location = input.location;

  if (!input.loggedIn) {
    return publicPaths.contains(location) ? null : '/login';
  }
  if (sessionFlowPaths.contains(location)) return null;

  switch (input.status) {
    case SpaceStatus.loading:
    case SpaceStatus.error:
      return location == '/splash' ? null : '/splash';
    case SpaceStatus.noOrganization:
      if (input.isSuperadmin) {
        if (location.startsWith('/admin') || location == '/account') return null;
        return '/admin';
      }
      return location == '/no-organization' ? null : '/no-organization';
    case SpaceStatus.ready:
      final home = input.isSupplier ? '/catalog' : '/library';
      if (location.startsWith('/admin') && !input.isSuperadmin) return home;
      if (const {'/login', '/splash', '/no-organization', '/'}.contains(location)) return home;
      bool under(String root) => location == root || location.startsWith('$root/');
      if (input.isSupplier && atelierRoots.any(under)) return home;
      if (!input.isSupplier && under('/catalog')) return home;
      return null;
  }
}
