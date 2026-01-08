import 'package:hive_ce/hive.dart';

part 'cart_model.g.dart';

@HiveType(typeId: 0)
class CartOption {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final double? price;

  const CartOption({required this.id, required this.name, this.price});

  double get safePrice => price ?? 0;
}

@HiveType(typeId: 1)
class CartModel {
  @HiveField(0)
  final String productId;

  @HiveField(1)
  final String productName;

  @HiveField(2)
  final String image;

  @HiveField(3)
  final double basePrice;

  @HiveField(4)
  final int quantity;

  @HiveField(5)
  final CartOption size;

  @HiveField(6)
  final CartOption? sugar;

  @HiveField(7)
  final CartOption? ice;

  @HiveField(8)
  final CartOption? extraShot;

  @HiveField(9)
  final int? discount;

  @HiveField(10)
  final String? note;

  @HiveField(11)
  final String? sizeId;

  @HiveField(12)
  final String? sugarId;

  @HiveField(13)
  final String? iceId;

  @HiveField(14)
  final String? extraShotId;

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
    this.sizeId,
    this.sugarId,
    this.iceId,
    this.extraShotId,
  });

  double get totalPrice {
    double price = basePrice + size.safePrice;

    // Apply discount to base price + size modifier only
    if (discount != null && discount! > 0) {
      price -= price * (discount! / 100);
    }

    // Add extra shot price (NOT discounted)
    price += (extraShot?.safePrice ?? 0);

    return price * quantity;
  }
}
