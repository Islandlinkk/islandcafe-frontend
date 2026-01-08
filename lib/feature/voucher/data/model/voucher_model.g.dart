// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'voucher_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_VoucherModel _$VoucherModelFromJson(Map<String, dynamic> json) =>
    _VoucherModel(
      id: json['id'] as String,
      code: json['code'] as String,
      description: json['description'] as String?,
      discountType: json['discountType'] as String,
      discountValue: _stringToNum(json['discountValue']),
      minOrderValue: _stringToNum(json['minOrderValue']),
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      isActive: json['isActive'] as bool,
    );

Map<String, dynamic> _$VoucherModelToJson(_VoucherModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'code': instance.code,
      'description': instance.description,
      'discountType': instance.discountType,
      'discountValue': instance.discountValue,
      'minOrderValue': instance.minOrderValue,
      'startDate': instance.startDate.toIso8601String(),
      'endDate': instance.endDate.toIso8601String(),
      'isActive': instance.isActive,
    };
