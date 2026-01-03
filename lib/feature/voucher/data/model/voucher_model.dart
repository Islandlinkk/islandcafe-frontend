import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:intl/intl.dart'; // Add this for date formatting

part 'voucher_model.freezed.dart';
part 'voucher_model.g.dart';

num _stringToNum(dynamic value) {
  if (value is num) return value;
  if (value is String) return num.tryParse(value) ?? 0;
  return 0;
}

@freezed
abstract class VoucherModel with _$VoucherModel {
  const VoucherModel._(); // Needed for custom getters

  const factory VoucherModel({
    required String id,
    required String code,
    String? description,
    required String discountType, // 'percentage' or 'fixed'
    @JsonKey(fromJson: _stringToNum) required num discountValue,
    @JsonKey(fromJson: _stringToNum) num? minOrderValue, // New Field
    required DateTime startDate,
    required DateTime endDate,
    required bool isActive,
  }) = _VoucherModel;

  factory VoucherModel.fromJson(Map<String, dynamic> json) =>
      _$VoucherModelFromJson(json);

  // --- Helpers for UI ---
  
  // Returns "10% OFF" or "$5.00 OFF"
  String get formattedDiscount {
    if (discountType == 'percentage') {
      return '${discountValue.toStringAsFixed(0)}% OFF';
    } else {
      return '\$${discountValue.toStringAsFixed(2)} OFF';
    }
  }

  // Returns "Min. Spend: $15.00"
  String get minSpendText {
    if (minOrderValue == null || minOrderValue == 0) return 'No min. spend';
    return 'Min. spend \$${minOrderValue!.toStringAsFixed(2)}';
  }

  // Returns "Valid until: 25 Dec 2025"
  String get formattedExpiry {
    return DateFormat('d MMM yyyy').format(endDate);
  }
}