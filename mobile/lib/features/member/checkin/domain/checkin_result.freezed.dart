// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'checkin_result.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CheckinResponse {

 bool get duplicate; String get checkinId; String get checkedInAt; CheckinMember get member; CheckinMembership get membership;/// Today's workout for PLUS/PREMIUM (D11/D12); null until then.
 Map<String, dynamic>? get todayWorkout;
/// Create a copy of CheckinResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CheckinResponseCopyWith<CheckinResponse> get copyWith => _$CheckinResponseCopyWithImpl<CheckinResponse>(this as CheckinResponse, _$identity);

  /// Serializes this CheckinResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as CheckinResponse;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CheckinResponse&&(identical(other.duplicate, _this.duplicate) || other.duplicate == _this.duplicate)&&(identical(other.checkinId, _this.checkinId) || other.checkinId == _this.checkinId)&&(identical(other.checkedInAt, _this.checkedInAt) || other.checkedInAt == _this.checkedInAt)&&(identical(other.member, _this.member) || other.member == _this.member)&&(identical(other.membership, _this.membership) || other.membership == _this.membership)&&const DeepCollectionEquality().equals(other.todayWorkout, _this.todayWorkout));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as CheckinResponse;
  return Object.hash(runtimeType,_this.duplicate,_this.checkinId,_this.checkedInAt,_this.member,_this.membership,const DeepCollectionEquality().hash(_this.todayWorkout));
}

@override
String toString() {
  final _this = this as CheckinResponse;
  return 'CheckinResponse(duplicate: ${_this.duplicate}, checkinId: ${_this.checkinId}, checkedInAt: ${_this.checkedInAt}, member: ${_this.member}, membership: ${_this.membership}, todayWorkout: ${_this.todayWorkout})';
}


}

/// @nodoc
abstract mixin class $CheckinResponseCopyWith<$Res>  {
  factory $CheckinResponseCopyWith(CheckinResponse value, $Res Function(CheckinResponse) _then) = _$CheckinResponseCopyWithImpl;
@useResult
$Res call({
 bool duplicate, String checkinId, String checkedInAt, CheckinMember member, CheckinMembership membership, Map<String, dynamic>? todayWorkout
});


$CheckinMemberCopyWith<$Res> get member;$CheckinMembershipCopyWith<$Res> get membership;

}
/// @nodoc
class _$CheckinResponseCopyWithImpl<$Res>
    implements $CheckinResponseCopyWith<$Res> {
  _$CheckinResponseCopyWithImpl(this._self, this._then);

  final CheckinResponse _self;
  final $Res Function(CheckinResponse) _then;

/// Create a copy of CheckinResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? duplicate = null,Object? checkinId = null,Object? checkedInAt = null,Object? member = null,Object? membership = null,Object? todayWorkout = freezed,}) {
  return _then(CheckinResponse(
duplicate: null == duplicate ? _self.duplicate : duplicate // ignore: cast_nullable_to_non_nullable
as bool,checkinId: null == checkinId ? _self.checkinId : checkinId // ignore: cast_nullable_to_non_nullable
as String,checkedInAt: null == checkedInAt ? _self.checkedInAt : checkedInAt // ignore: cast_nullable_to_non_nullable
as String,member: null == member ? _self.member : member // ignore: cast_nullable_to_non_nullable
as CheckinMember,membership: null == membership ? _self.membership : membership // ignore: cast_nullable_to_non_nullable
as CheckinMembership,todayWorkout: freezed == todayWorkout ? _self.todayWorkout : todayWorkout // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,
  ));
}
/// Create a copy of CheckinResponse
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CheckinMemberCopyWith<$Res> get member {
  
  return $CheckinMemberCopyWith<$Res>(_self.member, (value) {
    return _then(_self.copyWith(member: value));
  });
}/// Create a copy of CheckinResponse
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CheckinMembershipCopyWith<$Res> get membership {
  
  return $CheckinMembershipCopyWith<$Res>(_self.membership, (value) {
    return _then(_self.copyWith(membership: value));
  });
}
}


/// Adds pattern-matching-related methods to [CheckinResponse].
extension CheckinResponsePatterns on CheckinResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CheckinResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CheckinResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CheckinResponse value)  $default,){
final _that = this;
switch (_that) {
case _CheckinResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CheckinResponse value)?  $default,){
final _that = this;
switch (_that) {
case _CheckinResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool duplicate,  String checkinId,  String checkedInAt,  CheckinMember member,  CheckinMembership membership,  Map<String, dynamic>? todayWorkout)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CheckinResponse() when $default != null:
return $default(_that.duplicate,_that.checkinId,_that.checkedInAt,_that.member,_that.membership,_that.todayWorkout);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool duplicate,  String checkinId,  String checkedInAt,  CheckinMember member,  CheckinMembership membership,  Map<String, dynamic>? todayWorkout)  $default,) {final _that = this;
switch (_that) {
case _CheckinResponse():
return $default(_that.duplicate,_that.checkinId,_that.checkedInAt,_that.member,_that.membership,_that.todayWorkout);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool duplicate,  String checkinId,  String checkedInAt,  CheckinMember member,  CheckinMembership membership,  Map<String, dynamic>? todayWorkout)?  $default,) {final _that = this;
switch (_that) {
case _CheckinResponse() when $default != null:
return $default(_that.duplicate,_that.checkinId,_that.checkedInAt,_that.member,_that.membership,_that.todayWorkout);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CheckinResponse implements CheckinResponse {
  const _CheckinResponse({required this.duplicate, required this.checkinId, required this.checkedInAt, required this.member, required this.membership,  Map<String, dynamic>? todayWorkout}): _todayWorkout = todayWorkout;
  factory _CheckinResponse.fromJson(Map<String, dynamic> json) => _$CheckinResponseFromJson(json);

@override final  bool duplicate;
@override final  String checkinId;
@override final  String checkedInAt;
@override final  CheckinMember member;
@override final  CheckinMembership membership;
/// Today's workout for PLUS/PREMIUM (D11/D12); null until then.
 final  Map<String, dynamic>? _todayWorkout;
/// Today's workout for PLUS/PREMIUM (D11/D12); null until then.
@override Map<String, dynamic>? get todayWorkout {
  final value = _todayWorkout;
  if (value == null) return null;
  if (_todayWorkout is EqualUnmodifiableMapView) return _todayWorkout;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}


/// Create a copy of CheckinResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CheckinResponseCopyWith<_CheckinResponse> get copyWith => __$CheckinResponseCopyWithImpl<_CheckinResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CheckinResponseToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CheckinResponse&&(identical(other.duplicate, duplicate) || other.duplicate == duplicate)&&(identical(other.checkinId, checkinId) || other.checkinId == checkinId)&&(identical(other.checkedInAt, checkedInAt) || other.checkedInAt == checkedInAt)&&(identical(other.member, member) || other.member == member)&&(identical(other.membership, membership) || other.membership == membership)&&const DeepCollectionEquality().equals(other.todayWorkout, _todayWorkout));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,duplicate,checkinId,checkedInAt,member,membership,const DeepCollectionEquality().hash(_todayWorkout));
}

@override
String toString() {
    return 'CheckinResponse(duplicate: $duplicate, checkinId: $checkinId, checkedInAt: $checkedInAt, member: $member, membership: $membership, todayWorkout: $todayWorkout)';
}


}

/// @nodoc
abstract mixin class _$CheckinResponseCopyWith<$Res> implements $CheckinResponseCopyWith<$Res> {
  factory _$CheckinResponseCopyWith(_CheckinResponse value, $Res Function(_CheckinResponse) _then) = __$CheckinResponseCopyWithImpl;
@override @useResult
$Res call({
 bool duplicate, String checkinId, String checkedInAt, CheckinMember member, CheckinMembership membership, Map<String, dynamic>? todayWorkout
});


@override $CheckinMemberCopyWith<$Res> get member;@override $CheckinMembershipCopyWith<$Res> get membership;

}
/// @nodoc
class __$CheckinResponseCopyWithImpl<$Res>
    implements _$CheckinResponseCopyWith<$Res> {
  __$CheckinResponseCopyWithImpl(this._self, this._then);

  final _CheckinResponse _self;
  final $Res Function(_CheckinResponse) _then;

/// Create a copy of CheckinResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? duplicate = null,Object? checkinId = null,Object? checkedInAt = null,Object? member = null,Object? membership = null,Object? todayWorkout = freezed,}) {
  return _then(_CheckinResponse(
duplicate: null == duplicate ? _self.duplicate : duplicate // ignore: cast_nullable_to_non_nullable
as bool,checkinId: null == checkinId ? _self.checkinId : checkinId // ignore: cast_nullable_to_non_nullable
as String,checkedInAt: null == checkedInAt ? _self.checkedInAt : checkedInAt // ignore: cast_nullable_to_non_nullable
as String,member: null == member ? _self.member : member // ignore: cast_nullable_to_non_nullable
as CheckinMember,membership: null == membership ? _self.membership : membership // ignore: cast_nullable_to_non_nullable
as CheckinMembership,todayWorkout: freezed == todayWorkout ? _self._todayWorkout : todayWorkout // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,
  ));
}

/// Create a copy of CheckinResponse
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CheckinMemberCopyWith<$Res> get member {
  
  return $CheckinMemberCopyWith<$Res>(_self.member, (value) {
    return _then(_self.copyWith(member: value));
  });
}/// Create a copy of CheckinResponse
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CheckinMembershipCopyWith<$Res> get membership {
  
  return $CheckinMembershipCopyWith<$Res>(_self.membership, (value) {
    return _then(_self.copyWith(membership: value));
  });
}
}


/// @nodoc
mixin _$CheckinMember {

 String get firstName;
/// Create a copy of CheckinMember
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CheckinMemberCopyWith<CheckinMember> get copyWith => _$CheckinMemberCopyWithImpl<CheckinMember>(this as CheckinMember, _$identity);

  /// Serializes this CheckinMember to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as CheckinMember;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CheckinMember&&(identical(other.firstName, _this.firstName) || other.firstName == _this.firstName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as CheckinMember;
  return Object.hash(runtimeType,_this.firstName);
}

@override
String toString() {
  final _this = this as CheckinMember;
  return 'CheckinMember(firstName: ${_this.firstName})';
}


}

/// @nodoc
abstract mixin class $CheckinMemberCopyWith<$Res>  {
  factory $CheckinMemberCopyWith(CheckinMember value, $Res Function(CheckinMember) _then) = _$CheckinMemberCopyWithImpl;
@useResult
$Res call({
 String firstName
});




}
/// @nodoc
class _$CheckinMemberCopyWithImpl<$Res>
    implements $CheckinMemberCopyWith<$Res> {
  _$CheckinMemberCopyWithImpl(this._self, this._then);

  final CheckinMember _self;
  final $Res Function(CheckinMember) _then;

/// Create a copy of CheckinMember
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? firstName = null,}) {
  return _then(CheckinMember(
firstName: null == firstName ? _self.firstName : firstName // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [CheckinMember].
extension CheckinMemberPatterns on CheckinMember {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CheckinMember value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CheckinMember() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CheckinMember value)  $default,){
final _that = this;
switch (_that) {
case _CheckinMember():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CheckinMember value)?  $default,){
final _that = this;
switch (_that) {
case _CheckinMember() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String firstName)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CheckinMember() when $default != null:
return $default(_that.firstName);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String firstName)  $default,) {final _that = this;
switch (_that) {
case _CheckinMember():
return $default(_that.firstName);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String firstName)?  $default,) {final _that = this;
switch (_that) {
case _CheckinMember() when $default != null:
return $default(_that.firstName);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CheckinMember implements CheckinMember {
  const _CheckinMember({required this.firstName});
  factory _CheckinMember.fromJson(Map<String, dynamic> json) => _$CheckinMemberFromJson(json);

@override final  String firstName;

/// Create a copy of CheckinMember
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CheckinMemberCopyWith<_CheckinMember> get copyWith => __$CheckinMemberCopyWithImpl<_CheckinMember>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CheckinMemberToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CheckinMember&&(identical(other.firstName, firstName) || other.firstName == firstName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,firstName);
}

@override
String toString() {
    return 'CheckinMember(firstName: $firstName)';
}


}

/// @nodoc
abstract mixin class _$CheckinMemberCopyWith<$Res> implements $CheckinMemberCopyWith<$Res> {
  factory _$CheckinMemberCopyWith(_CheckinMember value, $Res Function(_CheckinMember) _then) = __$CheckinMemberCopyWithImpl;
@override @useResult
$Res call({
 String firstName
});




}
/// @nodoc
class __$CheckinMemberCopyWithImpl<$Res>
    implements _$CheckinMemberCopyWith<$Res> {
  __$CheckinMemberCopyWithImpl(this._self, this._then);

  final _CheckinMember _self;
  final $Res Function(_CheckinMember) _then;

/// Create a copy of CheckinMember
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? firstName = null,}) {
  return _then(_CheckinMember(
firstName: null == firstName ? _self.firstName : firstName // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$CheckinMembership {

 Tier get tier; String get endDate; int get daysLeft;
/// Create a copy of CheckinMembership
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CheckinMembershipCopyWith<CheckinMembership> get copyWith => _$CheckinMembershipCopyWithImpl<CheckinMembership>(this as CheckinMembership, _$identity);

  /// Serializes this CheckinMembership to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as CheckinMembership;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CheckinMembership&&(identical(other.tier, _this.tier) || other.tier == _this.tier)&&(identical(other.endDate, _this.endDate) || other.endDate == _this.endDate)&&(identical(other.daysLeft, _this.daysLeft) || other.daysLeft == _this.daysLeft));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as CheckinMembership;
  return Object.hash(runtimeType,_this.tier,_this.endDate,_this.daysLeft);
}

@override
String toString() {
  final _this = this as CheckinMembership;
  return 'CheckinMembership(tier: ${_this.tier}, endDate: ${_this.endDate}, daysLeft: ${_this.daysLeft})';
}


}

/// @nodoc
abstract mixin class $CheckinMembershipCopyWith<$Res>  {
  factory $CheckinMembershipCopyWith(CheckinMembership value, $Res Function(CheckinMembership) _then) = _$CheckinMembershipCopyWithImpl;
@useResult
$Res call({
 Tier tier, String endDate, int daysLeft
});




}
/// @nodoc
class _$CheckinMembershipCopyWithImpl<$Res>
    implements $CheckinMembershipCopyWith<$Res> {
  _$CheckinMembershipCopyWithImpl(this._self, this._then);

  final CheckinMembership _self;
  final $Res Function(CheckinMembership) _then;

/// Create a copy of CheckinMembership
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? tier = null,Object? endDate = null,Object? daysLeft = null,}) {
  return _then(CheckinMembership(
tier: null == tier ? _self.tier : tier // ignore: cast_nullable_to_non_nullable
as Tier,endDate: null == endDate ? _self.endDate : endDate // ignore: cast_nullable_to_non_nullable
as String,daysLeft: null == daysLeft ? _self.daysLeft : daysLeft // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [CheckinMembership].
extension CheckinMembershipPatterns on CheckinMembership {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CheckinMembership value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CheckinMembership() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CheckinMembership value)  $default,){
final _that = this;
switch (_that) {
case _CheckinMembership():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CheckinMembership value)?  $default,){
final _that = this;
switch (_that) {
case _CheckinMembership() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Tier tier,  String endDate,  int daysLeft)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CheckinMembership() when $default != null:
return $default(_that.tier,_that.endDate,_that.daysLeft);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Tier tier,  String endDate,  int daysLeft)  $default,) {final _that = this;
switch (_that) {
case _CheckinMembership():
return $default(_that.tier,_that.endDate,_that.daysLeft);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Tier tier,  String endDate,  int daysLeft)?  $default,) {final _that = this;
switch (_that) {
case _CheckinMembership() when $default != null:
return $default(_that.tier,_that.endDate,_that.daysLeft);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CheckinMembership implements CheckinMembership {
  const _CheckinMembership({required this.tier, required this.endDate, required this.daysLeft});
  factory _CheckinMembership.fromJson(Map<String, dynamic> json) => _$CheckinMembershipFromJson(json);

@override final  Tier tier;
@override final  String endDate;
@override final  int daysLeft;

/// Create a copy of CheckinMembership
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CheckinMembershipCopyWith<_CheckinMembership> get copyWith => __$CheckinMembershipCopyWithImpl<_CheckinMembership>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CheckinMembershipToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CheckinMembership&&(identical(other.tier, tier) || other.tier == tier)&&(identical(other.endDate, endDate) || other.endDate == endDate)&&(identical(other.daysLeft, daysLeft) || other.daysLeft == daysLeft));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,tier,endDate,daysLeft);
}

@override
String toString() {
    return 'CheckinMembership(tier: $tier, endDate: $endDate, daysLeft: $daysLeft)';
}


}

/// @nodoc
abstract mixin class _$CheckinMembershipCopyWith<$Res> implements $CheckinMembershipCopyWith<$Res> {
  factory _$CheckinMembershipCopyWith(_CheckinMembership value, $Res Function(_CheckinMembership) _then) = __$CheckinMembershipCopyWithImpl;
@override @useResult
$Res call({
 Tier tier, String endDate, int daysLeft
});




}
/// @nodoc
class __$CheckinMembershipCopyWithImpl<$Res>
    implements _$CheckinMembershipCopyWith<$Res> {
  __$CheckinMembershipCopyWithImpl(this._self, this._then);

  final _CheckinMembership _self;
  final $Res Function(_CheckinMembership) _then;

/// Create a copy of CheckinMembership
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? tier = null,Object? endDate = null,Object? daysLeft = null,}) {
  return _then(_CheckinMembership(
tier: null == tier ? _self.tier : tier // ignore: cast_nullable_to_non_nullable
as Tier,endDate: null == endDate ? _self.endDate : endDate // ignore: cast_nullable_to_non_nullable
as String,daysLeft: null == daysLeft ? _self.daysLeft : daysLeft // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
