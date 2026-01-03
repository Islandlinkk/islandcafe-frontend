import 'package:dio/dio.dart';
import 'package:island_cafe/core/config/api_config.dart';
import 'package:island_cafe/feature/voucher/data/model/voucher_model.dart';

class VoucherService {
  final Dio _dio;

  VoucherService(this._dio);

  // 1. Fetch ALL vouchers from the API
  Future<List<VoucherModel>> getVouchers() async {
    try {
      // Ensure ApiConfig.voucher is correct in your config file
      final response = await _dio.get(ApiConfig.voucher);

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => VoucherModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load vouchers: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Error fetching vouchers: $e');
    }
  }

  // 2. Find a SPECIFIC voucher by code (Uses the method above)
  Future<VoucherModel?> findVoucherByCode(String code) async {
    try {
      // We reuse the method above to get the list first
      final allVouchers = await getVouchers();
      
      // Then we search that list
      try {
        return allVouchers.firstWhere(
          (v) => v.code.toLowerCase() == code.toLowerCase(),
        );
      } catch (e) {
        return null; // Return null if not found
      }
    } catch (e) {
      rethrow;
    }
  }
}