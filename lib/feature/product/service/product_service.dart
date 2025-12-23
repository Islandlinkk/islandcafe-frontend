import 'dart:convert';

import 'package:island_cafe/core/config/api_config.dart';
import 'package:island_cafe/feature/product/data/model/product_model.dart';
import 'package:http/http.dart' as http;

class ProductService {
  Future<List<ProductModel>> fetchProducts() async {
    final url = Uri.parse(ApiConfig.products);
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => ProductModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load products');
    }
  }

  Future<ProductModel> fetchProductsByProductId(String productId) async {
    final url = Uri.parse(ApiConfig.productById(productId));
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      return ProductModel.fromJson(data);
    } else {
      throw Exception('Failed to load product');
    }
  }
}
