import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:island_cafe/feature/home/data/billboard_service.dart';
import 'package:island_cafe/feature/home/data/model/billboard.dart';

final billboardProvider = FutureProvider<List<Billboard>>((ref) async {
  final service = BillboardService();
  return service.fetchBillboards();
});

