// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'current_user.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CurrentUser {

 String get id; Role get role; String get firstName; String get lastName; String get phone; String? get email; bool get mustChangePassword; String? get birthDate; String? get gender; String? get emergencyContact;/// Only for members.
 MembershipSummary? get membership;
/// Create a copy of CurrentUser
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CurrentUserCopyWith<CurrentUser> get copyWith => _$CurrentUserCopyWithImpl<CurrentUser>(this as CurrentUser, _$identity);

  /// Serializes this CurrentUser to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as CurrentUser;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CurrentUser&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.role, _this.role) || other.role == _this.role)&&(identical(other.firstName, _this.firstName) || other.firstName == _this.firstName)&&(identical(other.lastName, _this.lastName) || other.lastName == _this.lastName)&&(identical(other.phone, _this.phone) || other.phone == _this.phone)&&(identical(other.email, _this.email) || other.email == _this.email)&&(identical(other.mustChangePassword, _this.mustChangePassword) || other.mustChangePassword == _this.mustChangePassword)&&(identical(other.birthDate, _this.birthDate) || other.birthDate == _this.birthDate)&&(identical(other.gender, _this.gender) || other.gender == _this.gender)&&(identical(other.emergencyContact, _this.emergencyContact) || other.emergencyContact == _this.emergencyContact)&&(identical(other.membership, _this.membership) || other.membership == _this.membership));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as CurrentUser;
  return Object.hash(runtimeType,_this.id,_this.role,_this.firstName,_this.lastName,_this.phone,_this.email,_this.mustChangePassword,_this.birthDate,_this.gender,_this.emergencyContact,_this.membership);
}

@override
String toString() {
  final _this = this as CurrentUser;
  return 'CurrentUser(id: ${_this.id}, role: ${_this.role}, firstName: ${_this.firstName}, lastName: ${_this.lastName}, phone: ${_this.phone}, email: ${_this.email}, mustChangePassword: ${_this.mustChangePassword}, birthDate: ${_this.birthDate}, gender: ${_this.gender}, emergencyContact: ${_this.emergencyContact}, membership: ${_this.membership})';
}


}

/// @nodoc
abstract mixin class $CurrentUserCopyWith<$Res>  {
  factory $CurrentUserCopyWith(CurrentUser value, $Res Function(CurrentUser) _then) = _$CurrentUserCopyWithImpl;
@useResult
$Res call({
 String id, Role role, String firstName, String lastName, String phone, String? email, bool mustChangePassword, String? birthDate, String? gender, String? emergencyContact, MembershipSummary? membership
});


$MembershipSummaryCopyWith<$Res>? get membership;

}
/// @nodoc
class _$CurrentUserCopyWithImpl<$Res>
    implements $CurrentUserCopyWith<$Res> {
  _$CurrentUserCopyWithImpl(this._self, this._then);

  final CurrentUser _self;
  final $Res Function(CurrentUser) _then;

/// Create a copy of CurrentUser
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? role = null,Object? firstName = null,Object? lastName = null,Object? phone = null,Object? email = freezed,Object? mustChangePassword = null,Object? birthDate = freezed,Object? gender = freezed,Object? emergencyContact = freezed,Object? membership = freezed,}) {
  return _then(CurrentUser(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as Role,firstName: null == firstName ? _self.firstName : firstName // ignore: cast_nullable_to_non_nullable
as String,lastName: null == lastName ? _self.lastName : lastName // ignore: cast_nullable_to_non_nullable
as String,phone: null == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,mustChangePassword: null == mustChangePassword ? _self.mustChangePassword : mustChangePassword // ignore: cast_nullable_to_non_nullable
as bool,birthDate: freezed == birthDate ? _self.birthDate : birthDate // ignore: cast_nullable_to_non_nullable
as String?,gender: freezed == gender ? _self.gender : gender // ignore: cast_nullable_to_non_nullable
as String?,emergencyContact: freezed == emergencyContact ? _self.emergencyContact : emergencyContact // ignore: cast_nullable_to_non_nullable
as String?,membership: freezed == membership ? _self.membership : membership // ignore: cast_nullable_to_non_nullable
as MembershipSummary?,
  ));
}
/// Create a copy of CurrentUser
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MembershipSummaryCopyWith<$Res>? get membership {
    if (_self.membership == null) {
    return null;
  }

  return $MembershipSummaryCopyWith<$Res>(_self.membership!, (value) {
    return _then(_self.copyWith(membership: value));
  });
}
}


/// Adds pattern-matching-related methods to [CurrentUser].
extension CurrentUserPatterns on CurrentUser {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CurrentUser value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CurrentUser() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CurrentUser value)  $default,){
final _that = this;
switch (_that) {
case _CurrentUser():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CurrentUser value)?  $default,){
final _that = this;
switch (_that) {
case _CurrentUser() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  Role role,  String firstName,  String lastName,  String phone,  String? email,  bool mustChangePassword,  String? birthDate,  String? gender,  String? emergencyContact,  MembershipSummary? membership)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CurrentUser() when $default != null:
return $default(_that.id,_that.role,_that.firstName,_that.lastName,_that.phone,_that.email,_that.mustChangePassword,_that.birthDate,_that.gender,_that.emergencyContact,_that.membership);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  Role role,  String firstName,  String lastName,  String phone,  String? email,  bool mustChangePassword,  String? birthDate,  String? gender,  String? emergencyContact,  MembershipSummary? membership)  $default,) {final _that = this;
switch (_that) {
case _CurrentUser():
return $default(_that.id,_that.role,_that.firstName,_that.lastName,_that.phone,_that.email,_that.mustChangePassword,_that.birthDate,_that.gender,_that.emergencyContact,_that.membership);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  Role role,  String firstName,  String lastName,  String phone,  String? email,  bool mustChangePassword,  String? birthDate,  String? gender,  String? emergencyContact,  MembershipSummary? membership)?  $default,) {final _that = this;
switch (_that) {
case _CurrentUser() when $default != null:
return $default(_that.id,_that.role,_that.firstName,_that.lastName,_that.phone,_that.email,_that.mustChangePassword,_that.birthDate,_that.gender,_that.emergencyContact,_that.membership);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CurrentUser extends CurrentUser {
  const _CurrentUser({required this.id, required this.role, required this.firstName, required this.lastName, required this.phone, this.email, required this.mustChangePassword, this.birthDate, this.gender, this.emergencyContact, this.membership}): super._();
  factory _CurrentUser.fromJson(Map<String, dynamic> json) => _$CurrentUserFromJson(json);

@override final  String id;
@override final  Role role;
@override final  String firstName;
@override final  String lastName;
@override final  String phone;
@override final  String? email;
@override final  bool mustChangePassword;
@override final  String? birthDate;
@override final  String? gender;
@override final  String? emergencyContact;
/// Only for members.
@override final  MembershipSummary? membership;

/// Create a copy of CurrentUser
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CurrentUserCopyWith<_CurrentUser> get copyWith => __$CurrentUserCopyWithImpl<_CurrentUser>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CurrentUserToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CurrentUser&&(identical(other.id, id) || other.id == id)&&(identical(other.role, role) || other.role == role)&&(identical(other.firstName, firstName) || other.firstName == firstName)&&(identical(other.lastName, lastName) || other.lastName == lastName)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.email, email) || other.email == email)&&(identical(other.mustChangePassword, mustChangePassword) || other.mustChangePassword == mustChangePassword)&&(identical(other.birthDate, birthDate) || other.birthDate == birthDate)&&(identical(other.gender, gender) || other.gender == gender)&&(identical(other.emergencyContact, emergencyContact) || other.emergencyContact == emergencyContact)&&(identical(other.membership, membership) || other.membership == membership));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,role,firstName,lastName,phone,email,mustChangePassword,birthDate,gender,emergencyContact,membership);
}

@override
String toString() {
    return 'CurrentUser(id: $id, role: $role, firstName: $firstName, lastName: $lastName, phone: $phone, email: $email, mustChangePassword: $mustChangePassword, birthDate: $birthDate, gender: $gender, emergencyContact: $emergencyContact, membership: $membership)';
}


}

/// @nodoc
abstract mixin class _$CurrentUserCopyWith<$Res> implements $CurrentUserCopyWith<$Res> {
  factory _$CurrentUserCopyWith(_CurrentUser value, $Res Function(_CurrentUser) _then) = __$CurrentUserCopyWithImpl;
@override @useResult
$Res call({
 String id, Role role, String firstName, String lastName, String phone, String? email, bool mustChangePassword, String? birthDate, String? gender, String? emergencyContact, MembershipSummary? membership
});


@override $MembershipSummaryCopyWith<$Res>? get membership;

}
/// @nodoc
class __$CurrentUserCopyWithImpl<$Res>
    implements _$CurrentUserCopyWith<$Res> {
  __$CurrentUserCopyWithImpl(this._self, this._then);

  final _CurrentUser _self;
  final $Res Function(_CurrentUser) _then;

/// Create a copy of CurrentUser
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? role = null,Object? firstName = null,Object? lastName = null,Object? phone = null,Object? email = freezed,Object? mustChangePassword = null,Object? birthDate = freezed,Object? gender = freezed,Object? emergencyContact = freezed,Object? membership = freezed,}) {
  return _then(_CurrentUser(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as Role,firstName: null == firstName ? _self.firstName : firstName // ignore: cast_nullable_to_non_nullable
as String,lastName: null == lastName ? _self.lastName : lastName // ignore: cast_nullable_to_non_nullable
as String,phone: null == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,mustChangePassword: null == mustChangePassword ? _self.mustChangePassword : mustChangePassword // ignore: cast_nullable_to_non_nullable
as bool,birthDate: freezed == birthDate ? _self.birthDate : birthDate // ignore: cast_nullable_to_non_nullable
as String?,gender: freezed == gender ? _self.gender : gender // ignore: cast_nullable_to_non_nullable
as String?,emergencyContact: freezed == emergencyContact ? _self.emergencyContact : emergencyContact // ignore: cast_nullable_to_non_nullable
as String?,membership: freezed == membership ? _self.membership : membership // ignore: cast_nullable_to_non_nullable
as MembershipSummary?,
  ));
}

/// Create a copy of CurrentUser
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MembershipSummaryCopyWith<$Res>? get membership {
    if (_self.membership == null) {
    return null;
  }

  return $MembershipSummaryCopyWith<$Res>(_self.membership!, (value) {
    return _then(_self.copyWith(membership: value));
  });
}
}


/// @nodoc
mixin _$MembershipSummary {

 Tier get tier; String get startDate; String get endDate; int get daysLeft; MembershipStatus get status; Tier? get nextTier; String? get nextTierStartDate;
/// Create a copy of MembershipSummary
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MembershipSummaryCopyWith<MembershipSummary> get copyWith => _$MembershipSummaryCopyWithImpl<MembershipSummary>(this as MembershipSummary, _$identity);

  /// Serializes this MembershipSummary to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as MembershipSummary;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MembershipSummary&&(identical(other.tier, _this.tier) || other.tier == _this.tier)&&(identical(other.startDate, _this.startDate) || other.startDate == _this.startDate)&&(identical(other.endDate, _this.endDate) || other.endDate == _this.endDate)&&(identical(other.daysLeft, _this.daysLeft) || other.daysLeft == _this.daysLeft)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.nextTier, _this.nextTier) || other.nextTier == _this.nextTier)&&(identical(other.nextTierStartDate, _this.nextTierStartDate) || other.nextTierStartDate == _this.nextTierStartDate));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as MembershipSummary;
  return Object.hash(runtimeType,_this.tier,_this.startDate,_this.endDate,_this.daysLeft,_this.status,_this.nextTier,_this.nextTierStartDate);
}

@override
String toString() {
  final _this = this as MembershipSummary;
  return 'MembershipSummary(tier: ${_this.tier}, startDate: ${_this.startDate}, endDate: ${_this.endDate}, daysLeft: ${_this.daysLeft}, status: ${_this.status}, nextTier: ${_this.nextTier}, nextTierStartDate: ${_this.nextTierStartDate})';
}


}

/// @nodoc
abstract mixin class $MembershipSummaryCopyWith<$Res>  {
  factory $MembershipSummaryCopyWith(MembershipSummary value, $Res Function(MembershipSummary) _then) = _$MembershipSummaryCopyWithImpl;
@useResult
$Res call({
 Tier tier, String startDate, String endDate, int daysLeft, MembershipStatus status, Tier? nextTier, String? nextTierStartDate
});




}
/// @nodoc
class _$MembershipSummaryCopyWithImpl<$Res>
    implements $MembershipSummaryCopyWith<$Res> {
  _$MembershipSummaryCopyWithImpl(this._self, this._then);

  final MembershipSummary _self;
  final $Res Function(MembershipSummary) _then;

/// Create a copy of MembershipSummary
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? tier = null,Object? startDate = null,Object? endDate = null,Object? daysLeft = null,Object? status = null,Object? nextTier = freezed,Object? nextTierStartDate = freezed,}) {
  return _then(MembershipSummary(
tier: null == tier ? _self.tier : tier // ignore: cast_nullable_to_non_nullable
as Tier,startDate: null == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as String,endDate: null == endDate ? _self.endDate : endDate // ignore: cast_nullable_to_non_nullable
as String,daysLeft: null == daysLeft ? _self.daysLeft : daysLeft // ignore: cast_nullable_to_non_nullable
as int,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as MembershipStatus,nextTier: freezed == nextTier ? _self.nextTier : nextTier // ignore: cast_nullable_to_non_nullable
as Tier?,nextTierStartDate: freezed == nextTierStartDate ? _self.nextTierStartDate : nextTierStartDate // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [MembershipSummary].
extension MembershipSummaryPatterns on MembershipSummary {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MembershipSummary value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MembershipSummary() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MembershipSummary value)  $default,){
final _that = this;
switch (_that) {
case _MembershipSummary():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MembershipSummary value)?  $default,){
final _that = this;
switch (_that) {
case _MembershipSummary() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Tier tier,  String startDate,  String endDate,  int daysLeft,  MembershipStatus status,  Tier? nextTier,  String? nextTierStartDate)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MembershipSummary() when $default != null:
return $default(_that.tier,_that.startDate,_that.endDate,_that.daysLeft,_that.status,_that.nextTier,_that.nextTierStartDate);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Tier tier,  String startDate,  String endDate,  int daysLeft,  MembershipStatus status,  Tier? nextTier,  String? nextTierStartDate)  $default,) {final _that = this;
switch (_that) {
case _MembershipSummary():
return $default(_that.tier,_that.startDate,_that.endDate,_that.daysLeft,_that.status,_that.nextTier,_that.nextTierStartDate);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Tier tier,  String startDate,  String endDate,  int daysLeft,  MembershipStatus status,  Tier? nextTier,  String? nextTierStartDate)?  $default,) {final _that = this;
switch (_that) {
case _MembershipSummary() when $default != null:
return $default(_that.tier,_that.startDate,_that.endDate,_that.daysLeft,_that.status,_that.nextTier,_that.nextTierStartDate);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MembershipSummary implements MembershipSummary {
  const _MembershipSummary({required this.tier, required this.startDate, required this.endDate, required this.daysLeft, required this.status, this.nextTier, this.nextTierStartDate});
  factory _MembershipSummary.fromJson(Map<String, dynamic> json) => _$MembershipSummaryFromJson(json);

@override final  Tier tier;
@override final  String startDate;
@override final  String endDate;
@override final  int daysLeft;
@override final  MembershipStatus status;
@override final  Tier? nextTier;
@override final  String? nextTierStartDate;

/// Create a copy of MembershipSummary
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MembershipSummaryCopyWith<_MembershipSummary> get copyWith => __$MembershipSummaryCopyWithImpl<_MembershipSummary>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MembershipSummaryToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _MembershipSummary&&(identical(other.tier, tier) || other.tier == tier)&&(identical(other.startDate, startDate) || other.startDate == startDate)&&(identical(other.endDate, endDate) || other.endDate == endDate)&&(identical(other.daysLeft, daysLeft) || other.daysLeft == daysLeft)&&(identical(other.status, status) || other.status == status)&&(identical(other.nextTier, nextTier) || other.nextTier == nextTier)&&(identical(other.nextTierStartDate, nextTierStartDate) || other.nextTierStartDate == nextTierStartDate));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,tier,startDate,endDate,daysLeft,status,nextTier,nextTierStartDate);
}

@override
String toString() {
    return 'MembershipSummary(tier: $tier, startDate: $startDate, endDate: $endDate, daysLeft: $daysLeft, status: $status, nextTier: $nextTier, nextTierStartDate: $nextTierStartDate)';
}


}

/// @nodoc
abstract mixin class _$MembershipSummaryCopyWith<$Res> implements $MembershipSummaryCopyWith<$Res> {
  factory _$MembershipSummaryCopyWith(_MembershipSummary value, $Res Function(_MembershipSummary) _then) = __$MembershipSummaryCopyWithImpl;
@override @useResult
$Res call({
 Tier tier, String startDate, String endDate, int daysLeft, MembershipStatus status, Tier? nextTier, String? nextTierStartDate
});




}
/// @nodoc
class __$MembershipSummaryCopyWithImpl<$Res>
    implements _$MembershipSummaryCopyWith<$Res> {
  __$MembershipSummaryCopyWithImpl(this._self, this._then);

  final _MembershipSummary _self;
  final $Res Function(_MembershipSummary) _then;

/// Create a copy of MembershipSummary
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? tier = null,Object? startDate = null,Object? endDate = null,Object? daysLeft = null,Object? status = null,Object? nextTier = freezed,Object? nextTierStartDate = freezed,}) {
  return _then(_MembershipSummary(
tier: null == tier ? _self.tier : tier // ignore: cast_nullable_to_non_nullable
as Tier,startDate: null == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as String,endDate: null == endDate ? _self.endDate : endDate // ignore: cast_nullable_to_non_nullable
as String,daysLeft: null == daysLeft ? _self.daysLeft : daysLeft // ignore: cast_nullable_to_non_nullable
as int,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as MembershipStatus,nextTier: freezed == nextTier ? _self.nextTier : nextTier // ignore: cast_nullable_to_non_nullable
as Tier?,nextTierStartDate: freezed == nextTierStartDate ? _self.nextTierStartDate : nextTierStartDate // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
