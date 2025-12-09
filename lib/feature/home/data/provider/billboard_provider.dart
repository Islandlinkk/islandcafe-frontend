import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:island_cafe/feature/home/service/billboard_service.dart';
import 'package:island_cafe/feature/home/data/model/billboard_model.dart';

final billboardProvider = FutureProvider<List<Billboard>>((ref) async {
  final service = BillboardService();
  return service.fetchBillboards();
});

