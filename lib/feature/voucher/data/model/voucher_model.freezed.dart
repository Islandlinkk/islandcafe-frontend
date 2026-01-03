// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'voucher_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$VoucherModel {

 String get id; String get code; String? get description; String get discountType;// 'percentage' or 'fixed'
@JsonKey(fromJson: _stringToNum) num get discountValue;@JsonKey(fromJson: _stringToNum) num? get minOrderValue;// New Field
 DateTime get startDate; DateTime get endDate; bool get isActive;
/// Create a copy of VoucherModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VoucherModelCopyWith<VoucherModel> get copyWith => _$VoucherModelCopyWithImpl<VoucherModel>(this as VoucherModel, _$identity);

  /// Serializes this VoucherModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VoucherModel&&(identical(other.id, id) || other.id == id)&&(identical(other.code, code) || other.code == code)&&(identical(other.description, description) || other.description == description)&&(identical(other.discountType, discountType) || other.discountType == discountType)&&(identical(other.discountValue, discountValue) || other.discountValue == discountValue)&&(identical(other.minOrderValue, minOrderValue) || other.minOrderValue == minOrderValue)&&(identical(other.startDate, startDate) || other.startDate == startDate)&&(identical(other.endDate, endDate) || other.endDate == endDate)&&(identical(other.isActive, isActive) || other.isActive == isActive));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,code,description,discountType,discountValue,minOrderValue,startDate,endDate,isActive);

@override
String toString() {
  return 'VoucherModel(id: $id, code: $code, description: $description, discountType: $discountType, discountValue: $discountValue, minOrderValue: $minOrderValue, startDate: $startDate, endDate: $endDate, isActive: $isActive)';
}


}

/// @nodoc
abstract mixin class $VoucherModelCopyWith<$Res>  {
  factory $VoucherModelCopyWith(VoucherModel value, $Res Function(VoucherModel) _then) = _$VoucherModelCopyWithImpl;
@useResult
$Res call({
 String id, String code, String? description, String discountType,@JsonKey(fromJson: _stringToNum) num discountValue,@JsonKey(fromJson: _stringToNum) num? minOrderValue, DateTime startDate, DateTime endDate, bool isActive
});




}
/// @nodoc
class _$VoucherModelCopyWithImpl<$Res>
    implements $VoucherModelCopyWith<$Res> {
  _$VoucherModelCopyWithImpl(this._self, this._then);

  final VoucherModel _self;
  final $Res Function(VoucherModel) _then;

/// Create a copy of VoucherModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? code = null,Object? description = freezed,Object? discountType = null,Object? discountValue = null,Object? minOrderValue = freezed,Object? startDate = null,Object? endDate = null,Object? isActive = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,discountType: null == discountType ? _self.discountType : discountType // ignore: cast_nullable_to_non_nullable
as String,discountValue: null == discountValue ? _self.discountValue : discountValue // ignore: cast_nullable_to_non_nullable
as num,minOrderValue: freezed == minOrderValue ? _self.minOrderValue : minOrderValue // ignore: cast_nullable_to_non_nullable
as num?,startDate: null == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as DateTime,endDate: null == endDate ? _self.endDate : endDate // ignore: cast_nullable_to_non_nullable
as DateTime,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [VoucherModel].
extension VoucherModelPatterns on VoucherModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _VoucherModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _VoucherModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _VoucherModel value)  $default,){
final _that = this;
switch (_that) {
case _VoucherModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _VoucherModel value)?  $default,){
final _that = this;
switch (_that) {
case _VoucherModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String code,  String? description,  String discountType, @JsonKey(fromJson: _stringToNum)  num discountValue, @JsonKey(fromJson: _stringToNum)  num? minOrderValue,  DateTime startDate,  DateTime endDate,  bool isActive)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _VoucherModel() when $default != null:
return $default(_that.id,_that.code,_that.description,_that.discountType,_that.discountValue,_that.minOrderValue,_that.startDate,_that.endDate,_that.isActive);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String code,  String? description,  String discountType, @JsonKey(fromJson: _stringToNum)  num discountValue, @JsonKey(fromJson: _stringToNum)  num? minOrderValue,  DateTime startDate,  DateTime endDate,  bool isActive)  $default,) {final _that = this;
switch (_that) {
case _VoucherModel():
return $default(_that.id,_that.code,_that.description,_that.discountType,_that.discountValue,_that.minOrderValue,_that.startDate,_that.endDate,_that.isActive);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String code,  String? description,  String discountType, @JsonKey(fromJson: _stringToNum)  num discountValue, @JsonKey(fromJson: _stringToNum)  num? minOrderValue,  DateTime startDate,  DateTime endDate,  bool isActive)?  $default,) {final _that = this;
switch (_that) {
case _VoucherModel() when $default != null:
return $default(_that.id,_that.code,_that.description,_that.discountType,_that.discountValue,_that.minOrderValue,_that.startDate,_that.endDate,_that.isActive);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _VoucherModel extends VoucherModel {
  const _VoucherModel({required this.id, required this.code, this.description, required this.discountType, @JsonKey(fromJson: _stringToNum) required this.discountValue, @JsonKey(fromJson: _stringToNum) this.minOrderValue, required this.startDate, required this.endDate, required this.isActive}): super._();
  factory _VoucherModel.fromJson(Map<String, dynamic> json) => _$VoucherModelFromJson(json);

@override final  String id;
@override final  String code;
@override final  String? description;
@override final  String discountType;
// 'percentage' or 'fixed'
@override@JsonKey(fromJson: _stringToNum) final  num discountValue;
@override@JsonKey(fromJson: _stringToNum) final  num? minOrderValue;
// New Field
@override final  DateTime startDate;
@override final  DateTime endDate;
@override final  bool isActive;

/// Create a copy of VoucherModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VoucherModelCopyWith<_VoucherModel> get copyWith => __$VoucherModelCopyWithImpl<_VoucherModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$VoucherModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _VoucherModel&&(identical(other.id, id) || other.id == id)&&(identical(other.code, code) || other.code == code)&&(identical(other.description, description) || other.description == description)&&(identical(other.discountType, discountType) || other.discountType == discountType)&&(identical(other.discountValue, discountValue) || other.discountValue == discountValue)&&(identical(other.minOrderValue, minOrderValue) || other.minOrderValue == minOrderValue)&&(identical(other.startDate, startDate) || other.startDate == startDate)&&(identical(other.endDate, endDate) || other.endDate == endDate)&&(identical(other.isActive, isActive) || other.isActive == isActive));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,code,description,discountType,discountValue,minOrderValue,startDate,endDate,isActive);

@override
String toString() {
  return 'VoucherModel(id: $id, code: $code, description: $description, discountType: $discountType, discountValue: $discountValue, minOrderValue: $minOrderValue, startDate: $startDate, endDate: $endDate, isActive: $isActive)';
}


}

/// @nodoc
abstract mixin class _$VoucherModelCopyWith<$Res> implements $VoucherModelCopyWith<$Res> {
  factory _$VoucherModelCopyWith(_VoucherModel value, $Res Function(_VoucherModel) _then) = __$VoucherModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String code, String? description, String discountType,@JsonKey(fromJson: _stringToNum) num discountValue,@JsonKey(fromJson: _stringToNum) num? minOrderValue, DateTime startDate, DateTime endDate, bool isActive
});




}
/// @nodoc
class __$VoucherModelCopyWithImpl<$Res>
    implements _$VoucherModelCopyWith<$Res> {
  __$VoucherModelCopyWithImpl(this._self, this._then);

  final _VoucherModel _self;
  final $Res Function(_VoucherModel) _then;

/// Create a copy of VoucherModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? code = null,Object? description = freezed,Object? discountType = null,Object? discountValue = null,Object? minOrderValue = freezed,Object? startDate = null,Object? endDate = null,Object? isActive = null,}) {
  return _then(_VoucherModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,discountType: null == discountType ? _self.discountType : discountType // ignore: cast_nullable_to_non_nullable
as String,discountValue: null == discountValue ? _self.discountValue : discountValue // ignore: cast_nullable_to_non_nullable
as num,minOrderValue: freezed == minOrderValue ? _self.minOrderValue : minOrderValue // ignore: cast_nullable_to_non_nullable
as num?,startDate: null == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as DateTime,endDate: null == endDate ? _self.endDate : endDate // ignore: cast_nullable_to_non_nullable
as DateTime,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
