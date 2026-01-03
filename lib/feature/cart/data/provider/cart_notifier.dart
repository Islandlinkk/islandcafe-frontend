import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
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
  static const String _boxName = 'cart_box';
  Box<CartModel>? _cartBox;

  @override
  CartState build() {
    _initializeBox();
    return [];
  }

  Future<void> _initializeBox() async {
    _cartBox = await Hive.openBox<CartModel>(_boxName);
    state = _cartBox!.values.toList();
  }

  Future<void> _saveToBox() async {
    if (_cartBox != null) {
      await _cartBox!.clear();
      await _cartBox!.addAll(state);
    }
  }

  Future<void> addToCart(CartModel newItem) async {
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
    await _saveToBox();
  }

  Future<void> removeItem(int index) async {
    state = [...state]..removeAt(index);
    await _saveToBox();
  }

  Future<void> clearCart() async {
    state = [];
    await _saveToBox();
  }

  Future<void> updateQuantity(int index, int newQuantity) async {
    if (newQuantity <= 0) {
      await removeItem(index);
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
    await _saveToBox();
  }
}
