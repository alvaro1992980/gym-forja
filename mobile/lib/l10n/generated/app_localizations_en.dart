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

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonConfirm => 'Confirm';

  @override
  String get commonSave => 'Save';

  @override
  String get commonContinue => 'Continue';

  @override
  String get commonBack => 'Back';

  @override
  String get commonDone => 'Done';

  @override
  String get commonSaved => 'Changes saved.';

  @override
  String get commonNotSet => '—';

  @override
  String get navDashboard => 'Dashboard';

  @override
  String get navMembers => 'Members';

  @override
  String get navCheckins => 'Check-ins';

  @override
  String get navPlans => 'Plans';

  @override
  String get navMore => 'More';

  @override
  String get membersSearchHint => 'Search by name or phone';

  @override
  String get filterActive => 'Active';

  @override
  String get filterExpiring => 'Expiring';

  @override
  String get filterExpired => 'Expired';

  @override
  String get filterInactive => 'Inactive';

  @override
  String get membersEmpty => 'No members match these filters.';

  @override
  String get membersNew => 'New member';

  @override
  String memberDaysLeftShort(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days',
      one: '1 day',
    );
    return '$_temp0';
  }

  @override
  String memberExpiredAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Expired $count days ago',
      one: 'Expired 1 day ago',
      zero: 'Expired',
    );
    return '$_temp0';
  }

  @override
  String get memberInactive => 'Inactive';

  @override
  String memberLastCheckin(String date) {
    return 'Last check-in: $date';
  }

  @override
  String get memberNoCheckins => 'No check-ins';

  @override
  String get memberTabMembership => 'Membership';

  @override
  String get memberTabPayments => 'Payments';

  @override
  String get memberTabCheckins => 'Check-ins';

  @override
  String get memberTabProfile => 'Profile';

  @override
  String get memberCall => 'Call';

  @override
  String get memberWhatsApp => 'WhatsApp';

  @override
  String get membershipStart => 'Start';

  @override
  String get membershipEnd => 'Ends';

  @override
  String membershipNextTier(String tier, String date) {
    return '$tier tier from $date';
  }

  @override
  String get actionRenew => 'Renew';

  @override
  String get actionChangeTier => 'Change tier';

  @override
  String get changeTierExpiredHint =>
      'The membership has expired: renew to change the tier.';

  @override
  String get paymentKindNew => 'Sign-up';

  @override
  String get paymentKindRenewal => 'Renewal';

  @override
  String get paymentKindUpgrade => 'Tier change';

  @override
  String paymentMonths(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count months',
      one: '1 month',
      zero: 'no months',
    );
    return '$_temp0';
  }

  @override
  String paymentRecordedBy(String name, String date) {
    return 'Recorded by $name · $date';
  }

  @override
  String paymentVoided(String reason) {
    return 'Voided: $reason';
  }

  @override
  String get paymentVoid => 'Void';

  @override
  String get paymentsEmpty => 'No payments.';

  @override
  String get voidTitle => 'Void payment';

  @override
  String get voidInfo =>
      'The payment stays on record as voided and the membership dates are recalculated.';

  @override
  String get voidReasonLabel => 'Reason';

  @override
  String get voidDone => 'Payment voided. Dates recalculated.';

  @override
  String get checkinsEmpty => 'No check-ins yet.';

  @override
  String get profileFirstName => 'First name';

  @override
  String get profileLastName => 'Last name';

  @override
  String get profilePhone => 'Phone';

  @override
  String get profileEmail => 'Email (optional)';

  @override
  String get profileBirthDate => 'Birth date';

  @override
  String get profileGender => 'Gender';

  @override
  String get profileEmergencyContact => 'Emergency contact';

  @override
  String get profileMedicalNotes => 'Medical notes';

  @override
  String get genderMale => 'Male';

  @override
  String get genderFemale => 'Female';

  @override
  String get genderOther => 'Other';

  @override
  String get actionEdit => 'Edit profile';

  @override
  String get actionResetPassword => 'Reset password';

  @override
  String get actionDeactivate => 'Deactivate';

  @override
  String get actionReactivate => 'Reactivate';

  @override
  String get resetPasswordConfirm =>
      'A new temporary password will be created and all their sessions will be closed. Continue?';

  @override
  String get deactivateConfirm =>
      'The account won\'t be able to check in or use the app. Deactivate?';

  @override
  String get reactivateConfirm => 'Reactivate this account?';

  @override
  String get memberDeactivated => 'Account deactivated.';

  @override
  String get memberReactivated => 'Account reactivated.';

  @override
  String get editMemberTitle => 'Edit member';

  @override
  String get fieldTier => 'Tier';

  @override
  String tierWithPrice(String price) {
    return '$price/month';
  }

  @override
  String get fieldMonths => 'Months';

  @override
  String get monthsOther => 'Other';

  @override
  String get fieldStartDate => 'Start date';

  @override
  String get startDateRangeHint =>
      'Between 7 days before and 30 days after today.';

  @override
  String get fieldAmount => 'Amount (Bs)';

  @override
  String get fieldMethod => 'Payment method';

  @override
  String get fieldNote => 'Note';

  @override
  String get noteRequiredHint =>
      'Required if the amount differs from the suggested one.';

  @override
  String get validationNoteRequired =>
      'Add a note: the amount differs from the suggested one.';

  @override
  String get validationAmountInvalid =>
      'Enter a valid amount (at most 2 decimals).';

  @override
  String get validationEmailInvalid => 'Invalid email.';

  @override
  String validationIntRange(int min, int max) {
    return 'Enter a number between $min and $max.';
  }

  @override
  String get methodCash => 'Cash';

  @override
  String get methodTransfer => 'Transfer';

  @override
  String get methodQr => 'QR';

  @override
  String get methodCard => 'Card';

  @override
  String get methodOther => 'Other';

  @override
  String suggestedAmount(String amount) {
    return 'Suggested amount: $amount';
  }

  @override
  String newPeriod(String start, String end) {
    return 'New period: $start – $end';
  }

  @override
  String get tierAppliesNow => 'The new tier applies from today.';

  @override
  String tierAppliesScheduled(String date) {
    return 'The new tier applies from $date.';
  }

  @override
  String get applyTierNowLabel => 'Apply the new tier from today';

  @override
  String get renewTitle => 'Renew membership';

  @override
  String get renewConfirm => 'Confirm payment';

  @override
  String get renewDone => 'Payment recorded.';

  @override
  String get tierChangeTitle => 'Change tier';

  @override
  String tierChangeCurrent(String tier) {
    return 'Current tier: $tier';
  }

  @override
  String get tierChangeTarget => 'New tier';

  @override
  String tierChangeUpgradeInfo(int days, String amount) {
    return 'Suggested prorated charge for $days days left: $amount';
  }

  @override
  String get tierChangeDowngradeWarning =>
      'Downgrading applies immediately and has no refund.';

  @override
  String get tierChangePremiumWarning =>
      'Leaving Premium removes the assigned trainer.';

  @override
  String get tierChangeConfirm => 'Confirm change';

  @override
  String get tierChangeDone => 'Tier updated.';

  @override
  String get newMemberTitle => 'New member';

  @override
  String get stepPersonal => 'Personal data';

  @override
  String get stepMembership => 'Membership';

  @override
  String get stepPayment => 'Payment';

  @override
  String get stepSummary => 'Summary';

  @override
  String get newMemberConfirm => 'Create member';

  @override
  String get tempPasswordTitle => 'Temporary password';

  @override
  String tempPasswordCreated(String name) {
    return 'Account ready: $name';
  }

  @override
  String tempPasswordUser(String phone) {
    return 'User: $phone';
  }

  @override
  String get tempPasswordWarning =>
      'This password is shown only once. Copy or share it now. They\'ll be asked to change it at first login.';

  @override
  String get tempPasswordCopy => 'Copy';

  @override
  String get tempPasswordCopied => 'Password copied.';

  @override
  String get tempPasswordShare => 'Share via WhatsApp';

  @override
  String tempPasswordShareText(String name, String phone, String password) {
    return 'Hi $name, you can now sign in to the gym app.\nUser: $phone\nTemporary password: $password\nYou\'ll be asked to change it when you sign in.';
  }

  @override
  String get morePricing => 'Prices';

  @override
  String get moreStaff => 'Staff';

  @override
  String get moreReports => 'Reports';

  @override
  String get moreSettings => 'Gym settings';

  @override
  String get moreProfile => 'My profile';

  @override
  String get pricingInfo =>
      'Monthly price of each tier. Changing it doesn\'t affect past payments.';

  @override
  String pricingMonthly(String tier) {
    return '$tier (Bs per month)';
  }

  @override
  String get staffAll => 'All';

  @override
  String get staffShowInactive => 'Show inactive';

  @override
  String get staffEmpty => 'No accounts.';

  @override
  String get staffNew => 'New account';

  @override
  String get newStaffTitle => 'New staff account';

  @override
  String get fieldRole => 'Role';

  @override
  String get staffCreate => 'Create account';

  @override
  String get settingsGymName => 'Gym name';

  @override
  String get settingsCooldown =>
      'Minutes between check-ins (prevents duplicates)';

  @override
  String get settingsInsideWindow => 'Minutes that count as \"inside\"';

  @override
  String get settingsCountryCode => 'Default country code';

  @override
  String get settingsTimezone => 'Time zone';

  @override
  String get settingsTimezoneHint => 'Set on the server.';
}
