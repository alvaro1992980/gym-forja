import '../../../core/models/enums.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../settings/data/gym_admin_repository.dart';

/// Localized names of API enums.
extension AdminLabels on AppLocalizations {
  String tierLabel(Tier tier) => switch (tier) {
    Tier.basic => tierBasic,
    Tier.plus => tierPlus,
    Tier.premium => tierPremium,
  };

  String methodLabel(PaymentMethod method) => switch (method) {
    PaymentMethod.cash => methodCash,
    PaymentMethod.transfer => methodTransfer,
    PaymentMethod.qr => methodQr,
    PaymentMethod.card => methodCard,
    PaymentMethod.other => methodOther,
  };

  String paymentKindLabel(PaymentKind kind) => switch (kind) {
    PaymentKind.newMembership => paymentKindNew,
    PaymentKind.renewal => paymentKindRenewal,
    PaymentKind.upgrade => paymentKindUpgrade,
  };

  String staffRoleLabel(StaffRole role) => switch (role) {
    StaffRole.admin => roleAdmin,
    StaffRole.trainer => roleTrainer,
    StaffRole.kiosk => roleKiosk,
  };

  /// Stored `gender` values (free text in the API) and their labels.
  String genderLabel(String value) => switch (value) {
    'MALE' => genderMale,
    'FEMALE' => genderFemale,
    'OTHER' => genderOther,
    _ => value,
  };
}

/// Values offered by the gender selector.
const genderValues = ['MALE', 'FEMALE', 'OTHER'];
