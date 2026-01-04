import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:island_cafe/feature/history/data/model/order_model.dart';
import 'package:island_cafe/feature/history/service/order_service.dart';

/// Provider for user orders
final ordersProvider = StreamProvider<List<OrderModel>>((ref) {
  return OrderService.getUserOrders();
});

/// Provider for creating orders
final orderServiceProvider = Provider<OrderService>((ref) {
  return OrderService();
});