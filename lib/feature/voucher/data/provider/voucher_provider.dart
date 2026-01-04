import 'package:island_cafe/feature/voucher/service/voucher_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'voucher_provider.g.dart';

@riverpod
VoucherService voucherService(Ref ref) {
  return VoucherService();
}