import 'package:island_cafe/core/config/api_config.dart';
import 'package:island_cafe/feature/product/data/model/extraShot_model.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ExtraShotService {
  Future<List<ExtraShotModel>> fetchExtraShots() async {
    final url = Uri.parse(ApiConfig.extraShot);
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => ExtraShotModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load extra shots');
    }
  }
}