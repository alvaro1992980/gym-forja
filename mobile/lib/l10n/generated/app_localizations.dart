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
