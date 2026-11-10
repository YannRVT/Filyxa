import 'package:flutter/foundation.dart' show kDebugMode;

/// Configuration injectée au build via `--dart-define-from-file=env.json`.
abstract final class Env {
  static const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

  // Connexion rapide : la condition sur kDebugMode retire ces valeurs des builds profile et release.
  static const devEmail = kDebugMode ? String.fromEnvironment('DEV_EMAIL') : '';
  static const devPassword = kDebugMode ? String.fromEnvironment('DEV_PASSWORD') : '';

  static bool get isConfigured => supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;

  static bool get hasQuickLogin => devEmail.isNotEmpty && devPassword.isNotEmpty;
}
