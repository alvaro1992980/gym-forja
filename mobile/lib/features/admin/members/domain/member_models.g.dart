// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'member_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PersonRef _$PersonRefFromJson(Map<String, dynamic> json) => _PersonRef(
  id: json['id'] as String,
  firstName: json['firstName'] as String,
  lastName: json['lastName'] as String,
);

Map<String, dynamic> _$PersonRefToJson(_PersonRef instance) =>
    <String, dynamic>{
      'id': instance.id,
      'firstName': instance.firstName,
      'lastName': instance.lastName,
    };

_MemberListItem _$MemberListItemFromJson(Map<String, dynamic> json) =>
    _MemberListItem(
      id: json['id'] as String,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      phone: json['phone'] as String,
      isActive: json['isActive'] as bool,
      tier: $enumDecode(_$TierEnumMap, json['tier']),
      endDate: json['endDate'] as String,
      daysLeft: (json['daysLeft'] as num).toInt(),
      status: $enumDecode(_$MemberStatusEnumMap, json['status']),
      trainerId: json['trainerId'] as String?,
      lastCheckinAt: json['lastCheckinAt'] as String?,
    );

Map<String, dynamic> _$MemberListItemToJson(_MemberListItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'firstName': instance.firstName,
      'lastName': instance.lastName,
      'phone': instance.phone,
      'isActive': instance.isActive,
      'tier': _$TierEnumMap[instance.tier]!,
      'endDate': instance.endDate,
      'daysLeft': instance.daysLeft,
      'status': _$MemberStatusEnumMap[instance.status]!,
      'trainerId': instance.trainerId,
      'lastCheckinAt': instance.lastCheckinAt,
    };

const _$TierEnumMap = {
  Tier.basic: 'BASIC',
  Tier.plus: 'PLUS',
  Tier.premium: 'PREMIUM',
};

const _$MemberStatusEnumMap = {
  MemberStatus.active: 'active',
  MemberStatus.expired: 'expired',
  MemberStatus.inactive: 'inactive',
};

_Payment _$PaymentFromJson(Map<String, dynamic> json) => _Payment(
  id: json['id'] as String,
  memberId: json['memberId'] as String,
  kind: $enumDecode(_$PaymentKindEnumMap, json['kind']),
  tier: $enumDecode(_$TierEnumMap, json['tier']),
  months: (json['months'] as num).toInt(),
  periodStart: json['periodStart'] as String?,
  periodEnd: json['periodEnd'] as String?,
  amount: json['amount'] as String,
  suggestedAmount: json['suggestedAmount'] as String,
  currency: json['currency'] as String,
  method: $enumDecode(_$PaymentMethodEnumMap, json['method']),
  note: json['note'] as String?,
  recordedBy: PersonRef.fromJson(json['recordedBy'] as Map<String, dynamic>),
  paidAt: json['paidAt'] as String,
  voidedAt: json['voidedAt'] as String?,
  voidReason: json['voidReason'] as String?,
);

Map<String, dynamic> _$PaymentToJson(_Payment instance) => <String, dynamic>{
  'id': instance.id,
  'memberId': instance.memberId,
  'kind': _$PaymentKindEnumMap[instance.kind]!,
  'tier': _$TierEnumMap[instance.tier]!,
  'months': instance.months,
  'periodStart': instance.periodStart,
  'periodEnd': instance.periodEnd,
  'amount': instance.amount,
  'suggestedAmount': instance.suggestedAmount,
  'currency': instance.currency,
  'method': _$PaymentMethodEnumMap[instance.method]!,
  'note': instance.note,
  'recordedBy': instance.recordedBy.toJson(),
  'paidAt': instance.paidAt,
  'voidedAt': instance.voidedAt,
  'voidReason': instance.voidReason,
};

const _$PaymentKindEnumMap = {
  PaymentKind.newMembership: 'NEW',
  PaymentKind.renewal: 'RENEWAL',
  PaymentKind.upgrade: 'UPGRADE',
};

const _$PaymentMethodEnumMap = {
  PaymentMethod.cash: 'CASH',
  PaymentMethod.transfer: 'TRANSFER',
  PaymentMethod.qr: 'QR',
  PaymentMethod.card: 'CARD',
  PaymentMethod.other: 'OTHER',
};

_CheckinRef _$CheckinRefFromJson(Map<String, dynamic> json) => _CheckinRef(
  id: json['id'] as String,
  createdAt: json['createdAt'] as String,
  tier: $enumDecode(_$TierEnumMap, json['tier']),
  daysLeft: (json['daysLeft'] as num).toInt(),
);

Map<String, dynamic> _$CheckinRefToJson(_CheckinRef instance) =>
    <String, dynamic>{
      'id': instance.id,
      'createdAt': instance.createdAt,
      'tier': _$TierEnumMap[instance.tier]!,
      'daysLeft': instance.daysLeft,
    };

_MemberDetail _$MemberDetailFromJson(Map<String, dynamic> json) =>
    _MemberDetail(
      id: json['id'] as String,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      phone: json['phone'] as String,
      email: json['email'] as String?,
      birthDate: json['birthDate'] as String?,
      gender: json['gender'] as String?,
      emergencyContact: json['emergencyContact'] as String?,
      medicalNotes: json['medicalNotes'] as String?,
      isActive: json['isActive'] as bool,
      mustChangePassword: json['mustChangePassword'] as bool,
      createdAt: json['createdAt'] as String,
      membership: MembershipSummary.fromJson(
        json['membership'] as Map<String, dynamic>,
      ),
      trainer: json['trainer'] == null
          ? null
          : PersonRef.fromJson(json['trainer'] as Map<String, dynamic>),
      recentCheckins:
          (json['recentCheckins'] as List<dynamic>?)
              ?.map((e) => CheckinRef.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <CheckinRef>[],
      payments:
          (json['payments'] as List<dynamic>?)
              ?.map((e) => Payment.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <Payment>[],
    );

Map<String, dynamic> _$MemberDetailToJson(_MemberDetail instance) =>
    <String, dynamic>{
      'id': instance.id,
      'firstName': instance.firstName,
      'lastName': instance.lastName,
      'phone': instance.phone,
      'email': instance.email,
      'birthDate': instance.birthDate,
      'gender': instance.gender,
      'emergencyContact': instance.emergencyContact,
      'medicalNotes': instance.medicalNotes,
      'isActive': instance.isActive,
      'mustChangePassword': instance.mustChangePassword,
      'createdAt': instance.createdAt,
      'membership': instance.membership.toJson(),
      'trainer': instance.trainer?.toJson(),
      'recentCheckins': instance.recentCheckins.map((e) => e.toJson()).toList(),
      'payments': instance.payments.map((e) => e.toJson()).toList(),
    };

_PaymentPreview _$PaymentPreviewFromJson(Map<String, dynamic> json) =>
    _PaymentPreview(
      periodStart: json['periodStart'] as String,
      periodEnd: json['periodEnd'] as String,
      suggestedAmount: json['suggestedAmount'] as String,
      currency: json['currency'] as String,
      tierApplies: $enumDecode(_$TierAppliesEnumMap, json['tierApplies']),
    );

Map<String, dynamic> _$PaymentPreviewToJson(_PaymentPreview instance) =>
    <String, dynamic>{
      'periodStart': instance.periodStart,
      'periodEnd': instance.periodEnd,
      'suggestedAmount': instance.suggestedAmount,
      'currency': instance.currency,
      'tierApplies': _$TierAppliesEnumMap[instance.tierApplies]!,
    };

const _$TierAppliesEnumMap = {
  TierApplies.unchanged: 'unchanged',
  TierApplies.now: 'now',
  TierApplies.scheduled: 'scheduled',
};

_TierChangePreview _$TierChangePreviewFromJson(Map<String, dynamic> json) =>
    _TierChangePreview(
      fromTier: $enumDecode(_$TierEnumMap, json['fromTier']),
      toTier: $enumDecode(_$TierEnumMap, json['toTier']),
      isUpgrade: json['isUpgrade'] as bool,
      daysLeft: (json['daysLeft'] as num).toInt(),
      suggestedAmount: json['suggestedAmount'] as String,
      currency: json['currency'] as String,
      warning: json['warning'] as String?,
    );

Map<String, dynamic> _$TierChangePreviewToJson(_TierChangePreview instance) =>
    <String, dynamic>{
      'fromTier': _$TierEnumMap[instance.fromTier]!,
      'toTier': _$TierEnumMap[instance.toTier]!,
      'isUpgrade': instance.isUpgrade,
      'daysLeft': instance.daysLeft,
      'suggestedAmount': instance.suggestedAmount,
      'currency': instance.currency,
      'warning': instance.warning,
    };
