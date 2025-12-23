import 'package:island_cafe/feature/product/data/model/product_model.dart';

class ExtraShotModel {
  final String id;
  final String name;
  final double priceModifier;
  final String productId;
  final ProductModel product;

  ExtraShotModel({
    required this.id,
    required this.name,
    required this.priceModifier,
    required this.productId,
    required this.product,
  });

  factory ExtraShotModel.fromJson(Map<String, dynamic> json){
    return ExtraShotModel(
      id: json['id'].toString(),
      name: json['name'].toString(),
      priceModifier: double.parse(json['priceModifier'].toString()),
      productId: json['productId'].toString(),
      product: ProductModel.fromJson(json['product']),
    );
  }
}