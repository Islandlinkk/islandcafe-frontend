import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:island_cafe/core/config/api_config.dart';
import 'package:island_cafe/feature/voucher/data/model/voucher_model.dart';

class VoucherService {
  // Matches 'ProductService': No constructor, no 'http.Client' injection needed.
  
  Future<List<VoucherModel>> fetchVouchers() async {
    final url = Uri.parse(ApiConfig.voucher); // Ensure ApiConfig has .voucher
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => VoucherModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load vouchers');
    }
  }

  // Matches 'fetchProductsByProductId' style
  Future<VoucherModel?> fetchVoucherByCode(String code) async {
    // Since your API doesn't have a direct "find by code" endpoint yet,
    // we fetch all and filter locally (keeping the logic, but changing the syntax)
    try {
      final allVouchers = await fetchVouchers();
      return allVouchers.firstWhere(
        (v) => v.code.toLowerCase() == code.toLowerCase(),
      );
    } catch (e) {
      return null; 
    }
  }
}