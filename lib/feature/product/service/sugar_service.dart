import 'package:island_cafe/core/config/api_config.dart';
import 'package:island_cafe/feature/product/data/model/sugar_model.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SugarService {
  Future<List<SugarModel>> fetchSugars() async {
    final url = Uri.parse(ApiConfig.sugar);
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => SugarModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load sugars');
    }
  }
}