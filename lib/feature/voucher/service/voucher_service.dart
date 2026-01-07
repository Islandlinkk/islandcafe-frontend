import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:island_cafe/core/config/api_config.dart';
import 'package:island_cafe/feature/voucher/data/model/voucher_model.dart';

class VoucherService {
  
  Future<List<VoucherModel>> fetchMyVouchers(String userId) async {
    final url = Uri.parse('${ApiConfig.voucher}/my?userId=$userId');
    final response = await http.get(url, headers: {'Content-Type': 'application/json'});

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((claim) => VoucherModel.fromJson(claim['voucher'])).toList();
    } else {
      throw Exception('Failed to load vouchers');
    }
  }

  Future<void> claimVoucher(String userId, String code) async {
    final url = Uri.parse('${ApiConfig.voucher}/claim?userId=$userId&code=$code');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
    );

    // 1. SUCCESS
    if (response.statusCode == 200 || response.statusCode == 201) {
      return; 
    }
    
    // 2. INVALID CODE (404)
    else if (response.statusCode == 404) {
      throw Exception('Invalid voucher code'); 
    }

    // 3. LOGIC ERROR / LIMIT REACHED (400)
    else if (response.statusCode == 400) {
      try {
        final body = json.decode(response.body);
        final serverMessage = body['message'] ?? body['error'];
        if (serverMessage != null && serverMessage.toString().isNotEmpty) {
           throw Exception(serverMessage); 
        }
      } catch (e) {
        if (e.toString().contains('Exception')) rethrow;
      }
      throw Exception('Voucher limit reached or unavailable');
    }

    // 4. OTHER ERRORS
    else {
      throw Exception('Server Error: ${response.statusCode}');
    }
  }
}