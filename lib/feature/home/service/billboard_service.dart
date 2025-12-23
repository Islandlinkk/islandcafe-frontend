import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:island_cafe/core/config/api_config.dart';
import 'package:island_cafe/feature/home/data/model/billboard_model.dart';

class BillboardService {
  Future<List<Billboard>> fetchBillboards() async {
    final url = Uri.parse(ApiConfig.billboard);
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(response.body);
      return jsonList
          .map((json) => Billboard.fromJson(json as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception(
        'Failed to load billboards: ${response.statusCode} - ${response.body}',
      );
    }
  }
}
