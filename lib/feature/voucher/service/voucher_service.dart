import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:island_cafe/core/config/api_config.dart';
import 'package:island_cafe/feature/voucher/data/model/voucher_model.dart';

class VoucherService {
  // 1. GET MY VOUCHERS (Standard)
  Future<List<VoucherModel>> fetchMyVouchers(String userId) async {
    final url = Uri.parse('${ApiConfig.voucher}/my?userId=$userId');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data
          .where((claim) => claim['voucher'] != null)
          .map(
            (claim) =>
                VoucherModel.fromJson(claim['voucher'] as Map<String, dynamic>),
          )
          .toList();
    } else {
      throw Exception('Failed to load vouchers');
    }
  }

  // 2. CLAIM VOUCHER (THE PROOF DEBUGGER)
  Future<void> claimVoucher(String userId, String code) async {
    final url = Uri.parse(
      '${ApiConfig.voucher}/claim?userId=$userId&code=$code',
    );

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      return;
    } else {
      final body = json.decode(response.body);
      throw Exception(
        body['error'] ?? body['message'] ?? 'Failed to claim voucher',
      );
    }
  }
}
