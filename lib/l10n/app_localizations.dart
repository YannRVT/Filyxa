import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_it.dart';
import 'app_localizations_pt.dart';
import 'app_localizations_ro.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('it'),
    Locale('pt'),
    Locale('ro'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In fr, this message translates to:
  /// **'Filyxa'**
  String get appTitle;

  /// No description provided for @navLibrary.
  ///
  /// In fr, this message translates to:
  /// **'TissuTech'**
  String get navLibrary;

  /// No description provided for @navStudio.
  ///
  /// In fr, this message translates to:
  /// **'Studio'**
  String get navStudio;

  /// No description provided for @navScanner.
  ///
  /// In fr, this message translates to:
  /// **'Scanner'**
  String get navScanner;

  /// No description provided for @navSuppliers.
  ///
  /// In fr, this message translates to:
  /// **'Fournisseurs'**
  String get navSuppliers;

  /// No description provided for @navAccount.
  ///
  /// In fr, this message translates to:
  /// **'Compte'**
  String get navAccount;

  /// No description provided for @comingSoonTitle.
  ///
  /// In fr, this message translates to:
  /// **'Bientôt disponible'**
  String get comingSoonTitle;

  /// No description provided for @comingSoonBody.
  ///
  /// In fr, this message translates to:
  /// **'Cette section arrive dans une prochaine version de Filyxa.'**
  String get comingSoonBody;

  /// No description provided for @emailLabel.
  ///
  /// In fr, this message translates to:
  /// **'E-mail'**
  String get emailLabel;

  /// No description provided for @passwordLabel.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe'**
  String get passwordLabel;

  /// No description provided for @newPasswordLabel.
  ///
  /// In fr, this message translates to:
  /// **'Nouveau mot de passe'**
  String get newPasswordLabel;

  /// No description provided for @confirmPasswordLabel.
  ///
  /// In fr, this message translates to:
  /// **'Confirmer le mot de passe'**
  String get confirmPasswordLabel;

  /// No description provided for @passwordHelper.
  ///
  /// In fr, this message translates to:
  /// **'8 caractères minimum, avec au moins une lettre et un chiffre'**
  String get passwordHelper;

  /// No description provided for @codeLabel.
  ///
  /// In fr, this message translates to:
  /// **'Code à 6 chiffres'**
  String get codeLabel;

  /// No description provided for @showPassword.
  ///
  /// In fr, this message translates to:
  /// **'Afficher le mot de passe'**
  String get showPassword;

  /// No description provided for @hidePassword.
  ///
  /// In fr, this message translates to:
  /// **'Masquer le mot de passe'**
  String get hidePassword;

  /// No description provided for @loginTitle.
  ///
  /// In fr, this message translates to:
  /// **'Connexion'**
  String get loginTitle;

  /// No description provided for @loginSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Accédez à la bibliothèque de matières de votre atelier.'**
  String get loginSubtitle;

  /// No description provided for @loginButton.
  ///
  /// In fr, this message translates to:
  /// **'Se connecter'**
  String get loginButton;

  /// No description provided for @forgotPassword.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe oublié ?'**
  String get forgotPassword;

  /// No description provided for @haveInvitation.
  ///
  /// In fr, this message translates to:
  /// **'J\'ai reçu une invitation'**
  String get haveInvitation;

  /// No description provided for @devQuickLogin.
  ///
  /// In fr, this message translates to:
  /// **'Connexion rapide (dev)'**
  String get devQuickLogin;

  /// No description provided for @inviteTitle.
  ///
  /// In fr, this message translates to:
  /// **'Rejoindre votre équipe'**
  String get inviteTitle;

  /// No description provided for @inviteIntro.
  ///
  /// In fr, this message translates to:
  /// **'Saisissez votre e-mail et le code à 6 chiffres reçu dans l\'e-mail d\'invitation.'**
  String get inviteIntro;

  /// No description provided for @verifyCode.
  ///
  /// In fr, this message translates to:
  /// **'Vérifier le code'**
  String get verifyCode;

  /// No description provided for @resendCode.
  ///
  /// In fr, this message translates to:
  /// **'Recevoir un nouveau code'**
  String get resendCode;

  /// No description provided for @codeResent.
  ///
  /// In fr, this message translates to:
  /// **'Si une invitation est en attente pour {email}, un nouveau code vient d\'être envoyé.'**
  String codeResent(String email);

  /// No description provided for @choosePasswordTitle.
  ///
  /// In fr, this message translates to:
  /// **'Choisissez votre mot de passe'**
  String get choosePasswordTitle;

  /// No description provided for @choosePasswordIntro.
  ///
  /// In fr, this message translates to:
  /// **'Bienvenue chez {organization}. Choisissez le mot de passe de votre compte.'**
  String choosePasswordIntro(String organization);

  /// No description provided for @savePassword.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrer et entrer'**
  String get savePassword;

  /// No description provided for @invitationExpiredTitle.
  ///
  /// In fr, this message translates to:
  /// **'Invitation expirée'**
  String get invitationExpiredTitle;

  /// No description provided for @invitationExpiredBody.
  ///
  /// In fr, this message translates to:
  /// **'Cette invitation a expiré. Demandez à l\'administrateur de votre atelier de vous en envoyer une nouvelle.'**
  String get invitationExpiredBody;

  /// No description provided for @invitationNotFound.
  ///
  /// In fr, this message translates to:
  /// **'Aucune invitation en attente pour cette adresse. Vérifiez l\'e-mail utilisé ou demandez une nouvelle invitation.'**
  String get invitationNotFound;

  /// No description provided for @alreadyMember.
  ///
  /// In fr, this message translates to:
  /// **'Ce compte appartient déjà à une organisation.'**
  String get alreadyMember;

  /// No description provided for @backToLogin.
  ///
  /// In fr, this message translates to:
  /// **'Retour à la connexion'**
  String get backToLogin;

  /// No description provided for @resetTitle.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe oublié'**
  String get resetTitle;

  /// No description provided for @resetIntro.
  ///
  /// In fr, this message translates to:
  /// **'Saisissez l\'e-mail de votre compte : vous recevrez un code de réinitialisation.'**
  String get resetIntro;

  /// No description provided for @sendCode.
  ///
  /// In fr, this message translates to:
  /// **'Envoyer le code'**
  String get sendCode;

  /// No description provided for @resetCodeSent.
  ///
  /// In fr, this message translates to:
  /// **'Si un compte existe pour {email}, un code à 6 chiffres vient d\'y être envoyé.'**
  String resetCodeSent(String email);

  /// No description provided for @resetButton.
  ///
  /// In fr, this message translates to:
  /// **'Changer le mot de passe'**
  String get resetButton;

  /// No description provided for @passwordChanged.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe modifié. Vous êtes connecté.'**
  String get passwordChanged;

  /// No description provided for @errorEmailInvalid.
  ///
  /// In fr, this message translates to:
  /// **'Adresse e-mail invalide'**
  String get errorEmailInvalid;

  /// No description provided for @errorPasswordShort.
  ///
  /// In fr, this message translates to:
  /// **'8 caractères minimum'**
  String get errorPasswordShort;

  /// No description provided for @errorPasswordWeak.
  ///
  /// In fr, this message translates to:
  /// **'Au moins une lettre et un chiffre'**
  String get errorPasswordWeak;

  /// No description provided for @errorPasswordMismatch.
  ///
  /// In fr, this message translates to:
  /// **'Les mots de passe ne correspondent pas'**
  String get errorPasswordMismatch;

  /// No description provided for @errorCodeInvalid.
  ///
  /// In fr, this message translates to:
  /// **'Saisissez le code à 6 chiffres'**
  String get errorCodeInvalid;

  /// No description provided for @errorBadCredentials.
  ///
  /// In fr, this message translates to:
  /// **'E-mail ou mot de passe incorrect'**
  String get errorBadCredentials;

  /// No description provided for @errorCodeExpired.
  ///
  /// In fr, this message translates to:
  /// **'Code incorrect ou expiré. Demandez-en un nouveau.'**
  String get errorCodeExpired;

  /// No description provided for @errorNetwork.
  ///
  /// In fr, this message translates to:
  /// **'Connexion impossible. Vérifiez votre réseau et réessayez.'**
  String get errorNetwork;

  /// No description provided for @errorTooManyRequests.
  ///
  /// In fr, this message translates to:
  /// **'Trop de tentatives. Patientez quelques minutes avant de réessayer.'**
  String get errorTooManyRequests;

  /// No description provided for @errorForbidden.
  ///
  /// In fr, this message translates to:
  /// **'Action réservée aux administrateurs.'**
  String get errorForbidden;

  /// No description provided for @errorEmailNotSent.
  ///
  /// In fr, this message translates to:
  /// **'L\'e-mail n\'a pas pu être envoyé. Réessayez dans quelques minutes.'**
  String get errorEmailNotSent;

  /// No description provided for @errorGeneric.
  ///
  /// In fr, this message translates to:
  /// **'Une erreur est survenue. Réessayez.'**
  String get errorGeneric;

  /// No description provided for @errorOrgName.
  ///
  /// In fr, this message translates to:
  /// **'Entre 2 et 120 caractères'**
  String get errorOrgName;

  /// No description provided for @retry.
  ///
  /// In fr, this message translates to:
  /// **'Réessayer'**
  String get retry;

  /// No description provided for @cancel.
  ///
  /// In fr, this message translates to:
  /// **'Annuler'**
  String get cancel;

  /// No description provided for @logout.
  ///
  /// In fr, this message translates to:
  /// **'Se déconnecter'**
  String get logout;

  /// No description provided for @accountTitle.
  ///
  /// In fr, this message translates to:
  /// **'Mon compte'**
  String get accountTitle;

  /// No description provided for @languageLabel.
  ///
  /// In fr, this message translates to:
  /// **'Langue'**
  String get languageLabel;

  /// No description provided for @organizationLabel.
  ///
  /// In fr, this message translates to:
  /// **'Organisation'**
  String get organizationLabel;

  /// No description provided for @roleLabel.
  ///
  /// In fr, this message translates to:
  /// **'Rôle'**
  String get roleLabel;

  /// No description provided for @roleAdmin.
  ///
  /// In fr, this message translates to:
  /// **'Admin'**
  String get roleAdmin;

  /// No description provided for @roleEditor.
  ///
  /// In fr, this message translates to:
  /// **'Éditeur'**
  String get roleEditor;

  /// No description provided for @roleViewer.
  ///
  /// In fr, this message translates to:
  /// **'Lecteur'**
  String get roleViewer;

  /// No description provided for @superadminConsole.
  ///
  /// In fr, this message translates to:
  /// **'Console super-admin'**
  String get superadminConsole;

  /// No description provided for @noOrgTitle.
  ///
  /// In fr, this message translates to:
  /// **'Aucune organisation'**
  String get noOrgTitle;

  /// No description provided for @noOrgBody.
  ///
  /// In fr, this message translates to:
  /// **'Votre compte n\'est rattaché à aucune organisation. Demandez une invitation à l\'administrateur de votre atelier.'**
  String get noOrgBody;

  /// No description provided for @loadingError.
  ///
  /// In fr, this message translates to:
  /// **'Impossible de charger votre espace.'**
  String get loadingError;

  /// No description provided for @adminTitle.
  ///
  /// In fr, this message translates to:
  /// **'Console super-admin'**
  String get adminTitle;

  /// No description provided for @adminNewAtelier.
  ///
  /// In fr, this message translates to:
  /// **'Nouvel atelier'**
  String get adminNewAtelier;

  /// No description provided for @adminEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Aucune organisation pour l\'instant. Créez le premier atelier pilote.'**
  String get adminEmpty;

  /// No description provided for @adminOrgName.
  ///
  /// In fr, this message translates to:
  /// **'Nom de l\'atelier'**
  String get adminOrgName;

  /// No description provided for @adminAdminEmail.
  ///
  /// In fr, this message translates to:
  /// **'E-mail de son admin'**
  String get adminAdminEmail;

  /// No description provided for @adminCreate.
  ///
  /// In fr, this message translates to:
  /// **'Créer et inviter'**
  String get adminCreate;

  /// No description provided for @adminCreated.
  ///
  /// In fr, this message translates to:
  /// **'Atelier créé. Invitation envoyée à {email}.'**
  String adminCreated(String email);

  /// No description provided for @adminInvitePending.
  ///
  /// In fr, this message translates to:
  /// **'Invitation en attente : {email} · expire le {date}'**
  String adminInvitePending(String email, String date);

  /// No description provided for @adminInviteExpired.
  ///
  /// In fr, this message translates to:
  /// **'Invitation expirée : {email}'**
  String adminInviteExpired(String email);

  /// No description provided for @adminMembers.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =0{Aucun membre} =1{1 membre} other{{count} membres}}'**
  String adminMembers(int count);

  /// No description provided for @adminReinvite.
  ///
  /// In fr, this message translates to:
  /// **'Renvoyer une invitation'**
  String get adminReinvite;

  /// No description provided for @adminReinvited.
  ///
  /// In fr, this message translates to:
  /// **'Invitation renvoyée à {email}.'**
  String adminReinvited(String email);

  /// No description provided for @orgKindAtelier.
  ///
  /// In fr, this message translates to:
  /// **'Atelier'**
  String get orgKindAtelier;

  /// No description provided for @orgKindSupplier.
  ///
  /// In fr, this message translates to:
  /// **'Fournisseur'**
  String get orgKindSupplier;

  /// No description provided for @missingConfig.
  ///
  /// In fr, this message translates to:
  /// **'Configuration Supabase manquante. Copiez env.example.json en env.json, renseignez-le, puis lancez : flutter run --dart-define-from-file=env.json'**
  String get missingConfig;

  /// No description provided for @membersEntry.
  ///
  /// In fr, this message translates to:
  /// **'Membres de l\'atelier'**
  String get membersEntry;

  /// No description provided for @membersTitle.
  ///
  /// In fr, this message translates to:
  /// **'Membres'**
  String get membersTitle;

  /// No description provided for @membersInvite.
  ///
  /// In fr, this message translates to:
  /// **'Inviter'**
  String get membersInvite;

  /// No description provided for @inviteDialogTitle.
  ///
  /// In fr, this message translates to:
  /// **'Inviter un membre'**
  String get inviteDialogTitle;

  /// No description provided for @inviteSend.
  ///
  /// In fr, this message translates to:
  /// **'Envoyer l\'invitation'**
  String get inviteSend;

  /// No description provided for @roleAdminHelp.
  ///
  /// In fr, this message translates to:
  /// **'Gère les membres et les paramètres de l\'atelier'**
  String get roleAdminHelp;

  /// No description provided for @roleEditorHelp.
  ///
  /// In fr, this message translates to:
  /// **'Crée, modifie, scanne, importe et partage'**
  String get roleEditorHelp;

  /// No description provided for @roleViewerHelp.
  ///
  /// In fr, this message translates to:
  /// **'Consulte et exporte, sans rien modifier'**
  String get roleViewerHelp;

  /// No description provided for @youSuffix.
  ///
  /// In fr, this message translates to:
  /// **'vous'**
  String get youSuffix;

  /// No description provided for @pendingInvitations.
  ///
  /// In fr, this message translates to:
  /// **'Invitations en attente'**
  String get pendingInvitations;

  /// No description provided for @invitationExpiresOn.
  ///
  /// In fr, this message translates to:
  /// **'Expire le {date}'**
  String invitationExpiresOn(String date);

  /// No description provided for @invitationExpiredShort.
  ///
  /// In fr, this message translates to:
  /// **'Expirée'**
  String get invitationExpiredShort;

  /// No description provided for @resendInvitation.
  ///
  /// In fr, this message translates to:
  /// **'Renvoyer'**
  String get resendInvitation;

  /// No description provided for @cancelInvitation.
  ///
  /// In fr, this message translates to:
  /// **'Annuler l\'invitation'**
  String get cancelInvitation;

  /// No description provided for @invitationSent.
  ///
  /// In fr, this message translates to:
  /// **'Invitation envoyée à {email}.'**
  String invitationSent(String email);

  /// No description provided for @invitationCanceled.
  ///
  /// In fr, this message translates to:
  /// **'Invitation annulée.'**
  String get invitationCanceled;

  /// No description provided for @changeRole.
  ///
  /// In fr, this message translates to:
  /// **'Changer le rôle'**
  String get changeRole;

  /// No description provided for @roleChanged.
  ///
  /// In fr, this message translates to:
  /// **'Rôle mis à jour.'**
  String get roleChanged;

  /// No description provided for @removeMember.
  ///
  /// In fr, this message translates to:
  /// **'Retirer de l\'atelier'**
  String get removeMember;

  /// No description provided for @removeConfirmTitle.
  ///
  /// In fr, this message translates to:
  /// **'Retirer {name} ?'**
  String removeConfirmTitle(String name);

  /// No description provided for @removeConfirmBody.
  ///
  /// In fr, this message translates to:
  /// **'Cette personne perdra immédiatement l\'accès aux données de l\'atelier. Vous pourrez l\'inviter à nouveau.'**
  String get removeConfirmBody;

  /// No description provided for @removeConfirm.
  ///
  /// In fr, this message translates to:
  /// **'Retirer'**
  String get removeConfirm;

  /// No description provided for @memberRemoved.
  ///
  /// In fr, this message translates to:
  /// **'Membre retiré.'**
  String get memberRemoved;

  /// No description provided for @errorLastAdmin.
  ///
  /// In fr, this message translates to:
  /// **'L\'atelier doit garder au moins un admin. Nommez d\'abord un autre admin.'**
  String get errorLastAdmin;

  /// No description provided for @lastAdminHint.
  ///
  /// In fr, this message translates to:
  /// **'Seul admin de l\'atelier'**
  String get lastAdminHint;

  /// No description provided for @memberActions.
  ///
  /// In fr, this message translates to:
  /// **'Actions pour {name}'**
  String memberActions(String name);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'en',
    'es',
    'fr',
    'it',
    'pt',
    'ro',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'it':
      return AppLocalizationsIt();
    case 'pt':
      return AppLocalizationsPt();
    case 'ro':
      return AppLocalizationsRo();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
