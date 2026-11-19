import 'package:json_annotation/json_annotation.dart';

/// User roles, as sent by the API (`ADMIN`, `TRAINER`, ...).
@JsonEnum(fieldRename: FieldRename.screamingSnake)
enum Role { admin, trainer, member, kiosk }

/// Membership tiers, as sent by the API (`BASIC`, `PLUS`, `PREMIUM`).
@JsonEnum(fieldRename: FieldRename.screamingSnake)
enum Tier { basic, plus, premium }

/// Date-derived membership status computed by the API ([R-01]–[R-03]).
@JsonEnum()
enum MembershipStatus { active, expired }
