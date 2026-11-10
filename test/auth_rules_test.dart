import 'package:filyxa/features/auth/domain/auth_rules.dart';
import 'package:filyxa/features/session/domain/user_space.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('saisie', () {
    test('e-mail', () {
      expect(checkEmail(' Claire@Atelier.fr '), isNull);
      expect(normalizeEmail(' Claire@Atelier.fr '), 'claire@atelier.fr');
      expect(checkEmail('claire@atelier'), AuthFieldError.emailInvalid);
      expect(checkEmail(null), AuthFieldError.emailInvalid);
    });

    test('mot de passe : 8 caractères, une lettre et un chiffre', () {
      expect(checkPassword('abc12'), AuthFieldError.passwordShort);
      expect(checkPassword('abcdefgh'), AuthFieldError.passwordWeak);
      expect(checkPassword('12345678'), AuthFieldError.passwordWeak);
      expect(checkPassword('tissu2027'), isNull);
      expect(checkPassword('étoffe2027'), isNull);
    });

    test('confirmation', () {
      expect(checkConfirmation('tissu2027', 'tissu2027'), isNull);
      expect(checkConfirmation('tissu2028', 'tissu2027'), AuthFieldError.passwordMismatch);
    });

    test('code à 6 chiffres', () {
      expect(checkCode('123456'), isNull);
      expect(checkCode(' 123456 '), isNull);
      expect(checkCode('12345'), AuthFieldError.codeInvalid);
      expect(checkCode('12a456'), AuthFieldError.codeInvalid);
    });
  });

  group('erreurs serveur', () {
    test('invitation', () {
      expect(classifyFailure(message: 'invitation_expired'), AuthFailure.invitationExpired);
      expect(classifyFailure(message: 'invitation_not_found'), AuthFailure.invitationNotFound);
      expect(classifyFailure(code: 'already_member', statusCode: 409), AuthFailure.alreadyMember);
      expect(classifyFailure(code: 'email_not_sent', statusCode: 502), AuthFailure.emailNotSent);
      expect(classifyFailure(code: 'forbidden', statusCode: 403), AuthFailure.forbidden);
    });

    test('authentification', () {
      expect(classifyFailure(message: 'Invalid login credentials', code: 'invalid_credentials'),
          AuthFailure.badCredentials);
      expect(classifyFailure(message: 'Token has expired or is invalid', code: 'otp_expired'),
          AuthFailure.codeExpired);
      expect(classifyFailure(message: 'email rate limit exceeded', statusCode: 429),
          AuthFailure.tooManyRequests);
      expect(classifyFailure(message: 'SocketException: Failed host lookup'), AuthFailure.network);
      expect(classifyFailure(message: '???'), AuthFailure.generic);
    });
  });

  group('rôles', () {
    test('hiérarchie Admin > Éditeur > Lecteur', () {
      expect(MemberRole.admin.atLeast(MemberRole.editor), isTrue);
      expect(MemberRole.editor.atLeast(MemberRole.editor), isTrue);
      expect(MemberRole.viewer.atLeast(MemberRole.editor), isFalse);
      expect(MemberRole.parse('editor'), MemberRole.editor);
      expect(MemberRole.parse('inconnu'), MemberRole.viewer);
    });

    test('nom affiché et initiales', () {
      const named = Profile(
        id: '1',
        email: 'claire.lune@atelier.fr',
        fullName: 'Claire Lune',
        locale: 'fr',
        isSuperadmin: false,
      );
      const unnamed = Profile(id: '2', email: 'marc@atelier.fr', locale: 'fr', isSuperadmin: false);
      expect(named.initials, 'CL');
      expect(unnamed.displayName, 'marc');
      expect(unnamed.initials, 'M');
    });
  });
}
