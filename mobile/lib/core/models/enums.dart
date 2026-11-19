import 'package:json_annotation/json_annotation.dart';

/// User roles, as sent by the API (`ADMIN`, `TRAINER`, ...).
@JsonEnum(fieldRename: FieldRename.screamingSnake)
enum Role { admin, trainer, member, kiosk }

/// Membership tiers, as sent by the API (`BASIC`, `PLUS`, `PREMIUM`).
@JsonEnum(fieldRename: FieldRename.screamingSnake)
enum Tier {
  basic,
  plus,
  premium;

  /// Order used for upgrades/downgrades.
  int get rank => index;

  /// Value for query parameters and request bodies.
  String get api => name.toUpperCase();
}

/// Date-derived membership status computed by the API ([R-01]–[R-03]).
@JsonEnum()
enum MembershipStatus { active, expired }

/// Member status in admin lists (`inactive` = account deactivated).
@JsonEnum()
enum MemberStatus { active, expired, inactive }

/// [R-06] Payment methods.
@JsonEnum(fieldRename: FieldRename.screamingSnake)
enum PaymentMethod {
  cash,
  transfer,
  qr,
  card,
  other;

  String get api => name.toUpperCase();
}

@JsonEnum()
enum PaymentKind {
  @JsonValue('NEW')
  newMembership,
  @JsonValue('RENEWAL')
  renewal,
  @JsonValue('UPGRADE')
  upgrade,
}

/// When the tier of a renewal applies ([R-09]).
@JsonEnum()
enum TierApplies { unchanged, now, scheduled }
