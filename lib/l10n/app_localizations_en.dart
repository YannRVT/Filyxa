// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Filyxa';

  @override
  String get navLibrary => 'TissuTech';

  @override
  String get navStudio => 'Studio';

  @override
  String get navScanner => 'Scanner';

  @override
  String get navSuppliers => 'Suppliers';

  @override
  String get navAccount => 'Account';

  @override
  String get comingSoonTitle => 'Coming soon';

  @override
  String get comingSoonBody =>
      'This section is coming in a future version of Filyxa.';

  @override
  String get emailLabel => 'Email';

  @override
  String get passwordLabel => 'Password';

  @override
  String get newPasswordLabel => 'New password';

  @override
  String get confirmPasswordLabel => 'Confirm password';

  @override
  String get passwordHelper =>
      'At least 8 characters, with at least one letter and one digit';

  @override
  String get codeLabel => '6-digit code';

  @override
  String get showPassword => 'Show password';

  @override
  String get hidePassword => 'Hide password';

  @override
  String get loginTitle => 'Sign in';

  @override
  String get loginSubtitle => 'Access your studio\'s material library.';

  @override
  String get loginButton => 'Sign in';

  @override
  String get forgotPassword => 'Forgot password?';

  @override
  String get haveInvitation => 'I have an invitation';

  @override
  String get devQuickLogin => 'Quick sign-in (dev)';

  @override
  String get inviteTitle => 'Join your team';

  @override
  String get inviteIntro =>
      'Enter your email and the 6-digit code from the invitation email.';

  @override
  String get verifyCode => 'Verify code';

  @override
  String get resendCode => 'Get a new code';

  @override
  String codeResent(String email) {
    return 'If an invitation is pending for $email, a new code has just been sent.';
  }

  @override
  String get choosePasswordTitle => 'Choose your password';

  @override
  String choosePasswordIntro(String organization) {
    return 'Welcome to $organization. Choose the password for your account.';
  }

  @override
  String get savePassword => 'Save and continue';

  @override
  String get invitationExpiredTitle => 'Invitation expired';

  @override
  String get invitationExpiredBody =>
      'This invitation has expired. Ask your studio\'s administrator to send you a new one.';

  @override
  String get invitationNotFound =>
      'No pending invitation for this address. Check the email you used or ask for a new invitation.';

  @override
  String get alreadyMember =>
      'This account already belongs to an organization.';

  @override
  String get backToLogin => 'Back to sign in';

  @override
  String get resetTitle => 'Forgot password';

  @override
  String get resetIntro =>
      'Enter your account email: you will receive a reset code.';

  @override
  String get sendCode => 'Send code';

  @override
  String resetCodeSent(String email) {
    return 'If an account exists for $email, a 6-digit code has just been sent to it.';
  }

  @override
  String get resetButton => 'Change password';

  @override
  String get passwordChanged => 'Password changed. You are signed in.';

  @override
  String get errorEmailInvalid => 'Invalid email address';

  @override
  String get errorPasswordShort => 'At least 8 characters';

  @override
  String get errorPasswordWeak => 'At least one letter and one digit';

  @override
  String get errorPasswordMismatch => 'Passwords do not match';

  @override
  String get errorCodeInvalid => 'Enter the 6-digit code';

  @override
  String get errorBadCredentials => 'Incorrect email or password';

  @override
  String get errorCodeExpired =>
      'Incorrect or expired code. Request a new one.';

  @override
  String get errorNetwork =>
      'Unable to connect. Check your network and try again.';

  @override
  String get errorTooManyRequests =>
      'Too many attempts. Wait a few minutes before trying again.';

  @override
  String get errorForbidden => 'Only administrators can do this.';

  @override
  String get errorEmailNotSent =>
      'The email could not be sent. Try again in a few minutes.';

  @override
  String get errorGeneric => 'Something went wrong. Try again.';

  @override
  String get errorOrgName => 'Between 2 and 120 characters';

  @override
  String get retry => 'Try again';

  @override
  String get cancel => 'Cancel';

  @override
  String get logout => 'Sign out';

  @override
  String get accountTitle => 'My account';

  @override
  String get languageLabel => 'Language';

  @override
  String get organizationLabel => 'Organization';

  @override
  String get roleLabel => 'Role';

  @override
  String get roleAdmin => 'Admin';

  @override
  String get roleEditor => 'Editor';

  @override
  String get roleViewer => 'Viewer';

  @override
  String get superadminConsole => 'Super-admin console';

  @override
  String get noOrgTitle => 'No organization';

  @override
  String get noOrgBody =>
      'Your account is not linked to any organization. Ask your studio\'s administrator for an invitation.';

  @override
  String get loadingError => 'Unable to load your workspace.';

  @override
  String get adminTitle => 'Super-admin console';

  @override
  String get adminNewAtelier => 'New studio';

  @override
  String get adminEmpty =>
      'No organizations yet. Create the first pilot studio.';

  @override
  String get adminOrgName => 'Studio name';

  @override
  String get adminAdminEmail => 'Admin email';

  @override
  String get adminCreate => 'Create and invite';

  @override
  String adminCreated(String email) {
    return 'Studio created. Invitation sent to $email.';
  }

  @override
  String adminInvitePending(String email, String date) {
    return 'Pending invitation: $email · expires $date';
  }

  @override
  String adminInviteExpired(String email) {
    return 'Expired invitation: $email';
  }

  @override
  String adminMembers(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count members',
      one: '1 member',
      zero: 'No members',
    );
    return '$_temp0';
  }

  @override
  String get adminReinvite => 'Resend invitation';

  @override
  String adminReinvited(String email) {
    return 'Invitation resent to $email.';
  }

  @override
  String get orgKindAtelier => 'Studio';

  @override
  String get orgKindSupplier => 'Supplier';

  @override
  String get missingConfig =>
      'Supabase configuration missing. Copy env.example.json to env.json, fill it in, then run: flutter run --dart-define-from-file=env.json';

  @override
  String get membersEntry => 'Studio members';

  @override
  String get membersTitle => 'Members';

  @override
  String get membersInvite => 'Invite';

  @override
  String get inviteDialogTitle => 'Invite a member';

  @override
  String get inviteSend => 'Send invitation';

  @override
  String get roleAdminHelp => 'Manages members and studio settings';

  @override
  String get roleEditorHelp => 'Creates, edits, scans, imports and shares';

  @override
  String get roleViewerHelp => 'Views and exports, without changing anything';

  @override
  String get youSuffix => 'you';

  @override
  String get pendingInvitations => 'Pending invitations';

  @override
  String invitationExpiresOn(String date) {
    return 'Expires $date';
  }

  @override
  String get invitationExpiredShort => 'Expired';

  @override
  String get resendInvitation => 'Resend';

  @override
  String get cancelInvitation => 'Cancel invitation';

  @override
  String invitationSent(String email) {
    return 'Invitation sent to $email.';
  }

  @override
  String get invitationCanceled => 'Invitation canceled.';

  @override
  String get changeRole => 'Change role';

  @override
  String get roleChanged => 'Role updated.';

  @override
  String get removeMember => 'Remove from studio';

  @override
  String removeConfirmTitle(String name) {
    return 'Remove $name?';
  }

  @override
  String get removeConfirmBody =>
      'This person will immediately lose access to the studio\'s data. You can invite them again later.';

  @override
  String get removeConfirm => 'Remove';

  @override
  String get memberRemoved => 'Member removed.';

  @override
  String get errorLastAdmin =>
      'The studio must keep at least one admin. Make someone else admin first.';

  @override
  String get lastAdminHint => 'Only admin of the studio';

  @override
  String memberActions(String name) {
    return 'Actions for $name';
  }

  @override
  String get libraryNew => 'New material';

  @override
  String get viewGallery => 'Gallery';

  @override
  String get viewTable => 'Table';

  @override
  String get libraryEmptyTitle => 'Your TissuTech is empty';

  @override
  String get libraryEmptyBody =>
      'Add your first materials: scan a sample label, import your Excel file or enter them by hand.';

  @override
  String get libraryEmptyViewer =>
      'No materials yet. Your studio\'s editors can add some.';

  @override
  String get actionScanSample => 'Scan a sample';

  @override
  String get actionImportExcel => 'Import an Excel file';

  @override
  String get actionCreateManual => 'Enter by hand';

  @override
  String materialCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count materials',
      one: '1 material',
      zero: 'No materials',
    );
    return '$_temp0';
  }

  @override
  String get colMaterial => 'Material';

  @override
  String get colReference => 'Reference';

  @override
  String get colComposition => 'Composition';

  @override
  String get colWeight => 'g/m²';

  @override
  String get colWidth => 'Width';

  @override
  String get colStock => 'Studio stock';

  @override
  String get fieldName => 'Material name';

  @override
  String get fieldSupplier => 'Supplier';

  @override
  String get fieldSupplierCode => 'Article code';

  @override
  String get fieldColorName => 'Colourway';

  @override
  String get fieldColorHex => 'Colour (#RRGGBB)';

  @override
  String get photoAdd => 'Add a photo';

  @override
  String get photoChange => 'Change photo';

  @override
  String get photoRemove => 'Remove photo';

  @override
  String get sectionIdentity => 'Identity';

  @override
  String get sectionColor => 'Colour and photo';

  @override
  String get sectionComposition => 'Composition';

  @override
  String get sectionTechnical => 'Specifications';

  @override
  String get sectionCare => 'Care';

  @override
  String get sectionUses => 'Uses and certifications';

  @override
  String get sectionStock => 'Studio stock';

  @override
  String get sectionNotes => 'Notes';

  @override
  String get addFiber => 'Add a fibre';

  @override
  String get removeFiber => 'Remove this fibre';

  @override
  String get fiberLabel => 'Fibre';

  @override
  String compositionTotal(String total) {
    return 'Total: $total%';
  }

  @override
  String get compositionMustBe100 =>
      'The total must be 100%, with no duplicate fibre';

  @override
  String get fieldWeight => 'Weight (g/m²)';

  @override
  String get fieldWidth => 'Width (cm)';

  @override
  String get fieldWeave => 'Weave';

  @override
  String get noneOption => 'Not specified';

  @override
  String get fieldCertifications => 'Certifications';

  @override
  String get fieldUses => 'Uses';

  @override
  String get fieldStock => 'Metres in stock (m)';

  @override
  String get errorRequired => 'Required field';

  @override
  String errorNumberRange(int min, int max) {
    return 'Number between $min and $max';
  }

  @override
  String get errorHex => 'Expected format #RRGGBB (e.g. #2F4A6B)';

  @override
  String get save => 'Save';

  @override
  String get materialSaved => 'Material saved.';

  @override
  String get edit => 'Edit';

  @override
  String get delete => 'Delete';

  @override
  String deleteMaterialTitle(String name) {
    return 'Delete “$name”?';
  }

  @override
  String get deleteMaterialBody =>
      'The material and its photo will be permanently deleted.';

  @override
  String get materialDeleted => 'Material deleted.';

  @override
  String get editStock => 'Edit stock';

  @override
  String get stockUpdated => 'Stock updated.';

  @override
  String stockMeters(String value) {
    return '$value m';
  }

  @override
  String get materialNotFound =>
      'This material no longer exists or is not accessible.';

  @override
  String get newMaterialTitle => 'New material';

  @override
  String get editMaterialTitle => 'Edit material';

  @override
  String get detailWeight => 'Weight';

  @override
  String get detailWidth => 'Width';

  @override
  String get photoUploadFailed => 'The photo could not be uploaded. Try again.';

  @override
  String get viewerReadOnly => 'Read only';

  @override
  String get errorEditorsOnly =>
      'Only the studio\'s editors and admins can do this.';

  @override
  String get searchHint => 'Search: name, code, supplier, colour, fibre…';

  @override
  String get clearSearch => 'Clear search';

  @override
  String get filtersButton => 'Filters';

  @override
  String get clearFilters => 'Clear filters';

  @override
  String get showResults => 'Show results';

  @override
  String get noResultsTitle => 'No results';

  @override
  String get noResultsBody => 'No material matches your search or filters.';

  @override
  String resultCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count results',
      one: '1 result',
      zero: 'No results',
    );
    return '$_temp0';
  }

  @override
  String get filterFiber => 'Fibre';

  @override
  String get filterFiberAny => 'All fibres';

  @override
  String filterFiberMin(int pct) {
    return 'At least $pct%';
  }

  @override
  String get filterWeight => 'Weight';

  @override
  String get filterColor => 'Colour';

  @override
  String get filterInStock => 'In stock at the studio';

  @override
  String removeFilter(String label) {
    return 'Remove filter $label';
  }

  @override
  String chipFiberMin(String fiber, int pct) {
    return '$fiber ≥ $pct%';
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
  String get catalogEmptyTitle => 'Your catalogue is empty';

  @override
  String get catalogEmptyBody =>
      'Import your catalogue from an Excel or CSV file exported from your management software.';

  @override
  String get catalogImport => 'Import a file';

  @override
  String get catalogSettings => 'Availability';

  @override
  String referenceCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count references',
      one: '1 reference',
      zero: 'No references',
    );
    return '$_temp0';
  }

  @override
  String get showRetired => 'Show retired references';

  @override
  String get retiredBadge => 'Retired';

  @override
  String get colStatus => 'Availability';

  @override
  String get colLeadTime => 'Lead time';

  @override
  String get statusAvailable => 'Available';

  @override
  String get statusLow => 'Low stock';

  @override
  String get statusOnOrder => 'On order';

  @override
  String statusOnOrderWeeks(int weeks) {
    return 'On order · $weeks wk';
  }

  @override
  String get statusOutOfStock => 'Out of stock';

  @override
  String get statusHidden => 'Hidden';

  @override
  String get modeExact => 'Exact quantity';

  @override
  String get modeTiers => 'Tiers';

  @override
  String get modeHidden => 'Hidden';

  @override
  String get modeExactHelp => 'Studios see your exact metres in stock.';

  @override
  String get modeTiersHelp =>
      'Studios only see: available, low stock, on order or out of stock.';

  @override
  String get modeHiddenHelp => 'Studios do not see availability.';

  @override
  String modeDefault(String mode) {
    return 'General setting ($mode)';
  }

  @override
  String get thresholdLabel => 'Low stock threshold (m)';

  @override
  String get thresholdHelp =>
      'Below this many metres, the reference shows as “low stock”.';

  @override
  String get leadTimeLabel => 'Restock lead time (weeks)';

  @override
  String get leadTimeHelp => 'Shown when the reference is on order.';

  @override
  String get availabilitySettingsTitle => 'Availability display';

  @override
  String get availabilitySettingsIntro =>
      'Choose what studios see of your stock. You can adjust each reference from its page.';

  @override
  String get settingsSaved => 'Settings saved.';

  @override
  String get referenceRetire => 'Retire from catalogue';

  @override
  String get referenceRestore => 'Restore to catalogue';

  @override
  String get referenceRetired =>
      'Reference retired from the published catalogue.';

  @override
  String get referenceRestored => 'Reference restored to the catalogue.';

  @override
  String retireConfirmTitle(String code) {
    return 'Retire “$code”?';
  }

  @override
  String get retireConfirmBody =>
      'Studios will no longer see it. Those using it keep its last data sheet. You can restore it later.';

  @override
  String get referenceAvailabilityTitle => 'Availability of this reference';

  @override
  String get stockLabel => 'Stock';

  @override
  String whatAteliersSee(String value) {
    return 'What studios see: $value';
  }

  @override
  String get importTitle => 'Import the catalogue';

  @override
  String get importPickFile => 'Choose an Excel or CSV file';

  @override
  String get importPickHelp =>
      'An .xlsx or .csv file, one row per reference with a header row. Up to 5,000 rows. A known reference is updated by its code.';

  @override
  String get importUnreadable =>
      'This file could not be read. Save it as .xlsx or .csv and try again.';

  @override
  String importTooMany(int count) {
    return 'This file has $count rows: up to 5,000 per import.';
  }

  @override
  String get importMappingTitle => 'Match your columns';

  @override
  String get importMappingIntro =>
      'Recognised columns are already matched. Article code and name are required.';

  @override
  String get importColumnNone => '— Ignore —';

  @override
  String get importFieldName => 'Name';

  @override
  String get importFieldStock => 'Stock (m)';

  @override
  String importSummary(int valid, int invalid) {
    return '$valid rows ready · $invalid with errors';
  }

  @override
  String get importErrorsTitle => 'Rows with errors (not imported)';

  @override
  String importLine(int line) {
    return 'Row $line';
  }

  @override
  String importRun(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Import $count references',
      one: 'Import 1 reference',
    );
    return '$_temp0';
  }

  @override
  String importRunning(int done, int total) {
    return 'Importing… $done/$total';
  }

  @override
  String get importDoneTitle => 'Import complete';

  @override
  String importDone(int inserted, int updated) {
    return '$inserted created · $updated updated';
  }

  @override
  String importServerRejected(String message) {
    return 'Rejected by the server: $message';
  }

  @override
  String get importAgain => 'Import another file';

  @override
  String get backToCatalog => 'Back to catalogue';

  @override
  String importFileName(String name) {
    return 'File: $name';
  }

  @override
  String get issueMissingCode => 'Missing article code';

  @override
  String get issueMissingName => 'Missing name';

  @override
  String issueComposition(String value) {
    return 'Unreadable composition or not 100%: “$value”';
  }

  @override
  String issueNumber(String field, String value) {
    return '$field: invalid value “$value”';
  }

  @override
  String issueColor(String value) {
    return 'Invalid colour “$value” (format #RRGGBB)';
  }

  @override
  String issueDuplicate(String value) {
    return 'Code “$value” appears several times in the file';
  }

  @override
  String get adminOrgKind => 'Organization type';

  @override
  String get adminNewOrg => 'New organization';

  @override
  String get adminOrgNameGeneric => 'Organization name';

  @override
  String get scanTitle => 'Scan a sample';

  @override
  String get scanIntro =>
      'Photograph the sample label, flat and in focus. Filyxa reads the composition, weight, width, care and article code; you check before saving.';

  @override
  String get scanTakePhoto => 'Take a photo';

  @override
  String get scanImportPhoto => 'Import a photo';

  @override
  String get scanReading => 'Reading the label…';

  @override
  String scanUsage(int scans, int quota) {
    return '$scans / $quota scans this month';
  }

  @override
  String scanQuotaWarning(int percent) {
    return '$percent% of the monthly scan quota is used.';
  }

  @override
  String get scanQuotaExhausted =>
      'Monthly scan quota reached. You can still enter materials by hand.';

  @override
  String get scanFailureNotLabel =>
      'No readable textile label in this photo. Take it again closer, flat, without glare.';

  @override
  String get scanFailureRefused =>
      'The analysis of this image was declined. Try another photo.';

  @override
  String get scanFailureAi =>
      'The reading service is temporarily unavailable. Try again in a moment.';

  @override
  String get scanFailureImage =>
      'This image is not supported (JPEG, PNG or WebP, 5 MB max).';

  @override
  String get prefillBanner =>
      'Form pre-filled by the scan. Check the flagged fields before saving.';

  @override
  String get fieldUncertain => 'Read with low confidence: please check';

  @override
  String get sectionUncertain => 'Uncertain reading: check this section.';

  @override
  String duplicateFound(String name) {
    return 'A material with this article code already exists: “$name”.';
  }

  @override
  String get duplicateOpen => 'Open the existing material';

  @override
  String get matchTitle => 'Is this the right reference?';

  @override
  String matchIntro(String supplier) {
    return 'Found in $supplier\'s catalogue. Confirm to link your material to its data and availability.';
  }

  @override
  String get matchConfirm => 'Yes, link this reference';

  @override
  String get matchOthers => 'Other close references';

  @override
  String get matchNone => 'None of these references';

  @override
  String get supplierData => 'Supplier data';

  @override
  String get supplierDataHelp =>
      'Kept up to date by the supplier, not editable here.';

  @override
  String get referenceRetiredBanner =>
      'Reference retired by the supplier. The last known values are kept.';

  @override
  String get linkToSupplier => 'Link to a supplier reference';

  @override
  String get linkSearchHint => 'Article code, name or supplier';

  @override
  String get linkSearchEmpty => 'No published reference matches.';

  @override
  String get linkConfirm => 'Link';

  @override
  String get unlink => 'Unlink the reference';

  @override
  String get unlinkConfirmBody =>
      'The material keeps its current values and becomes editable again. It will no longer follow the supplier\'s updates.';

  @override
  String get linkedDone => 'Material linked to the supplier.';

  @override
  String get unlinkedDone => 'Material unlinked from the supplier.';

  @override
  String get privateLayer => 'Studio information';

  @override
  String get privateLayerHelp => 'Visible to your studio only.';

  @override
  String get fieldPrice => 'Negotiated price (€/m)';

  @override
  String get fieldTags => 'Tags';

  @override
  String get fieldTagsHint => 'Comma-separated (e.g. AW27, to approve)';

  @override
  String priceValue(String value) {
    return '€$value/m';
  }

  @override
  String get atelierImportTitle => 'Import your workshop library';

  @override
  String get atelierImportHelp =>
      'An .xlsx or .csv file with one row per material and a header row. 5,000 rows maximum. A material already in your library (same supplier and code, or same name and colour) is updated, never duplicated.';

  @override
  String get atelierImportMappingIntro =>
      'Recognised columns are already matched. Only the material name is required.';

  @override
  String atelierImportRun(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Import $count materials',
      one: 'Import 1 material',
    );
    return '$_temp0';
  }

  @override
  String atelierImportDone(int imported, int linked, int pending, int errors) {
    return '$imported imported · $linked linked to a supplier · $pending to confirm · $errors with errors';
  }

  @override
  String atelierImportDetail(int inserted, int updated) {
    return 'including $inserted new and $updated updated';
  }

  @override
  String get backToLibrary => 'Back to TissuTech';

  @override
  String reviewLinksAction(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Confirm $count matches',
      one: 'Confirm 1 match',
    );
    return '$_temp0';
  }

  @override
  String pendingLinksBanner(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count imported materials look like supplier references.',
      one: '1 imported material looks like a supplier reference.',
    );
    return '$_temp0';
  }

  @override
  String get reviewTitle => 'Matches to confirm';

  @override
  String reviewProgress(int index, int total) {
    return '$index of $total';
  }

  @override
  String get reviewIntro =>
      'Your record looks like a published reference. Confirm to link it to its data and availability.';

  @override
  String get reviewSkip => 'Later';

  @override
  String get reviewDone => 'All matches have been handled.';

  @override
  String get reviewNoCandidate =>
      'No published reference matches this material any more.';

  @override
  String get reviewOpen => 'Review';

  @override
  String get reportAction => 'Report an error';

  @override
  String get reportTitle => 'Report an error to the supplier';

  @override
  String get reportIntro =>
      'The supplier will fix the record for every workshop. They don\'t see your workshop\'s name unless you choose to share it.';

  @override
  String get reportField => 'Field';

  @override
  String get reportObserved => 'Observed value';

  @override
  String get reportObservedHint => 'E.g. 300 g/m² measured on the swatch';

  @override
  String get reportComment => 'Comment (optional)';

  @override
  String get reportShareIdentity =>
      'Share my workshop\'s name with the supplier';

  @override
  String get reportSend => 'Send';

  @override
  String get reportSent => 'Report sent to the supplier.';

  @override
  String get reportFieldAvailability => 'Availability';

  @override
  String get reportFieldOther => 'Other';

  @override
  String get reportsSection => 'Reports';

  @override
  String get reportStatusOpen => 'Open';

  @override
  String get reportStatusFixed => 'Fixed';

  @override
  String get reportStatusRejected => 'Rejected';

  @override
  String reportObservedLine(String value) {
    return 'Observed: $value';
  }

  @override
  String reportReasonLine(String reason) {
    return 'Reason: $reason';
  }

  @override
  String reportResponseLine(String response) {
    return 'Reply: $response';
  }

  @override
  String get supplierReportsTitle => 'Reports from workshops';

  @override
  String supplierReportsButton(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count open reports',
      one: '1 open report',
      zero: 'Reports',
    );
    return '$_temp0';
  }

  @override
  String get supplierReportsEmpty => 'No reports yet.';

  @override
  String get reportAnonymous => 'Anonymous workshop';

  @override
  String get reportMarkFixed => 'Mark as fixed';

  @override
  String get reportReject => 'Reject';

  @override
  String get reportRejectTitle => 'Reject the report';

  @override
  String get reportRejectReason => 'Reason for rejecting';

  @override
  String get reportFixTitle => 'Mark as fixed';

  @override
  String get reportFixHelp =>
      'Remember to fix the reference in your catalogue: linked workshops will see it right away.';

  @override
  String get reportFixMessage => 'Message to the workshop (optional)';

  @override
  String get reportEditReference => 'Open the reference';

  @override
  String get reportFilterOpen => 'Open';

  @override
  String get reportFilterAll => 'All';

  @override
  String get notificationsTitle => 'Notifications';

  @override
  String get notificationsEmpty => 'No notifications.';

  @override
  String notificationsTooltip(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Notifications ($count unread)',
      one: 'Notifications (1 unread)',
      zero: 'Notifications',
    );
    return '$_temp0';
  }

  @override
  String notifReportNew(String code, String field) {
    return 'New report on $code · $field';
  }

  @override
  String notifReportFixed(String name, String field) {
    return '$name: the supplier fixed \"$field\"';
  }

  @override
  String notifReportRejected(String name, String field) {
    return '$name: report on \"$field\" rejected';
  }
}
