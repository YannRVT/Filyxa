import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/session/data/user_space_repository.dart';
import '../l10n/l10n.dart';
import 'locale.dart';
import 'router.dart';
import 'theme.dart';

class FilyxaApp extends ConsumerWidget {
  const FilyxaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'Filyxa',
      debugShowCheckedModeBanner: false,
      theme: FxTheme.light(),
      locale: ref.watch(localeProvider),
      supportedLocales: supportedLocales,
      localeListResolutionCallback: (deviceLocales, _) => resolveDeviceLocale(deviceLocales),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        ...GlobalMaterialLocalizations.delegates,
      ],
      routerConfig: ref.watch(routerProvider),
      builder: (context, child) => _RefreshOnResume(child: child!),
    );
  }
}

/// Recharge l'espace de l'utilisateur quand l'app revient au premier plan :
/// un membre retiré ou dont le rôle a changé le voit sans redémarrer l'app.
class _RefreshOnResume extends ConsumerStatefulWidget {
  const _RefreshOnResume({required this.child});

  final Widget child;

  @override
  ConsumerState<_RefreshOnResume> createState() => _RefreshOnResumeState();
}

class _RefreshOnResumeState extends ConsumerState<_RefreshOnResume> {
  late final AppLifecycleListener _listener;

  @override
  void initState() {
    super.initState();
    _listener = AppLifecycleListener(onResume: () => ref.invalidate(userSpaceProvider));
  }

  @override
  void dispose() {
    _listener.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
