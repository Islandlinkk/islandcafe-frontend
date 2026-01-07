import 'package:firebase_auth/firebase_auth.dart';
import 'package:island_cafe/feature/voucher/data/model/voucher_model.dart';
import 'package:island_cafe/feature/voucher/data/provider/voucher_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'my_voucher_provider.g.dart';

@riverpod
class MyVouchers extends _$MyVouchers {
  
  @override
  Future<List<VoucherModel>> build() async {
    // 1. Get current User ID
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return []; // Return empty if not logged in

    // 2. Fetch from Server
    final service = ref.watch(voucherServiceProvider);
    return await service.fetchMyVouchers(user.uid);
  }

  Future<void> claimVoucher(String code) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('You must be logged in');

    // 1. Call API
    final service = ref.read(voucherServiceProvider);
    await service.claimVoucher(user.uid, code);

    // 2. Refresh the list automatically
    // This forces build() to run again, fetching the new list from server
    ref.invalidateSelf();
    
    // Wait for the refresh to finish so the UI updates
    await future; 
  }
}