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

  @override
  String get libraryNew => 'Nouvelle matière';

  @override
  String get viewGallery => 'Galerie';

  @override
  String get viewTable => 'Tableau';

  @override
  String get libraryEmptyTitle => 'Votre TissuTech est vide';

  @override
  String get libraryEmptyBody =>
      'Ajoutez vos premières matières : scannez l\'étiquette d\'un échantillon, importez votre fichier Excel ou saisissez-les à la main.';

  @override
  String get libraryEmptyViewer =>
      'Aucune matière pour l\'instant. Les éditeurs de votre atelier peuvent en ajouter.';

  @override
  String get actionScanSample => 'Scanner un échantillon';

  @override
  String get actionImportExcel => 'Importer un fichier Excel';

  @override
  String get actionCreateManual => 'Saisir à la main';

  @override
  String materialCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count matières',
      one: '1 matière',
      zero: 'Aucune matière',
    );
    return '$_temp0';
  }

  @override
  String get colMaterial => 'Matière';

  @override
  String get colReference => 'Référence';

  @override
  String get colComposition => 'Composition';

  @override
  String get colWeight => 'g/m²';

  @override
  String get colWidth => 'Laize';

  @override
  String get colStock => 'Stock atelier';

  @override
  String get fieldName => 'Nom de la matière';

  @override
  String get fieldSupplier => 'Fournisseur';

  @override
  String get fieldSupplierCode => 'Code article';

  @override
  String get fieldColorName => 'Coloris';

  @override
  String get fieldColorHex => 'Couleur (#RRGGBB)';

  @override
  String get photoAdd => 'Ajouter une photo';

  @override
  String get photoChange => 'Changer la photo';

  @override
  String get photoRemove => 'Retirer la photo';

  @override
  String get sectionIdentity => 'Identité';

  @override
  String get sectionColor => 'Couleur et photo';

  @override
  String get sectionComposition => 'Composition';

  @override
  String get sectionTechnical => 'Caractéristiques';

  @override
  String get sectionCare => 'Entretien';

  @override
  String get sectionUses => 'Usages et certifications';

  @override
  String get sectionStock => 'Stock atelier';

  @override
  String get sectionNotes => 'Notes';

  @override
  String get addFiber => 'Ajouter une fibre';

  @override
  String get removeFiber => 'Retirer cette fibre';

  @override
  String get fiberLabel => 'Fibre';

  @override
  String compositionTotal(String total) {
    return 'Total : $total %';
  }

  @override
  String get compositionMustBe100 =>
      'Le total doit faire 100 %, sans fibre en double';

  @override
  String get fieldWeight => 'Grammage (g/m²)';

  @override
  String get fieldWidth => 'Laize (cm)';

  @override
  String get fieldWeave => 'Armure';

  @override
  String get noneOption => 'Non renseigné';

  @override
  String get fieldCertifications => 'Certifications';

  @override
  String get fieldUses => 'Usages';

  @override
  String get fieldStock => 'Métrage en stock (m)';

  @override
  String get errorRequired => 'Champ obligatoire';

  @override
  String errorNumberRange(int min, int max) {
    return 'Nombre entre $min et $max';
  }

  @override
  String get errorHex => 'Format #RRGGBB attendu (ex. #2F4A6B)';

  @override
  String get save => 'Enregistrer';

  @override
  String get materialSaved => 'Matière enregistrée.';

  @override
  String get edit => 'Modifier';

  @override
  String get delete => 'Supprimer';

  @override
  String deleteMaterialTitle(String name) {
    return 'Supprimer « $name » ?';
  }

  @override
  String get deleteMaterialBody =>
      'La matière et sa photo seront définitivement supprimées.';

  @override
  String get materialDeleted => 'Matière supprimée.';

  @override
  String get editStock => 'Modifier le stock';

  @override
  String get stockUpdated => 'Stock mis à jour.';

  @override
  String stockMeters(String value) {
    return '$value m';
  }

  @override
  String get materialNotFound =>
      'Cette matière n\'existe plus ou n\'est pas accessible.';

  @override
  String get newMaterialTitle => 'Nouvelle matière';

  @override
  String get editMaterialTitle => 'Modifier la matière';

  @override
  String get detailWeight => 'Grammage';

  @override
  String get detailWidth => 'Laize';

  @override
  String get photoUploadFailed =>
      'La photo n\'a pas pu être envoyée. Réessayez.';

  @override
  String get viewerReadOnly => 'Lecture seule';

  @override
  String get errorEditorsOnly =>
      'Action réservée aux éditeurs et aux administrateurs de l\'atelier.';

  @override
  String get searchHint =>
      'Rechercher : nom, code, fournisseur, couleur, fibre…';

  @override
  String get clearSearch => 'Effacer la recherche';

  @override
  String get filtersButton => 'Filtres';

  @override
  String get clearFilters => 'Effacer les filtres';

  @override
  String get showResults => 'Afficher les résultats';

  @override
  String get noResultsTitle => 'Aucun résultat';

  @override
  String get noResultsBody =>
      'Aucune matière ne correspond à votre recherche ou à vos filtres.';

  @override
  String resultCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count résultats',
      one: '1 résultat',
      zero: 'Aucun résultat',
    );
    return '$_temp0';
  }

  @override
  String get filterFiber => 'Fibre';

  @override
  String get filterFiberAny => 'Toutes les fibres';

  @override
  String filterFiberMin(int pct) {
    return 'Au moins $pct %';
  }

  @override
  String get filterWeight => 'Grammage';

  @override
  String get filterColor => 'Couleur';

  @override
  String get filterInStock => 'En stock à l\'atelier';

  @override
  String removeFilter(String label) {
    return 'Retirer le filtre $label';
  }

  @override
  String chipFiberMin(String fiber, int pct) {
    return '$fiber ≥ $pct %';
  }

  @override
  String chipWeightRange(int min, int max) {
    return '$min–$max g/m²';
  }

  @override
  String chipWeightMin(int min) {
    return '≥ $min g/m²';
  }

  @override
  String chipWeightMax(int max) {
    return '≤ $max g/m²';
  }

  @override
  String get navCatalog => 'Catalogue';

  @override
  String get catalogEmptyTitle => 'Votre catalogue est vide';

  @override
  String get catalogEmptyBody =>
      'Importez votre catalogue depuis un fichier Excel ou CSV exporté de votre logiciel de gestion.';

  @override
  String get catalogImport => 'Importer un fichier';

  @override
  String get catalogSettings => 'Disponibilité';

  @override
  String referenceCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count références',
      one: '1 référence',
      zero: 'Aucune référence',
    );
    return '$_temp0';
  }

  @override
  String get showRetired => 'Afficher les références retirées';

  @override
  String get retiredBadge => 'Retirée';

  @override
  String get colStatus => 'Disponibilité';

  @override
  String get colLeadTime => 'Délai';

  @override
  String get statusAvailable => 'Disponible';

  @override
  String get statusLow => 'Stock faible';

  @override
  String get statusOnOrder => 'Sur commande';

  @override
  String statusOnOrderWeeks(int weeks) {
    return 'Sur commande · $weeks sem.';
  }

  @override
  String get statusOutOfStock => 'Rupture';

  @override
  String get statusHidden => 'Masquée';

  @override
  String get modeExact => 'Quantité exacte';

  @override
  String get modeTiers => 'Paliers';

  @override
  String get modeHidden => 'Masquée';

  @override
  String get modeExactHelp => 'Les ateliers voient votre métrage exact.';

  @override
  String get modeTiersHelp =>
      'Les ateliers voient seulement : disponible, stock faible, sur commande ou rupture.';

  @override
  String get modeHiddenHelp => 'Les ateliers ne voient pas la disponibilité.';

  @override
  String modeDefault(String mode) {
    return 'Réglage général ($mode)';
  }

  @override
  String get thresholdLabel => 'Seuil de stock faible (m)';

  @override
  String get thresholdHelp =>
      'En dessous de ce métrage, la référence apparaît en « stock faible ».';

  @override
  String get leadTimeLabel => 'Délai de réassort (semaines)';

  @override
  String get leadTimeHelp => 'Affiché quand la référence est sur commande.';

  @override
  String get availabilitySettingsTitle => 'Affichage de la disponibilité';

  @override
  String get availabilitySettingsIntro =>
      'Choisissez ce que les ateliers voient de votre stock. Vous pouvez ajuster chaque référence depuis sa fiche.';

  @override
  String get settingsSaved => 'Réglages enregistrés.';

  @override
  String get referenceRetire => 'Retirer du catalogue';

  @override
  String get referenceRestore => 'Remettre au catalogue';

  @override
  String get referenceRetired => 'Référence retirée du catalogue publié.';

  @override
  String get referenceRestored => 'Référence remise au catalogue.';

  @override
  String retireConfirmTitle(String code) {
    return 'Retirer « $code » ?';
  }

  @override
  String get retireConfirmBody =>
      'Elle ne sera plus visible par les ateliers. Ceux qui l\'utilisent garderont sa dernière fiche. Vous pourrez la remettre au catalogue.';

  @override
  String get referenceAvailabilityTitle => 'Disponibilité de cette référence';

  @override
  String get stockLabel => 'Stock';

  @override
  String whatAteliersSee(String value) {
    return 'Ce que voient les ateliers : $value';
  }

  @override
  String get importTitle => 'Importer le catalogue';

  @override
  String get importPickFile => 'Choisir un fichier Excel ou CSV';

  @override
  String get importPickHelp =>
      'Fichier .xlsx ou .csv, une ligne par référence et une ligne d\'intitulés. 5 000 lignes au maximum. Une référence déjà connue est mise à jour par son code.';

  @override
  String get importUnreadable =>
      'Ce fichier n\'a pas pu être lu. Enregistrez-le au format .xlsx ou .csv puis réessayez.';

  @override
  String importTooMany(int count) {
    return 'Ce fichier contient $count lignes : 5 000 au maximum par import.';
  }

  @override
  String get importMappingTitle => 'Associez vos colonnes';

  @override
  String get importMappingIntro =>
      'Les colonnes reconnues sont déjà associées. Le code article et la désignation sont obligatoires.';

  @override
  String get importColumnNone => '— Ignorer —';

  @override
  String get importFieldName => 'Désignation';

  @override
  String get importFieldStock => 'Stock (m)';

  @override
  String importSummary(int valid, int invalid) {
    return '$valid lignes prêtes · $invalid en erreur';
  }

  @override
  String get importErrorsTitle => 'Lignes en erreur (non importées)';

  @override
  String importLine(int line) {
    return 'Ligne $line';
  }

  @override
  String importRun(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Importer $count références',
      one: 'Importer 1 référence',
    );
    return '$_temp0';
  }

  @override
  String importRunning(int done, int total) {
    return 'Import en cours… $done/$total';
  }

  @override
  String get importDoneTitle => 'Import terminé';

  @override
  String importDone(int inserted, int updated) {
    return '$inserted créées · $updated mises à jour';
  }

  @override
  String importServerRejected(String message) {
    return 'Refusée par le serveur : $message';
  }

  @override
  String get importAgain => 'Importer un autre fichier';

  @override
  String get backToCatalog => 'Retour au catalogue';

  @override
  String importFileName(String name) {
    return 'Fichier : $name';
  }

  @override
  String get issueMissingCode => 'Code article manquant';

  @override
  String get issueMissingName => 'Désignation manquante';

  @override
  String issueComposition(String value) {
    return 'Composition illisible ou différente de 100 % : « $value »';
  }

  @override
  String issueNumber(String field, String value) {
    return '$field : valeur invalide « $value »';
  }

  @override
  String issueColor(String value) {
    return 'Couleur invalide « $value » (format #RRGGBB)';
  }

  @override
  String issueDuplicate(String value) {
    return 'Code « $value » présent plusieurs fois dans le fichier';
  }

  @override
  String get adminOrgKind => 'Type d\'organisation';

  @override
  String get adminNewOrg => 'Nouvelle organisation';

  @override
  String get adminOrgNameGeneric => 'Nom de l\'organisation';

  @override
  String get scanTitle => 'Scanner un échantillon';

  @override
  String get scanIntro =>
      'Photographiez l\'étiquette de l\'échantillon, bien à plat et nette. Filyxa lit la composition, le grammage, la laize, l\'entretien et le code article ; vous vérifiez avant d\'enregistrer.';

  @override
  String get scanTakePhoto => 'Prendre une photo';

  @override
  String get scanImportPhoto => 'Importer une photo';

  @override
  String get scanReading => 'Lecture de l\'étiquette…';

  @override
  String scanUsage(int scans, int quota) {
    return '$scans / $quota scans ce mois-ci';
  }

  @override
  String scanQuotaWarning(int percent) {
    return '$percent % du quota mensuel de scans est utilisé.';
  }

  @override
  String get scanQuotaExhausted =>
      'Quota mensuel de scans atteint. La saisie à la main reste possible.';

  @override
  String get scanFailureNotLabel =>
      'Aucune étiquette textile lisible sur cette photo. Reprenez-la de plus près, bien à plat, sans reflet.';

  @override
  String get scanFailureRefused =>
      'L\'analyse de cette image a été refusée. Essayez une autre photo.';

  @override
  String get scanFailureAi =>
      'Le service de lecture est momentanément indisponible. Réessayez dans un instant.';

  @override
  String get scanFailureImage =>
      'Cette image n\'est pas prise en charge (JPEG, PNG ou WebP, 5 Mo maximum).';

  @override
  String get prefillBanner =>
      'Fiche pré-remplie par le scan. Vérifiez les champs signalés avant d\'enregistrer.';

  @override
  String get fieldUncertain => 'Lu avec peu de certitude : à vérifier';

  @override
  String get sectionUncertain => 'Lecture incertaine : vérifiez cette section.';

  @override
  String duplicateFound(String name) {
    return 'Une matière avec ce code article existe déjà : « $name ».';
  }

  @override
  String get duplicateOpen => 'Ouvrir la fiche existante';

  @override
  String get matchTitle => 'C\'est bien cette référence ?';

  @override
  String matchIntro(String supplier) {
    return 'Trouvée dans le catalogue de $supplier. Confirmez pour relier votre fiche à ses données et à sa disponibilité.';
  }

  @override
  String get matchConfirm => 'Oui, lier cette référence';

  @override
  String get matchOthers => 'Autres références proches';

  @override
  String get matchNone => 'Aucune de ces références';

  @override
  String get supplierData => 'Données fournisseur';

  @override
  String get supplierDataHelp =>
      'Tenues à jour par le fournisseur, non modifiables ici.';

  @override
  String get referenceRetiredBanner =>
      'Référence retirée par le fournisseur. Les dernières valeurs connues sont conservées.';

  @override
  String get linkToSupplier => 'Lier à une référence fournisseur';

  @override
  String get linkSearchHint => 'Code article, désignation ou fournisseur';

  @override
  String get linkSearchEmpty => 'Aucune référence publiée ne correspond.';

  @override
  String get linkConfirm => 'Lier';

  @override
  String get unlink => 'Délier la référence';

  @override
  String get unlinkConfirmBody =>
      'La fiche garde ses valeurs actuelles et redevient modifiable. Elle ne suivra plus les mises à jour du fournisseur.';

  @override
  String get linkedDone => 'Fiche liée au fournisseur.';

  @override
  String get unlinkedDone => 'Fiche déliée du fournisseur.';

  @override
  String get privateLayer => 'Informations de l\'atelier';

  @override
  String get privateLayerHelp => 'Visibles par votre atelier seulement.';

  @override
  String get fieldPrice => 'Prix négocié (€/m)';

  @override
  String get fieldTags => 'Étiquettes';

  @override
  String get fieldTagsHint => 'Séparées par des virgules (ex. AH27, à valider)';

  @override
  String priceValue(String value) {
    return '$value €/m';
  }

  @override
  String get atelierImportTitle => 'Importer la base de l\'atelier';

  @override
  String get atelierImportHelp =>
      'Fichier .xlsx ou .csv, une ligne par matière et une ligne d\'intitulés. 5 000 lignes au maximum. Une matière déjà présente (même fournisseur et même code, ou même nom et même coloris) est mise à jour, jamais dupliquée.';

  @override
  String get atelierImportMappingIntro =>
      'Les colonnes reconnues sont déjà associées. Seul le nom de la matière est obligatoire.';

  @override
  String atelierImportRun(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Importer $count matières',
      one: 'Importer 1 matière',
    );
    return '$_temp0';
  }

  @override
  String atelierImportDone(int imported, int linked, int pending, int errors) {
    return '$imported importées · $linked reliées à un fournisseur · $pending à confirmer · $errors en erreur';
  }

  @override
  String atelierImportDetail(int inserted, int updated) {
    return 'dont $inserted nouvelles et $updated mises à jour';
  }

  @override
  String get backToLibrary => 'Retour à TissuTech';

  @override
  String reviewLinksAction(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Confirmer $count correspondances',
      one: 'Confirmer 1 correspondance',
    );
    return '$_temp0';
  }

  @override
  String pendingLinksBanner(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count matières importées ressemblent à des références fournisseur.',
      one: '1 matière importée ressemble à une référence fournisseur.',
    );
    return '$_temp0';
  }

  @override
  String get reviewTitle => 'Correspondances à confirmer';

  @override
  String reviewProgress(int index, int total) {
    return '$index sur $total';
  }

  @override
  String get reviewIntro =>
      'Votre fiche ressemble à une référence publiée. Confirmez pour la relier à ses données et à sa disponibilité.';

  @override
  String get reviewSkip => 'Plus tard';

  @override
  String get reviewDone => 'Toutes les correspondances ont été traitées.';

  @override
  String get reviewNoCandidate =>
      'Aucune référence publiée ne correspond plus à cette matière.';

  @override
  String get reviewOpen => 'Traiter';

  @override
  String get reportAction => 'Signaler une erreur';

  @override
  String get reportTitle => 'Signaler une erreur au fournisseur';

  @override
  String get reportIntro =>
      'Le fournisseur corrigera sa fiche pour tous les ateliers. Il ne voit pas le nom de votre atelier, sauf si vous choisissez de le partager.';

  @override
  String get reportField => 'Champ concerné';

  @override
  String get reportObserved => 'Valeur constatée';

  @override
  String get reportObservedHint => 'Ex. 300 g/m² mesurés sur l\'échantillon';

  @override
  String get reportComment => 'Commentaire (facultatif)';

  @override
  String get reportShareIdentity =>
      'Partager le nom de mon atelier avec le fournisseur';

  @override
  String get reportSend => 'Envoyer';

  @override
  String get reportSent => 'Signalement envoyé au fournisseur.';

  @override
  String get reportFieldAvailability => 'Disponibilité';

  @override
  String get reportFieldOther => 'Autre';

  @override
  String get reportsSection => 'Signalements';

  @override
  String get reportStatusOpen => 'Ouvert';

  @override
  String get reportStatusFixed => 'Corrigé';

  @override
  String get reportStatusRejected => 'Rejeté';

  @override
  String reportObservedLine(String value) {
    return 'Constaté : $value';
  }

  @override
  String reportReasonLine(String reason) {
    return 'Motif : $reason';
  }

  @override
  String reportResponseLine(String response) {
    return 'Réponse : $response';
  }

  @override
  String get supplierReportsTitle => 'Signalements des ateliers';

  @override
  String supplierReportsButton(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count signalements ouverts',
      one: '1 signalement ouvert',
      zero: 'Signalements',
    );
    return '$_temp0';
  }

  @override
  String get supplierReportsEmpty => 'Aucun signalement pour le moment.';

  @override
  String get reportAnonymous => 'Atelier anonyme';

  @override
  String get reportMarkFixed => 'Marquer corrigé';

  @override
  String get reportReject => 'Rejeter';

  @override
  String get reportRejectTitle => 'Rejeter le signalement';

  @override
  String get reportRejectReason => 'Motif du rejet';

  @override
  String get reportFixTitle => 'Marquer comme corrigé';

  @override
  String get reportFixHelp =>
      'Pensez à corriger la référence dans votre catalogue : les ateliers liés la verront aussitôt.';

  @override
  String get reportFixMessage => 'Message à l\'atelier (facultatif)';

  @override
  String get reportEditReference => 'Ouvrir la référence';

  @override
  String get reportFilterOpen => 'Ouverts';

  @override
  String get reportFilterAll => 'Tous';

  @override
  String get notificationsTitle => 'Notifications';

  @override
  String get notificationsEmpty => 'Aucune notification.';

  @override
  String notificationsTooltip(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Notifications ($count non lues)',
      one: 'Notifications (1 non lue)',
      zero: 'Notifications',
    );
    return '$_temp0';
  }

  @override
  String notifReportNew(String code, String field) {
    return 'Nouveau signalement sur $code · $field';
  }

  @override
  String notifReportFixed(String name, String field) {
    return '$name : le fournisseur a corrigé « $field »';
  }

  @override
  String notifReportRejected(String name, String field) {
    return '$name : signalement sur « $field » rejeté';
  }

  @override
  String get studioNewCollection => 'Nouvelle collection';

  @override
  String get studioCollectionName => 'Nom de la collection';

  @override
  String get studioCollectionHint => 'Ex. AH27';

  @override
  String get studioEmptyTitle => 'Aucune collection pour le moment';

  @override
  String get studioEmptyEditor =>
      'Créez une collection pour regrouper les modèles d\'une saison, par exemple « AH27 ».';

  @override
  String get studioEmptyViewer =>
      'Les éditeurs de votre atelier n\'ont pas encore créé de collection.';

  @override
  String studioModelCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count modèles',
      one: '1 modèle',
      zero: 'Aucun modèle',
    );
    return '$_temp0';
  }

  @override
  String get collectionEmptyTitle => 'Cette collection est vide';

  @override
  String get collectionEmptyEditor =>
      'Ajoutez un premier modèle : vêtement, chaussure, maroquinerie ou accessoire.';

  @override
  String get collectionEmptyViewer =>
      'Aucun modèle dans cette collection pour le moment.';

  @override
  String get studioNewModel => 'Nouveau modèle';

  @override
  String get modelName => 'Nom du modèle';

  @override
  String get modelReference => 'Référence (facultatif)';

  @override
  String get modelType => 'Type de produit';

  @override
  String get productGarment => 'Vêtement';

  @override
  String get productFootwear => 'Chaussure';

  @override
  String get productLeatherGoods => 'Maroquinerie';

  @override
  String get productAccessory => 'Accessoire';

  @override
  String colorwayCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count coloris',
      one: '1 coloris',
    );
    return '$_temp0';
  }

  @override
  String bomLineCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count matières',
      one: '1 matière',
      zero: 'aucune matière',
    );
    return '$_temp0';
  }

  @override
  String get rename => 'Renommer';

  @override
  String get create => 'Créer';

  @override
  String get add => 'Ajouter';

  @override
  String deleteCollectionTitle(String name) {
    return 'Supprimer la collection « $name » ?';
  }

  @override
  String get deleteCollectionBody =>
      'Ses modèles, coloris et quantités seront définitivement supprimés. Les matières de TissuTech sont conservées.';

  @override
  String deleteModelTitle(String name) {
    return 'Supprimer le modèle « $name » ?';
  }

  @override
  String get deleteModelBody =>
      'Ses coloris et sa nomenclature seront définitivement supprimés. Les matières de TissuTech sont conservées.';

  @override
  String get wasteLabel => 'Marge de perte (%)';

  @override
  String get quantityLabel => 'Quantité prévue (pièces)';

  @override
  String get addColorway => 'Ajouter un coloris';

  @override
  String get declineColorways => 'Décliner en coloris';

  @override
  String get colorwayCurrent => 'Coloris actuel';

  @override
  String get colorwayNew => 'Nouveau coloris';

  @override
  String get colorwayNameHint => 'Ex. Noir';

  @override
  String colorwayDefault(int index) {
    return 'Coloris $index';
  }

  @override
  String colorwayCopyHelp(String name) {
    return 'Le nouveau coloris reprend les matières de « $name » : vous n\'aurez qu\'à changer celles qui diffèrent.';
  }

  @override
  String get deleteColorway => 'Supprimer ce coloris';

  @override
  String get addMaterial => 'Ajouter une matière';

  @override
  String get modelEmptyTitle => 'Aucune matière dans ce modèle';

  @override
  String get modelEmptyEditor =>
      'Ajoutez les matières du modèle et leur consommation par pièce pour calculer le besoin.';

  @override
  String get modelEmptyViewer =>
      'Aucune matière n\'a encore été associée à ce modèle.';

  @override
  String get bomRoleLabel => 'Rôle';

  @override
  String get roleOther => 'Autre rôle…';

  @override
  String get roleCustom => 'Nom du rôle';

  @override
  String get role_main => 'Tissu principal';

  @override
  String get role_lining => 'Doublure';

  @override
  String get role_interfacing => 'Entoilage';

  @override
  String get role_contrast => 'Tissu contrasté';

  @override
  String get role_pocketing => 'Fond de poche';

  @override
  String get role_rib => 'Bord-côte';

  @override
  String get role_upper => 'Tige';

  @override
  String get role_sock_lining => 'Première de propreté';

  @override
  String get role_insole => 'Première de montage';

  @override
  String get role_outsole => 'Semelle';

  @override
  String get role_reinforcement => 'Renfort';

  @override
  String get role_exterior => 'Extérieur';

  @override
  String get role_gusset => 'Soufflet';

  @override
  String get role_strap => 'Anse ou bandoulière';

  @override
  String get role_trim => 'Garniture';

  @override
  String get consumptionLabel => 'Consommation (m/pièce)';

  @override
  String requirementLine(String value) {
    return 'Besoin : $value m';
  }

  @override
  String get requirementTitle => 'Besoin total par matière';

  @override
  String requirementFormula(String waste) {
    return 'Consommation × quantité × (1 + marge de $waste %)';
  }

  @override
  String get pickMaterial => 'Choisir une matière';

  @override
  String get pickMaterialSearch => 'Rechercher dans TissuTech';

  @override
  String get pickMaterialEmpty => 'Aucune matière ne correspond.';

  @override
  String get pickMaterialLibraryEmpty =>
      'Ajoutez d\'abord des matières dans TissuTech.';

  @override
  String get removeLine => 'Retirer cette matière';

  @override
  String get materialMissing => 'Matière supprimée de TissuTech';

  @override
  String get alertsTitle => 'Alertes';

  @override
  String get alertsNone =>
      'Aucune alerte : les matières de ce modèle sont compatibles et le stock est suffisant.';

  @override
  String alertsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count alertes',
      one: '1 alerte',
    );
    return '$_temp0';
  }

  @override
  String get alertFamilyCare => 'Entretien';

  @override
  String get alertFamilyTechnical => 'Technique';

  @override
  String get alertFamilyCertification => 'Certifications';

  @override
  String get alertFamilyStock => 'Stock';

  @override
  String alertQuoted(String name) {
    return '« $name »';
  }

  @override
  String get alertNoIron => 'aucun repassage';

  @override
  String get alertNoMainTitle => 'Aucun tissu principal';

  @override
  String get alertNoMainBody =>
      'Désignez le tissu principal pour activer toutes les vérifications.';

  @override
  String get alertLiningHeavierTitle =>
      'Doublure plus lourde que le tissu principal';

  @override
  String alertLiningHeavierBody(String lining, String main) {
    return '$lining dépasse $main : la doublure risque de déformer le produit.';
  }

  @override
  String get alertStretchTitle => 'Tissu extensible, doublure rigide';

  @override
  String alertStretchBody(String main, String lining) {
    return '$main contient de l\'élasthanne mais pas $lining : prévoyez de l\'aisance ou une doublure stretch.';
  }

  @override
  String get alertInterfacingHeavierTitle => 'Entoilage trop lourd';

  @override
  String alertInterfacingHeavierBody(String interfacing, String main) {
    return '$interfacing est plus lourd que $main : risque de rigidité et de transparence.';
  }

  @override
  String get alertFusingTitle => 'Thermocollage risqué';

  @override
  String alertFusingBody(String main, String iron) {
    return '$main supporte au plus $iron : choisissez un entoilage à coudre ou basse température.';
  }

  @override
  String get alertConsumptionTitle => 'Consommation non saisie';

  @override
  String alertConsumptionBody(String materials) {
    return '$materials : le besoin ne peut pas être calculé.';
  }

  @override
  String get alertCareConflictTitle => 'Entretiens incompatibles';

  @override
  String alertCareConflictBody(String details) {
    return '$details. L\'étiquette du produit devra imposer l\'entretien le plus restrictif.';
  }

  @override
  String alertWashTitle(int temp) {
    return 'Lavage limité à $temp °C';
  }

  @override
  String alertIronTitle(String iron) {
    return 'Repassage limité : $iron';
  }

  @override
  String get alertTumbleTitle => 'Sèche-linge à éviter';

  @override
  String alertLimitBody(String details) {
    return '$details. Le produit fini suit la matière la plus fragile.';
  }

  @override
  String alertCertTitle(String cert) {
    return '$cert non tenue sur tout le produit';
  }

  @override
  String alertCertBody(String certified, String cert, String missing) {
    return '$certified est certifié $cert, mais pas $missing : le produit fini ne pourra pas revendiquer $cert.';
  }

  @override
  String get alertRetiredTitle => 'Référence retirée par le fournisseur';

  @override
  String alertRetiredBody(String material, String need, String atelier) {
    return '$material n\'est plus proposée : besoin $need, stock atelier $atelier.';
  }

  @override
  String get alertAtelierShortTitle => 'Stock atelier insuffisant';

  @override
  String alertAtelierShortBody(
    String material,
    String need,
    String atelier,
    String missing,
  ) {
    return '$material : besoin $need, stock atelier $atelier. Il manque $missing.';
  }

  @override
  String get alertCoveredTitle => 'À commander chez le fournisseur';

  @override
  String alertCoveredBody(
    String material,
    String need,
    String atelier,
    String missing,
  ) {
    return '$material : besoin $need, stock atelier $atelier. Le complément ($missing) est disponible chez le fournisseur.';
  }

  @override
  String alertCoveredBodyExact(
    String material,
    String need,
    String atelier,
    String missing,
    String supplier,
  ) {
    return '$material : besoin $need, stock atelier $atelier. Le complément ($missing) est disponible chez le fournisseur ($supplier en stock).';
  }

  @override
  String get alertSupplierShortTitle => 'Stock fournisseur insuffisant';

  @override
  String alertSupplierShortBody(
    String material,
    String missing,
    String atelier,
    String supplier,
  ) {
    return '$material : il manque $missing après le stock atelier ($atelier), et le fournisseur n\'en a que $supplier.';
  }

  @override
  String get alertSupplierLowTitle => 'Stock faible chez le fournisseur';

  @override
  String alertSupplierLowBody(String material, String missing, String atelier) {
    return '$material : il manque $missing après le stock atelier ($atelier), et le fournisseur est en stock faible.';
  }

  @override
  String get alertOnOrderTitle => 'Sur commande chez le fournisseur';

  @override
  String alertOnOrderBody(
    String material,
    String missing,
    String atelier,
    int weeks,
  ) {
    return '$material : il manque $missing après le stock atelier ($atelier). Délai de réassort : $weeks semaines.';
  }

  @override
  String get alertOutTitle => 'Rupture chez le fournisseur';

  @override
  String alertOutBody(String material, String missing, String atelier) {
    return '$material : il manque $missing après le stock atelier ($atelier), et le fournisseur est en rupture.';
  }

  @override
  String get alertHiddenTitle => 'Disponibilité non communiquée';

  @override
  String alertHiddenBody(String material, String missing, String atelier) {
    return '$material : il manque $missing après le stock atelier ($atelier). Le fournisseur ne publie pas son stock : contactez-le.';
  }

  @override
  String notifStockLow(String name, String code) {
    return '$name : stock faible chez le fournisseur ($code)';
  }

  @override
  String notifStockOut(String name, String code) {
    return '$name : rupture chez le fournisseur ($code)';
  }

  @override
  String notifReferenceUpdated(String name, String code) {
    return '$name : fiche modifiée par le fournisseur ($code)';
  }

  @override
  String notifReferenceRetired(String name, String code) {
    return '$name : référence retirée par le fournisseur ($code)';
  }

  @override
  String notifUsedIn(String models) {
    return 'Utilisée dans : $models';
  }

  @override
  String get exportPdf => 'Exporter en PDF';

  @override
  String get exportDossier => 'Exporter le dossier PDF';

  @override
  String get pdfLanguage => 'Langue du PDF';

  @override
  String get pdfMaterialSheet => 'Fiche matière';

  @override
  String get pdfModelDossier => 'Dossier matières';

  @override
  String get pdfCollectionDossier => 'Dossier matières de la collection';

  @override
  String pdfEditedOn(String date) {
    return 'Édité le $date';
  }

  @override
  String get pdfNotSet => 'Non renseigné';

  @override
  String get pdfCompositionNote =>
      'Composition exprimée selon le règlement (UE) n° 1007/2011. Caractéristiques indicatives, à valider sur échantillon.';

  @override
  String get pdfSupplierData => 'Données fournisseur';

  @override
  String pdfPage(int page, int total) {
    return 'Page $page / $total';
  }

  @override
  String get pdfContents => 'Sommaire';

  @override
  String get pdfMaterial => 'Matière';

  @override
  String get pdfConsumption => 'Conso./pièce';

  @override
  String get pdfNeed => 'Besoin';

  @override
  String get pdfGenerationError => 'Le PDF n\'a pas pu être généré. Réessayez.';
}
