// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Filyxa';

  @override
  String get navLibrary => 'TissuTech';

  @override
  String get navStudio => 'Studio';

  @override
  String get navScanner => 'Escáner';

  @override
  String get navSuppliers => 'Proveedores';

  @override
  String get navAccount => 'Cuenta';

  @override
  String get comingSoonTitle => 'Próximamente';

  @override
  String get comingSoonBody =>
      'Esta sección llegará en una próxima versión de Filyxa.';

  @override
  String get emailLabel => 'Correo electrónico';

  @override
  String get passwordLabel => 'Contraseña';

  @override
  String get newPasswordLabel => 'Nueva contraseña';

  @override
  String get confirmPasswordLabel => 'Confirmar contraseña';

  @override
  String get passwordHelper =>
      'Mínimo 8 caracteres, con al menos una letra y un número';

  @override
  String get codeLabel => 'Código de 6 dígitos';

  @override
  String get showPassword => 'Mostrar contraseña';

  @override
  String get hidePassword => 'Ocultar contraseña';

  @override
  String get loginTitle => 'Iniciar sesión';

  @override
  String get loginSubtitle =>
      'Accede a la biblioteca de materiales de tu taller.';

  @override
  String get loginButton => 'Iniciar sesión';

  @override
  String get forgotPassword => '¿Olvidaste tu contraseña?';

  @override
  String get haveInvitation => 'He recibido una invitación';

  @override
  String get devQuickLogin => 'Acceso rápido (dev)';

  @override
  String get inviteTitle => 'Únete a tu equipo';

  @override
  String get inviteIntro =>
      'Introduce tu correo y el código de 6 dígitos recibido en el correo de invitación.';

  @override
  String get verifyCode => 'Verificar el código';

  @override
  String get resendCode => 'Recibir un código nuevo';

  @override
  String codeResent(String email) {
    return 'Si hay una invitación pendiente para $email, se acaba de enviar un código nuevo.';
  }

  @override
  String get choosePasswordTitle => 'Elige tu contraseña';

  @override
  String choosePasswordIntro(String organization) {
    return 'Bienvenido a $organization. Elige la contraseña de tu cuenta.';
  }

  @override
  String get savePassword => 'Guardar y entrar';

  @override
  String get invitationExpiredTitle => 'Invitación caducada';

  @override
  String get invitationExpiredBody =>
      'Esta invitación ha caducado. Pide al administrador de tu taller que te envíe una nueva.';

  @override
  String get invitationNotFound =>
      'No hay ninguna invitación pendiente para esta dirección. Comprueba el correo utilizado o pide una nueva invitación.';

  @override
  String get alreadyMember => 'Esta cuenta ya pertenece a una organización.';

  @override
  String get backToLogin => 'Volver al inicio de sesión';

  @override
  String get resetTitle => 'Contraseña olvidada';

  @override
  String get resetIntro =>
      'Introduce el correo de tu cuenta: recibirás un código de restablecimiento.';

  @override
  String get sendCode => 'Enviar el código';

  @override
  String resetCodeSent(String email) {
    return 'Si existe una cuenta para $email, se le acaba de enviar un código de 6 dígitos.';
  }

  @override
  String get resetButton => 'Cambiar la contraseña';

  @override
  String get passwordChanged => 'Contraseña cambiada. Has iniciado sesión.';

  @override
  String get errorEmailInvalid => 'Correo electrónico no válido';

  @override
  String get errorPasswordShort => 'Mínimo 8 caracteres';

  @override
  String get errorPasswordWeak => 'Al menos una letra y un número';

  @override
  String get errorPasswordMismatch => 'Las contraseñas no coinciden';

  @override
  String get errorCodeInvalid => 'Introduce el código de 6 dígitos';

  @override
  String get errorBadCredentials => 'Correo o contraseña incorrectos';

  @override
  String get errorCodeExpired =>
      'Código incorrecto o caducado. Solicita uno nuevo.';

  @override
  String get errorNetwork =>
      'No se puede conectar. Comprueba tu red e inténtalo de nuevo.';

  @override
  String get errorTooManyRequests =>
      'Demasiados intentos. Espera unos minutos antes de volver a intentarlo.';

  @override
  String get errorForbidden => 'Acción reservada a los administradores.';

  @override
  String get errorEmailNotSent =>
      'No se ha podido enviar el correo. Inténtalo de nuevo en unos minutos.';

  @override
  String get errorGeneric => 'Se ha producido un error. Inténtalo de nuevo.';

  @override
  String get errorOrgName => 'Entre 2 y 120 caracteres';

  @override
  String get retry => 'Reintentar';

  @override
  String get cancel => 'Cancelar';

  @override
  String get logout => 'Cerrar sesión';

  @override
  String get accountTitle => 'Mi cuenta';

  @override
  String get languageLabel => 'Idioma';

  @override
  String get organizationLabel => 'Organización';

  @override
  String get roleLabel => 'Rol';

  @override
  String get roleAdmin => 'Admin';

  @override
  String get roleEditor => 'Editor';

  @override
  String get roleViewer => 'Lector';

  @override
  String get superadminConsole => 'Consola de superadministrador';

  @override
  String get noOrgTitle => 'Ninguna organización';

  @override
  String get noOrgBody =>
      'Tu cuenta no está vinculada a ninguna organización. Pide una invitación al administrador de tu taller.';

  @override
  String get loadingError => 'No se puede cargar tu espacio.';

  @override
  String get adminTitle => 'Consola de superadministrador';

  @override
  String get adminNewAtelier => 'Nuevo taller';

  @override
  String get adminEmpty =>
      'Todavía no hay organizaciones. Crea el primer taller piloto.';

  @override
  String get adminOrgName => 'Nombre del taller';

  @override
  String get adminAdminEmail => 'Correo de su administrador';

  @override
  String get adminCreate => 'Crear e invitar';

  @override
  String adminCreated(String email) {
    return 'Taller creado. Invitación enviada a $email.';
  }

  @override
  String adminInvitePending(String email, String date) {
    return 'Invitación pendiente: $email · caduca el $date';
  }

  @override
  String adminInviteExpired(String email) {
    return 'Invitación caducada: $email';
  }

  @override
  String adminMembers(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count miembros',
      one: '1 miembro',
      zero: 'Ningún miembro',
    );
    return '$_temp0';
  }

  @override
  String get adminReinvite => 'Reenviar la invitación';

  @override
  String adminReinvited(String email) {
    return 'Invitación reenviada a $email.';
  }

  @override
  String get orgKindAtelier => 'Taller';

  @override
  String get orgKindSupplier => 'Proveedor';

  @override
  String get missingConfig =>
      'Falta la configuración de Supabase. Copia env.example.json en env.json, rellénalo y ejecuta: flutter run --dart-define-from-file=env.json';

  @override
  String get membersEntry => 'Miembros del taller';

  @override
  String get membersTitle => 'Miembros';

  @override
  String get membersInvite => 'Invitar';

  @override
  String get inviteDialogTitle => 'Invitar a un miembro';

  @override
  String get inviteSend => 'Enviar la invitación';

  @override
  String get roleAdminHelp => 'Gestiona los miembros y los ajustes del taller';

  @override
  String get roleEditorHelp => 'Crea, modifica, escanea, importa y comparte';

  @override
  String get roleViewerHelp => 'Consulta y exporta, sin modificar nada';

  @override
  String get youSuffix => 'tú';

  @override
  String get pendingInvitations => 'Invitaciones pendientes';

  @override
  String invitationExpiresOn(String date) {
    return 'Caduca el $date';
  }

  @override
  String get invitationExpiredShort => 'Caducada';

  @override
  String get resendInvitation => 'Reenviar';

  @override
  String get cancelInvitation => 'Cancelar la invitación';

  @override
  String invitationSent(String email) {
    return 'Invitación enviada a $email.';
  }

  @override
  String get invitationCanceled => 'Invitación cancelada.';

  @override
  String get changeRole => 'Cambiar el rol';

  @override
  String get roleChanged => 'Rol actualizado.';

  @override
  String get removeMember => 'Quitar del taller';

  @override
  String removeConfirmTitle(String name) {
    return '¿Quitar a $name?';
  }

  @override
  String get removeConfirmBody =>
      'Esta persona perderá inmediatamente el acceso a los datos del taller. Podrás invitarla de nuevo.';

  @override
  String get removeConfirm => 'Quitar';

  @override
  String get memberRemoved => 'Miembro eliminado.';

  @override
  String get errorLastAdmin =>
      'El taller debe conservar al menos un administrador. Nombra antes a otro administrador.';

  @override
  String get lastAdminHint => 'Único administrador del taller';

  @override
  String memberActions(String name) {
    return 'Acciones para $name';
  }

  @override
  String get libraryNew => 'Nuevo material';

  @override
  String get viewGallery => 'Galería';

  @override
  String get viewTable => 'Tabla';

  @override
  String get libraryEmptyTitle => 'Tu TissuTech está vacío';

  @override
  String get libraryEmptyBody =>
      'Añade tus primeros materiales: escanea la etiqueta de una muestra, importa tu archivo Excel o introdúcelos a mano.';

  @override
  String get libraryEmptyViewer =>
      'Todavía no hay materiales. Los editores de tu taller pueden añadirlos.';

  @override
  String get actionScanSample => 'Escanear una muestra';

  @override
  String get actionImportExcel => 'Importar un archivo Excel';

  @override
  String get actionCreateManual => 'Introducir a mano';

  @override
  String materialCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count materiales',
      one: '1 material',
      zero: 'Ningún material',
    );
    return '$_temp0';
  }

  @override
  String get colMaterial => 'Material';

  @override
  String get colReference => 'Referencia';

  @override
  String get colComposition => 'Composición';

  @override
  String get colWeight => 'g/m²';

  @override
  String get colWidth => 'Ancho';

  @override
  String get colStock => 'Stock del taller';

  @override
  String get fieldName => 'Nombre del material';

  @override
  String get fieldSupplier => 'Proveedor';

  @override
  String get fieldSupplierCode => 'Código de artículo';

  @override
  String get fieldColorName => 'Color';

  @override
  String get fieldColorHex => 'Color (#RRGGBB)';

  @override
  String get photoAdd => 'Añadir una foto';

  @override
  String get photoChange => 'Cambiar la foto';

  @override
  String get photoRemove => 'Quitar la foto';

  @override
  String get sectionIdentity => 'Identidad';

  @override
  String get sectionColor => 'Color y foto';

  @override
  String get sectionComposition => 'Composición';

  @override
  String get sectionTechnical => 'Características';

  @override
  String get sectionCare => 'Cuidado';

  @override
  String get sectionUses => 'Usos y certificaciones';

  @override
  String get sectionStock => 'Stock del taller';

  @override
  String get sectionNotes => 'Notas';

  @override
  String get addFiber => 'Añadir una fibra';

  @override
  String get removeFiber => 'Quitar esta fibra';

  @override
  String get fiberLabel => 'Fibra';

  @override
  String compositionTotal(String total) {
    return 'Total: $total %';
  }

  @override
  String get compositionMustBe100 =>
      'El total debe ser 100 %, sin fibras repetidas';

  @override
  String get fieldWeight => 'Gramaje (g/m²)';

  @override
  String get fieldWidth => 'Ancho (cm)';

  @override
  String get fieldWeave => 'Ligamento';

  @override
  String get noneOption => 'Sin indicar';

  @override
  String get fieldCertifications => 'Certificaciones';

  @override
  String get fieldUses => 'Usos';

  @override
  String get fieldStock => 'Metros en stock (m)';

  @override
  String get errorRequired => 'Campo obligatorio';

  @override
  String errorNumberRange(int min, int max) {
    return 'Número entre $min y $max';
  }

  @override
  String get errorHex => 'Formato esperado #RRGGBB (p. ej. #2F4A6B)';

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
    return '¿Eliminar «$name»?';
  }

  @override
  String get deleteMaterialBody =>
      'El material y su foto se eliminarán definitivamente.';

  @override
  String get materialDeleted => 'Material eliminado.';

  @override
  String get editStock => 'Editar stock';

  @override
  String get stockUpdated => 'Stock actualizado.';

  @override
  String stockMeters(String value) {
    return '$value m';
  }

  @override
  String get materialNotFound =>
      'Este material ya no existe o no es accesible.';

  @override
  String get newMaterialTitle => 'Nuevo material';

  @override
  String get editMaterialTitle => 'Editar el material';

  @override
  String get detailWeight => 'Gramaje';

  @override
  String get detailWidth => 'Ancho';

  @override
  String get photoUploadFailed =>
      'No se ha podido subir la foto. Inténtalo de nuevo.';

  @override
  String get viewerReadOnly => 'Solo lectura';

  @override
  String get errorEditorsOnly =>
      'Acción reservada a los editores y administradores del taller.';

  @override
  String get searchHint => 'Buscar: nombre, código, proveedor, color, fibra…';

  @override
  String get clearSearch => 'Borrar la búsqueda';

  @override
  String get filtersButton => 'Filtros';

  @override
  String get clearFilters => 'Borrar los filtros';

  @override
  String get showResults => 'Ver los resultados';

  @override
  String get noResultsTitle => 'Sin resultados';

  @override
  String get noResultsBody =>
      'Ningún material coincide con tu búsqueda o tus filtros.';

  @override
  String resultCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count resultados',
      one: '1 resultado',
      zero: 'Sin resultados',
    );
    return '$_temp0';
  }

  @override
  String get filterFiber => 'Fibra';

  @override
  String get filterFiberAny => 'Todas las fibras';

  @override
  String filterFiberMin(int pct) {
    return 'Al menos $pct %';
  }

  @override
  String get filterWeight => 'Gramaje';

  @override
  String get filterColor => 'Color';

  @override
  String get filterInStock => 'En stock en el taller';

  @override
  String removeFilter(String label) {
    return 'Quitar el filtro $label';
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
  String get catalogEmptyTitle => 'Tu catálogo está vacío';

  @override
  String get catalogEmptyBody =>
      'Importa tu catálogo desde un archivo Excel o CSV exportado de tu software de gestión.';

  @override
  String get catalogImport => 'Importar un archivo';

  @override
  String get catalogSettings => 'Disponibilidad';

  @override
  String referenceCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count referencias',
      one: '1 referencia',
      zero: 'Ninguna referencia',
    );
    return '$_temp0';
  }

  @override
  String get showRetired => 'Mostrar las referencias retiradas';

  @override
  String get retiredBadge => 'Retirada';

  @override
  String get colStatus => 'Disponibilidad';

  @override
  String get colLeadTime => 'Plazo';

  @override
  String get statusAvailable => 'Disponible';

  @override
  String get statusLow => 'Stock bajo';

  @override
  String get statusOnOrder => 'Bajo pedido';

  @override
  String statusOnOrderWeeks(int weeks) {
    return 'Bajo pedido · $weeks sem.';
  }

  @override
  String get statusOutOfStock => 'Agotado';

  @override
  String get statusHidden => 'Oculta';

  @override
  String get modeExact => 'Cantidad exacta';

  @override
  String get modeTiers => 'Niveles';

  @override
  String get modeHidden => 'Oculta';

  @override
  String get modeExactHelp => 'Los talleres ven tus metros exactos en stock.';

  @override
  String get modeTiersHelp =>
      'Los talleres solo ven: disponible, stock bajo, bajo pedido o agotado.';

  @override
  String get modeHiddenHelp => 'Los talleres no ven la disponibilidad.';

  @override
  String modeDefault(String mode) {
    return 'Ajuste general ($mode)';
  }

  @override
  String get thresholdLabel => 'Umbral de stock bajo (m)';

  @override
  String get thresholdHelp =>
      'Por debajo de estos metros, la referencia aparece como «stock bajo».';

  @override
  String get leadTimeLabel => 'Plazo de reposición (semanas)';

  @override
  String get leadTimeHelp =>
      'Se muestra cuando la referencia está bajo pedido.';

  @override
  String get availabilitySettingsTitle => 'Visualización de la disponibilidad';

  @override
  String get availabilitySettingsIntro =>
      'Elige qué ven los talleres de tu stock. Puedes ajustar cada referencia desde su ficha.';

  @override
  String get settingsSaved => 'Ajustes guardados.';

  @override
  String get referenceRetire => 'Retirar del catálogo';

  @override
  String get referenceRestore => 'Volver a publicar';

  @override
  String get referenceRetired => 'Referencia retirada del catálogo publicado.';

  @override
  String get referenceRestored => 'Referencia publicada de nuevo.';

  @override
  String retireConfirmTitle(String code) {
    return '¿Retirar «$code»?';
  }

  @override
  String get retireConfirmBody =>
      'Los talleres ya no la verán. Quienes la usan conservarán su última ficha. Podrás volver a publicarla.';

  @override
  String get referenceAvailabilityTitle => 'Disponibilidad de esta referencia';

  @override
  String get stockLabel => 'Stock';

  @override
  String whatAteliersSee(String value) {
    return 'Lo que ven los talleres: $value';
  }

  @override
  String get importTitle => 'Importar el catálogo';

  @override
  String get importPickFile => 'Elegir un archivo Excel o CSV';

  @override
  String get importPickHelp =>
      'Archivo .xlsx o .csv, una fila por referencia y una fila de encabezados. 5.000 filas como máximo. Una referencia conocida se actualiza por su código.';

  @override
  String get importUnreadable =>
      'No se ha podido leer este archivo. Guárdalo en formato .xlsx o .csv e inténtalo de nuevo.';

  @override
  String importTooMany(int count) {
    return 'Este archivo contiene $count filas: 5.000 como máximo por importación.';
  }

  @override
  String get importMappingTitle => 'Asocia tus columnas';

  @override
  String get importMappingIntro =>
      'Las columnas reconocidas ya están asociadas. El código y la denominación son obligatorios.';

  @override
  String get importColumnNone => '— Ignorar —';

  @override
  String get importFieldName => 'Denominación';

  @override
  String get importFieldStock => 'Stock (m)';

  @override
  String importSummary(int valid, int invalid) {
    return '$valid filas listas · $invalid con errores';
  }

  @override
  String get importErrorsTitle => 'Filas con errores (no importadas)';

  @override
  String importLine(int line) {
    return 'Fila $line';
  }

  @override
  String importRun(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Importar $count referencias',
      one: 'Importar 1 referencia',
    );
    return '$_temp0';
  }

  @override
  String importRunning(int done, int total) {
    return 'Importando… $done/$total';
  }

  @override
  String get importDoneTitle => 'Importación terminada';

  @override
  String importDone(int inserted, int updated) {
    return '$inserted creadas · $updated actualizadas';
  }

  @override
  String importServerRejected(String message) {
    return 'Rechazada por el servidor: $message';
  }

  @override
  String get importAgain => 'Importar otro archivo';

  @override
  String get backToCatalog => 'Volver al catálogo';

  @override
  String importFileName(String name) {
    return 'Archivo: $name';
  }

  @override
  String get issueMissingCode => 'Falta el código';

  @override
  String get issueMissingName => 'Falta la denominación';

  @override
  String issueComposition(String value) {
    return 'Composición ilegible o distinta del 100 %: «$value»';
  }

  @override
  String issueNumber(String field, String value) {
    return '$field: valor no válido «$value»';
  }

  @override
  String issueColor(String value) {
    return 'Color no válido «$value» (formato #RRGGBB)';
  }

  @override
  String issueDuplicate(String value) {
    return 'El código «$value» aparece varias veces en el archivo';
  }

  @override
  String get adminOrgKind => 'Tipo de organización';

  @override
  String get adminNewOrg => 'Nueva organización';

  @override
  String get adminOrgNameGeneric => 'Nombre de la organización';

  @override
  String get scanTitle => 'Escanear una muestra';

  @override
  String get scanIntro =>
      'Fotografía la etiqueta de la muestra, plana y nítida. Filyxa lee la composición, el gramaje, el ancho, el cuidado y el código; tú lo compruebas antes de guardar.';

  @override
  String get scanTakePhoto => 'Hacer una foto';

  @override
  String get scanImportPhoto => 'Importar una foto';

  @override
  String get scanReading => 'Leyendo la etiqueta…';

  @override
  String scanUsage(int scans, int quota) {
    return '$scans / $quota escaneos este mes';
  }

  @override
  String scanQuotaWarning(int percent) {
    return 'Se ha usado el $percent % de la cuota mensual de escaneos.';
  }

  @override
  String get scanQuotaExhausted =>
      'Cuota mensual de escaneos alcanzada. Puedes seguir introduciendo materiales a mano.';

  @override
  String get scanFailureNotLabel =>
      'No hay ninguna etiqueta textil legible en esta foto. Vuelve a hacerla más cerca, plana y sin reflejos.';

  @override
  String get scanFailureRefused =>
      'Se ha rechazado el análisis de esta imagen. Prueba con otra foto.';

  @override
  String get scanFailureAi =>
      'El servicio de lectura no está disponible en este momento. Inténtalo de nuevo en un instante.';

  @override
  String get scanFailureImage =>
      'Esta imagen no es compatible (JPEG, PNG o WebP, 5 MB como máximo).';

  @override
  String get prefillBanner =>
      'Ficha rellenada por el escaneo. Comprueba los campos señalados antes de guardar.';

  @override
  String get fieldUncertain => 'Leído con poca certeza: compruébalo';

  @override
  String get sectionUncertain => 'Lectura incierta: comprueba esta sección.';

  @override
  String duplicateFound(String name) {
    return 'Ya existe un material con este código: «$name».';
  }

  @override
  String get duplicateOpen => 'Abrir la ficha existente';

  @override
  String get matchTitle => '¿Es esta la referencia?';

  @override
  String matchIntro(String supplier) {
    return 'Encontrada en el catálogo de $supplier. Confirma para vincular tu ficha a sus datos y a su disponibilidad.';
  }

  @override
  String get matchConfirm => 'Sí, vincular esta referencia';

  @override
  String get matchOthers => 'Otras referencias cercanas';

  @override
  String get matchNone => 'Ninguna de estas referencias';

  @override
  String get supplierData => 'Datos del proveedor';

  @override
  String get supplierDataHelp =>
      'Actualizados por el proveedor, no editables aquí.';

  @override
  String get referenceRetiredBanner =>
      'Referencia retirada por el proveedor. Se conservan los últimos valores conocidos.';

  @override
  String get linkToSupplier => 'Vincular a una referencia del proveedor';

  @override
  String get linkSearchHint => 'Código, denominación o proveedor';

  @override
  String get linkSearchEmpty => 'Ninguna referencia publicada coincide.';

  @override
  String get linkConfirm => 'Vincular';

  @override
  String get unlink => 'Desvincular la referencia';

  @override
  String get unlinkConfirmBody =>
      'La ficha conserva sus valores actuales y vuelve a ser editable. Ya no seguirá las actualizaciones del proveedor.';

  @override
  String get linkedDone => 'Ficha vinculada al proveedor.';

  @override
  String get unlinkedDone => 'Ficha desvinculada del proveedor.';

  @override
  String get privateLayer => 'Información del taller';

  @override
  String get privateLayerHelp => 'Visibles solo para tu taller.';

  @override
  String get fieldPrice => 'Precio negociado (€/m)';

  @override
  String get fieldTags => 'Etiquetas';

  @override
  String get fieldTagsHint => 'Separadas por comas (p. ej. OI27, por validar)';

  @override
  String priceValue(String value) {
    return '$value €/m';
  }

  @override
  String get atelierImportTitle => 'Importar la base del taller';

  @override
  String get atelierImportHelp =>
      'Archivo .xlsx o .csv, una fila por material y una fila de encabezados. 5.000 filas como máximo. Un material ya existente (mismo proveedor y código, o mismo nombre y color) se actualiza, nunca se duplica.';

  @override
  String get atelierImportMappingIntro =>
      'Las columnas reconocidas ya están asociadas. Solo el nombre del material es obligatorio.';

  @override
  String atelierImportRun(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Importar $count materiales',
      one: 'Importar 1 material',
    );
    return '$_temp0';
  }

  @override
  String atelierImportDone(int imported, int linked, int pending, int errors) {
    return '$imported importados · $linked vinculados a un proveedor · $pending por confirmar · $errors con errores';
  }

  @override
  String atelierImportDetail(int inserted, int updated) {
    return 'de ellos $inserted nuevos y $updated actualizados';
  }

  @override
  String get backToLibrary => 'Volver a TissuTech';

  @override
  String reviewLinksAction(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Confirmar $count coincidencias',
      one: 'Confirmar 1 coincidencia',
    );
    return '$_temp0';
  }

  @override
  String pendingLinksBanner(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count materiales importados se parecen a referencias de proveedor.',
      one: '1 material importado se parece a una referencia de proveedor.',
    );
    return '$_temp0';
  }

  @override
  String get reviewTitle => 'Coincidencias por confirmar';

  @override
  String reviewProgress(int index, int total) {
    return '$index de $total';
  }

  @override
  String get reviewIntro =>
      'Su ficha se parece a una referencia publicada. Confirme para vincularla a sus datos y disponibilidad.';

  @override
  String get reviewSkip => 'Más tarde';

  @override
  String get reviewDone => 'Se han tratado todas las coincidencias.';

  @override
  String get reviewNoCandidate =>
      'Ya ninguna referencia publicada corresponde a este material.';

  @override
  String get reviewOpen => 'Revisar';

  @override
  String get reportAction => 'Señalar un error';

  @override
  String get reportTitle => 'Señalar un error al proveedor';

  @override
  String get reportIntro =>
      'El proveedor corregirá la ficha para todos los talleres. No ve el nombre de su taller, salvo si decide compartirlo.';

  @override
  String get reportField => 'Campo';

  @override
  String get reportObserved => 'Valor constatado';

  @override
  String get reportObservedHint => 'Ej. 300 g/m² medidos en la muestra';

  @override
  String get reportComment => 'Comentario (opcional)';

  @override
  String get reportShareIdentity =>
      'Compartir el nombre de mi taller con el proveedor';

  @override
  String get reportSend => 'Enviar';

  @override
  String get reportSent => 'Señalamiento enviado al proveedor.';

  @override
  String get reportFieldAvailability => 'Disponibilidad';

  @override
  String get reportFieldOther => 'Otro';

  @override
  String get reportsSection => 'Señalamientos';

  @override
  String get reportStatusOpen => 'Abierto';

  @override
  String get reportStatusFixed => 'Corregido';

  @override
  String get reportStatusRejected => 'Rechazado';

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
    return 'Respuesta: $response';
  }

  @override
  String get supplierReportsTitle => 'Señalamientos de los talleres';

  @override
  String supplierReportsButton(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count señalamientos abiertos',
      one: '1 señalamiento abierto',
      zero: 'Señalamientos',
    );
    return '$_temp0';
  }

  @override
  String get supplierReportsEmpty => 'Ningún señalamiento por ahora.';

  @override
  String get reportAnonymous => 'Taller anónimo';

  @override
  String get reportMarkFixed => 'Marcar como corregido';

  @override
  String get reportReject => 'Rechazar';

  @override
  String get reportRejectTitle => 'Rechazar el señalamiento';

  @override
  String get reportRejectReason => 'Motivo del rechazo';

  @override
  String get reportFixTitle => 'Marcar como corregido';

  @override
  String get reportFixHelp =>
      'Recuerde corregir la referencia en su catálogo: los talleres vinculados la verán de inmediato.';

  @override
  String get reportFixMessage => 'Mensaje al taller (opcional)';

  @override
  String get reportEditReference => 'Abrir la referencia';

  @override
  String get reportFilterOpen => 'Abiertos';

  @override
  String get reportFilterAll => 'Todos';

  @override
  String get notificationsTitle => 'Notificaciones';

  @override
  String get notificationsEmpty => 'Ninguna notificación.';

  @override
  String notificationsTooltip(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Notificaciones ($count sin leer)',
      one: 'Notificaciones (1 sin leer)',
      zero: 'Notificaciones',
    );
    return '$_temp0';
  }

  @override
  String notifReportNew(String code, String field) {
    return 'Nuevo señalamiento sobre $code · $field';
  }

  @override
  String notifReportFixed(String name, String field) {
    return '$name: el proveedor corrigió «$field»';
  }

  @override
  String notifReportRejected(String name, String field) {
    return '$name: señalamiento sobre «$field» rechazado';
  }
}
