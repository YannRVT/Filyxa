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
}
