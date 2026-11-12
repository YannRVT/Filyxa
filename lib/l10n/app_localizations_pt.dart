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

  @override
  String get scanTitle => 'Digitalizar uma amostra';

  @override
  String get scanIntro =>
      'Fotografe a etiqueta da amostra, plana e nítida. O Filyxa lê a composição, a gramagem, a largura, os cuidados e o código; verifica antes de guardar.';

  @override
  String get scanTakePhoto => 'Tirar uma fotografia';

  @override
  String get scanImportPhoto => 'Importar uma fotografia';

  @override
  String get scanReading => 'A ler a etiqueta…';

  @override
  String scanUsage(int scans, int quota) {
    return '$scans / $quota digitalizações este mês';
  }

  @override
  String scanQuotaWarning(int percent) {
    return 'Foi utilizado $percent % da quota mensal de digitalizações.';
  }

  @override
  String get scanQuotaExhausted =>
      'Quota mensal de digitalizações atingida. A introdução manual continua possível.';

  @override
  String get scanFailureNotLabel =>
      'Não há nenhuma etiqueta têxtil legível nesta fotografia. Tire-a de novo mais de perto, plana e sem reflexos.';

  @override
  String get scanFailureRefused =>
      'A análise desta imagem foi recusada. Experimente outra fotografia.';

  @override
  String get scanFailureAi =>
      'O serviço de leitura está temporariamente indisponível. Tente novamente dentro de instantes.';

  @override
  String get scanFailureImage =>
      'Esta imagem não é suportada (JPEG, PNG ou WebP, máximo 5 MB).';

  @override
  String get prefillBanner =>
      'Ficha pré-preenchida pela digitalização. Verifique os campos assinalados antes de guardar.';

  @override
  String get fieldUncertain => 'Lido com pouca certeza: verifique';

  @override
  String get sectionUncertain => 'Leitura incerta: verifique esta secção.';

  @override
  String duplicateFound(String name) {
    return 'Já existe um material com este código: «$name».';
  }

  @override
  String get duplicateOpen => 'Abrir a ficha existente';

  @override
  String get matchTitle => 'É esta a referência?';

  @override
  String matchIntro(String supplier) {
    return 'Encontrada no catálogo de $supplier. Confirme para ligar a sua ficha aos dados e à disponibilidade.';
  }

  @override
  String get matchConfirm => 'Sim, ligar esta referência';

  @override
  String get matchOthers => 'Outras referências próximas';

  @override
  String get matchNone => 'Nenhuma destas referências';

  @override
  String get supplierData => 'Dados do fornecedor';

  @override
  String get supplierDataHelp =>
      'Atualizados pelo fornecedor, não editáveis aqui.';

  @override
  String get referenceRetiredBanner =>
      'Referência retirada pelo fornecedor. Os últimos valores conhecidos são mantidos.';

  @override
  String get linkToSupplier => 'Ligar a uma referência do fornecedor';

  @override
  String get linkSearchHint => 'Código, designação ou fornecedor';

  @override
  String get linkSearchEmpty => 'Nenhuma referência publicada corresponde.';

  @override
  String get linkConfirm => 'Ligar';

  @override
  String get unlink => 'Desligar a referência';

  @override
  String get unlinkConfirmBody =>
      'A ficha mantém os valores atuais e volta a ser editável. Deixará de seguir as atualizações do fornecedor.';

  @override
  String get linkedDone => 'Ficha ligada ao fornecedor.';

  @override
  String get unlinkedDone => 'Ficha desligada do fornecedor.';

  @override
  String get privateLayer => 'Informações do ateliê';

  @override
  String get privateLayerHelp => 'Visíveis apenas para o seu ateliê.';

  @override
  String get fieldPrice => 'Preço negociado (€/m)';

  @override
  String get fieldTags => 'Etiquetas';

  @override
  String get fieldTagsHint => 'Separadas por vírgulas (ex. OI27, a validar)';

  @override
  String priceValue(String value) {
    return '$value €/m';
  }

  @override
  String get atelierImportTitle => 'Importar a base do ateliê';

  @override
  String get atelierImportHelp =>
      'Ficheiro .xlsx ou .csv, uma linha por material e uma linha de cabeçalhos. Máximo de 5 000 linhas. Um material já existente (mesmo fornecedor e código, ou mesmo nome e cor) é atualizado, nunca duplicado.';

  @override
  String get atelierImportMappingIntro =>
      'As colunas reconhecidas já estão associadas. Apenas o nome do material é obrigatório.';

  @override
  String atelierImportRun(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Importar $count materiais',
      one: 'Importar 1 material',
    );
    return '$_temp0';
  }

  @override
  String atelierImportDone(int imported, int linked, int pending, int errors) {
    return '$imported importados · $linked ligados a um fornecedor · $pending por confirmar · $errors com erros';
  }

  @override
  String atelierImportDetail(int inserted, int updated) {
    return 'dos quais $inserted novos e $updated atualizados';
  }

  @override
  String get backToLibrary => 'Voltar ao TissuTech';

  @override
  String reviewLinksAction(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Confirmar $count correspondências',
      one: 'Confirmar 1 correspondência',
    );
    return '$_temp0';
  }

  @override
  String pendingLinksBanner(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count materiais importados parecem-se com referências de fornecedor.',
      one: '1 material importado parece-se com uma referência de fornecedor.',
    );
    return '$_temp0';
  }

  @override
  String get reviewTitle => 'Correspondências por confirmar';

  @override
  String reviewProgress(int index, int total) {
    return '$index de $total';
  }

  @override
  String get reviewIntro =>
      'A sua ficha parece-se com uma referência publicada. Confirme para a ligar aos seus dados e disponibilidade.';

  @override
  String get reviewSkip => 'Mais tarde';

  @override
  String get reviewDone => 'Todas as correspondências foram tratadas.';

  @override
  String get reviewNoCandidate =>
      'Nenhuma referência publicada corresponde já a este material.';

  @override
  String get reviewOpen => 'Rever';

  @override
  String get reportAction => 'Assinalar um erro';

  @override
  String get reportTitle => 'Assinalar um erro ao fornecedor';

  @override
  String get reportIntro =>
      'O fornecedor corrigirá a ficha para todos os ateliês. Não vê o nome do seu ateliê, salvo se optar por partilhá-lo.';

  @override
  String get reportField => 'Campo';

  @override
  String get reportObserved => 'Valor constatado';

  @override
  String get reportObservedHint => 'Ex. 300 g/m² medidos na amostra';

  @override
  String get reportComment => 'Comentário (opcional)';

  @override
  String get reportShareIdentity =>
      'Partilhar o nome do meu ateliê com o fornecedor';

  @override
  String get reportSend => 'Enviar';

  @override
  String get reportSent => 'Assinalamento enviado ao fornecedor.';

  @override
  String get reportFieldAvailability => 'Disponibilidade';

  @override
  String get reportFieldOther => 'Outro';

  @override
  String get reportsSection => 'Assinalamentos';

  @override
  String get reportStatusOpen => 'Aberto';

  @override
  String get reportStatusFixed => 'Corrigido';

  @override
  String get reportStatusRejected => 'Rejeitado';

  @override
  String reportObservedLine(String value) {
    return 'Constatado: $value';
  }

  @override
  String reportReasonLine(String reason) {
    return 'Motivo: $reason';
  }

  @override
  String reportResponseLine(String response) {
    return 'Resposta: $response';
  }

  @override
  String get supplierReportsTitle => 'Assinalamentos dos ateliês';

  @override
  String supplierReportsButton(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count assinalamentos abertos',
      one: '1 assinalamento aberto',
      zero: 'Assinalamentos',
    );
    return '$_temp0';
  }

  @override
  String get supplierReportsEmpty => 'Nenhum assinalamento por agora.';

  @override
  String get reportAnonymous => 'Ateliê anónimo';

  @override
  String get reportMarkFixed => 'Marcar como corrigido';

  @override
  String get reportReject => 'Rejeitar';

  @override
  String get reportRejectTitle => 'Rejeitar o assinalamento';

  @override
  String get reportRejectReason => 'Motivo da rejeição';

  @override
  String get reportFixTitle => 'Marcar como corrigido';

  @override
  String get reportFixHelp =>
      'Lembre-se de corrigir a referência no catálogo: os ateliês ligados verão de imediato.';

  @override
  String get reportFixMessage => 'Mensagem ao ateliê (opcional)';

  @override
  String get reportEditReference => 'Abrir a referência';

  @override
  String get reportFilterOpen => 'Abertos';

  @override
  String get reportFilterAll => 'Todos';

  @override
  String get notificationsTitle => 'Notificações';

  @override
  String get notificationsEmpty => 'Nenhuma notificação.';

  @override
  String notificationsTooltip(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Notificações ($count por ler)',
      one: 'Notificações (1 por ler)',
      zero: 'Notificações',
    );
    return '$_temp0';
  }

  @override
  String notifReportNew(String code, String field) {
    return 'Novo assinalamento sobre $code · $field';
  }

  @override
  String notifReportFixed(String name, String field) {
    return '$name: o fornecedor corrigiu «$field»';
  }

  @override
  String notifReportRejected(String name, String field) {
    return '$name: assinalamento sobre «$field» rejeitado';
  }

  @override
  String get studioNewCollection => 'Nova coleção';

  @override
  String get studioCollectionName => 'Nome da coleção';

  @override
  String get studioCollectionHint => 'Ex. OI27';

  @override
  String get studioEmptyTitle => 'Ainda não há coleções';

  @override
  String get studioEmptyEditor =>
      'Crie uma coleção para agrupar os modelos de uma estação, por exemplo «OI27».';

  @override
  String get studioEmptyViewer =>
      'Os editores do seu ateliê ainda não criaram nenhuma coleção.';

  @override
  String studioModelCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count modelos',
      one: '1 modelo',
      zero: 'Nenhum modelo',
    );
    return '$_temp0';
  }

  @override
  String get collectionEmptyTitle => 'Esta coleção está vazia';

  @override
  String get collectionEmptyEditor =>
      'Adicione um primeiro modelo: vestuário, calçado, marroquinaria ou acessório.';

  @override
  String get collectionEmptyViewer => 'Ainda não há modelos nesta coleção.';

  @override
  String get studioNewModel => 'Novo modelo';

  @override
  String get modelName => 'Nome do modelo';

  @override
  String get modelReference => 'Referência (opcional)';

  @override
  String get modelType => 'Tipo de produto';

  @override
  String get productGarment => 'Vestuário';

  @override
  String get productFootwear => 'Calçado';

  @override
  String get productLeatherGoods => 'Marroquinaria';

  @override
  String get productAccessory => 'Acessório';

  @override
  String colorwayCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count cores',
      one: '1 cor',
    );
    return '$_temp0';
  }

  @override
  String bomLineCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count materiais',
      one: '1 material',
      zero: 'nenhum material',
    );
    return '$_temp0';
  }

  @override
  String get rename => 'Mudar o nome';

  @override
  String get create => 'Criar';

  @override
  String get add => 'Adicionar';

  @override
  String deleteCollectionTitle(String name) {
    return 'Eliminar a coleção «$name»?';
  }

  @override
  String get deleteCollectionBody =>
      'Os seus modelos, cores e quantidades serão eliminados definitivamente. Os materiais do TissuTech são mantidos.';

  @override
  String deleteModelTitle(String name) {
    return 'Eliminar o modelo «$name»?';
  }

  @override
  String get deleteModelBody =>
      'As suas cores e a lista de materiais serão eliminadas definitivamente. Os materiais do TissuTech são mantidos.';

  @override
  String get wasteLabel => 'Margem de desperdício (%)';

  @override
  String get quantityLabel => 'Quantidade prevista (peças)';

  @override
  String get addColorway => 'Adicionar uma cor';

  @override
  String get declineColorways => 'Declinar em cores';

  @override
  String get colorwayCurrent => 'Cor atual';

  @override
  String get colorwayNew => 'Nova cor';

  @override
  String get colorwayNameHint => 'Ex. Preto';

  @override
  String colorwayDefault(int index) {
    return 'Cor $index';
  }

  @override
  String colorwayCopyHelp(String name) {
    return 'A nova cor retoma os materiais de «$name»: só terá de mudar os que diferem.';
  }

  @override
  String get deleteColorway => 'Eliminar esta cor';

  @override
  String get addMaterial => 'Adicionar um material';

  @override
  String get modelEmptyTitle => 'Nenhum material neste modelo';

  @override
  String get modelEmptyEditor =>
      'Adicione os materiais do modelo e o consumo por peça para calcular a necessidade.';

  @override
  String get modelEmptyViewer =>
      'Ainda não foi associado nenhum material a este modelo.';

  @override
  String get bomRoleLabel => 'Função';

  @override
  String get roleOther => 'Outra função…';

  @override
  String get roleCustom => 'Nome da função';

  @override
  String get role_main => 'Tecido principal';

  @override
  String get role_lining => 'Forro';

  @override
  String get role_interfacing => 'Entretela';

  @override
  String get role_contrast => 'Tecido de contraste';

  @override
  String get role_pocketing => 'Forro de bolso';

  @override
  String get role_rib => 'Canelado';

  @override
  String get role_upper => 'Gáspea';

  @override
  String get role_sock_lining => 'Palmilha';

  @override
  String get role_insole => 'Palmilha de montagem';

  @override
  String get role_outsole => 'Sola';

  @override
  String get role_reinforcement => 'Reforço';

  @override
  String get role_exterior => 'Exterior';

  @override
  String get role_gusset => 'Fole';

  @override
  String get role_strap => 'Alça ou bandoleira';

  @override
  String get role_trim => 'Guarnição';

  @override
  String get consumptionLabel => 'Consumo (m/peça)';

  @override
  String requirementLine(String value) {
    return 'Necessidade: $value m';
  }

  @override
  String get requirementTitle => 'Necessidade total por material';

  @override
  String requirementFormula(String waste) {
    return 'Consumo × quantidade × (1 + desperdício de $waste %)';
  }

  @override
  String get pickMaterial => 'Escolher um material';

  @override
  String get pickMaterialSearch => 'Pesquisar no TissuTech';

  @override
  String get pickMaterialEmpty => 'Nenhum material corresponde.';

  @override
  String get pickMaterialLibraryEmpty =>
      'Adicione primeiro materiais no TissuTech.';

  @override
  String get removeLine => 'Remover este material';

  @override
  String get materialMissing => 'Material eliminado do TissuTech';

  @override
  String get alertsTitle => 'Alertas';

  @override
  String get alertsNone =>
      'Nenhum alerta: os materiais do modelo são compatíveis e o stock é suficiente.';

  @override
  String alertsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count alertas',
      one: '1 alerta',
    );
    return '$_temp0';
  }

  @override
  String get alertFamilyCare => 'Conservação';

  @override
  String get alertFamilyTechnical => 'Técnica';

  @override
  String get alertFamilyCertification => 'Certificações';

  @override
  String get alertFamilyStock => 'Stock';

  @override
  String alertQuoted(String name) {
    return '«$name»';
  }

  @override
  String get alertNoIron => 'nenhuma engomagem';

  @override
  String get alertNoMainTitle => 'Nenhum tecido principal';

  @override
  String get alertNoMainBody =>
      'Indique o tecido principal para ativar todas as verificações.';

  @override
  String get alertLiningHeavierTitle =>
      'Forro mais pesado do que o tecido principal';

  @override
  String alertLiningHeavierBody(String lining, String main) {
    return '$lining excede $main: o forro pode deformar o produto.';
  }

  @override
  String get alertStretchTitle => 'Tecido elástico, forro rígido';

  @override
  String alertStretchBody(String main, String lining) {
    return '$main contém elastano mas $lining não: preveja folga ou um forro elástico.';
  }

  @override
  String get alertInterfacingHeavierTitle => 'Entretela demasiado pesada';

  @override
  String alertInterfacingHeavierBody(String interfacing, String main) {
    return '$interfacing é mais pesada do que $main: risco de rigidez e transparência.';
  }

  @override
  String get alertFusingTitle => 'Termocolagem arriscada';

  @override
  String alertFusingBody(String main, String iron) {
    return '$main suporta no máximo $iron: escolha uma entretela para coser ou de baixa temperatura.';
  }

  @override
  String get alertConsumptionTitle => 'Consumo não indicado';

  @override
  String alertConsumptionBody(String materials) {
    return '$materials: não é possível calcular a necessidade.';
  }

  @override
  String get alertCareConflictTitle => 'Conservação incompatível';

  @override
  String alertCareConflictBody(String details) {
    return '$details. A etiqueta do produto deverá indicar a conservação mais restritiva.';
  }

  @override
  String alertWashTitle(int temp) {
    return 'Lavagem limitada a $temp °C';
  }

  @override
  String alertIronTitle(String iron) {
    return 'Engomagem limitada: $iron';
  }

  @override
  String get alertTumbleTitle => 'Evitar a máquina de secar';

  @override
  String alertLimitBody(String details) {
    return '$details. O produto final segue o material mais delicado.';
  }

  @override
  String alertCertTitle(String cert) {
    return '$cert não cumprida em todo o produto';
  }

  @override
  String alertCertBody(String certified, String cert, String missing) {
    return '$certified é certificado $cert, mas $missing não: o produto final não poderá reivindicar $cert.';
  }

  @override
  String get alertRetiredTitle => 'Referência retirada pelo fornecedor';

  @override
  String alertRetiredBody(String material, String need, String atelier) {
    return '$material já não é proposto: necessidade $need, stock do ateliê $atelier.';
  }

  @override
  String get alertAtelierShortTitle => 'Stock do ateliê insuficiente';

  @override
  String alertAtelierShortBody(
    String material,
    String need,
    String atelier,
    String missing,
  ) {
    return '$material: necessidade $need, stock do ateliê $atelier. Faltam $missing.';
  }

  @override
  String get alertCoveredTitle => 'A encomendar ao fornecedor';

  @override
  String alertCoveredBody(
    String material,
    String need,
    String atelier,
    String missing,
  ) {
    return '$material: necessidade $need, stock do ateliê $atelier. O restante ($missing) está disponível no fornecedor.';
  }

  @override
  String alertCoveredBodyExact(
    String material,
    String need,
    String atelier,
    String missing,
    String supplier,
  ) {
    return '$material: necessidade $need, stock do ateliê $atelier. O restante ($missing) está disponível no fornecedor ($supplier em stock).';
  }

  @override
  String get alertSupplierShortTitle => 'Stock do fornecedor insuficiente';

  @override
  String alertSupplierShortBody(
    String material,
    String missing,
    String atelier,
    String supplier,
  ) {
    return '$material: faltam $missing após o stock do ateliê ($atelier) e o fornecedor só tem $supplier.';
  }

  @override
  String get alertSupplierLowTitle => 'Stock baixo no fornecedor';

  @override
  String alertSupplierLowBody(String material, String missing, String atelier) {
    return '$material: faltam $missing após o stock do ateliê ($atelier) e o fornecedor tem stock baixo.';
  }

  @override
  String get alertOnOrderTitle => 'Por encomenda no fornecedor';

  @override
  String alertOnOrderBody(
    String material,
    String missing,
    String atelier,
    int weeks,
  ) {
    return '$material: faltam $missing após o stock do ateliê ($atelier). Prazo de reposição: $weeks semanas.';
  }

  @override
  String get alertOutTitle => 'Esgotado no fornecedor';

  @override
  String alertOutBody(String material, String missing, String atelier) {
    return '$material: faltam $missing após o stock do ateliê ($atelier) e o fornecedor está esgotado.';
  }

  @override
  String get alertHiddenTitle => 'Disponibilidade não comunicada';

  @override
  String alertHiddenBody(String material, String missing, String atelier) {
    return '$material: faltam $missing após o stock do ateliê ($atelier). O fornecedor não publica o stock: contacte-o.';
  }

  @override
  String notifStockLow(String name, String code) {
    return '$name: stock baixo no fornecedor ($code)';
  }

  @override
  String notifStockOut(String name, String code) {
    return '$name: esgotado no fornecedor ($code)';
  }

  @override
  String notifReferenceUpdated(String name, String code) {
    return '$name: ficha alterada pelo fornecedor ($code)';
  }

  @override
  String notifReferenceRetired(String name, String code) {
    return '$name: referência retirada pelo fornecedor ($code)';
  }

  @override
  String notifUsedIn(String models) {
    return 'Usado em: $models';
  }

  @override
  String get exportPdf => 'Exportar em PDF';

  @override
  String get exportDossier => 'Exportar o dossier PDF';

  @override
  String get pdfLanguage => 'Idioma do PDF';

  @override
  String get pdfMaterialSheet => 'Ficha de material';

  @override
  String get pdfModelDossier => 'Dossier de materiais';

  @override
  String get pdfCollectionDossier => 'Dossier de materiais da coleção';

  @override
  String pdfEditedOn(String date) {
    return 'Emitido em $date';
  }

  @override
  String get pdfNotSet => 'Não indicado';

  @override
  String get pdfCompositionNote =>
      'Composição expressa segundo o Regulamento (UE) n.º 1007/2011. Características indicativas, a validar em amostra.';

  @override
  String get pdfSupplierData => 'Dados do fornecedor';

  @override
  String pdfPage(int page, int total) {
    return 'Página $page / $total';
  }

  @override
  String get pdfContents => 'Índice';

  @override
  String get pdfMaterial => 'Material';

  @override
  String get pdfConsumption => 'Consumo/peça';

  @override
  String get pdfNeed => 'Necessidade';

  @override
  String get pdfGenerationError =>
      'Não foi possível gerar o PDF. Tente novamente.';

  @override
  String get shareAction => 'Partilhar';

  @override
  String get shareTitle => 'Partilhar só de leitura';

  @override
  String get shareIntro =>
      'O destinatário abre a ligação sem conta e vê fichas sempre atualizadas, sem preços, notas nem stock do ateliê.';

  @override
  String get shareLanguage => 'Idioma da página';

  @override
  String get shareValidity => 'Validade (dias)';

  @override
  String get shareCreate => 'Criar a ligação';

  @override
  String get shareCopy => 'Copiar a ligação';

  @override
  String get shareCopied => 'Ligação copiada.';

  @override
  String shareExpires(String date) {
    return 'Expira em $date';
  }

  @override
  String get shareRevoke => 'Revogar';

  @override
  String get shareRevokeConfirm =>
      'Revogar esta ligação? Deixará de funcionar de imediato.';

  @override
  String get shareRevoked => 'Ligação revogada.';

  @override
  String get shareExtend => 'Alterar a validade';

  @override
  String get shareActiveLinks => 'Ligações ativas';

  @override
  String get shareNone => 'Nenhuma ligação ativa.';

  @override
  String get shareLinksTitle => 'Ligações partilhadas';

  @override
  String get shareScopeMaterial => 'Material';

  @override
  String get shareScopeModel => 'Modelo';

  @override
  String get shareScopeCollection => 'Coleção';

  @override
  String get shareUnknownTarget => 'Elemento eliminado';

  @override
  String sharedFrom(String org) {
    return 'Partilhado por $org';
  }

  @override
  String sharedReadOnly(String date) {
    return 'Só de leitura · dados atualizados · ligação válida até $date';
  }

  @override
  String get sharedExpiredTitle => 'Esta ligação expirou';

  @override
  String sharedExpiredBody(String date) {
    return 'Já não é válida desde $date. Peça uma nova ligação ao ateliê que a enviou.';
  }

  @override
  String get sharedRevokedTitle => 'Esta ligação foi revogada';

  @override
  String get sharedRevokedBody =>
      'O ateliê desativou-a. Peça-lhe uma nova ligação se necessário.';

  @override
  String get sharedNotFoundTitle => 'Ligação não encontrada';

  @override
  String get sharedNotFoundBody =>
      'Verifique o endereço ou peça uma nova ligação ao ateliê.';

  @override
  String get sharedError =>
      'Não foi possível carregar a página. Verifique a ligação e tente novamente.';

  @override
  String get adminPlan => 'Plano';

  @override
  String get plan_pilot => 'Piloto';

  @override
  String get plan_essential => 'Essencial';

  @override
  String get plan_pro => 'Pro';

  @override
  String get plan_custom => 'À medida';

  @override
  String get adminQuota => 'Quota de digitalizações por mês';

  @override
  String get adminQuotaHint => 'Vazio: quota do plano';

  @override
  String adminScans(int scans, int quota) {
    return '$scans / $quota digitalizações';
  }

  @override
  String adminItemsAtelier(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count materiais',
      one: '1 material',
      zero: 'nenhum material',
    );
    return '$_temp0';
  }

  @override
  String adminItemsSupplier(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count referências',
      one: '1 referência',
      zero: 'nenhuma referência',
    );
    return '$_temp0';
  }

  @override
  String adminTokens(String input, String output) {
    return 'Tokens: $input de entrada · $output de saída';
  }

  @override
  String adminCost(String cost) {
    return 'Custo de IA estimado: $cost';
  }

  @override
  String adminTotalCost(String cost) {
    return 'Custo de IA do mês, todas as organizações: $cost';
  }

  @override
  String get adminEditPlan => 'Alterar o plano';

  @override
  String get adminPlanSaved =>
      'Plano atualizado: a nova quota aplica-se de imediato ao digitalizador.';

  @override
  String get adminPricingTitle =>
      'Tarifa do modelo de IA (\$ por milhão de tokens)';

  @override
  String get adminPricingInput => 'Entrada';

  @override
  String get adminPricingOutput => 'Saída';

  @override
  String get adminPreviousMonth => 'Mês anterior';

  @override
  String get adminNextMonth => 'Mês seguinte';

  @override
  String get proRequired => 'Funcionalidade reservada ao plano Pro.';

  @override
  String get proLocked => 'Disponível com o plano Pro';

  @override
  String get modelStatusLabel => 'Estado';

  @override
  String get modelStatusIdea => 'Ideia';

  @override
  String get modelStatusPrototype => 'Protótipo';

  @override
  String get modelStatusValidated => 'Validado';

  @override
  String get modelStatusInProduction => 'Em produção';

  @override
  String get modelStatusDelivered => 'Entregue';

  @override
  String get modelStatusAbandoned => 'Abandonado';

  @override
  String get modelStatusFinal => 'Um modelo entregue já não muda de estado.';

  @override
  String get deadlinesTitle => 'Prazos';

  @override
  String get deadlineHelp =>
      'Data até à qual o modelo deve atingir cada etapa.';

  @override
  String get deadlineNone => 'Sem prazo';

  @override
  String get deadlineClear => 'Apagar o prazo';

  @override
  String get deadlineOverdueTag => 'Atrasado';

  @override
  String get tabModels => 'Modelos';

  @override
  String get tabPlanning => 'Planeamento';

  @override
  String get planningEmpty =>
      'Ainda não há prazos nesta coleção. Defina-os em cada modelo.';

  @override
  String get planningNoDeadline => 'Sem prazo';

  @override
  String planningNext(String stage, String date) {
    return '$stage previsto a $date';
  }

  @override
  String notifDeadlineOverdue(String name, String stage, String date) {
    return 'Prazo ultrapassado: $name — $stage previsto a $date';
  }

  @override
  String get sizesTitle => 'Tamanhos';

  @override
  String get sizeChartLabel => 'Tabela de tamanhos';

  @override
  String get sizeChartNone => 'Sem tabela (quantidade por cor)';

  @override
  String get sizeChartAlpha => 'XS–XXL';

  @override
  String get sizeChartEu => '34–48';

  @override
  String get sizeChartShoes => 'Números 35–46';

  @override
  String get sizeChartOne => 'Tamanho único';

  @override
  String get sizeChartsTitle => 'Tabelas de tamanhos';

  @override
  String get sizeChartsBuiltIn => 'Fornecidas pela Filyxa';

  @override
  String get sizeChartsMine => 'Tabelas do ateliê';

  @override
  String get sizeChartsMineEmpty => 'Nenhuma tabela própria.';

  @override
  String get sizeChartNew => 'Nova tabela';

  @override
  String get sizeChartEdit => 'Editar tabela';

  @override
  String get sizeChartName => 'Nome da tabela';

  @override
  String get sizeChartSizes => 'Tamanhos, por ordem, separados por vírgulas';

  @override
  String get sizeChartChangeTitle => 'Mudar de tabela?';

  @override
  String get sizeChartChangeBody =>
      'As quantidades dos tamanhos ausentes da nova tabela serão apagadas.';

  @override
  String get sizeChartFromColorwaysBody =>
      'As quantidades introduzidas por cor serão substituídas pelas quantidades por tamanho, a introduzir na tabela.';

  @override
  String get sizeChartChange => 'Mudar';

  @override
  String get totalLabel => 'Total';

  @override
  String get sizeErrorInUse =>
      'Um tamanho com quantidades num modelo não pode ser removido.';

  @override
  String get sizeErrorInvalid =>
      'Os tamanhos devem ser distintos e não vazios (máx. 12 caracteres).';

  @override
  String get sizeChartInUse =>
      'Esta tabela é usada por um modelo: impossível eliminá-la.';

  @override
  String get sizeChartDeleteTitle => 'Eliminar a tabela?';

  @override
  String get baseSizeLabel => 'Tamanho base';

  @override
  String get gradePctLabel => 'Diferença por tamanho (%)';

  @override
  String gradingSummary(String base, String pct) {
    return 'Tamanho base: $base · $pct % por tamanho';
  }

  @override
  String get gradeRowLabel => 'Diferença';

  @override
  String get baseSizeTag => 'base';

  @override
  String sizeGradeTitle(String size) {
    return 'Diferença do tamanho $size';
  }

  @override
  String get sizeGradeLabel => 'Diferença em relação à base (%)';

  @override
  String get sizeGradeHelp => 'Por exemplo 10 para +10 %, -5 para −5 %.';

  @override
  String get sizeGradeReset => 'Voltar à diferença do modelo';

  @override
  String get requirementBySize => 'Detalhe por tamanho e cor';

  @override
  String requirementFormulaGraded(String waste) {
    return 'Consumo do tamanho base × (1 + diferença do tamanho) × quantidade × (1 + $waste % de perda)';
  }

  @override
  String get prototypingTitle => 'Prototipagem';

  @override
  String get prototypingHelp =>
      'Metros consumidos pelos protótipos (testes de cola, testes de material, sublimação com margem nos lados), calculados no tamanho base da primeira cor.';

  @override
  String get prototypeCountLabel => 'Número de protótipos';

  @override
  String get protoLossLabel => 'Perda proto (%)';

  @override
  String requirementSplit(String production, String prototype) {
    return 'Produção $production · Prototipagem $prototype';
  }

  @override
  String get productionReserveTitle => 'Lançar em produção';

  @override
  String get productionReserveBody =>
      'A necessidade de cada material (produção e prototipagem) será reservada no stock do ateliê.';

  @override
  String get productionDeliverTitle => 'Entregar o modelo';

  @override
  String get productionDeliverBody =>
      'Os metros consumidos serão deduzidos do stock do ateliê. Ajuste-os se o consumo real foi diferente.';

  @override
  String productionAvailable(String meters) {
    return 'Disponível: $meters';
  }

  @override
  String productionStock(String meters) {
    return 'Stock do ateliê: $meters';
  }

  @override
  String productionShortage(String meters) {
    return 'Em falta: $meters';
  }

  @override
  String get productionShortageNote =>
      'O stock disponível não cobre toda a necessidade. Pode encomendar o resto ou lançar mesmo assim.';

  @override
  String get productionLaunch => 'Reservar e lançar';

  @override
  String get productionLaunchAnyway => 'Lançar mesmo assim';

  @override
  String get productionDeliver => 'Deduzir e entregar';

  @override
  String get productionUsed => 'Consumido';

  @override
  String get productionNoMaterial => 'Nenhum material neste modelo.';

  @override
  String stockReserved(String meters) {
    return 'Reservado: $meters';
  }

  @override
  String stockAvailable(String meters) {
    return 'Disponível: $meters';
  }

  @override
  String get costTitle => 'Custo de produção';

  @override
  String costPerPiece(String amount) {
    return '$amount / peça';
  }

  @override
  String costPerPieceShort(String amount) {
    return '$amount / peça';
  }

  @override
  String costFlat(String amount) {
    return '$amount fixo';
  }

  @override
  String get costMaterials => 'Materiais (perdas incluídas)';

  @override
  String get costKindSupply => 'Aviamento';

  @override
  String get costKindLabor => 'Confeção';

  @override
  String get costKindOverhead => 'Despesas';

  @override
  String get costAdd => 'Adicionar um custo';

  @override
  String get costEdit => 'Editar custo';

  @override
  String get costLabel => 'Descrição';

  @override
  String get costUnitPrice => 'Preço unitário';

  @override
  String get costQuantity => 'Quantidade por peça';

  @override
  String get costQuantityFlat => 'Quantidade para o modelo';

  @override
  String get costPerModelSwitch => 'Valor fixo para todo o modelo';

  @override
  String costTotal(int pieces) {
    return 'Total de produção ($pieces peças)';
  }

  @override
  String get costPrototyping => 'Prototipagem (materiais)';

  @override
  String costIncomplete(String materials) {
    return 'Custo incompleto: sem preço para $materials.';
  }

  @override
  String get costIncompleteShort => 'Custo incompleto: há materiais sem preço.';

  @override
  String collectionCost(String amount) {
    return 'Custo da coleção: $amount';
  }

  @override
  String collectionCostPrototyping(String amount) {
    return 'Prototipagem, à parte: $amount';
  }

  @override
  String get costTargetPrice => 'Preço de venda pretendido';

  @override
  String coefficientValue(String value) {
    return 'Coeficiente: $value';
  }

  @override
  String coefficientLow(String value, String min) {
    return 'Coeficiente $value < $min';
  }

  @override
  String get coefficientNeedPrice =>
      'Introduza um preço de venda pretendido para calcular o coeficiente.';

  @override
  String get coefficientIncomplete =>
      'Coeficiente indisponível: custo incompleto.';

  @override
  String get workspaceTitle => 'Definições do ateliê';

  @override
  String get minCoefficientLabel => 'Coeficiente mínimo';

  @override
  String get minCoefficientHelp =>
      'Um modelo cujo coeficiente (preço de venda ÷ custo por peça) fique abaixo é assinalado no Studio.';

  @override
  String get workspaceSaved => 'Definição guardada.';

  @override
  String get colorwayColorTitle => 'Cor da variante';

  @override
  String get colorwayColorHex => 'Código de cor (#RRGGBB)';
}
