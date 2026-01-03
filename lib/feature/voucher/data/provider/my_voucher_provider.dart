import 'package:hive_ce/hive.dart'; // Using Hive CE
import 'package:island_cafe/feature/voucher/data/model/voucher_model.dart';
import 'package:island_cafe/feature/voucher/data/provider/voucher_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'my_voucher_provider.g.dart';

@riverpod
class MyVouchers extends _$MyVouchers {
  // Reference to the Hive CE Box
  Box get _box => Hive.box('voucher_box');

  @override
  List<VoucherModel> build() {
    // 1. LOAD: Read from database
    final List<dynamic> storedList = _box.get('claimed_vouchers', defaultValue: []);
    
    return storedList
        .map((json) => VoucherModel.fromJson(Map<String, dynamic>.from(json)))
        .toList();
  }

  Future<void> claimVoucher(String code) async {
    // Check for duplicate in local list
    if (state.any((v) => v.code.toLowerCase() == code.toLowerCase())) {
      throw Exception('You have already claimed this voucher!');
    }

    // 2. FETCH: Use the NEW method name 'fetchVoucherByCode'
    final service = ref.read(voucherServiceProvider);
    
    // --- THIS WAS THE ERROR (was findVoucherByCode) ---
    final voucher = await service.fetchVoucherByCode(code); 

    if (voucher == null) {
      throw Exception('Invalid Voucher Code');
    }

    // Add to state
    state = [...state, voucher];

    // 3. SAVE: Save to Hive
    _saveToHive();
  }
  
  void _saveToHive() {
    final List<Map<String, dynamic>> jsonList = 
        state.map((v) => v.toJson()).toList();
    
    _box.put('claimed_vouchers', jsonList);
  }
}