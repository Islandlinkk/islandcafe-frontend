import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:island_cafe/feature/cart/data/provider/cart_notifier.dart';
import 'package:island_cafe/feature/voucher/data/model/voucher_model.dart';

// Selected voucher state
final selectedVoucherProvider = StateProvider<VoucherModel?>((ref) => null);

// Cart subtotal (before voucher)
final cartTotalProvider = Provider<double>((ref) {
  final cart = ref.watch(cartProvider);
  return cart.fold(0.0, (sum, item) => sum + item.totalPrice);
});

// Cart total with voucher discount applied
final cartTotalWithVoucherProvider = Provider<double>((ref) {
  final subtotal = ref.watch(cartTotalProvider);
  final voucher = ref.watch(selectedVoucherProvider);

  if (voucher == null) return subtotal;

  // Check minimum order value
  final minOrder = voucher.minOrderValue?.toDouble();
  if (minOrder != null && subtotal < minOrder) {
    return subtotal; // Don't apply if below minimum
  }

  // Calculate discount
  final discountValue = (voucher.discountValue ?? 0).toDouble();
  double discount = 0;
  if (voucher.discountType.toUpperCase() == 'PERCENT') {
    discount = subtotal * (discountValue / 100);
  } else {
    discount = discountValue;
  }

  final total = subtotal - discount;
  return total < 0 ? 0 : total; // Don't go below 0
});

// Voucher discount amount
final voucherDiscountAmountProvider = Provider<double>((ref) {
  final subtotal = ref.watch(cartTotalProvider);
  final total = ref.watch(cartTotalWithVoucherProvider);
  return subtotal - total;
});
