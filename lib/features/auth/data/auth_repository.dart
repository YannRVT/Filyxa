import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/supabase.dart';
import '../domain/auth_rules.dart';

/// Exception unique remontée à l'interface, porteuse d'une [AuthFailure].
class AuthError implements Exception {
  const AuthError(this.failure);

  final AuthFailure failure;

  factory AuthError.from(Object error) {
    if (error is AuthError) return error;
    if (error is AuthException) {
      return AuthError(classifyFailure(
        message: error.message,
        code: error.code,
        statusCode: int.tryParse(error.statusCode ?? ''),
      ));
    }
    if (error is PostgrestException) {
      return AuthError(classifyFailure(message: error.message, code: error.code));
    }
    if (error is FunctionException) {
      final details = error.details;
      final code = details is Map ? details['error']?.toString() : details?.toString();
      return AuthError(classifyFailure(code: code, statusCode: error.status));
    }
    return AuthError(classifyFailure(message: error.toString()));
  }

  @override
  String toString() => 'AuthError($failure)';
}

class AuthRepository {
  AuthRepository(this._client);

  final SupabaseClient _client;

  GoTrueClient get _auth => _client.auth;

  Future<T> _guard<T>(Future<T> Function() action) async {
    try {
      return await action();
    } catch (e) {
      throw AuthError.from(e);
    }
  }

  Future<void> signIn(String email, String password) => _guard(
        () => _auth.signInWithPassword(email: normalizeEmail(email), password: password),
      );

  Future<void> signOut() => _guard(() => _auth.signOut());

  /// Vérifie le code reçu par e-mail. Un compte créé par l'invitation reçoit un
  /// code de type « invite » ; un compte existant reçoit un code de connexion.
  Future<void> verifyInvitationCode(String email, String code) => _guard(() async {
        final normalized = normalizeEmail(email);
        try {
          await _auth.verifyOTP(email: normalized, token: code.trim(), type: OtpType.invite);
        } on AuthException {
          await _auth.verifyOTP(email: normalized, token: code.trim(), type: OtpType.email);
        }
      });

  /// Redemande un code pour une invitation encore valable (48 h).
  /// Le serveur répond de la même façon que l'adresse soit invitée ou non.
  Future<void> resendInvitationCode(String email) => _guard(() => _client.functions.invoke(
        'admin-users',
        body: {'action': 'resend_invitation', 'email': normalizeEmail(email)},
      ));

  /// Rattache l'utilisateur connecté à l'organisation de son invitation.
  Future<String> acceptInvitation() => _guard(() async {
        final orgId = await _client.rpc<String>('accept_invitation');
        return orgId;
      });

  Future<void> setPassword(String password) =>
      _guard(() => _auth.updateUser(UserAttributes(password: password)));

  Future<void> sendRecoveryCode(String email) =>
      _guard(() => _auth.resetPasswordForEmail(normalizeEmail(email)));

  /// Vérifie le code de réinitialisation puis enregistre le nouveau mot de passe.
  Future<void> resetPassword(String email, String code, String newPassword) => _guard(() async {
        await _auth.verifyOTP(
          email: normalizeEmail(email),
          token: code.trim(),
          type: OtpType.recovery,
        );
        await _auth.updateUser(UserAttributes(password: newPassword));
      });
}

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepository(ref.watch(supabaseProvider)),
);
