import 'package:island_cafe/feature/checkout/data/model/order_item_model.dart';
import 'package:island_cafe/feature/voucher/data/model/voucher_model.dart';

class OrderModel {
  final String? id;
  final String userId;
  final String orderStatus;
  final String oderFrom;
  final bool paymentStatus;
  final String paymentMethod;
  final DateTime? createdAt;
  final double total;
  final double discount;
  final int? displayId;
  final double discountVoucher;
  final String? voucherId;
  final String? voucherCode;
  final String? pickupTime;
  final VoucherModel? voucher;
  final List<OrderItemModel> orderItems;

  const OrderModel({
    this.id,
    required this.userId,
    this.orderStatus = 'Pending',
    this.oderFrom = 'System',
    this.paymentStatus = false,
    this.paymentMethod = 'CASH',
    this.createdAt,
    required this.total,
    this.discount = 0,
    this.displayId,
    this.discountVoucher = 0,
    this.voucherId,
    this.voucherCode,
    this.pickupTime,
    this.voucher,
    this.orderItems = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'orderStatus': orderStatus,
      'oderFrom': oderFrom,
      'paymentStatus': paymentStatus,
      'paymentMethod': paymentMethod,
      'createdAt': createdAt?.toIso8601String(),
      'total': total,
      'discount': discount,
      'displayId': displayId,
      'discountVoucher': discountVoucher,
      'voucherId': voucherId,
      'voucherCode': voucherCode,
      'pickupTime': pickupTime,
      'voucher': voucher?.toJson(),
      'orderItems': orderItems.map((item) => item.toJson()).toList(),
    };
  }

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'] as String?,
      userId: json['userId'] as String,
      orderStatus: json['orderStatus'] as String? ?? 'Pending',
      oderFrom: json['oderFrom'] as String? ?? 'System',
      paymentStatus: json['paymentStatus'] as bool? ?? false,
      paymentMethod: json['paymentMethod'] as String? ?? 'Cash',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      total: _parseToDouble(json['total']) ?? 0,
      discount: _parseToDouble(json['discount']) ?? 0,
      displayId: json['displayId'] as int?,
      discountVoucher: _parseToDouble(json['discountVoucher']) ?? 0,
      voucherId: json['voucherId'] as String?,
      voucherCode: json['voucherCode'] as String?,
      pickupTime: json['pickupTime'] as String?,
      voucher: json['voucher'] != null
          ? VoucherModel.fromJson(json['voucher'] as Map<String, dynamic>)
          : null,
      orderItems:
          (json['orderItems'] as List<dynamic>?)
              ?.map(
                (item) => OrderItemModel.fromJson(item as Map<String, dynamic>),
              )
              .toList() ??
          [],
    );
  }

  static double? _parseToDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  OrderModel copyWith({
    String? id,
    String? userId,
    String? orderStatus,
    String? oderFrom,
    bool? paymentStatus,
    String? paymentMethod,
    DateTime? createdAt,
    double? total,
    double? discount,
    int? displayId,
    double? discountVoucher,
    String? voucherId,
    String? voucherCode,
    String? pickupTime,
    VoucherModel? voucher,
    List<OrderItemModel>? orderItems,
  }) {
    return OrderModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      orderStatus: orderStatus ?? this.orderStatus,
      oderFrom: oderFrom ?? this.oderFrom,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      createdAt: createdAt ?? this.createdAt,
      total: total ?? this.total,
      discount: discount ?? this.discount,
      displayId: displayId ?? this.displayId,
      discountVoucher: discountVoucher ?? this.discountVoucher,
      voucherId: voucherId ?? this.voucherId,
      voucherCode: voucherCode ?? this.voucherCode,
      pickupTime: pickupTime ?? this.pickupTime,
      voucher: voucher ?? this.voucher,
      orderItems: orderItems ?? this.orderItems,
    );
  }
}
