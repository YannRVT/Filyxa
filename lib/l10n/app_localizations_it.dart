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
}
