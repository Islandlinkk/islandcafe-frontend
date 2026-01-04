import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:island_cafe/core/config/api_config.dart';
import 'package:island_cafe/feature/history/data/model/feedback_model.dart';

class FeedbackService {
  static User? get _currentUser => FirebaseAuth.instance.currentUser;

  static Future<List<FeedbackModel>> fetchFeedback({String? userId}) async {
    try {
      final baseUrl = ApiConfig.feedback;
      final uri = userId != null
          ? Uri.parse('$baseUrl?userId=$userId')
          : Uri.parse(baseUrl);

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
                'Request timeout: Failed to connect to feedback API',
              );
            },
          );

      if (response.statusCode == 200) {
        try {
          // Check if response is valid JSON
          final trimmedBody = response.body.trim();
          if (trimmedBody.isEmpty) {
            return [];
          }

          if (!trimmedBody.startsWith('[') && !trimmedBody.startsWith('{')) {
            // Response is not JSON, might be an error message
            throw Exception('Invalid response format: ${response.body}');
          }

          final List<dynamic> jsonList = json.decode(response.body);
          final feedbackList = jsonList
              .map(
                (json) => FeedbackModel.fromJson(json as Map<String, dynamic>),
              )
              .toList();

          // Sort by createdAt descending (newest first)
          feedbackList.sort((a, b) => b.createdAt.compareTo(a.createdAt));

          return feedbackList;
        } on FormatException {
          throw Exception('Failed to parse feedback data: ${response.body}');
        } catch (e) {
          throw Exception('Failed to parse feedback data: $e');
        }
      } else {
        _handleError(response, 'Failed to fetch feedback');
        return [];
      }
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Network error: $e');
    }
  }

  static Future<List<FeedbackModel>> fetchFeedbackByUserId(
    String userId,
  ) async {
    try {
      // Try with query parameter first (if API supports it)
      return await fetchFeedback(userId: userId);
    } catch (e) {
      // Fallback: fetch all and filter in memory
      // This ensures compatibility even if query params aren't supported
      try {
        final allFeedback = await fetchFeedback();
        final userFeedback = allFeedback
            .where((feedback) => feedback.userId == userId)
            .toList();
        // Sort by createdAt descending
        userFeedback.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        return userFeedback;
      } catch (fallbackError) {
        throw Exception('Failed to fetch feedback: $fallbackError');
      }
    }
  }

  /// Fetch feedback for the current logged-in user
  static Future<List<FeedbackModel>> fetchMyFeedback() async {
    final user = _currentUser;
    if (user == null) {
      throw Exception('User must be logged in to fetch feedback');
    }
    return await fetchFeedbackByUserId(user.uid);
  }

  /// Fetch a single feedback by ID
  static Future<FeedbackModel?> fetchFeedbackById(String feedbackId) async {
    final url = Uri.parse('${ApiConfig.feedback}/$feedbackId');

    final response = await http.get(
      url,
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      try {
        final trimmedBody = response.body.trim();
        if (trimmedBody.isEmpty) {
          return null;
        }
        if (!trimmedBody.startsWith('{') && !trimmedBody.startsWith('[')) {
          throw Exception('Invalid response format: ${response.body}');
        }
        final jsonData = json.decode(response.body) as Map<String, dynamic>;
        return FeedbackModel.fromJson(jsonData);
      } on FormatException {
        throw Exception('Failed to parse feedback data: ${response.body}');
      }
    } else if (response.statusCode == 404) {
      return null;
    } else {
      _handleError(response, 'Failed to fetch feedback');
      return null;
    }
  }

  static Future<FeedbackModel> submitFeedback({
    required String userId,
    String? orderId,
    required String category,
    required String description,
    List<String>? imageUrls,
  }) async {
    final user = _currentUser;
    if (user == null) {
      throw Exception('User must be logged in to submit feedback');
    }

    if (category.isEmpty) {
      throw Exception('Feedback category is required');
    }

    if (description.trim().isEmpty) {
      throw Exception('Feedback description is required');
    }

    try {
      // Construct the API URL
      final url = Uri.parse(ApiConfig.feedback);

      // Prepare request body matching API format
      // Only include orderId if it's not null and not empty
      final requestBody = <String, dynamic>{
        'userId': userId,
        'category': category,
        'description': description.trim(),
        'images': imageUrls ?? [],
      };
      
      // Only add orderId if it's provided and not empty
      if (orderId != null && orderId.isNotEmpty) {
        requestBody['orderId'] = orderId;
      }

      // Debug: Print request details (remove in production)
      print('Submitting feedback to: $url');
      print('Request body: ${json.encode(requestBody)}');

      final response = await http
          .post(
            url,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: json.encode(requestBody),
          )
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              throw Exception('Request timeout: Failed to submit feedback');
            },
          );

      // Debug: Print response details
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        try {
          // API may return the created feedback object or just success
          if (response.body.isNotEmpty) {
            final trimmedBody = response.body.trim();
            // Check if response is valid JSON
            if (trimmedBody.startsWith('{') || trimmedBody.startsWith('[')) {
              final jsonData = json.decode(response.body);
              // Handle both single object and array response
              if (jsonData is List && jsonData.isNotEmpty) {
                return FeedbackModel.fromJson(
                  jsonData[0] as Map<String, dynamic>,
                );
              } else if (jsonData is Map<String, dynamic>) {
                return FeedbackModel.fromJson(jsonData);
              }
            } else {
              // Response is not JSON, but status is success
              // This might mean the API accepted the request but returned plain text
              // Create a minimal feedback model to return
              throw Exception(
                'Feedback submitted but received invalid response format: ${response.body}',
              );
            }
          }
          // If no response body, throw exception as we need to return FeedbackModel
          throw Exception(
            'Feedback submitted but no response data received from server',
          );
        } on FormatException {
          // If response is not valid JSON but status is 200/201
          throw Exception(
            'Feedback submitted but received invalid response format: ${response.body}',
          );
        } catch (e) {
          if (e is Exception && e.toString().contains('Feedback submitted')) {
            rethrow;
          }
          throw Exception(
            'Feedback submitted but failed to parse response: $e',
          );
        }
      } else {
        // Handle error responses (4xx, 5xx)
        _handleError(response, 'Failed to submit feedback');
        throw Exception('Failed to submit feedback');
      }
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Network error while submitting feedback: $e');
    }
  }

  /// Update feedback status (if API supports it)
  static Future<void> updateFeedbackStatus({
    required String feedbackId,
    required String status,
  }) async {
    final url = Uri.parse('${ApiConfig.feedback}/$feedbackId');

    final response = await http.patch(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'status': status}),
    );

    if (response.statusCode == 200 || response.statusCode == 204) {
      return;
    } else {
      _handleError(response, 'Failed to update feedback status');
    }
  }

  /// Delete feedback (if API supports it)
  static Future<void> deleteFeedback(String feedbackId) async {
    final url = Uri.parse('${ApiConfig.feedback}/$feedbackId');

    final response = await http.delete(
      url,
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200 || response.statusCode == 204) {
      return;
    } else {
      _handleError(response, 'Failed to delete feedback');
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
