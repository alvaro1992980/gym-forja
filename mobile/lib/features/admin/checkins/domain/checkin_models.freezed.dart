// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'checkin_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CheckinItem {

 String get id; PersonRef get member; Tier get tier; int get daysLeft; String get createdAt;
/// Create a copy of CheckinItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CheckinItemCopyWith<CheckinItem> get copyWith => _$CheckinItemCopyWithImpl<CheckinItem>(this as CheckinItem, _$identity);

  /// Serializes this CheckinItem to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as CheckinItem;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CheckinItem&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.member, _this.member) || other.member == _this.member)&&(identical(other.tier, _this.tier) || other.tier == _this.tier)&&(identical(other.daysLeft, _this.daysLeft) || other.daysLeft == _this.daysLeft)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as CheckinItem;
  return Object.hash(runtimeType,_this.id,_this.member,_this.tier,_this.daysLeft,_this.createdAt);
}

@override
String toString() {
  final _this = this as CheckinItem;
  return 'CheckinItem(id: ${_this.id}, member: ${_this.member}, tier: ${_this.tier}, daysLeft: ${_this.daysLeft}, createdAt: ${_this.createdAt})';
}


}

/// @nodoc
abstract mixin class $CheckinItemCopyWith<$Res>  {
  factory $CheckinItemCopyWith(CheckinItem value, $Res Function(CheckinItem) _then) = _$CheckinItemCopyWithImpl;
@useResult
$Res call({
 String id, PersonRef member, Tier tier, int daysLeft, String createdAt
});


$PersonRefCopyWith<$Res> get member;

}
/// @nodoc
class _$CheckinItemCopyWithImpl<$Res>
    implements $CheckinItemCopyWith<$Res> {
  _$CheckinItemCopyWithImpl(this._self, this._then);

  final CheckinItem _self;
  final $Res Function(CheckinItem) _then;

/// Create a copy of CheckinItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? member = null,Object? tier = null,Object? daysLeft = null,Object? createdAt = null,}) {
  return _then(CheckinItem(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,member: null == member ? _self.member : member // ignore: cast_nullable_to_non_nullable
as PersonRef,tier: null == tier ? _self.tier : tier // ignore: cast_nullable_to_non_nullable
as Tier,daysLeft: null == daysLeft ? _self.daysLeft : daysLeft // ignore: cast_nullable_to_non_nullable
as int,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,
  ));
}
/// Create a copy of CheckinItem
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PersonRefCopyWith<$Res> get member {
  
  return $PersonRefCopyWith<$Res>(_self.member, (value) {
    return _then(_self.copyWith(member: value));
  });
}
}


/// Adds pattern-matching-related methods to [CheckinItem].
extension CheckinItemPatterns on CheckinItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CheckinItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CheckinItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CheckinItem value)  $default,){
final _that = this;
switch (_that) {
case _CheckinItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CheckinItem value)?  $default,){
final _that = this;
switch (_that) {
case _CheckinItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  PersonRef member,  Tier tier,  int daysLeft,  String createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CheckinItem() when $default != null:
return $default(_that.id,_that.member,_that.tier,_that.daysLeft,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  PersonRef member,  Tier tier,  int daysLeft,  String createdAt)  $default,) {final _that = this;
switch (_that) {
case _CheckinItem():
return $default(_that.id,_that.member,_that.tier,_that.daysLeft,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  PersonRef member,  Tier tier,  int daysLeft,  String createdAt)?  $default,) {final _that = this;
switch (_that) {
case _CheckinItem() when $default != null:
return $default(_that.id,_that.member,_that.tier,_that.daysLeft,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CheckinItem implements CheckinItem {
  const _CheckinItem({required this.id, required this.member, required this.tier, required this.daysLeft, required this.createdAt});
  factory _CheckinItem.fromJson(Map<String, dynamic> json) => _$CheckinItemFromJson(json);

@override final  String id;
@override final  PersonRef member;
@override final  Tier tier;
@override final  int daysLeft;
@override final  String createdAt;

/// Create a copy of CheckinItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CheckinItemCopyWith<_CheckinItem> get copyWith => __$CheckinItemCopyWithImpl<_CheckinItem>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CheckinItemToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CheckinItem&&(identical(other.id, id) || other.id == id)&&(identical(other.member, member) || other.member == member)&&(identical(other.tier, tier) || other.tier == tier)&&(identical(other.daysLeft, daysLeft) || other.daysLeft == daysLeft)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,member,tier,daysLeft,createdAt);
}

@override
String toString() {
    return 'CheckinItem(id: $id, member: $member, tier: $tier, daysLeft: $daysLeft, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$CheckinItemCopyWith<$Res> implements $CheckinItemCopyWith<$Res> {
  factory _$CheckinItemCopyWith(_CheckinItem value, $Res Function(_CheckinItem) _then) = __$CheckinItemCopyWithImpl;
@override @useResult
$Res call({
 String id, PersonRef member, Tier tier, int daysLeft, String createdAt
});


@override $PersonRefCopyWith<$Res> get member;

}
/// @nodoc
class __$CheckinItemCopyWithImpl<$Res>
    implements _$CheckinItemCopyWith<$Res> {
  __$CheckinItemCopyWithImpl(this._self, this._then);

  final _CheckinItem _self;
  final $Res Function(_CheckinItem) _then;

/// Create a copy of CheckinItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? member = null,Object? tier = null,Object? daysLeft = null,Object? createdAt = null,}) {
  return _then(_CheckinItem(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,member: null == member ? _self.member : member // ignore: cast_nullable_to_non_nullable
as PersonRef,tier: null == tier ? _self.tier : tier // ignore: cast_nullable_to_non_nullable
as Tier,daysLeft: null == daysLeft ? _self.daysLeft : daysLeft // ignore: cast_nullable_to_non_nullable
as int,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

/// Create a copy of CheckinItem
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PersonRefCopyWith<$Res> get member {
  
  return $PersonRefCopyWith<$Res>(_self.member, (value) {
    return _then(_self.copyWith(member: value));
  });
}
}


/// @nodoc
mixin _$CheckinAttempt {

 String get id; CheckinResult get result; PersonRef? get member; String? get detail; String get createdAt;
/// Create a copy of CheckinAttempt
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CheckinAttemptCopyWith<CheckinAttempt> get copyWith => _$CheckinAttemptCopyWithImpl<CheckinAttempt>(this as CheckinAttempt, _$identity);

  /// Serializes this CheckinAttempt to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as CheckinAttempt;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CheckinAttempt&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.result, _this.result) || other.result == _this.result)&&(identical(other.member, _this.member) || other.member == _this.member)&&(identical(other.detail, _this.detail) || other.detail == _this.detail)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as CheckinAttempt;
  return Object.hash(runtimeType,_this.id,_this.result,_this.member,_this.detail,_this.createdAt);
}

@override
String toString() {
  final _this = this as CheckinAttempt;
  return 'CheckinAttempt(id: ${_this.id}, result: ${_this.result}, member: ${_this.member}, detail: ${_this.detail}, createdAt: ${_this.createdAt})';
}


}

/// @nodoc
abstract mixin class $CheckinAttemptCopyWith<$Res>  {
  factory $CheckinAttemptCopyWith(CheckinAttempt value, $Res Function(CheckinAttempt) _then) = _$CheckinAttemptCopyWithImpl;
@useResult
$Res call({
 String id, CheckinResult result, PersonRef? member, String? detail, String createdAt
});


$PersonRefCopyWith<$Res>? get member;

}
/// @nodoc
class _$CheckinAttemptCopyWithImpl<$Res>
    implements $CheckinAttemptCopyWith<$Res> {
  _$CheckinAttemptCopyWithImpl(this._self, this._then);

  final CheckinAttempt _self;
  final $Res Function(CheckinAttempt) _then;

/// Create a copy of CheckinAttempt
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? result = null,Object? member = freezed,Object? detail = freezed,Object? createdAt = null,}) {
  return _then(CheckinAttempt(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,result: null == result ? _self.result : result // ignore: cast_nullable_to_non_nullable
as CheckinResult,member: freezed == member ? _self.member : member // ignore: cast_nullable_to_non_nullable
as PersonRef?,detail: freezed == detail ? _self.detail : detail // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,
  ));
}
/// Create a copy of CheckinAttempt
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PersonRefCopyWith<$Res>? get member {
    if (_self.member == null) {
    return null;
  }

  return $PersonRefCopyWith<$Res>(_self.member!, (value) {
    return _then(_self.copyWith(member: value));
  });
}
}


/// Adds pattern-matching-related methods to [CheckinAttempt].
extension CheckinAttemptPatterns on CheckinAttempt {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CheckinAttempt value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CheckinAttempt() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CheckinAttempt value)  $default,){
final _that = this;
switch (_that) {
case _CheckinAttempt():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CheckinAttempt value)?  $default,){
final _that = this;
switch (_that) {
case _CheckinAttempt() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  CheckinResult result,  PersonRef? member,  String? detail,  String createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CheckinAttempt() when $default != null:
return $default(_that.id,_that.result,_that.member,_that.detail,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  CheckinResult result,  PersonRef? member,  String? detail,  String createdAt)  $default,) {final _that = this;
switch (_that) {
case _CheckinAttempt():
return $default(_that.id,_that.result,_that.member,_that.detail,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  CheckinResult result,  PersonRef? member,  String? detail,  String createdAt)?  $default,) {final _that = this;
switch (_that) {
case _CheckinAttempt() when $default != null:
return $default(_that.id,_that.result,_that.member,_that.detail,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CheckinAttempt extends CheckinAttempt {
  const _CheckinAttempt({required this.id, required this.result, this.member, this.detail, required this.createdAt}): super._();
  factory _CheckinAttempt.fromJson(Map<String, dynamic> json) => _$CheckinAttemptFromJson(json);

@override final  String id;
@override final  CheckinResult result;
@override final  PersonRef? member;
@override final  String? detail;
@override final  String createdAt;

/// Create a copy of CheckinAttempt
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CheckinAttemptCopyWith<_CheckinAttempt> get copyWith => __$CheckinAttemptCopyWithImpl<_CheckinAttempt>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CheckinAttemptToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CheckinAttempt&&(identical(other.id, id) || other.id == id)&&(identical(other.result, result) || other.result == result)&&(identical(other.member, member) || other.member == member)&&(identical(other.detail, detail) || other.detail == detail)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,result,member,detail,createdAt);
}

@override
String toString() {
    return 'CheckinAttempt(id: $id, result: $result, member: $member, detail: $detail, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$CheckinAttemptCopyWith<$Res> implements $CheckinAttemptCopyWith<$Res> {
  factory _$CheckinAttemptCopyWith(_CheckinAttempt value, $Res Function(_CheckinAttempt) _then) = __$CheckinAttemptCopyWithImpl;
@override @useResult
$Res call({
 String id, CheckinResult result, PersonRef? member, String? detail, String createdAt
});


@override $PersonRefCopyWith<$Res>? get member;

}
/// @nodoc
class __$CheckinAttemptCopyWithImpl<$Res>
    implements _$CheckinAttemptCopyWith<$Res> {
  __$CheckinAttemptCopyWithImpl(this._self, this._then);

  final _CheckinAttempt _self;
  final $Res Function(_CheckinAttempt) _then;

/// Create a copy of CheckinAttempt
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? result = null,Object? member = freezed,Object? detail = freezed,Object? createdAt = null,}) {
  return _then(_CheckinAttempt(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,result: null == result ? _self.result : result // ignore: cast_nullable_to_non_nullable
as CheckinResult,member: freezed == member ? _self.member : member // ignore: cast_nullable_to_non_nullable
as PersonRef?,detail: freezed == detail ? _self.detail : detail // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

/// Create a copy of CheckinAttempt
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PersonRefCopyWith<$Res>? get member {
    if (_self.member == null) {
    return null;
  }

  return $PersonRefCopyWith<$Res>(_self.member!, (value) {
    return _then(_self.copyWith(member: value));
  });
}
}


/// @nodoc
mixin _$InsideNow {

 int get count; int get windowMinutes; List<CheckinItem> get items;
/// Create a copy of InsideNow
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$InsideNowCopyWith<InsideNow> get copyWith => _$InsideNowCopyWithImpl<InsideNow>(this as InsideNow, _$identity);

  /// Serializes this InsideNow to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as InsideNow;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is InsideNow&&(identical(other.count, _this.count) || other.count == _this.count)&&(identical(other.windowMinutes, _this.windowMinutes) || other.windowMinutes == _this.windowMinutes)&&const DeepCollectionEquality().equals(other.items, _this.items));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as InsideNow;
  return Object.hash(runtimeType,_this.count,_this.windowMinutes,const DeepCollectionEquality().hash(_this.items));
}

@override
String toString() {
  final _this = this as InsideNow;
  return 'InsideNow(count: ${_this.count}, windowMinutes: ${_this.windowMinutes}, items: ${_this.items})';
}


}

/// @nodoc
abstract mixin class $InsideNowCopyWith<$Res>  {
  factory $InsideNowCopyWith(InsideNow value, $Res Function(InsideNow) _then) = _$InsideNowCopyWithImpl;
@useResult
$Res call({
 int count, int windowMinutes, List<CheckinItem> items
});




}
/// @nodoc
class _$InsideNowCopyWithImpl<$Res>
    implements $InsideNowCopyWith<$Res> {
  _$InsideNowCopyWithImpl(this._self, this._then);

  final InsideNow _self;
  final $Res Function(InsideNow) _then;

/// Create a copy of InsideNow
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? count = null,Object? windowMinutes = null,Object? items = null,}) {
  return _then(InsideNow(
count: null == count ? _self.count : count // ignore: cast_nullable_to_non_nullable
as int,windowMinutes: null == windowMinutes ? _self.windowMinutes : windowMinutes // ignore: cast_nullable_to_non_nullable
as int,items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<CheckinItem>,
  ));
}

}


/// Adds pattern-matching-related methods to [InsideNow].
extension InsideNowPatterns on InsideNow {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _InsideNow value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _InsideNow() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _InsideNow value)  $default,){
final _that = this;
switch (_that) {
case _InsideNow():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _InsideNow value)?  $default,){
final _that = this;
switch (_that) {
case _InsideNow() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int count,  int windowMinutes,  List<CheckinItem> items)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _InsideNow() when $default != null:
return $default(_that.count,_that.windowMinutes,_that.items);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int count,  int windowMinutes,  List<CheckinItem> items)  $default,) {final _that = this;
switch (_that) {
case _InsideNow():
return $default(_that.count,_that.windowMinutes,_that.items);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int count,  int windowMinutes,  List<CheckinItem> items)?  $default,) {final _that = this;
switch (_that) {
case _InsideNow() when $default != null:
return $default(_that.count,_that.windowMinutes,_that.items);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _InsideNow implements InsideNow {
  const _InsideNow({required this.count, required this.windowMinutes, required  List<CheckinItem> items}): _items = items;
  factory _InsideNow.fromJson(Map<String, dynamic> json) => _$InsideNowFromJson(json);

@override final  int count;
@override final  int windowMinutes;
 final  List<CheckinItem> _items;
@override List<CheckinItem> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}


/// Create a copy of InsideNow
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$InsideNowCopyWith<_InsideNow> get copyWith => __$InsideNowCopyWithImpl<_InsideNow>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$InsideNowToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _InsideNow&&(identical(other.count, count) || other.count == count)&&(identical(other.windowMinutes, windowMinutes) || other.windowMinutes == windowMinutes)&&const DeepCollectionEquality().equals(other.items, _items));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,count,windowMinutes,const DeepCollectionEquality().hash(_items));
}

@override
String toString() {
    return 'InsideNow(count: $count, windowMinutes: $windowMinutes, items: $items)';
}


}

/// @nodoc
abstract mixin class _$InsideNowCopyWith<$Res> implements $InsideNowCopyWith<$Res> {
  factory _$InsideNowCopyWith(_InsideNow value, $Res Function(_InsideNow) _then) = __$InsideNowCopyWithImpl;
@override @useResult
$Res call({
 int count, int windowMinutes, List<CheckinItem> items
});




}
/// @nodoc
class __$InsideNowCopyWithImpl<$Res>
    implements _$InsideNowCopyWith<$Res> {
  __$InsideNowCopyWithImpl(this._self, this._then);

  final _InsideNow _self;
  final $Res Function(_InsideNow) _then;

/// Create a copy of InsideNow
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? count = null,Object? windowMinutes = null,Object? items = null,}) {
  return _then(_InsideNow(
count: null == count ? _self.count : count // ignore: cast_nullable_to_non_nullable
as int,windowMinutes: null == windowMinutes ? _self.windowMinutes : windowMinutes // ignore: cast_nullable_to_non_nullable
as int,items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<CheckinItem>,
  ));
}


}

// dart format on
