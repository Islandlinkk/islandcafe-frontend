import 'package:island_cafe/feature/product/data/model/product_model.dart';

class SizeModel {
  final String id;
  final String sizeName;
  final double priceModifier;
  final double fullPrice;
  final String productId;
  final ProductModel product;

  SizeModel({
    required this.id,
    required this.sizeName,
    required this.priceModifier,
    required this.fullPrice,
    required this.productId,
    required this.product,
  });

  factory SizeModel.fromJson(Map<String, dynamic> json) {
    return SizeModel(
      id: json['id'].toString(),
      sizeName: json['sizeName'].toString(),
      priceModifier: double.parse(json['priceModifier'].toString()),
      fullPrice: double.parse(json['fullPrice'].toString()),
      productId: json['productId'].toString(),
      product: ProductModel.fromJson(json['product']),
    );
  }
}
