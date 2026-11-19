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
}
