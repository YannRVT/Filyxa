import 'package:filyxa/features/auth/ui/invite_screen.dart';
import 'package:filyxa/features/auth/ui/login_screen.dart';
import 'package:filyxa/features/auth/ui/reset_screen.dart';
import 'package:filyxa/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

Widget _app(Widget screen, {Locale locale = const Locale('fr')}) => ProviderScope(
      child: MaterialApp(
        locale: locale,
        localizationsDelegates: const [AppLocalizations.delegate, ...GlobalMaterialLocalizations.delegates],
        supportedLocales: AppLocalizations.supportedLocales,
        home: screen,
      ),
    );

void main() {
  const screens = {
    'connexion': LoginScreen(),
    'invitation': InviteScreen(),
    'mot de passe oublié': ResetScreen(),
  };

  for (final size in const [Size(360, 740), Size(1440, 900)]) {
    for (final locale in const [Locale('fr'), Locale('ro')]) {
      for (final entry in screens.entries) {
        testWidgets('${entry.key} sans débordement (${size.width.toInt()} px, ${locale.languageCode})',
            (tester) async {
          tester.view.physicalSize = size;
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.reset);
          await tester.pumpWidget(_app(entry.value, locale: locale));
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
        });
      }
    }
  }

  testWidgets('connexion : un e-mail invalide est signalé avant tout appel serveur', (tester) async {
    await tester.pumpWidget(_app(const LoginScreen()));
    await tester.enterText(find.byType(TextFormField).first, 'claire@atelier');
    await tester.tap(find.text('Se connecter'));
    await tester.pumpAndSettle();
    expect(find.text('Adresse e-mail invalide'), findsOneWidget);
  });

  testWidgets('invitation : le code n\'accepte que 6 chiffres', (tester) async {
    await tester.pumpWidget(_app(const InviteScreen()));
    final code = find.byType(TextFormField).at(1);
    await tester.enterText(code, '12ab345678');
    await tester.pump();
    expect(tester.widget<TextFormField>(code).controller!.text, '123456');
  });
}
