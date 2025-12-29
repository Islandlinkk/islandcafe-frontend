import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:island_cafe/feature/cart/data/model/cart_model.dart';

typedef CartState = List<CartModel>;

final cartProvider = NotifierProvider<CartNotifier, CartState>(
  CartNotifier.new,
);

bool _isSameItem(CartModel a, CartModel b) {
  return a.productId == b.productId &&
      a.size.id == b.size.id &&
      a.sugar?.id == b.sugar?.id &&
      a.ice?.id == b.ice?.id &&
      a.extraShot?.id == b.extraShot?.id;
}

class CartNotifier extends Notifier<CartState> {
  @override
  CartState build() => [];

  void addToCart(CartModel newItem) {
    final index = state.indexWhere((item) => _isSameItem(item, newItem));

    if (index >= 0) {
      final existing = state[index];

      final updatedItem = CartModel(
        productId: existing.productId,
        productName: existing.productName,
        image: existing.image,
        basePrice: existing.basePrice,
        discount: existing.discount,
        quantity: existing.quantity + newItem.quantity,
        size: existing.size,
        sugar: existing.sugar,
        ice: existing.ice,
        extraShot: existing.extraShot,
        note: existing.note,
      );

      state = [
        ...state.sublist(0, index),
        updatedItem,
        ...state.sublist(index + 1),
      ];
    } else {
      state = [...state, newItem];
    }
  }

  void removeItem(int index) {
    state = [...state]..removeAt(index);
  }

  void clearCart() {
    state = [];
  }

  void updateQuantity(int index, int newQuantity) {
    if (newQuantity <= 0) {
      removeItem(index);
      return;
    }

    final item = state[index];
    final updatedItem = CartModel(
      productId: item.productId,
      productName: item.productName,
      image: item.image,
      basePrice: item.basePrice,
      discount: item.discount,
      quantity: newQuantity,
      size: item.size,
      sugar: item.sugar,
      ice: item.ice,
      extraShot: item.extraShot,
      note: item.note,
    );

    state = [
      ...state.sublist(0, index),
      updatedItem,
      ...state.sublist(index + 1),
    ];
  }
}
