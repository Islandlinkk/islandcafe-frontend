import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:island_cafe/feature/product/data/model/extraShot_model.dart';
import 'package:island_cafe/feature/product/service/extraShot_service.dart';

final extraShotsProvider = FutureProvider.family<List<ExtraShotModel>, String>((ref, productId) async {
  final extraShotService = ExtraShotService();
 final extraShots = await extraShotService.fetchExtraShots();
 return extraShots.where((extraShot) => extraShot.productId == productId).toList();
});