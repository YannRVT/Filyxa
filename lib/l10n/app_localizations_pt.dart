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

  @override
  String get libraryNew => 'Novo material';

  @override
  String get viewGallery => 'Galeria';

  @override
  String get viewTable => 'Tabela';

  @override
  String get libraryEmptyTitle => 'O seu TissuTech está vazio';

  @override
  String get libraryEmptyBody =>
      'Adicione os seus primeiros materiais: digitalize a etiqueta de uma amostra, importe o seu ficheiro Excel ou introduza-os manualmente.';

  @override
  String get libraryEmptyViewer =>
      'Ainda não há materiais. Os editores do seu ateliê podem adicioná-los.';

  @override
  String get actionScanSample => 'Digitalizar uma amostra';

  @override
  String get actionImportExcel => 'Importar um ficheiro Excel';

  @override
  String get actionCreateManual => 'Introduzir manualmente';

  @override
  String materialCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count materiais',
      one: '1 material',
      zero: 'Nenhum material',
    );
    return '$_temp0';
  }

  @override
  String get colMaterial => 'Material';

  @override
  String get colReference => 'Referência';

  @override
  String get colComposition => 'Composição';

  @override
  String get colWeight => 'g/m²';

  @override
  String get colWidth => 'Largura';

  @override
  String get colStock => 'Stock do ateliê';

  @override
  String get fieldName => 'Nome do material';

  @override
  String get fieldSupplier => 'Fornecedor';

  @override
  String get fieldSupplierCode => 'Código do artigo';

  @override
  String get fieldColorName => 'Cor';

  @override
  String get fieldColorHex => 'Cor (#RRGGBB)';

  @override
  String get photoAdd => 'Adicionar uma fotografia';

  @override
  String get photoChange => 'Alterar a fotografia';

  @override
  String get photoRemove => 'Remover a fotografia';

  @override
  String get sectionIdentity => 'Identidade';

  @override
  String get sectionColor => 'Cor e fotografia';

  @override
  String get sectionComposition => 'Composição';

  @override
  String get sectionTechnical => 'Características';

  @override
  String get sectionCare => 'Cuidados';

  @override
  String get sectionUses => 'Utilizações e certificações';

  @override
  String get sectionStock => 'Stock do ateliê';

  @override
  String get sectionNotes => 'Notas';

  @override
  String get addFiber => 'Adicionar uma fibra';

  @override
  String get removeFiber => 'Remover esta fibra';

  @override
  String get fiberLabel => 'Fibra';

  @override
  String compositionTotal(String total) {
    return 'Total: $total %';
  }

  @override
  String get compositionMustBe100 =>
      'O total deve ser 100 %, sem fibras repetidas';

  @override
  String get fieldWeight => 'Gramagem (g/m²)';

  @override
  String get fieldWidth => 'Largura (cm)';

  @override
  String get fieldWeave => 'Debuxo';

  @override
  String get noneOption => 'Não indicado';

  @override
  String get fieldCertifications => 'Certificações';

  @override
  String get fieldUses => 'Utilizações';

  @override
  String get fieldStock => 'Metros em stock (m)';

  @override
  String get errorRequired => 'Campo obrigatório';

  @override
  String errorNumberRange(int min, int max) {
    return 'Número entre $min e $max';
  }

  @override
  String get errorHex => 'Formato esperado #RRGGBB (ex. #2F4A6B)';

  @override
  String get save => 'Guardar';

  @override
  String get materialSaved => 'Material guardado.';

  @override
  String get edit => 'Editar';

  @override
  String get delete => 'Eliminar';

  @override
  String deleteMaterialTitle(String name) {
    return 'Eliminar «$name»?';
  }

  @override
  String get deleteMaterialBody =>
      'O material e a sua fotografia serão eliminados definitivamente.';

  @override
  String get materialDeleted => 'Material eliminado.';

  @override
  String get editStock => 'Editar stock';

  @override
  String get stockUpdated => 'Stock atualizado.';

  @override
  String stockMeters(String value) {
    return '$value m';
  }

  @override
  String get materialNotFound =>
      'Este material já não existe ou não está acessível.';

  @override
  String get newMaterialTitle => 'Novo material';

  @override
  String get editMaterialTitle => 'Editar o material';

  @override
  String get detailWeight => 'Gramagem';

  @override
  String get detailWidth => 'Largura';

  @override
  String get photoUploadFailed =>
      'Não foi possível enviar a fotografia. Tente novamente.';

  @override
  String get viewerReadOnly => 'Só de leitura';

  @override
  String get errorEditorsOnly =>
      'Ação reservada aos editores e administradores do ateliê.';

  @override
  String get searchHint => 'Pesquisar: nome, código, fornecedor, cor, fibra…';

  @override
  String get clearSearch => 'Limpar a pesquisa';

  @override
  String get filtersButton => 'Filtros';

  @override
  String get clearFilters => 'Limpar os filtros';

  @override
  String get showResults => 'Ver os resultados';

  @override
  String get noResultsTitle => 'Sem resultados';

  @override
  String get noResultsBody =>
      'Nenhum material corresponde à sua pesquisa ou aos seus filtros.';

  @override
  String resultCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count resultados',
      one: '1 resultado',
      zero: 'Sem resultados',
    );
    return '$_temp0';
  }

  @override
  String get filterFiber => 'Fibra';

  @override
  String get filterFiberAny => 'Todas as fibras';

  @override
  String filterFiberMin(int pct) {
    return 'Pelo menos $pct %';
  }

  @override
  String get filterWeight => 'Gramagem';

  @override
  String get filterColor => 'Cor';

  @override
  String get filterInStock => 'Em stock no ateliê';

  @override
  String removeFilter(String label) {
    return 'Remover o filtro $label';
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
  String get navCatalog => 'Catálogo';

  @override
  String get catalogEmptyTitle => 'O seu catálogo está vazio';

  @override
  String get catalogEmptyBody =>
      'Importe o seu catálogo a partir de um ficheiro Excel ou CSV exportado do seu software de gestão.';

  @override
  String get catalogImport => 'Importar um ficheiro';

  @override
  String get catalogSettings => 'Disponibilidade';

  @override
  String referenceCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count referências',
      one: '1 referência',
      zero: 'Nenhuma referência',
    );
    return '$_temp0';
  }

  @override
  String get showRetired => 'Mostrar as referências retiradas';

  @override
  String get retiredBadge => 'Retirada';

  @override
  String get colStatus => 'Disponibilidade';

  @override
  String get colLeadTime => 'Prazo';

  @override
  String get statusAvailable => 'Disponível';

  @override
  String get statusLow => 'Stock baixo';

  @override
  String get statusOnOrder => 'Por encomenda';

  @override
  String statusOnOrderWeeks(int weeks) {
    return 'Por encomenda · $weeks sem.';
  }

  @override
  String get statusOutOfStock => 'Esgotado';

  @override
  String get statusHidden => 'Oculta';

  @override
  String get modeExact => 'Quantidade exata';

  @override
  String get modeTiers => 'Escalões';

  @override
  String get modeHidden => 'Oculta';

  @override
  String get modeExactHelp => 'Os ateliês veem os metros exatos em stock.';

  @override
  String get modeTiersHelp =>
      'Os ateliês só veem: disponível, stock baixo, por encomenda ou esgotado.';

  @override
  String get modeHiddenHelp => 'Os ateliês não veem a disponibilidade.';

  @override
  String modeDefault(String mode) {
    return 'Definição geral ($mode)';
  }

  @override
  String get thresholdLabel => 'Limite de stock baixo (m)';

  @override
  String get thresholdHelp =>
      'Abaixo destes metros, a referência aparece como «stock baixo».';

  @override
  String get leadTimeLabel => 'Prazo de reposição (semanas)';

  @override
  String get leadTimeHelp => 'Mostrado quando a referência está por encomenda.';

  @override
  String get availabilitySettingsTitle => 'Apresentação da disponibilidade';

  @override
  String get availabilitySettingsIntro =>
      'Escolha o que os ateliês veem do seu stock. Pode ajustar cada referência na respetiva ficha.';

  @override
  String get settingsSaved => 'Definições guardadas.';

  @override
  String get referenceRetire => 'Retirar do catálogo';

  @override
  String get referenceRestore => 'Repor no catálogo';

  @override
  String get referenceRetired => 'Referência retirada do catálogo publicado.';

  @override
  String get referenceRestored => 'Referência reposta no catálogo.';

  @override
  String retireConfirmTitle(String code) {
    return 'Retirar «$code»?';
  }

  @override
  String get retireConfirmBody =>
      'Os ateliês deixarão de a ver. Quem a utiliza mantém a última ficha. Poderá repô-la mais tarde.';

  @override
  String get referenceAvailabilityTitle => 'Disponibilidade desta referência';

  @override
  String get stockLabel => 'Stock';

  @override
  String whatAteliersSee(String value) {
    return 'O que os ateliês veem: $value';
  }

  @override
  String get importTitle => 'Importar o catálogo';

  @override
  String get importPickFile => 'Escolher um ficheiro Excel ou CSV';

  @override
  String get importPickHelp =>
      'Ficheiro .xlsx ou .csv, uma linha por referência e uma linha de cabeçalhos. Máximo de 5000 linhas. Uma referência já conhecida é atualizada pelo código.';

  @override
  String get importUnreadable =>
      'Não foi possível ler este ficheiro. Guarde-o em formato .xlsx ou .csv e tente novamente.';

  @override
  String importTooMany(int count) {
    return 'Este ficheiro contém $count linhas: máximo de 5000 por importação.';
  }

  @override
  String get importMappingTitle => 'Associe as suas colunas';

  @override
  String get importMappingIntro =>
      'As colunas reconhecidas já estão associadas. O código e a designação são obrigatórios.';

  @override
  String get importColumnNone => '— Ignorar —';

  @override
  String get importFieldName => 'Designação';

  @override
  String get importFieldStock => 'Stock (m)';

  @override
  String importSummary(int valid, int invalid) {
    return '$valid linhas prontas · $invalid com erros';
  }

  @override
  String get importErrorsTitle => 'Linhas com erros (não importadas)';

  @override
  String importLine(int line) {
    return 'Linha $line';
  }

  @override
  String importRun(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Importar $count referências',
      one: 'Importar 1 referência',
    );
    return '$_temp0';
  }

  @override
  String importRunning(int done, int total) {
    return 'A importar… $done/$total';
  }

  @override
  String get importDoneTitle => 'Importação concluída';

  @override
  String importDone(int inserted, int updated) {
    return '$inserted criadas · $updated atualizadas';
  }

  @override
  String importServerRejected(String message) {
    return 'Recusada pelo servidor: $message';
  }

  @override
  String get importAgain => 'Importar outro ficheiro';

  @override
  String get backToCatalog => 'Voltar ao catálogo';

  @override
  String importFileName(String name) {
    return 'Ficheiro: $name';
  }

  @override
  String get issueMissingCode => 'Código em falta';

  @override
  String get issueMissingName => 'Designação em falta';

  @override
  String issueComposition(String value) {
    return 'Composição ilegível ou diferente de 100 %: «$value»';
  }

  @override
  String issueNumber(String field, String value) {
    return '$field: valor inválido «$value»';
  }

  @override
  String issueColor(String value) {
    return 'Cor inválida «$value» (formato #RRGGBB)';
  }

  @override
  String issueDuplicate(String value) {
    return 'Código «$value» presente várias vezes no ficheiro';
  }

  @override
  String get adminOrgKind => 'Tipo de organização';

  @override
  String get adminNewOrg => 'Nova organização';

  @override
  String get adminOrgNameGeneric => 'Nome da organização';
}
