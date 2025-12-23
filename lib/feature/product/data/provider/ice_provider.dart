
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:island_cafe/feature/product/data/model/ice_model.dart';
import 'package:island_cafe/feature/product/service/ice_service.dart';

final icesProvider = FutureProvider.family<List<IceModel>, String>((ref, productId) async {
  final iceService = IceService();
 final ices = await iceService.fetchIces();
 return ices.where((ice) => ice.productId == productId).toList();
});