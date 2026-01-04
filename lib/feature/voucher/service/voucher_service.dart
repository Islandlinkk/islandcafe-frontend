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
    // 1. Construct URL (Params in URL as required by your API)
    final url = Uri.parse('${ApiConfig.voucher}/claim?userId=$userId&code=$code');

    print('--------------- DEBUG START ---------------');
    print('1. Firebase User ID: $userId');
    print('2. Voucher Code: $code');
    print('3. Calling API URL: $url');
    print('-------------------------------------------');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
    );

    print('4. Backend Response Code: ${response.statusCode}');
    print('5. Backend Response Body: ${response.body}');
    print('--------------- DEBUG END -----------------');

    // SUCCESS CASE
    if (response.statusCode == 200 || response.statusCode == 201) {
      return; 
    } 
    
    // ERROR ANALYSIS
    else {
      try {
        final body = json.decode(response.body);
        String rawError = body['message'] ?? body['error'] ?? response.body;

        // --- THE EVIDENCE LOGIC ---
        if (rawError.contains('Foreign key constraint') || rawError.contains('VoucherUsage_userId_fkey')) {
          // This specific error PROVES the ID was sent, but DB rejected it.
          throw Exception(
            'PROOF OF ERROR:\n'
            'The Backend received User ID: "$userId"\n'
            'But rejected it because this ID does NOT exist in the PostgreSQL "User" table.\n'
            '(Prisma Error: Foreign Key Constraint Violated)'
          );
        }

        // Other errors (Wrong code, etc.)
        throw Exception('Backend Error: $rawError');

      } catch (e) {
        // If the custom message above was thrown, rethrow it so UI sees it
        if (e.toString().contains('PROOF OF ERROR')) rethrow;
        throw Exception('Server Error (${response.statusCode}): ${response.body}');
      }
    }
  }
}