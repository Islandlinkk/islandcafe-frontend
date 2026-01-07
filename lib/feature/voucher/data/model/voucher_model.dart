import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:intl/intl.dart';

part 'voucher_model.freezed.dart';
part 'voucher_model.g.dart';

num _stringToNum(dynamic value) {
  if (value is num) return value;
  if (value is String) return num.tryParse(value) ?? 0;
  return 0;
}

@freezed
abstract class VoucherModel with _$VoucherModel {
  const VoucherModel._();

  const factory VoucherModel({
    required String id,
    required String code,
    String? description,
    required String discountType,
    
    // Fixed: Added JsonKey to handle String/Num conversion
    @JsonKey(fromJson: _stringToNum) 
    required num discountValue,

    // Fixed: Added JsonKey to map minOrderTotal and handle conversion
    @JsonKey(name: 'minOrderTotal', fromJson: _stringToNum) 
    num? minOrderValue,
    
    required DateTime startDate,
    required DateTime endDate,
    required bool isActive,
  }) = _VoucherModel;

  factory VoucherModel.fromJson(Map<String, dynamic> json) =>
      _$VoucherModelFromJson(json);

  String get formattedDiscount {
    if (discountType.toUpperCase() == 'PERCENTAGE') {
      return '${discountValue.toStringAsFixed(0)}% OFF';
    } else {
      return '\$${discountValue.toStringAsFixed(2)} OFF';
    }
  }

  String get minSpendText {
    if (minOrderValue == null || minOrderValue == 0) return 'No min. spend';
    return 'Min. spend \$${minOrderValue!.toStringAsFixed(2)}';
  }

  String get formattedExpiry {
    return DateFormat('d MMM yyyy').format(endDate);
  }
}