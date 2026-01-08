import 'dart:convert';

import 'package:island_cafe/core/config/api_config.dart';
import 'package:island_cafe/feature/checkout/data/model/order_item_model.dart';
import 'package:http/http.dart' as http;

class OrderItemService {
  Future<List<OrderItemModel>> fetchOrderItems() async {
    final url = Uri.parse(ApiConfig.orderItem);
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(response.body);
      return jsonList
          .map((json) => OrderItemModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception(
        'Failed to load order items: ${response.statusCode} - ${response.body}',
      );
    }
  }

  Future<OrderItemModel> createOrderItem(OrderItemModel orderItem) async {
    final url = Uri.parse(ApiConfig.orderItem);

    try {
      final jsonData = orderItem.toJson();

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(jsonData),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Don't parse the response, just return the original orderItem
        // because we don't need the server's response data
        return orderItem;
      } else {
        throw Exception(
          'Failed to create order item: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e, stackTrace) {
      print('Error creating order item: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }
}
