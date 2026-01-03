import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
}

