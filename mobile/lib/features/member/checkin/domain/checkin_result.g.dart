// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'checkin_result.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CheckinResponse _$CheckinResponseFromJson(Map<String, dynamic> json) =>
    _CheckinResponse(
      duplicate: json['duplicate'] as bool,
      checkinId: json['checkinId'] as String,
      checkedInAt: json['checkedInAt'] as String,
      member: CheckinMember.fromJson(json['member'] as Map<String, dynamic>),
      membership: CheckinMembership.fromJson(
        json['membership'] as Map<String, dynamic>,
      ),
      todayWorkout: json['todayWorkout'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$CheckinResponseToJson(_CheckinResponse instance) =>
    <String, dynamic>{
      'duplicate': instance.duplicate,
      'checkinId': instance.checkinId,
      'checkedInAt': instance.checkedInAt,
      'member': instance.member.toJson(),
      'membership': instance.membership.toJson(),
      'todayWorkout': instance.todayWorkout,
    };

_CheckinMember _$CheckinMemberFromJson(Map<String, dynamic> json) =>
    _CheckinMember(firstName: json['firstName'] as String);

Map<String, dynamic> _$CheckinMemberToJson(_CheckinMember instance) =>
    <String, dynamic>{'firstName': instance.firstName};

_CheckinMembership _$CheckinMembershipFromJson(Map<String, dynamic> json) =>
    _CheckinMembership(
      tier: $enumDecode(_$TierEnumMap, json['tier']),
      endDate: json['endDate'] as String,
      daysLeft: (json['daysLeft'] as num).toInt(),
    );

Map<String, dynamic> _$CheckinMembershipToJson(_CheckinMembership instance) =>
    <String, dynamic>{
      'tier': _$TierEnumMap[instance.tier]!,
      'endDate': instance.endDate,
      'daysLeft': instance.daysLeft,
    };

const _$TierEnumMap = {
  Tier.basic: 'BASIC',
  Tier.plus: 'PLUS',
  Tier.premium: 'PREMIUM',
};
