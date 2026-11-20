import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
  ];

  /// App name shown by the OS and on the login screen.
  ///
  /// In es, this message translates to:
  /// **'Gimnasio'**
  String get appTitle;

  /// No description provided for @commonRetry.
  ///
  /// In es, this message translates to:
  /// **'Reintentar'**
  String get commonRetry;

  /// No description provided for @commonLoading.
  ///
  /// In es, this message translates to:
  /// **'Cargando…'**
  String get commonLoading;

  /// No description provided for @commonEmpty.
  ///
  /// In es, this message translates to:
  /// **'No hay nada aquí todavía.'**
  String get commonEmpty;

  /// No description provided for @commonComingSoon.
  ///
  /// In es, this message translates to:
  /// **'Esta sección estará disponible pronto.'**
  String get commonComingSoon;

  /// No description provided for @splashRestoreFailed.
  ///
  /// In es, this message translates to:
  /// **'No pudimos abrir tu sesión.'**
  String get splashRestoreFailed;

  /// No description provided for @loginTitle.
  ///
  /// In es, this message translates to:
  /// **'Iniciar sesión'**
  String get loginTitle;

  /// No description provided for @loginSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Ingresa con tu número de teléfono.'**
  String get loginSubtitle;

  /// No description provided for @loginCountryCodeLabel.
  ///
  /// In es, this message translates to:
  /// **'Código de país'**
  String get loginCountryCodeLabel;

  /// No description provided for @loginPhoneLabel.
  ///
  /// In es, this message translates to:
  /// **'Teléfono'**
  String get loginPhoneLabel;

  /// No description provided for @loginPhoneHint.
  ///
  /// In es, this message translates to:
  /// **'71234567'**
  String get loginPhoneHint;

  /// No description provided for @loginPasswordLabel.
  ///
  /// In es, this message translates to:
  /// **'Contraseña'**
  String get loginPasswordLabel;

  /// No description provided for @loginShowPassword.
  ///
  /// In es, this message translates to:
  /// **'Mostrar contraseña'**
  String get loginShowPassword;

  /// No description provided for @loginHidePassword.
  ///
  /// In es, this message translates to:
  /// **'Ocultar contraseña'**
  String get loginHidePassword;

  /// No description provided for @loginSubmit.
  ///
  /// In es, this message translates to:
  /// **'Ingresar'**
  String get loginSubmit;

  /// No description provided for @changePasswordTitle.
  ///
  /// In es, this message translates to:
  /// **'Cambiar contraseña'**
  String get changePasswordTitle;

  /// No description provided for @changePasswordForcedInfo.
  ///
  /// In es, this message translates to:
  /// **'Por seguridad, crea una contraseña nueva antes de continuar.'**
  String get changePasswordForcedInfo;

  /// No description provided for @changePasswordCurrentLabel.
  ///
  /// In es, this message translates to:
  /// **'Contraseña actual'**
  String get changePasswordCurrentLabel;

  /// No description provided for @changePasswordNewLabel.
  ///
  /// In es, this message translates to:
  /// **'Contraseña nueva'**
  String get changePasswordNewLabel;

  /// No description provided for @changePasswordConfirmLabel.
  ///
  /// In es, this message translates to:
  /// **'Repite la contraseña nueva'**
  String get changePasswordConfirmLabel;

  /// No description provided for @changePasswordSubmit.
  ///
  /// In es, this message translates to:
  /// **'Guardar contraseña'**
  String get changePasswordSubmit;

  /// No description provided for @changePasswordSuccess.
  ///
  /// In es, this message translates to:
  /// **'Contraseña actualizada.'**
  String get changePasswordSuccess;

  /// No description provided for @passwordStrengthHint.
  ///
  /// In es, this message translates to:
  /// **'Usa al menos 8 caracteres y combina letras, números y símbolos.'**
  String get passwordStrengthHint;

  /// No description provided for @passwordStrengthWeak.
  ///
  /// In es, this message translates to:
  /// **'Seguridad: débil'**
  String get passwordStrengthWeak;

  /// No description provided for @passwordStrengthMedium.
  ///
  /// In es, this message translates to:
  /// **'Seguridad: media'**
  String get passwordStrengthMedium;

  /// No description provided for @passwordStrengthStrong.
  ///
  /// In es, this message translates to:
  /// **'Seguridad: fuerte'**
  String get passwordStrengthStrong;

  /// No description provided for @validationRequired.
  ///
  /// In es, this message translates to:
  /// **'Este campo es obligatorio.'**
  String get validationRequired;

  /// No description provided for @validationPhoneInvalid.
  ///
  /// In es, this message translates to:
  /// **'Ingresa un número de teléfono válido.'**
  String get validationPhoneInvalid;

  /// No description provided for @validationPasswordTooShort.
  ///
  /// In es, this message translates to:
  /// **'Debe tener al menos {min} caracteres.'**
  String validationPasswordTooShort(int min);

  /// No description provided for @validationPasswordsDontMatch.
  ///
  /// In es, this message translates to:
  /// **'Las contraseñas no coinciden.'**
  String get validationPasswordsDontMatch;

  /// No description provided for @validationPasswordSameAsCurrent.
  ///
  /// In es, this message translates to:
  /// **'La nueva contraseña debe ser distinta de la actual.'**
  String get validationPasswordSameAsCurrent;

  /// No description provided for @logout.
  ///
  /// In es, this message translates to:
  /// **'Cerrar sesión'**
  String get logout;

  /// No description provided for @homeGreeting.
  ///
  /// In es, this message translates to:
  /// **'Hola, {name}'**
  String homeGreeting(String name);

  /// No description provided for @homeAdminTitle.
  ///
  /// In es, this message translates to:
  /// **'Administración'**
  String get homeAdminTitle;

  /// No description provided for @homeTrainerTitle.
  ///
  /// In es, this message translates to:
  /// **'Mis alumnos'**
  String get homeTrainerTitle;

  /// No description provided for @homeMemberTitle.
  ///
  /// In es, this message translates to:
  /// **'Inicio'**
  String get homeMemberTitle;

  /// No description provided for @homeKioskTitle.
  ///
  /// In es, this message translates to:
  /// **'Modo kiosco'**
  String get homeKioskTitle;

  /// No description provided for @roleAdmin.
  ///
  /// In es, this message translates to:
  /// **'Administrador'**
  String get roleAdmin;

  /// No description provided for @roleTrainer.
  ///
  /// In es, this message translates to:
  /// **'Entrenador'**
  String get roleTrainer;

  /// No description provided for @roleMember.
  ///
  /// In es, this message translates to:
  /// **'Socio'**
  String get roleMember;

  /// No description provided for @roleKiosk.
  ///
  /// In es, this message translates to:
  /// **'Kiosco'**
  String get roleKiosk;

  /// No description provided for @tierBasic.
  ///
  /// In es, this message translates to:
  /// **'Basic'**
  String get tierBasic;

  /// No description provided for @tierPlus.
  ///
  /// In es, this message translates to:
  /// **'Plus'**
  String get tierPlus;

  /// No description provided for @tierPremium.
  ///
  /// In es, this message translates to:
  /// **'Premium'**
  String get tierPremium;

  /// No description provided for @membershipDaysLeft.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =0{Último día} =1{Te queda 1 día} other{Te quedan {count} días}}'**
  String membershipDaysLeft(int count);

  /// No description provided for @membershipExpired.
  ///
  /// In es, this message translates to:
  /// **'Membresía vencida — acércate a recepción'**
  String get membershipExpired;

  /// No description provided for @membershipEndDate.
  ///
  /// In es, this message translates to:
  /// **'Vence el {date}'**
  String membershipEndDate(String date);

  /// No description provided for @membershipNone.
  ///
  /// In es, this message translates to:
  /// **'No tienes una membresía registrada.'**
  String get membershipNone;

  /// No description provided for @errorNetwork.
  ///
  /// In es, this message translates to:
  /// **'Sin conexión. Revisa tu internet e intenta de nuevo.'**
  String get errorNetwork;

  /// No description provided for @errorTimeout.
  ///
  /// In es, this message translates to:
  /// **'El servidor tardó demasiado en responder. Intenta de nuevo.'**
  String get errorTimeout;

  /// No description provided for @errorUnknown.
  ///
  /// In es, this message translates to:
  /// **'Ocurrió un error inesperado. Intenta de nuevo.'**
  String get errorUnknown;

  /// No description provided for @errorValidation.
  ///
  /// In es, this message translates to:
  /// **'Los datos enviados no son válidos.'**
  String get errorValidation;

  /// No description provided for @errorBadRequest.
  ///
  /// In es, this message translates to:
  /// **'La solicitud no es válida.'**
  String get errorBadRequest;

  /// No description provided for @errorUnauthorized.
  ///
  /// In es, this message translates to:
  /// **'Tu sesión expiró. Inicia sesión de nuevo.'**
  String get errorUnauthorized;

  /// No description provided for @errorForbidden.
  ///
  /// In es, this message translates to:
  /// **'No tienes permiso para realizar esta acción.'**
  String get errorForbidden;

  /// No description provided for @errorNotFound.
  ///
  /// In es, this message translates to:
  /// **'No se encontró lo que buscabas.'**
  String get errorNotFound;

  /// No description provided for @errorConflict.
  ///
  /// In es, this message translates to:
  /// **'La operación entra en conflicto con el estado actual.'**
  String get errorConflict;

  /// No description provided for @errorTooManyRequests.
  ///
  /// In es, this message translates to:
  /// **'Demasiados intentos. Espera un momento e intenta de nuevo.'**
  String get errorTooManyRequests;

  /// No description provided for @errorServer.
  ///
  /// In es, this message translates to:
  /// **'El servidor tuvo un problema. Intenta de nuevo más tarde.'**
  String get errorServer;

  /// No description provided for @errorInvalidCredentials.
  ///
  /// In es, this message translates to:
  /// **'Teléfono o contraseña incorrectos.'**
  String get errorInvalidCredentials;

  /// No description provided for @errorPasswordChangeRequired.
  ///
  /// In es, this message translates to:
  /// **'Debes cambiar tu contraseña antes de continuar.'**
  String get errorPasswordChangeRequired;

  /// No description provided for @errorAccountInactive.
  ///
  /// In es, this message translates to:
  /// **'Tu cuenta está desactivada. Acércate a recepción.'**
  String get errorAccountInactive;

  /// No description provided for @errorPhoneAlreadyExists.
  ///
  /// In es, this message translates to:
  /// **'Ya existe una cuenta con ese número de teléfono.'**
  String get errorPhoneAlreadyExists;

  /// No description provided for @errorEmailAlreadyExists.
  ///
  /// In es, this message translates to:
  /// **'Ya existe una cuenta con ese correo.'**
  String get errorEmailAlreadyExists;

  /// No description provided for @errorWrongCurrentPassword.
  ///
  /// In es, this message translates to:
  /// **'La contraseña actual no es correcta.'**
  String get errorWrongCurrentPassword;

  /// No description provided for @errorPasswordUnchanged.
  ///
  /// In es, this message translates to:
  /// **'La nueva contraseña debe ser distinta de la actual.'**
  String get errorPasswordUnchanged;

  /// No description provided for @errorLastActiveAdmin.
  ///
  /// In es, this message translates to:
  /// **'Debe existir al menos un administrador activo.'**
  String get errorLastActiveAdmin;

  /// No description provided for @errorAmountNoteRequired.
  ///
  /// In es, this message translates to:
  /// **'Si el monto cambia respecto al sugerido, debes agregar una nota.'**
  String get errorAmountNoteRequired;

  /// No description provided for @errorMembershipExpired.
  ///
  /// In es, this message translates to:
  /// **'La membresía está vencida. Acércate a recepción para renovar.'**
  String get errorMembershipExpired;

  /// No description provided for @errorStartDateOutOfRange.
  ///
  /// In es, this message translates to:
  /// **'La fecha de inicio debe estar entre 7 días antes y 30 días después de hoy.'**
  String get errorStartDateOutOfRange;

  /// No description provided for @errorTierUnchanged.
  ///
  /// In es, this message translates to:
  /// **'El socio ya tiene ese plan.'**
  String get errorTierUnchanged;

  /// No description provided for @errorPaymentAlreadyVoided.
  ///
  /// In es, this message translates to:
  /// **'Este pago ya fue anulado.'**
  String get errorPaymentAlreadyVoided;

  /// No description provided for @errorPaymentMethodRequired.
  ///
  /// In es, this message translates to:
  /// **'Indica el método de pago.'**
  String get errorPaymentMethodRequired;

  /// No description provided for @errorDowngradeHasNoCharge.
  ///
  /// In es, this message translates to:
  /// **'Bajar de plan no tiene cobro.'**
  String get errorDowngradeHasNoCharge;

  /// No description provided for @errorNoMembership.
  ///
  /// In es, this message translates to:
  /// **'No hay una membresía registrada.'**
  String get errorNoMembership;

  /// No description provided for @errorQrTokenInvalid.
  ///
  /// In es, this message translates to:
  /// **'Código no válido, vuelve a escanear.'**
  String get errorQrTokenInvalid;

  /// No description provided for @errorQrTokenExpired.
  ///
  /// In es, this message translates to:
  /// **'Código vencido, escanea de nuevo.'**
  String get errorQrTokenExpired;

  /// No description provided for @errorTierRequired.
  ///
  /// In es, this message translates to:
  /// **'Tu plan de membresía no incluye esta función.'**
  String get errorTierRequired;

  /// No description provided for @errorSessionAlreadyOpen.
  ///
  /// In es, this message translates to:
  /// **'Ya tienes un entrenamiento en curso.'**
  String get errorSessionAlreadyOpen;

  /// No description provided for @commonCancel.
  ///
  /// In es, this message translates to:
  /// **'Cancelar'**
  String get commonCancel;

  /// No description provided for @commonConfirm.
  ///
  /// In es, this message translates to:
  /// **'Confirmar'**
  String get commonConfirm;

  /// No description provided for @commonSave.
  ///
  /// In es, this message translates to:
  /// **'Guardar'**
  String get commonSave;

  /// No description provided for @commonContinue.
  ///
  /// In es, this message translates to:
  /// **'Continuar'**
  String get commonContinue;

  /// No description provided for @commonBack.
  ///
  /// In es, this message translates to:
  /// **'Atrás'**
  String get commonBack;

  /// No description provided for @commonDone.
  ///
  /// In es, this message translates to:
  /// **'Listo'**
  String get commonDone;

  /// No description provided for @commonSaved.
  ///
  /// In es, this message translates to:
  /// **'Cambios guardados.'**
  String get commonSaved;

  /// No description provided for @commonNotSet.
  ///
  /// In es, this message translates to:
  /// **'—'**
  String get commonNotSet;

  /// No description provided for @navDashboard.
  ///
  /// In es, this message translates to:
  /// **'Dashboard'**
  String get navDashboard;

  /// No description provided for @navMembers.
  ///
  /// In es, this message translates to:
  /// **'Socios'**
  String get navMembers;

  /// No description provided for @navCheckins.
  ///
  /// In es, this message translates to:
  /// **'Ingresos'**
  String get navCheckins;

  /// No description provided for @navPlans.
  ///
  /// In es, this message translates to:
  /// **'Planes'**
  String get navPlans;

  /// No description provided for @navMore.
  ///
  /// In es, this message translates to:
  /// **'Más'**
  String get navMore;

  /// No description provided for @membersSearchHint.
  ///
  /// In es, this message translates to:
  /// **'Buscar por nombre o teléfono'**
  String get membersSearchHint;

  /// No description provided for @filterActive.
  ///
  /// In es, this message translates to:
  /// **'Activos'**
  String get filterActive;

  /// No description provided for @filterExpiring.
  ///
  /// In es, this message translates to:
  /// **'Por vencer'**
  String get filterExpiring;

  /// No description provided for @filterExpired.
  ///
  /// In es, this message translates to:
  /// **'Vencidos'**
  String get filterExpired;

  /// No description provided for @filterInactive.
  ///
  /// In es, this message translates to:
  /// **'Inactivos'**
  String get filterInactive;

  /// No description provided for @membersEmpty.
  ///
  /// In es, this message translates to:
  /// **'No hay socios con estos filtros.'**
  String get membersEmpty;

  /// No description provided for @membersNew.
  ///
  /// In es, this message translates to:
  /// **'Nuevo socio'**
  String get membersNew;

  /// No description provided for @memberDaysLeftShort.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =1{1 día} other{{count} días}}'**
  String memberDaysLeftShort(int count);

  /// No description provided for @memberExpiredAgo.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =0{Vencido} =1{Vencido hace 1 día} other{Vencido hace {count} días}}'**
  String memberExpiredAgo(int count);

  /// No description provided for @memberInactive.
  ///
  /// In es, this message translates to:
  /// **'Inactivo'**
  String get memberInactive;

  /// No description provided for @memberLastCheckin.
  ///
  /// In es, this message translates to:
  /// **'Último ingreso: {date}'**
  String memberLastCheckin(String date);

  /// No description provided for @memberNoCheckins.
  ///
  /// In es, this message translates to:
  /// **'Sin ingresos'**
  String get memberNoCheckins;

  /// No description provided for @memberTabMembership.
  ///
  /// In es, this message translates to:
  /// **'Membresía'**
  String get memberTabMembership;

  /// No description provided for @memberTabPayments.
  ///
  /// In es, this message translates to:
  /// **'Pagos'**
  String get memberTabPayments;

  /// No description provided for @memberTabCheckins.
  ///
  /// In es, this message translates to:
  /// **'Ingresos'**
  String get memberTabCheckins;

  /// No description provided for @memberTabProfile.
  ///
  /// In es, this message translates to:
  /// **'Datos'**
  String get memberTabProfile;

  /// No description provided for @memberCall.
  ///
  /// In es, this message translates to:
  /// **'Llamar'**
  String get memberCall;

  /// No description provided for @memberWhatsApp.
  ///
  /// In es, this message translates to:
  /// **'WhatsApp'**
  String get memberWhatsApp;

  /// No description provided for @membershipStart.
  ///
  /// In es, this message translates to:
  /// **'Inicio'**
  String get membershipStart;

  /// No description provided for @membershipEnd.
  ///
  /// In es, this message translates to:
  /// **'Vence'**
  String get membershipEnd;

  /// No description provided for @membershipNextTier.
  ///
  /// In es, this message translates to:
  /// **'Plan {tier} desde el {date}'**
  String membershipNextTier(String tier, String date);

  /// No description provided for @actionRenew.
  ///
  /// In es, this message translates to:
  /// **'Renovar'**
  String get actionRenew;

  /// No description provided for @actionChangeTier.
  ///
  /// In es, this message translates to:
  /// **'Cambiar plan'**
  String get actionChangeTier;

  /// No description provided for @changeTierExpiredHint.
  ///
  /// In es, this message translates to:
  /// **'La membresía está vencida: renueva para cambiar de plan.'**
  String get changeTierExpiredHint;

  /// No description provided for @paymentKindNew.
  ///
  /// In es, this message translates to:
  /// **'Inscripción'**
  String get paymentKindNew;

  /// No description provided for @paymentKindRenewal.
  ///
  /// In es, this message translates to:
  /// **'Renovación'**
  String get paymentKindRenewal;

  /// No description provided for @paymentKindUpgrade.
  ///
  /// In es, this message translates to:
  /// **'Cambio de plan'**
  String get paymentKindUpgrade;

  /// No description provided for @paymentMonths.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =0{sin meses} =1{1 mes} other{{count} meses}}'**
  String paymentMonths(int count);

  /// No description provided for @paymentRecordedBy.
  ///
  /// In es, this message translates to:
  /// **'Registrado por {name} · {date}'**
  String paymentRecordedBy(String name, String date);

  /// No description provided for @paymentVoided.
  ///
  /// In es, this message translates to:
  /// **'Anulado: {reason}'**
  String paymentVoided(String reason);

  /// No description provided for @paymentVoid.
  ///
  /// In es, this message translates to:
  /// **'Anular'**
  String get paymentVoid;

  /// No description provided for @paymentsEmpty.
  ///
  /// In es, this message translates to:
  /// **'Sin pagos.'**
  String get paymentsEmpty;

  /// No description provided for @voidTitle.
  ///
  /// In es, this message translates to:
  /// **'Anular pago'**
  String get voidTitle;

  /// No description provided for @voidInfo.
  ///
  /// In es, this message translates to:
  /// **'El pago queda registrado como anulado y las fechas de la membresía se recalculan.'**
  String get voidInfo;

  /// No description provided for @voidReasonLabel.
  ///
  /// In es, this message translates to:
  /// **'Motivo'**
  String get voidReasonLabel;

  /// No description provided for @voidDone.
  ///
  /// In es, this message translates to:
  /// **'Pago anulado. Fechas recalculadas.'**
  String get voidDone;

  /// No description provided for @checkinsEmpty.
  ///
  /// In es, this message translates to:
  /// **'Todavía no registró ingresos.'**
  String get checkinsEmpty;

  /// No description provided for @profileFirstName.
  ///
  /// In es, this message translates to:
  /// **'Nombre'**
  String get profileFirstName;

  /// No description provided for @profileLastName.
  ///
  /// In es, this message translates to:
  /// **'Apellido'**
  String get profileLastName;

  /// No description provided for @profilePhone.
  ///
  /// In es, this message translates to:
  /// **'Teléfono'**
  String get profilePhone;

  /// No description provided for @profileEmail.
  ///
  /// In es, this message translates to:
  /// **'Correo (opcional)'**
  String get profileEmail;

  /// No description provided for @profileBirthDate.
  ///
  /// In es, this message translates to:
  /// **'Fecha de nacimiento'**
  String get profileBirthDate;

  /// No description provided for @profileGender.
  ///
  /// In es, this message translates to:
  /// **'Género'**
  String get profileGender;

  /// No description provided for @profileEmergencyContact.
  ///
  /// In es, this message translates to:
  /// **'Contacto de emergencia'**
  String get profileEmergencyContact;

  /// No description provided for @profileMedicalNotes.
  ///
  /// In es, this message translates to:
  /// **'Notas médicas'**
  String get profileMedicalNotes;

  /// No description provided for @genderMale.
  ///
  /// In es, this message translates to:
  /// **'Masculino'**
  String get genderMale;

  /// No description provided for @genderFemale.
  ///
  /// In es, this message translates to:
  /// **'Femenino'**
  String get genderFemale;

  /// No description provided for @genderOther.
  ///
  /// In es, this message translates to:
  /// **'Otro'**
  String get genderOther;

  /// No description provided for @actionEdit.
  ///
  /// In es, this message translates to:
  /// **'Editar datos'**
  String get actionEdit;

  /// No description provided for @actionResetPassword.
  ///
  /// In es, this message translates to:
  /// **'Restablecer contraseña'**
  String get actionResetPassword;

  /// No description provided for @actionDeactivate.
  ///
  /// In es, this message translates to:
  /// **'Desactivar'**
  String get actionDeactivate;

  /// No description provided for @actionReactivate.
  ///
  /// In es, this message translates to:
  /// **'Reactivar'**
  String get actionReactivate;

  /// No description provided for @resetPasswordConfirm.
  ///
  /// In es, this message translates to:
  /// **'Se generará una contraseña temporal nueva y se cerrarán todas sus sesiones. ¿Continuar?'**
  String get resetPasswordConfirm;

  /// No description provided for @deactivateConfirm.
  ///
  /// In es, this message translates to:
  /// **'La cuenta no podrá ingresar ni usar la app. ¿Desactivar?'**
  String get deactivateConfirm;

  /// No description provided for @reactivateConfirm.
  ///
  /// In es, this message translates to:
  /// **'¿Reactivar esta cuenta?'**
  String get reactivateConfirm;

  /// No description provided for @memberDeactivated.
  ///
  /// In es, this message translates to:
  /// **'Cuenta desactivada.'**
  String get memberDeactivated;

  /// No description provided for @memberReactivated.
  ///
  /// In es, this message translates to:
  /// **'Cuenta reactivada.'**
  String get memberReactivated;

  /// No description provided for @editMemberTitle.
  ///
  /// In es, this message translates to:
  /// **'Editar socio'**
  String get editMemberTitle;

  /// No description provided for @fieldTier.
  ///
  /// In es, this message translates to:
  /// **'Plan'**
  String get fieldTier;

  /// No description provided for @tierWithPrice.
  ///
  /// In es, this message translates to:
  /// **'{price}/mes'**
  String tierWithPrice(String price);

  /// No description provided for @fieldMonths.
  ///
  /// In es, this message translates to:
  /// **'Meses'**
  String get fieldMonths;

  /// No description provided for @monthsOther.
  ///
  /// In es, this message translates to:
  /// **'Otro'**
  String get monthsOther;

  /// No description provided for @fieldStartDate.
  ///
  /// In es, this message translates to:
  /// **'Fecha de inicio'**
  String get fieldStartDate;

  /// No description provided for @startDateRangeHint.
  ///
  /// In es, this message translates to:
  /// **'Entre 7 días antes y 30 días después de hoy.'**
  String get startDateRangeHint;

  /// No description provided for @fieldAmount.
  ///
  /// In es, this message translates to:
  /// **'Monto (Bs)'**
  String get fieldAmount;

  /// No description provided for @fieldMethod.
  ///
  /// In es, this message translates to:
  /// **'Método de pago'**
  String get fieldMethod;

  /// No description provided for @fieldNote.
  ///
  /// In es, this message translates to:
  /// **'Nota'**
  String get fieldNote;

  /// No description provided for @noteRequiredHint.
  ///
  /// In es, this message translates to:
  /// **'Obligatoria si el monto cambia respecto al sugerido.'**
  String get noteRequiredHint;

  /// No description provided for @validationNoteRequired.
  ///
  /// In es, this message translates to:
  /// **'Agrega una nota: el monto es distinto al sugerido.'**
  String get validationNoteRequired;

  /// No description provided for @validationAmountInvalid.
  ///
  /// In es, this message translates to:
  /// **'Ingresa un monto válido (máximo 2 decimales).'**
  String get validationAmountInvalid;

  /// No description provided for @validationEmailInvalid.
  ///
  /// In es, this message translates to:
  /// **'Correo no válido.'**
  String get validationEmailInvalid;

  /// No description provided for @validationIntRange.
  ///
  /// In es, this message translates to:
  /// **'Ingresa un número entre {min} y {max}.'**
  String validationIntRange(int min, int max);

  /// No description provided for @methodCash.
  ///
  /// In es, this message translates to:
  /// **'Efectivo'**
  String get methodCash;

  /// No description provided for @methodTransfer.
  ///
  /// In es, this message translates to:
  /// **'Transferencia'**
  String get methodTransfer;

  /// No description provided for @methodQr.
  ///
  /// In es, this message translates to:
  /// **'QR'**
  String get methodQr;

  /// No description provided for @methodCard.
  ///
  /// In es, this message translates to:
  /// **'Tarjeta'**
  String get methodCard;

  /// No description provided for @methodOther.
  ///
  /// In es, this message translates to:
  /// **'Otro'**
  String get methodOther;

  /// No description provided for @suggestedAmount.
  ///
  /// In es, this message translates to:
  /// **'Monto sugerido: {amount}'**
  String suggestedAmount(String amount);

  /// No description provided for @newPeriod.
  ///
  /// In es, this message translates to:
  /// **'Nuevo periodo: {start} – {end}'**
  String newPeriod(String start, String end);

  /// No description provided for @tierAppliesNow.
  ///
  /// In es, this message translates to:
  /// **'El plan nuevo se aplica desde hoy.'**
  String get tierAppliesNow;

  /// No description provided for @tierAppliesScheduled.
  ///
  /// In es, this message translates to:
  /// **'El plan nuevo se aplica desde el {date}.'**
  String tierAppliesScheduled(String date);

  /// No description provided for @applyTierNowLabel.
  ///
  /// In es, this message translates to:
  /// **'Aplicar el plan nuevo desde hoy'**
  String get applyTierNowLabel;

  /// No description provided for @renewTitle.
  ///
  /// In es, this message translates to:
  /// **'Renovar membresía'**
  String get renewTitle;

  /// No description provided for @renewConfirm.
  ///
  /// In es, this message translates to:
  /// **'Confirmar pago'**
  String get renewConfirm;

  /// No description provided for @renewDone.
  ///
  /// In es, this message translates to:
  /// **'Pago registrado.'**
  String get renewDone;

  /// No description provided for @tierChangeTitle.
  ///
  /// In es, this message translates to:
  /// **'Cambiar plan'**
  String get tierChangeTitle;

  /// No description provided for @tierChangeCurrent.
  ///
  /// In es, this message translates to:
  /// **'Plan actual: {tier}'**
  String tierChangeCurrent(String tier);

  /// No description provided for @tierChangeTarget.
  ///
  /// In es, this message translates to:
  /// **'Nuevo plan'**
  String get tierChangeTarget;

  /// No description provided for @tierChangeUpgradeInfo.
  ///
  /// In es, this message translates to:
  /// **'Cargo prorrateado sugerido por {days} días restantes: {amount}'**
  String tierChangeUpgradeInfo(int days, String amount);

  /// No description provided for @tierChangeDowngradeWarning.
  ///
  /// In es, this message translates to:
  /// **'Bajar de plan se aplica de inmediato y no tiene reembolso.'**
  String get tierChangeDowngradeWarning;

  /// No description provided for @tierChangePremiumWarning.
  ///
  /// In es, this message translates to:
  /// **'Al dejar Premium se quita el entrenador asignado.'**
  String get tierChangePremiumWarning;

  /// No description provided for @tierChangeConfirm.
  ///
  /// In es, this message translates to:
  /// **'Confirmar cambio'**
  String get tierChangeConfirm;

  /// No description provided for @tierChangeDone.
  ///
  /// In es, this message translates to:
  /// **'Plan actualizado.'**
  String get tierChangeDone;

  /// No description provided for @newMemberTitle.
  ///
  /// In es, this message translates to:
  /// **'Nuevo socio'**
  String get newMemberTitle;

  /// No description provided for @stepPersonal.
  ///
  /// In es, this message translates to:
  /// **'Datos personales'**
  String get stepPersonal;

  /// No description provided for @stepMembership.
  ///
  /// In es, this message translates to:
  /// **'Membresía'**
  String get stepMembership;

  /// No description provided for @stepPayment.
  ///
  /// In es, this message translates to:
  /// **'Pago'**
  String get stepPayment;

  /// No description provided for @stepSummary.
  ///
  /// In es, this message translates to:
  /// **'Resumen'**
  String get stepSummary;

  /// No description provided for @newMemberConfirm.
  ///
  /// In es, this message translates to:
  /// **'Crear socio'**
  String get newMemberConfirm;

  /// No description provided for @tempPasswordTitle.
  ///
  /// In es, this message translates to:
  /// **'Contraseña temporal'**
  String get tempPasswordTitle;

  /// No description provided for @tempPasswordCreated.
  ///
  /// In es, this message translates to:
  /// **'Cuenta lista: {name}'**
  String tempPasswordCreated(String name);

  /// No description provided for @tempPasswordUser.
  ///
  /// In es, this message translates to:
  /// **'Usuario: {phone}'**
  String tempPasswordUser(String phone);

  /// No description provided for @tempPasswordWarning.
  ///
  /// In es, this message translates to:
  /// **'Esta contraseña se muestra una sola vez. Cópiala o compártela ahora. Se pedirá cambiarla al ingresar.'**
  String get tempPasswordWarning;

  /// No description provided for @tempPasswordCopy.
  ///
  /// In es, this message translates to:
  /// **'Copiar'**
  String get tempPasswordCopy;

  /// No description provided for @tempPasswordCopied.
  ///
  /// In es, this message translates to:
  /// **'Contraseña copiada.'**
  String get tempPasswordCopied;

  /// No description provided for @tempPasswordShare.
  ///
  /// In es, this message translates to:
  /// **'Compartir por WhatsApp'**
  String get tempPasswordShare;

  /// No description provided for @tempPasswordShareText.
  ///
  /// In es, this message translates to:
  /// **'Hola {name}, ya puedes ingresar a la app del gimnasio.\nUsuario: {phone}\nContraseña temporal: {password}\nTe pedirá cambiarla al entrar.'**
  String tempPasswordShareText(String name, String phone, String password);

  /// No description provided for @morePricing.
  ///
  /// In es, this message translates to:
  /// **'Precios'**
  String get morePricing;

  /// No description provided for @moreStaff.
  ///
  /// In es, this message translates to:
  /// **'Personal'**
  String get moreStaff;

  /// No description provided for @moreReports.
  ///
  /// In es, this message translates to:
  /// **'Reportes'**
  String get moreReports;

  /// No description provided for @moreSettings.
  ///
  /// In es, this message translates to:
  /// **'Configuración del gimnasio'**
  String get moreSettings;

  /// No description provided for @moreProfile.
  ///
  /// In es, this message translates to:
  /// **'Mi perfil'**
  String get moreProfile;

  /// No description provided for @pricingInfo.
  ///
  /// In es, this message translates to:
  /// **'Precio mensual de cada plan. Cambiarlo no afecta pagos anteriores.'**
  String get pricingInfo;

  /// No description provided for @pricingMonthly.
  ///
  /// In es, this message translates to:
  /// **'{tier} (Bs por mes)'**
  String pricingMonthly(String tier);

  /// No description provided for @staffAll.
  ///
  /// In es, this message translates to:
  /// **'Todos'**
  String get staffAll;

  /// No description provided for @staffShowInactive.
  ///
  /// In es, this message translates to:
  /// **'Mostrar inactivos'**
  String get staffShowInactive;

  /// No description provided for @staffEmpty.
  ///
  /// In es, this message translates to:
  /// **'No hay cuentas.'**
  String get staffEmpty;

  /// No description provided for @staffNew.
  ///
  /// In es, this message translates to:
  /// **'Nueva cuenta'**
  String get staffNew;

  /// No description provided for @newStaffTitle.
  ///
  /// In es, this message translates to:
  /// **'Nueva cuenta de personal'**
  String get newStaffTitle;

  /// No description provided for @fieldRole.
  ///
  /// In es, this message translates to:
  /// **'Rol'**
  String get fieldRole;

  /// No description provided for @staffCreate.
  ///
  /// In es, this message translates to:
  /// **'Crear cuenta'**
  String get staffCreate;

  /// No description provided for @settingsGymName.
  ///
  /// In es, this message translates to:
  /// **'Nombre del gimnasio'**
  String get settingsGymName;

  /// No description provided for @settingsCooldown.
  ///
  /// In es, this message translates to:
  /// **'Minutos entre ingresos (evita duplicados)'**
  String get settingsCooldown;

  /// No description provided for @settingsInsideWindow.
  ///
  /// In es, this message translates to:
  /// **'Minutos que cuentan como \"adentro\"'**
  String get settingsInsideWindow;

  /// No description provided for @settingsCountryCode.
  ///
  /// In es, this message translates to:
  /// **'Código de país por defecto'**
  String get settingsCountryCode;

  /// No description provided for @settingsTimezone.
  ///
  /// In es, this message translates to:
  /// **'Zona horaria'**
  String get settingsTimezone;

  /// No description provided for @settingsTimezoneHint.
  ///
  /// In es, this message translates to:
  /// **'Se configura en el servidor.'**
  String get settingsTimezoneHint;

  /// No description provided for @dashboardMetricsSoon.
  ///
  /// In es, this message translates to:
  /// **'Las métricas del gimnasio llegan pronto.'**
  String get dashboardMetricsSoon;

  /// No description provided for @dashboardRecentCheckins.
  ///
  /// In es, this message translates to:
  /// **'Últimos ingresos'**
  String get dashboardRecentCheckins;

  /// No description provided for @dashboardNoCheckins.
  ///
  /// In es, this message translates to:
  /// **'Todavía no hay ingresos.'**
  String get dashboardNoCheckins;

  /// No description provided for @checkinsInsideTab.
  ///
  /// In es, this message translates to:
  /// **'Adentro ahora'**
  String get checkinsInsideTab;

  /// No description provided for @checkinsInsideTabCount.
  ///
  /// In es, this message translates to:
  /// **'Adentro ahora ({count})'**
  String checkinsInsideTabCount(int count);

  /// No description provided for @checkinsTodayTab.
  ///
  /// In es, this message translates to:
  /// **'Hoy'**
  String get checkinsTodayTab;

  /// No description provided for @checkinsInsideHint.
  ///
  /// In es, this message translates to:
  /// **'Ingresaron en los últimos {minutes} minutos.'**
  String checkinsInsideHint(int minutes);

  /// No description provided for @checkinsInsideEmpty.
  ///
  /// In es, this message translates to:
  /// **'Nadie adentro ahora.'**
  String get checkinsInsideEmpty;

  /// No description provided for @checkinsTodayEmpty.
  ///
  /// In es, this message translates to:
  /// **'Todavía no hay ingresos hoy.'**
  String get checkinsTodayEmpty;

  /// No description provided for @checkinsDenied.
  ///
  /// In es, this message translates to:
  /// **'Rechazado'**
  String get checkinsDenied;

  /// No description provided for @checkinsDeniedExpired.
  ///
  /// In es, this message translates to:
  /// **'membresía vencida el {date}'**
  String checkinsDeniedExpired(String date);

  /// No description provided for @checkinsDeniedExpiredShort.
  ///
  /// In es, this message translates to:
  /// **'membresía vencida'**
  String get checkinsDeniedExpiredShort;

  /// No description provided for @checkinsDeniedInactive.
  ///
  /// In es, this message translates to:
  /// **'cuenta desactivada'**
  String get checkinsDeniedInactive;

  /// No description provided for @checkinsAlertsOn.
  ///
  /// In es, this message translates to:
  /// **'Sonido y vibración activados'**
  String get checkinsAlertsOn;

  /// No description provided for @checkinsAlertsOff.
  ///
  /// In es, this message translates to:
  /// **'Sonido y vibración desactivados'**
  String get checkinsAlertsOff;

  /// No description provided for @kioskScanHint.
  ///
  /// In es, this message translates to:
  /// **'Escanea con la app para ingresar'**
  String get kioskScanHint;

  /// No description provided for @kioskOffline.
  ///
  /// In es, this message translates to:
  /// **'Sin conexión'**
  String get kioskOffline;

  /// No description provided for @kioskRetrying.
  ///
  /// In es, this message translates to:
  /// **'Reintentando…'**
  String get kioskRetrying;

  /// No description provided for @kioskExitTitle.
  ///
  /// In es, this message translates to:
  /// **'Salir del modo kiosco'**
  String get kioskExitTitle;

  /// No description provided for @kioskExitBody.
  ///
  /// In es, this message translates to:
  /// **'Ingresa el teléfono y la contraseña de un administrador.'**
  String get kioskExitBody;

  /// No description provided for @kioskExitConfirm.
  ///
  /// In es, this message translates to:
  /// **'Salir'**
  String get kioskExitConfirm;

  /// No description provided for @kioskExitWrong.
  ///
  /// In es, this message translates to:
  /// **'No son credenciales de un administrador.'**
  String get kioskExitWrong;

  /// No description provided for @memberScanButton.
  ///
  /// In es, this message translates to:
  /// **'Escanear para ingresar'**
  String get memberScanButton;

  /// No description provided for @memberExpiredOn.
  ///
  /// In es, this message translates to:
  /// **'Venció el {date}'**
  String memberExpiredOn(String date);

  /// No description provided for @memberCheckinsThisMonth.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =0{Sin ingresos este mes} =1{1 ingreso este mes} other{{count} ingresos este mes}}'**
  String memberCheckinsThisMonth(int count);

  /// No description provided for @scannerTitle.
  ///
  /// In es, this message translates to:
  /// **'Escanear QR'**
  String get scannerTitle;

  /// No description provided for @scannerTorch.
  ///
  /// In es, this message translates to:
  /// **'Linterna'**
  String get scannerTorch;

  /// No description provided for @scannerHint.
  ///
  /// In es, this message translates to:
  /// **'Apunta al código QR de la entrada'**
  String get scannerHint;

  /// No description provided for @scannerSending.
  ///
  /// In es, this message translates to:
  /// **'Registrando tu ingreso…'**
  String get scannerSending;

  /// No description provided for @scannerExplain.
  ///
  /// In es, this message translates to:
  /// **'Para registrar tu ingreso, la app necesita usar la cámara y leer el código QR de la entrada.'**
  String get scannerExplain;

  /// No description provided for @scannerAllowCamera.
  ///
  /// In es, this message translates to:
  /// **'Permitir cámara'**
  String get scannerAllowCamera;

  /// No description provided for @scannerDenied.
  ///
  /// In es, this message translates to:
  /// **'Sin la cámara no se puede leer el código QR. Puedes permitirla ahora.'**
  String get scannerDenied;

  /// No description provided for @scannerBlocked.
  ///
  /// In es, this message translates to:
  /// **'El permiso de la cámara está bloqueado. Actívalo en la configuración del teléfono.'**
  String get scannerBlocked;

  /// No description provided for @scannerOpenSettings.
  ///
  /// In es, this message translates to:
  /// **'Abrir configuración'**
  String get scannerOpenSettings;

  /// No description provided for @checkinWelcome.
  ///
  /// In es, this message translates to:
  /// **'¡Bienvenido, {name}!'**
  String checkinWelcome(String name);

  /// No description provided for @checkinDuplicate.
  ///
  /// In es, this message translates to:
  /// **'Ya registraste tu ingreso hoy a las {time}.'**
  String checkinDuplicate(String time);

  /// No description provided for @checkinEnjoy.
  ///
  /// In es, this message translates to:
  /// **'Listo, ¡buen entrenamiento!'**
  String get checkinEnjoy;

  /// No description provided for @checkinGoHome.
  ///
  /// In es, this message translates to:
  /// **'Ir al inicio'**
  String get checkinGoHome;

  /// No description provided for @checkinExpiredTitle.
  ///
  /// In es, this message translates to:
  /// **'Membresía vencida'**
  String get checkinExpiredTitle;

  /// No description provided for @checkinExpiredBody.
  ///
  /// In es, this message translates to:
  /// **'Acércate a recepción para renovar y seguir entrenando.'**
  String get checkinExpiredBody;

  /// No description provided for @checkinInvalidQr.
  ///
  /// In es, this message translates to:
  /// **'Código no válido, vuelve a escanear.'**
  String get checkinInvalidQr;

  /// No description provided for @checkinScanAgain.
  ///
  /// In es, this message translates to:
  /// **'Escanear de nuevo'**
  String get checkinScanAgain;

  /// No description provided for @checkinInactive.
  ///
  /// In es, this message translates to:
  /// **'Tu cuenta está desactivada. Acércate a recepción.'**
  String get checkinInactive;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
