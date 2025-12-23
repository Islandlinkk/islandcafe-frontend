import 'package:island_cafe/core/config/api_config.dart';
import 'package:island_cafe/feature/product/data/model/size_model.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SizeService {
  Future<List<SizeModel>> fetchSizes() async {
    final url = Uri.parse(ApiConfig.size);
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => SizeModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load sizes');
    }
  }
}