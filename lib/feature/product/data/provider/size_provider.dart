import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:island_cafe/feature/product/data/model/size_model.dart';
import 'package:island_cafe/feature/product/service/size_service.dart';

final sizesProvider =
    FutureProvider.family<List<SizeModel>, String>((ref, productId) async {
  final sizeService = SizeService();
  final sizes = await sizeService.fetchSizes();
  return sizes.where((size)=>size.productId == productId).toList();
});
