import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/supabase.dart';
import '../features/account/account_screen.dart';
import '../features/admin/ui/admin_screen.dart';
import '../features/auth/ui/invite_screen.dart';
import '../features/auth/ui/login_screen.dart';
import '../features/auth/ui/reset_screen.dart';
import '../features/members/ui/members_screen.dart';
import '../features/session/data/user_space_repository.dart';
import '../features/session/domain/user_space.dart';
import '../features/session/ui/session_screens.dart';
import '../l10n/l10n.dart';
import '../shared/widgets/section_placeholder.dart';
import 'app_shell.dart';
import 'redirect.dart';

SpaceStatus spaceStatusOf(AsyncValue<UserSpace?> space) {
  if (space.hasError) return SpaceStatus.error;
  final value = space.value;
  if (value == null) return SpaceStatus.loading;
  return value.hasOrganization ? SpaceStatus.ready : SpaceStatus.noOrganization;
}

final routerProvider = Provider<GoRouter>((ref) {
  final auth = ref.watch(supabaseProvider).auth;
  final refresh = _RefreshNotifier(auth.onAuthStateChange);
  ref.listen(userSpaceProvider, (_, _) => refresh.ping());
  ref.onDispose(refresh.dispose);

  Widget placeholder(BuildContext context, String Function(AppLocalizations) title, IconData icon) =>
      SectionPlaceholder(title: title(context.l10n), icon: icon);

  return GoRouter(
    initialLocation: '/library',
    refreshListenable: refresh,
    redirect: (context, state) {
      final space = ref.read(userSpaceProvider);
      return decideRedirect(RedirectInput(
        location: state.matchedLocation,
        loggedIn: auth.currentSession != null,
        status: spaceStatusOf(space),
        isSuperadmin: space.value?.profile.isSuperadmin ?? false,
      ));
    },
    routes: [
      GoRoute(path: '/login', builder: (_, _) => const LoginScreen()),
      GoRoute(path: '/invite', builder: (_, _) => const InviteScreen()),
      GoRoute(
        path: '/reset',
        builder: (_, state) => ResetScreen(initialEmail: state.extra as String?),
      ),
      GoRoute(path: '/splash', builder: (_, _) => const SplashScreen()),
      GoRoute(path: '/no-organization', builder: (_, _) => const NoOrganizationScreen()),
      GoRoute(path: '/admin', builder: (_, _) => const AdminScreen()),
      StatefulShellRoute.indexedStack(
        builder: (_, _, shell) => AppShell(navigationShell: shell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/library',
              builder: (c, _) => placeholder(c, (l) => l.navLibrary, Icons.grid_view_outlined),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/studio',
              builder: (c, _) => placeholder(c, (l) => l.navStudio, Icons.layers_outlined),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/scan',
              builder: (c, _) =>
                  placeholder(c, (l) => l.navScanner, Icons.document_scanner_outlined),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/suppliers',
              builder: (c, _) =>
                  placeholder(c, (l) => l.navSuppliers, Icons.local_shipping_outlined),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/account',
              builder: (_, _) => const AccountScreen(),
              routes: [
                GoRoute(path: 'members', builder: (_, _) => const MembersScreen()),
              ],
            ),
          ]),
        ],
      ),
    ],
  );
});

class _RefreshNotifier extends ChangeNotifier {
  _RefreshNotifier(Stream<dynamic> stream) {
    _sub = stream.listen((_) => notifyListeners());
  }

  late final StreamSubscription<dynamic> _sub;

  void ping() => notifyListeners();

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}
