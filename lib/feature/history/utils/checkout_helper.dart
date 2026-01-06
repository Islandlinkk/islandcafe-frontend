import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:island_cafe/feature/cart/data/provider/cart_notifier.dart';
import 'package:island_cafe/feature/history/service/order_service.dart';

/// Helper function to checkout and create order from cart
Future<Map<String, dynamic>> checkoutCart(WidgetRef ref) async {
  final cartItems = ref.read(cartProvider);
  
  if (cartItems.isEmpty) {
    return {
      'success': false,
      'message': 'Your cart is empty',
    };
  }

  try {
    // Create order from cart
    final order = await OrderService.createOrder(
      cartItems: cartItems,
      status: 'pending', // You can change to 'completed' if payment is immediate
    );

    // Clear cart after successful order creation
    ref.read(cartProvider.notifier).clearCart();

    return {
      'success': true,
      'message': 'Order placed successfully!',
      'order': order,
    };
  } catch (e) {
    return {
      'success': false,
      'message': 'Failed to create order: $e',
    };
  }
}
