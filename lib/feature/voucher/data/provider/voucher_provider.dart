import 'package:island_cafe/feature/voucher/data/model/voucher_model.dart';
import 'package:island_cafe/feature/voucher/service/voucher_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';


part 'voucher_provider.g.dart';

// 1. We don't need to provide Dio or HttpClient anymore.

@riverpod
VoucherService voucherService(Ref ref) {
  return VoucherService();
}

@riverpod
Future<List<VoucherModel>> vouchers(Ref ref) async {
  final service = ref.watch(voucherServiceProvider);
  return service.fetchVouchers();
}