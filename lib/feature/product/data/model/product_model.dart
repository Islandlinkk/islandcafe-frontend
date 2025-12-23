import 'package:island_cafe/feature/product/data/model/category_model.dart';

class ProductModel {
  final String id;
  final String name;
  final String image;
  final double price;
  final int? discount;
  final String description;
  final String categoryId;
  final bool status;
  final DateTime createdAt;
  final CategoryModel category;

  ProductModel({
    required this.id,
    required this.name,
    required this.image,
    required this.price,
    required this.discount,
    required this.description,
    required this.categoryId,
    required this.status,
    required this.createdAt,
    required this.category,
  });

    factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] as String,
      name: json['name'] as String,
      price: double.parse(json['price'].toString()),
      discount: json['discount'] as int,
      image: json['image'] as String,
      description: json['description'] as String,
      categoryId: json['categoryId'] as String,
      status: json['status'] as bool,
      createdAt: DateTime.parse(json['createdAt']),
      category: CategoryModel.fromJson(json['category']),
    );
  }
}