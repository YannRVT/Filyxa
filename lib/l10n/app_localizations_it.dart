// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get appTitle => 'Filyxa';

  @override
  String get navLibrary => 'TissuTech';

  @override
  String get navStudio => 'Studio';

  @override
  String get navScanner => 'Scanner';

  @override
  String get navSuppliers => 'Fornitori';

  @override
  String get navAccount => 'Account';

  @override
  String get comingSoonTitle => 'Presto disponibile';

  @override
  String get comingSoonBody =>
      'Questa sezione arriverà in una prossima versione di Filyxa.';

  @override
  String get emailLabel => 'E-mail';

  @override
  String get passwordLabel => 'Password';

  @override
  String get newPasswordLabel => 'Nuova password';

  @override
  String get confirmPasswordLabel => 'Conferma password';

  @override
  String get passwordHelper =>
      'Almeno 8 caratteri, con almeno una lettera e una cifra';

  @override
  String get codeLabel => 'Codice a 6 cifre';

  @override
  String get showPassword => 'Mostra password';

  @override
  String get hidePassword => 'Nascondi password';

  @override
  String get loginTitle => 'Accesso';

  @override
  String get loginSubtitle =>
      'Accedi alla libreria dei materiali del tuo atelier.';

  @override
  String get loginButton => 'Accedi';

  @override
  String get forgotPassword => 'Password dimenticata?';

  @override
  String get haveInvitation => 'Ho ricevuto un invito';

  @override
  String get devQuickLogin => 'Accesso rapido (dev)';

  @override
  String get inviteTitle => 'Unisciti al tuo team';

  @override
  String get inviteIntro =>
      'Inserisci la tua e-mail e il codice a 6 cifre ricevuto nell\'e-mail di invito.';

  @override
  String get verifyCode => 'Verifica il codice';

  @override
  String get resendCode => 'Ricevi un nuovo codice';

  @override
  String codeResent(String email) {
    return 'Se c\'è un invito in attesa per $email, è appena stato inviato un nuovo codice.';
  }

  @override
  String get choosePasswordTitle => 'Scegli la tua password';

  @override
  String choosePasswordIntro(String organization) {
    return 'Benvenuto in $organization. Scegli la password del tuo account.';
  }

  @override
  String get savePassword => 'Salva ed entra';

  @override
  String get invitationExpiredTitle => 'Invito scaduto';

  @override
  String get invitationExpiredBody =>
      'Questo invito è scaduto. Chiedi all\'amministratore del tuo atelier di inviartene uno nuovo.';

  @override
  String get invitationNotFound =>
      'Nessun invito in attesa per questo indirizzo. Verifica l\'e-mail utilizzata o chiedi un nuovo invito.';

  @override
  String get alreadyMember =>
      'Questo account appartiene già a un\'organizzazione.';

  @override
  String get backToLogin => 'Torna all\'accesso';

  @override
  String get resetTitle => 'Password dimenticata';

  @override
  String get resetIntro =>
      'Inserisci l\'e-mail del tuo account: riceverai un codice di reimpostazione.';

  @override
  String get sendCode => 'Invia il codice';

  @override
  String resetCodeSent(String email) {
    return 'Se esiste un account per $email, è appena stato inviato un codice a 6 cifre.';
  }

  @override
  String get resetButton => 'Cambia password';

  @override
  String get passwordChanged => 'Password modificata. Sei connesso.';

  @override
  String get errorEmailInvalid => 'Indirizzo e-mail non valido';

  @override
  String get errorPasswordShort => 'Almeno 8 caratteri';

  @override
  String get errorPasswordWeak => 'Almeno una lettera e una cifra';

  @override
  String get errorPasswordMismatch => 'Le password non corrispondono';

  @override
  String get errorCodeInvalid => 'Inserisci il codice a 6 cifre';

  @override
  String get errorBadCredentials => 'E-mail o password errata';

  @override
  String get errorCodeExpired =>
      'Codice errato o scaduto. Richiedine uno nuovo.';

  @override
  String get errorNetwork =>
      'Connessione impossibile. Controlla la rete e riprova.';

  @override
  String get errorTooManyRequests =>
      'Troppi tentativi. Attendi qualche minuto prima di riprovare.';

  @override
  String get errorForbidden => 'Azione riservata agli amministratori.';

  @override
  String get errorEmailNotSent =>
      'Impossibile inviare l\'e-mail. Riprova tra qualche minuto.';

  @override
  String get errorGeneric => 'Si è verificato un errore. Riprova.';

  @override
  String get errorOrgName => 'Tra 2 e 120 caratteri';

  @override
  String get retry => 'Riprova';

  @override
  String get cancel => 'Annulla';

  @override
  String get logout => 'Esci';

  @override
  String get accountTitle => 'Il mio account';

  @override
  String get languageLabel => 'Lingua';

  @override
  String get organizationLabel => 'Organizzazione';

  @override
  String get roleLabel => 'Ruolo';

  @override
  String get roleAdmin => 'Admin';

  @override
  String get roleEditor => 'Editor';

  @override
  String get roleViewer => 'Lettore';

  @override
  String get superadminConsole => 'Console super-admin';

  @override
  String get noOrgTitle => 'Nessuna organizzazione';

  @override
  String get noOrgBody =>
      'Il tuo account non è collegato a nessuna organizzazione. Chiedi un invito all\'amministratore del tuo atelier.';

  @override
  String get loadingError => 'Impossibile caricare il tuo spazio.';

  @override
  String get adminTitle => 'Console super-admin';

  @override
  String get adminNewAtelier => 'Nuovo atelier';

  @override
  String get adminEmpty =>
      'Nessuna organizzazione per ora. Crea il primo atelier pilota.';

  @override
  String get adminOrgName => 'Nome dell\'atelier';

  @override
  String get adminAdminEmail => 'E-mail del suo admin';

  @override
  String get adminCreate => 'Crea e invita';

  @override
  String adminCreated(String email) {
    return 'Atelier creato. Invito inviato a $email.';
  }

  @override
  String adminInvitePending(String email, String date) {
    return 'Invito in attesa: $email · scade il $date';
  }

  @override
  String adminInviteExpired(String email) {
    return 'Invito scaduto: $email';
  }

  @override
  String adminMembers(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count membri',
      one: '1 membro',
      zero: 'Nessun membro',
    );
    return '$_temp0';
  }

  @override
  String get adminReinvite => 'Invia di nuovo l\'invito';

  @override
  String adminReinvited(String email) {
    return 'Invito inviato di nuovo a $email.';
  }

  @override
  String get orgKindAtelier => 'Atelier';

  @override
  String get orgKindSupplier => 'Fornitore';

  @override
  String get missingConfig =>
      'Configurazione Supabase mancante. Copia env.example.json in env.json, compilalo, quindi esegui: flutter run --dart-define-from-file=env.json';

  @override
  String get membersEntry => 'Membri dell\'atelier';

  @override
  String get membersTitle => 'Membri';

  @override
  String get membersInvite => 'Invita';

  @override
  String get inviteDialogTitle => 'Invita un membro';

  @override
  String get inviteSend => 'Invia l\'invito';

  @override
  String get roleAdminHelp =>
      'Gestisce i membri e le impostazioni dell\'atelier';

  @override
  String get roleEditorHelp => 'Crea, modifica, scansiona, importa e condivide';

  @override
  String get roleViewerHelp => 'Consulta ed esporta, senza modificare nulla';

  @override
  String get youSuffix => 'tu';

  @override
  String get pendingInvitations => 'Inviti in attesa';

  @override
  String invitationExpiresOn(String date) {
    return 'Scade il $date';
  }

  @override
  String get invitationExpiredShort => 'Scaduto';

  @override
  String get resendInvitation => 'Invia di nuovo';

  @override
  String get cancelInvitation => 'Annulla l\'invito';

  @override
  String invitationSent(String email) {
    return 'Invito inviato a $email.';
  }

  @override
  String get invitationCanceled => 'Invito annullato.';

  @override
  String get changeRole => 'Cambia ruolo';

  @override
  String get roleChanged => 'Ruolo aggiornato.';

  @override
  String get removeMember => 'Rimuovi dall\'atelier';

  @override
  String removeConfirmTitle(String name) {
    return 'Rimuovere $name?';
  }

  @override
  String get removeConfirmBody =>
      'Questa persona perderà immediatamente l\'accesso ai dati dell\'atelier. Potrai invitarla di nuovo.';

  @override
  String get removeConfirm => 'Rimuovi';

  @override
  String get memberRemoved => 'Membro rimosso.';

  @override
  String get errorLastAdmin =>
      'L\'atelier deve mantenere almeno un admin. Nomina prima un altro admin.';

  @override
  String get lastAdminHint => 'Unico admin dell\'atelier';

  @override
  String memberActions(String name) {
    return 'Azioni per $name';
  }

  @override
  String get libraryNew => 'Nuovo materiale';

  @override
  String get viewGallery => 'Galleria';

  @override
  String get viewTable => 'Tabella';

  @override
  String get libraryEmptyTitle => 'Il tuo TissuTech è vuoto';

  @override
  String get libraryEmptyBody =>
      'Aggiungi i tuoi primi materiali: scansiona l\'etichetta di un campione, importa il tuo file Excel o inseriscili a mano.';

  @override
  String get libraryEmptyViewer =>
      'Nessun materiale per ora. Gli editor del tuo atelier possono aggiungerne.';

  @override
  String get actionScanSample => 'Scansiona un campione';

  @override
  String get actionImportExcel => 'Importa un file Excel';

  @override
  String get actionCreateManual => 'Inserisci a mano';

  @override
  String materialCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count materiali',
      one: '1 materiale',
      zero: 'Nessun materiale',
    );
    return '$_temp0';
  }

  @override
  String get colMaterial => 'Materiale';

  @override
  String get colReference => 'Riferimento';

  @override
  String get colComposition => 'Composizione';

  @override
  String get colWeight => 'g/m²';

  @override
  String get colWidth => 'Altezza';

  @override
  String get colStock => 'Stock atelier';

  @override
  String get fieldName => 'Nome del materiale';

  @override
  String get fieldSupplier => 'Fornitore';

  @override
  String get fieldSupplierCode => 'Codice articolo';

  @override
  String get fieldColorName => 'Colore';

  @override
  String get fieldColorHex => 'Colore (#RRGGBB)';

  @override
  String get photoAdd => 'Aggiungi una foto';

  @override
  String get photoChange => 'Cambia foto';

  @override
  String get photoRemove => 'Rimuovi foto';

  @override
  String get sectionIdentity => 'Identità';

  @override
  String get sectionColor => 'Colore e foto';

  @override
  String get sectionComposition => 'Composizione';

  @override
  String get sectionTechnical => 'Caratteristiche';

  @override
  String get sectionCare => 'Manutenzione';

  @override
  String get sectionUses => 'Usi e certificazioni';

  @override
  String get sectionStock => 'Stock atelier';

  @override
  String get sectionNotes => 'Note';

  @override
  String get addFiber => 'Aggiungi una fibra';

  @override
  String get removeFiber => 'Rimuovi questa fibra';

  @override
  String get fiberLabel => 'Fibra';

  @override
  String compositionTotal(String total) {
    return 'Totale: $total%';
  }

  @override
  String get compositionMustBe100 =>
      'Il totale deve essere 100%, senza fibre duplicate';

  @override
  String get fieldWeight => 'Grammatura (g/m²)';

  @override
  String get fieldWidth => 'Altezza (cm)';

  @override
  String get fieldWeave => 'Armatura';

  @override
  String get noneOption => 'Non indicato';

  @override
  String get fieldCertifications => 'Certificazioni';

  @override
  String get fieldUses => 'Usi';

  @override
  String get fieldStock => 'Metri in stock (m)';

  @override
  String get errorRequired => 'Campo obbligatorio';

  @override
  String errorNumberRange(int min, int max) {
    return 'Numero tra $min e $max';
  }

  @override
  String get errorHex => 'Formato atteso #RRGGBB (es. #2F4A6B)';

  @override
  String get save => 'Salva';

  @override
  String get materialSaved => 'Materiale salvato.';

  @override
  String get edit => 'Modifica';

  @override
  String get delete => 'Elimina';

  @override
  String deleteMaterialTitle(String name) {
    return 'Eliminare «$name»?';
  }

  @override
  String get deleteMaterialBody =>
      'Il materiale e la sua foto saranno eliminati definitivamente.';

  @override
  String get materialDeleted => 'Materiale eliminato.';

  @override
  String get editStock => 'Modifica stock';

  @override
  String get stockUpdated => 'Stock aggiornato.';

  @override
  String stockMeters(String value) {
    return '$value m';
  }

  @override
  String get materialNotFound =>
      'Questo materiale non esiste più o non è accessibile.';

  @override
  String get newMaterialTitle => 'Nuovo materiale';

  @override
  String get editMaterialTitle => 'Modifica il materiale';

  @override
  String get detailWeight => 'Grammatura';

  @override
  String get detailWidth => 'Altezza';

  @override
  String get photoUploadFailed => 'Impossibile caricare la foto. Riprova.';

  @override
  String get viewerReadOnly => 'Sola lettura';

  @override
  String get errorEditorsOnly =>
      'Azione riservata agli editor e agli admin dell\'atelier.';

  @override
  String get searchHint => 'Cerca: nome, codice, fornitore, colore, fibra…';

  @override
  String get clearSearch => 'Cancella la ricerca';

  @override
  String get filtersButton => 'Filtri';

  @override
  String get clearFilters => 'Cancella i filtri';

  @override
  String get showResults => 'Mostra i risultati';

  @override
  String get noResultsTitle => 'Nessun risultato';

  @override
  String get noResultsBody =>
      'Nessun materiale corrisponde alla ricerca o ai filtri.';

  @override
  String resultCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count risultati',
      one: '1 risultato',
      zero: 'Nessun risultato',
    );
    return '$_temp0';
  }

  @override
  String get filterFiber => 'Fibra';

  @override
  String get filterFiberAny => 'Tutte le fibre';

  @override
  String filterFiberMin(int pct) {
    return 'Almeno $pct%';
  }

  @override
  String get filterWeight => 'Grammatura';

  @override
  String get filterColor => 'Colore';

  @override
  String get filterInStock => 'Disponibile in atelier';

  @override
  String removeFilter(String label) {
    return 'Rimuovi il filtro $label';
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
  String get navCatalog => 'Catalogo';

  @override
  String get catalogEmptyTitle => 'Il tuo catalogo è vuoto';

  @override
  String get catalogEmptyBody =>
      'Importa il tuo catalogo da un file Excel o CSV esportato dal tuo gestionale.';

  @override
  String get catalogImport => 'Importa un file';

  @override
  String get catalogSettings => 'Disponibilità';

  @override
  String referenceCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count riferimenti',
      one: '1 riferimento',
      zero: 'Nessun riferimento',
    );
    return '$_temp0';
  }

  @override
  String get showRetired => 'Mostra i riferimenti ritirati';

  @override
  String get retiredBadge => 'Ritirato';

  @override
  String get colStatus => 'Disponibilità';

  @override
  String get colLeadTime => 'Tempi';

  @override
  String get statusAvailable => 'Disponibile';

  @override
  String get statusLow => 'Scorta bassa';

  @override
  String get statusOnOrder => 'Su ordinazione';

  @override
  String statusOnOrderWeeks(int weeks) {
    return 'Su ordinazione · $weeks sett.';
  }

  @override
  String get statusOutOfStock => 'Esaurito';

  @override
  String get statusHidden => 'Nascosta';

  @override
  String get modeExact => 'Quantità esatta';

  @override
  String get modeTiers => 'Fasce';

  @override
  String get modeHidden => 'Nascosta';

  @override
  String get modeExactHelp => 'Gli atelier vedono i metri esatti in stock.';

  @override
  String get modeTiersHelp =>
      'Gli atelier vedono solo: disponibile, scorta bassa, su ordinazione o esaurito.';

  @override
  String get modeHiddenHelp => 'Gli atelier non vedono la disponibilità.';

  @override
  String modeDefault(String mode) {
    return 'Impostazione generale ($mode)';
  }

  @override
  String get thresholdLabel => 'Soglia di scorta bassa (m)';

  @override
  String get thresholdHelp =>
      'Sotto questa quantità, il riferimento appare come «scorta bassa».';

  @override
  String get leadTimeLabel => 'Tempi di riassortimento (settimane)';

  @override
  String get leadTimeHelp => 'Mostrato quando il riferimento è su ordinazione.';

  @override
  String get availabilitySettingsTitle => 'Visualizzazione della disponibilità';

  @override
  String get availabilitySettingsIntro =>
      'Scegli cosa vedono gli atelier del tuo stock. Puoi regolare ogni riferimento dalla sua scheda.';

  @override
  String get settingsSaved => 'Impostazioni salvate.';

  @override
  String get referenceRetire => 'Ritira dal catalogo';

  @override
  String get referenceRestore => 'Rimetti nel catalogo';

  @override
  String get referenceRetired =>
      'Riferimento ritirato dal catalogo pubblicato.';

  @override
  String get referenceRestored => 'Riferimento rimesso nel catalogo.';

  @override
  String retireConfirmTitle(String code) {
    return 'Ritirare «$code»?';
  }

  @override
  String get retireConfirmBody =>
      'Gli atelier non la vedranno più. Chi la usa conserverà l\'ultima scheda. Potrai rimetterla nel catalogo.';

  @override
  String get referenceAvailabilityTitle =>
      'Disponibilità di questo riferimento';

  @override
  String get stockLabel => 'Stock';

  @override
  String whatAteliersSee(String value) {
    return 'Cosa vedono gli atelier: $value';
  }

  @override
  String get importTitle => 'Importa il catalogo';

  @override
  String get importPickFile => 'Scegli un file Excel o CSV';

  @override
  String get importPickHelp =>
      'File .xlsx o .csv, una riga per riferimento e una riga di intestazioni. Massimo 5.000 righe. Un riferimento già noto viene aggiornato tramite il suo codice.';

  @override
  String get importUnreadable =>
      'Impossibile leggere questo file. Salvalo in formato .xlsx o .csv e riprova.';

  @override
  String importTooMany(int count) {
    return 'Questo file contiene $count righe: massimo 5.000 per importazione.';
  }

  @override
  String get importMappingTitle => 'Associa le tue colonne';

  @override
  String get importMappingIntro =>
      'Le colonne riconosciute sono già associate. Codice articolo e descrizione sono obbligatori.';

  @override
  String get importColumnNone => '— Ignora —';

  @override
  String get importFieldName => 'Descrizione';

  @override
  String get importFieldStock => 'Stock (m)';

  @override
  String importSummary(int valid, int invalid) {
    return '$valid righe pronte · $invalid con errori';
  }

  @override
  String get importErrorsTitle => 'Righe con errori (non importate)';

  @override
  String importLine(int line) {
    return 'Riga $line';
  }

  @override
  String importRun(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Importa $count riferimenti',
      one: 'Importa 1 riferimento',
    );
    return '$_temp0';
  }

  @override
  String importRunning(int done, int total) {
    return 'Importazione in corso… $done/$total';
  }

  @override
  String get importDoneTitle => 'Importazione completata';

  @override
  String importDone(int inserted, int updated) {
    return '$inserted creati · $updated aggiornati';
  }

  @override
  String importServerRejected(String message) {
    return 'Rifiutata dal server: $message';
  }

  @override
  String get importAgain => 'Importa un altro file';

  @override
  String get backToCatalog => 'Torna al catalogo';

  @override
  String importFileName(String name) {
    return 'File: $name';
  }

  @override
  String get issueMissingCode => 'Codice articolo mancante';

  @override
  String get issueMissingName => 'Descrizione mancante';

  @override
  String issueComposition(String value) {
    return 'Composizione illeggibile o diversa da 100%: «$value»';
  }

  @override
  String issueNumber(String field, String value) {
    return '$field: valore non valido «$value»';
  }

  @override
  String issueColor(String value) {
    return 'Colore non valido «$value» (formato #RRGGBB)';
  }

  @override
  String issueDuplicate(String value) {
    return 'Codice «$value» presente più volte nel file';
  }

  @override
  String get adminOrgKind => 'Tipo di organizzazione';

  @override
  String get adminNewOrg => 'Nuova organizzazione';

  @override
  String get adminOrgNameGeneric => 'Nome dell\'organizzazione';

  @override
  String get scanTitle => 'Scansiona un campione';

  @override
  String get scanIntro =>
      'Fotografa l\'etichetta del campione, ben piatta e a fuoco. Filyxa legge composizione, grammatura, altezza, manutenzione e codice articolo; tu verifichi prima di salvare.';

  @override
  String get scanTakePhoto => 'Scatta una foto';

  @override
  String get scanImportPhoto => 'Importa una foto';

  @override
  String get scanReading => 'Lettura dell\'etichetta…';

  @override
  String scanUsage(int scans, int quota) {
    return '$scans / $quota scansioni questo mese';
  }

  @override
  String scanQuotaWarning(int percent) {
    return 'È stato utilizzato il $percent% della quota mensile di scansioni.';
  }

  @override
  String get scanQuotaExhausted =>
      'Quota mensile di scansioni raggiunta. L\'inserimento manuale resta possibile.';

  @override
  String get scanFailureNotLabel =>
      'Nessuna etichetta tessile leggibile in questa foto. Riprendila più da vicino, ben piatta, senza riflessi.';

  @override
  String get scanFailureRefused =>
      'L\'analisi di questa immagine è stata rifiutata. Prova un\'altra foto.';

  @override
  String get scanFailureAi =>
      'Il servizio di lettura è momentaneamente non disponibile. Riprova tra poco.';

  @override
  String get scanFailureImage =>
      'Questa immagine non è supportata (JPEG, PNG o WebP, massimo 5 MB).';

  @override
  String get prefillBanner =>
      'Scheda precompilata dalla scansione. Verifica i campi segnalati prima di salvare.';

  @override
  String get fieldUncertain => 'Letto con poca certezza: da verificare';

  @override
  String get sectionUncertain => 'Lettura incerta: verifica questa sezione.';

  @override
  String duplicateFound(String name) {
    return 'Esiste già un materiale con questo codice articolo: «$name».';
  }

  @override
  String get duplicateOpen => 'Apri la scheda esistente';

  @override
  String get matchTitle => 'È proprio questo riferimento?';

  @override
  String matchIntro(String supplier) {
    return 'Trovato nel catalogo di $supplier. Conferma per collegare la scheda ai suoi dati e alla sua disponibilità.';
  }

  @override
  String get matchConfirm => 'Sì, collega questo riferimento';

  @override
  String get matchOthers => 'Altri riferimenti simili';

  @override
  String get matchNone => 'Nessuno di questi riferimenti';

  @override
  String get supplierData => 'Dati del fornitore';

  @override
  String get supplierDataHelp =>
      'Aggiornati dal fornitore, non modificabili qui.';

  @override
  String get referenceRetiredBanner =>
      'Riferimento ritirato dal fornitore. Gli ultimi valori noti sono conservati.';

  @override
  String get linkToSupplier => 'Collega a un riferimento del fornitore';

  @override
  String get linkSearchHint => 'Codice articolo, descrizione o fornitore';

  @override
  String get linkSearchEmpty => 'Nessun riferimento pubblicato corrisponde.';

  @override
  String get linkConfirm => 'Collega';

  @override
  String get unlink => 'Scollega il riferimento';

  @override
  String get unlinkConfirmBody =>
      'La scheda conserva i valori attuali e torna modificabile. Non seguirà più gli aggiornamenti del fornitore.';

  @override
  String get linkedDone => 'Scheda collegata al fornitore.';

  @override
  String get unlinkedDone => 'Scheda scollegata dal fornitore.';

  @override
  String get privateLayer => 'Informazioni dell\'atelier';

  @override
  String get privateLayerHelp => 'Visibili solo al tuo atelier.';

  @override
  String get fieldPrice => 'Prezzo negoziato (€/m)';

  @override
  String get fieldTags => 'Etichette';

  @override
  String get fieldTagsHint => 'Separate da virgole (es. AI27, da approvare)';

  @override
  String priceValue(String value) {
    return '$value €/m';
  }

  @override
  String get atelierImportTitle => 'Importa l\'archivio del laboratorio';

  @override
  String get atelierImportHelp =>
      'File .xlsx o .csv, una riga per materiale e una riga di intestazioni. Massimo 5.000 righe. Un materiale già presente (stesso fornitore e codice, o stesso nome e colore) viene aggiornato, mai duplicato.';

  @override
  String get atelierImportMappingIntro =>
      'Le colonne riconosciute sono già associate. È obbligatorio solo il nome del materiale.';

  @override
  String atelierImportRun(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Importa $count materiali',
      one: 'Importa 1 materiale',
    );
    return '$_temp0';
  }

  @override
  String atelierImportDone(int imported, int linked, int pending, int errors) {
    return '$imported importati · $linked collegati a un fornitore · $pending da confermare · $errors con errori';
  }

  @override
  String atelierImportDetail(int inserted, int updated) {
    return 'di cui $inserted nuovi e $updated aggiornati';
  }

  @override
  String get backToLibrary => 'Torna a TissuTech';

  @override
  String reviewLinksAction(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Conferma $count corrispondenze',
      one: 'Conferma 1 corrispondenza',
    );
    return '$_temp0';
  }

  @override
  String pendingLinksBanner(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count materiali importati somigliano a riferimenti fornitore.',
      one: '1 materiale importato somiglia a un riferimento fornitore.',
    );
    return '$_temp0';
  }

  @override
  String get reviewTitle => 'Corrispondenze da confermare';

  @override
  String reviewProgress(int index, int total) {
    return '$index di $total';
  }

  @override
  String get reviewIntro =>
      'La tua scheda somiglia a un riferimento pubblicato. Conferma per collegarla ai suoi dati e alla disponibilità.';

  @override
  String get reviewSkip => 'Più tardi';

  @override
  String get reviewDone => 'Tutte le corrispondenze sono state gestite.';

  @override
  String get reviewNoCandidate =>
      'Nessun riferimento pubblicato corrisponde più a questo materiale.';

  @override
  String get reviewOpen => 'Gestisci';

  @override
  String get reportAction => 'Segnala un errore';

  @override
  String get reportTitle => 'Segnala un errore al fornitore';

  @override
  String get reportIntro =>
      'Il fornitore correggerà la scheda per tutti i laboratori. Non vede il nome del tuo laboratorio, a meno che tu non scelga di condividerlo.';

  @override
  String get reportField => 'Campo';

  @override
  String get reportObserved => 'Valore rilevato';

  @override
  String get reportObservedHint => 'Es. 300 g/m² misurati sul campione';

  @override
  String get reportComment => 'Commento (facoltativo)';

  @override
  String get reportShareIdentity =>
      'Condividi il nome del mio laboratorio con il fornitore';

  @override
  String get reportSend => 'Invia';

  @override
  String get reportSent => 'Segnalazione inviata al fornitore.';

  @override
  String get reportFieldAvailability => 'Disponibilità';

  @override
  String get reportFieldOther => 'Altro';

  @override
  String get reportsSection => 'Segnalazioni';

  @override
  String get reportStatusOpen => 'Aperta';

  @override
  String get reportStatusFixed => 'Corretta';

  @override
  String get reportStatusRejected => 'Respinta';

  @override
  String reportObservedLine(String value) {
    return 'Rilevato: $value';
  }

  @override
  String reportReasonLine(String reason) {
    return 'Motivo: $reason';
  }

  @override
  String reportResponseLine(String response) {
    return 'Risposta: $response';
  }

  @override
  String get supplierReportsTitle => 'Segnalazioni dei laboratori';

  @override
  String supplierReportsButton(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count segnalazioni aperte',
      one: '1 segnalazione aperta',
      zero: 'Segnalazioni',
    );
    return '$_temp0';
  }

  @override
  String get supplierReportsEmpty => 'Nessuna segnalazione per ora.';

  @override
  String get reportAnonymous => 'Laboratorio anonimo';

  @override
  String get reportMarkFixed => 'Segna come corretta';

  @override
  String get reportReject => 'Respingi';

  @override
  String get reportRejectTitle => 'Respingi la segnalazione';

  @override
  String get reportRejectReason => 'Motivo del rifiuto';

  @override
  String get reportFixTitle => 'Segna come corretta';

  @override
  String get reportFixHelp =>
      'Ricorda di correggere il riferimento nel catalogo: i laboratori collegati lo vedranno subito.';

  @override
  String get reportFixMessage => 'Messaggio al laboratorio (facoltativo)';

  @override
  String get reportEditReference => 'Apri il riferimento';

  @override
  String get reportFilterOpen => 'Aperte';

  @override
  String get reportFilterAll => 'Tutte';

  @override
  String get notificationsTitle => 'Notifiche';

  @override
  String get notificationsEmpty => 'Nessuna notifica.';

  @override
  String notificationsTooltip(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Notifiche ($count non lette)',
      one: 'Notifiche (1 non letta)',
      zero: 'Notifiche',
    );
    return '$_temp0';
  }

  @override
  String notifReportNew(String code, String field) {
    return 'Nuova segnalazione su $code · $field';
  }

  @override
  String notifReportFixed(String name, String field) {
    return '$name: il fornitore ha corretto «$field»';
  }

  @override
  String notifReportRejected(String name, String field) {
    return '$name: segnalazione su «$field» respinta';
  }

  @override
  String get studioNewCollection => 'Nuova collezione';

  @override
  String get studioCollectionName => 'Nome della collezione';

  @override
  String get studioCollectionHint => 'Es. AI27';

  @override
  String get studioEmptyTitle => 'Ancora nessuna collezione';

  @override
  String get studioEmptyEditor =>
      'Crea una collezione per raggruppare i modelli di una stagione, ad esempio «AI27».';

  @override
  String get studioEmptyViewer =>
      'Gli editor del tuo laboratorio non hanno ancora creato collezioni.';

  @override
  String studioModelCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count modelli',
      one: '1 modello',
      zero: 'Nessun modello',
    );
    return '$_temp0';
  }

  @override
  String get collectionEmptyTitle => 'Questa collezione è vuota';

  @override
  String get collectionEmptyEditor =>
      'Aggiungi un primo modello: abbigliamento, calzatura, pelletteria o accessorio.';

  @override
  String get collectionEmptyViewer =>
      'Ancora nessun modello in questa collezione.';

  @override
  String get studioNewModel => 'Nuovo modello';

  @override
  String get modelName => 'Nome del modello';

  @override
  String get modelReference => 'Riferimento (facoltativo)';

  @override
  String get modelType => 'Tipo di prodotto';

  @override
  String get productGarment => 'Abbigliamento';

  @override
  String get productFootwear => 'Calzatura';

  @override
  String get productLeatherGoods => 'Pelletteria';

  @override
  String get productAccessory => 'Accessorio';

  @override
  String colorwayCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count varianti colore',
      one: '1 variante colore',
    );
    return '$_temp0';
  }

  @override
  String bomLineCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count materiali',
      one: '1 materiale',
      zero: 'nessun materiale',
    );
    return '$_temp0';
  }

  @override
  String get rename => 'Rinomina';

  @override
  String get create => 'Crea';

  @override
  String get add => 'Aggiungi';

  @override
  String deleteCollectionTitle(String name) {
    return 'Eliminare la collezione «$name»?';
  }

  @override
  String get deleteCollectionBody =>
      'I suoi modelli, varianti e quantità saranno eliminati definitivamente. I materiali di TissuTech sono conservati.';

  @override
  String deleteModelTitle(String name) {
    return 'Eliminare il modello «$name»?';
  }

  @override
  String get deleteModelBody =>
      'Le sue varianti e la distinta materiali saranno eliminate definitivamente. I materiali di TissuTech sono conservati.';

  @override
  String get wasteLabel => 'Margine di scarto (%)';

  @override
  String get quantityLabel => 'Quantità prevista (pezzi)';

  @override
  String get addColorway => 'Aggiungi una variante';

  @override
  String get declineColorways => 'Declina in varianti colore';

  @override
  String get colorwayCurrent => 'Variante attuale';

  @override
  String get colorwayNew => 'Nuova variante';

  @override
  String get colorwayNameHint => 'Es. Nero';

  @override
  String colorwayDefault(int index) {
    return 'Variante $index';
  }

  @override
  String colorwayCopyHelp(String name) {
    return 'La nuova variante riprende i materiali di «$name»: basterà cambiare quelli diversi.';
  }

  @override
  String get deleteColorway => 'Elimina questa variante';

  @override
  String get addMaterial => 'Aggiungi un materiale';

  @override
  String get modelEmptyTitle => 'Nessun materiale in questo modello';

  @override
  String get modelEmptyEditor =>
      'Aggiungi i materiali del modello e il consumo per pezzo per calcolare il fabbisogno.';

  @override
  String get modelEmptyViewer =>
      'Nessun materiale è ancora associato a questo modello.';

  @override
  String get bomRoleLabel => 'Ruolo';

  @override
  String get roleOther => 'Altro ruolo…';

  @override
  String get roleCustom => 'Nome del ruolo';

  @override
  String get role_main => 'Tessuto principale';

  @override
  String get role_lining => 'Fodera';

  @override
  String get role_interfacing => 'Teletta';

  @override
  String get role_contrast => 'Tessuto a contrasto';

  @override
  String get role_pocketing => 'Tasche';

  @override
  String get role_rib => 'Costina';

  @override
  String get role_upper => 'Tomaia';

  @override
  String get role_sock_lining => 'Sottopiede';

  @override
  String get role_insole => 'Soletta di montaggio';

  @override
  String get role_outsole => 'Suola';

  @override
  String get role_reinforcement => 'Rinforzo';

  @override
  String get role_exterior => 'Esterno';

  @override
  String get role_gusset => 'Soffietto';

  @override
  String get role_strap => 'Manico o tracolla';

  @override
  String get role_trim => 'Guarnizione';

  @override
  String get consumptionLabel => 'Consumo (m/pezzo)';

  @override
  String requirementLine(String value) {
    return 'Fabbisogno: $value m';
  }

  @override
  String get requirementTitle => 'Fabbisogno totale per materiale';

  @override
  String requirementFormula(String waste) {
    return 'Consumo × quantità × (1 + scarto del $waste %)';
  }

  @override
  String get pickMaterial => 'Scegli un materiale';

  @override
  String get pickMaterialSearch => 'Cerca in TissuTech';

  @override
  String get pickMaterialEmpty => 'Nessun materiale corrispondente.';

  @override
  String get pickMaterialLibraryEmpty =>
      'Aggiungi prima dei materiali in TissuTech.';

  @override
  String get removeLine => 'Rimuovi questo materiale';

  @override
  String get materialMissing => 'Materiale eliminato da TissuTech';

  @override
  String get alertsTitle => 'Avvisi';

  @override
  String get alertsNone =>
      'Nessun avviso: i materiali del modello sono compatibili e lo stock è sufficiente.';

  @override
  String alertsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count avvisi',
      one: '1 avviso',
    );
    return '$_temp0';
  }

  @override
  String get alertFamilyCare => 'Manutenzione';

  @override
  String get alertFamilyTechnical => 'Tecnica';

  @override
  String get alertFamilyCertification => 'Certificazioni';

  @override
  String get alertFamilyStock => 'Stock';

  @override
  String alertQuoted(String name) {
    return '«$name»';
  }

  @override
  String get alertNoIron => 'nessuna stiratura';

  @override
  String get alertNoMainTitle => 'Nessun tessuto principale';

  @override
  String get alertNoMainBody =>
      'Indica il tessuto principale per attivare tutti i controlli.';

  @override
  String get alertLiningHeavierTitle =>
      'Fodera più pesante del tessuto principale';

  @override
  String alertLiningHeavierBody(String lining, String main) {
    return '$lining supera $main: la fodera rischia di deformare il prodotto.';
  }

  @override
  String get alertStretchTitle => 'Tessuto elasticizzato, fodera rigida';

  @override
  String alertStretchBody(String main, String lining) {
    return '$main contiene elastan ma $lining no: prevedi agio o una fodera elasticizzata.';
  }

  @override
  String get alertInterfacingHeavierTitle => 'Teletta troppo pesante';

  @override
  String alertInterfacingHeavierBody(String interfacing, String main) {
    return '$interfacing è più pesante di $main: rischio di rigidità e trasparenza.';
  }

  @override
  String get alertFusingTitle => 'Termoadesivazione rischiosa';

  @override
  String alertFusingBody(String main, String iron) {
    return '$main sopporta al massimo $iron: scegli una teletta da cucire o a bassa temperatura.';
  }

  @override
  String get alertConsumptionTitle => 'Consumo non inserito';

  @override
  String alertConsumptionBody(String materials) {
    return '$materials: il fabbisogno non può essere calcolato.';
  }

  @override
  String get alertCareConflictTitle => 'Manutenzioni incompatibili';

  @override
  String alertCareConflictBody(String details) {
    return '$details. L\'etichetta del prodotto dovrà indicare la manutenzione più restrittiva.';
  }

  @override
  String alertWashTitle(int temp) {
    return 'Lavaggio limitato a $temp °C';
  }

  @override
  String alertIronTitle(String iron) {
    return 'Stiratura limitata: $iron';
  }

  @override
  String get alertTumbleTitle => 'Evitare l\'asciugatrice';

  @override
  String alertLimitBody(String details) {
    return '$details. Il prodotto finito segue il materiale più delicato.';
  }

  @override
  String alertCertTitle(String cert) {
    return '$cert non rispettata su tutto il prodotto';
  }

  @override
  String alertCertBody(String certified, String cert, String missing) {
    return '$certified è certificato $cert, ma $missing no: il prodotto finito non potrà dichiarare $cert.';
  }

  @override
  String get alertRetiredTitle => 'Riferimento ritirato dal fornitore';

  @override
  String alertRetiredBody(String material, String need, String atelier) {
    return '$material non è più proposto: fabbisogno $need, stock laboratorio $atelier.';
  }

  @override
  String get alertAtelierShortTitle => 'Stock del laboratorio insufficiente';

  @override
  String alertAtelierShortBody(
    String material,
    String need,
    String atelier,
    String missing,
  ) {
    return '$material: fabbisogno $need, stock laboratorio $atelier. Mancano $missing.';
  }

  @override
  String get alertCoveredTitle => 'Da ordinare al fornitore';

  @override
  String alertCoveredBody(
    String material,
    String need,
    String atelier,
    String missing,
  ) {
    return '$material: fabbisogno $need, stock laboratorio $atelier. Il resto ($missing) è disponibile presso il fornitore.';
  }

  @override
  String alertCoveredBodyExact(
    String material,
    String need,
    String atelier,
    String missing,
    String supplier,
  ) {
    return '$material: fabbisogno $need, stock laboratorio $atelier. Il resto ($missing) è disponibile presso il fornitore ($supplier in stock).';
  }

  @override
  String get alertSupplierShortTitle => 'Stock del fornitore insufficiente';

  @override
  String alertSupplierShortBody(
    String material,
    String missing,
    String atelier,
    String supplier,
  ) {
    return '$material: mancano $missing dopo lo stock del laboratorio ($atelier) e il fornitore ne ha solo $supplier.';
  }

  @override
  String get alertSupplierLowTitle => 'Stock basso presso il fornitore';

  @override
  String alertSupplierLowBody(String material, String missing, String atelier) {
    return '$material: mancano $missing dopo lo stock del laboratorio ($atelier) e il fornitore ha stock basso.';
  }

  @override
  String get alertOnOrderTitle => 'Su ordinazione presso il fornitore';

  @override
  String alertOnOrderBody(
    String material,
    String missing,
    String atelier,
    int weeks,
  ) {
    return '$material: mancano $missing dopo lo stock del laboratorio ($atelier). Tempi di riassortimento: $weeks settimane.';
  }

  @override
  String get alertOutTitle => 'Esaurito presso il fornitore';

  @override
  String alertOutBody(String material, String missing, String atelier) {
    return '$material: mancano $missing dopo lo stock del laboratorio ($atelier) e il fornitore è esaurito.';
  }

  @override
  String get alertHiddenTitle => 'Disponibilità non comunicata';

  @override
  String alertHiddenBody(String material, String missing, String atelier) {
    return '$material: mancano $missing dopo lo stock del laboratorio ($atelier). Il fornitore non pubblica lo stock: contattalo.';
  }

  @override
  String notifStockLow(String name, String code) {
    return '$name: stock basso presso il fornitore ($code)';
  }

  @override
  String notifStockOut(String name, String code) {
    return '$name: esaurito presso il fornitore ($code)';
  }

  @override
  String notifReferenceUpdated(String name, String code) {
    return '$name: scheda modificata dal fornitore ($code)';
  }

  @override
  String notifReferenceRetired(String name, String code) {
    return '$name: riferimento ritirato dal fornitore ($code)';
  }

  @override
  String notifUsedIn(String models) {
    return 'Usato in: $models';
  }

  @override
  String get exportPdf => 'Esporta in PDF';

  @override
  String get exportDossier => 'Esporta il dossier PDF';

  @override
  String get pdfLanguage => 'Lingua del PDF';

  @override
  String get pdfMaterialSheet => 'Scheda materiale';

  @override
  String get pdfModelDossier => 'Dossier materiali';

  @override
  String get pdfCollectionDossier => 'Dossier materiali della collezione';

  @override
  String pdfEditedOn(String date) {
    return 'Emesso il $date';
  }

  @override
  String get pdfNotSet => 'Non indicato';

  @override
  String get pdfCompositionNote =>
      'Composizione espressa secondo il regolamento (UE) n. 1007/2011. Caratteristiche indicative, da verificare su campione.';

  @override
  String get pdfSupplierData => 'Dati del fornitore';

  @override
  String pdfPage(int page, int total) {
    return 'Pagina $page / $total';
  }

  @override
  String get pdfContents => 'Indice';

  @override
  String get pdfMaterial => 'Materiale';

  @override
  String get pdfConsumption => 'Consumo/pezzo';

  @override
  String get pdfNeed => 'Fabbisogno';

  @override
  String get pdfGenerationError =>
      'Non è stato possibile generare il PDF. Riprova.';

  @override
  String get shareAction => 'Condividi';

  @override
  String get shareTitle => 'Condividi in sola lettura';

  @override
  String get shareIntro =>
      'Il destinatario apre il link senza account e vede schede sempre aggiornate, senza prezzi, note né stock del laboratorio.';

  @override
  String get shareLanguage => 'Lingua della pagina';

  @override
  String get shareValidity => 'Validità (giorni)';

  @override
  String get shareCreate => 'Crea il link';

  @override
  String get shareCopy => 'Copia il link';

  @override
  String get shareCopied => 'Link copiato.';

  @override
  String shareExpires(String date) {
    return 'Scade il $date';
  }

  @override
  String get shareRevoke => 'Revoca';

  @override
  String get shareRevokeConfirm =>
      'Revocare questo link? Smetterà subito di funzionare.';

  @override
  String get shareRevoked => 'Link revocato.';

  @override
  String get shareExtend => 'Modifica la scadenza';

  @override
  String get shareActiveLinks => 'Link attivi';

  @override
  String get shareNone => 'Nessun link attivo.';

  @override
  String get shareLinksTitle => 'Link condivisi';

  @override
  String get shareScopeMaterial => 'Materiale';

  @override
  String get shareScopeModel => 'Modello';

  @override
  String get shareScopeCollection => 'Collezione';

  @override
  String get shareUnknownTarget => 'Elemento eliminato';

  @override
  String sharedFrom(String org) {
    return 'Condiviso da $org';
  }

  @override
  String sharedReadOnly(String date) {
    return 'Sola lettura · dati aggiornati · link valido fino al $date';
  }

  @override
  String get sharedExpiredTitle => 'Questo link è scaduto';

  @override
  String sharedExpiredBody(String date) {
    return 'Non è più valido dal $date. Chiedi un nuovo link al laboratorio che te l\'ha inviato.';
  }

  @override
  String get sharedRevokedTitle => 'Questo link è stato revocato';

  @override
  String get sharedRevokedBody =>
      'Il laboratorio l\'ha disattivato. Chiedigli un nuovo link se necessario.';

  @override
  String get sharedNotFoundTitle => 'Link non trovato';

  @override
  String get sharedNotFoundBody =>
      'Verifica l\'indirizzo o chiedi un nuovo link al laboratorio.';

  @override
  String get sharedError =>
      'Impossibile caricare la pagina. Verifica la connessione e riprova.';
}
