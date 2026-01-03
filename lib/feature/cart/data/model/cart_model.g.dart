// GENERATED CODE - Hive Type Adapters
// This file provides Hive adapters for cart persistence

part of 'cart_model.dart';

class CartOptionAdapter extends TypeAdapter<CartOption> {
  @override
  final int typeId = 0;

  @override
  CartOption read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CartOption(
      id: fields[0] as String,
      name: fields[1] as String,
      price: fields[2] as double?,
    );
  }

  @override
  void write(BinaryWriter writer, CartOption obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.price);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CartOptionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class CartModelAdapter extends TypeAdapter<CartModel> {
  @override
  final int typeId = 1;

  @override
  CartModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CartModel(
      productId: fields[0] as String,
      productName: fields[1] as String,
      image: fields[2] as String,
      basePrice: fields[3] as double,
      quantity: fields[4] as int,
      size: fields[5] as CartOption,
      sugar: fields[6] as CartOption?,
      ice: fields[7] as CartOption?,
      extraShot: fields[8] as CartOption?,
      discount: fields[9] as int?,
      note: fields[10] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, CartModel obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.productId)
      ..writeByte(1)
      ..write(obj.productName)
      ..writeByte(2)
      ..write(obj.image)
      ..writeByte(3)
      ..write(obj.basePrice)
      ..writeByte(4)
      ..write(obj.quantity)
      ..writeByte(5)
      ..write(obj.size)
      ..writeByte(6)
      ..write(obj.sugar)
      ..writeByte(7)
      ..write(obj.ice)
      ..writeByte(8)
      ..write(obj.extraShot)
      ..writeByte(9)
      ..write(obj.discount)
      ..writeByte(10)
      ..write(obj.note);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CartModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
