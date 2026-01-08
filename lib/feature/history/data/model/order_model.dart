import 'package:cloud_firestore/cloud_firestore.dart';

class OrderModel {
  final String id;
  final String orderNumber;
  final double totalAmount;
  final DateTime orderDate;
  final String status; // 'pending', 'completed', 'cancelled'
  final List<OrderItem> items;
  final String userId;

  OrderModel({
    required this.id,
    required this.orderNumber,
    required this.totalAmount,
    required this.orderDate,
    required this.status,
    required this.items,
    required this.userId,
  });

  factory OrderModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return OrderModel(
      id: doc.id,
      orderNumber: data['orderNumber'] ?? '',
      totalAmount: (data['totalAmount'] ?? 0).toDouble(),
      orderDate: (data['orderDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      status: data['status'] ?? 'pending',
      items: (data['items'] as List<dynamic>?)
              ?.map((item) => OrderItem.fromMap(item))
              .toList() ??
          [],
      userId: data['userId'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'orderNumber': orderNumber,
      'totalAmount': totalAmount,
      'orderDate': Timestamp.fromDate(orderDate),
      'status': status,
      'items': items.map((item) => item.toMap()).toList(),
      'userId': userId,
    };
  }

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    // Map API fields to model fields
    // API uses: orderStatus, createdAt, total (string), displayId, orderItems
    final orderStatus = json['orderStatus'] ?? 'pending';
    // Convert orderStatus to lowercase for consistency
    final status = orderStatus.toString().toLowerCase();
    
    return OrderModel(
      id: json['id'] ?? '',
      orderNumber: json['displayId']?.toString() ?? json['orderNumber'] ?? '',
      totalAmount: json['total'] != null
          ? double.tryParse(json['total'].toString()) ?? 0.0
          : (json['totalAmount'] ?? 0).toDouble(),
      orderDate: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : (json['orderDate'] != null
              ? DateTime.parse(json['orderDate'])
              : DateTime.now()),
      status: status,
      items: (json['orderItems'] as List<dynamic>?)
              ?.map((item) => OrderItem.fromJson(item as Map<String, dynamic>))
              .toList() ??
          (json['items'] as List<dynamic>?)
              ?.map((item) => OrderItem.fromMap(item as Map<String, dynamic>))
              .toList() ??
          [],
      userId: json['userId'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'orderNumber': orderNumber,
      'totalAmount': totalAmount,
      'orderDate': orderDate.toIso8601String(),
      'status': status,
      'items': items.map((item) => item.toMap()).toList(),
      'userId': userId,
    };
  }
}

class OrderItem {
  final String productId;
  final String productName;
  final int quantity;
  final double price;
  final String? size;
  final String? sugar;
  final String? ice;
  final String? extraShot;
  final String? image;

  OrderItem({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.price,
    this.size,
    this.sugar,
    this.ice,
    this.extraShot,
    this.image,
  });

  factory OrderItem.fromMap(Map<String, dynamic> map) {
    return OrderItem(
      productId: map['productId'] ?? '',
      productName: map['productName'] ?? '',
      quantity: map['quantity'] ?? 1,
      price: (map['price'] ?? 0).toDouble(),
      size: map['size'],
      sugar: map['sugar'],
      ice: map['ice'],
      extraShot: map['extraShot'],
      image: map['image'],
    );
  }

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    // API structure: productId, quantity, price (string), sizeId, iceId, sugarId, extraShotId
    // Note: API doesn't provide productName, size name, etc. - using IDs or placeholders
    return OrderItem(
      productId: json['productId'] ?? '',
      productName: json['productName'] ?? 'Product', // API doesn't provide this
      quantity: json['quantity'] ?? 1,
      price: json['price'] != null
          ? double.tryParse(json['price'].toString()) ?? 0.0
          : 0.0,
      size: json['sizeId']?.toString() ?? json['size'],
      sugar: json['sugarId']?.toString() ?? json['sugar'],
      ice: json['iceId']?.toString() ?? json['ice'],
      extraShot: json['extraShotId']?.toString() ?? json['extraShot'],
      image: json['image'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'productName': productName,
      'quantity': quantity,
      'price': price,
      if (size != null) 'size': size,
      if (sugar != null) 'sugar': sugar,
      if (ice != null) 'ice': ice,
      if (extraShot != null) 'extraShot': extraShot,
      if (image != null) 'image': image,
    };
  }
}
