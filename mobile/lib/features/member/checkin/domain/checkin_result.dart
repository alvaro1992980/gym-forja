import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/models/enums.dart';
import '../../../../core/network/api_exception.dart';

part 'checkin_result.freezed.dart';
part 'checkin_result.g.dart';

/// `POST /checkins` success body (docs/PLAN.md 8.4).
@freezed
abstract class CheckinResponse with _$CheckinResponse {
  const factory CheckinResponse({
    required bool duplicate,
    required String checkinId,
    required String checkedInAt,
    required CheckinMember member,
    required CheckinMembership membership,

    /// Today's workout for PLUS/PREMIUM (D11/D12); null until then.
    Map<String, dynamic>? todayWorkout,
  }) = _CheckinResponse;

  factory CheckinResponse.fromJson(Map<String, dynamic> json) =>
      _$CheckinResponseFromJson(json);
}

@freezed
abstract class CheckinMember with _$CheckinMember {
  const factory CheckinMember({required String firstName}) = _CheckinMember;

  factory CheckinMember.fromJson(Map<String, dynamic> json) =>
      _$CheckinMemberFromJson(json);
}

@freezed
abstract class CheckinMembership with _$CheckinMembership {
  const factory CheckinMembership({
    required Tier tier,
    required String endDate,
    required int daysLeft,
  }) = _CheckinMembership;

  factory CheckinMembership.fromJson(Map<String, dynamic> json) =>
      _$CheckinMembershipFromJson(json);
}

/// What the result screen shows (section 9.5 #3).
sealed class CheckinOutcome {
  const CheckinOutcome();

  /// Maps a failed `POST /checkins` to the screen variant.
  factory CheckinOutcome.fromError(Object error) {
    if (error is ApiException) {
      switch (error.code) {
        case 'MEMBERSHIP_EXPIRED':
          final details = error.details;
          return CheckinExpired(
            endDate: details is Map ? details['endDate'] as String? : null,
          );
        case 'QR_TOKEN_EXPIRED' || 'QR_TOKEN_INVALID':
          return const CheckinInvalidQr();
        case 'ACCOUNT_INACTIVE':
          return const CheckinInactive();
      }
    }
    return CheckinFailed(error);
  }
}

/// SUCCESS or DUPLICATE [R-19].
final class CheckinAccepted extends CheckinOutcome {
  const CheckinAccepted(this.response);
  final CheckinResponse response;
}

/// [R-20] Expired membership.
final class CheckinExpired extends CheckinOutcome {
  const CheckinExpired({this.endDate});
  final String? endDate;
}

/// Expired, tampered or unknown QR [R-17]/[R-18]: scan again.
final class CheckinInvalidQr extends CheckinOutcome {
  const CheckinInvalidQr();
}

/// [R-21] Deactivated account.
final class CheckinInactive extends CheckinOutcome {
  const CheckinInactive();
}

/// No connection, server error, rate limit…
final class CheckinFailed extends CheckinOutcome {
  const CheckinFailed(this.error);
  final Object error;
}
