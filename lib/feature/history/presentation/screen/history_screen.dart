import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:island_cafe/feature/auth/services/auth_service.dart';
import 'package:island_cafe/feature/history/data/model/feedback_model.dart';
import 'package:island_cafe/feature/history/data/model/order_model.dart';
import 'package:island_cafe/feature/history/service/feedback_service.dart';
import 'package:island_cafe/feature/theme/loading_screen.dart';
import 'package:go_router/go_router.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});
  //   OrderModel(
  //     id: '1',
  //     orderNumber: '8005470707328249913',
  //     totalAmount: 45.50,
  //     orderDate: DateTime.now().subtract(const Duration(days: 2)),
  //     status: 'completed',
  //     userId: 'mock_user',
  //     items: [
  //       OrderItem(
  //         productId: '1',
  //         productName: 'Cappuccino',
  //         quantity: 2,
  //         price: 12.50,
  //         size: 'Large',
  //       ),
  //       OrderItem(
  //         productId: '2',
  //         productName: 'Latte',
  //         quantity: 1,
  //         price: 10.00,
  //         size: 'Medium',
  //       ),
  //       OrderItem(
  //         productId: '3',
  //         productName: 'Croissant',
  //         quantity: 2,
  //         price: 5.25,
  //       ),
  //     ],
  //   ),
  //   OrderModel(
  //     id: '2',
  //     orderNumber: '8005470707328249914',
  //     totalAmount: 28.75,
  //     orderDate: DateTime.now().subtract(const Duration(days: 5)),
  //     status: 'completed',
  //     userId: 'mock_user',
  //     items: [
  //       OrderItem(
  //         productId: '4',
  //         productName: 'Espresso',
  //         quantity: 1,
  //         price: 8.50,
  //         size: 'Small',
  //       ),
  //       OrderItem(
  //         productId: '5',
  //         productName: 'Muffin',
  //         quantity: 2,
  //         price: 10.125,
  //       ),
  //     ],
  //   ),
  //   OrderModel(
  //     id: '3',
  //     orderNumber: '8005470707328249915',
  //     totalAmount: 15.00,
  //     orderDate: DateTime.now().subtract(const Duration(days: 1)),
  //     status: 'pending',
  //     userId: 'mock_user',
  //     items: [
  //       OrderItem(
  //         productId: '6',
  //         productName: 'Americano',
  //         quantity: 1,
  //         price: 15.00,
  //         size: 'Large',
  //       ),
  //     ],
  //   ),
  // ];

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}
class _HistoryScreenState extends State<HistoryScreen> with AutomaticKeepAliveClientMixin {
  List<FeedbackModel> _feedbackList = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadFeedback();
  }
  void loadFeedback() {
    _loadFeedback();
  }

  @override
  bool get wantKeepAlive => true;

  Future<void> _loadFeedback() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final user = AuthService.currentUser;
      List<FeedbackModel> feedback;

      if (user != null) {
        feedback = await FeedbackService.fetchMyFeedback();
      } else {
        feedback = await FeedbackService.fetchFeedback();
      }
      if (!mounted) return;

      setState(() {
        _feedbackList = feedback;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  // Static mock data for UI display
  static List<OrderModel> get _mockOrders => [
    OrderModel(
      id: '1',
      orderNumber: '8005470707328249913',
      totalAmount: 45.50,
      orderDate: DateTime.now().subtract(const Duration(days: 2)),
      status: 'completed',
      userId: 'mock_user',
      items: [
        OrderItem(
          productId: '1',
          productName: 'Cappuccino',
          quantity: 2,
          price: 12.50,
          size: 'Large',
        ),
        OrderItem(
          productId: '2',
          productName: 'Latte',
          quantity: 1,
          price: 10.00,
          size: 'Medium',
        ),
        OrderItem(
          productId: '3',
          productName: 'Croissant',
          quantity: 2,
          price: 5.25,
        ),
      ],
    ),
  ];

@override
  Widget build(BuildContext context) {
    super.build(context); 

    final orders = _mockOrders;
    
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'History',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.black),
            onPressed: _loadFeedback,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await context.push('/feedback-submission');
          if (result == true) {
            _loadFeedback();
          }
        },
        backgroundColor: const Color(0xFFFF6B6B),
        icon: const Icon(Icons.feedback, color: Colors.white),
        label: const Text(
          'Submit Feedback',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: _isLoading
          ? const LoadingScreen()
          : _errorMessage != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading feedback',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      _errorMessage!,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadFeedback,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            )
          : DefaultTabController(
              length: 2,
              child: Column(
                children: [
                  const TabBar(
                    labelColor: Colors.black,
                    unselectedLabelColor: Colors.grey,
                    indicatorColor: Colors.black,
                    tabs: [
                      Tab(text: 'Orders'),
                      Tab(text: 'Feedback'),
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        // Orders Tab
                        orders.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.shopping_bag_outlined,
                                      size: 64,
                                      color: Colors.grey[400],
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'No orders yet',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Your order history will appear here',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[500],
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : ListView.builder(
                                padding: const EdgeInsets.all(16),
                                itemCount: orders.length,
                                itemBuilder: (context, index) {
                                  return OrderFeedbackCard(
                                    order: orders[index],
                                  );
                                },
                              ),
                        // Feedback Tab
                        _feedbackList.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.feedback_outlined,
                                      size: 64,
                                      color: Colors.grey[400],
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'No feedback yet',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Your feedback submissions will appear here',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[500],
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : RefreshIndicator(
                                onRefresh: _loadFeedback,
                                child: ListView.builder(
                                  padding: const EdgeInsets.all(16),
                                  itemCount: _feedbackList.length,
                                  itemBuilder: (context, index) {
                                    return FeedbackCard(
                                      feedback: _feedbackList[index],
                                    );
                                  },
                                ),
                              ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

class OrderFeedbackCard extends StatelessWidget {
  final OrderModel order;

  const OrderFeedbackCard({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM dd, yyyy • HH:mm');
    final statusColor = order.status == 'completed'
        ? Colors.green
        : order.status == 'pending'
        ? Colors.orange
        : Colors.red;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Order Summary Section
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Order #${order.orderNumber}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            dateFormat.format(order.orderDate),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        order.status.toUpperCase(),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: statusColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Order Items
                ...order.items
                    .take(3)
                    .map(
                      (item) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          children: [
                            Text(
                              '${item.quantity}x',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[700],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                item.productName,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                if (order.items.length > 3)
                  Text(
                    '+ ${order.items.length - 3} more items',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[500],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                const SizedBox(height: 12),
                Text(
                  'Total: \$${order.totalAmount.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Feedback Card Widget to display submitted feedback
class FeedbackCard extends StatelessWidget {
  final FeedbackModel feedback;

  const FeedbackCard({super.key, required this.feedback});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM dd, yyyy • HH:mm');
    final statusColor = feedback.status == 'PENDING'
        ? Colors.orange
        : feedback.status == 'RESOLVED'
        ? Colors.green
        : Colors.grey;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with status and date
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        feedback.category,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        dateFormat.format(feedback.createdAt),
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    feedback.status,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Description
            Text(
              feedback.description,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
                height: 1.5,
              ),
            ),
            // Images if available
            if (feedback.images.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: feedback.images.map((imageUrl) {
                  return GestureDetector(
                    onTap: () {
                      // Show full screen image
                      showDialog(
                        context: context,
                        builder: (context) => Dialog(
                          backgroundColor: Colors.transparent,
                          child: Stack(
                            children: [
                              Center(
                                child: InteractiveViewer(
                                  child: Image.network(
                                    imageUrl,
                                    fit: BoxFit.contain,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        padding: const EdgeInsets.all(32),
                                        color: Colors.grey[200],
                                        child: const Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              Icons.broken_image,
                                              color: Colors.grey,
                                              size: 48,
                                            ),
                                            SizedBox(height: 8),
                                            Text(
                                              'Failed to load image',
                                              style: TextStyle(
                                                color: Colors.grey,
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 40,
                                right: 20,
                                child: IconButton(
                                  icon: const Icon(
                                    Icons.close,
                                    color: Colors.white,
                                    size: 32,
                                  ),
                                  onPressed: () => Navigator.of(context).pop(),
                                  style: IconButton.styleFrom(
                                    backgroundColor: Colors.black54,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          imageUrl,
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              width: 100,
                              height: 100,
                              color: Colors.grey[200],
                              child: Center(
                                child: CircularProgressIndicator(
                                  value:
                                      loadingProgress.expectedTotalBytes != null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                            loadingProgress.expectedTotalBytes!
                                      : null,
                                ),
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: 100,
                              height: 100,
                              color: Colors.grey[200],
                              child: const Icon(
                                Icons.broken_image,
                                color: Colors.grey,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
            // Order info if available
            if (feedback.order?.orderNumber != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.receipt, size: 16, color: Colors.grey),
                    const SizedBox(width: 8),
                    Text(
                      'Order: ${feedback.order!.orderNumber}',
                      style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
