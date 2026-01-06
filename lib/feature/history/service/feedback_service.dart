import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:island_cafe/core/config/api_config.dart';
import 'package:island_cafe/feature/history/data/model/feedback_model.dart';
import 'package:island_cafe/feature/account/service/user_api_service.dart';

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

    // Fetch API user account to get the API user ID
    final apiUserAccount = await UserApiService.getCurrentUserAccount();
    if (apiUserAccount == null) {
      throw Exception('User account not found in API database');
    }

    return await fetchFeedbackByUserId(apiUserAccount.id);
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
      // Fetch API user account to get the API user ID
      final apiUserAccount = await UserApiService.getCurrentUserAccount();
      if (apiUserAccount == null) {
        throw Exception('User account not found in API database. Please contact support to set up your account.');
      }

      final apiUserId = apiUserAccount.id;
      print('✅ Using API User ID: $apiUserId');

      // Construct the API URL
      final url = Uri.parse(ApiConfig.feedback);

      // Prepare request body matching API format
      final requestBody = <String, dynamic>{
        'userId': apiUserId,
        'orderId': orderId ?? '',
        'category': category,
        'description': description.trim(),
        'status': 'PENDING',
      };
      
      // Only include images if provided
      if (imageUrls != null && imageUrls.isNotEmpty) {
        requestBody['images'] = imageUrls;
      }

      // Debug: Print request details
      print('📤 Submitting feedback to: $url');
      print('📦 Request body: ${json.encode(requestBody)}');
      print('👤 User ID: $userId');

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
      print('📥 Response status: ${response.statusCode}');
      print('📥 Response body: ${response.body}');

      // Handle SUCCESS responses (200, 201)
      if (response.statusCode == 200 || response.statusCode == 201) {
        try {
          print('✅ Feedback submission successful!');
          
          // API may return the created feedback object or just success
          if (response.body.isNotEmpty) {
            final trimmedBody = response.body.trim();
            // Check if response is valid JSON
            if (trimmedBody.startsWith('{') || trimmedBody.startsWith('[')) {
              final jsonData = json.decode(response.body);
              // Handle both single object and array response
              if (jsonData is List && jsonData.isNotEmpty) {
                final feedbackModel = FeedbackModel.fromJson(
                  jsonData[0] as Map<String, dynamic>,
                );
                print('✅ Feedback created with ID: ${feedbackModel.id}');
                return feedbackModel;
              } else if (jsonData is Map<String, dynamic>) {
                final feedbackModel = FeedbackModel.fromJson(jsonData);
                print('✅ Feedback created with ID: ${feedbackModel.id}');
                return feedbackModel;
              }
            } else {
              // Response is not JSON, but status is success
              print('⚠️ Success but invalid response format: ${response.body}');
              throw Exception(
                'Feedback submitted successfully but received invalid response format',
              );
            }
          }
          // If no response body, throw exception as we need to return FeedbackModel
          print('⚠️ Success but no response data received');
          throw Exception(
            'Feedback submitted successfully but no response data received from server',
          );
        } on FormatException catch (e) {
          // If response is not valid JSON but status is 200/201
          print('❌ Failed to parse success response: $e');
          throw Exception(
            'Feedback submitted successfully but failed to parse response: ${response.body}',
          );
        } catch (e) {
          if (e is Exception && e.toString().contains('Feedback submitted')) {
            rethrow;
          }
          print('❌ Error processing success response: $e');
          throw Exception(
            'Feedback submitted successfully but failed to process response: $e',
          );
        }
      } 
      // Handle FAILURE responses (4xx, 5xx)
      else {
        print('❌ Feedback submission failed with status: ${response.statusCode}');
        
        // Get detailed error message
        String errorMessage = 'Failed to submit feedback';
        String errorType = 'UNKNOWN_ERROR';
        
        try {
          final trimmedBody = response.body.trim();
          if (trimmedBody.isNotEmpty) {
            if (trimmedBody.startsWith('{') || trimmedBody.startsWith('[')) {
              final errorBody = json.decode(response.body);
              errorMessage = errorBody['message'] ?? 
                           errorBody['error'] ?? 
                           errorBody['details'] ?? 
                           'Server error (${response.statusCode})';
            } else {
              errorMessage = trimmedBody;
            }
          } else {
            errorMessage = 'Server error (${response.statusCode})';
          }
          
          // Categorize error types for better handling
          if (response.statusCode == 400) {
            errorType = 'BAD_REQUEST';
            // Check for foreign key constraint errors (user ID doesn't exist)
            if (errorMessage.toLowerCase().contains('foreign key') ||
                errorMessage.toLowerCase().contains('userid') ||
                errorMessage.toLowerCase().contains('user id')) {
              errorMessage = 'User account not found in system. Please contact support to set up your account.';
              errorType = 'USER_NOT_FOUND';
            }
          } else if (response.statusCode == 401) {
            errorType = 'UNAUTHORIZED';
            errorMessage = 'Authentication failed. Please log in again.';
          } else if (response.statusCode == 403) {
            errorType = 'FORBIDDEN';
            errorMessage = 'Access denied. You do not have permission to submit feedback.';
          } else if (response.statusCode == 404) {
            errorType = 'NOT_FOUND';
            errorMessage = 'Feedback service not found. Please contact support.';
          } else if (response.statusCode == 422) {
            errorType = 'VALIDATION_ERROR';
            errorMessage = 'Invalid feedback data. Please check your input and try again.';
          } else if (response.statusCode >= 500) {
            errorType = 'SERVER_ERROR';
            errorMessage = 'Server error occurred. Please try again later or contact support.';
          }
        } catch (e) {
          errorMessage = 'Server error (${response.statusCode}): ${response.body}';
          errorType = 'PARSE_ERROR';
        }
        
        print('❌ Error type: $errorType');
        print('❌ Error message: $errorMessage');
        print('❌ Status code: ${response.statusCode}');
        print('❌ Full response: ${response.body}');
        
        throw Exception('[$errorType] $errorMessage');
      }
    } catch (e) {
      // Handle different types of errors
      if (e is Exception) {
        // Check if it's already a formatted error with error type
        final errorString = e.toString();
        if (errorString.contains('[') && errorString.contains(']')) {
          // Already formatted error, rethrow as is
          rethrow;
        }
        
        // Categorize network/connection errors
        if (errorString.toLowerCase().contains('timeout') ||
            errorString.toLowerCase().contains('socket') ||
            errorString.toLowerCase().contains('network') ||
            errorString.toLowerCase().contains('connection')) {
          print('❌ Network error: $e');
          throw Exception('[NETWORK_ERROR] Network connection failed. Please check your internet connection and try again.');
        }
        
        // Categorize authentication errors
        if (errorString.toLowerCase().contains('user account not found') ||
            errorString.toLowerCase().contains('user must be logged in') ||
            errorString.toLowerCase().contains('authentication')) {
          print('❌ Authentication error: $e');
          rethrow; // Keep original message
        }
        
        // Re-throw other exceptions as-is
        rethrow;
      }
      
      // Handle non-Exception errors
      print('❌ Unexpected error type: ${e.runtimeType}');
      print('❌ Error: $e');
      throw Exception('[UNEXPECTED_ERROR] An unexpected error occurred: $e');
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
