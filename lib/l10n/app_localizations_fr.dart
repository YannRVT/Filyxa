// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'Filyxa';

  @override
  String get navLibrary => 'TissuTech';

  @override
  String get navStudio => 'Studio';

  @override
  String get navScanner => 'Scanner';

  @override
  String get navSuppliers => 'Fournisseurs';

  @override
  String get navAccount => 'Compte';

  @override
  String get comingSoonTitle => 'Bientôt disponible';

  @override
  String get comingSoonBody =>
      'Cette section arrive dans une prochaine version de Filyxa.';

  @override
  String get emailLabel => 'E-mail';

  @override
  String get passwordLabel => 'Mot de passe';

  @override
  String get newPasswordLabel => 'Nouveau mot de passe';

  @override
  String get confirmPasswordLabel => 'Confirmer le mot de passe';

  @override
  String get passwordHelper =>
      '8 caractères minimum, avec au moins une lettre et un chiffre';

  @override
  String get codeLabel => 'Code à 6 chiffres';

  @override
  String get showPassword => 'Afficher le mot de passe';

  @override
  String get hidePassword => 'Masquer le mot de passe';

  @override
  String get loginTitle => 'Connexion';

  @override
  String get loginSubtitle =>
      'Accédez à la bibliothèque de matières de votre atelier.';

  @override
  String get loginButton => 'Se connecter';

  @override
  String get forgotPassword => 'Mot de passe oublié ?';

  @override
  String get haveInvitation => 'J\'ai reçu une invitation';

  @override
  String get devQuickLogin => 'Connexion rapide (dev)';

  @override
  String get inviteTitle => 'Rejoindre votre équipe';

  @override
  String get inviteIntro =>
      'Saisissez votre e-mail et le code à 6 chiffres reçu dans l\'e-mail d\'invitation.';

  @override
  String get verifyCode => 'Vérifier le code';

  @override
  String get resendCode => 'Recevoir un nouveau code';

  @override
  String codeResent(String email) {
    return 'Si une invitation est en attente pour $email, un nouveau code vient d\'être envoyé.';
  }

  @override
  String get choosePasswordTitle => 'Choisissez votre mot de passe';

  @override
  String choosePasswordIntro(String organization) {
    return 'Bienvenue chez $organization. Choisissez le mot de passe de votre compte.';
  }

  @override
  String get savePassword => 'Enregistrer et entrer';

  @override
  String get invitationExpiredTitle => 'Invitation expirée';

  @override
  String get invitationExpiredBody =>
      'Cette invitation a expiré. Demandez à l\'administrateur de votre atelier de vous en envoyer une nouvelle.';

  @override
  String get invitationNotFound =>
      'Aucune invitation en attente pour cette adresse. Vérifiez l\'e-mail utilisé ou demandez une nouvelle invitation.';

  @override
  String get alreadyMember => 'Ce compte appartient déjà à une organisation.';

  @override
  String get backToLogin => 'Retour à la connexion';

  @override
  String get resetTitle => 'Mot de passe oublié';

  @override
  String get resetIntro =>
      'Saisissez l\'e-mail de votre compte : vous recevrez un code de réinitialisation.';

  @override
  String get sendCode => 'Envoyer le code';

  @override
  String resetCodeSent(String email) {
    return 'Si un compte existe pour $email, un code à 6 chiffres vient d\'y être envoyé.';
  }

  @override
  String get resetButton => 'Changer le mot de passe';

  @override
  String get passwordChanged => 'Mot de passe modifié. Vous êtes connecté.';

  @override
  String get errorEmailInvalid => 'Adresse e-mail invalide';

  @override
  String get errorPasswordShort => '8 caractères minimum';

  @override
  String get errorPasswordWeak => 'Au moins une lettre et un chiffre';

  @override
  String get errorPasswordMismatch => 'Les mots de passe ne correspondent pas';

  @override
  String get errorCodeInvalid => 'Saisissez le code à 6 chiffres';

  @override
  String get errorBadCredentials => 'E-mail ou mot de passe incorrect';

  @override
  String get errorCodeExpired =>
      'Code incorrect ou expiré. Demandez-en un nouveau.';

  @override
  String get errorNetwork =>
      'Connexion impossible. Vérifiez votre réseau et réessayez.';

  @override
  String get errorTooManyRequests =>
      'Trop de tentatives. Patientez quelques minutes avant de réessayer.';

  @override
  String get errorForbidden => 'Action réservée aux administrateurs.';

  @override
  String get errorEmailNotSent =>
      'L\'e-mail n\'a pas pu être envoyé. Réessayez dans quelques minutes.';

  @override
  String get errorGeneric => 'Une erreur est survenue. Réessayez.';

  @override
  String get errorOrgName => 'Entre 2 et 120 caractères';

  @override
  String get retry => 'Réessayer';

  @override
  String get cancel => 'Annuler';

  @override
  String get logout => 'Se déconnecter';

  @override
  String get accountTitle => 'Mon compte';

  @override
  String get languageLabel => 'Langue';

  @override
  String get organizationLabel => 'Organisation';

  @override
  String get roleLabel => 'Rôle';

  @override
  String get roleAdmin => 'Admin';

  @override
  String get roleEditor => 'Éditeur';

  @override
  String get roleViewer => 'Lecteur';

  @override
  String get superadminConsole => 'Console super-admin';

  @override
  String get noOrgTitle => 'Aucune organisation';

  @override
  String get noOrgBody =>
      'Votre compte n\'est rattaché à aucune organisation. Demandez une invitation à l\'administrateur de votre atelier.';

  @override
  String get loadingError => 'Impossible de charger votre espace.';

  @override
  String get adminTitle => 'Console super-admin';

  @override
  String get adminNewAtelier => 'Nouvel atelier';

  @override
  String get adminEmpty =>
      'Aucune organisation pour l\'instant. Créez le premier atelier pilote.';

  @override
  String get adminOrgName => 'Nom de l\'atelier';

  @override
  String get adminAdminEmail => 'E-mail de son admin';

  @override
  String get adminCreate => 'Créer et inviter';

  @override
  String adminCreated(String email) {
    return 'Atelier créé. Invitation envoyée à $email.';
  }

  @override
  String adminInvitePending(String email, String date) {
    return 'Invitation en attente : $email · expire le $date';
  }

  @override
  String adminInviteExpired(String email) {
    return 'Invitation expirée : $email';
  }

  @override
  String adminMembers(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count membres',
      one: '1 membre',
      zero: 'Aucun membre',
    );
    return '$_temp0';
  }

  @override
  String get adminReinvite => 'Renvoyer une invitation';

  @override
  String adminReinvited(String email) {
    return 'Invitation renvoyée à $email.';
  }

  @override
  String get orgKindAtelier => 'Atelier';

  @override
  String get orgKindSupplier => 'Fournisseur';

  @override
  String get missingConfig =>
      'Configuration Supabase manquante. Copiez env.example.json en env.json, renseignez-le, puis lancez : flutter run --dart-define-from-file=env.json';

  @override
  String get membersEntry => 'Membres de l\'atelier';

  @override
  String get membersTitle => 'Membres';

  @override
  String get membersInvite => 'Inviter';

  @override
  String get inviteDialogTitle => 'Inviter un membre';

  @override
  String get inviteSend => 'Envoyer l\'invitation';

  @override
  String get roleAdminHelp =>
      'Gère les membres et les paramètres de l\'atelier';

  @override
  String get roleEditorHelp => 'Crée, modifie, scanne, importe et partage';

  @override
  String get roleViewerHelp => 'Consulte et exporte, sans rien modifier';

  @override
  String get youSuffix => 'vous';

  @override
  String get pendingInvitations => 'Invitations en attente';

  @override
  String invitationExpiresOn(String date) {
    return 'Expire le $date';
  }

  @override
  String get invitationExpiredShort => 'Expirée';

  @override
  String get resendInvitation => 'Renvoyer';

  @override
  String get cancelInvitation => 'Annuler l\'invitation';

  @override
  String invitationSent(String email) {
    return 'Invitation envoyée à $email.';
  }

  @override
  String get invitationCanceled => 'Invitation annulée.';

  @override
  String get changeRole => 'Changer le rôle';

  @override
  String get roleChanged => 'Rôle mis à jour.';

  @override
  String get removeMember => 'Retirer de l\'atelier';

  @override
  String removeConfirmTitle(String name) {
    return 'Retirer $name ?';
  }

  @override
  String get removeConfirmBody =>
      'Cette personne perdra immédiatement l\'accès aux données de l\'atelier. Vous pourrez l\'inviter à nouveau.';

  @override
  String get removeConfirm => 'Retirer';

  @override
  String get memberRemoved => 'Membre retiré.';

  @override
  String get errorLastAdmin =>
      'L\'atelier doit garder au moins un admin. Nommez d\'abord un autre admin.';

  @override
  String get lastAdminHint => 'Seul admin de l\'atelier';

  @override
  String memberActions(String name) {
    return 'Actions pour $name';
  }
}
