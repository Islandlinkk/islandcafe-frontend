import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:island_cafe/feature/home/data/model/billboard_model.dart';

class BillboardService {
  static const _endpoint =
      'https://coffee-shop-system-two.vercel.app/api/billboard';

  Future<List<Billboard>> fetchBillboards() async {
    final url= Uri.parse(_endpoint);
    final response = await http.get(url);
      if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((json) => Billboard.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load billboards');
    }
}
}
