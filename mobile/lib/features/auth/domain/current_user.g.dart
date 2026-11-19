// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'current_user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CurrentUser _$CurrentUserFromJson(Map<String, dynamic> json) => _CurrentUser(
  id: json['id'] as String,
  role: $enumDecode(_$RoleEnumMap, json['role']),
  firstName: json['firstName'] as String,
  lastName: json['lastName'] as String,
  phone: json['phone'] as String,
  email: json['email'] as String?,
  mustChangePassword: json['mustChangePassword'] as bool,
  birthDate: json['birthDate'] as String?,
  gender: json['gender'] as String?,
  emergencyContact: json['emergencyContact'] as String?,
  membership: json['membership'] == null
      ? null
      : MembershipSummary.fromJson(json['membership'] as Map<String, dynamic>),
);

Map<String, dynamic> _$CurrentUserToJson(_CurrentUser instance) =>
    <String, dynamic>{
      'id': instance.id,
      'role': _$RoleEnumMap[instance.role]!,
      'firstName': instance.firstName,
      'lastName': instance.lastName,
      'phone': instance.phone,
      'email': instance.email,
      'mustChangePassword': instance.mustChangePassword,
      'birthDate': instance.birthDate,
      'gender': instance.gender,
      'emergencyContact': instance.emergencyContact,
      'membership': instance.membership?.toJson(),
    };

const _$RoleEnumMap = {
  Role.admin: 'ADMIN',
  Role.trainer: 'TRAINER',
  Role.member: 'MEMBER',
  Role.kiosk: 'KIOSK',
};

_MembershipSummary _$MembershipSummaryFromJson(Map<String, dynamic> json) =>
    _MembershipSummary(
      tier: $enumDecode(_$TierEnumMap, json['tier']),
      startDate: json['startDate'] as String,
      endDate: json['endDate'] as String,
      daysLeft: (json['daysLeft'] as num).toInt(),
      status: $enumDecode(_$MembershipStatusEnumMap, json['status']),
      nextTier: $enumDecodeNullable(_$TierEnumMap, json['nextTier']),
      nextTierStartDate: json['nextTierStartDate'] as String?,
    );

Map<String, dynamic> _$MembershipSummaryToJson(_MembershipSummary instance) =>
    <String, dynamic>{
      'tier': _$TierEnumMap[instance.tier]!,
      'startDate': instance.startDate,
      'endDate': instance.endDate,
      'daysLeft': instance.daysLeft,
      'status': _$MembershipStatusEnumMap[instance.status]!,
      'nextTier': _$TierEnumMap[instance.nextTier],
      'nextTierStartDate': instance.nextTierStartDate,
    };

const _$TierEnumMap = {
  Tier.basic: 'BASIC',
  Tier.plus: 'PLUS',
  Tier.premium: 'PREMIUM',
};

const _$MembershipStatusEnumMap = {
  MembershipStatus.active: 'active',
  MembershipStatus.expired: 'expired',
};
