import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class FavoriteService {
  final String baseUrl =
      "https://coffee-shop-system-two.vercel.app/api/favorite";

  Future<List<dynamic>> fetchFavorites(String userId) async {
    try {
      final url = Uri.parse('$baseUrl?userId=$userId');
      final response = await http.get(url);
      
      if (response.statusCode != 200) return [];
      
      final decoded = json.decode(response.body);
      
      // Standardize the response
      if (decoded is List) return decoded;
      if (decoded is Map) {
        if (decoded['data'] is List) return decoded['data'];
        if (decoded['favorites'] is List) return decoded['favorites'];
      }
      return [];
    } catch (e) {
      debugPrint('Fetch Favorites Error: $e');
      return [];
    }
  }

  Future<bool> addFavorite(String userId, String productId) async {
    try {
      final url = Uri.parse('$baseUrl?userId=$userId&productId=$productId');
      debugPrint('[FavoriteService] POST $url');
      final response = await http.post(url);
      debugPrint(
        '[FavoriteService] POST status=${response.statusCode} body=${response.body}',
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      debugPrint('[FavoriteService] POST error: $e');
      return false;
    }
  }

  Future<bool> removeFavorite(String userId, String productId) async {
    try {
      final url = Uri.parse('$baseUrl?userId=$userId&productId=$productId');
      debugPrint('[FavoriteService] DELETE $url');
      final response = await http.delete(url);
      debugPrint(
        '[FavoriteService] DELETE status=${response.statusCode} body=${response.body}',
      );
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('[FavoriteService] DELETE error: $e');
      return false;
    }
  }
}
