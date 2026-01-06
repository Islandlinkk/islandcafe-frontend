import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:island_cafe/core/config/api_config.dart';

class UserSyncService {
  /// CREATE User (POST)
  static Future<void> createUser({
    required String uid,
    required String name,
    required String email,
    String? phone,
    String? gender,
    String? birthday,
    String? photoURL,
  }) async {
    try {
      final url = Uri.parse(ApiConfig.account);
      
      final body = {
        "id": uid,
        "name": name,
        "email": email,
        "phone": phone ?? "",
        "gender": gender ?? "",
        "birthday": birthday ?? "",
        "photoURL": photoURL ?? "",
        "password": "",
      };

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(body),
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        print("API Create Failed: ${response.body}");
      }
    } catch (e) {
      print("Error creating user in API: $e");
    }
  }

  /// UPDATE User (PATCH)
  static Future<void> updateUser({
    required String uid,
    required String name,
    required String email,
    String? phone,
    String? gender,
    String? birthday,
    String? photoURL,
  }) async {
    try {
      final url = Uri.parse(ApiConfig.accountById(uid));
      
      final body = {
        "name": name,
        "email": email,
        "phone": phone ?? "",
        "gender": gender ?? "",
        "birthday": birthday ?? "",
        "photoURL": photoURL ?? "",
        "password": "", 
      };

      final response = await http.patch(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(body),
      );

      if (response.statusCode != 200) {
        print("API Update Failed: ${response.body}");
      }
    } catch (e) {
      print("Error updating user in API: $e");
    }
  }

  /// DELETE User (DELETE)
  static Future<void> deleteUser(String uid) async {
    try {
      final url = Uri.parse(ApiConfig.accountById(uid));
      
      final response = await http.delete(url);

      if (response.statusCode != 200) {
        print("API Delete Failed: ${response.body}");
      }
    } catch (e) {
      print("Error deleting user from API: $e");
    }
  }
}
