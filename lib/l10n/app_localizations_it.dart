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
}
