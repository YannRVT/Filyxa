// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Filyxa';

  @override
  String get navLibrary => 'TissuTech';

  @override
  String get navStudio => 'Studio';

  @override
  String get navScanner => 'Escáner';

  @override
  String get navSuppliers => 'Proveedores';

  @override
  String get navAccount => 'Cuenta';

  @override
  String get comingSoonTitle => 'Próximamente';

  @override
  String get comingSoonBody =>
      'Esta sección llegará en una próxima versión de Filyxa.';

  @override
  String get emailLabel => 'Correo electrónico';

  @override
  String get passwordLabel => 'Contraseña';

  @override
  String get newPasswordLabel => 'Nueva contraseña';

  @override
  String get confirmPasswordLabel => 'Confirmar contraseña';

  @override
  String get passwordHelper =>
      'Mínimo 8 caracteres, con al menos una letra y un número';

  @override
  String get codeLabel => 'Código de 6 dígitos';

  @override
  String get showPassword => 'Mostrar contraseña';

  @override
  String get hidePassword => 'Ocultar contraseña';

  @override
  String get loginTitle => 'Iniciar sesión';

  @override
  String get loginSubtitle =>
      'Accede a la biblioteca de materiales de tu taller.';

  @override
  String get loginButton => 'Iniciar sesión';

  @override
  String get forgotPassword => '¿Olvidaste tu contraseña?';

  @override
  String get haveInvitation => 'He recibido una invitación';

  @override
  String get devQuickLogin => 'Acceso rápido (dev)';

  @override
  String get inviteTitle => 'Únete a tu equipo';

  @override
  String get inviteIntro =>
      'Introduce tu correo y el código de 6 dígitos recibido en el correo de invitación.';

  @override
  String get verifyCode => 'Verificar el código';

  @override
  String get resendCode => 'Recibir un código nuevo';

  @override
  String codeResent(String email) {
    return 'Si hay una invitación pendiente para $email, se acaba de enviar un código nuevo.';
  }

  @override
  String get choosePasswordTitle => 'Elige tu contraseña';

  @override
  String choosePasswordIntro(String organization) {
    return 'Bienvenido a $organization. Elige la contraseña de tu cuenta.';
  }

  @override
  String get savePassword => 'Guardar y entrar';

  @override
  String get invitationExpiredTitle => 'Invitación caducada';

  @override
  String get invitationExpiredBody =>
      'Esta invitación ha caducado. Pide al administrador de tu taller que te envíe una nueva.';

  @override
  String get invitationNotFound =>
      'No hay ninguna invitación pendiente para esta dirección. Comprueba el correo utilizado o pide una nueva invitación.';

  @override
  String get alreadyMember => 'Esta cuenta ya pertenece a una organización.';

  @override
  String get backToLogin => 'Volver al inicio de sesión';

  @override
  String get resetTitle => 'Contraseña olvidada';

  @override
  String get resetIntro =>
      'Introduce el correo de tu cuenta: recibirás un código de restablecimiento.';

  @override
  String get sendCode => 'Enviar el código';

  @override
  String resetCodeSent(String email) {
    return 'Si existe una cuenta para $email, se le acaba de enviar un código de 6 dígitos.';
  }

  @override
  String get resetButton => 'Cambiar la contraseña';

  @override
  String get passwordChanged => 'Contraseña cambiada. Has iniciado sesión.';

  @override
  String get errorEmailInvalid => 'Correo electrónico no válido';

  @override
  String get errorPasswordShort => 'Mínimo 8 caracteres';

  @override
  String get errorPasswordWeak => 'Al menos una letra y un número';

  @override
  String get errorPasswordMismatch => 'Las contraseñas no coinciden';

  @override
  String get errorCodeInvalid => 'Introduce el código de 6 dígitos';

  @override
  String get errorBadCredentials => 'Correo o contraseña incorrectos';

  @override
  String get errorCodeExpired =>
      'Código incorrecto o caducado. Solicita uno nuevo.';

  @override
  String get errorNetwork =>
      'No se puede conectar. Comprueba tu red e inténtalo de nuevo.';

  @override
  String get errorTooManyRequests =>
      'Demasiados intentos. Espera unos minutos antes de volver a intentarlo.';

  @override
  String get errorForbidden => 'Acción reservada a los administradores.';

  @override
  String get errorEmailNotSent =>
      'No se ha podido enviar el correo. Inténtalo de nuevo en unos minutos.';

  @override
  String get errorGeneric => 'Se ha producido un error. Inténtalo de nuevo.';

  @override
  String get errorOrgName => 'Entre 2 y 120 caracteres';

  @override
  String get retry => 'Reintentar';

  @override
  String get cancel => 'Cancelar';

  @override
  String get logout => 'Cerrar sesión';

  @override
  String get accountTitle => 'Mi cuenta';

  @override
  String get languageLabel => 'Idioma';

  @override
  String get organizationLabel => 'Organización';

  @override
  String get roleLabel => 'Rol';

  @override
  String get roleAdmin => 'Admin';

  @override
  String get roleEditor => 'Editor';

  @override
  String get roleViewer => 'Lector';

  @override
  String get superadminConsole => 'Consola de superadministrador';

  @override
  String get noOrgTitle => 'Ninguna organización';

  @override
  String get noOrgBody =>
      'Tu cuenta no está vinculada a ninguna organización. Pide una invitación al administrador de tu taller.';

  @override
  String get loadingError => 'No se puede cargar tu espacio.';

  @override
  String get adminTitle => 'Consola de superadministrador';

  @override
  String get adminNewAtelier => 'Nuevo taller';

  @override
  String get adminEmpty =>
      'Todavía no hay organizaciones. Crea el primer taller piloto.';

  @override
  String get adminOrgName => 'Nombre del taller';

  @override
  String get adminAdminEmail => 'Correo de su administrador';

  @override
  String get adminCreate => 'Crear e invitar';

  @override
  String adminCreated(String email) {
    return 'Taller creado. Invitación enviada a $email.';
  }

  @override
  String adminInvitePending(String email, String date) {
    return 'Invitación pendiente: $email · caduca el $date';
  }

  @override
  String adminInviteExpired(String email) {
    return 'Invitación caducada: $email';
  }

  @override
  String adminMembers(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count miembros',
      one: '1 miembro',
      zero: 'Ningún miembro',
    );
    return '$_temp0';
  }

  @override
  String get adminReinvite => 'Reenviar la invitación';

  @override
  String adminReinvited(String email) {
    return 'Invitación reenviada a $email.';
  }

  @override
  String get orgKindAtelier => 'Taller';

  @override
  String get orgKindSupplier => 'Proveedor';

  @override
  String get missingConfig =>
      'Falta la configuración de Supabase. Copia env.example.json en env.json, rellénalo y ejecuta: flutter run --dart-define-from-file=env.json';

  @override
  String get membersEntry => 'Miembros del taller';

  @override
  String get membersTitle => 'Miembros';

  @override
  String get membersInvite => 'Invitar';

  @override
  String get inviteDialogTitle => 'Invitar a un miembro';

  @override
  String get inviteSend => 'Enviar la invitación';

  @override
  String get roleAdminHelp => 'Gestiona los miembros y los ajustes del taller';

  @override
  String get roleEditorHelp => 'Crea, modifica, escanea, importa y comparte';

  @override
  String get roleViewerHelp => 'Consulta y exporta, sin modificar nada';

  @override
  String get youSuffix => 'tú';

  @override
  String get pendingInvitations => 'Invitaciones pendientes';

  @override
  String invitationExpiresOn(String date) {
    return 'Caduca el $date';
  }

  @override
  String get invitationExpiredShort => 'Caducada';

  @override
  String get resendInvitation => 'Reenviar';

  @override
  String get cancelInvitation => 'Cancelar la invitación';

  @override
  String invitationSent(String email) {
    return 'Invitación enviada a $email.';
  }

  @override
  String get invitationCanceled => 'Invitación cancelada.';

  @override
  String get changeRole => 'Cambiar el rol';

  @override
  String get roleChanged => 'Rol actualizado.';

  @override
  String get removeMember => 'Quitar del taller';

  @override
  String removeConfirmTitle(String name) {
    return '¿Quitar a $name?';
  }

  @override
  String get removeConfirmBody =>
      'Esta persona perderá inmediatamente el acceso a los datos del taller. Podrás invitarla de nuevo.';

  @override
  String get removeConfirm => 'Quitar';

  @override
  String get memberRemoved => 'Miembro eliminado.';

  @override
  String get errorLastAdmin =>
      'El taller debe conservar al menos un administrador. Nombra antes a otro administrador.';

  @override
  String get lastAdminHint => 'Único administrador del taller';

  @override
  String memberActions(String name) {
    return 'Acciones para $name';
  }
}
