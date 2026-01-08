import 'package:island_cafe/feature/checkout/data/model/order_item_model.dart';
import 'package:island_cafe/feature/checkout/service/order_item_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'order_item_provider.g.dart';

// Service Provider
@riverpod
OrderItemService orderItemService(Ref ref) {
  return OrderItemService();
}

// Fetch all order items
@riverpod
Future<List<OrderItemModel>> orderItems(Ref ref) async {
  final service = ref.watch(orderItemServiceProvider);
  return await service.fetchOrderItems();
}

// Create order item notifier
@Riverpod(keepAlive: true)
class OrderItemCreator extends _$OrderItemCreator {
  @override
  FutureOr<OrderItemModel?> build() {
    return null;
  }

  Future<void> createOrderItem(OrderItemModel orderItem) async {
    // Check if ref is still mounted before proceeding
    if (!ref.mounted) {
      throw Exception('Provider has been disposed');
    }

    state = const AsyncValue.loading();

    final service = ref.read(orderItemServiceProvider);

    state = await AsyncValue.guard(() async {
      final createdOrderItem = await service.createOrderItem(orderItem);

      // Only invalidate if ref is still mounted
      if (ref.mounted) {
        ref.invalidate(orderItemsProvider);
      }

      return createdOrderItem;
    });
  }

  Future<void> createMultipleOrderItems(List<OrderItemModel> orderItems) async {
    // Check if ref is still mounted before proceeding
    if (!ref.mounted) {
      throw Exception('Provider has been disposed');
    }

    state = const AsyncValue.loading();

    final service = ref.read(orderItemServiceProvider);

    try {
      for (var i = 0; i < orderItems.length; i++) {
        final orderItem = orderItems[i];

        // Check if ref is still mounted before each operation
        if (!ref.mounted) {
          throw Exception('Provider was disposed during operation');
        }

        await service.createOrderItem(orderItem);
      }

      // Only invalidate if ref is still mounted
      if (ref.mounted) {
        ref.invalidate(orderItemsProvider);
      }

      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }
}
