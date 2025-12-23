import 'package:island_cafe/feature/product/data/model/product_model.dart';

class IceModel {
  final String id;
  final String name;
  final String productId;
  final ProductModel product;

  IceModel({
    required this.id,
    required this.name,
    required this.productId,
    required this.product,
  });

  factory IceModel.fromJson(Map<String, dynamic> json){
    return IceModel(
      id: json['id'].toString(),
      name: json['name'].toString(),
      productId: json['productId'].toString(),
      product: ProductModel.fromJson(json['product']),
    );
  }
}