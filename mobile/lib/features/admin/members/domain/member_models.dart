import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/models/enums.dart';
import '../../../auth/domain/current_user.dart';

part 'member_models.freezed.dart';
part 'member_models.g.dart';

/// `{id, firstName, lastName}`.
@freezed
abstract class PersonRef with _$PersonRef {
  const factory PersonRef({
    required String id,
    required String firstName,
    required String lastName,
  }) = _PersonRef;

  const PersonRef._();

  factory PersonRef.fromJson(Map<String, dynamic> json) =>
      _$PersonRefFromJson(json);

  String get fullName => '$firstName $lastName';
}

/// Row of `GET /admin/members`.
@freezed
abstract class MemberListItem with _$MemberListItem {
  const factory MemberListItem({
    required String id,
    required String firstName,
    required String lastName,
    required String phone,
    required bool isActive,
    required Tier tier,
    required String endDate,
    required int daysLeft,
    required MemberStatus status,
    String? trainerId,
    String? lastCheckinAt,
  }) = _MemberListItem;

  const MemberListItem._();

  factory MemberListItem.fromJson(Map<String, dynamic> json) =>
      _$MemberListItemFromJson(json);

  String get fullName => '$firstName $lastName';
}

/// Admin view of a payment.
@freezed
abstract class Payment with _$Payment {
  const factory Payment({
    required String id,
    required String memberId,
    required PaymentKind kind,
    required Tier tier,
    required int months,
    String? periodStart,
    String? periodEnd,
    required String amount,
    required String suggestedAmount,
    required String currency,
    required PaymentMethod method,
    String? note,
    required PersonRef recordedBy,
    required String paidAt,
    String? voidedAt,
    String? voidReason,
  }) = _Payment;

  const Payment._();

  factory Payment.fromJson(Map<String, dynamic> json) =>
      _$PaymentFromJson(json);

  bool get isVoided => voidedAt != null;
}

@freezed
abstract class CheckinRef with _$CheckinRef {
  const factory CheckinRef({
    required String id,
    required String createdAt,
    required Tier tier,
    required int daysLeft,
  }) = _CheckinRef;

  factory CheckinRef.fromJson(Map<String, dynamic> json) =>
      _$CheckinRefFromJson(json);
}

/// `GET /admin/members/:id`.
@freezed
abstract class MemberDetail with _$MemberDetail {
  const factory MemberDetail({
    required String id,
    required String firstName,
    required String lastName,
    required String phone,
    String? email,
    String? birthDate,
    String? gender,
    String? emergencyContact,
    String? medicalNotes,
    required bool isActive,
    required bool mustChangePassword,
    required String createdAt,
    required MembershipSummary membership,
    PersonRef? trainer,
    @Default(<CheckinRef>[]) List<CheckinRef> recentCheckins,
    @Default(<Payment>[]) List<Payment> payments,
  }) = _MemberDetail;

  const MemberDetail._();

  factory MemberDetail.fromJson(Map<String, dynamic> json) =>
      _$MemberDetailFromJson(json);

  String get fullName => '$firstName $lastName';
}

/// Renewal / new member preview ([R-07]–[R-10]).
@freezed
abstract class PaymentPreview with _$PaymentPreview {
  const factory PaymentPreview({
    required String periodStart,
    required String periodEnd,
    required String suggestedAmount,
    required String currency,
    required TierApplies tierApplies,
  }) = _PaymentPreview;

  factory PaymentPreview.fromJson(Map<String, dynamic> json) =>
      _$PaymentPreviewFromJson(json);
}

/// Tier change preview ([R-13]/[R-14]).
@freezed
abstract class TierChangePreview with _$TierChangePreview {
  const factory TierChangePreview({
    required Tier fromTier,
    required Tier toTier,
    required bool isUpgrade,
    required int daysLeft,
    required String suggestedAmount,
    required String currency,
    String? warning,
  }) = _TierChangePreview;

  factory TierChangePreview.fromJson(Map<String, dynamic> json) =>
      _$TierChangePreviewFromJson(json);
}

/// Data entered in the new-member stepper (`POST /admin/members`).
class NewMemberInput {
  const NewMemberInput({
    required this.firstName,
    required this.lastName,
    required this.phone,
    this.email,
    this.birthDate,
    this.gender,
    this.emergencyContact,
    this.medicalNotes,
    required this.tier,
    required this.months,
    this.startDate,
    required this.amountCents,
    required this.method,
    this.note,
  });

  final String firstName;
  final String lastName;
  final String phone;
  final String? email;
  final String? birthDate;
  final String? gender;
  final String? emergencyContact;
  final String? medicalNotes;
  final Tier tier;
  final int months;
  final String? startDate;
  final int amountCents;
  final PaymentMethod method;
  final String? note;
}

/// Editable profile fields (`PATCH /admin/members/:id`; null clears).
class MemberProfileInput {
  const MemberProfileInput({
    required this.firstName,
    required this.lastName,
    required this.phone,
    this.email,
    this.birthDate,
    this.gender,
    this.emergencyContact,
    this.medicalNotes,
  });

  final String firstName;
  final String lastName;
  final String phone;
  final String? email;
  final String? birthDate;
  final String? gender;
  final String? emergencyContact;
  final String? medicalNotes;

  Map<String, Object?> toJson() => {
    'firstName': firstName,
    'lastName': lastName,
    'phone': phone,
    'email': email,
    'birthDate': birthDate,
    'gender': gender,
    'emergencyContact': emergencyContact,
    'medicalNotes': medicalNotes,
  };
}

/// Filters of the members list (section 9.3 #2).
@freezed
abstract class MemberFilters with _$MemberFilters {
  const factory MemberFilters({
    @Default('') String query,
    MemberStatusFilter? status,
    Tier? tier,
  }) = _MemberFilters;
}

/// `status` query values of `GET /admin/members`.
enum MemberStatusFilter { active, expiring, expired, inactive }
