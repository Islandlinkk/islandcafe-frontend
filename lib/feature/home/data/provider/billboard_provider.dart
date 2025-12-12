import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:island_cafe/feature/home/service/billboard_service.dart';
import 'package:island_cafe/feature/home/data/model/billboard_model.dart';

final billboardProvider = FutureProvider<List<Billboard>>((ref) async {
  final service = BillboardService();
  final billboards = await service.fetchBillboards();
  final activeBillboards = billboards
      .where((billboard) => billboard.isActive == true)
      .toList();
  return activeBillboards;
});

final billboardHompageProvider = FutureProvider<List<Billboard>>((ref) async {
  final service = BillboardService();
  final billboards = await service.fetchBillboards();
  final activeBillboards = billboards
      .where((billboard) => billboard.isActive == true)
      .take(5)
      .toList();
  return activeBillboards;
});
