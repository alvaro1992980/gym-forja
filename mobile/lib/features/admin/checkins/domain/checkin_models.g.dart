// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'checkin_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CheckinItem _$CheckinItemFromJson(Map<String, dynamic> json) => _CheckinItem(
  id: json['id'] as String,
  member: PersonRef.fromJson(json['member'] as Map<String, dynamic>),
  tier: $enumDecode(_$TierEnumMap, json['tier']),
  daysLeft: (json['daysLeft'] as num).toInt(),
  createdAt: json['createdAt'] as String,
);

Map<String, dynamic> _$CheckinItemToJson(_CheckinItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'member': instance.member.toJson(),
      'tier': _$TierEnumMap[instance.tier]!,
      'daysLeft': instance.daysLeft,
      'createdAt': instance.createdAt,
    };

const _$TierEnumMap = {
  Tier.basic: 'BASIC',
  Tier.plus: 'PLUS',
  Tier.premium: 'PREMIUM',
};

_CheckinAttempt _$CheckinAttemptFromJson(Map<String, dynamic> json) =>
    _CheckinAttempt(
      id: json['id'] as String,
      result: $enumDecode(_$CheckinResultEnumMap, json['result']),
      member: json['member'] == null
          ? null
          : PersonRef.fromJson(json['member'] as Map<String, dynamic>),
      detail: json['detail'] as String?,
      createdAt: json['createdAt'] as String,
    );

Map<String, dynamic> _$CheckinAttemptToJson(_CheckinAttempt instance) =>
    <String, dynamic>{
      'id': instance.id,
      'result': _$CheckinResultEnumMap[instance.result]!,
      'member': instance.member?.toJson(),
      'detail': instance.detail,
      'createdAt': instance.createdAt,
    };

const _$CheckinResultEnumMap = {
  CheckinResult.success: 'SUCCESS',
  CheckinResult.duplicate: 'DUPLICATE',
  CheckinResult.deniedExpired: 'DENIED_EXPIRED',
  CheckinResult.deniedInactive: 'DENIED_INACTIVE',
  CheckinResult.invalidToken: 'INVALID_TOKEN',
};

_InsideNow _$InsideNowFromJson(Map<String, dynamic> json) => _InsideNow(
  count: (json['count'] as num).toInt(),
  windowMinutes: (json['windowMinutes'] as num).toInt(),
  items: (json['items'] as List<dynamic>)
      .map((e) => CheckinItem.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$InsideNowToJson(_InsideNow instance) =>
    <String, dynamic>{
      'count': instance.count,
      'windowMinutes': instance.windowMinutes,
      'items': instance.items.map((e) => e.toJson()).toList(),
    };
