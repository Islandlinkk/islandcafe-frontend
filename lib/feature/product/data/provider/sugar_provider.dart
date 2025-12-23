import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:island_cafe/feature/product/data/model/sugar_model.dart';
import 'package:island_cafe/feature/product/service/sugar_service.dart';

final sugarsProvider = FutureProvider.family<List<SugarModel>, String>((ref, productId) async {
  final sugarService = SugarService();
  final sugars = await sugarService.fetchSugars();
  return sugars.where((sugar) => sugar.productId == productId).toList();
});
