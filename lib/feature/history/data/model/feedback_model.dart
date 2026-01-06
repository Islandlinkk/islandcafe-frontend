class FeedbackModel {
  final String id;
  final String userId;
  final String? orderId;
  final String category;
  final String description;
  final List<String> images;
  final String status; // 'PENDING', 'RESOLVED', etc.
  final String? updatedById;
  final DateTime createdAt;
  final FeedbackUser? user;
  final FeedbackOrder? order;

  FeedbackModel({
    required this.id,
    required this.userId,
    this.orderId,
    required this.category,
    required this.description,
    required this.images,
    required this.status,
    this.updatedById,
    required this.createdAt,
    this.user,
    this.order,
  });

  factory FeedbackModel.fromJson(Map<String, dynamic> json) {
    return FeedbackModel(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      orderId: json['orderId'],
      category: json['category'] ?? '',
      description: json['description'] ?? '',
      images: (json['images'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      status: json['status'] ?? 'PENDING',
      updatedById: json['updatedById'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      user: json['user'] != null
          ? FeedbackUser.fromJson(json['user'])
          : null,
      order: json['order'] != null
          ? FeedbackOrder.fromJson(json['order'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'orderId': orderId,
      'category': category,
      'description': description,
      'images': images,
      'status': status,
      'updatedById': updatedById,
      'createdAt': createdAt.toIso8601String(),
      'user': user?.toJson(),
      'order': order?.toJson(),
    };
  }
}

class FeedbackUser {
  final String id;
  final String name;
  final String? email;
  final String? birthday;
  final String? gender;
  final String? phone;
  final String? photoURL;

  FeedbackUser({
    required this.id,
    required this.name,
    this.email,
    this.birthday,
    this.gender,
    this.phone,
    this.photoURL,
  });

  factory FeedbackUser.fromJson(Map<String, dynamic> json) {
    return FeedbackUser(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'],
      birthday: json['birthday'],
      gender: json['gender'],
      phone: json['phone'],
      photoURL: json['photoURL'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'birthday': birthday,
      'gender': gender,
      'phone': phone,
      'photoURL': photoURL,
    };
  }
}

class FeedbackOrder {
  final String? id;
  final String? orderNumber;
  final double? totalAmount;
  final DateTime? orderDate;
  final String? status;

  FeedbackOrder({
    this.id,
    this.orderNumber,
    this.totalAmount,
    this.orderDate,
    this.status,
  });

  factory FeedbackOrder.fromJson(Map<String, dynamic> json) {
    return FeedbackOrder(
      id: json['id'],
      orderNumber: json['orderNumber'],
      totalAmount: json['totalAmount'] != null
          ? (json['totalAmount'] as num).toDouble()
          : null,
      orderDate: json['orderDate'] != null
          ? DateTime.parse(json['orderDate'])
          : null,
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'orderNumber': orderNumber,
      'totalAmount': totalAmount,
      'orderDate': orderDate?.toIso8601String(),
      'status': status,
    };
  }
}

