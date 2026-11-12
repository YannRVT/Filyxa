/// Règles de saisie de l'authentification, indépendantes de l'interface.
/// Chaque validateur renvoie un code d'erreur ([AuthFieldError]) ou `null`.
library;

const kPasswordMinLength = 8;
const kCodeLength = 6;

enum AuthFieldError { emailInvalid, passwordShort, passwordWeak, passwordMismatch, codeInvalid }

final _emailRe = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

String normalizeEmail(String value) => value.trim().toLowerCase();

AuthFieldError? checkEmail(String? value) =>
    _emailRe.hasMatch(normalizeEmail(value ?? '')) ? null : AuthFieldError.emailInvalid;

AuthFieldError? checkPassword(String? value) {
  final v = value ?? '';
  if (v.length < kPasswordMinLength) return AuthFieldError.passwordShort;
  if (!RegExp(r'[A-Za-zÀ-ÿ]').hasMatch(v) || !RegExp(r'\d').hasMatch(v)) {
    return AuthFieldError.passwordWeak;
  }
  return null;
}

AuthFieldError? checkConfirmation(String? value, String password) =>
    value == password ? null : AuthFieldError.passwordMismatch;

AuthFieldError? checkCode(String? value) =>
    RegExp('^\\d{$kCodeLength}\$').hasMatch((value ?? '').trim()) ? null : AuthFieldError.codeInvalid;

/// Erreurs métier renvoyées par le serveur, traduites par l'interface.
enum AuthFailure {
  badCredentials,
  codeExpired,
  invitationExpired,
  invitationNotFound,
  alreadyMember,
  lastAdmin,
  forbidden,
  proRequired,
  emailNotSent,
  tooManyRequests,
  network,
  generic,
}

/// Rapproche un message ou un code d'erreur serveur d'une [AuthFailure].
AuthFailure classifyFailure({String? message, String? code, int? statusCode}) {
  final text = '${code ?? ''} ${message ?? ''}'.toLowerCase();
  if (text.contains('invitation_expired')) return AuthFailure.invitationExpired;
  if (text.contains('invitation_not_found')) return AuthFailure.invitationNotFound;
  if (text.contains('already_member')) return AuthFailure.alreadyMember;
  if (text.contains('last_admin')) return AuthFailure.lastAdmin;
  if (text.contains('email_not_sent')) return AuthFailure.emailNotSent;
  if (text.contains('pro_required')) return AuthFailure.proRequired;
  if (text.contains('forbidden') || statusCode == 403) return AuthFailure.forbidden;
  if (statusCode == 429 || text.contains('rate limit') || text.contains('over_') ) {
    return AuthFailure.tooManyRequests;
  }
  if (text.contains('invalid login') || text.contains('invalid_credentials')) {
    return AuthFailure.badCredentials;
  }
  if (text.contains('otp') || text.contains('token has expired') || text.contains('expired')) {
    return AuthFailure.codeExpired;
  }
  if (text.contains('socket') || text.contains('failed host lookup') ||
      text.contains('network') || text.contains('clientexception')) {
    return AuthFailure.network;
  }
  return AuthFailure.generic;
}
