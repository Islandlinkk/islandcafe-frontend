import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:island_cafe/feature/voucher/data/model/voucher_model.dart';
import 'package:island_cafe/feature/voucher/data/provider/voucher_provider.dart';

part 'my_voucher_provider.g.dart';

@riverpod
class MyVouchers extends _$MyVouchers {
  @override
  List<VoucherModel> build() {
    return []; // 1. Start with an empty list
  }

  Future<void> claimVoucher(String code) async {
    // 2. Check if already claimed
    if (state.any((v) => v.code.toLowerCase() == code.toLowerCase())) {
      throw Exception('You have already claimed this voucher!');
    }

    // 3. Call the service to find the voucher
    final service = ref.read(voucherServiceProvider);
    final voucher = await service.findVoucherByCode(code);

    if (voucher == null) {
      throw Exception('Invalid Voucher Code');
    }

    // 4. Add to the list
    state = [...state, voucher];
  }
  
  // Optional: Remove voucher
  void removeVoucher(String id) {
    state = state.where((v) => v.id != id).toList();
  }
}