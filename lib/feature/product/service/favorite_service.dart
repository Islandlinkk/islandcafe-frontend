import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:island_cafe/core/config/api_config.dart';
import 'package:island_cafe/feature/product/data/model/favorite_model.dart';

class FavoriteService {
  // Fetch user's favorite products
  Future<List<Favorite>> fetchFavorites(String userId) async {
    final url = Uri.parse(ApiConfig.favoriteById(userId));
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final Map<String, dynamic> body = json.decode(response.body);
      final List<dynamic> data = body['favorites'] as List<dynamic>;
      return data
          .map((item) => Favorite.fromJson(item as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception('Failed to load favorites');
    }
  }

  // Add product to favorites
  Future<void> addFavorite(String userId, String productId) async {
    final url = Uri.parse(
      '${ApiConfig.baseUrl}/favorite?userId=$userId&productId=$productId',
    );
    final response = await http.post(url);

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to add favorite');
    }
  }

  // Remove product from favorites
  Future<void> removeFavorite(String userId, String productId) async {
    final url = Uri.parse(
      '${ApiConfig.baseUrl}/favorite?userId=$userId&productId=$productId',
    );
    final response = await http.delete(url);

    if (response.statusCode != 200 && response.statusCode != 204) {
      final body = json.decode(response.body);
      throw Exception(
        body['error'] ?? body['message'] ?? 'Failed to remove favorite',
      );
    }
  }
}
