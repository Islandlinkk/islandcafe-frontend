import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:island_cafe/core/config/api_config.dart';

class UserSyncService {
  /// Syncs user data (Create or Update) to external API
  static Future<void> syncUser({
    required String name,
    required String email,
    String? phone, // Default empty if not available (e.g. Google Auth)
    String? gender,
    String? birthday,
  }) async {
    try {
      final url = Uri.parse(ApiConfig.account);
      
      final body = {
        "name": name,
        "email": email,
        "phone": phone ?? "", // Send empty if not available (e.g. Google Auth)
        "gender": gender ?? "",
        "birthday": birthday ?? "",
      };

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(body),
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        return Future.error("Failed to sync user: ${response.body}");
      }
    } catch (e) {
      return Future.error("Error syncing user data: $e");
    }
  }

  /// Deletes user from external API
  static Future<void> deleteUser(String email) async {
    try {
      // Assuming DELETE endpoint uses email or ID in the query or body
      // Adjust this URL structure based on your specific backend requirements
      // Example: DELETE .../api/account?email=john@example.com
      final url = Uri.parse('${ApiConfig.account}?email=$email');
      
      final response = await http.delete(url);

      if (response.statusCode != 200) {
        return Future.error("Failed to delete user from API: ${response.body}");
      }
    } catch (e) {
      return Future.error("Error deleting user from API: $e");
    }
  }
}