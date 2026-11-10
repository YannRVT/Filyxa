import 'package:flutter/widgets.dart';

import '../features/auth/domain/auth_rules.dart';
import '../features/session/domain/user_space.dart';
import 'app_localizations.dart';

export 'app_localizations.dart';

extension L10nContext on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}

extension AuthFieldErrorText on AppLocalizations {
  String fieldError(AuthFieldError error) => switch (error) {
        AuthFieldError.emailInvalid => errorEmailInvalid,
        AuthFieldError.passwordShort => errorPasswordShort,
        AuthFieldError.passwordWeak => errorPasswordWeak,
        AuthFieldError.passwordMismatch => errorPasswordMismatch,
        AuthFieldError.codeInvalid => errorCodeInvalid,
      };

  String failure(AuthFailure failure) => switch (failure) {
        AuthFailure.badCredentials => errorBadCredentials,
        AuthFailure.codeExpired => errorCodeExpired,
        AuthFailure.invitationExpired => invitationExpiredBody,
        AuthFailure.invitationNotFound => invitationNotFound,
        AuthFailure.alreadyMember => alreadyMember,
        AuthFailure.forbidden => errorForbidden,
        AuthFailure.emailNotSent => errorEmailNotSent,
        AuthFailure.tooManyRequests => errorTooManyRequests,
        AuthFailure.network => errorNetwork,
        AuthFailure.generic => errorGeneric,
      };

  String role(MemberRole role) => switch (role) {
        MemberRole.admin => roleAdmin,
        MemberRole.editor => roleEditor,
        MemberRole.viewer => roleViewer,
      };

  String orgKind(OrgKind kind) => switch (kind) {
        OrgKind.atelier => orgKindAtelier,
        OrgKind.supplier => orgKindSupplier,
      };
}
