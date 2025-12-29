class CartOption {
  final String id;
  final String name;
  final double? price;

  const CartOption({required this.id, required this.name, this.price});

  double get safePrice => price ?? 0;
}

class CartModel {
  final String productId;
  final String productName;
  final String image;
  final double basePrice;
  final int quantity;

  final CartOption size;
  final CartOption? sugar;
  final CartOption? ice;
  final CartOption? extraShot;

  final int? discount;
  final String? note;

  const CartModel({
    required this.productId,
    required this.productName,
    required this.image,
    required this.basePrice,
    required this.quantity,
    required this.size,
    this.sugar,
    this.ice,
    this.extraShot,
    this.discount,
    this.note,
  });

  double get totalPrice {
    double price = basePrice + size.safePrice + (extraShot?.safePrice ?? 0);

    if (discount != null && discount! > 0) {
      price -= price * (discount! / 100);
    }

    return price * quantity;
  }
}
