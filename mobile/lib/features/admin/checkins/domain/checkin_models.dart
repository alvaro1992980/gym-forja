import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/models/enums.dart';
import '../../members/domain/member_models.dart';

part 'checkin_models.freezed.dart';
part 'checkin_models.g.dart';

/// Row of `GET /admin/checkins` and `/admin/checkins/inside`.
@freezed
abstract class CheckinItem with _$CheckinItem {
  const factory CheckinItem({
    required String id,
    required PersonRef member,
    required Tier tier,
    required int daysLeft,
    required String createdAt,
  }) = _CheckinItem;

  factory CheckinItem.fromJson(Map<String, dynamic> json) =>
      _$CheckinItemFromJson(json);
}

/// [R-22] results stored for every scan.
@JsonEnum(fieldRename: FieldRename.screamingSnake)
enum CheckinResult {
  success,
  duplicate,
  deniedExpired,
  deniedInactive,
  invalidToken,
}

/// Row of `GET /admin/checkins/attempts`.
@freezed
abstract class CheckinAttempt with _$CheckinAttempt {
  const factory CheckinAttempt({
    required String id,
    required CheckinResult result,
    PersonRef? member,
    String? detail,
    required String createdAt,
  }) = _CheckinAttempt;

  const CheckinAttempt._();

  factory CheckinAttempt.fromJson(Map<String, dynamic> json) =>
      _$CheckinAttemptFromJson(json);

  bool get isDenied =>
      result == CheckinResult.deniedExpired ||
      result == CheckinResult.deniedInactive;

  /// `endDate=2026-11-10` in the detail of expired denials.
  String? get endDate {
    final d = detail;
    return d != null && d.startsWith('endDate=') ? d.substring(8) : null;
  }
}

/// `GET /admin/checkins/inside` [R-23].
@freezed
abstract class InsideNow with _$InsideNow {
  const factory InsideNow({
    required int count,
    required int windowMinutes,
    required List<CheckinItem> items,
  }) = _InsideNow;

  factory InsideNow.fromJson(Map<String, dynamic> json) =>
      _$InsideNowFromJson(json);
}

/// One row of the live feed: a check-in or a denied entry (shown in red).
sealed class FeedEntry {
  const FeedEntry();

  /// Stable key for list animations.
  String get key;
  PersonRef get member;
  String get createdAt;
}

final class FeedCheckin extends FeedEntry {
  const FeedCheckin(this.checkin);

  final CheckinItem checkin;

  @override
  String get key => 'c:${checkin.id}';
  @override
  PersonRef get member => checkin.member;
  @override
  String get createdAt => checkin.createdAt;
}

final class FeedDenied extends FeedEntry {
  const FeedDenied({
    required this.member,
    required this.expired,
    required this.endDate,
    required this.createdAt,
  });

  @override
  final PersonRef member;

  /// Expired membership; otherwise a deactivated account.
  final bool expired;
  final String? endDate;
  @override
  final String createdAt;

  @override
  String get key => 'd:${member.id}:$createdAt';
}
