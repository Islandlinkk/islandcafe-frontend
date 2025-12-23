import 'package:island_cafe/feature/product/data/model/product_model.dart';

class SugarModel {
  final String id;
  final String name;
  final String productId;
  final ProductModel product;

  SugarModel({required this.id, required this.name, required this.productId, required this.product});

  factory SugarModel.fromJson(Map<String, dynamic> json) {
    return SugarModel(
      id: json['id'].toString(),
      name: json['name'].toString(),
      productId: json['productId'].toString(),
      product: ProductModel.fromJson(json['product']),
    );
  }
}
