import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:island_cafe/core/config/api_config.dart';
import 'package:island_cafe/feature/account/service/user_api_service.dart';
import 'package:island_cafe/feature/cart/data/model/cart_model.dart';
import 'package:island_cafe/feature/history/data/model/order_model.dart';

class OrderService {
  static FirebaseFirestore get _firestore => FirebaseFirestore.instance;
  static User? get _currentUser => FirebaseAuth.instance.currentUser;

  /// Generate unique order number
  static String _generateOrderNumber() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = (timestamp % 100000).toString().padLeft(5, '0');
    return '800$timestamp$random';
  }

  /// Create order from cart items
  static Future<OrderModel> createOrder({
    required List<CartModel> cartItems,
    String status = 'pending',
  }) async {
    final user = _currentUser;
    if (user == null) {
      throw Exception('User must be logged in to create an order');
    }

    if (cartItems.isEmpty) {
      throw Exception('Cart is empty');
    }

    // Calculate total
    final totalAmount = cartItems.fold<double>(
      0,
      (sum, item) => sum + item.totalPrice,
    );

    // Convert cart items to order items
    final orderItems = cartItems.map((cartItem) {
      return OrderItem(
        productId: cartItem.productId,
        productName: cartItem.productName,
        quantity: cartItem.quantity,
        price: cartItem.totalPrice,
        size: cartItem.size.name,
        sugar: cartItem.sugar?.name,
        ice: cartItem.ice?.name,
        extraShot: cartItem.extraShot?.name,
        image: cartItem.image,
      );
    }).toList();

    // Create order
    final orderNumber = _generateOrderNumber();
    final order = OrderModel(
      id: '', // Will be set by Firestore
      orderNumber: orderNumber,
      totalAmount: totalAmount,
      orderDate: DateTime.now(),
      status: status,
      items: orderItems,
      userId: user.uid,
    );

    // Save to Firestore
    final docRef = await _firestore.collection('orders').add(order.toFirestore());

    // Return order with Firestore ID
    return OrderModel(
      id: docRef.id,
      orderNumber: order.orderNumber,
      totalAmount: order.totalAmount,
      orderDate: order.orderDate,
      status: order.status,
      items: order.items,
      userId: order.userId,
    );
  }

  /// Get orders for current user
  static Stream<List<OrderModel>> getUserOrders() {
    final user = _currentUser;
    if (user == null) return Stream.value([]);

    // Try with orderBy first (requires composite index)
    // If it fails, fallback to simple where query and sort in memory
    return _firestore
        .collection('orders')
        .where('userId', isEqualTo: user.uid)
        .snapshots()
        .map((snapshot) {
          final orders = snapshot.docs
              .map((doc) => OrderModel.fromFirestore(doc))
              .toList();
          // Sort by orderDate descending in memory
          orders.sort((a, b) => b.orderDate.compareTo(a.orderDate));
          return orders;
        })
        .handleError((error) {
          // If permission denied, return empty list
          print('Error fetching orders: $error');
          return <OrderModel>[];
        });
  }

  /// Update order status
  static Future<void> updateOrderStatus({
    required String orderId,
    required String status,
  }) async {
    await _firestore.collection('orders').doc(orderId).update({
      'status': status,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Get single order by ID
  static Future<OrderModel?> getOrderById(String orderId) async {
    final doc = await _firestore.collection('orders').doc(orderId).get();
    if (!doc.exists) return null;
    return OrderModel.fromFirestore(doc);
  }

  // ==================== API METHODS ====================

  /// Fetch all orders from API
  static Future<List<OrderModel>> fetchAllOrders() async {
    return await fetchOrders();
  }

  /// Fetch orders from API (optionally filtered by userId)
  static Future<List<OrderModel>> fetchOrders({String? userId}) async {
    try {
      final baseUrl = ApiConfig.order;
      final uri = userId != null
          ? Uri.parse('$baseUrl?userId=$userId')
          : Uri.parse(baseUrl);

      print('📤 Fetching orders from: $uri');

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
                'Request timeout: Failed to connect to order API',
              );
            },
          );

      if (response.statusCode == 200) {
        try {
          // Check if response is valid JSON
          final trimmedBody = response.body.trim();
          if (trimmedBody.isEmpty) {
            print('⚠️ Empty response from orders API');
            return [];
          }

          if (!trimmedBody.startsWith('[') && !trimmedBody.startsWith('{')) {
            // Response is not JSON, might be an error message
            print('❌ Invalid response format: ${response.body}');
            throw Exception('Invalid response format: ${response.body}');
          }

          final List<dynamic> jsonList = json.decode(response.body);
          print('✅ Fetched ${jsonList.length} orders from API');
          
          final ordersList = jsonList
              .map(
                (json) {
                  try {
                    return OrderModel.fromJson(json as Map<String, dynamic>);
                  } catch (e) {
                    print('❌ Error parsing order: $e');
                    print('❌ Order data: $json');
                    rethrow;
                  }
                },
              )
              .toList();

          // Sort by orderDate descending (newest first)
          ordersList.sort((a, b) => b.orderDate.compareTo(a.orderDate));

          print('✅ Successfully parsed ${ordersList.length} orders');
          return ordersList;
        } on FormatException catch (e) {
          print('❌ FormatException parsing orders: $e');
          print('❌ Response body: ${response.body}');
          throw Exception('Failed to parse order data: ${response.body}');
        } catch (e) {
          print('❌ Error parsing orders: $e');
          print('❌ Response body: ${response.body}');
          throw Exception('Failed to parse order data: $e');
        }
      } else {
        print('❌ Orders API returned status ${response.statusCode}');
        print('❌ Response body: ${response.body}');
        _handleError(response, 'Failed to fetch orders');
        return [];
      }
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Network error: $e');
    }
  }

  /// Fetch orders by user ID from API
  static Future<List<OrderModel>> fetchOrdersByUserId(String userId) async {
    try {
      // Try with query parameter first (if API supports it)
      return await fetchOrders(userId: userId);
    } catch (e) {
      // Fallback: fetch all and filter in memory
      // This ensures compatibility even if query params aren't supported
      try {
        final allOrders = await fetchOrders();
        final userOrders = allOrders
            .where((order) => order.userId == userId)
            .toList();
        // Sort by orderDate descending
        userOrders.sort((a, b) => b.orderDate.compareTo(a.orderDate));
        return userOrders;
      } catch (fallbackError) {
        throw Exception('Failed to fetch orders: $fallbackError');
      }
    }
  }

  /// Fetch orders for the current logged-in user
  static Future<List<OrderModel>> fetchMyOrders() async {
    final user = _currentUser;
    if (user == null) {
      throw Exception('User must be logged in to fetch orders');
    }

    try {
      // Fetch API user account to get the API user ID
      final apiUserAccount = await UserApiService.getCurrentUserAccount();
      if (apiUserAccount == null) {
        throw Exception('User account not found in API database. Please contact support to set up your account.');
      }

      print('✅ Using API User ID: ${apiUserAccount.id}');
      return await fetchOrdersByUserId(apiUserAccount.id);
    } catch (e) {
      print('❌ Error in fetchMyOrders: $e');
      rethrow;
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
