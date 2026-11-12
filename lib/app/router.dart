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
import '../features/library/ui/atelier_import_screen.dart';
import '../features/library/ui/library_screen.dart';
import '../features/library/ui/link_review_screen.dart';
import '../features/library/ui/material_detail_screen.dart';
import '../features/library/ui/material_form_screen.dart';
import '../features/members/ui/members_screen.dart';
import '../features/reports/ui/notifications_screen.dart';
import '../features/reports/ui/supplier_reports_screen.dart';
import '../features/scanner/domain/scan.dart';
import '../features/scanner/ui/scanner_screen.dart';
import '../features/share/ui/share_widgets.dart';
import '../features/share/ui/shared_view_screen.dart';
import '../features/studio/ui/collection_screen.dart';
import '../features/studio/ui/model_screen.dart';
import '../features/studio/ui/size_widgets.dart';
import '../features/studio/ui/studio_screen.dart';
import '../features/supplier/ui/catalog_import_screen.dart';
import '../features/supplier/ui/catalog_screen.dart';
import '../features/supplier/ui/reference_screen.dart';
import '../features/supplier/ui/supplier_settings_screen.dart';
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
        isSupplier: space.value?.membership?.organization.kind == OrgKind.supplier,
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
      GoRoute(path: '/notifications', builder: (_, _) => const NotificationsScreen()),
      GoRoute(path: '/s/:token', builder: (_, state) => SharedViewScreen(token: state.pathParameters['token']!)),
      StatefulShellRoute.indexedStack(
        builder: (_, _, shell) => AppShell(
          navigationShell: shell,
          supplier: ref.read(userSpaceProvider).value?.membership?.organization.kind == OrgKind.supplier,
        ),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/library',
              builder: (_, _) => const LibraryScreen(),
              routes: [
                GoRoute(
                  path: 'new',
                  builder: (_, state) => MaterialFormScreen(prefill: state.extra as ScanPrefill?),
                ),
                GoRoute(path: 'import', builder: (_, _) => const AtelierImportScreen()),
                GoRoute(path: 'links', builder: (_, _) => const LinkReviewScreen()),
                GoRoute(
                  path: ':id',
                  builder: (_, state) => MaterialDetailScreen(materialId: state.pathParameters['id']!),
                  routes: [
                    GoRoute(
                      path: 'edit',
                      builder: (_, state) => MaterialFormScreen(materialId: state.pathParameters['id']),
                    ),
                  ],
                ),
              ],
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/studio',
              builder: (_, _) => const StudioScreen(),
              routes: [
                GoRoute(
                  path: 'collections/:collectionId',
                  builder: (_, state) => CollectionScreen(collectionId: state.pathParameters['collectionId']!),
                ),
                GoRoute(
                  path: 'models/:modelId',
                  builder: (_, state) => ModelScreen(modelId: state.pathParameters['modelId']!),
                ),
              ],
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/scan', builder: (_, _) => const ScannerScreen()),
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
                GoRoute(path: 'links', builder: (_, _) => const ShareLinksScreen()),
                GoRoute(path: 'sizes', builder: (_, _) => const SizeChartsScreen()),
              ],
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/catalog',
              builder: (_, _) => const CatalogScreen(),
              routes: [
                GoRoute(path: 'import', builder: (_, _) => const CatalogImportScreen()),
                GoRoute(path: 'settings', builder: (_, _) => const SupplierSettingsScreen()),
                GoRoute(path: 'reports', builder: (_, _) => const SupplierReportsScreen()),
                GoRoute(
                  path: ':id',
                  builder: (_, state) => ReferenceScreen(referenceId: state.pathParameters['id']!),
                ),
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
