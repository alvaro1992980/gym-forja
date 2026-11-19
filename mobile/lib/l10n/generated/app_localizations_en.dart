// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Gym';

  @override
  String get commonRetry => 'Retry';

  @override
  String get commonLoading => 'Loading…';

  @override
  String get commonEmpty => 'Nothing here yet.';

  @override
  String get commonComingSoon => 'This section is coming soon.';

  @override
  String get splashRestoreFailed => 'We couldn\'t open your session.';

  @override
  String get loginTitle => 'Sign in';

  @override
  String get loginSubtitle => 'Sign in with your phone number.';

  @override
  String get loginCountryCodeLabel => 'Country code';

  @override
  String get loginPhoneLabel => 'Phone';

  @override
  String get loginPhoneHint => '71234567';

  @override
  String get loginPasswordLabel => 'Password';

  @override
  String get loginShowPassword => 'Show password';

  @override
  String get loginHidePassword => 'Hide password';

  @override
  String get loginSubmit => 'Sign in';

  @override
  String get changePasswordTitle => 'Change password';

  @override
  String get changePasswordForcedInfo =>
      'For your security, create a new password before you continue.';

  @override
  String get changePasswordCurrentLabel => 'Current password';

  @override
  String get changePasswordNewLabel => 'New password';

  @override
  String get changePasswordConfirmLabel => 'Repeat the new password';

  @override
  String get changePasswordSubmit => 'Save password';

  @override
  String get changePasswordSuccess => 'Password updated.';

  @override
  String get passwordStrengthHint =>
      'Use at least 8 characters and mix letters, numbers and symbols.';

  @override
  String get passwordStrengthWeak => 'Strength: weak';

  @override
  String get passwordStrengthMedium => 'Strength: medium';

  @override
  String get passwordStrengthStrong => 'Strength: strong';

  @override
  String get validationRequired => 'This field is required.';

  @override
  String get validationPhoneInvalid => 'Enter a valid phone number.';

  @override
  String validationPasswordTooShort(int min) {
    return 'Must be at least $min characters.';
  }

  @override
  String get validationPasswordsDontMatch => 'The passwords don\'t match.';

  @override
  String get validationPasswordSameAsCurrent =>
      'The new password must be different from the current one.';

  @override
  String get logout => 'Log out';

  @override
  String homeGreeting(String name) {
    return 'Hi, $name';
  }

  @override
  String get homeAdminTitle => 'Administration';

  @override
  String get homeTrainerTitle => 'My members';

  @override
  String get homeMemberTitle => 'Home';

  @override
  String get homeKioskTitle => 'Kiosk mode';

  @override
  String get roleAdmin => 'Administrator';

  @override
  String get roleTrainer => 'Trainer';

  @override
  String get roleMember => 'Member';

  @override
  String get roleKiosk => 'Kiosk';

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
      other: '$count days left',
      one: '1 day left',
      zero: 'Last day',
    );
    return '$_temp0';
  }

  @override
  String get membershipExpired =>
      'Membership expired — please visit the front desk';

  @override
  String membershipEndDate(String date) {
    return 'Ends on $date';
  }

  @override
  String get membershipNone => 'You don\'t have a membership yet.';

  @override
  String get errorNetwork =>
      'No connection. Check your internet and try again.';

  @override
  String get errorTimeout => 'The server took too long to answer. Try again.';

  @override
  String get errorUnknown => 'Something went wrong. Try again.';

  @override
  String get errorValidation => 'Some of the data is not valid.';

  @override
  String get errorBadRequest => 'The request is not valid.';

  @override
  String get errorUnauthorized => 'Your session expired. Sign in again.';

  @override
  String get errorForbidden => 'You don\'t have permission to do this.';

  @override
  String get errorNotFound => 'We couldn\'t find what you were looking for.';

  @override
  String get errorConflict => 'This conflicts with the current state.';

  @override
  String get errorTooManyRequests =>
      'Too many attempts. Wait a moment and try again.';

  @override
  String get errorServer => 'The server had a problem. Try again later.';

  @override
  String get errorInvalidCredentials => 'Wrong phone or password.';

  @override
  String get errorPasswordChangeRequired =>
      'You must change your password before you continue.';

  @override
  String get errorAccountInactive =>
      'Your account is deactivated. Please visit the front desk.';

  @override
  String get errorPhoneAlreadyExists =>
      'An account with that phone number already exists.';

  @override
  String get errorEmailAlreadyExists =>
      'An account with that email already exists.';

  @override
  String get errorWrongCurrentPassword =>
      'The current password is not correct.';

  @override
  String get errorPasswordUnchanged =>
      'The new password must be different from the current one.';

  @override
  String get errorLastActiveAdmin =>
      'There must be at least one active administrator.';

  @override
  String get errorAmountNoteRequired =>
      'If the amount differs from the suggested one, add a note.';

  @override
  String get errorMembershipExpired =>
      'The membership has expired. Please visit the front desk to renew.';

  @override
  String get errorStartDateOutOfRange =>
      'The start date must be between 7 days before and 30 days after today.';

  @override
  String get errorTierUnchanged => 'The member already has that tier.';

  @override
  String get errorPaymentAlreadyVoided => 'This payment was already voided.';

  @override
  String get errorPaymentMethodRequired => 'Choose a payment method.';

  @override
  String get errorDowngradeHasNoCharge => 'Downgrading has no charge.';

  @override
  String get errorNoMembership => 'There is no membership on record.';

  @override
  String get errorQrTokenInvalid => 'Invalid code, scan again.';

  @override
  String get errorQrTokenExpired => 'Expired code, scan again.';

  @override
  String get errorTierRequired =>
      'Your membership tier doesn\'t include this feature.';

  @override
  String get errorSessionAlreadyOpen =>
      'You already have a workout in progress.';
}
