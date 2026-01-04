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
      return data.map((claim) => VoucherModel.fromJson(claim['voucher'])).toList();
    } else {
      throw Exception('Failed to load vouchers');
    }
  }

  // 2. CLAIM VOUCHER (THE PROOF DEBUGGER)
  Future<void> claimVoucher(String userId, String code) async {
    final url = Uri.parse('${ApiConfig.voucher}/claim?userId=$userId&code=$code');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      return; 
    }
    else {
      try {
        final body = json.decode(response.body);
        String rawError = body['message'] ?? body['error'] ?? response.body;
        if (rawError.contains('Foreign key constraint') || rawError.contains('VoucherUsage_userId_fkey')) {
          throw Exception(
            'PROOF OF ERROR:\n'
            'The Backend received User ID: "$userId"\n'
            'But rejected it because this ID does NOT exist in the PostgreSQL "User" table.\n'
            '(Prisma Error: Foreign Key Constraint Violated)'
          );
        }
        throw Exception('Backend Error: $rawError');

      } catch (e) {
        if (e.toString().contains('PROOF OF ERROR')) rethrow;
        throw Exception('Server Error (${response.statusCode}): ${response.body}');
      }
    }
  }
}