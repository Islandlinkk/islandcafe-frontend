import 'package:island_cafe/feature/checkout/data/model/order_model.dart';
import 'package:island_cafe/feature/checkout/service/order_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'order_provider.g.dart';

// Service Provider
@riverpod
OrderService orderService(Ref ref) {
  return OrderService();
}

// Fetch all orders
@riverpod
Future<List<OrderModel>> orders(Ref ref) async {
  final service = ref.watch(orderServiceProvider);
  return await service.fetchOrders();
}

// Create order notifier
@Riverpod(keepAlive: true)
class OrderCreator extends _$OrderCreator {
  @override
  FutureOr<OrderModel?> build() {
    return null;
  }

  Future<OrderModel> createOrder(OrderModel order) async {
    // Check if ref is still mounted before proceeding
    if (!ref.mounted) {
      throw Exception('Provider has been disposed');
    }

    state = const AsyncValue.loading();

    final service = ref.read(orderServiceProvider);

    state = await AsyncValue.guard(() async {
      final createdOrder = await service.createOrder(order);

      // Only invalidate if ref is still mounted
      if (ref.mounted) {
        ref.invalidate(ordersProvider);
      }

      return createdOrder;
    });

    // Return the created order directly or throw if failed
    if (state.hasValue && state.value != null) {
      return state.value!;
    } else if (state.hasError) {
      throw state.error!;
    } else {
      throw Exception('Failed to create order');
    }
  }
}
