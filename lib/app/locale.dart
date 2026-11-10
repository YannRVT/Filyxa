import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/supabase.dart';
import '../features/session/data/user_space_repository.dart';

/// Langues de Filyxa, dans l'ordre d'affichage, avec leur nom dans leur propre langue.
const supportedLanguages = <String, String>{
  'fr': 'Français',
  'en': 'English',
  'it': 'Italiano',
  'es': 'Español',
  'pt': 'Português',
  'ro': 'Română',
};

const supportedLocales = [
  Locale('fr'),
  Locale('en'),
  Locale('it'),
  Locale('es'),
  Locale('pt'),
  Locale('ro'),
];

/// Langue de l'appareil si elle est prise en charge, sinon le français.
Locale resolveDeviceLocale(List<Locale>? deviceLocales) {
  for (final locale in deviceLocales ?? const <Locale>[]) {
    if (supportedLanguages.containsKey(locale.languageCode)) return Locale(locale.languageCode);
  }
  return const Locale('fr');
}

/// Langue choisie par l'utilisateur. `null` = langue de l'appareil.
/// Une fois connecté, la langue enregistrée dans le profil s'applique.
class LocaleController extends Notifier<Locale?> {
  @override
  Locale? build() {
    final space = ref.watch(userSpaceProvider).value;
    final saved = space?.profile.locale;
    return saved != null && supportedLanguages.containsKey(saved) ? Locale(saved) : null;
  }

  Future<void> select(String languageCode) async {
    if (!supportedLanguages.containsKey(languageCode)) return;
    state = Locale(languageCode);
    final userId = ref.read(currentUserIdProvider);
    if (userId != null) {
      await ref.read(userSpaceRepositoryProvider).updateLocale(userId, languageCode);
    }
  }
}

final localeProvider = NotifierProvider<LocaleController, Locale?>(LocaleController.new);
