import 'package:dio/dio.dart';
import 'package:island_cafe/feature/voucher/data/model/voucher_model.dart';
import 'package:island_cafe/feature/voucher/service/voucher_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'voucher_provider.g.dart';

@riverpod
Dio dio(Ref ref) {
  return Dio();
}

@riverpod
VoucherService voucherService(Ref ref) {
  final dio = ref.watch(dioProvider);
  
  // FIX: Just pass 'dio'. Do not pass 'baseUrl'.
  return VoucherService(dio); 
}

@riverpod
Future<List<VoucherModel>> vouchers(Ref ref) async {
  final service = ref.watch(voucherServiceProvider);
  return service.getVouchers();
}