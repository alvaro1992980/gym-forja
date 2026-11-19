import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../core/models/enums.dart';

part 'current_user.freezed.dart';
part 'current_user.g.dart';

/// The signed-in user, as returned by `GET /me`.
@freezed
abstract class CurrentUser with _$CurrentUser {
  const factory CurrentUser({
    required String id,
    required Role role,
    required String firstName,
    required String lastName,
    required String phone,
    String? email,
    required bool mustChangePassword,
    String? birthDate,
    String? gender,
    String? emergencyContact,

    /// Only for members.
    MembershipSummary? membership,
  }) = _CurrentUser;

  const CurrentUser._();

  factory CurrentUser.fromJson(Map<String, dynamic> json) =>
      _$CurrentUserFromJson(json);

  String get fullName => '$firstName $lastName';
}

/// Date-derived view of a membership. Dates are gym-local `yyyy-MM-dd`.
@freezed
abstract class MembershipSummary with _$MembershipSummary {
  const factory MembershipSummary({
    required Tier tier,
    required String startDate,
    required String endDate,
    required int daysLeft,
    required MembershipStatus status,
    Tier? nextTier,
    String? nextTierStartDate,
  }) = _MembershipSummary;

  factory MembershipSummary.fromJson(Map<String, dynamic> json) =>
      _$MembershipSummaryFromJson(json);
}
