
import 'package:island_cafe/feature/product/data/model/product_model.dart';

class Favorite {
  ProductModel product;
  String userId;
  Favorite({
    required this.product ,
    required this.userId,
  });
  factory Favorite.fromJson(Map<String, dynamic> json) {
    return Favorite(
      product: ProductModel.fromJson(json['product'] as Map<String, dynamic>),
      userId: json['userId'] as String,
    );
  }
  
}