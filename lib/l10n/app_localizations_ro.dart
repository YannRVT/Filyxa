// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Romanian Moldavian Moldovan (`ro`).
class AppLocalizationsRo extends AppLocalizations {
  AppLocalizationsRo([String locale = 'ro']) : super(locale);

  @override
  String get appTitle => 'Filyxa';

  @override
  String get navLibrary => 'TissuTech';

  @override
  String get navStudio => 'Studio';

  @override
  String get navScanner => 'Scanner';

  @override
  String get navSuppliers => 'Furnizori';

  @override
  String get navAccount => 'Cont';

  @override
  String get comingSoonTitle => 'În curând';

  @override
  String get comingSoonBody =>
      'Această secțiune va fi disponibilă într-o versiune viitoare Filyxa.';

  @override
  String get emailLabel => 'E-mail';

  @override
  String get passwordLabel => 'Parolă';

  @override
  String get newPasswordLabel => 'Parolă nouă';

  @override
  String get confirmPasswordLabel => 'Confirmă parola';

  @override
  String get passwordHelper =>
      'Minimum 8 caractere, cu cel puțin o literă și o cifră';

  @override
  String get codeLabel => 'Cod din 6 cifre';

  @override
  String get showPassword => 'Afișează parola';

  @override
  String get hidePassword => 'Ascunde parola';

  @override
  String get loginTitle => 'Autentificare';

  @override
  String get loginSubtitle =>
      'Accesează biblioteca de materiale a atelierului tău.';

  @override
  String get loginButton => 'Autentificare';

  @override
  String get forgotPassword => 'Ai uitat parola?';

  @override
  String get haveInvitation => 'Am primit o invitație';

  @override
  String get devQuickLogin => 'Autentificare rapidă (dev)';

  @override
  String get inviteTitle => 'Alătură-te echipei tale';

  @override
  String get inviteIntro =>
      'Introdu adresa de e-mail și codul din 6 cifre primit în e-mailul de invitație.';

  @override
  String get verifyCode => 'Verifică codul';

  @override
  String get resendCode => 'Primește un cod nou';

  @override
  String codeResent(String email) {
    return 'Dacă există o invitație în așteptare pentru $email, tocmai a fost trimis un cod nou.';
  }

  @override
  String get choosePasswordTitle => 'Alege-ți parola';

  @override
  String choosePasswordIntro(String organization) {
    return 'Bun venit la $organization. Alege parola contului tău.';
  }

  @override
  String get savePassword => 'Salvează și intră';

  @override
  String get invitationExpiredTitle => 'Invitație expirată';

  @override
  String get invitationExpiredBody =>
      'Această invitație a expirat. Cere administratorului atelierului tău să îți trimită una nouă.';

  @override
  String get invitationNotFound =>
      'Nicio invitație în așteptare pentru această adresă. Verifică adresa de e-mail folosită sau cere o invitație nouă.';

  @override
  String get alreadyMember => 'Acest cont aparține deja unei organizații.';

  @override
  String get backToLogin => 'Înapoi la autentificare';

  @override
  String get resetTitle => 'Parolă uitată';

  @override
  String get resetIntro =>
      'Introdu adresa de e-mail a contului: vei primi un cod de resetare.';

  @override
  String get sendCode => 'Trimite codul';

  @override
  String resetCodeSent(String email) {
    return 'Dacă există un cont pentru $email, tocmai i-a fost trimis un cod din 6 cifre.';
  }

  @override
  String get resetButton => 'Schimbă parola';

  @override
  String get passwordChanged => 'Parola a fost schimbată. Ești autentificat.';

  @override
  String get errorEmailInvalid => 'Adresă de e-mail nevalidă';

  @override
  String get errorPasswordShort => 'Minimum 8 caractere';

  @override
  String get errorPasswordWeak => 'Cel puțin o literă și o cifră';

  @override
  String get errorPasswordMismatch => 'Parolele nu coincid';

  @override
  String get errorCodeInvalid => 'Introdu codul din 6 cifre';

  @override
  String get errorBadCredentials => 'E-mail sau parolă incorectă';

  @override
  String get errorCodeExpired => 'Cod incorect sau expirat. Cere unul nou.';

  @override
  String get errorNetwork =>
      'Conectare imposibilă. Verifică rețeaua și încearcă din nou.';

  @override
  String get errorTooManyRequests =>
      'Prea multe încercări. Așteaptă câteva minute înainte de a încerca din nou.';

  @override
  String get errorForbidden => 'Acțiune rezervată administratorilor.';

  @override
  String get errorEmailNotSent =>
      'E-mailul nu a putut fi trimis. Încearcă din nou peste câteva minute.';

  @override
  String get errorGeneric => 'A apărut o eroare. Încearcă din nou.';

  @override
  String get errorOrgName => 'Între 2 și 120 de caractere';

  @override
  String get retry => 'Încearcă din nou';

  @override
  String get cancel => 'Anulează';

  @override
  String get logout => 'Deconectare';

  @override
  String get accountTitle => 'Contul meu';

  @override
  String get languageLabel => 'Limbă';

  @override
  String get organizationLabel => 'Organizație';

  @override
  String get roleLabel => 'Rol';

  @override
  String get roleAdmin => 'Admin';

  @override
  String get roleEditor => 'Editor';

  @override
  String get roleViewer => 'Cititor';

  @override
  String get superadminConsole => 'Consolă super-admin';

  @override
  String get noOrgTitle => 'Nicio organizație';

  @override
  String get noOrgBody =>
      'Contul tău nu este asociat niciunei organizații. Cere o invitație administratorului atelierului tău.';

  @override
  String get loadingError => 'Spațiul tău nu poate fi încărcat.';

  @override
  String get adminTitle => 'Consolă super-admin';

  @override
  String get adminNewAtelier => 'Atelier nou';

  @override
  String get adminEmpty =>
      'Nicio organizație deocamdată. Creează primul atelier pilot.';

  @override
  String get adminOrgName => 'Numele atelierului';

  @override
  String get adminAdminEmail => 'E-mailul administratorului';

  @override
  String get adminCreate => 'Creează și invită';

  @override
  String adminCreated(String email) {
    return 'Atelier creat. Invitație trimisă către $email.';
  }

  @override
  String adminInvitePending(String email, String date) {
    return 'Invitație în așteptare: $email · expiră pe $date';
  }

  @override
  String adminInviteExpired(String email) {
    return 'Invitație expirată: $email';
  }

  @override
  String adminMembers(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count de membri',
      few: '$count membri',
      one: '1 membru',
      zero: 'Niciun membru',
    );
    return '$_temp0';
  }

  @override
  String get adminReinvite => 'Retrimite invitația';

  @override
  String adminReinvited(String email) {
    return 'Invitație retrimisă către $email.';
  }

  @override
  String get orgKindAtelier => 'Atelier';

  @override
  String get orgKindSupplier => 'Furnizor';

  @override
  String get missingConfig =>
      'Configurația Supabase lipsește. Copiază env.example.json în env.json, completează-l, apoi rulează: flutter run --dart-define-from-file=env.json';

  @override
  String get membersEntry => 'Membrii atelierului';

  @override
  String get membersTitle => 'Membri';

  @override
  String get membersInvite => 'Invită';

  @override
  String get inviteDialogTitle => 'Invită un membru';

  @override
  String get inviteSend => 'Trimite invitația';

  @override
  String get roleAdminHelp => 'Gestionează membrii și setările atelierului';

  @override
  String get roleEditorHelp =>
      'Creează, modifică, scanează, importă și partajează';

  @override
  String get roleViewerHelp => 'Consultă și exportă, fără a modifica nimic';

  @override
  String get youSuffix => 'tu';

  @override
  String get pendingInvitations => 'Invitații în așteptare';

  @override
  String invitationExpiresOn(String date) {
    return 'Expiră pe $date';
  }

  @override
  String get invitationExpiredShort => 'Expirată';

  @override
  String get resendInvitation => 'Retrimite';

  @override
  String get cancelInvitation => 'Anulează invitația';

  @override
  String invitationSent(String email) {
    return 'Invitație trimisă către $email.';
  }

  @override
  String get invitationCanceled => 'Invitație anulată.';

  @override
  String get changeRole => 'Schimbă rolul';

  @override
  String get roleChanged => 'Rol actualizat.';

  @override
  String get removeMember => 'Elimină din atelier';

  @override
  String removeConfirmTitle(String name) {
    return 'Elimini pe $name?';
  }

  @override
  String get removeConfirmBody =>
      'Această persoană va pierde imediat accesul la datele atelierului. O poți invita din nou.';

  @override
  String get removeConfirm => 'Elimină';

  @override
  String get memberRemoved => 'Membru eliminat.';

  @override
  String get errorLastAdmin =>
      'Atelierul trebuie să păstreze cel puțin un admin. Numește mai întâi un alt admin.';

  @override
  String get lastAdminHint => 'Singurul admin al atelierului';

  @override
  String memberActions(String name) {
    return 'Acțiuni pentru $name';
  }

  @override
  String get libraryNew => 'Material nou';

  @override
  String get viewGallery => 'Galerie';

  @override
  String get viewTable => 'Tabel';

  @override
  String get libraryEmptyTitle => 'TissuTech-ul tău este gol';

  @override
  String get libraryEmptyBody =>
      'Adaugă primele materiale: scanează eticheta unei mostre, importă fișierul Excel sau introdu-le manual.';

  @override
  String get libraryEmptyViewer =>
      'Niciun material deocamdată. Editorii atelierului tău pot adăuga.';

  @override
  String get actionScanSample => 'Scanează o mostră';

  @override
  String get actionImportExcel => 'Importă un fișier Excel';

  @override
  String get actionCreateManual => 'Introdu manual';

  @override
  String materialCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count de materiale',
      few: '$count materiale',
      one: '1 material',
      zero: 'Niciun material',
    );
    return '$_temp0';
  }

  @override
  String get colMaterial => 'Material';

  @override
  String get colReference => 'Referință';

  @override
  String get colComposition => 'Compoziție';

  @override
  String get colWeight => 'g/m²';

  @override
  String get colWidth => 'Lățime';

  @override
  String get colStock => 'Stoc atelier';

  @override
  String get fieldName => 'Numele materialului';

  @override
  String get fieldSupplier => 'Furnizor';

  @override
  String get fieldSupplierCode => 'Cod articol';

  @override
  String get fieldColorName => 'Culoare';

  @override
  String get fieldColorHex => 'Culoare (#RRGGBB)';

  @override
  String get photoAdd => 'Adaugă o fotografie';

  @override
  String get photoChange => 'Schimbă fotografia';

  @override
  String get photoRemove => 'Elimină fotografia';

  @override
  String get sectionIdentity => 'Identitate';

  @override
  String get sectionColor => 'Culoare și fotografie';

  @override
  String get sectionComposition => 'Compoziție';

  @override
  String get sectionTechnical => 'Caracteristici';

  @override
  String get sectionCare => 'Întreținere';

  @override
  String get sectionUses => 'Utilizări și certificări';

  @override
  String get sectionStock => 'Stoc atelier';

  @override
  String get sectionNotes => 'Note';

  @override
  String get addFiber => 'Adaugă o fibră';

  @override
  String get removeFiber => 'Elimină această fibră';

  @override
  String get fiberLabel => 'Fibră';

  @override
  String compositionTotal(String total) {
    return 'Total: $total %';
  }

  @override
  String get compositionMustBe100 =>
      'Totalul trebuie să fie 100 %, fără fibre duplicate';

  @override
  String get fieldWeight => 'Gramaj (g/m²)';

  @override
  String get fieldWidth => 'Lățime (cm)';

  @override
  String get fieldWeave => 'Legătură';

  @override
  String get noneOption => 'Nespecificat';

  @override
  String get fieldCertifications => 'Certificări';

  @override
  String get fieldUses => 'Utilizări';

  @override
  String get fieldStock => 'Metri în stoc (m)';

  @override
  String get errorRequired => 'Câmp obligatoriu';

  @override
  String errorNumberRange(int min, int max) {
    return 'Număr între $min și $max';
  }

  @override
  String get errorHex => 'Format așteptat #RRGGBB (ex. #2F4A6B)';

  @override
  String get save => 'Salvează';

  @override
  String get materialSaved => 'Material salvat.';

  @override
  String get edit => 'Modifică';

  @override
  String get delete => 'Șterge';

  @override
  String deleteMaterialTitle(String name) {
    return 'Ștergi „$name”?';
  }

  @override
  String get deleteMaterialBody =>
      'Materialul și fotografia sa vor fi șterse definitiv.';

  @override
  String get materialDeleted => 'Material șters.';

  @override
  String get editStock => 'Modifică stocul';

  @override
  String get stockUpdated => 'Stoc actualizat.';

  @override
  String stockMeters(String value) {
    return '$value m';
  }

  @override
  String get materialNotFound =>
      'Acest material nu mai există sau nu este accesibil.';

  @override
  String get newMaterialTitle => 'Material nou';

  @override
  String get editMaterialTitle => 'Modifică materialul';

  @override
  String get detailWeight => 'Gramaj';

  @override
  String get detailWidth => 'Lățime';

  @override
  String get photoUploadFailed =>
      'Fotografia nu a putut fi încărcată. Încearcă din nou.';

  @override
  String get viewerReadOnly => 'Doar citire';

  @override
  String get errorEditorsOnly =>
      'Acțiune rezervată editorilor și administratorilor atelierului.';

  @override
  String get searchHint => 'Caută: nume, cod, furnizor, culoare, fibră…';

  @override
  String get clearSearch => 'Șterge căutarea';

  @override
  String get filtersButton => 'Filtre';

  @override
  String get clearFilters => 'Șterge filtrele';

  @override
  String get showResults => 'Afișează rezultatele';

  @override
  String get noResultsTitle => 'Niciun rezultat';

  @override
  String get noResultsBody =>
      'Niciun material nu corespunde căutării sau filtrelor.';

  @override
  String resultCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count de rezultate',
      few: '$count rezultate',
      one: '1 rezultat',
      zero: 'Niciun rezultat',
    );
    return '$_temp0';
  }

  @override
  String get filterFiber => 'Fibră';

  @override
  String get filterFiberAny => 'Toate fibrele';

  @override
  String filterFiberMin(int pct) {
    return 'Cel puțin $pct %';
  }

  @override
  String get filterWeight => 'Gramaj';

  @override
  String get filterColor => 'Culoare';

  @override
  String get filterInStock => 'În stoc în atelier';

  @override
  String removeFilter(String label) {
    return 'Elimină filtrul $label';
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
  String get navCatalog => 'Catalog';

  @override
  String get catalogEmptyTitle => 'Catalogul tău este gol';

  @override
  String get catalogEmptyBody =>
      'Importă catalogul dintr-un fișier Excel sau CSV exportat din programul tău de gestiune.';

  @override
  String get catalogImport => 'Importă un fișier';

  @override
  String get catalogSettings => 'Disponibilitate';

  @override
  String referenceCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count de referințe',
      few: '$count referințe',
      one: '1 referință',
      zero: 'Nicio referință',
    );
    return '$_temp0';
  }

  @override
  String get showRetired => 'Afișează referințele retrase';

  @override
  String get retiredBadge => 'Retrasă';

  @override
  String get colStatus => 'Disponibilitate';

  @override
  String get colLeadTime => 'Termen';

  @override
  String get statusAvailable => 'Disponibil';

  @override
  String get statusLow => 'Stoc redus';

  @override
  String get statusOnOrder => 'La comandă';

  @override
  String statusOnOrderWeeks(int weeks) {
    return 'La comandă · $weeks săpt.';
  }

  @override
  String get statusOutOfStock => 'Stoc epuizat';

  @override
  String get statusHidden => 'Ascunsă';

  @override
  String get modeExact => 'Cantitate exactă';

  @override
  String get modeTiers => 'Niveluri';

  @override
  String get modeHidden => 'Ascunsă';

  @override
  String get modeExactHelp => 'Atelierele văd metrajul exact din stoc.';

  @override
  String get modeTiersHelp =>
      'Atelierele văd doar: disponibil, stoc redus, la comandă sau stoc epuizat.';

  @override
  String get modeHiddenHelp => 'Atelierele nu văd disponibilitatea.';

  @override
  String modeDefault(String mode) {
    return 'Setare generală ($mode)';
  }

  @override
  String get thresholdLabel => 'Prag de stoc redus (m)';

  @override
  String get thresholdHelp =>
      'Sub acest metraj, referința apare ca „stoc redus”.';

  @override
  String get leadTimeLabel => 'Termen de reaprovizionare (săptămâni)';

  @override
  String get leadTimeHelp => 'Afișat când referința este la comandă.';

  @override
  String get availabilitySettingsTitle => 'Afișarea disponibilității';

  @override
  String get availabilitySettingsIntro =>
      'Alege ce văd atelierele din stocul tău. Poți ajusta fiecare referință din fișa ei.';

  @override
  String get settingsSaved => 'Setări salvate.';

  @override
  String get referenceRetire => 'Retrage din catalog';

  @override
  String get referenceRestore => 'Repune în catalog';

  @override
  String get referenceRetired => 'Referință retrasă din catalogul publicat.';

  @override
  String get referenceRestored => 'Referință repusă în catalog.';

  @override
  String retireConfirmTitle(String code) {
    return 'Retragi „$code”?';
  }

  @override
  String get retireConfirmBody =>
      'Atelierele nu o vor mai vedea. Cei care o folosesc păstrează ultima fișă. O poți repune ulterior.';

  @override
  String get referenceAvailabilityTitle => 'Disponibilitatea acestei referințe';

  @override
  String get stockLabel => 'Stoc';

  @override
  String whatAteliersSee(String value) {
    return 'Ce văd atelierele: $value';
  }

  @override
  String get importTitle => 'Importă catalogul';

  @override
  String get importPickFile => 'Alege un fișier Excel sau CSV';

  @override
  String get importPickHelp =>
      'Fișier .xlsx sau .csv, un rând pe referință și un rând de antet. Maximum 5.000 de rânduri. O referință existentă este actualizată după cod.';

  @override
  String get importUnreadable =>
      'Fișierul nu a putut fi citit. Salvează-l în format .xlsx sau .csv și încearcă din nou.';

  @override
  String importTooMany(int count) {
    return 'Fișierul conține $count rânduri: maximum 5.000 per import.';
  }

  @override
  String get importMappingTitle => 'Asociază coloanele';

  @override
  String get importMappingIntro =>
      'Coloanele recunoscute sunt deja asociate. Codul articolului și denumirea sunt obligatorii.';

  @override
  String get importColumnNone => '— Ignoră —';

  @override
  String get importFieldName => 'Denumire';

  @override
  String get importFieldStock => 'Stoc (m)';

  @override
  String importSummary(int valid, int invalid) {
    return '$valid rânduri pregătite · $invalid cu erori';
  }

  @override
  String get importErrorsTitle => 'Rânduri cu erori (neimportate)';

  @override
  String importLine(int line) {
    return 'Rândul $line';
  }

  @override
  String importRun(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Importă $count referințe',
      one: 'Importă 1 referință',
    );
    return '$_temp0';
  }

  @override
  String importRunning(int done, int total) {
    return 'Import în curs… $done/$total';
  }

  @override
  String get importDoneTitle => 'Import finalizat';

  @override
  String importDone(int inserted, int updated) {
    return '$inserted create · $updated actualizate';
  }

  @override
  String importServerRejected(String message) {
    return 'Respinsă de server: $message';
  }

  @override
  String get importAgain => 'Importă alt fișier';

  @override
  String get backToCatalog => 'Înapoi la catalog';

  @override
  String importFileName(String name) {
    return 'Fișier: $name';
  }

  @override
  String get issueMissingCode => 'Lipsește codul articolului';

  @override
  String get issueMissingName => 'Lipsește denumirea';

  @override
  String issueComposition(String value) {
    return 'Compoziție ilizibilă sau diferită de 100 %: „$value”';
  }

  @override
  String issueNumber(String field, String value) {
    return '$field: valoare nevalidă „$value”';
  }

  @override
  String issueColor(String value) {
    return 'Culoare nevalidă „$value” (format #RRGGBB)';
  }

  @override
  String issueDuplicate(String value) {
    return 'Codul „$value” apare de mai multe ori în fișier';
  }

  @override
  String get adminOrgKind => 'Tipul organizației';

  @override
  String get adminNewOrg => 'Organizație nouă';

  @override
  String get adminOrgNameGeneric => 'Numele organizației';

  @override
  String get scanTitle => 'Scanează o mostră';

  @override
  String get scanIntro =>
      'Fotografiază eticheta mostrei, dreaptă și clară. Filyxa citește compoziția, gramajul, lățimea, întreținerea și codul articolului; tu verifici înainte de salvare.';

  @override
  String get scanTakePhoto => 'Fă o fotografie';

  @override
  String get scanImportPhoto => 'Importă o fotografie';

  @override
  String get scanReading => 'Se citește eticheta…';

  @override
  String scanUsage(int scans, int quota) {
    return '$scans / $quota scanări luna aceasta';
  }

  @override
  String scanQuotaWarning(int percent) {
    return 'S-a folosit $percent % din cota lunară de scanări.';
  }

  @override
  String get scanQuotaExhausted =>
      'Cota lunară de scanări a fost atinsă. Introducerea manuală rămâne posibilă.';

  @override
  String get scanFailureNotLabel =>
      'Nicio etichetă textilă lizibilă în această fotografie. Refă-o mai de aproape, dreaptă, fără reflexii.';

  @override
  String get scanFailureRefused =>
      'Analiza acestei imagini a fost refuzată. Încearcă o altă fotografie.';

  @override
  String get scanFailureAi =>
      'Serviciul de citire este momentan indisponibil. Încearcă din nou în câteva clipe.';

  @override
  String get scanFailureImage =>
      'Această imagine nu este acceptată (JPEG, PNG sau WebP, maximum 5 MB).';

  @override
  String get prefillBanner =>
      'Fișă precompletată de scanare. Verifică câmpurile semnalate înainte de salvare.';

  @override
  String get fieldUncertain => 'Citit cu puțină certitudine: de verificat';

  @override
  String get sectionUncertain => 'Citire incertă: verifică această secțiune.';

  @override
  String duplicateFound(String name) {
    return 'Există deja un material cu acest cod de articol: „$name”.';
  }

  @override
  String get duplicateOpen => 'Deschide fișa existentă';

  @override
  String get matchTitle => 'Aceasta este referința?';

  @override
  String matchIntro(String supplier) {
    return 'Găsită în catalogul $supplier. Confirmă pentru a lega fișa de datele și disponibilitatea ei.';
  }

  @override
  String get matchConfirm => 'Da, leagă această referință';

  @override
  String get matchOthers => 'Alte referințe apropiate';

  @override
  String get matchNone => 'Niciuna dintre aceste referințe';

  @override
  String get supplierData => 'Datele furnizorului';

  @override
  String get supplierDataHelp =>
      'Actualizate de furnizor, nu pot fi modificate aici.';

  @override
  String get referenceRetiredBanner =>
      'Referință retrasă de furnizor. Ultimele valori cunoscute sunt păstrate.';

  @override
  String get linkToSupplier => 'Leagă de o referință a furnizorului';

  @override
  String get linkSearchHint => 'Cod articol, denumire sau furnizor';

  @override
  String get linkSearchEmpty => 'Nicio referință publicată nu corespunde.';

  @override
  String get linkConfirm => 'Leagă';

  @override
  String get unlink => 'Dezleagă referința';

  @override
  String get unlinkConfirmBody =>
      'Fișa își păstrează valorile actuale și devine din nou modificabilă. Nu va mai urma actualizările furnizorului.';

  @override
  String get linkedDone => 'Fișă legată de furnizor.';

  @override
  String get unlinkedDone => 'Fișă dezlegată de furnizor.';

  @override
  String get privateLayer => 'Informațiile atelierului';

  @override
  String get privateLayerHelp => 'Vizibile doar pentru atelierul tău.';

  @override
  String get fieldPrice => 'Preț negociat (€/m)';

  @override
  String get fieldTags => 'Etichete';

  @override
  String get fieldTagsHint => 'Separate prin virgulă (ex. TI27, de validat)';

  @override
  String priceValue(String value) {
    return '$value €/m';
  }

  @override
  String get atelierImportTitle => 'Importă baza atelierului';

  @override
  String get atelierImportHelp =>
      'Fișier .xlsx sau .csv, un rând pe material și un rând de antet. Maximum 5.000 de rânduri. Un material deja existent (același furnizor și cod, sau același nume și culoare) este actualizat, niciodată dublat.';

  @override
  String get atelierImportMappingIntro =>
      'Coloanele recunoscute sunt deja asociate. Doar numele materialului este obligatoriu.';

  @override
  String atelierImportRun(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Importă $count materiale',
      one: 'Importă 1 material',
    );
    return '$_temp0';
  }

  @override
  String atelierImportDone(int imported, int linked, int pending, int errors) {
    return '$imported importate · $linked legate de un furnizor · $pending de confirmat · $errors cu erori';
  }

  @override
  String atelierImportDetail(int inserted, int updated) {
    return 'dintre care $inserted noi și $updated actualizate';
  }

  @override
  String get backToLibrary => 'Înapoi la TissuTech';

  @override
  String reviewLinksAction(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Confirmă $count potriviri',
      one: 'Confirmă 1 potrivire',
    );
    return '$_temp0';
  }

  @override
  String pendingLinksBanner(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count materiale importate seamănă cu referințe de furnizor.',
      one: '1 material importat seamănă cu o referință de furnizor.',
    );
    return '$_temp0';
  }

  @override
  String get reviewTitle => 'Potriviri de confirmat';

  @override
  String reviewProgress(int index, int total) {
    return '$index din $total';
  }

  @override
  String get reviewIntro =>
      'Fișa dvs. seamănă cu o referință publicată. Confirmați pentru a o lega de datele și disponibilitatea ei.';

  @override
  String get reviewSkip => 'Mai târziu';

  @override
  String get reviewDone => 'Toate potrivirile au fost tratate.';

  @override
  String get reviewNoCandidate =>
      'Nicio referință publicată nu mai corespunde acestui material.';

  @override
  String get reviewOpen => 'Revizuiește';

  @override
  String get reportAction => 'Semnalează o eroare';

  @override
  String get reportTitle => 'Semnalează o eroare furnizorului';

  @override
  String get reportIntro =>
      'Furnizorul va corecta fișa pentru toate atelierele. Nu vede numele atelierului dvs., decât dacă alegeți să-l partajați.';

  @override
  String get reportField => 'Câmp';

  @override
  String get reportObserved => 'Valoare constatată';

  @override
  String get reportObservedHint => 'Ex. 300 g/m² măsurate pe mostră';

  @override
  String get reportComment => 'Comentariu (opțional)';

  @override
  String get reportShareIdentity =>
      'Partajează numele atelierului meu cu furnizorul';

  @override
  String get reportSend => 'Trimite';

  @override
  String get reportSent => 'Semnalare trimisă furnizorului.';

  @override
  String get reportFieldAvailability => 'Disponibilitate';

  @override
  String get reportFieldOther => 'Altul';

  @override
  String get reportsSection => 'Semnalări';

  @override
  String get reportStatusOpen => 'Deschisă';

  @override
  String get reportStatusFixed => 'Corectată';

  @override
  String get reportStatusRejected => 'Respinsă';

  @override
  String reportObservedLine(String value) {
    return 'Constatat: $value';
  }

  @override
  String reportReasonLine(String reason) {
    return 'Motiv: $reason';
  }

  @override
  String reportResponseLine(String response) {
    return 'Răspuns: $response';
  }

  @override
  String get supplierReportsTitle => 'Semnalări de la ateliere';

  @override
  String supplierReportsButton(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count semnalări deschise',
      one: '1 semnalare deschisă',
      zero: 'Semnalări',
    );
    return '$_temp0';
  }

  @override
  String get supplierReportsEmpty => 'Nicio semnalare deocamdată.';

  @override
  String get reportAnonymous => 'Atelier anonim';

  @override
  String get reportMarkFixed => 'Marchează corectată';

  @override
  String get reportReject => 'Respinge';

  @override
  String get reportRejectTitle => 'Respinge semnalarea';

  @override
  String get reportRejectReason => 'Motivul respingerii';

  @override
  String get reportFixTitle => 'Marchează ca fiind corectată';

  @override
  String get reportFixHelp =>
      'Nu uitați să corectați referința în catalog: atelierele legate o vor vedea imediat.';

  @override
  String get reportFixMessage => 'Mesaj către atelier (opțional)';

  @override
  String get reportEditReference => 'Deschide referința';

  @override
  String get reportFilterOpen => 'Deschise';

  @override
  String get reportFilterAll => 'Toate';

  @override
  String get notificationsTitle => 'Notificări';

  @override
  String get notificationsEmpty => 'Nicio notificare.';

  @override
  String notificationsTooltip(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Notificări ($count necitite)',
      one: 'Notificări (1 necitită)',
      zero: 'Notificări',
    );
    return '$_temp0';
  }

  @override
  String notifReportNew(String code, String field) {
    return 'Semnalare nouă pentru $code · $field';
  }

  @override
  String notifReportFixed(String name, String field) {
    return '$name: furnizorul a corectat „$field”';
  }

  @override
  String notifReportRejected(String name, String field) {
    return '$name: semnalarea pentru „$field” a fost respinsă';
  }

  @override
  String get studioNewCollection => 'Colecție nouă';

  @override
  String get studioCollectionName => 'Numele colecției';

  @override
  String get studioCollectionHint => 'Ex. TI27';

  @override
  String get studioEmptyTitle => 'Nicio colecție deocamdată';

  @override
  String get studioEmptyEditor =>
      'Creați o colecție pentru a grupa modelele unui sezon, de exemplu „TI27”.';

  @override
  String get studioEmptyViewer =>
      'Editorii atelierului dvs. nu au creat încă nicio colecție.';

  @override
  String studioModelCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count modele',
      one: '1 model',
      zero: 'Niciun model',
    );
    return '$_temp0';
  }

  @override
  String get collectionEmptyTitle => 'Această colecție este goală';

  @override
  String get collectionEmptyEditor =>
      'Adăugați un prim model: îmbrăcăminte, încălțăminte, marochinărie sau accesoriu.';

  @override
  String get collectionEmptyViewer =>
      'Niciun model în această colecție deocamdată.';

  @override
  String get studioNewModel => 'Model nou';

  @override
  String get modelName => 'Numele modelului';

  @override
  String get modelReference => 'Referință (opțional)';

  @override
  String get modelType => 'Tip de produs';

  @override
  String get productGarment => 'Îmbrăcăminte';

  @override
  String get productFootwear => 'Încălțăminte';

  @override
  String get productLeatherGoods => 'Marochinărie';

  @override
  String get productAccessory => 'Accesoriu';

  @override
  String colorwayCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count culori',
      one: '1 culoare',
    );
    return '$_temp0';
  }

  @override
  String bomLineCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count materiale',
      one: '1 material',
      zero: 'niciun material',
    );
    return '$_temp0';
  }

  @override
  String get rename => 'Redenumește';

  @override
  String get create => 'Creează';

  @override
  String get add => 'Adaugă';

  @override
  String deleteCollectionTitle(String name) {
    return 'Ștergeți colecția „$name”?';
  }

  @override
  String get deleteCollectionBody =>
      'Modelele, culorile și cantitățile sale vor fi șterse definitiv. Materialele din TissuTech sunt păstrate.';

  @override
  String deleteModelTitle(String name) {
    return 'Ștergeți modelul „$name”?';
  }

  @override
  String get deleteModelBody =>
      'Culorile și lista de materiale vor fi șterse definitiv. Materialele din TissuTech sunt păstrate.';

  @override
  String get wasteLabel => 'Marjă de pierdere (%)';

  @override
  String get quantityLabel => 'Cantitate planificată (bucăți)';

  @override
  String get addColorway => 'Adaugă o culoare';

  @override
  String get declineColorways => 'Declină în culori';

  @override
  String get colorwayCurrent => 'Culoarea actuală';

  @override
  String get colorwayNew => 'Culoare nouă';

  @override
  String get colorwayNameHint => 'Ex. Negru';

  @override
  String colorwayDefault(int index) {
    return 'Culoarea $index';
  }

  @override
  String colorwayCopyHelp(String name) {
    return 'Noua culoare preia materialele din „$name”: schimbați doar ce diferă.';
  }

  @override
  String get deleteColorway => 'Șterge această culoare';

  @override
  String get addMaterial => 'Adaugă un material';

  @override
  String get modelEmptyTitle => 'Niciun material în acest model';

  @override
  String get modelEmptyEditor =>
      'Adăugați materialele modelului și consumul pe bucată pentru a calcula necesarul.';

  @override
  String get modelEmptyViewer =>
      'Niciun material nu a fost încă asociat acestui model.';

  @override
  String get bomRoleLabel => 'Rol';

  @override
  String get roleOther => 'Alt rol…';

  @override
  String get roleCustom => 'Numele rolului';

  @override
  String get role_main => 'Material principal';

  @override
  String get role_lining => 'Căptușeală';

  @override
  String get role_interfacing => 'Întăritură';

  @override
  String get role_contrast => 'Material de contrast';

  @override
  String get role_pocketing => 'Buzunare';

  @override
  String get role_rib => 'Bord-coastă';

  @override
  String get role_upper => 'Fețe';

  @override
  String get role_sock_lining => 'Branț de curățenie';

  @override
  String get role_insole => 'Branț de montaj';

  @override
  String get role_outsole => 'Talpă';

  @override
  String get role_reinforcement => 'Ranforsare';

  @override
  String get role_exterior => 'Exterior';

  @override
  String get role_gusset => 'Burduf';

  @override
  String get role_strap => 'Mâner sau curea';

  @override
  String get role_trim => 'Garnitură';

  @override
  String get consumptionLabel => 'Consum (m/bucată)';

  @override
  String requirementLine(String value) {
    return 'Necesar: $value m';
  }

  @override
  String get requirementTitle => 'Necesar total pe material';

  @override
  String requirementFormula(String waste) {
    return 'Consum × cantitate × (1 + pierdere de $waste %)';
  }

  @override
  String get pickMaterial => 'Alegeți un material';

  @override
  String get pickMaterialSearch => 'Căutați în TissuTech';

  @override
  String get pickMaterialEmpty => 'Niciun material nu corespunde.';

  @override
  String get pickMaterialLibraryEmpty =>
      'Adăugați mai întâi materiale în TissuTech.';

  @override
  String get removeLine => 'Elimină acest material';

  @override
  String get materialMissing => 'Material șters din TissuTech';

  @override
  String get alertsTitle => 'Alerte';

  @override
  String get alertsNone =>
      'Nicio alertă: materialele modelului sunt compatibile, iar stocul este suficient.';

  @override
  String alertsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count alerte',
      one: '1 alertă',
    );
    return '$_temp0';
  }

  @override
  String get alertFamilyCare => 'Întreținere';

  @override
  String get alertFamilyTechnical => 'Tehnic';

  @override
  String get alertFamilyCertification => 'Certificări';

  @override
  String get alertFamilyStock => 'Stoc';

  @override
  String alertQuoted(String name) {
    return '„$name”';
  }

  @override
  String get alertNoIron => 'nicio călcare';

  @override
  String get alertNoMainTitle => 'Niciun material principal';

  @override
  String get alertNoMainBody =>
      'Desemnați materialul principal pentru a activa toate verificările.';

  @override
  String get alertLiningHeavierTitle =>
      'Căptușeală mai grea decât materialul principal';

  @override
  String alertLiningHeavierBody(String lining, String main) {
    return '$lining depășește $main: căptușeala poate deforma produsul.';
  }

  @override
  String get alertStretchTitle => 'Material elastic, căptușeală rigidă';

  @override
  String alertStretchBody(String main, String lining) {
    return '$main conține elastan, dar $lining nu: prevedeți lărgime sau o căptușeală elastică.';
  }

  @override
  String get alertInterfacingHeavierTitle => 'Întăritură prea grea';

  @override
  String alertInterfacingHeavierBody(String interfacing, String main) {
    return '$interfacing este mai grea decât $main: risc de rigiditate și transparență.';
  }

  @override
  String get alertFusingTitle => 'Termolipire riscantă';

  @override
  String alertFusingBody(String main, String iron) {
    return '$main suportă cel mult $iron: alegeți o întăritură de cusut sau la temperatură joasă.';
  }

  @override
  String get alertConsumptionTitle => 'Consum necompletat';

  @override
  String alertConsumptionBody(String materials) {
    return '$materials: necesarul nu poate fi calculat.';
  }

  @override
  String get alertCareConflictTitle => 'Întreținere incompatibilă';

  @override
  String alertCareConflictBody(String details) {
    return '$details. Eticheta produsului va trebui să impună întreținerea cea mai restrictivă.';
  }

  @override
  String alertWashTitle(int temp) {
    return 'Spălare limitată la $temp °C';
  }

  @override
  String alertIronTitle(String iron) {
    return 'Călcare limitată: $iron';
  }

  @override
  String get alertTumbleTitle => 'Evitați uscătorul';

  @override
  String alertLimitBody(String details) {
    return '$details. Produsul finit urmează materialul cel mai delicat.';
  }

  @override
  String alertCertTitle(String cert) {
    return '$cert nerespectată pe tot produsul';
  }

  @override
  String alertCertBody(String certified, String cert, String missing) {
    return '$certified este certificat $cert, dar $missing nu: produsul finit nu va putea revendica $cert.';
  }

  @override
  String get alertRetiredTitle => 'Referință retrasă de furnizor';

  @override
  String alertRetiredBody(String material, String need, String atelier) {
    return '$material nu mai este oferit: necesar $need, stoc atelier $atelier.';
  }

  @override
  String get alertAtelierShortTitle => 'Stoc atelier insuficient';

  @override
  String alertAtelierShortBody(
    String material,
    String need,
    String atelier,
    String missing,
  ) {
    return '$material: necesar $need, stoc atelier $atelier. Lipsesc $missing.';
  }

  @override
  String get alertCoveredTitle => 'De comandat la furnizor';

  @override
  String alertCoveredBody(
    String material,
    String need,
    String atelier,
    String missing,
  ) {
    return '$material: necesar $need, stoc atelier $atelier. Restul ($missing) este disponibil la furnizor.';
  }

  @override
  String alertCoveredBodyExact(
    String material,
    String need,
    String atelier,
    String missing,
    String supplier,
  ) {
    return '$material: necesar $need, stoc atelier $atelier. Restul ($missing) este disponibil la furnizor ($supplier în stoc).';
  }

  @override
  String get alertSupplierShortTitle => 'Stoc furnizor insuficient';

  @override
  String alertSupplierShortBody(
    String material,
    String missing,
    String atelier,
    String supplier,
  ) {
    return '$material: lipsesc $missing după stocul atelierului ($atelier), iar furnizorul are doar $supplier.';
  }

  @override
  String get alertSupplierLowTitle => 'Stoc redus la furnizor';

  @override
  String alertSupplierLowBody(String material, String missing, String atelier) {
    return '$material: lipsesc $missing după stocul atelierului ($atelier), iar furnizorul are stoc redus.';
  }

  @override
  String get alertOnOrderTitle => 'La comandă la furnizor';

  @override
  String alertOnOrderBody(
    String material,
    String missing,
    String atelier,
    int weeks,
  ) {
    return '$material: lipsesc $missing după stocul atelierului ($atelier). Termen de reaprovizionare: $weeks săptămâni.';
  }

  @override
  String get alertOutTitle => 'Stoc epuizat la furnizor';

  @override
  String alertOutBody(String material, String missing, String atelier) {
    return '$material: lipsesc $missing după stocul atelierului ($atelier), iar furnizorul nu mai are stoc.';
  }

  @override
  String get alertHiddenTitle => 'Disponibilitate necomunicată';

  @override
  String alertHiddenBody(String material, String missing, String atelier) {
    return '$material: lipsesc $missing după stocul atelierului ($atelier). Furnizorul nu își publică stocul: contactați-l.';
  }

  @override
  String notifStockLow(String name, String code) {
    return '$name: stoc redus la furnizor ($code)';
  }

  @override
  String notifStockOut(String name, String code) {
    return '$name: stoc epuizat la furnizor ($code)';
  }

  @override
  String notifReferenceUpdated(String name, String code) {
    return '$name: fișă modificată de furnizor ($code)';
  }

  @override
  String notifReferenceRetired(String name, String code) {
    return '$name: referință retrasă de furnizor ($code)';
  }

  @override
  String notifUsedIn(String models) {
    return 'Folosit în: $models';
  }

  @override
  String get exportPdf => 'Exportă în PDF';

  @override
  String get exportDossier => 'Exportă dosarul PDF';

  @override
  String get pdfLanguage => 'Limba PDF';

  @override
  String get pdfMaterialSheet => 'Fișă material';

  @override
  String get pdfModelDossier => 'Dosar materiale';

  @override
  String get pdfCollectionDossier => 'Dosarul de materiale al colecției';

  @override
  String pdfEditedOn(String date) {
    return 'Emis la $date';
  }

  @override
  String get pdfNotSet => 'Necompletat';

  @override
  String get pdfCompositionNote =>
      'Compoziție exprimată conform Regulamentului (UE) nr. 1007/2011. Caracteristici orientative, de validat pe mostră.';

  @override
  String get pdfSupplierData => 'Date furnizor';

  @override
  String pdfPage(int page, int total) {
    return 'Pagina $page / $total';
  }

  @override
  String get pdfContents => 'Cuprins';

  @override
  String get pdfMaterial => 'Material';

  @override
  String get pdfConsumption => 'Consum/buc.';

  @override
  String get pdfNeed => 'Necesar';

  @override
  String get pdfGenerationError =>
      'PDF-ul nu a putut fi generat. Încercați din nou.';

  @override
  String get shareAction => 'Partajează';

  @override
  String get shareTitle => 'Partajează doar pentru citire';

  @override
  String get shareIntro =>
      'Destinatarul deschide linkul fără cont și vede fișe mereu actualizate, fără prețuri, note sau stocul atelierului.';

  @override
  String get shareLanguage => 'Limba paginii';

  @override
  String get shareValidity => 'Valabilitate (zile)';

  @override
  String get shareCreate => 'Creează linkul';

  @override
  String get shareCopy => 'Copiază linkul';

  @override
  String get shareCopied => 'Link copiat.';

  @override
  String shareExpires(String date) {
    return 'Expiră la $date';
  }

  @override
  String get shareRevoke => 'Revocă';

  @override
  String get shareRevokeConfirm =>
      'Revocați acest link? Nu va mai funcționa imediat.';

  @override
  String get shareRevoked => 'Link revocat.';

  @override
  String get shareExtend => 'Modifică expirarea';

  @override
  String get shareActiveLinks => 'Linkuri active';

  @override
  String get shareNone => 'Niciun link activ.';

  @override
  String get shareLinksTitle => 'Linkuri partajate';

  @override
  String get shareScopeMaterial => 'Material';

  @override
  String get shareScopeModel => 'Model';

  @override
  String get shareScopeCollection => 'Colecție';

  @override
  String get shareUnknownTarget => 'Element șters';

  @override
  String sharedFrom(String org) {
    return 'Partajat de $org';
  }

  @override
  String sharedReadOnly(String date) {
    return 'Doar citire · date actualizate · link valabil până la $date';
  }

  @override
  String get sharedExpiredTitle => 'Acest link a expirat';

  @override
  String sharedExpiredBody(String date) {
    return 'Nu mai este valabil din $date. Cereți un link nou atelierului care vi l-a trimis.';
  }

  @override
  String get sharedRevokedTitle => 'Acest link a fost revocat';

  @override
  String get sharedRevokedBody =>
      'Atelierul l-a dezactivat. Cereți-i un link nou dacă este nevoie.';

  @override
  String get sharedNotFoundTitle => 'Link negăsit';

  @override
  String get sharedNotFoundBody =>
      'Verificați adresa sau cereți un link nou atelierului.';

  @override
  String get sharedError =>
      'Pagina nu a putut fi încărcată. Verificați conexiunea și încercați din nou.';

  @override
  String get adminPlan => 'Plan';

  @override
  String get plan_pilot => 'Pilot';

  @override
  String get plan_essential => 'Esențial';

  @override
  String get plan_pro => 'Pro';

  @override
  String get plan_custom => 'Personalizat';

  @override
  String get adminQuota => 'Cotă lunară de scanări';

  @override
  String get adminQuotaHint => 'Gol: cota planului';

  @override
  String adminScans(int scans, int quota) {
    return '$scans / $quota scanări';
  }

  @override
  String adminItemsAtelier(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count materiale',
      one: '1 material',
      zero: 'niciun material',
    );
    return '$_temp0';
  }

  @override
  String adminItemsSupplier(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count referințe',
      one: '1 referință',
      zero: 'nicio referință',
    );
    return '$_temp0';
  }

  @override
  String adminTokens(String input, String output) {
    return 'Tokeni: $input intrare · $output ieșire';
  }

  @override
  String adminCost(String cost) {
    return 'Cost IA estimat: $cost';
  }

  @override
  String adminTotalCost(String cost) {
    return 'Cost IA al lunii, toate organizațiile: $cost';
  }

  @override
  String get adminEditPlan => 'Modifică planul';

  @override
  String get adminPlanSaved =>
      'Plan actualizat: noua cotă se aplică imediat scanerului.';

  @override
  String get adminPricingTitle =>
      'Tariful modelului IA (\$ pe milion de tokeni)';

  @override
  String get adminPricingInput => 'Intrare';

  @override
  String get adminPricingOutput => 'Ieșire';

  @override
  String get adminPreviousMonth => 'Luna anterioară';

  @override
  String get adminNextMonth => 'Luna următoare';

  @override
  String get proRequired => 'Funcție rezervată planului Pro.';

  @override
  String get proLocked => 'Disponibil cu planul Pro';

  @override
  String get modelStatusLabel => 'Stare';

  @override
  String get modelStatusIdea => 'Idee';

  @override
  String get modelStatusPrototype => 'Prototip';

  @override
  String get modelStatusValidated => 'Validat';

  @override
  String get modelStatusInProduction => 'În producție';

  @override
  String get modelStatusDelivered => 'Livrat';

  @override
  String get modelStatusAbandoned => 'Abandonat';

  @override
  String get modelStatusFinal => 'Un model livrat nu își mai schimbă starea.';

  @override
  String get deadlinesTitle => 'Termene';

  @override
  String get deadlineHelp =>
      'Data până la care modelul trebuie să atingă fiecare etapă.';

  @override
  String get deadlineNone => 'Fără termen';

  @override
  String get deadlineClear => 'Șterge termenul';

  @override
  String get deadlineOverdueTag => 'Întârziat';

  @override
  String get tabModels => 'Modele';

  @override
  String get tabPlanning => 'Planificare';

  @override
  String get planningEmpty =>
      'Niciun termen în această colecție. Stabilește-le din fiecare model.';

  @override
  String get planningNoDeadline => 'Fără termen';

  @override
  String planningNext(String stage, String date) {
    return '$stage prevăzut pe $date';
  }

  @override
  String notifDeadlineOverdue(String name, String stage, String date) {
    return 'Termen depășit: $name — $stage prevăzut pe $date';
  }

  @override
  String get sizesTitle => 'Mărimi';

  @override
  String get sizeChartLabel => 'Grilă de mărimi';

  @override
  String get sizeChartNone => 'Fără grilă (cantitate pe culoare)';

  @override
  String get sizeChartAlpha => 'XS–XXL';

  @override
  String get sizeChartEu => '34–48';

  @override
  String get sizeChartShoes => 'Numere 35–46';

  @override
  String get sizeChartOne => 'Mărime unică';

  @override
  String get sizeChartsTitle => 'Grile de mărimi';

  @override
  String get sizeChartsBuiltIn => 'Furnizate de Filyxa';

  @override
  String get sizeChartsMine => 'Grilele atelierului';

  @override
  String get sizeChartsMineEmpty => 'Nicio grilă proprie.';

  @override
  String get sizeChartNew => 'Grilă nouă';

  @override
  String get sizeChartEdit => 'Modifică grila';

  @override
  String get sizeChartName => 'Numele grilei';

  @override
  String get sizeChartSizes => 'Mărimi, în ordine, separate prin virgule';

  @override
  String get sizeChartChangeTitle => 'Schimbi grila?';

  @override
  String get sizeChartChangeBody =>
      'Cantitățile mărimilor absente din noua grilă vor fi șterse.';

  @override
  String get sizeChartChange => 'Schimbă';

  @override
  String get totalLabel => 'Total';

  @override
  String get sizeErrorInUse =>
      'O mărime cu cantități pe un model nu poate fi eliminată.';

  @override
  String get sizeErrorInvalid =>
      'Mărimile trebuie să fie distincte și nevide (max. 12 caractere).';

  @override
  String get sizeChartInUse =>
      'Grila este folosită de un model: nu poate fi ștearsă.';

  @override
  String get sizeChartDeleteTitle => 'Ștergi grila?';
}
