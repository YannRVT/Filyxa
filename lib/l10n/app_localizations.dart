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

  /// No description provided for @libraryNew.
  ///
  /// In fr, this message translates to:
  /// **'Nouvelle matière'**
  String get libraryNew;

  /// No description provided for @viewGallery.
  ///
  /// In fr, this message translates to:
  /// **'Galerie'**
  String get viewGallery;

  /// No description provided for @viewTable.
  ///
  /// In fr, this message translates to:
  /// **'Tableau'**
  String get viewTable;

  /// No description provided for @libraryEmptyTitle.
  ///
  /// In fr, this message translates to:
  /// **'Votre TissuTech est vide'**
  String get libraryEmptyTitle;

  /// No description provided for @libraryEmptyBody.
  ///
  /// In fr, this message translates to:
  /// **'Ajoutez vos premières matières : scannez l\'étiquette d\'un échantillon, importez votre fichier Excel ou saisissez-les à la main.'**
  String get libraryEmptyBody;

  /// No description provided for @libraryEmptyViewer.
  ///
  /// In fr, this message translates to:
  /// **'Aucune matière pour l\'instant. Les éditeurs de votre atelier peuvent en ajouter.'**
  String get libraryEmptyViewer;

  /// No description provided for @actionScanSample.
  ///
  /// In fr, this message translates to:
  /// **'Scanner un échantillon'**
  String get actionScanSample;

  /// No description provided for @actionImportExcel.
  ///
  /// In fr, this message translates to:
  /// **'Importer un fichier Excel'**
  String get actionImportExcel;

  /// No description provided for @actionCreateManual.
  ///
  /// In fr, this message translates to:
  /// **'Saisir à la main'**
  String get actionCreateManual;

  /// No description provided for @materialCount.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =0{Aucune matière} =1{1 matière} other{{count} matières}}'**
  String materialCount(int count);

  /// No description provided for @colMaterial.
  ///
  /// In fr, this message translates to:
  /// **'Matière'**
  String get colMaterial;

  /// No description provided for @colReference.
  ///
  /// In fr, this message translates to:
  /// **'Référence'**
  String get colReference;

  /// No description provided for @colComposition.
  ///
  /// In fr, this message translates to:
  /// **'Composition'**
  String get colComposition;

  /// No description provided for @colWeight.
  ///
  /// In fr, this message translates to:
  /// **'g/m²'**
  String get colWeight;

  /// No description provided for @colWidth.
  ///
  /// In fr, this message translates to:
  /// **'Laize'**
  String get colWidth;

  /// No description provided for @colStock.
  ///
  /// In fr, this message translates to:
  /// **'Stock atelier'**
  String get colStock;

  /// No description provided for @fieldName.
  ///
  /// In fr, this message translates to:
  /// **'Nom de la matière'**
  String get fieldName;

  /// No description provided for @fieldSupplier.
  ///
  /// In fr, this message translates to:
  /// **'Fournisseur'**
  String get fieldSupplier;

  /// No description provided for @fieldSupplierCode.
  ///
  /// In fr, this message translates to:
  /// **'Code article'**
  String get fieldSupplierCode;

  /// No description provided for @fieldColorName.
  ///
  /// In fr, this message translates to:
  /// **'Coloris'**
  String get fieldColorName;

  /// No description provided for @fieldColorHex.
  ///
  /// In fr, this message translates to:
  /// **'Couleur (#RRGGBB)'**
  String get fieldColorHex;

  /// No description provided for @photoAdd.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter une photo'**
  String get photoAdd;

  /// No description provided for @photoChange.
  ///
  /// In fr, this message translates to:
  /// **'Changer la photo'**
  String get photoChange;

  /// No description provided for @photoRemove.
  ///
  /// In fr, this message translates to:
  /// **'Retirer la photo'**
  String get photoRemove;

  /// No description provided for @sectionIdentity.
  ///
  /// In fr, this message translates to:
  /// **'Identité'**
  String get sectionIdentity;

  /// No description provided for @sectionColor.
  ///
  /// In fr, this message translates to:
  /// **'Couleur et photo'**
  String get sectionColor;

  /// No description provided for @sectionComposition.
  ///
  /// In fr, this message translates to:
  /// **'Composition'**
  String get sectionComposition;

  /// No description provided for @sectionTechnical.
  ///
  /// In fr, this message translates to:
  /// **'Caractéristiques'**
  String get sectionTechnical;

  /// No description provided for @sectionCare.
  ///
  /// In fr, this message translates to:
  /// **'Entretien'**
  String get sectionCare;

  /// No description provided for @sectionUses.
  ///
  /// In fr, this message translates to:
  /// **'Usages et certifications'**
  String get sectionUses;

  /// No description provided for @sectionStock.
  ///
  /// In fr, this message translates to:
  /// **'Stock atelier'**
  String get sectionStock;

  /// No description provided for @sectionNotes.
  ///
  /// In fr, this message translates to:
  /// **'Notes'**
  String get sectionNotes;

  /// No description provided for @addFiber.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter une fibre'**
  String get addFiber;

  /// No description provided for @removeFiber.
  ///
  /// In fr, this message translates to:
  /// **'Retirer cette fibre'**
  String get removeFiber;

  /// No description provided for @fiberLabel.
  ///
  /// In fr, this message translates to:
  /// **'Fibre'**
  String get fiberLabel;

  /// No description provided for @compositionTotal.
  ///
  /// In fr, this message translates to:
  /// **'Total : {total} %'**
  String compositionTotal(String total);

  /// No description provided for @compositionMustBe100.
  ///
  /// In fr, this message translates to:
  /// **'Le total doit faire 100 %, sans fibre en double'**
  String get compositionMustBe100;

  /// No description provided for @fieldWeight.
  ///
  /// In fr, this message translates to:
  /// **'Grammage (g/m²)'**
  String get fieldWeight;

  /// No description provided for @fieldWidth.
  ///
  /// In fr, this message translates to:
  /// **'Laize (cm)'**
  String get fieldWidth;

  /// No description provided for @fieldWeave.
  ///
  /// In fr, this message translates to:
  /// **'Armure'**
  String get fieldWeave;

  /// No description provided for @noneOption.
  ///
  /// In fr, this message translates to:
  /// **'Non renseigné'**
  String get noneOption;

  /// No description provided for @fieldCertifications.
  ///
  /// In fr, this message translates to:
  /// **'Certifications'**
  String get fieldCertifications;

  /// No description provided for @fieldUses.
  ///
  /// In fr, this message translates to:
  /// **'Usages'**
  String get fieldUses;

  /// No description provided for @fieldStock.
  ///
  /// In fr, this message translates to:
  /// **'Métrage en stock (m)'**
  String get fieldStock;

  /// No description provided for @errorRequired.
  ///
  /// In fr, this message translates to:
  /// **'Champ obligatoire'**
  String get errorRequired;

  /// No description provided for @errorNumberRange.
  ///
  /// In fr, this message translates to:
  /// **'Nombre entre {min} et {max}'**
  String errorNumberRange(int min, int max);

  /// No description provided for @errorHex.
  ///
  /// In fr, this message translates to:
  /// **'Format #RRGGBB attendu (ex. #2F4A6B)'**
  String get errorHex;

  /// No description provided for @save.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrer'**
  String get save;

  /// No description provided for @materialSaved.
  ///
  /// In fr, this message translates to:
  /// **'Matière enregistrée.'**
  String get materialSaved;

  /// No description provided for @edit.
  ///
  /// In fr, this message translates to:
  /// **'Modifier'**
  String get edit;

  /// No description provided for @delete.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer'**
  String get delete;

  /// No description provided for @deleteMaterialTitle.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer « {name} » ?'**
  String deleteMaterialTitle(String name);

  /// No description provided for @deleteMaterialBody.
  ///
  /// In fr, this message translates to:
  /// **'La matière et sa photo seront définitivement supprimées.'**
  String get deleteMaterialBody;

  /// No description provided for @materialDeleted.
  ///
  /// In fr, this message translates to:
  /// **'Matière supprimée.'**
  String get materialDeleted;

  /// No description provided for @editStock.
  ///
  /// In fr, this message translates to:
  /// **'Modifier le stock'**
  String get editStock;

  /// No description provided for @stockUpdated.
  ///
  /// In fr, this message translates to:
  /// **'Stock mis à jour.'**
  String get stockUpdated;

  /// No description provided for @stockMeters.
  ///
  /// In fr, this message translates to:
  /// **'{value} m'**
  String stockMeters(String value);

  /// No description provided for @materialNotFound.
  ///
  /// In fr, this message translates to:
  /// **'Cette matière n\'existe plus ou n\'est pas accessible.'**
  String get materialNotFound;

  /// No description provided for @newMaterialTitle.
  ///
  /// In fr, this message translates to:
  /// **'Nouvelle matière'**
  String get newMaterialTitle;

  /// No description provided for @editMaterialTitle.
  ///
  /// In fr, this message translates to:
  /// **'Modifier la matière'**
  String get editMaterialTitle;

  /// No description provided for @detailWeight.
  ///
  /// In fr, this message translates to:
  /// **'Grammage'**
  String get detailWeight;

  /// No description provided for @detailWidth.
  ///
  /// In fr, this message translates to:
  /// **'Laize'**
  String get detailWidth;

  /// No description provided for @photoUploadFailed.
  ///
  /// In fr, this message translates to:
  /// **'La photo n\'a pas pu être envoyée. Réessayez.'**
  String get photoUploadFailed;

  /// No description provided for @viewerReadOnly.
  ///
  /// In fr, this message translates to:
  /// **'Lecture seule'**
  String get viewerReadOnly;

  /// No description provided for @errorEditorsOnly.
  ///
  /// In fr, this message translates to:
  /// **'Action réservée aux éditeurs et aux administrateurs de l\'atelier.'**
  String get errorEditorsOnly;

  /// No description provided for @searchHint.
  ///
  /// In fr, this message translates to:
  /// **'Rechercher : nom, code, fournisseur, couleur, fibre…'**
  String get searchHint;

  /// No description provided for @clearSearch.
  ///
  /// In fr, this message translates to:
  /// **'Effacer la recherche'**
  String get clearSearch;

  /// No description provided for @filtersButton.
  ///
  /// In fr, this message translates to:
  /// **'Filtres'**
  String get filtersButton;

  /// No description provided for @clearFilters.
  ///
  /// In fr, this message translates to:
  /// **'Effacer les filtres'**
  String get clearFilters;

  /// No description provided for @showResults.
  ///
  /// In fr, this message translates to:
  /// **'Afficher les résultats'**
  String get showResults;

  /// No description provided for @noResultsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Aucun résultat'**
  String get noResultsTitle;

  /// No description provided for @noResultsBody.
  ///
  /// In fr, this message translates to:
  /// **'Aucune matière ne correspond à votre recherche ou à vos filtres.'**
  String get noResultsBody;

  /// No description provided for @resultCount.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =0{Aucun résultat} =1{1 résultat} other{{count} résultats}}'**
  String resultCount(int count);

  /// No description provided for @filterFiber.
  ///
  /// In fr, this message translates to:
  /// **'Fibre'**
  String get filterFiber;

  /// No description provided for @filterFiberAny.
  ///
  /// In fr, this message translates to:
  /// **'Toutes les fibres'**
  String get filterFiberAny;

  /// No description provided for @filterFiberMin.
  ///
  /// In fr, this message translates to:
  /// **'Au moins {pct} %'**
  String filterFiberMin(int pct);

  /// No description provided for @filterWeight.
  ///
  /// In fr, this message translates to:
  /// **'Grammage'**
  String get filterWeight;

  /// No description provided for @filterColor.
  ///
  /// In fr, this message translates to:
  /// **'Couleur'**
  String get filterColor;

  /// No description provided for @filterInStock.
  ///
  /// In fr, this message translates to:
  /// **'En stock à l\'atelier'**
  String get filterInStock;

  /// No description provided for @removeFilter.
  ///
  /// In fr, this message translates to:
  /// **'Retirer le filtre {label}'**
  String removeFilter(String label);

  /// No description provided for @chipFiberMin.
  ///
  /// In fr, this message translates to:
  /// **'{fiber} ≥ {pct} %'**
  String chipFiberMin(String fiber, int pct);

  /// No description provided for @chipWeightRange.
  ///
  /// In fr, this message translates to:
  /// **'{min}–{max} g/m²'**
  String chipWeightRange(int min, int max);

  /// No description provided for @chipWeightMin.
  ///
  /// In fr, this message translates to:
  /// **'≥ {min} g/m²'**
  String chipWeightMin(int min);

  /// No description provided for @chipWeightMax.
  ///
  /// In fr, this message translates to:
  /// **'≤ {max} g/m²'**
  String chipWeightMax(int max);

  /// No description provided for @navCatalog.
  ///
  /// In fr, this message translates to:
  /// **'Catalogue'**
  String get navCatalog;

  /// No description provided for @catalogEmptyTitle.
  ///
  /// In fr, this message translates to:
  /// **'Votre catalogue est vide'**
  String get catalogEmptyTitle;

  /// No description provided for @catalogEmptyBody.
  ///
  /// In fr, this message translates to:
  /// **'Importez votre catalogue depuis un fichier Excel ou CSV exporté de votre logiciel de gestion.'**
  String get catalogEmptyBody;

  /// No description provided for @catalogImport.
  ///
  /// In fr, this message translates to:
  /// **'Importer un fichier'**
  String get catalogImport;

  /// No description provided for @catalogSettings.
  ///
  /// In fr, this message translates to:
  /// **'Disponibilité'**
  String get catalogSettings;

  /// No description provided for @referenceCount.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =0{Aucune référence} =1{1 référence} other{{count} références}}'**
  String referenceCount(int count);

  /// No description provided for @showRetired.
  ///
  /// In fr, this message translates to:
  /// **'Afficher les références retirées'**
  String get showRetired;

  /// No description provided for @retiredBadge.
  ///
  /// In fr, this message translates to:
  /// **'Retirée'**
  String get retiredBadge;

  /// No description provided for @colStatus.
  ///
  /// In fr, this message translates to:
  /// **'Disponibilité'**
  String get colStatus;

  /// No description provided for @colLeadTime.
  ///
  /// In fr, this message translates to:
  /// **'Délai'**
  String get colLeadTime;

  /// No description provided for @statusAvailable.
  ///
  /// In fr, this message translates to:
  /// **'Disponible'**
  String get statusAvailable;

  /// No description provided for @statusLow.
  ///
  /// In fr, this message translates to:
  /// **'Stock faible'**
  String get statusLow;

  /// No description provided for @statusOnOrder.
  ///
  /// In fr, this message translates to:
  /// **'Sur commande'**
  String get statusOnOrder;

  /// No description provided for @statusOnOrderWeeks.
  ///
  /// In fr, this message translates to:
  /// **'Sur commande · {weeks} sem.'**
  String statusOnOrderWeeks(int weeks);

  /// No description provided for @statusOutOfStock.
  ///
  /// In fr, this message translates to:
  /// **'Rupture'**
  String get statusOutOfStock;

  /// No description provided for @statusHidden.
  ///
  /// In fr, this message translates to:
  /// **'Masquée'**
  String get statusHidden;

  /// No description provided for @modeExact.
  ///
  /// In fr, this message translates to:
  /// **'Quantité exacte'**
  String get modeExact;

  /// No description provided for @modeTiers.
  ///
  /// In fr, this message translates to:
  /// **'Paliers'**
  String get modeTiers;

  /// No description provided for @modeHidden.
  ///
  /// In fr, this message translates to:
  /// **'Masquée'**
  String get modeHidden;

  /// No description provided for @modeExactHelp.
  ///
  /// In fr, this message translates to:
  /// **'Les ateliers voient votre métrage exact.'**
  String get modeExactHelp;

  /// No description provided for @modeTiersHelp.
  ///
  /// In fr, this message translates to:
  /// **'Les ateliers voient seulement : disponible, stock faible, sur commande ou rupture.'**
  String get modeTiersHelp;

  /// No description provided for @modeHiddenHelp.
  ///
  /// In fr, this message translates to:
  /// **'Les ateliers ne voient pas la disponibilité.'**
  String get modeHiddenHelp;

  /// No description provided for @modeDefault.
  ///
  /// In fr, this message translates to:
  /// **'Réglage général ({mode})'**
  String modeDefault(String mode);

  /// No description provided for @thresholdLabel.
  ///
  /// In fr, this message translates to:
  /// **'Seuil de stock faible (m)'**
  String get thresholdLabel;

  /// No description provided for @thresholdHelp.
  ///
  /// In fr, this message translates to:
  /// **'En dessous de ce métrage, la référence apparaît en « stock faible ».'**
  String get thresholdHelp;

  /// No description provided for @leadTimeLabel.
  ///
  /// In fr, this message translates to:
  /// **'Délai de réassort (semaines)'**
  String get leadTimeLabel;

  /// No description provided for @leadTimeHelp.
  ///
  /// In fr, this message translates to:
  /// **'Affiché quand la référence est sur commande.'**
  String get leadTimeHelp;

  /// No description provided for @availabilitySettingsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Affichage de la disponibilité'**
  String get availabilitySettingsTitle;

  /// No description provided for @availabilitySettingsIntro.
  ///
  /// In fr, this message translates to:
  /// **'Choisissez ce que les ateliers voient de votre stock. Vous pouvez ajuster chaque référence depuis sa fiche.'**
  String get availabilitySettingsIntro;

  /// No description provided for @settingsSaved.
  ///
  /// In fr, this message translates to:
  /// **'Réglages enregistrés.'**
  String get settingsSaved;

  /// No description provided for @referenceRetire.
  ///
  /// In fr, this message translates to:
  /// **'Retirer du catalogue'**
  String get referenceRetire;

  /// No description provided for @referenceRestore.
  ///
  /// In fr, this message translates to:
  /// **'Remettre au catalogue'**
  String get referenceRestore;

  /// No description provided for @referenceRetired.
  ///
  /// In fr, this message translates to:
  /// **'Référence retirée du catalogue publié.'**
  String get referenceRetired;

  /// No description provided for @referenceRestored.
  ///
  /// In fr, this message translates to:
  /// **'Référence remise au catalogue.'**
  String get referenceRestored;

  /// No description provided for @retireConfirmTitle.
  ///
  /// In fr, this message translates to:
  /// **'Retirer « {code} » ?'**
  String retireConfirmTitle(String code);

  /// No description provided for @retireConfirmBody.
  ///
  /// In fr, this message translates to:
  /// **'Elle ne sera plus visible par les ateliers. Ceux qui l\'utilisent garderont sa dernière fiche. Vous pourrez la remettre au catalogue.'**
  String get retireConfirmBody;

  /// No description provided for @referenceAvailabilityTitle.
  ///
  /// In fr, this message translates to:
  /// **'Disponibilité de cette référence'**
  String get referenceAvailabilityTitle;

  /// No description provided for @stockLabel.
  ///
  /// In fr, this message translates to:
  /// **'Stock'**
  String get stockLabel;

  /// No description provided for @whatAteliersSee.
  ///
  /// In fr, this message translates to:
  /// **'Ce que voient les ateliers : {value}'**
  String whatAteliersSee(String value);

  /// No description provided for @importTitle.
  ///
  /// In fr, this message translates to:
  /// **'Importer le catalogue'**
  String get importTitle;

  /// No description provided for @importPickFile.
  ///
  /// In fr, this message translates to:
  /// **'Choisir un fichier Excel ou CSV'**
  String get importPickFile;

  /// No description provided for @importPickHelp.
  ///
  /// In fr, this message translates to:
  /// **'Fichier .xlsx ou .csv, une ligne par référence et une ligne d\'intitulés. 5 000 lignes au maximum. Une référence déjà connue est mise à jour par son code.'**
  String get importPickHelp;

  /// No description provided for @importUnreadable.
  ///
  /// In fr, this message translates to:
  /// **'Ce fichier n\'a pas pu être lu. Enregistrez-le au format .xlsx ou .csv puis réessayez.'**
  String get importUnreadable;

  /// No description provided for @importTooMany.
  ///
  /// In fr, this message translates to:
  /// **'Ce fichier contient {count} lignes : 5 000 au maximum par import.'**
  String importTooMany(int count);

  /// No description provided for @importMappingTitle.
  ///
  /// In fr, this message translates to:
  /// **'Associez vos colonnes'**
  String get importMappingTitle;

  /// No description provided for @importMappingIntro.
  ///
  /// In fr, this message translates to:
  /// **'Les colonnes reconnues sont déjà associées. Le code article et la désignation sont obligatoires.'**
  String get importMappingIntro;

  /// No description provided for @importColumnNone.
  ///
  /// In fr, this message translates to:
  /// **'— Ignorer —'**
  String get importColumnNone;

  /// No description provided for @importFieldName.
  ///
  /// In fr, this message translates to:
  /// **'Désignation'**
  String get importFieldName;

  /// No description provided for @importFieldStock.
  ///
  /// In fr, this message translates to:
  /// **'Stock (m)'**
  String get importFieldStock;

  /// No description provided for @importSummary.
  ///
  /// In fr, this message translates to:
  /// **'{valid} lignes prêtes · {invalid} en erreur'**
  String importSummary(int valid, int invalid);

  /// No description provided for @importErrorsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Lignes en erreur (non importées)'**
  String get importErrorsTitle;

  /// No description provided for @importLine.
  ///
  /// In fr, this message translates to:
  /// **'Ligne {line}'**
  String importLine(int line);

  /// No description provided for @importRun.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =1{Importer 1 référence} other{Importer {count} références}}'**
  String importRun(int count);

  /// No description provided for @importRunning.
  ///
  /// In fr, this message translates to:
  /// **'Import en cours… {done}/{total}'**
  String importRunning(int done, int total);

  /// No description provided for @importDoneTitle.
  ///
  /// In fr, this message translates to:
  /// **'Import terminé'**
  String get importDoneTitle;

  /// No description provided for @importDone.
  ///
  /// In fr, this message translates to:
  /// **'{inserted} créées · {updated} mises à jour'**
  String importDone(int inserted, int updated);

  /// No description provided for @importServerRejected.
  ///
  /// In fr, this message translates to:
  /// **'Refusée par le serveur : {message}'**
  String importServerRejected(String message);

  /// No description provided for @importAgain.
  ///
  /// In fr, this message translates to:
  /// **'Importer un autre fichier'**
  String get importAgain;

  /// No description provided for @backToCatalog.
  ///
  /// In fr, this message translates to:
  /// **'Retour au catalogue'**
  String get backToCatalog;

  /// No description provided for @importFileName.
  ///
  /// In fr, this message translates to:
  /// **'Fichier : {name}'**
  String importFileName(String name);

  /// No description provided for @issueMissingCode.
  ///
  /// In fr, this message translates to:
  /// **'Code article manquant'**
  String get issueMissingCode;

  /// No description provided for @issueMissingName.
  ///
  /// In fr, this message translates to:
  /// **'Désignation manquante'**
  String get issueMissingName;

  /// No description provided for @issueComposition.
  ///
  /// In fr, this message translates to:
  /// **'Composition illisible ou différente de 100 % : « {value} »'**
  String issueComposition(String value);

  /// No description provided for @issueNumber.
  ///
  /// In fr, this message translates to:
  /// **'{field} : valeur invalide « {value} »'**
  String issueNumber(String field, String value);

  /// No description provided for @issueColor.
  ///
  /// In fr, this message translates to:
  /// **'Couleur invalide « {value} » (format #RRGGBB)'**
  String issueColor(String value);

  /// No description provided for @issueDuplicate.
  ///
  /// In fr, this message translates to:
  /// **'Code « {value} » présent plusieurs fois dans le fichier'**
  String issueDuplicate(String value);

  /// No description provided for @adminOrgKind.
  ///
  /// In fr, this message translates to:
  /// **'Type d\'organisation'**
  String get adminOrgKind;

  /// No description provided for @adminNewOrg.
  ///
  /// In fr, this message translates to:
  /// **'Nouvelle organisation'**
  String get adminNewOrg;

  /// No description provided for @adminOrgNameGeneric.
  ///
  /// In fr, this message translates to:
  /// **'Nom de l\'organisation'**
  String get adminOrgNameGeneric;

  /// No description provided for @scanTitle.
  ///
  /// In fr, this message translates to:
  /// **'Scanner un échantillon'**
  String get scanTitle;

  /// No description provided for @scanIntro.
  ///
  /// In fr, this message translates to:
  /// **'Photographiez l\'étiquette de l\'échantillon, bien à plat et nette. Filyxa lit la composition, le grammage, la laize, l\'entretien et le code article ; vous vérifiez avant d\'enregistrer.'**
  String get scanIntro;

  /// No description provided for @scanTakePhoto.
  ///
  /// In fr, this message translates to:
  /// **'Prendre une photo'**
  String get scanTakePhoto;

  /// No description provided for @scanImportPhoto.
  ///
  /// In fr, this message translates to:
  /// **'Importer une photo'**
  String get scanImportPhoto;

  /// No description provided for @scanReading.
  ///
  /// In fr, this message translates to:
  /// **'Lecture de l\'étiquette…'**
  String get scanReading;

  /// No description provided for @scanUsage.
  ///
  /// In fr, this message translates to:
  /// **'{scans} / {quota} scans ce mois-ci'**
  String scanUsage(int scans, int quota);

  /// No description provided for @scanQuotaWarning.
  ///
  /// In fr, this message translates to:
  /// **'{percent} % du quota mensuel de scans est utilisé.'**
  String scanQuotaWarning(int percent);

  /// No description provided for @scanQuotaExhausted.
  ///
  /// In fr, this message translates to:
  /// **'Quota mensuel de scans atteint. La saisie à la main reste possible.'**
  String get scanQuotaExhausted;

  /// No description provided for @scanFailureNotLabel.
  ///
  /// In fr, this message translates to:
  /// **'Aucune étiquette textile lisible sur cette photo. Reprenez-la de plus près, bien à plat, sans reflet.'**
  String get scanFailureNotLabel;

  /// No description provided for @scanFailureRefused.
  ///
  /// In fr, this message translates to:
  /// **'L\'analyse de cette image a été refusée. Essayez une autre photo.'**
  String get scanFailureRefused;

  /// No description provided for @scanFailureAi.
  ///
  /// In fr, this message translates to:
  /// **'Le service de lecture est momentanément indisponible. Réessayez dans un instant.'**
  String get scanFailureAi;

  /// No description provided for @scanFailureImage.
  ///
  /// In fr, this message translates to:
  /// **'Cette image n\'est pas prise en charge (JPEG, PNG ou WebP, 5 Mo maximum).'**
  String get scanFailureImage;

  /// No description provided for @prefillBanner.
  ///
  /// In fr, this message translates to:
  /// **'Fiche pré-remplie par le scan. Vérifiez les champs signalés avant d\'enregistrer.'**
  String get prefillBanner;

  /// No description provided for @fieldUncertain.
  ///
  /// In fr, this message translates to:
  /// **'Lu avec peu de certitude : à vérifier'**
  String get fieldUncertain;

  /// No description provided for @sectionUncertain.
  ///
  /// In fr, this message translates to:
  /// **'Lecture incertaine : vérifiez cette section.'**
  String get sectionUncertain;

  /// No description provided for @duplicateFound.
  ///
  /// In fr, this message translates to:
  /// **'Une matière avec ce code article existe déjà : « {name} ».'**
  String duplicateFound(String name);

  /// No description provided for @duplicateOpen.
  ///
  /// In fr, this message translates to:
  /// **'Ouvrir la fiche existante'**
  String get duplicateOpen;

  /// No description provided for @matchTitle.
  ///
  /// In fr, this message translates to:
  /// **'C\'est bien cette référence ?'**
  String get matchTitle;

  /// No description provided for @matchIntro.
  ///
  /// In fr, this message translates to:
  /// **'Trouvée dans le catalogue de {supplier}. Confirmez pour relier votre fiche à ses données et à sa disponibilité.'**
  String matchIntro(String supplier);

  /// No description provided for @matchConfirm.
  ///
  /// In fr, this message translates to:
  /// **'Oui, lier cette référence'**
  String get matchConfirm;

  /// No description provided for @matchOthers.
  ///
  /// In fr, this message translates to:
  /// **'Autres références proches'**
  String get matchOthers;

  /// No description provided for @matchNone.
  ///
  /// In fr, this message translates to:
  /// **'Aucune de ces références'**
  String get matchNone;

  /// No description provided for @supplierData.
  ///
  /// In fr, this message translates to:
  /// **'Données fournisseur'**
  String get supplierData;

  /// No description provided for @supplierDataHelp.
  ///
  /// In fr, this message translates to:
  /// **'Tenues à jour par le fournisseur, non modifiables ici.'**
  String get supplierDataHelp;

  /// No description provided for @referenceRetiredBanner.
  ///
  /// In fr, this message translates to:
  /// **'Référence retirée par le fournisseur. Les dernières valeurs connues sont conservées.'**
  String get referenceRetiredBanner;

  /// No description provided for @linkToSupplier.
  ///
  /// In fr, this message translates to:
  /// **'Lier à une référence fournisseur'**
  String get linkToSupplier;

  /// No description provided for @linkSearchHint.
  ///
  /// In fr, this message translates to:
  /// **'Code article, désignation ou fournisseur'**
  String get linkSearchHint;

  /// No description provided for @linkSearchEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Aucune référence publiée ne correspond.'**
  String get linkSearchEmpty;

  /// No description provided for @linkConfirm.
  ///
  /// In fr, this message translates to:
  /// **'Lier'**
  String get linkConfirm;

  /// No description provided for @unlink.
  ///
  /// In fr, this message translates to:
  /// **'Délier la référence'**
  String get unlink;

  /// No description provided for @unlinkConfirmBody.
  ///
  /// In fr, this message translates to:
  /// **'La fiche garde ses valeurs actuelles et redevient modifiable. Elle ne suivra plus les mises à jour du fournisseur.'**
  String get unlinkConfirmBody;

  /// No description provided for @linkedDone.
  ///
  /// In fr, this message translates to:
  /// **'Fiche liée au fournisseur.'**
  String get linkedDone;

  /// No description provided for @unlinkedDone.
  ///
  /// In fr, this message translates to:
  /// **'Fiche déliée du fournisseur.'**
  String get unlinkedDone;

  /// No description provided for @privateLayer.
  ///
  /// In fr, this message translates to:
  /// **'Informations de l\'atelier'**
  String get privateLayer;

  /// No description provided for @privateLayerHelp.
  ///
  /// In fr, this message translates to:
  /// **'Visibles par votre atelier seulement.'**
  String get privateLayerHelp;

  /// No description provided for @fieldPrice.
  ///
  /// In fr, this message translates to:
  /// **'Prix négocié (€/m)'**
  String get fieldPrice;

  /// No description provided for @fieldTags.
  ///
  /// In fr, this message translates to:
  /// **'Étiquettes'**
  String get fieldTags;

  /// No description provided for @fieldTagsHint.
  ///
  /// In fr, this message translates to:
  /// **'Séparées par des virgules (ex. AH27, à valider)'**
  String get fieldTagsHint;

  /// No description provided for @priceValue.
  ///
  /// In fr, this message translates to:
  /// **'{value} €/m'**
  String priceValue(String value);

  /// No description provided for @atelierImportTitle.
  ///
  /// In fr, this message translates to:
  /// **'Importer la base de l\'atelier'**
  String get atelierImportTitle;

  /// No description provided for @atelierImportHelp.
  ///
  /// In fr, this message translates to:
  /// **'Fichier .xlsx ou .csv, une ligne par matière et une ligne d\'intitulés. 5 000 lignes au maximum. Une matière déjà présente (même fournisseur et même code, ou même nom et même coloris) est mise à jour, jamais dupliquée.'**
  String get atelierImportHelp;

  /// No description provided for @atelierImportMappingIntro.
  ///
  /// In fr, this message translates to:
  /// **'Les colonnes reconnues sont déjà associées. Seul le nom de la matière est obligatoire.'**
  String get atelierImportMappingIntro;

  /// No description provided for @atelierImportRun.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =1{Importer 1 matière} other{Importer {count} matières}}'**
  String atelierImportRun(int count);

  /// No description provided for @atelierImportDone.
  ///
  /// In fr, this message translates to:
  /// **'{imported} importées · {linked} reliées à un fournisseur · {pending} à confirmer · {errors} en erreur'**
  String atelierImportDone(int imported, int linked, int pending, int errors);

  /// No description provided for @atelierImportDetail.
  ///
  /// In fr, this message translates to:
  /// **'dont {inserted} nouvelles et {updated} mises à jour'**
  String atelierImportDetail(int inserted, int updated);

  /// No description provided for @backToLibrary.
  ///
  /// In fr, this message translates to:
  /// **'Retour à TissuTech'**
  String get backToLibrary;

  /// No description provided for @reviewLinksAction.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =1{Confirmer 1 correspondance} other{Confirmer {count} correspondances}}'**
  String reviewLinksAction(int count);

  /// No description provided for @pendingLinksBanner.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =1{1 matière importée ressemble à une référence fournisseur.} other{{count} matières importées ressemblent à des références fournisseur.}}'**
  String pendingLinksBanner(int count);

  /// No description provided for @reviewTitle.
  ///
  /// In fr, this message translates to:
  /// **'Correspondances à confirmer'**
  String get reviewTitle;

  /// No description provided for @reviewProgress.
  ///
  /// In fr, this message translates to:
  /// **'{index} sur {total}'**
  String reviewProgress(int index, int total);

  /// No description provided for @reviewIntro.
  ///
  /// In fr, this message translates to:
  /// **'Votre fiche ressemble à une référence publiée. Confirmez pour la relier à ses données et à sa disponibilité.'**
  String get reviewIntro;

  /// No description provided for @reviewSkip.
  ///
  /// In fr, this message translates to:
  /// **'Plus tard'**
  String get reviewSkip;

  /// No description provided for @reviewDone.
  ///
  /// In fr, this message translates to:
  /// **'Toutes les correspondances ont été traitées.'**
  String get reviewDone;

  /// No description provided for @reviewNoCandidate.
  ///
  /// In fr, this message translates to:
  /// **'Aucune référence publiée ne correspond plus à cette matière.'**
  String get reviewNoCandidate;

  /// No description provided for @reviewOpen.
  ///
  /// In fr, this message translates to:
  /// **'Traiter'**
  String get reviewOpen;

  /// No description provided for @reportAction.
  ///
  /// In fr, this message translates to:
  /// **'Signaler une erreur'**
  String get reportAction;

  /// No description provided for @reportTitle.
  ///
  /// In fr, this message translates to:
  /// **'Signaler une erreur au fournisseur'**
  String get reportTitle;

  /// No description provided for @reportIntro.
  ///
  /// In fr, this message translates to:
  /// **'Le fournisseur corrigera sa fiche pour tous les ateliers. Il ne voit pas le nom de votre atelier, sauf si vous choisissez de le partager.'**
  String get reportIntro;

  /// No description provided for @reportField.
  ///
  /// In fr, this message translates to:
  /// **'Champ concerné'**
  String get reportField;

  /// No description provided for @reportObserved.
  ///
  /// In fr, this message translates to:
  /// **'Valeur constatée'**
  String get reportObserved;

  /// No description provided for @reportObservedHint.
  ///
  /// In fr, this message translates to:
  /// **'Ex. 300 g/m² mesurés sur l\'échantillon'**
  String get reportObservedHint;

  /// No description provided for @reportComment.
  ///
  /// In fr, this message translates to:
  /// **'Commentaire (facultatif)'**
  String get reportComment;

  /// No description provided for @reportShareIdentity.
  ///
  /// In fr, this message translates to:
  /// **'Partager le nom de mon atelier avec le fournisseur'**
  String get reportShareIdentity;

  /// No description provided for @reportSend.
  ///
  /// In fr, this message translates to:
  /// **'Envoyer'**
  String get reportSend;

  /// No description provided for @reportSent.
  ///
  /// In fr, this message translates to:
  /// **'Signalement envoyé au fournisseur.'**
  String get reportSent;

  /// No description provided for @reportFieldAvailability.
  ///
  /// In fr, this message translates to:
  /// **'Disponibilité'**
  String get reportFieldAvailability;

  /// No description provided for @reportFieldOther.
  ///
  /// In fr, this message translates to:
  /// **'Autre'**
  String get reportFieldOther;

  /// No description provided for @reportsSection.
  ///
  /// In fr, this message translates to:
  /// **'Signalements'**
  String get reportsSection;

  /// No description provided for @reportStatusOpen.
  ///
  /// In fr, this message translates to:
  /// **'Ouvert'**
  String get reportStatusOpen;

  /// No description provided for @reportStatusFixed.
  ///
  /// In fr, this message translates to:
  /// **'Corrigé'**
  String get reportStatusFixed;

  /// No description provided for @reportStatusRejected.
  ///
  /// In fr, this message translates to:
  /// **'Rejeté'**
  String get reportStatusRejected;

  /// No description provided for @reportObservedLine.
  ///
  /// In fr, this message translates to:
  /// **'Constaté : {value}'**
  String reportObservedLine(String value);

  /// No description provided for @reportReasonLine.
  ///
  /// In fr, this message translates to:
  /// **'Motif : {reason}'**
  String reportReasonLine(String reason);

  /// No description provided for @reportResponseLine.
  ///
  /// In fr, this message translates to:
  /// **'Réponse : {response}'**
  String reportResponseLine(String response);

  /// No description provided for @supplierReportsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Signalements des ateliers'**
  String get supplierReportsTitle;

  /// No description provided for @supplierReportsButton.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =0{Signalements} =1{1 signalement ouvert} other{{count} signalements ouverts}}'**
  String supplierReportsButton(int count);

  /// No description provided for @supplierReportsEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Aucun signalement pour le moment.'**
  String get supplierReportsEmpty;

  /// No description provided for @reportAnonymous.
  ///
  /// In fr, this message translates to:
  /// **'Atelier anonyme'**
  String get reportAnonymous;

  /// No description provided for @reportMarkFixed.
  ///
  /// In fr, this message translates to:
  /// **'Marquer corrigé'**
  String get reportMarkFixed;

  /// No description provided for @reportReject.
  ///
  /// In fr, this message translates to:
  /// **'Rejeter'**
  String get reportReject;

  /// No description provided for @reportRejectTitle.
  ///
  /// In fr, this message translates to:
  /// **'Rejeter le signalement'**
  String get reportRejectTitle;

  /// No description provided for @reportRejectReason.
  ///
  /// In fr, this message translates to:
  /// **'Motif du rejet'**
  String get reportRejectReason;

  /// No description provided for @reportFixTitle.
  ///
  /// In fr, this message translates to:
  /// **'Marquer comme corrigé'**
  String get reportFixTitle;

  /// No description provided for @reportFixHelp.
  ///
  /// In fr, this message translates to:
  /// **'Pensez à corriger la référence dans votre catalogue : les ateliers liés la verront aussitôt.'**
  String get reportFixHelp;

  /// No description provided for @reportFixMessage.
  ///
  /// In fr, this message translates to:
  /// **'Message à l\'atelier (facultatif)'**
  String get reportFixMessage;

  /// No description provided for @reportEditReference.
  ///
  /// In fr, this message translates to:
  /// **'Ouvrir la référence'**
  String get reportEditReference;

  /// No description provided for @reportFilterOpen.
  ///
  /// In fr, this message translates to:
  /// **'Ouverts'**
  String get reportFilterOpen;

  /// No description provided for @reportFilterAll.
  ///
  /// In fr, this message translates to:
  /// **'Tous'**
  String get reportFilterAll;

  /// No description provided for @notificationsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Notifications'**
  String get notificationsTitle;

  /// No description provided for @notificationsEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Aucune notification.'**
  String get notificationsEmpty;

  /// No description provided for @notificationsTooltip.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =0{Notifications} =1{Notifications (1 non lue)} other{Notifications ({count} non lues)}}'**
  String notificationsTooltip(int count);

  /// No description provided for @notifReportNew.
  ///
  /// In fr, this message translates to:
  /// **'Nouveau signalement sur {code} · {field}'**
  String notifReportNew(String code, String field);

  /// No description provided for @notifReportFixed.
  ///
  /// In fr, this message translates to:
  /// **'{name} : le fournisseur a corrigé « {field} »'**
  String notifReportFixed(String name, String field);

  /// No description provided for @notifReportRejected.
  ///
  /// In fr, this message translates to:
  /// **'{name} : signalement sur « {field} » rejeté'**
  String notifReportRejected(String name, String field);

  /// No description provided for @studioNewCollection.
  ///
  /// In fr, this message translates to:
  /// **'Nouvelle collection'**
  String get studioNewCollection;

  /// No description provided for @studioCollectionName.
  ///
  /// In fr, this message translates to:
  /// **'Nom de la collection'**
  String get studioCollectionName;

  /// No description provided for @studioCollectionHint.
  ///
  /// In fr, this message translates to:
  /// **'Ex. AH27'**
  String get studioCollectionHint;

  /// No description provided for @studioEmptyTitle.
  ///
  /// In fr, this message translates to:
  /// **'Aucune collection pour le moment'**
  String get studioEmptyTitle;

  /// No description provided for @studioEmptyEditor.
  ///
  /// In fr, this message translates to:
  /// **'Créez une collection pour regrouper les modèles d\'une saison, par exemple « AH27 ».'**
  String get studioEmptyEditor;

  /// No description provided for @studioEmptyViewer.
  ///
  /// In fr, this message translates to:
  /// **'Les éditeurs de votre atelier n\'ont pas encore créé de collection.'**
  String get studioEmptyViewer;

  /// No description provided for @studioModelCount.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =0{Aucun modèle} =1{1 modèle} other{{count} modèles}}'**
  String studioModelCount(int count);

  /// No description provided for @collectionEmptyTitle.
  ///
  /// In fr, this message translates to:
  /// **'Cette collection est vide'**
  String get collectionEmptyTitle;

  /// No description provided for @collectionEmptyEditor.
  ///
  /// In fr, this message translates to:
  /// **'Ajoutez un premier modèle : vêtement, chaussure, maroquinerie ou accessoire.'**
  String get collectionEmptyEditor;

  /// No description provided for @collectionEmptyViewer.
  ///
  /// In fr, this message translates to:
  /// **'Aucun modèle dans cette collection pour le moment.'**
  String get collectionEmptyViewer;

  /// No description provided for @studioNewModel.
  ///
  /// In fr, this message translates to:
  /// **'Nouveau modèle'**
  String get studioNewModel;

  /// No description provided for @modelName.
  ///
  /// In fr, this message translates to:
  /// **'Nom du modèle'**
  String get modelName;

  /// No description provided for @modelReference.
  ///
  /// In fr, this message translates to:
  /// **'Référence (facultatif)'**
  String get modelReference;

  /// No description provided for @modelType.
  ///
  /// In fr, this message translates to:
  /// **'Type de produit'**
  String get modelType;

  /// No description provided for @productGarment.
  ///
  /// In fr, this message translates to:
  /// **'Vêtement'**
  String get productGarment;

  /// No description provided for @productFootwear.
  ///
  /// In fr, this message translates to:
  /// **'Chaussure'**
  String get productFootwear;

  /// No description provided for @productLeatherGoods.
  ///
  /// In fr, this message translates to:
  /// **'Maroquinerie'**
  String get productLeatherGoods;

  /// No description provided for @productAccessory.
  ///
  /// In fr, this message translates to:
  /// **'Accessoire'**
  String get productAccessory;

  /// No description provided for @colorwayCount.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =1{1 coloris} other{{count} coloris}}'**
  String colorwayCount(int count);

  /// No description provided for @bomLineCount.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =0{aucune matière} =1{1 matière} other{{count} matières}}'**
  String bomLineCount(int count);

  /// No description provided for @rename.
  ///
  /// In fr, this message translates to:
  /// **'Renommer'**
  String get rename;

  /// No description provided for @create.
  ///
  /// In fr, this message translates to:
  /// **'Créer'**
  String get create;

  /// No description provided for @add.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter'**
  String get add;

  /// No description provided for @deleteCollectionTitle.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer la collection « {name} » ?'**
  String deleteCollectionTitle(String name);

  /// No description provided for @deleteCollectionBody.
  ///
  /// In fr, this message translates to:
  /// **'Ses modèles, coloris et quantités seront définitivement supprimés. Les matières de TissuTech sont conservées.'**
  String get deleteCollectionBody;

  /// No description provided for @deleteModelTitle.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer le modèle « {name} » ?'**
  String deleteModelTitle(String name);

  /// No description provided for @deleteModelBody.
  ///
  /// In fr, this message translates to:
  /// **'Ses coloris et sa nomenclature seront définitivement supprimés. Les matières de TissuTech sont conservées.'**
  String get deleteModelBody;

  /// No description provided for @wasteLabel.
  ///
  /// In fr, this message translates to:
  /// **'Marge de perte (%)'**
  String get wasteLabel;

  /// No description provided for @quantityLabel.
  ///
  /// In fr, this message translates to:
  /// **'Quantité prévue (pièces)'**
  String get quantityLabel;

  /// No description provided for @addColorway.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter un coloris'**
  String get addColorway;

  /// No description provided for @declineColorways.
  ///
  /// In fr, this message translates to:
  /// **'Décliner en coloris'**
  String get declineColorways;

  /// No description provided for @colorwayCurrent.
  ///
  /// In fr, this message translates to:
  /// **'Coloris actuel'**
  String get colorwayCurrent;

  /// No description provided for @colorwayNew.
  ///
  /// In fr, this message translates to:
  /// **'Nouveau coloris'**
  String get colorwayNew;

  /// No description provided for @colorwayNameHint.
  ///
  /// In fr, this message translates to:
  /// **'Ex. Noir'**
  String get colorwayNameHint;

  /// No description provided for @colorwayDefault.
  ///
  /// In fr, this message translates to:
  /// **'Coloris {index}'**
  String colorwayDefault(int index);

  /// No description provided for @colorwayCopyHelp.
  ///
  /// In fr, this message translates to:
  /// **'Le nouveau coloris reprend les matières de « {name} » : vous n\'aurez qu\'à changer celles qui diffèrent.'**
  String colorwayCopyHelp(String name);

  /// No description provided for @deleteColorway.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer ce coloris'**
  String get deleteColorway;

  /// No description provided for @addMaterial.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter une matière'**
  String get addMaterial;

  /// No description provided for @modelEmptyTitle.
  ///
  /// In fr, this message translates to:
  /// **'Aucune matière dans ce modèle'**
  String get modelEmptyTitle;

  /// No description provided for @modelEmptyEditor.
  ///
  /// In fr, this message translates to:
  /// **'Ajoutez les matières du modèle et leur consommation par pièce pour calculer le besoin.'**
  String get modelEmptyEditor;

  /// No description provided for @modelEmptyViewer.
  ///
  /// In fr, this message translates to:
  /// **'Aucune matière n\'a encore été associée à ce modèle.'**
  String get modelEmptyViewer;

  /// No description provided for @bomRoleLabel.
  ///
  /// In fr, this message translates to:
  /// **'Rôle'**
  String get bomRoleLabel;

  /// No description provided for @roleOther.
  ///
  /// In fr, this message translates to:
  /// **'Autre rôle…'**
  String get roleOther;

  /// No description provided for @roleCustom.
  ///
  /// In fr, this message translates to:
  /// **'Nom du rôle'**
  String get roleCustom;

  /// No description provided for @role_main.
  ///
  /// In fr, this message translates to:
  /// **'Tissu principal'**
  String get role_main;

  /// No description provided for @role_lining.
  ///
  /// In fr, this message translates to:
  /// **'Doublure'**
  String get role_lining;

  /// No description provided for @role_interfacing.
  ///
  /// In fr, this message translates to:
  /// **'Entoilage'**
  String get role_interfacing;

  /// No description provided for @role_contrast.
  ///
  /// In fr, this message translates to:
  /// **'Tissu contrasté'**
  String get role_contrast;

  /// No description provided for @role_pocketing.
  ///
  /// In fr, this message translates to:
  /// **'Fond de poche'**
  String get role_pocketing;

  /// No description provided for @role_rib.
  ///
  /// In fr, this message translates to:
  /// **'Bord-côte'**
  String get role_rib;

  /// No description provided for @role_upper.
  ///
  /// In fr, this message translates to:
  /// **'Tige'**
  String get role_upper;

  /// No description provided for @role_sock_lining.
  ///
  /// In fr, this message translates to:
  /// **'Première de propreté'**
  String get role_sock_lining;

  /// No description provided for @role_insole.
  ///
  /// In fr, this message translates to:
  /// **'Première de montage'**
  String get role_insole;

  /// No description provided for @role_outsole.
  ///
  /// In fr, this message translates to:
  /// **'Semelle'**
  String get role_outsole;

  /// No description provided for @role_reinforcement.
  ///
  /// In fr, this message translates to:
  /// **'Renfort'**
  String get role_reinforcement;

  /// No description provided for @role_exterior.
  ///
  /// In fr, this message translates to:
  /// **'Extérieur'**
  String get role_exterior;

  /// No description provided for @role_gusset.
  ///
  /// In fr, this message translates to:
  /// **'Soufflet'**
  String get role_gusset;

  /// No description provided for @role_strap.
  ///
  /// In fr, this message translates to:
  /// **'Anse ou bandoulière'**
  String get role_strap;

  /// No description provided for @role_trim.
  ///
  /// In fr, this message translates to:
  /// **'Garniture'**
  String get role_trim;

  /// No description provided for @consumptionLabel.
  ///
  /// In fr, this message translates to:
  /// **'Consommation (m/pièce)'**
  String get consumptionLabel;

  /// No description provided for @requirementLine.
  ///
  /// In fr, this message translates to:
  /// **'Besoin : {value} m'**
  String requirementLine(String value);

  /// No description provided for @requirementTitle.
  ///
  /// In fr, this message translates to:
  /// **'Besoin total par matière'**
  String get requirementTitle;

  /// No description provided for @requirementFormula.
  ///
  /// In fr, this message translates to:
  /// **'Consommation × quantité × (1 + marge de {waste} %)'**
  String requirementFormula(String waste);

  /// No description provided for @pickMaterial.
  ///
  /// In fr, this message translates to:
  /// **'Choisir une matière'**
  String get pickMaterial;

  /// No description provided for @pickMaterialSearch.
  ///
  /// In fr, this message translates to:
  /// **'Rechercher dans TissuTech'**
  String get pickMaterialSearch;

  /// No description provided for @pickMaterialEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Aucune matière ne correspond.'**
  String get pickMaterialEmpty;

  /// No description provided for @pickMaterialLibraryEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Ajoutez d\'abord des matières dans TissuTech.'**
  String get pickMaterialLibraryEmpty;

  /// No description provided for @removeLine.
  ///
  /// In fr, this message translates to:
  /// **'Retirer cette matière'**
  String get removeLine;

  /// No description provided for @materialMissing.
  ///
  /// In fr, this message translates to:
  /// **'Matière supprimée de TissuTech'**
  String get materialMissing;

  /// No description provided for @alertsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Alertes'**
  String get alertsTitle;

  /// No description provided for @alertsNone.
  ///
  /// In fr, this message translates to:
  /// **'Aucune alerte : les matières de ce modèle sont compatibles et le stock est suffisant.'**
  String get alertsNone;

  /// No description provided for @alertsCount.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =1{1 alerte} other{{count} alertes}}'**
  String alertsCount(int count);

  /// No description provided for @alertFamilyCare.
  ///
  /// In fr, this message translates to:
  /// **'Entretien'**
  String get alertFamilyCare;

  /// No description provided for @alertFamilyTechnical.
  ///
  /// In fr, this message translates to:
  /// **'Technique'**
  String get alertFamilyTechnical;

  /// No description provided for @alertFamilyCertification.
  ///
  /// In fr, this message translates to:
  /// **'Certifications'**
  String get alertFamilyCertification;

  /// No description provided for @alertFamilyStock.
  ///
  /// In fr, this message translates to:
  /// **'Stock'**
  String get alertFamilyStock;

  /// No description provided for @alertQuoted.
  ///
  /// In fr, this message translates to:
  /// **'« {name} »'**
  String alertQuoted(String name);

  /// No description provided for @alertNoIron.
  ///
  /// In fr, this message translates to:
  /// **'aucun repassage'**
  String get alertNoIron;

  /// No description provided for @alertNoMainTitle.
  ///
  /// In fr, this message translates to:
  /// **'Aucun tissu principal'**
  String get alertNoMainTitle;

  /// No description provided for @alertNoMainBody.
  ///
  /// In fr, this message translates to:
  /// **'Désignez le tissu principal pour activer toutes les vérifications.'**
  String get alertNoMainBody;

  /// No description provided for @alertLiningHeavierTitle.
  ///
  /// In fr, this message translates to:
  /// **'Doublure plus lourde que le tissu principal'**
  String get alertLiningHeavierTitle;

  /// No description provided for @alertLiningHeavierBody.
  ///
  /// In fr, this message translates to:
  /// **'{lining} dépasse {main} : la doublure risque de déformer le produit.'**
  String alertLiningHeavierBody(String lining, String main);

  /// No description provided for @alertStretchTitle.
  ///
  /// In fr, this message translates to:
  /// **'Tissu extensible, doublure rigide'**
  String get alertStretchTitle;

  /// No description provided for @alertStretchBody.
  ///
  /// In fr, this message translates to:
  /// **'{main} contient de l\'élasthanne mais pas {lining} : prévoyez de l\'aisance ou une doublure stretch.'**
  String alertStretchBody(String main, String lining);

  /// No description provided for @alertInterfacingHeavierTitle.
  ///
  /// In fr, this message translates to:
  /// **'Entoilage trop lourd'**
  String get alertInterfacingHeavierTitle;

  /// No description provided for @alertInterfacingHeavierBody.
  ///
  /// In fr, this message translates to:
  /// **'{interfacing} est plus lourd que {main} : risque de rigidité et de transparence.'**
  String alertInterfacingHeavierBody(String interfacing, String main);

  /// No description provided for @alertFusingTitle.
  ///
  /// In fr, this message translates to:
  /// **'Thermocollage risqué'**
  String get alertFusingTitle;

  /// No description provided for @alertFusingBody.
  ///
  /// In fr, this message translates to:
  /// **'{main} supporte au plus {iron} : choisissez un entoilage à coudre ou basse température.'**
  String alertFusingBody(String main, String iron);

  /// No description provided for @alertConsumptionTitle.
  ///
  /// In fr, this message translates to:
  /// **'Consommation non saisie'**
  String get alertConsumptionTitle;

  /// No description provided for @alertConsumptionBody.
  ///
  /// In fr, this message translates to:
  /// **'{materials} : le besoin ne peut pas être calculé.'**
  String alertConsumptionBody(String materials);

  /// No description provided for @alertCareConflictTitle.
  ///
  /// In fr, this message translates to:
  /// **'Entretiens incompatibles'**
  String get alertCareConflictTitle;

  /// No description provided for @alertCareConflictBody.
  ///
  /// In fr, this message translates to:
  /// **'{details}. L\'étiquette du produit devra imposer l\'entretien le plus restrictif.'**
  String alertCareConflictBody(String details);

  /// No description provided for @alertWashTitle.
  ///
  /// In fr, this message translates to:
  /// **'Lavage limité à {temp} °C'**
  String alertWashTitle(int temp);

  /// No description provided for @alertIronTitle.
  ///
  /// In fr, this message translates to:
  /// **'Repassage limité : {iron}'**
  String alertIronTitle(String iron);

  /// No description provided for @alertTumbleTitle.
  ///
  /// In fr, this message translates to:
  /// **'Sèche-linge à éviter'**
  String get alertTumbleTitle;

  /// No description provided for @alertLimitBody.
  ///
  /// In fr, this message translates to:
  /// **'{details}. Le produit fini suit la matière la plus fragile.'**
  String alertLimitBody(String details);

  /// No description provided for @alertCertTitle.
  ///
  /// In fr, this message translates to:
  /// **'{cert} non tenue sur tout le produit'**
  String alertCertTitle(String cert);

  /// No description provided for @alertCertBody.
  ///
  /// In fr, this message translates to:
  /// **'{certified} est certifié {cert}, mais pas {missing} : le produit fini ne pourra pas revendiquer {cert}.'**
  String alertCertBody(String certified, String cert, String missing);

  /// No description provided for @alertRetiredTitle.
  ///
  /// In fr, this message translates to:
  /// **'Référence retirée par le fournisseur'**
  String get alertRetiredTitle;

  /// No description provided for @alertRetiredBody.
  ///
  /// In fr, this message translates to:
  /// **'{material} n\'est plus proposée : besoin {need}, stock atelier {atelier}.'**
  String alertRetiredBody(String material, String need, String atelier);

  /// No description provided for @alertAtelierShortTitle.
  ///
  /// In fr, this message translates to:
  /// **'Stock atelier insuffisant'**
  String get alertAtelierShortTitle;

  /// No description provided for @alertAtelierShortBody.
  ///
  /// In fr, this message translates to:
  /// **'{material} : besoin {need}, stock atelier {atelier}. Il manque {missing}.'**
  String alertAtelierShortBody(
    String material,
    String need,
    String atelier,
    String missing,
  );

  /// No description provided for @alertCoveredTitle.
  ///
  /// In fr, this message translates to:
  /// **'À commander chez le fournisseur'**
  String get alertCoveredTitle;

  /// No description provided for @alertCoveredBody.
  ///
  /// In fr, this message translates to:
  /// **'{material} : besoin {need}, stock atelier {atelier}. Le complément ({missing}) est disponible chez le fournisseur.'**
  String alertCoveredBody(
    String material,
    String need,
    String atelier,
    String missing,
  );

  /// No description provided for @alertCoveredBodyExact.
  ///
  /// In fr, this message translates to:
  /// **'{material} : besoin {need}, stock atelier {atelier}. Le complément ({missing}) est disponible chez le fournisseur ({supplier} en stock).'**
  String alertCoveredBodyExact(
    String material,
    String need,
    String atelier,
    String missing,
    String supplier,
  );

  /// No description provided for @alertSupplierShortTitle.
  ///
  /// In fr, this message translates to:
  /// **'Stock fournisseur insuffisant'**
  String get alertSupplierShortTitle;

  /// No description provided for @alertSupplierShortBody.
  ///
  /// In fr, this message translates to:
  /// **'{material} : il manque {missing} après le stock atelier ({atelier}), et le fournisseur n\'en a que {supplier}.'**
  String alertSupplierShortBody(
    String material,
    String missing,
    String atelier,
    String supplier,
  );

  /// No description provided for @alertSupplierLowTitle.
  ///
  /// In fr, this message translates to:
  /// **'Stock faible chez le fournisseur'**
  String get alertSupplierLowTitle;

  /// No description provided for @alertSupplierLowBody.
  ///
  /// In fr, this message translates to:
  /// **'{material} : il manque {missing} après le stock atelier ({atelier}), et le fournisseur est en stock faible.'**
  String alertSupplierLowBody(String material, String missing, String atelier);

  /// No description provided for @alertOnOrderTitle.
  ///
  /// In fr, this message translates to:
  /// **'Sur commande chez le fournisseur'**
  String get alertOnOrderTitle;

  /// No description provided for @alertOnOrderBody.
  ///
  /// In fr, this message translates to:
  /// **'{material} : il manque {missing} après le stock atelier ({atelier}). Délai de réassort : {weeks} semaines.'**
  String alertOnOrderBody(
    String material,
    String missing,
    String atelier,
    int weeks,
  );

  /// No description provided for @alertOutTitle.
  ///
  /// In fr, this message translates to:
  /// **'Rupture chez le fournisseur'**
  String get alertOutTitle;

  /// No description provided for @alertOutBody.
  ///
  /// In fr, this message translates to:
  /// **'{material} : il manque {missing} après le stock atelier ({atelier}), et le fournisseur est en rupture.'**
  String alertOutBody(String material, String missing, String atelier);

  /// No description provided for @alertHiddenTitle.
  ///
  /// In fr, this message translates to:
  /// **'Disponibilité non communiquée'**
  String get alertHiddenTitle;

  /// No description provided for @alertHiddenBody.
  ///
  /// In fr, this message translates to:
  /// **'{material} : il manque {missing} après le stock atelier ({atelier}). Le fournisseur ne publie pas son stock : contactez-le.'**
  String alertHiddenBody(String material, String missing, String atelier);

  /// No description provided for @notifStockLow.
  ///
  /// In fr, this message translates to:
  /// **'{name} : stock faible chez le fournisseur ({code})'**
  String notifStockLow(String name, String code);

  /// No description provided for @notifStockOut.
  ///
  /// In fr, this message translates to:
  /// **'{name} : rupture chez le fournisseur ({code})'**
  String notifStockOut(String name, String code);

  /// No description provided for @notifReferenceUpdated.
  ///
  /// In fr, this message translates to:
  /// **'{name} : fiche modifiée par le fournisseur ({code})'**
  String notifReferenceUpdated(String name, String code);

  /// No description provided for @notifReferenceRetired.
  ///
  /// In fr, this message translates to:
  /// **'{name} : référence retirée par le fournisseur ({code})'**
  String notifReferenceRetired(String name, String code);

  /// No description provided for @notifUsedIn.
  ///
  /// In fr, this message translates to:
  /// **'Utilisée dans : {models}'**
  String notifUsedIn(String models);

  /// No description provided for @exportPdf.
  ///
  /// In fr, this message translates to:
  /// **'Exporter en PDF'**
  String get exportPdf;

  /// No description provided for @exportDossier.
  ///
  /// In fr, this message translates to:
  /// **'Exporter le dossier PDF'**
  String get exportDossier;

  /// No description provided for @pdfLanguage.
  ///
  /// In fr, this message translates to:
  /// **'Langue du PDF'**
  String get pdfLanguage;

  /// No description provided for @pdfMaterialSheet.
  ///
  /// In fr, this message translates to:
  /// **'Fiche matière'**
  String get pdfMaterialSheet;

  /// No description provided for @pdfModelDossier.
  ///
  /// In fr, this message translates to:
  /// **'Dossier matières'**
  String get pdfModelDossier;

  /// No description provided for @pdfCollectionDossier.
  ///
  /// In fr, this message translates to:
  /// **'Dossier matières de la collection'**
  String get pdfCollectionDossier;

  /// No description provided for @pdfEditedOn.
  ///
  /// In fr, this message translates to:
  /// **'Édité le {date}'**
  String pdfEditedOn(String date);

  /// No description provided for @pdfNotSet.
  ///
  /// In fr, this message translates to:
  /// **'Non renseigné'**
  String get pdfNotSet;

  /// No description provided for @pdfCompositionNote.
  ///
  /// In fr, this message translates to:
  /// **'Composition exprimée selon le règlement (UE) n° 1007/2011. Caractéristiques indicatives, à valider sur échantillon.'**
  String get pdfCompositionNote;

  /// No description provided for @pdfSupplierData.
  ///
  /// In fr, this message translates to:
  /// **'Données fournisseur'**
  String get pdfSupplierData;

  /// No description provided for @pdfPage.
  ///
  /// In fr, this message translates to:
  /// **'Page {page} / {total}'**
  String pdfPage(int page, int total);

  /// No description provided for @pdfContents.
  ///
  /// In fr, this message translates to:
  /// **'Sommaire'**
  String get pdfContents;

  /// No description provided for @pdfMaterial.
  ///
  /// In fr, this message translates to:
  /// **'Matière'**
  String get pdfMaterial;

  /// No description provided for @pdfConsumption.
  ///
  /// In fr, this message translates to:
  /// **'Conso./pièce'**
  String get pdfConsumption;

  /// No description provided for @pdfNeed.
  ///
  /// In fr, this message translates to:
  /// **'Besoin'**
  String get pdfNeed;

  /// No description provided for @pdfGenerationError.
  ///
  /// In fr, this message translates to:
  /// **'Le PDF n\'a pas pu être généré. Réessayez.'**
  String get pdfGenerationError;

  /// No description provided for @shareAction.
  ///
  /// In fr, this message translates to:
  /// **'Partager'**
  String get shareAction;

  /// No description provided for @shareTitle.
  ///
  /// In fr, this message translates to:
  /// **'Partager en lecture seule'**
  String get shareTitle;

  /// No description provided for @shareIntro.
  ///
  /// In fr, this message translates to:
  /// **'Le destinataire ouvre le lien sans compte et voit des fiches toujours à jour, sans prix, notes ni stock de l\'atelier.'**
  String get shareIntro;

  /// No description provided for @shareLanguage.
  ///
  /// In fr, this message translates to:
  /// **'Langue de la page'**
  String get shareLanguage;

  /// No description provided for @shareValidity.
  ///
  /// In fr, this message translates to:
  /// **'Validité (jours)'**
  String get shareValidity;

  /// No description provided for @shareCreate.
  ///
  /// In fr, this message translates to:
  /// **'Créer le lien'**
  String get shareCreate;

  /// No description provided for @shareCopy.
  ///
  /// In fr, this message translates to:
  /// **'Copier le lien'**
  String get shareCopy;

  /// No description provided for @shareCopied.
  ///
  /// In fr, this message translates to:
  /// **'Lien copié.'**
  String get shareCopied;

  /// No description provided for @shareExpires.
  ///
  /// In fr, this message translates to:
  /// **'Expire le {date}'**
  String shareExpires(String date);

  /// No description provided for @shareRevoke.
  ///
  /// In fr, this message translates to:
  /// **'Révoquer'**
  String get shareRevoke;

  /// No description provided for @shareRevokeConfirm.
  ///
  /// In fr, this message translates to:
  /// **'Révoquer ce lien ? Il cessera aussitôt de fonctionner.'**
  String get shareRevokeConfirm;

  /// No description provided for @shareRevoked.
  ///
  /// In fr, this message translates to:
  /// **'Lien révoqué.'**
  String get shareRevoked;

  /// No description provided for @shareExtend.
  ///
  /// In fr, this message translates to:
  /// **'Modifier l\'expiration'**
  String get shareExtend;

  /// No description provided for @shareActiveLinks.
  ///
  /// In fr, this message translates to:
  /// **'Liens actifs'**
  String get shareActiveLinks;

  /// No description provided for @shareNone.
  ///
  /// In fr, this message translates to:
  /// **'Aucun lien actif.'**
  String get shareNone;

  /// No description provided for @shareLinksTitle.
  ///
  /// In fr, this message translates to:
  /// **'Liens partagés'**
  String get shareLinksTitle;

  /// No description provided for @shareScopeMaterial.
  ///
  /// In fr, this message translates to:
  /// **'Fiche matière'**
  String get shareScopeMaterial;

  /// No description provided for @shareScopeModel.
  ///
  /// In fr, this message translates to:
  /// **'Modèle'**
  String get shareScopeModel;

  /// No description provided for @shareScopeCollection.
  ///
  /// In fr, this message translates to:
  /// **'Collection'**
  String get shareScopeCollection;

  /// No description provided for @shareUnknownTarget.
  ///
  /// In fr, this message translates to:
  /// **'Élément supprimé'**
  String get shareUnknownTarget;

  /// No description provided for @sharedFrom.
  ///
  /// In fr, this message translates to:
  /// **'Partagé par {org}'**
  String sharedFrom(String org);

  /// No description provided for @sharedReadOnly.
  ///
  /// In fr, this message translates to:
  /// **'Lecture seule · données à jour · lien valable jusqu\'au {date}'**
  String sharedReadOnly(String date);

  /// No description provided for @sharedExpiredTitle.
  ///
  /// In fr, this message translates to:
  /// **'Ce lien a expiré'**
  String get sharedExpiredTitle;

  /// No description provided for @sharedExpiredBody.
  ///
  /// In fr, this message translates to:
  /// **'Il n\'est plus valable depuis le {date}. Demandez un nouveau lien à l\'atelier qui vous l\'a envoyé.'**
  String sharedExpiredBody(String date);

  /// No description provided for @sharedRevokedTitle.
  ///
  /// In fr, this message translates to:
  /// **'Ce lien a été révoqué'**
  String get sharedRevokedTitle;

  /// No description provided for @sharedRevokedBody.
  ///
  /// In fr, this message translates to:
  /// **'L\'atelier l\'a désactivé. Demandez-lui un nouveau lien si besoin.'**
  String get sharedRevokedBody;

  /// No description provided for @sharedNotFoundTitle.
  ///
  /// In fr, this message translates to:
  /// **'Lien introuvable'**
  String get sharedNotFoundTitle;

  /// No description provided for @sharedNotFoundBody.
  ///
  /// In fr, this message translates to:
  /// **'Vérifiez l\'adresse ou demandez un nouveau lien à l\'atelier.'**
  String get sharedNotFoundBody;

  /// No description provided for @sharedError.
  ///
  /// In fr, this message translates to:
  /// **'Impossible de charger la page. Vérifiez votre connexion puis réessayez.'**
  String get sharedError;
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
