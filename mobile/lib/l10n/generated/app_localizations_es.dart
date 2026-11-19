// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Gimnasio';

  @override
  String get commonRetry => 'Reintentar';

  @override
  String get commonLoading => 'Cargando…';

  @override
  String get commonEmpty => 'No hay nada aquí todavía.';

  @override
  String get commonComingSoon => 'Esta sección estará disponible pronto.';

  @override
  String get splashRestoreFailed => 'No pudimos abrir tu sesión.';

  @override
  String get loginTitle => 'Iniciar sesión';

  @override
  String get loginSubtitle => 'Ingresa con tu número de teléfono.';

  @override
  String get loginCountryCodeLabel => 'Código de país';

  @override
  String get loginPhoneLabel => 'Teléfono';

  @override
  String get loginPhoneHint => '71234567';

  @override
  String get loginPasswordLabel => 'Contraseña';

  @override
  String get loginShowPassword => 'Mostrar contraseña';

  @override
  String get loginHidePassword => 'Ocultar contraseña';

  @override
  String get loginSubmit => 'Ingresar';

  @override
  String get changePasswordTitle => 'Cambiar contraseña';

  @override
  String get changePasswordForcedInfo =>
      'Por seguridad, crea una contraseña nueva antes de continuar.';

  @override
  String get changePasswordCurrentLabel => 'Contraseña actual';

  @override
  String get changePasswordNewLabel => 'Contraseña nueva';

  @override
  String get changePasswordConfirmLabel => 'Repite la contraseña nueva';

  @override
  String get changePasswordSubmit => 'Guardar contraseña';

  @override
  String get changePasswordSuccess => 'Contraseña actualizada.';

  @override
  String get passwordStrengthHint =>
      'Usa al menos 8 caracteres y combina letras, números y símbolos.';

  @override
  String get passwordStrengthWeak => 'Seguridad: débil';

  @override
  String get passwordStrengthMedium => 'Seguridad: media';

  @override
  String get passwordStrengthStrong => 'Seguridad: fuerte';

  @override
  String get validationRequired => 'Este campo es obligatorio.';

  @override
  String get validationPhoneInvalid => 'Ingresa un número de teléfono válido.';

  @override
  String validationPasswordTooShort(int min) {
    return 'Debe tener al menos $min caracteres.';
  }

  @override
  String get validationPasswordsDontMatch => 'Las contraseñas no coinciden.';

  @override
  String get validationPasswordSameAsCurrent =>
      'La nueva contraseña debe ser distinta de la actual.';

  @override
  String get logout => 'Cerrar sesión';

  @override
  String homeGreeting(String name) {
    return 'Hola, $name';
  }

  @override
  String get homeAdminTitle => 'Administración';

  @override
  String get homeTrainerTitle => 'Mis alumnos';

  @override
  String get homeMemberTitle => 'Inicio';

  @override
  String get homeKioskTitle => 'Modo kiosco';

  @override
  String get roleAdmin => 'Administrador';

  @override
  String get roleTrainer => 'Entrenador';

  @override
  String get roleMember => 'Socio';

  @override
  String get roleKiosk => 'Kiosco';

  @override
  String get tierBasic => 'Basic';

  @override
  String get tierPlus => 'Plus';

  @override
  String get tierPremium => 'Premium';

  @override
  String membershipDaysLeft(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Te quedan $count días',
      one: 'Te queda 1 día',
      zero: 'Último día',
    );
    return '$_temp0';
  }

  @override
  String get membershipExpired => 'Membresía vencida — acércate a recepción';

  @override
  String membershipEndDate(String date) {
    return 'Vence el $date';
  }

  @override
  String get membershipNone => 'No tienes una membresía registrada.';

  @override
  String get errorNetwork =>
      'Sin conexión. Revisa tu internet e intenta de nuevo.';

  @override
  String get errorTimeout =>
      'El servidor tardó demasiado en responder. Intenta de nuevo.';

  @override
  String get errorUnknown => 'Ocurrió un error inesperado. Intenta de nuevo.';

  @override
  String get errorValidation => 'Los datos enviados no son válidos.';

  @override
  String get errorBadRequest => 'La solicitud no es válida.';

  @override
  String get errorUnauthorized => 'Tu sesión expiró. Inicia sesión de nuevo.';

  @override
  String get errorForbidden => 'No tienes permiso para realizar esta acción.';

  @override
  String get errorNotFound => 'No se encontró lo que buscabas.';

  @override
  String get errorConflict =>
      'La operación entra en conflicto con el estado actual.';

  @override
  String get errorTooManyRequests =>
      'Demasiados intentos. Espera un momento e intenta de nuevo.';

  @override
  String get errorServer =>
      'El servidor tuvo un problema. Intenta de nuevo más tarde.';

  @override
  String get errorInvalidCredentials => 'Teléfono o contraseña incorrectos.';

  @override
  String get errorPasswordChangeRequired =>
      'Debes cambiar tu contraseña antes de continuar.';

  @override
  String get errorAccountInactive =>
      'Tu cuenta está desactivada. Acércate a recepción.';

  @override
  String get errorPhoneAlreadyExists =>
      'Ya existe una cuenta con ese número de teléfono.';

  @override
  String get errorEmailAlreadyExists => 'Ya existe una cuenta con ese correo.';

  @override
  String get errorWrongCurrentPassword =>
      'La contraseña actual no es correcta.';

  @override
  String get errorPasswordUnchanged =>
      'La nueva contraseña debe ser distinta de la actual.';

  @override
  String get errorLastActiveAdmin =>
      'Debe existir al menos un administrador activo.';

  @override
  String get errorAmountNoteRequired =>
      'Si el monto cambia respecto al sugerido, debes agregar una nota.';

  @override
  String get errorMembershipExpired =>
      'La membresía está vencida. Acércate a recepción para renovar.';

  @override
  String get errorStartDateOutOfRange =>
      'La fecha de inicio debe estar entre 7 días antes y 30 días después de hoy.';

  @override
  String get errorTierUnchanged => 'El socio ya tiene ese plan.';

  @override
  String get errorPaymentAlreadyVoided => 'Este pago ya fue anulado.';

  @override
  String get errorPaymentMethodRequired => 'Indica el método de pago.';

  @override
  String get errorDowngradeHasNoCharge => 'Bajar de plan no tiene cobro.';

  @override
  String get errorNoMembership => 'No hay una membresía registrada.';

  @override
  String get errorQrTokenInvalid => 'Código no válido, vuelve a escanear.';

  @override
  String get errorQrTokenExpired => 'Código vencido, escanea de nuevo.';

  @override
  String get errorTierRequired =>
      'Tu plan de membresía no incluye esta función.';

  @override
  String get errorSessionAlreadyOpen => 'Ya tienes un entrenamiento en curso.';

  @override
  String get commonCancel => 'Cancelar';

  @override
  String get commonConfirm => 'Confirmar';

  @override
  String get commonSave => 'Guardar';

  @override
  String get commonContinue => 'Continuar';

  @override
  String get commonBack => 'Atrás';

  @override
  String get commonDone => 'Listo';

  @override
  String get commonSaved => 'Cambios guardados.';

  @override
  String get commonNotSet => '—';

  @override
  String get navDashboard => 'Dashboard';

  @override
  String get navMembers => 'Socios';

  @override
  String get navCheckins => 'Ingresos';

  @override
  String get navPlans => 'Planes';

  @override
  String get navMore => 'Más';

  @override
  String get membersSearchHint => 'Buscar por nombre o teléfono';

  @override
  String get filterActive => 'Activos';

  @override
  String get filterExpiring => 'Por vencer';

  @override
  String get filterExpired => 'Vencidos';

  @override
  String get filterInactive => 'Inactivos';

  @override
  String get membersEmpty => 'No hay socios con estos filtros.';

  @override
  String get membersNew => 'Nuevo socio';

  @override
  String memberDaysLeftShort(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count días',
      one: '1 día',
    );
    return '$_temp0';
  }

  @override
  String memberExpiredAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Vencido hace $count días',
      one: 'Vencido hace 1 día',
      zero: 'Vencido',
    );
    return '$_temp0';
  }

  @override
  String get memberInactive => 'Inactivo';

  @override
  String memberLastCheckin(String date) {
    return 'Último ingreso: $date';
  }

  @override
  String get memberNoCheckins => 'Sin ingresos';

  @override
  String get memberTabMembership => 'Membresía';

  @override
  String get memberTabPayments => 'Pagos';

  @override
  String get memberTabCheckins => 'Ingresos';

  @override
  String get memberTabProfile => 'Datos';

  @override
  String get memberCall => 'Llamar';

  @override
  String get memberWhatsApp => 'WhatsApp';

  @override
  String get membershipStart => 'Inicio';

  @override
  String get membershipEnd => 'Vence';

  @override
  String membershipNextTier(String tier, String date) {
    return 'Plan $tier desde el $date';
  }

  @override
  String get actionRenew => 'Renovar';

  @override
  String get actionChangeTier => 'Cambiar plan';

  @override
  String get changeTierExpiredHint =>
      'La membresía está vencida: renueva para cambiar de plan.';

  @override
  String get paymentKindNew => 'Inscripción';

  @override
  String get paymentKindRenewal => 'Renovación';

  @override
  String get paymentKindUpgrade => 'Cambio de plan';

  @override
  String paymentMonths(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count meses',
      one: '1 mes',
      zero: 'sin meses',
    );
    return '$_temp0';
  }

  @override
  String paymentRecordedBy(String name, String date) {
    return 'Registrado por $name · $date';
  }

  @override
  String paymentVoided(String reason) {
    return 'Anulado: $reason';
  }

  @override
  String get paymentVoid => 'Anular';

  @override
  String get paymentsEmpty => 'Sin pagos.';

  @override
  String get voidTitle => 'Anular pago';

  @override
  String get voidInfo =>
      'El pago queda registrado como anulado y las fechas de la membresía se recalculan.';

  @override
  String get voidReasonLabel => 'Motivo';

  @override
  String get voidDone => 'Pago anulado. Fechas recalculadas.';

  @override
  String get checkinsEmpty => 'Todavía no registró ingresos.';

  @override
  String get profileFirstName => 'Nombre';

  @override
  String get profileLastName => 'Apellido';

  @override
  String get profilePhone => 'Teléfono';

  @override
  String get profileEmail => 'Correo (opcional)';

  @override
  String get profileBirthDate => 'Fecha de nacimiento';

  @override
  String get profileGender => 'Género';

  @override
  String get profileEmergencyContact => 'Contacto de emergencia';

  @override
  String get profileMedicalNotes => 'Notas médicas';

  @override
  String get genderMale => 'Masculino';

  @override
  String get genderFemale => 'Femenino';

  @override
  String get genderOther => 'Otro';

  @override
  String get actionEdit => 'Editar datos';

  @override
  String get actionResetPassword => 'Restablecer contraseña';

  @override
  String get actionDeactivate => 'Desactivar';

  @override
  String get actionReactivate => 'Reactivar';

  @override
  String get resetPasswordConfirm =>
      'Se generará una contraseña temporal nueva y se cerrarán todas sus sesiones. ¿Continuar?';

  @override
  String get deactivateConfirm =>
      'La cuenta no podrá ingresar ni usar la app. ¿Desactivar?';

  @override
  String get reactivateConfirm => '¿Reactivar esta cuenta?';

  @override
  String get memberDeactivated => 'Cuenta desactivada.';

  @override
  String get memberReactivated => 'Cuenta reactivada.';

  @override
  String get editMemberTitle => 'Editar socio';

  @override
  String get fieldTier => 'Plan';

  @override
  String tierWithPrice(String price) {
    return '$price/mes';
  }

  @override
  String get fieldMonths => 'Meses';

  @override
  String get monthsOther => 'Otro';

  @override
  String get fieldStartDate => 'Fecha de inicio';

  @override
  String get startDateRangeHint =>
      'Entre 7 días antes y 30 días después de hoy.';

  @override
  String get fieldAmount => 'Monto (Bs)';

  @override
  String get fieldMethod => 'Método de pago';

  @override
  String get fieldNote => 'Nota';

  @override
  String get noteRequiredHint =>
      'Obligatoria si el monto cambia respecto al sugerido.';

  @override
  String get validationNoteRequired =>
      'Agrega una nota: el monto es distinto al sugerido.';

  @override
  String get validationAmountInvalid =>
      'Ingresa un monto válido (máximo 2 decimales).';

  @override
  String get validationEmailInvalid => 'Correo no válido.';

  @override
  String validationIntRange(int min, int max) {
    return 'Ingresa un número entre $min y $max.';
  }

  @override
  String get methodCash => 'Efectivo';

  @override
  String get methodTransfer => 'Transferencia';

  @override
  String get methodQr => 'QR';

  @override
  String get methodCard => 'Tarjeta';

  @override
  String get methodOther => 'Otro';

  @override
  String suggestedAmount(String amount) {
    return 'Monto sugerido: $amount';
  }

  @override
  String newPeriod(String start, String end) {
    return 'Nuevo periodo: $start – $end';
  }

  @override
  String get tierAppliesNow => 'El plan nuevo se aplica desde hoy.';

  @override
  String tierAppliesScheduled(String date) {
    return 'El plan nuevo se aplica desde el $date.';
  }

  @override
  String get applyTierNowLabel => 'Aplicar el plan nuevo desde hoy';

  @override
  String get renewTitle => 'Renovar membresía';

  @override
  String get renewConfirm => 'Confirmar pago';

  @override
  String get renewDone => 'Pago registrado.';

  @override
  String get tierChangeTitle => 'Cambiar plan';

  @override
  String tierChangeCurrent(String tier) {
    return 'Plan actual: $tier';
  }

  @override
  String get tierChangeTarget => 'Nuevo plan';

  @override
  String tierChangeUpgradeInfo(int days, String amount) {
    return 'Cargo prorrateado sugerido por $days días restantes: $amount';
  }

  @override
  String get tierChangeDowngradeWarning =>
      'Bajar de plan se aplica de inmediato y no tiene reembolso.';

  @override
  String get tierChangePremiumWarning =>
      'Al dejar Premium se quita el entrenador asignado.';

  @override
  String get tierChangeConfirm => 'Confirmar cambio';

  @override
  String get tierChangeDone => 'Plan actualizado.';

  @override
  String get newMemberTitle => 'Nuevo socio';

  @override
  String get stepPersonal => 'Datos personales';

  @override
  String get stepMembership => 'Membresía';

  @override
  String get stepPayment => 'Pago';

  @override
  String get stepSummary => 'Resumen';

  @override
  String get newMemberConfirm => 'Crear socio';

  @override
  String get tempPasswordTitle => 'Contraseña temporal';

  @override
  String tempPasswordCreated(String name) {
    return 'Cuenta lista: $name';
  }

  @override
  String tempPasswordUser(String phone) {
    return 'Usuario: $phone';
  }

  @override
  String get tempPasswordWarning =>
      'Esta contraseña se muestra una sola vez. Cópiala o compártela ahora. Se pedirá cambiarla al ingresar.';

  @override
  String get tempPasswordCopy => 'Copiar';

  @override
  String get tempPasswordCopied => 'Contraseña copiada.';

  @override
  String get tempPasswordShare => 'Compartir por WhatsApp';

  @override
  String tempPasswordShareText(String name, String phone, String password) {
    return 'Hola $name, ya puedes ingresar a la app del gimnasio.\nUsuario: $phone\nContraseña temporal: $password\nTe pedirá cambiarla al entrar.';
  }

  @override
  String get morePricing => 'Precios';

  @override
  String get moreStaff => 'Personal';

  @override
  String get moreReports => 'Reportes';

  @override
  String get moreSettings => 'Configuración del gimnasio';

  @override
  String get moreProfile => 'Mi perfil';

  @override
  String get pricingInfo =>
      'Precio mensual de cada plan. Cambiarlo no afecta pagos anteriores.';

  @override
  String pricingMonthly(String tier) {
    return '$tier (Bs por mes)';
  }

  @override
  String get staffAll => 'Todos';

  @override
  String get staffShowInactive => 'Mostrar inactivos';

  @override
  String get staffEmpty => 'No hay cuentas.';

  @override
  String get staffNew => 'Nueva cuenta';

  @override
  String get newStaffTitle => 'Nueva cuenta de personal';

  @override
  String get fieldRole => 'Rol';

  @override
  String get staffCreate => 'Crear cuenta';

  @override
  String get settingsGymName => 'Nombre del gimnasio';

  @override
  String get settingsCooldown => 'Minutos entre ingresos (evita duplicados)';

  @override
  String get settingsInsideWindow => 'Minutos que cuentan como \"adentro\"';

  @override
  String get settingsCountryCode => 'Código de país por defecto';

  @override
  String get settingsTimezone => 'Zona horaria';

  @override
  String get settingsTimezoneHint => 'Se configura en el servidor.';
}
