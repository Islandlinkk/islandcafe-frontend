import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:island_cafe/feature/home/data/model/billboard.dart';

class BillboardService {
  static const _endpoint =
      'https://coffee-shop-system-two.vercel.app/api/billboard';

  Future<List<Billboard>> fetchBillboards() async {
    final response = await http.get(Uri.parse(_endpoint));
    if (response.statusCode != 200) {
      throw Exception('Failed to load billboards');
    }
    final List<dynamic> rawList = jsonDecode(response.body) as List<dynamic>;
    return rawList
        .map((e) => Billboard.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
