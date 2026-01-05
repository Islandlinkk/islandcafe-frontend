import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:island_cafe/core/config/api_config.dart';
import 'package:island_cafe/feature/account/data/model/user_api_model.dart';

class UserApiService {
  static User? get _currentUser => FirebaseAuth.instance.currentUser;

  /// Fetch account data for the current logged-in user using their email
  static Future<UserApiModel?> getCurrentUserAccount() async {
    final user = _currentUser;
    if (user == null) {
      throw Exception('User must be logged in to fetch account data');
    }

    final email = user.email;
    if (email == null || email.isEmpty) {
      throw Exception('User email is not available');
    }

    return await getUserAccountByEmail(email);
  }

  /// Fetch account data by email from the API
  static Future<UserApiModel?> getUserAccountByEmail(String email) async {
    try {
      final baseUrl = ApiConfig.account;
      final uri = Uri.parse('$baseUrl?email=${Uri.encodeComponent(email)}');

      final response = await http
          .get(
            uri,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          )
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              throw Exception(
                'Request timeout: Failed to connect to account API',
              );
            },
          );

      if (response.statusCode == 200) {
        try {
          final trimmedBody = response.body.trim();
          if (trimmedBody.isEmpty) {
            return null;
          }

          if (!trimmedBody.startsWith('[') && !trimmedBody.startsWith('{')) {
            throw Exception('Invalid response format: ${response.body}');
          }

          // Handle both single object and array response
          final jsonData = json.decode(response.body);
          
          if (jsonData is List) {
            // If API returns an array, take the first item
            if (jsonData.isEmpty) {
              return null;
            }
            return UserApiModel.fromJson(
              jsonData[0] as Map<String, dynamic>,
            );
          } else if (jsonData is Map<String, dynamic>) {
            // If API returns a single object
            return UserApiModel.fromJson(jsonData);
          } else {
            throw Exception('Invalid response format: ${response.body}');
          }
        } on FormatException {
          throw Exception('Failed to parse account data: ${response.body}');
        } catch (e) {
          throw Exception('Failed to parse account data: $e');
        }
      } else if (response.statusCode == 404) {
        // User not found in the API database
        return null;
      } else {
        _handleError(response, 'Failed to fetch account data');
        return null;
      }
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Network error: $e');
    }
  }

  /// Helper method to handle API errors consistently
  static void _handleError(http.Response response, String defaultMessage) {
    // Check if response body is empty
    if (response.body.isEmpty) {
      throw Exception('$defaultMessage (Status: ${response.statusCode})');
    }

    // Try to parse as JSON, but handle plain text errors gracefully
    try {
      // Check if response looks like JSON (starts with { or [)
      final trimmedBody = response.body.trim();
      if (trimmedBody.startsWith('{') || trimmedBody.startsWith('[')) {
        final errorBody = json.decode(response.body);
        final errorMessage =
            errorBody['message'] ?? errorBody['error'] ?? defaultMessage;
        throw Exception(errorMessage);
      } else {
        // Response is plain text (like "Internal Server Error")
        throw Exception('$defaultMessage: ${response.body.trim()}');
      }
    } on FormatException {
      // Response is not valid JSON, treat as plain text error
      throw Exception('$defaultMessage: ${response.body.trim()}');
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception(
        '$defaultMessage: ${response.statusCode} - ${response.body}',
      );
    }
  }
}

