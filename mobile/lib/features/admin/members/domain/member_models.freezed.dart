// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'member_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PersonRef {

 String get id; String get firstName; String get lastName;
/// Create a copy of PersonRef
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PersonRefCopyWith<PersonRef> get copyWith => _$PersonRefCopyWithImpl<PersonRef>(this as PersonRef, _$identity);

  /// Serializes this PersonRef to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as PersonRef;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PersonRef&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.firstName, _this.firstName) || other.firstName == _this.firstName)&&(identical(other.lastName, _this.lastName) || other.lastName == _this.lastName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as PersonRef;
  return Object.hash(runtimeType,_this.id,_this.firstName,_this.lastName);
}

@override
String toString() {
  final _this = this as PersonRef;
  return 'PersonRef(id: ${_this.id}, firstName: ${_this.firstName}, lastName: ${_this.lastName})';
}


}

/// @nodoc
abstract mixin class $PersonRefCopyWith<$Res>  {
  factory $PersonRefCopyWith(PersonRef value, $Res Function(PersonRef) _then) = _$PersonRefCopyWithImpl;
@useResult
$Res call({
 String id, String firstName, String lastName
});




}
/// @nodoc
class _$PersonRefCopyWithImpl<$Res>
    implements $PersonRefCopyWith<$Res> {
  _$PersonRefCopyWithImpl(this._self, this._then);

  final PersonRef _self;
  final $Res Function(PersonRef) _then;

/// Create a copy of PersonRef
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? firstName = null,Object? lastName = null,}) {
  return _then(PersonRef(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,firstName: null == firstName ? _self.firstName : firstName // ignore: cast_nullable_to_non_nullable
as String,lastName: null == lastName ? _self.lastName : lastName // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [PersonRef].
extension PersonRefPatterns on PersonRef {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PersonRef value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PersonRef() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PersonRef value)  $default,){
final _that = this;
switch (_that) {
case _PersonRef():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PersonRef value)?  $default,){
final _that = this;
switch (_that) {
case _PersonRef() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String firstName,  String lastName)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PersonRef() when $default != null:
return $default(_that.id,_that.firstName,_that.lastName);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String firstName,  String lastName)  $default,) {final _that = this;
switch (_that) {
case _PersonRef():
return $default(_that.id,_that.firstName,_that.lastName);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String firstName,  String lastName)?  $default,) {final _that = this;
switch (_that) {
case _PersonRef() when $default != null:
return $default(_that.id,_that.firstName,_that.lastName);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PersonRef extends PersonRef {
  const _PersonRef({required this.id, required this.firstName, required this.lastName}): super._();
  factory _PersonRef.fromJson(Map<String, dynamic> json) => _$PersonRefFromJson(json);

@override final  String id;
@override final  String firstName;
@override final  String lastName;

/// Create a copy of PersonRef
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PersonRefCopyWith<_PersonRef> get copyWith => __$PersonRefCopyWithImpl<_PersonRef>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PersonRefToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _PersonRef&&(identical(other.id, id) || other.id == id)&&(identical(other.firstName, firstName) || other.firstName == firstName)&&(identical(other.lastName, lastName) || other.lastName == lastName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,firstName,lastName);
}

@override
String toString() {
    return 'PersonRef(id: $id, firstName: $firstName, lastName: $lastName)';
}


}

/// @nodoc
abstract mixin class _$PersonRefCopyWith<$Res> implements $PersonRefCopyWith<$Res> {
  factory _$PersonRefCopyWith(_PersonRef value, $Res Function(_PersonRef) _then) = __$PersonRefCopyWithImpl;
@override @useResult
$Res call({
 String id, String firstName, String lastName
});




}
/// @nodoc
class __$PersonRefCopyWithImpl<$Res>
    implements _$PersonRefCopyWith<$Res> {
  __$PersonRefCopyWithImpl(this._self, this._then);

  final _PersonRef _self;
  final $Res Function(_PersonRef) _then;

/// Create a copy of PersonRef
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? firstName = null,Object? lastName = null,}) {
  return _then(_PersonRef(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,firstName: null == firstName ? _self.firstName : firstName // ignore: cast_nullable_to_non_nullable
as String,lastName: null == lastName ? _self.lastName : lastName // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$MemberListItem {

 String get id; String get firstName; String get lastName; String get phone; bool get isActive; Tier get tier; String get endDate; int get daysLeft; MemberStatus get status; String? get trainerId; String? get lastCheckinAt;
/// Create a copy of MemberListItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MemberListItemCopyWith<MemberListItem> get copyWith => _$MemberListItemCopyWithImpl<MemberListItem>(this as MemberListItem, _$identity);

  /// Serializes this MemberListItem to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as MemberListItem;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MemberListItem&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.firstName, _this.firstName) || other.firstName == _this.firstName)&&(identical(other.lastName, _this.lastName) || other.lastName == _this.lastName)&&(identical(other.phone, _this.phone) || other.phone == _this.phone)&&(identical(other.isActive, _this.isActive) || other.isActive == _this.isActive)&&(identical(other.tier, _this.tier) || other.tier == _this.tier)&&(identical(other.endDate, _this.endDate) || other.endDate == _this.endDate)&&(identical(other.daysLeft, _this.daysLeft) || other.daysLeft == _this.daysLeft)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.trainerId, _this.trainerId) || other.trainerId == _this.trainerId)&&(identical(other.lastCheckinAt, _this.lastCheckinAt) || other.lastCheckinAt == _this.lastCheckinAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as MemberListItem;
  return Object.hash(runtimeType,_this.id,_this.firstName,_this.lastName,_this.phone,_this.isActive,_this.tier,_this.endDate,_this.daysLeft,_this.status,_this.trainerId,_this.lastCheckinAt);
}

@override
String toString() {
  final _this = this as MemberListItem;
  return 'MemberListItem(id: ${_this.id}, firstName: ${_this.firstName}, lastName: ${_this.lastName}, phone: ${_this.phone}, isActive: ${_this.isActive}, tier: ${_this.tier}, endDate: ${_this.endDate}, daysLeft: ${_this.daysLeft}, status: ${_this.status}, trainerId: ${_this.trainerId}, lastCheckinAt: ${_this.lastCheckinAt})';
}


}

/// @nodoc
abstract mixin class $MemberListItemCopyWith<$Res>  {
  factory $MemberListItemCopyWith(MemberListItem value, $Res Function(MemberListItem) _then) = _$MemberListItemCopyWithImpl;
@useResult
$Res call({
 String id, String firstName, String lastName, String phone, bool isActive, Tier tier, String endDate, int daysLeft, MemberStatus status, String? trainerId, String? lastCheckinAt
});




}
/// @nodoc
class _$MemberListItemCopyWithImpl<$Res>
    implements $MemberListItemCopyWith<$Res> {
  _$MemberListItemCopyWithImpl(this._self, this._then);

  final MemberListItem _self;
  final $Res Function(MemberListItem) _then;

/// Create a copy of MemberListItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? firstName = null,Object? lastName = null,Object? phone = null,Object? isActive = null,Object? tier = null,Object? endDate = null,Object? daysLeft = null,Object? status = null,Object? trainerId = freezed,Object? lastCheckinAt = freezed,}) {
  return _then(MemberListItem(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,firstName: null == firstName ? _self.firstName : firstName // ignore: cast_nullable_to_non_nullable
as String,lastName: null == lastName ? _self.lastName : lastName // ignore: cast_nullable_to_non_nullable
as String,phone: null == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,tier: null == tier ? _self.tier : tier // ignore: cast_nullable_to_non_nullable
as Tier,endDate: null == endDate ? _self.endDate : endDate // ignore: cast_nullable_to_non_nullable
as String,daysLeft: null == daysLeft ? _self.daysLeft : daysLeft // ignore: cast_nullable_to_non_nullable
as int,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as MemberStatus,trainerId: freezed == trainerId ? _self.trainerId : trainerId // ignore: cast_nullable_to_non_nullable
as String?,lastCheckinAt: freezed == lastCheckinAt ? _self.lastCheckinAt : lastCheckinAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [MemberListItem].
extension MemberListItemPatterns on MemberListItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MemberListItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MemberListItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MemberListItem value)  $default,){
final _that = this;
switch (_that) {
case _MemberListItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MemberListItem value)?  $default,){
final _that = this;
switch (_that) {
case _MemberListItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String firstName,  String lastName,  String phone,  bool isActive,  Tier tier,  String endDate,  int daysLeft,  MemberStatus status,  String? trainerId,  String? lastCheckinAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MemberListItem() when $default != null:
return $default(_that.id,_that.firstName,_that.lastName,_that.phone,_that.isActive,_that.tier,_that.endDate,_that.daysLeft,_that.status,_that.trainerId,_that.lastCheckinAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String firstName,  String lastName,  String phone,  bool isActive,  Tier tier,  String endDate,  int daysLeft,  MemberStatus status,  String? trainerId,  String? lastCheckinAt)  $default,) {final _that = this;
switch (_that) {
case _MemberListItem():
return $default(_that.id,_that.firstName,_that.lastName,_that.phone,_that.isActive,_that.tier,_that.endDate,_that.daysLeft,_that.status,_that.trainerId,_that.lastCheckinAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String firstName,  String lastName,  String phone,  bool isActive,  Tier tier,  String endDate,  int daysLeft,  MemberStatus status,  String? trainerId,  String? lastCheckinAt)?  $default,) {final _that = this;
switch (_that) {
case _MemberListItem() when $default != null:
return $default(_that.id,_that.firstName,_that.lastName,_that.phone,_that.isActive,_that.tier,_that.endDate,_that.daysLeft,_that.status,_that.trainerId,_that.lastCheckinAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MemberListItem extends MemberListItem {
  const _MemberListItem({required this.id, required this.firstName, required this.lastName, required this.phone, required this.isActive, required this.tier, required this.endDate, required this.daysLeft, required this.status, this.trainerId, this.lastCheckinAt}): super._();
  factory _MemberListItem.fromJson(Map<String, dynamic> json) => _$MemberListItemFromJson(json);

@override final  String id;
@override final  String firstName;
@override final  String lastName;
@override final  String phone;
@override final  bool isActive;
@override final  Tier tier;
@override final  String endDate;
@override final  int daysLeft;
@override final  MemberStatus status;
@override final  String? trainerId;
@override final  String? lastCheckinAt;

/// Create a copy of MemberListItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MemberListItemCopyWith<_MemberListItem> get copyWith => __$MemberListItemCopyWithImpl<_MemberListItem>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MemberListItemToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _MemberListItem&&(identical(other.id, id) || other.id == id)&&(identical(other.firstName, firstName) || other.firstName == firstName)&&(identical(other.lastName, lastName) || other.lastName == lastName)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.tier, tier) || other.tier == tier)&&(identical(other.endDate, endDate) || other.endDate == endDate)&&(identical(other.daysLeft, daysLeft) || other.daysLeft == daysLeft)&&(identical(other.status, status) || other.status == status)&&(identical(other.trainerId, trainerId) || other.trainerId == trainerId)&&(identical(other.lastCheckinAt, lastCheckinAt) || other.lastCheckinAt == lastCheckinAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,firstName,lastName,phone,isActive,tier,endDate,daysLeft,status,trainerId,lastCheckinAt);
}

@override
String toString() {
    return 'MemberListItem(id: $id, firstName: $firstName, lastName: $lastName, phone: $phone, isActive: $isActive, tier: $tier, endDate: $endDate, daysLeft: $daysLeft, status: $status, trainerId: $trainerId, lastCheckinAt: $lastCheckinAt)';
}


}

/// @nodoc
abstract mixin class _$MemberListItemCopyWith<$Res> implements $MemberListItemCopyWith<$Res> {
  factory _$MemberListItemCopyWith(_MemberListItem value, $Res Function(_MemberListItem) _then) = __$MemberListItemCopyWithImpl;
@override @useResult
$Res call({
 String id, String firstName, String lastName, String phone, bool isActive, Tier tier, String endDate, int daysLeft, MemberStatus status, String? trainerId, String? lastCheckinAt
});




}
/// @nodoc
class __$MemberListItemCopyWithImpl<$Res>
    implements _$MemberListItemCopyWith<$Res> {
  __$MemberListItemCopyWithImpl(this._self, this._then);

  final _MemberListItem _self;
  final $Res Function(_MemberListItem) _then;

/// Create a copy of MemberListItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? firstName = null,Object? lastName = null,Object? phone = null,Object? isActive = null,Object? tier = null,Object? endDate = null,Object? daysLeft = null,Object? status = null,Object? trainerId = freezed,Object? lastCheckinAt = freezed,}) {
  return _then(_MemberListItem(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,firstName: null == firstName ? _self.firstName : firstName // ignore: cast_nullable_to_non_nullable
as String,lastName: null == lastName ? _self.lastName : lastName // ignore: cast_nullable_to_non_nullable
as String,phone: null == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,tier: null == tier ? _self.tier : tier // ignore: cast_nullable_to_non_nullable
as Tier,endDate: null == endDate ? _self.endDate : endDate // ignore: cast_nullable_to_non_nullable
as String,daysLeft: null == daysLeft ? _self.daysLeft : daysLeft // ignore: cast_nullable_to_non_nullable
as int,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as MemberStatus,trainerId: freezed == trainerId ? _self.trainerId : trainerId // ignore: cast_nullable_to_non_nullable
as String?,lastCheckinAt: freezed == lastCheckinAt ? _self.lastCheckinAt : lastCheckinAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$Payment {

 String get id; String get memberId; PaymentKind get kind; Tier get tier; int get months; String? get periodStart; String? get periodEnd; String get amount; String get suggestedAmount; String get currency; PaymentMethod get method; String? get note; PersonRef get recordedBy; String get paidAt; String? get voidedAt; String? get voidReason;
/// Create a copy of Payment
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PaymentCopyWith<Payment> get copyWith => _$PaymentCopyWithImpl<Payment>(this as Payment, _$identity);

  /// Serializes this Payment to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Payment;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Payment&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.memberId, _this.memberId) || other.memberId == _this.memberId)&&(identical(other.kind, _this.kind) || other.kind == _this.kind)&&(identical(other.tier, _this.tier) || other.tier == _this.tier)&&(identical(other.months, _this.months) || other.months == _this.months)&&(identical(other.periodStart, _this.periodStart) || other.periodStart == _this.periodStart)&&(identical(other.periodEnd, _this.periodEnd) || other.periodEnd == _this.periodEnd)&&(identical(other.amount, _this.amount) || other.amount == _this.amount)&&(identical(other.suggestedAmount, _this.suggestedAmount) || other.suggestedAmount == _this.suggestedAmount)&&(identical(other.currency, _this.currency) || other.currency == _this.currency)&&(identical(other.method, _this.method) || other.method == _this.method)&&(identical(other.note, _this.note) || other.note == _this.note)&&(identical(other.recordedBy, _this.recordedBy) || other.recordedBy == _this.recordedBy)&&(identical(other.paidAt, _this.paidAt) || other.paidAt == _this.paidAt)&&(identical(other.voidedAt, _this.voidedAt) || other.voidedAt == _this.voidedAt)&&(identical(other.voidReason, _this.voidReason) || other.voidReason == _this.voidReason));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Payment;
  return Object.hash(runtimeType,_this.id,_this.memberId,_this.kind,_this.tier,_this.months,_this.periodStart,_this.periodEnd,_this.amount,_this.suggestedAmount,_this.currency,_this.method,_this.note,_this.recordedBy,_this.paidAt,_this.voidedAt,_this.voidReason);
}

@override
String toString() {
  final _this = this as Payment;
  return 'Payment(id: ${_this.id}, memberId: ${_this.memberId}, kind: ${_this.kind}, tier: ${_this.tier}, months: ${_this.months}, periodStart: ${_this.periodStart}, periodEnd: ${_this.periodEnd}, amount: ${_this.amount}, suggestedAmount: ${_this.suggestedAmount}, currency: ${_this.currency}, method: ${_this.method}, note: ${_this.note}, recordedBy: ${_this.recordedBy}, paidAt: ${_this.paidAt}, voidedAt: ${_this.voidedAt}, voidReason: ${_this.voidReason})';
}


}

/// @nodoc
abstract mixin class $PaymentCopyWith<$Res>  {
  factory $PaymentCopyWith(Payment value, $Res Function(Payment) _then) = _$PaymentCopyWithImpl;
@useResult
$Res call({
 String id, String memberId, PaymentKind kind, Tier tier, int months, String? periodStart, String? periodEnd, String amount, String suggestedAmount, String currency, PaymentMethod method, String? note, PersonRef recordedBy, String paidAt, String? voidedAt, String? voidReason
});


$PersonRefCopyWith<$Res> get recordedBy;

}
/// @nodoc
class _$PaymentCopyWithImpl<$Res>
    implements $PaymentCopyWith<$Res> {
  _$PaymentCopyWithImpl(this._self, this._then);

  final Payment _self;
  final $Res Function(Payment) _then;

/// Create a copy of Payment
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? memberId = null,Object? kind = null,Object? tier = null,Object? months = null,Object? periodStart = freezed,Object? periodEnd = freezed,Object? amount = null,Object? suggestedAmount = null,Object? currency = null,Object? method = null,Object? note = freezed,Object? recordedBy = null,Object? paidAt = null,Object? voidedAt = freezed,Object? voidReason = freezed,}) {
  return _then(Payment(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,memberId: null == memberId ? _self.memberId : memberId // ignore: cast_nullable_to_non_nullable
as String,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as PaymentKind,tier: null == tier ? _self.tier : tier // ignore: cast_nullable_to_non_nullable
as Tier,months: null == months ? _self.months : months // ignore: cast_nullable_to_non_nullable
as int,periodStart: freezed == periodStart ? _self.periodStart : periodStart // ignore: cast_nullable_to_non_nullable
as String?,periodEnd: freezed == periodEnd ? _self.periodEnd : periodEnd // ignore: cast_nullable_to_non_nullable
as String?,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as String,suggestedAmount: null == suggestedAmount ? _self.suggestedAmount : suggestedAmount // ignore: cast_nullable_to_non_nullable
as String,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,method: null == method ? _self.method : method // ignore: cast_nullable_to_non_nullable
as PaymentMethod,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,recordedBy: null == recordedBy ? _self.recordedBy : recordedBy // ignore: cast_nullable_to_non_nullable
as PersonRef,paidAt: null == paidAt ? _self.paidAt : paidAt // ignore: cast_nullable_to_non_nullable
as String,voidedAt: freezed == voidedAt ? _self.voidedAt : voidedAt // ignore: cast_nullable_to_non_nullable
as String?,voidReason: freezed == voidReason ? _self.voidReason : voidReason // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of Payment
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PersonRefCopyWith<$Res> get recordedBy {
  
  return $PersonRefCopyWith<$Res>(_self.recordedBy, (value) {
    return _then(_self.copyWith(recordedBy: value));
  });
}
}


/// Adds pattern-matching-related methods to [Payment].
extension PaymentPatterns on Payment {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Payment value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Payment() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Payment value)  $default,){
final _that = this;
switch (_that) {
case _Payment():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Payment value)?  $default,){
final _that = this;
switch (_that) {
case _Payment() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String memberId,  PaymentKind kind,  Tier tier,  int months,  String? periodStart,  String? periodEnd,  String amount,  String suggestedAmount,  String currency,  PaymentMethod method,  String? note,  PersonRef recordedBy,  String paidAt,  String? voidedAt,  String? voidReason)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Payment() when $default != null:
return $default(_that.id,_that.memberId,_that.kind,_that.tier,_that.months,_that.periodStart,_that.periodEnd,_that.amount,_that.suggestedAmount,_that.currency,_that.method,_that.note,_that.recordedBy,_that.paidAt,_that.voidedAt,_that.voidReason);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String memberId,  PaymentKind kind,  Tier tier,  int months,  String? periodStart,  String? periodEnd,  String amount,  String suggestedAmount,  String currency,  PaymentMethod method,  String? note,  PersonRef recordedBy,  String paidAt,  String? voidedAt,  String? voidReason)  $default,) {final _that = this;
switch (_that) {
case _Payment():
return $default(_that.id,_that.memberId,_that.kind,_that.tier,_that.months,_that.periodStart,_that.periodEnd,_that.amount,_that.suggestedAmount,_that.currency,_that.method,_that.note,_that.recordedBy,_that.paidAt,_that.voidedAt,_that.voidReason);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String memberId,  PaymentKind kind,  Tier tier,  int months,  String? periodStart,  String? periodEnd,  String amount,  String suggestedAmount,  String currency,  PaymentMethod method,  String? note,  PersonRef recordedBy,  String paidAt,  String? voidedAt,  String? voidReason)?  $default,) {final _that = this;
switch (_that) {
case _Payment() when $default != null:
return $default(_that.id,_that.memberId,_that.kind,_that.tier,_that.months,_that.periodStart,_that.periodEnd,_that.amount,_that.suggestedAmount,_that.currency,_that.method,_that.note,_that.recordedBy,_that.paidAt,_that.voidedAt,_that.voidReason);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Payment extends Payment {
  const _Payment({required this.id, required this.memberId, required this.kind, required this.tier, required this.months, this.periodStart, this.periodEnd, required this.amount, required this.suggestedAmount, required this.currency, required this.method, this.note, required this.recordedBy, required this.paidAt, this.voidedAt, this.voidReason}): super._();
  factory _Payment.fromJson(Map<String, dynamic> json) => _$PaymentFromJson(json);

@override final  String id;
@override final  String memberId;
@override final  PaymentKind kind;
@override final  Tier tier;
@override final  int months;
@override final  String? periodStart;
@override final  String? periodEnd;
@override final  String amount;
@override final  String suggestedAmount;
@override final  String currency;
@override final  PaymentMethod method;
@override final  String? note;
@override final  PersonRef recordedBy;
@override final  String paidAt;
@override final  String? voidedAt;
@override final  String? voidReason;

/// Create a copy of Payment
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PaymentCopyWith<_Payment> get copyWith => __$PaymentCopyWithImpl<_Payment>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PaymentToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Payment&&(identical(other.id, id) || other.id == id)&&(identical(other.memberId, memberId) || other.memberId == memberId)&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.tier, tier) || other.tier == tier)&&(identical(other.months, months) || other.months == months)&&(identical(other.periodStart, periodStart) || other.periodStart == periodStart)&&(identical(other.periodEnd, periodEnd) || other.periodEnd == periodEnd)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.suggestedAmount, suggestedAmount) || other.suggestedAmount == suggestedAmount)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.method, method) || other.method == method)&&(identical(other.note, note) || other.note == note)&&(identical(other.recordedBy, recordedBy) || other.recordedBy == recordedBy)&&(identical(other.paidAt, paidAt) || other.paidAt == paidAt)&&(identical(other.voidedAt, voidedAt) || other.voidedAt == voidedAt)&&(identical(other.voidReason, voidReason) || other.voidReason == voidReason));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,memberId,kind,tier,months,periodStart,periodEnd,amount,suggestedAmount,currency,method,note,recordedBy,paidAt,voidedAt,voidReason);
}

@override
String toString() {
    return 'Payment(id: $id, memberId: $memberId, kind: $kind, tier: $tier, months: $months, periodStart: $periodStart, periodEnd: $periodEnd, amount: $amount, suggestedAmount: $suggestedAmount, currency: $currency, method: $method, note: $note, recordedBy: $recordedBy, paidAt: $paidAt, voidedAt: $voidedAt, voidReason: $voidReason)';
}


}

/// @nodoc
abstract mixin class _$PaymentCopyWith<$Res> implements $PaymentCopyWith<$Res> {
  factory _$PaymentCopyWith(_Payment value, $Res Function(_Payment) _then) = __$PaymentCopyWithImpl;
@override @useResult
$Res call({
 String id, String memberId, PaymentKind kind, Tier tier, int months, String? periodStart, String? periodEnd, String amount, String suggestedAmount, String currency, PaymentMethod method, String? note, PersonRef recordedBy, String paidAt, String? voidedAt, String? voidReason
});


@override $PersonRefCopyWith<$Res> get recordedBy;

}
/// @nodoc
class __$PaymentCopyWithImpl<$Res>
    implements _$PaymentCopyWith<$Res> {
  __$PaymentCopyWithImpl(this._self, this._then);

  final _Payment _self;
  final $Res Function(_Payment) _then;

/// Create a copy of Payment
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? memberId = null,Object? kind = null,Object? tier = null,Object? months = null,Object? periodStart = freezed,Object? periodEnd = freezed,Object? amount = null,Object? suggestedAmount = null,Object? currency = null,Object? method = null,Object? note = freezed,Object? recordedBy = null,Object? paidAt = null,Object? voidedAt = freezed,Object? voidReason = freezed,}) {
  return _then(_Payment(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,memberId: null == memberId ? _self.memberId : memberId // ignore: cast_nullable_to_non_nullable
as String,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as PaymentKind,tier: null == tier ? _self.tier : tier // ignore: cast_nullable_to_non_nullable
as Tier,months: null == months ? _self.months : months // ignore: cast_nullable_to_non_nullable
as int,periodStart: freezed == periodStart ? _self.periodStart : periodStart // ignore: cast_nullable_to_non_nullable
as String?,periodEnd: freezed == periodEnd ? _self.periodEnd : periodEnd // ignore: cast_nullable_to_non_nullable
as String?,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as String,suggestedAmount: null == suggestedAmount ? _self.suggestedAmount : suggestedAmount // ignore: cast_nullable_to_non_nullable
as String,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,method: null == method ? _self.method : method // ignore: cast_nullable_to_non_nullable
as PaymentMethod,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,recordedBy: null == recordedBy ? _self.recordedBy : recordedBy // ignore: cast_nullable_to_non_nullable
as PersonRef,paidAt: null == paidAt ? _self.paidAt : paidAt // ignore: cast_nullable_to_non_nullable
as String,voidedAt: freezed == voidedAt ? _self.voidedAt : voidedAt // ignore: cast_nullable_to_non_nullable
as String?,voidReason: freezed == voidReason ? _self.voidReason : voidReason // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of Payment
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PersonRefCopyWith<$Res> get recordedBy {
  
  return $PersonRefCopyWith<$Res>(_self.recordedBy, (value) {
    return _then(_self.copyWith(recordedBy: value));
  });
}
}


/// @nodoc
mixin _$CheckinRef {

 String get id; String get createdAt; Tier get tier; int get daysLeft;
/// Create a copy of CheckinRef
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CheckinRefCopyWith<CheckinRef> get copyWith => _$CheckinRefCopyWithImpl<CheckinRef>(this as CheckinRef, _$identity);

  /// Serializes this CheckinRef to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as CheckinRef;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CheckinRef&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt)&&(identical(other.tier, _this.tier) || other.tier == _this.tier)&&(identical(other.daysLeft, _this.daysLeft) || other.daysLeft == _this.daysLeft));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as CheckinRef;
  return Object.hash(runtimeType,_this.id,_this.createdAt,_this.tier,_this.daysLeft);
}

@override
String toString() {
  final _this = this as CheckinRef;
  return 'CheckinRef(id: ${_this.id}, createdAt: ${_this.createdAt}, tier: ${_this.tier}, daysLeft: ${_this.daysLeft})';
}


}

/// @nodoc
abstract mixin class $CheckinRefCopyWith<$Res>  {
  factory $CheckinRefCopyWith(CheckinRef value, $Res Function(CheckinRef) _then) = _$CheckinRefCopyWithImpl;
@useResult
$Res call({
 String id, String createdAt, Tier tier, int daysLeft
});




}
/// @nodoc
class _$CheckinRefCopyWithImpl<$Res>
    implements $CheckinRefCopyWith<$Res> {
  _$CheckinRefCopyWithImpl(this._self, this._then);

  final CheckinRef _self;
  final $Res Function(CheckinRef) _then;

/// Create a copy of CheckinRef
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? createdAt = null,Object? tier = null,Object? daysLeft = null,}) {
  return _then(CheckinRef(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,tier: null == tier ? _self.tier : tier // ignore: cast_nullable_to_non_nullable
as Tier,daysLeft: null == daysLeft ? _self.daysLeft : daysLeft // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [CheckinRef].
extension CheckinRefPatterns on CheckinRef {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CheckinRef value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CheckinRef() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CheckinRef value)  $default,){
final _that = this;
switch (_that) {
case _CheckinRef():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CheckinRef value)?  $default,){
final _that = this;
switch (_that) {
case _CheckinRef() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String createdAt,  Tier tier,  int daysLeft)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CheckinRef() when $default != null:
return $default(_that.id,_that.createdAt,_that.tier,_that.daysLeft);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String createdAt,  Tier tier,  int daysLeft)  $default,) {final _that = this;
switch (_that) {
case _CheckinRef():
return $default(_that.id,_that.createdAt,_that.tier,_that.daysLeft);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String createdAt,  Tier tier,  int daysLeft)?  $default,) {final _that = this;
switch (_that) {
case _CheckinRef() when $default != null:
return $default(_that.id,_that.createdAt,_that.tier,_that.daysLeft);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CheckinRef implements CheckinRef {
  const _CheckinRef({required this.id, required this.createdAt, required this.tier, required this.daysLeft});
  factory _CheckinRef.fromJson(Map<String, dynamic> json) => _$CheckinRefFromJson(json);

@override final  String id;
@override final  String createdAt;
@override final  Tier tier;
@override final  int daysLeft;

/// Create a copy of CheckinRef
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CheckinRefCopyWith<_CheckinRef> get copyWith => __$CheckinRefCopyWithImpl<_CheckinRef>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CheckinRefToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CheckinRef&&(identical(other.id, id) || other.id == id)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.tier, tier) || other.tier == tier)&&(identical(other.daysLeft, daysLeft) || other.daysLeft == daysLeft));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,createdAt,tier,daysLeft);
}

@override
String toString() {
    return 'CheckinRef(id: $id, createdAt: $createdAt, tier: $tier, daysLeft: $daysLeft)';
}


}

/// @nodoc
abstract mixin class _$CheckinRefCopyWith<$Res> implements $CheckinRefCopyWith<$Res> {
  factory _$CheckinRefCopyWith(_CheckinRef value, $Res Function(_CheckinRef) _then) = __$CheckinRefCopyWithImpl;
@override @useResult
$Res call({
 String id, String createdAt, Tier tier, int daysLeft
});




}
/// @nodoc
class __$CheckinRefCopyWithImpl<$Res>
    implements _$CheckinRefCopyWith<$Res> {
  __$CheckinRefCopyWithImpl(this._self, this._then);

  final _CheckinRef _self;
  final $Res Function(_CheckinRef) _then;

/// Create a copy of CheckinRef
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? createdAt = null,Object? tier = null,Object? daysLeft = null,}) {
  return _then(_CheckinRef(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,tier: null == tier ? _self.tier : tier // ignore: cast_nullable_to_non_nullable
as Tier,daysLeft: null == daysLeft ? _self.daysLeft : daysLeft // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$MemberDetail {

 String get id; String get firstName; String get lastName; String get phone; String? get email; String? get birthDate; String? get gender; String? get emergencyContact; String? get medicalNotes; bool get isActive; bool get mustChangePassword; String get createdAt; MembershipSummary get membership; PersonRef? get trainer; List<CheckinRef> get recentCheckins; List<Payment> get payments;
/// Create a copy of MemberDetail
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MemberDetailCopyWith<MemberDetail> get copyWith => _$MemberDetailCopyWithImpl<MemberDetail>(this as MemberDetail, _$identity);

  /// Serializes this MemberDetail to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as MemberDetail;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MemberDetail&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.firstName, _this.firstName) || other.firstName == _this.firstName)&&(identical(other.lastName, _this.lastName) || other.lastName == _this.lastName)&&(identical(other.phone, _this.phone) || other.phone == _this.phone)&&(identical(other.email, _this.email) || other.email == _this.email)&&(identical(other.birthDate, _this.birthDate) || other.birthDate == _this.birthDate)&&(identical(other.gender, _this.gender) || other.gender == _this.gender)&&(identical(other.emergencyContact, _this.emergencyContact) || other.emergencyContact == _this.emergencyContact)&&(identical(other.medicalNotes, _this.medicalNotes) || other.medicalNotes == _this.medicalNotes)&&(identical(other.isActive, _this.isActive) || other.isActive == _this.isActive)&&(identical(other.mustChangePassword, _this.mustChangePassword) || other.mustChangePassword == _this.mustChangePassword)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt)&&(identical(other.membership, _this.membership) || other.membership == _this.membership)&&(identical(other.trainer, _this.trainer) || other.trainer == _this.trainer)&&const DeepCollectionEquality().equals(other.recentCheckins, _this.recentCheckins)&&const DeepCollectionEquality().equals(other.payments, _this.payments));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as MemberDetail;
  return Object.hash(runtimeType,_this.id,_this.firstName,_this.lastName,_this.phone,_this.email,_this.birthDate,_this.gender,_this.emergencyContact,_this.medicalNotes,_this.isActive,_this.mustChangePassword,_this.createdAt,_this.membership,_this.trainer,const DeepCollectionEquality().hash(_this.recentCheckins),const DeepCollectionEquality().hash(_this.payments));
}

@override
String toString() {
  final _this = this as MemberDetail;
  return 'MemberDetail(id: ${_this.id}, firstName: ${_this.firstName}, lastName: ${_this.lastName}, phone: ${_this.phone}, email: ${_this.email}, birthDate: ${_this.birthDate}, gender: ${_this.gender}, emergencyContact: ${_this.emergencyContact}, medicalNotes: ${_this.medicalNotes}, isActive: ${_this.isActive}, mustChangePassword: ${_this.mustChangePassword}, createdAt: ${_this.createdAt}, membership: ${_this.membership}, trainer: ${_this.trainer}, recentCheckins: ${_this.recentCheckins}, payments: ${_this.payments})';
}


}

/// @nodoc
abstract mixin class $MemberDetailCopyWith<$Res>  {
  factory $MemberDetailCopyWith(MemberDetail value, $Res Function(MemberDetail) _then) = _$MemberDetailCopyWithImpl;
@useResult
$Res call({
 String id, String firstName, String lastName, String phone, String? email, String? birthDate, String? gender, String? emergencyContact, String? medicalNotes, bool isActive, bool mustChangePassword, String createdAt, MembershipSummary membership, PersonRef? trainer, List<CheckinRef> recentCheckins, List<Payment> payments
});


$MembershipSummaryCopyWith<$Res> get membership;$PersonRefCopyWith<$Res>? get trainer;

}
/// @nodoc
class _$MemberDetailCopyWithImpl<$Res>
    implements $MemberDetailCopyWith<$Res> {
  _$MemberDetailCopyWithImpl(this._self, this._then);

  final MemberDetail _self;
  final $Res Function(MemberDetail) _then;

/// Create a copy of MemberDetail
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? firstName = null,Object? lastName = null,Object? phone = null,Object? email = freezed,Object? birthDate = freezed,Object? gender = freezed,Object? emergencyContact = freezed,Object? medicalNotes = freezed,Object? isActive = null,Object? mustChangePassword = null,Object? createdAt = null,Object? membership = null,Object? trainer = freezed,Object? recentCheckins = null,Object? payments = null,}) {
  return _then(MemberDetail(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,firstName: null == firstName ? _self.firstName : firstName // ignore: cast_nullable_to_non_nullable
as String,lastName: null == lastName ? _self.lastName : lastName // ignore: cast_nullable_to_non_nullable
as String,phone: null == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,birthDate: freezed == birthDate ? _self.birthDate : birthDate // ignore: cast_nullable_to_non_nullable
as String?,gender: freezed == gender ? _self.gender : gender // ignore: cast_nullable_to_non_nullable
as String?,emergencyContact: freezed == emergencyContact ? _self.emergencyContact : emergencyContact // ignore: cast_nullable_to_non_nullable
as String?,medicalNotes: freezed == medicalNotes ? _self.medicalNotes : medicalNotes // ignore: cast_nullable_to_non_nullable
as String?,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,mustChangePassword: null == mustChangePassword ? _self.mustChangePassword : mustChangePassword // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,membership: null == membership ? _self.membership : membership // ignore: cast_nullable_to_non_nullable
as MembershipSummary,trainer: freezed == trainer ? _self.trainer : trainer // ignore: cast_nullable_to_non_nullable
as PersonRef?,recentCheckins: null == recentCheckins ? _self.recentCheckins : recentCheckins // ignore: cast_nullable_to_non_nullable
as List<CheckinRef>,payments: null == payments ? _self.payments : payments // ignore: cast_nullable_to_non_nullable
as List<Payment>,
  ));
}
/// Create a copy of MemberDetail
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MembershipSummaryCopyWith<$Res> get membership {
  
  return $MembershipSummaryCopyWith<$Res>(_self.membership, (value) {
    return _then(_self.copyWith(membership: value));
  });
}/// Create a copy of MemberDetail
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PersonRefCopyWith<$Res>? get trainer {
    if (_self.trainer == null) {
    return null;
  }

  return $PersonRefCopyWith<$Res>(_self.trainer!, (value) {
    return _then(_self.copyWith(trainer: value));
  });
}
}


/// Adds pattern-matching-related methods to [MemberDetail].
extension MemberDetailPatterns on MemberDetail {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MemberDetail value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MemberDetail() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MemberDetail value)  $default,){
final _that = this;
switch (_that) {
case _MemberDetail():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MemberDetail value)?  $default,){
final _that = this;
switch (_that) {
case _MemberDetail() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String firstName,  String lastName,  String phone,  String? email,  String? birthDate,  String? gender,  String? emergencyContact,  String? medicalNotes,  bool isActive,  bool mustChangePassword,  String createdAt,  MembershipSummary membership,  PersonRef? trainer,  List<CheckinRef> recentCheckins,  List<Payment> payments)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MemberDetail() when $default != null:
return $default(_that.id,_that.firstName,_that.lastName,_that.phone,_that.email,_that.birthDate,_that.gender,_that.emergencyContact,_that.medicalNotes,_that.isActive,_that.mustChangePassword,_that.createdAt,_that.membership,_that.trainer,_that.recentCheckins,_that.payments);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String firstName,  String lastName,  String phone,  String? email,  String? birthDate,  String? gender,  String? emergencyContact,  String? medicalNotes,  bool isActive,  bool mustChangePassword,  String createdAt,  MembershipSummary membership,  PersonRef? trainer,  List<CheckinRef> recentCheckins,  List<Payment> payments)  $default,) {final _that = this;
switch (_that) {
case _MemberDetail():
return $default(_that.id,_that.firstName,_that.lastName,_that.phone,_that.email,_that.birthDate,_that.gender,_that.emergencyContact,_that.medicalNotes,_that.isActive,_that.mustChangePassword,_that.createdAt,_that.membership,_that.trainer,_that.recentCheckins,_that.payments);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String firstName,  String lastName,  String phone,  String? email,  String? birthDate,  String? gender,  String? emergencyContact,  String? medicalNotes,  bool isActive,  bool mustChangePassword,  String createdAt,  MembershipSummary membership,  PersonRef? trainer,  List<CheckinRef> recentCheckins,  List<Payment> payments)?  $default,) {final _that = this;
switch (_that) {
case _MemberDetail() when $default != null:
return $default(_that.id,_that.firstName,_that.lastName,_that.phone,_that.email,_that.birthDate,_that.gender,_that.emergencyContact,_that.medicalNotes,_that.isActive,_that.mustChangePassword,_that.createdAt,_that.membership,_that.trainer,_that.recentCheckins,_that.payments);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MemberDetail extends MemberDetail {
  const _MemberDetail({required this.id, required this.firstName, required this.lastName, required this.phone, this.email, this.birthDate, this.gender, this.emergencyContact, this.medicalNotes, required this.isActive, required this.mustChangePassword, required this.createdAt, required this.membership, this.trainer,  List<CheckinRef> recentCheckins = const <CheckinRef>[],  List<Payment> payments = const <Payment>[]}): _recentCheckins = recentCheckins,_payments = payments,super._();
  factory _MemberDetail.fromJson(Map<String, dynamic> json) => _$MemberDetailFromJson(json);

@override final  String id;
@override final  String firstName;
@override final  String lastName;
@override final  String phone;
@override final  String? email;
@override final  String? birthDate;
@override final  String? gender;
@override final  String? emergencyContact;
@override final  String? medicalNotes;
@override final  bool isActive;
@override final  bool mustChangePassword;
@override final  String createdAt;
@override final  MembershipSummary membership;
@override final  PersonRef? trainer;
 final  List<CheckinRef> _recentCheckins;
@override@JsonKey() List<CheckinRef> get recentCheckins {
  if (_recentCheckins is EqualUnmodifiableListView) return _recentCheckins;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_recentCheckins);
}

 final  List<Payment> _payments;
@override@JsonKey() List<Payment> get payments {
  if (_payments is EqualUnmodifiableListView) return _payments;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_payments);
}


/// Create a copy of MemberDetail
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MemberDetailCopyWith<_MemberDetail> get copyWith => __$MemberDetailCopyWithImpl<_MemberDetail>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MemberDetailToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _MemberDetail&&(identical(other.id, id) || other.id == id)&&(identical(other.firstName, firstName) || other.firstName == firstName)&&(identical(other.lastName, lastName) || other.lastName == lastName)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.email, email) || other.email == email)&&(identical(other.birthDate, birthDate) || other.birthDate == birthDate)&&(identical(other.gender, gender) || other.gender == gender)&&(identical(other.emergencyContact, emergencyContact) || other.emergencyContact == emergencyContact)&&(identical(other.medicalNotes, medicalNotes) || other.medicalNotes == medicalNotes)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.mustChangePassword, mustChangePassword) || other.mustChangePassword == mustChangePassword)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.membership, membership) || other.membership == membership)&&(identical(other.trainer, trainer) || other.trainer == trainer)&&const DeepCollectionEquality().equals(other.recentCheckins, _recentCheckins)&&const DeepCollectionEquality().equals(other.payments, _payments));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,firstName,lastName,phone,email,birthDate,gender,emergencyContact,medicalNotes,isActive,mustChangePassword,createdAt,membership,trainer,const DeepCollectionEquality().hash(_recentCheckins),const DeepCollectionEquality().hash(_payments));
}

@override
String toString() {
    return 'MemberDetail(id: $id, firstName: $firstName, lastName: $lastName, phone: $phone, email: $email, birthDate: $birthDate, gender: $gender, emergencyContact: $emergencyContact, medicalNotes: $medicalNotes, isActive: $isActive, mustChangePassword: $mustChangePassword, createdAt: $createdAt, membership: $membership, trainer: $trainer, recentCheckins: $recentCheckins, payments: $payments)';
}


}

/// @nodoc
abstract mixin class _$MemberDetailCopyWith<$Res> implements $MemberDetailCopyWith<$Res> {
  factory _$MemberDetailCopyWith(_MemberDetail value, $Res Function(_MemberDetail) _then) = __$MemberDetailCopyWithImpl;
@override @useResult
$Res call({
 String id, String firstName, String lastName, String phone, String? email, String? birthDate, String? gender, String? emergencyContact, String? medicalNotes, bool isActive, bool mustChangePassword, String createdAt, MembershipSummary membership, PersonRef? trainer, List<CheckinRef> recentCheckins, List<Payment> payments
});


@override $MembershipSummaryCopyWith<$Res> get membership;@override $PersonRefCopyWith<$Res>? get trainer;

}
/// @nodoc
class __$MemberDetailCopyWithImpl<$Res>
    implements _$MemberDetailCopyWith<$Res> {
  __$MemberDetailCopyWithImpl(this._self, this._then);

  final _MemberDetail _self;
  final $Res Function(_MemberDetail) _then;

/// Create a copy of MemberDetail
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? firstName = null,Object? lastName = null,Object? phone = null,Object? email = freezed,Object? birthDate = freezed,Object? gender = freezed,Object? emergencyContact = freezed,Object? medicalNotes = freezed,Object? isActive = null,Object? mustChangePassword = null,Object? createdAt = null,Object? membership = null,Object? trainer = freezed,Object? recentCheckins = null,Object? payments = null,}) {
  return _then(_MemberDetail(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,firstName: null == firstName ? _self.firstName : firstName // ignore: cast_nullable_to_non_nullable
as String,lastName: null == lastName ? _self.lastName : lastName // ignore: cast_nullable_to_non_nullable
as String,phone: null == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,birthDate: freezed == birthDate ? _self.birthDate : birthDate // ignore: cast_nullable_to_non_nullable
as String?,gender: freezed == gender ? _self.gender : gender // ignore: cast_nullable_to_non_nullable
as String?,emergencyContact: freezed == emergencyContact ? _self.emergencyContact : emergencyContact // ignore: cast_nullable_to_non_nullable
as String?,medicalNotes: freezed == medicalNotes ? _self.medicalNotes : medicalNotes // ignore: cast_nullable_to_non_nullable
as String?,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,mustChangePassword: null == mustChangePassword ? _self.mustChangePassword : mustChangePassword // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,membership: null == membership ? _self.membership : membership // ignore: cast_nullable_to_non_nullable
as MembershipSummary,trainer: freezed == trainer ? _self.trainer : trainer // ignore: cast_nullable_to_non_nullable
as PersonRef?,recentCheckins: null == recentCheckins ? _self._recentCheckins : recentCheckins // ignore: cast_nullable_to_non_nullable
as List<CheckinRef>,payments: null == payments ? _self._payments : payments // ignore: cast_nullable_to_non_nullable
as List<Payment>,
  ));
}

/// Create a copy of MemberDetail
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MembershipSummaryCopyWith<$Res> get membership {
  
  return $MembershipSummaryCopyWith<$Res>(_self.membership, (value) {
    return _then(_self.copyWith(membership: value));
  });
}/// Create a copy of MemberDetail
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PersonRefCopyWith<$Res>? get trainer {
    if (_self.trainer == null) {
    return null;
  }

  return $PersonRefCopyWith<$Res>(_self.trainer!, (value) {
    return _then(_self.copyWith(trainer: value));
  });
}
}


/// @nodoc
mixin _$PaymentPreview {

 String get periodStart; String get periodEnd; String get suggestedAmount; String get currency; TierApplies get tierApplies;
/// Create a copy of PaymentPreview
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PaymentPreviewCopyWith<PaymentPreview> get copyWith => _$PaymentPreviewCopyWithImpl<PaymentPreview>(this as PaymentPreview, _$identity);

  /// Serializes this PaymentPreview to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as PaymentPreview;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PaymentPreview&&(identical(other.periodStart, _this.periodStart) || other.periodStart == _this.periodStart)&&(identical(other.periodEnd, _this.periodEnd) || other.periodEnd == _this.periodEnd)&&(identical(other.suggestedAmount, _this.suggestedAmount) || other.suggestedAmount == _this.suggestedAmount)&&(identical(other.currency, _this.currency) || other.currency == _this.currency)&&(identical(other.tierApplies, _this.tierApplies) || other.tierApplies == _this.tierApplies));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as PaymentPreview;
  return Object.hash(runtimeType,_this.periodStart,_this.periodEnd,_this.suggestedAmount,_this.currency,_this.tierApplies);
}

@override
String toString() {
  final _this = this as PaymentPreview;
  return 'PaymentPreview(periodStart: ${_this.periodStart}, periodEnd: ${_this.periodEnd}, suggestedAmount: ${_this.suggestedAmount}, currency: ${_this.currency}, tierApplies: ${_this.tierApplies})';
}


}

/// @nodoc
abstract mixin class $PaymentPreviewCopyWith<$Res>  {
  factory $PaymentPreviewCopyWith(PaymentPreview value, $Res Function(PaymentPreview) _then) = _$PaymentPreviewCopyWithImpl;
@useResult
$Res call({
 String periodStart, String periodEnd, String suggestedAmount, String currency, TierApplies tierApplies
});




}
/// @nodoc
class _$PaymentPreviewCopyWithImpl<$Res>
    implements $PaymentPreviewCopyWith<$Res> {
  _$PaymentPreviewCopyWithImpl(this._self, this._then);

  final PaymentPreview _self;
  final $Res Function(PaymentPreview) _then;

/// Create a copy of PaymentPreview
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? periodStart = null,Object? periodEnd = null,Object? suggestedAmount = null,Object? currency = null,Object? tierApplies = null,}) {
  return _then(PaymentPreview(
periodStart: null == periodStart ? _self.periodStart : periodStart // ignore: cast_nullable_to_non_nullable
as String,periodEnd: null == periodEnd ? _self.periodEnd : periodEnd // ignore: cast_nullable_to_non_nullable
as String,suggestedAmount: null == suggestedAmount ? _self.suggestedAmount : suggestedAmount // ignore: cast_nullable_to_non_nullable
as String,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,tierApplies: null == tierApplies ? _self.tierApplies : tierApplies // ignore: cast_nullable_to_non_nullable
as TierApplies,
  ));
}

}


/// Adds pattern-matching-related methods to [PaymentPreview].
extension PaymentPreviewPatterns on PaymentPreview {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PaymentPreview value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PaymentPreview() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PaymentPreview value)  $default,){
final _that = this;
switch (_that) {
case _PaymentPreview():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PaymentPreview value)?  $default,){
final _that = this;
switch (_that) {
case _PaymentPreview() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String periodStart,  String periodEnd,  String suggestedAmount,  String currency,  TierApplies tierApplies)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PaymentPreview() when $default != null:
return $default(_that.periodStart,_that.periodEnd,_that.suggestedAmount,_that.currency,_that.tierApplies);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String periodStart,  String periodEnd,  String suggestedAmount,  String currency,  TierApplies tierApplies)  $default,) {final _that = this;
switch (_that) {
case _PaymentPreview():
return $default(_that.periodStart,_that.periodEnd,_that.suggestedAmount,_that.currency,_that.tierApplies);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String periodStart,  String periodEnd,  String suggestedAmount,  String currency,  TierApplies tierApplies)?  $default,) {final _that = this;
switch (_that) {
case _PaymentPreview() when $default != null:
return $default(_that.periodStart,_that.periodEnd,_that.suggestedAmount,_that.currency,_that.tierApplies);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PaymentPreview implements PaymentPreview {
  const _PaymentPreview({required this.periodStart, required this.periodEnd, required this.suggestedAmount, required this.currency, required this.tierApplies});
  factory _PaymentPreview.fromJson(Map<String, dynamic> json) => _$PaymentPreviewFromJson(json);

@override final  String periodStart;
@override final  String periodEnd;
@override final  String suggestedAmount;
@override final  String currency;
@override final  TierApplies tierApplies;

/// Create a copy of PaymentPreview
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PaymentPreviewCopyWith<_PaymentPreview> get copyWith => __$PaymentPreviewCopyWithImpl<_PaymentPreview>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PaymentPreviewToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _PaymentPreview&&(identical(other.periodStart, periodStart) || other.periodStart == periodStart)&&(identical(other.periodEnd, periodEnd) || other.periodEnd == periodEnd)&&(identical(other.suggestedAmount, suggestedAmount) || other.suggestedAmount == suggestedAmount)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.tierApplies, tierApplies) || other.tierApplies == tierApplies));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,periodStart,periodEnd,suggestedAmount,currency,tierApplies);
}

@override
String toString() {
    return 'PaymentPreview(periodStart: $periodStart, periodEnd: $periodEnd, suggestedAmount: $suggestedAmount, currency: $currency, tierApplies: $tierApplies)';
}


}

/// @nodoc
abstract mixin class _$PaymentPreviewCopyWith<$Res> implements $PaymentPreviewCopyWith<$Res> {
  factory _$PaymentPreviewCopyWith(_PaymentPreview value, $Res Function(_PaymentPreview) _then) = __$PaymentPreviewCopyWithImpl;
@override @useResult
$Res call({
 String periodStart, String periodEnd, String suggestedAmount, String currency, TierApplies tierApplies
});




}
/// @nodoc
class __$PaymentPreviewCopyWithImpl<$Res>
    implements _$PaymentPreviewCopyWith<$Res> {
  __$PaymentPreviewCopyWithImpl(this._self, this._then);

  final _PaymentPreview _self;
  final $Res Function(_PaymentPreview) _then;

/// Create a copy of PaymentPreview
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? periodStart = null,Object? periodEnd = null,Object? suggestedAmount = null,Object? currency = null,Object? tierApplies = null,}) {
  return _then(_PaymentPreview(
periodStart: null == periodStart ? _self.periodStart : periodStart // ignore: cast_nullable_to_non_nullable
as String,periodEnd: null == periodEnd ? _self.periodEnd : periodEnd // ignore: cast_nullable_to_non_nullable
as String,suggestedAmount: null == suggestedAmount ? _self.suggestedAmount : suggestedAmount // ignore: cast_nullable_to_non_nullable
as String,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,tierApplies: null == tierApplies ? _self.tierApplies : tierApplies // ignore: cast_nullable_to_non_nullable
as TierApplies,
  ));
}


}


/// @nodoc
mixin _$TierChangePreview {

 Tier get fromTier; Tier get toTier; bool get isUpgrade; int get daysLeft; String get suggestedAmount; String get currency; String? get warning;
/// Create a copy of TierChangePreview
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TierChangePreviewCopyWith<TierChangePreview> get copyWith => _$TierChangePreviewCopyWithImpl<TierChangePreview>(this as TierChangePreview, _$identity);

  /// Serializes this TierChangePreview to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as TierChangePreview;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TierChangePreview&&(identical(other.fromTier, _this.fromTier) || other.fromTier == _this.fromTier)&&(identical(other.toTier, _this.toTier) || other.toTier == _this.toTier)&&(identical(other.isUpgrade, _this.isUpgrade) || other.isUpgrade == _this.isUpgrade)&&(identical(other.daysLeft, _this.daysLeft) || other.daysLeft == _this.daysLeft)&&(identical(other.suggestedAmount, _this.suggestedAmount) || other.suggestedAmount == _this.suggestedAmount)&&(identical(other.currency, _this.currency) || other.currency == _this.currency)&&(identical(other.warning, _this.warning) || other.warning == _this.warning));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as TierChangePreview;
  return Object.hash(runtimeType,_this.fromTier,_this.toTier,_this.isUpgrade,_this.daysLeft,_this.suggestedAmount,_this.currency,_this.warning);
}

@override
String toString() {
  final _this = this as TierChangePreview;
  return 'TierChangePreview(fromTier: ${_this.fromTier}, toTier: ${_this.toTier}, isUpgrade: ${_this.isUpgrade}, daysLeft: ${_this.daysLeft}, suggestedAmount: ${_this.suggestedAmount}, currency: ${_this.currency}, warning: ${_this.warning})';
}


}

/// @nodoc
abstract mixin class $TierChangePreviewCopyWith<$Res>  {
  factory $TierChangePreviewCopyWith(TierChangePreview value, $Res Function(TierChangePreview) _then) = _$TierChangePreviewCopyWithImpl;
@useResult
$Res call({
 Tier fromTier, Tier toTier, bool isUpgrade, int daysLeft, String suggestedAmount, String currency, String? warning
});




}
/// @nodoc
class _$TierChangePreviewCopyWithImpl<$Res>
    implements $TierChangePreviewCopyWith<$Res> {
  _$TierChangePreviewCopyWithImpl(this._self, this._then);

  final TierChangePreview _self;
  final $Res Function(TierChangePreview) _then;

/// Create a copy of TierChangePreview
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? fromTier = null,Object? toTier = null,Object? isUpgrade = null,Object? daysLeft = null,Object? suggestedAmount = null,Object? currency = null,Object? warning = freezed,}) {
  return _then(TierChangePreview(
fromTier: null == fromTier ? _self.fromTier : fromTier // ignore: cast_nullable_to_non_nullable
as Tier,toTier: null == toTier ? _self.toTier : toTier // ignore: cast_nullable_to_non_nullable
as Tier,isUpgrade: null == isUpgrade ? _self.isUpgrade : isUpgrade // ignore: cast_nullable_to_non_nullable
as bool,daysLeft: null == daysLeft ? _self.daysLeft : daysLeft // ignore: cast_nullable_to_non_nullable
as int,suggestedAmount: null == suggestedAmount ? _self.suggestedAmount : suggestedAmount // ignore: cast_nullable_to_non_nullable
as String,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,warning: freezed == warning ? _self.warning : warning // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [TierChangePreview].
extension TierChangePreviewPatterns on TierChangePreview {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TierChangePreview value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TierChangePreview() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TierChangePreview value)  $default,){
final _that = this;
switch (_that) {
case _TierChangePreview():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TierChangePreview value)?  $default,){
final _that = this;
switch (_that) {
case _TierChangePreview() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Tier fromTier,  Tier toTier,  bool isUpgrade,  int daysLeft,  String suggestedAmount,  String currency,  String? warning)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TierChangePreview() when $default != null:
return $default(_that.fromTier,_that.toTier,_that.isUpgrade,_that.daysLeft,_that.suggestedAmount,_that.currency,_that.warning);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Tier fromTier,  Tier toTier,  bool isUpgrade,  int daysLeft,  String suggestedAmount,  String currency,  String? warning)  $default,) {final _that = this;
switch (_that) {
case _TierChangePreview():
return $default(_that.fromTier,_that.toTier,_that.isUpgrade,_that.daysLeft,_that.suggestedAmount,_that.currency,_that.warning);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Tier fromTier,  Tier toTier,  bool isUpgrade,  int daysLeft,  String suggestedAmount,  String currency,  String? warning)?  $default,) {final _that = this;
switch (_that) {
case _TierChangePreview() when $default != null:
return $default(_that.fromTier,_that.toTier,_that.isUpgrade,_that.daysLeft,_that.suggestedAmount,_that.currency,_that.warning);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TierChangePreview implements TierChangePreview {
  const _TierChangePreview({required this.fromTier, required this.toTier, required this.isUpgrade, required this.daysLeft, required this.suggestedAmount, required this.currency, this.warning});
  factory _TierChangePreview.fromJson(Map<String, dynamic> json) => _$TierChangePreviewFromJson(json);

@override final  Tier fromTier;
@override final  Tier toTier;
@override final  bool isUpgrade;
@override final  int daysLeft;
@override final  String suggestedAmount;
@override final  String currency;
@override final  String? warning;

/// Create a copy of TierChangePreview
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TierChangePreviewCopyWith<_TierChangePreview> get copyWith => __$TierChangePreviewCopyWithImpl<_TierChangePreview>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TierChangePreviewToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _TierChangePreview&&(identical(other.fromTier, fromTier) || other.fromTier == fromTier)&&(identical(other.toTier, toTier) || other.toTier == toTier)&&(identical(other.isUpgrade, isUpgrade) || other.isUpgrade == isUpgrade)&&(identical(other.daysLeft, daysLeft) || other.daysLeft == daysLeft)&&(identical(other.suggestedAmount, suggestedAmount) || other.suggestedAmount == suggestedAmount)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.warning, warning) || other.warning == warning));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,fromTier,toTier,isUpgrade,daysLeft,suggestedAmount,currency,warning);
}

@override
String toString() {
    return 'TierChangePreview(fromTier: $fromTier, toTier: $toTier, isUpgrade: $isUpgrade, daysLeft: $daysLeft, suggestedAmount: $suggestedAmount, currency: $currency, warning: $warning)';
}


}

/// @nodoc
abstract mixin class _$TierChangePreviewCopyWith<$Res> implements $TierChangePreviewCopyWith<$Res> {
  factory _$TierChangePreviewCopyWith(_TierChangePreview value, $Res Function(_TierChangePreview) _then) = __$TierChangePreviewCopyWithImpl;
@override @useResult
$Res call({
 Tier fromTier, Tier toTier, bool isUpgrade, int daysLeft, String suggestedAmount, String currency, String? warning
});




}
/// @nodoc
class __$TierChangePreviewCopyWithImpl<$Res>
    implements _$TierChangePreviewCopyWith<$Res> {
  __$TierChangePreviewCopyWithImpl(this._self, this._then);

  final _TierChangePreview _self;
  final $Res Function(_TierChangePreview) _then;

/// Create a copy of TierChangePreview
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? fromTier = null,Object? toTier = null,Object? isUpgrade = null,Object? daysLeft = null,Object? suggestedAmount = null,Object? currency = null,Object? warning = freezed,}) {
  return _then(_TierChangePreview(
fromTier: null == fromTier ? _self.fromTier : fromTier // ignore: cast_nullable_to_non_nullable
as Tier,toTier: null == toTier ? _self.toTier : toTier // ignore: cast_nullable_to_non_nullable
as Tier,isUpgrade: null == isUpgrade ? _self.isUpgrade : isUpgrade // ignore: cast_nullable_to_non_nullable
as bool,daysLeft: null == daysLeft ? _self.daysLeft : daysLeft // ignore: cast_nullable_to_non_nullable
as int,suggestedAmount: null == suggestedAmount ? _self.suggestedAmount : suggestedAmount // ignore: cast_nullable_to_non_nullable
as String,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,warning: freezed == warning ? _self.warning : warning // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc
mixin _$MemberFilters {

 String get query; MemberStatusFilter? get status; Tier? get tier;
/// Create a copy of MemberFilters
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MemberFiltersCopyWith<MemberFilters> get copyWith => _$MemberFiltersCopyWithImpl<MemberFilters>(this as MemberFilters, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as MemberFilters;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MemberFilters&&(identical(other.query, _this.query) || other.query == _this.query)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.tier, _this.tier) || other.tier == _this.tier));
}


@override
int get hashCode {
  final _this = this as MemberFilters;
  return Object.hash(runtimeType,_this.query,_this.status,_this.tier);
}

@override
String toString() {
  final _this = this as MemberFilters;
  return 'MemberFilters(query: ${_this.query}, status: ${_this.status}, tier: ${_this.tier})';
}


}

/// @nodoc
abstract mixin class $MemberFiltersCopyWith<$Res>  {
  factory $MemberFiltersCopyWith(MemberFilters value, $Res Function(MemberFilters) _then) = _$MemberFiltersCopyWithImpl;
@useResult
$Res call({
 String query, MemberStatusFilter? status, Tier? tier
});




}
/// @nodoc
class _$MemberFiltersCopyWithImpl<$Res>
    implements $MemberFiltersCopyWith<$Res> {
  _$MemberFiltersCopyWithImpl(this._self, this._then);

  final MemberFilters _self;
  final $Res Function(MemberFilters) _then;

/// Create a copy of MemberFilters
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? query = null,Object? status = freezed,Object? tier = freezed,}) {
  return _then(MemberFilters(
query: null == query ? _self.query : query // ignore: cast_nullable_to_non_nullable
as String,status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as MemberStatusFilter?,tier: freezed == tier ? _self.tier : tier // ignore: cast_nullable_to_non_nullable
as Tier?,
  ));
}

}


/// Adds pattern-matching-related methods to [MemberFilters].
extension MemberFiltersPatterns on MemberFilters {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MemberFilters value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MemberFilters() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MemberFilters value)  $default,){
final _that = this;
switch (_that) {
case _MemberFilters():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MemberFilters value)?  $default,){
final _that = this;
switch (_that) {
case _MemberFilters() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String query,  MemberStatusFilter? status,  Tier? tier)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MemberFilters() when $default != null:
return $default(_that.query,_that.status,_that.tier);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String query,  MemberStatusFilter? status,  Tier? tier)  $default,) {final _that = this;
switch (_that) {
case _MemberFilters():
return $default(_that.query,_that.status,_that.tier);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String query,  MemberStatusFilter? status,  Tier? tier)?  $default,) {final _that = this;
switch (_that) {
case _MemberFilters() when $default != null:
return $default(_that.query,_that.status,_that.tier);case _:
  return null;

}
}

}

/// @nodoc


class _MemberFilters implements MemberFilters {
  const _MemberFilters({this.query = '', this.status, this.tier});
  

@override@JsonKey() final  String query;
@override final  MemberStatusFilter? status;
@override final  Tier? tier;

/// Create a copy of MemberFilters
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MemberFiltersCopyWith<_MemberFilters> get copyWith => __$MemberFiltersCopyWithImpl<_MemberFilters>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _MemberFilters&&(identical(other.query, query) || other.query == query)&&(identical(other.status, status) || other.status == status)&&(identical(other.tier, tier) || other.tier == tier));
}


@override
int get hashCode {
    return Object.hash(runtimeType,query,status,tier);
}

@override
String toString() {
    return 'MemberFilters(query: $query, status: $status, tier: $tier)';
}


}

/// @nodoc
abstract mixin class _$MemberFiltersCopyWith<$Res> implements $MemberFiltersCopyWith<$Res> {
  factory _$MemberFiltersCopyWith(_MemberFilters value, $Res Function(_MemberFilters) _then) = __$MemberFiltersCopyWithImpl;
@override @useResult
$Res call({
 String query, MemberStatusFilter? status, Tier? tier
});




}
/// @nodoc
class __$MemberFiltersCopyWithImpl<$Res>
    implements _$MemberFiltersCopyWith<$Res> {
  __$MemberFiltersCopyWithImpl(this._self, this._then);

  final _MemberFilters _self;
  final $Res Function(_MemberFilters) _then;

/// Create a copy of MemberFilters
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? query = null,Object? status = freezed,Object? tier = freezed,}) {
  return _then(_MemberFilters(
query: null == query ? _self.query : query // ignore: cast_nullable_to_non_nullable
as String,status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as MemberStatusFilter?,tier: freezed == tier ? _self.tier : tier // ignore: cast_nullable_to_non_nullable
as Tier?,
  ));
}


}

// dart format on
