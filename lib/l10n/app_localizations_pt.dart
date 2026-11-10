// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appTitle => 'Filyxa';

  @override
  String get navLibrary => 'TissuTech';

  @override
  String get navStudio => 'Studio';

  @override
  String get navScanner => 'Scanner';

  @override
  String get navSuppliers => 'Fornecedores';

  @override
  String get navAccount => 'Conta';

  @override
  String get comingSoonTitle => 'Em breve';

  @override
  String get comingSoonBody =>
      'Esta secção chega numa próxima versão do Filyxa.';

  @override
  String get emailLabel => 'E-mail';

  @override
  String get passwordLabel => 'Palavra-passe';

  @override
  String get newPasswordLabel => 'Nova palavra-passe';

  @override
  String get confirmPasswordLabel => 'Confirmar palavra-passe';

  @override
  String get passwordHelper =>
      'Mínimo 8 caracteres, com pelo menos uma letra e um algarismo';

  @override
  String get codeLabel => 'Código de 6 algarismos';

  @override
  String get showPassword => 'Mostrar palavra-passe';

  @override
  String get hidePassword => 'Ocultar palavra-passe';

  @override
  String get loginTitle => 'Iniciar sessão';

  @override
  String get loginSubtitle => 'Aceda à biblioteca de materiais do seu ateliê.';

  @override
  String get loginButton => 'Iniciar sessão';

  @override
  String get forgotPassword => 'Esqueceu-se da palavra-passe?';

  @override
  String get haveInvitation => 'Recebi um convite';

  @override
  String get devQuickLogin => 'Acesso rápido (dev)';

  @override
  String get inviteTitle => 'Junte-se à sua equipa';

  @override
  String get inviteIntro =>
      'Introduza o seu e-mail e o código de 6 algarismos recebido no e-mail de convite.';

  @override
  String get verifyCode => 'Verificar o código';

  @override
  String get resendCode => 'Receber um novo código';

  @override
  String codeResent(String email) {
    return 'Se houver um convite pendente para $email, acaba de ser enviado um novo código.';
  }

  @override
  String get choosePasswordTitle => 'Escolha a sua palavra-passe';

  @override
  String choosePasswordIntro(String organization) {
    return 'Bem-vindo à $organization. Escolha a palavra-passe da sua conta.';
  }

  @override
  String get savePassword => 'Guardar e entrar';

  @override
  String get invitationExpiredTitle => 'Convite expirado';

  @override
  String get invitationExpiredBody =>
      'Este convite expirou. Peça ao administrador do seu ateliê que lhe envie um novo.';

  @override
  String get invitationNotFound =>
      'Não há nenhum convite pendente para este endereço. Verifique o e-mail utilizado ou peça um novo convite.';

  @override
  String get alreadyMember => 'Esta conta já pertence a uma organização.';

  @override
  String get backToLogin => 'Voltar ao início de sessão';

  @override
  String get resetTitle => 'Palavra-passe esquecida';

  @override
  String get resetIntro =>
      'Introduza o e-mail da sua conta: receberá um código de redefinição.';

  @override
  String get sendCode => 'Enviar o código';

  @override
  String resetCodeSent(String email) {
    return 'Se existir uma conta para $email, acaba de ser enviado um código de 6 algarismos.';
  }

  @override
  String get resetButton => 'Alterar a palavra-passe';

  @override
  String get passwordChanged => 'Palavra-passe alterada. Sessão iniciada.';

  @override
  String get errorEmailInvalid => 'Endereço de e-mail inválido';

  @override
  String get errorPasswordShort => 'Mínimo 8 caracteres';

  @override
  String get errorPasswordWeak => 'Pelo menos uma letra e um algarismo';

  @override
  String get errorPasswordMismatch => 'As palavras-passe não coincidem';

  @override
  String get errorCodeInvalid => 'Introduza o código de 6 algarismos';

  @override
  String get errorBadCredentials => 'E-mail ou palavra-passe incorretos';

  @override
  String get errorCodeExpired => 'Código incorreto ou expirado. Peça um novo.';

  @override
  String get errorNetwork =>
      'Não é possível ligar. Verifique a sua rede e tente novamente.';

  @override
  String get errorTooManyRequests =>
      'Demasiadas tentativas. Aguarde alguns minutos antes de tentar novamente.';

  @override
  String get errorForbidden => 'Ação reservada aos administradores.';

  @override
  String get errorEmailNotSent =>
      'Não foi possível enviar o e-mail. Tente novamente dentro de alguns minutos.';

  @override
  String get errorGeneric => 'Ocorreu um erro. Tente novamente.';

  @override
  String get errorOrgName => 'Entre 2 e 120 caracteres';

  @override
  String get retry => 'Tentar novamente';

  @override
  String get cancel => 'Cancelar';

  @override
  String get logout => 'Terminar sessão';

  @override
  String get accountTitle => 'A minha conta';

  @override
  String get languageLabel => 'Idioma';

  @override
  String get organizationLabel => 'Organização';

  @override
  String get roleLabel => 'Função';

  @override
  String get roleAdmin => 'Admin';

  @override
  String get roleEditor => 'Editor';

  @override
  String get roleViewer => 'Leitor';

  @override
  String get superadminConsole => 'Consola de superadministrador';

  @override
  String get noOrgTitle => 'Nenhuma organização';

  @override
  String get noOrgBody =>
      'A sua conta não está associada a nenhuma organização. Peça um convite ao administrador do seu ateliê.';

  @override
  String get loadingError => 'Não é possível carregar o seu espaço.';

  @override
  String get adminTitle => 'Consola de superadministrador';

  @override
  String get adminNewAtelier => 'Novo ateliê';

  @override
  String get adminEmpty =>
      'Ainda não há organizações. Crie o primeiro ateliê piloto.';

  @override
  String get adminOrgName => 'Nome do ateliê';

  @override
  String get adminAdminEmail => 'E-mail do seu administrador';

  @override
  String get adminCreate => 'Criar e convidar';

  @override
  String adminCreated(String email) {
    return 'Ateliê criado. Convite enviado para $email.';
  }

  @override
  String adminInvitePending(String email, String date) {
    return 'Convite pendente: $email · expira a $date';
  }

  @override
  String adminInviteExpired(String email) {
    return 'Convite expirado: $email';
  }

  @override
  String adminMembers(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count membros',
      one: '1 membro',
      zero: 'Nenhum membro',
    );
    return '$_temp0';
  }

  @override
  String get adminReinvite => 'Reenviar o convite';

  @override
  String adminReinvited(String email) {
    return 'Convite reenviado para $email.';
  }

  @override
  String get orgKindAtelier => 'Ateliê';

  @override
  String get orgKindSupplier => 'Fornecedor';

  @override
  String get missingConfig =>
      'Configuração do Supabase em falta. Copie env.example.json para env.json, preencha-o e execute: flutter run --dart-define-from-file=env.json';

  @override
  String get membersEntry => 'Membros do ateliê';

  @override
  String get membersTitle => 'Membros';

  @override
  String get membersInvite => 'Convidar';

  @override
  String get inviteDialogTitle => 'Convidar um membro';

  @override
  String get inviteSend => 'Enviar o convite';

  @override
  String get roleAdminHelp => 'Gere os membros e as definições do ateliê';

  @override
  String get roleEditorHelp => 'Cria, edita, digitaliza, importa e partilha';

  @override
  String get roleViewerHelp => 'Consulta e exporta, sem alterar nada';

  @override
  String get youSuffix => 'você';

  @override
  String get pendingInvitations => 'Convites pendentes';

  @override
  String invitationExpiresOn(String date) {
    return 'Expira a $date';
  }

  @override
  String get invitationExpiredShort => 'Expirado';

  @override
  String get resendInvitation => 'Reenviar';

  @override
  String get cancelInvitation => 'Cancelar o convite';

  @override
  String invitationSent(String email) {
    return 'Convite enviado para $email.';
  }

  @override
  String get invitationCanceled => 'Convite cancelado.';

  @override
  String get changeRole => 'Alterar a função';

  @override
  String get roleChanged => 'Função atualizada.';

  @override
  String get removeMember => 'Remover do ateliê';

  @override
  String removeConfirmTitle(String name) {
    return 'Remover $name?';
  }

  @override
  String get removeConfirmBody =>
      'Esta pessoa perderá imediatamente o acesso aos dados do ateliê. Poderá convidá-la novamente.';

  @override
  String get removeConfirm => 'Remover';

  @override
  String get memberRemoved => 'Membro removido.';

  @override
  String get errorLastAdmin =>
      'O ateliê deve manter pelo menos um administrador. Nomeie primeiro outro administrador.';

  @override
  String get lastAdminHint => 'Único administrador do ateliê';

  @override
  String memberActions(String name) {
    return 'Ações para $name';
  }
}
