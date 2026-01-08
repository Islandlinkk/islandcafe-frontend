class OrderItemModel {
  final String orderId;
  final String productId;
  final int quantity;
  final num price;
  final String? note;
  final String? sizeId;
  final String? extraShotId;
  final String? iceId;
  final String? sugarId;

  const OrderItemModel({
    required this.orderId,
    required this.productId,
    this.quantity = 1,
    required this.price,
    this.note,
    this.sizeId,
    this.extraShotId,
    this.iceId,
    this.sugarId,
  });

  Map<String, dynamic> toJson() {
    return {
      'orderId': orderId,
      'productId': productId,
      'quantity': quantity,
      'price': price.toString(),
      'note': note,
      'sizeId': sizeId,
      'extraShotId': extraShotId,
      'iceId': iceId,
      'sugarId': sugarId,
    };
  }

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      orderId: json['orderId'] as String,
      productId: json['productId'] as String,
      quantity: _parseToInt(json['quantity']) ?? 1,
      price: _parseToNumber(json['price']) ?? 0,
      note: json['note'] as String?,
      sizeId: json['sizeId'] as String?,
      extraShotId: json['extraShotId'] as String?,
      iceId: json['iceId'] as String?,
      sugarId: json['sugarId'] as String?,
    );
  }

  static int? _parseToInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    if (value is num) return value.toInt();
    return null;
  }

  static num? _parseToNumber(dynamic value) {
    if (value == null) return null;
    if (value is num) return value;
    if (value is String) {
      final parsed = num.tryParse(value);
      return parsed;
    }
    return null;
  }

  OrderItemModel copyWith({
    String? orderId,
    String? productId,
    int? quantity,
    num? price,
    String? note,
    String? sizeId,
    String? extraShotId,
    String? iceId,
    String? sugarId,
    DateTime? createdAt,
  }) {
    return OrderItemModel(
      orderId: orderId ?? this.orderId,
      productId: productId ?? this.productId,
      quantity: quantity ?? this.quantity,
      price: price ?? this.price,
      note: note ?? this.note,
      sizeId: sizeId ?? this.sizeId,
      extraShotId: extraShotId ?? this.extraShotId,
      iceId: iceId ?? this.iceId,
      sugarId: sugarId ?? this.sugarId,
    );
  }
}
