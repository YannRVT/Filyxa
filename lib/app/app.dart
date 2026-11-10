import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
    );
  }
}
