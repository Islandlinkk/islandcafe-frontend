import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:island_cafe/feature/cart/data/provider/cart_notifier.dart';

final cartTotalProvider = Provider<double>((ref) {
  final cart = ref.watch(cartProvider);
  return cart.fold(0.0, (sum, item) => sum + item.totalPrice);
});
