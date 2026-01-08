import 'dart:convert';

import 'package:island_cafe/core/config/api_config.dart';
import 'package:island_cafe/feature/checkout/data/model/order_model.dart';
import 'package:http/http.dart' as http;

class OrderService {
  Future<List<OrderModel>> fetchOrders() async {
    final url = Uri.parse(ApiConfig.order);
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(response.body);
      return jsonList
          .map((json) => OrderModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception(
        'Failed to load orders: ${response.statusCode} - ${response.body}',
      );
    }
  }

  Future<OrderModel> createOrder(OrderModel order) async {
    final url = Uri.parse(ApiConfig.order);
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(order.toJson()),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final jsonResponse = json.decode(response.body);
      return OrderModel.fromJson(jsonResponse as Map<String, dynamic>);
    } else {
      throw Exception(
        'Failed to create order: ${response.statusCode} - ${response.body}',
      );
    }
  }
}
