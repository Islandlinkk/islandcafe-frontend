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

