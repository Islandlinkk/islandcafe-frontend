import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:island_cafe/feature/history/data/model/feedback_model.dart';
import 'package:island_cafe/feature/history/data/model/order_model.dart';
import 'package:island_cafe/feature/history/data/provider/feedback_provider.dart';
import 'package:island_cafe/feature/theme/loading_screen.dart';

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  // Static mock data for UI display (Orders)
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

    // 1. WATCH THE PROVIDER
    final feedbackAsyncValue = ref.watch(feedbackProvider);
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
            // 2. REFRESH USING RIVERPOD
            onPressed: () => ref.refresh(feedbackProvider),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await context.push<bool>('/feedback-submission');
          if (result == true) {
            ref.invalidate(feedbackProvider);
          }
        },
        backgroundColor: const Color(0xFFFF6B6B),
        icon: const Icon(Icons.feedback, color: Colors.white),
        label: const Text(
          'Submit Feedback',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),

      // 4. USE TAB CONTROLLER
      body: DefaultTabController(
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
                  // TAB 1: ORDERS
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
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: orders.length,
                          itemBuilder: (context, index) {
                            return OrderFeedbackCard(order: orders[index]);
                          },
                        ),

                  // TAB 2: FEEDBACK
                  feedbackAsyncValue.when(
                    loading: () => const LoadingScreen(),
                    error: (error, stack) => Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 64,
                            color: Colors.red[300],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Error loading feedback',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey[600],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(
                              error.toString(),
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Colors.grey),
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () => ref.refresh(feedbackProvider),
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                    data: (feedbackList) {
                      if (feedbackList.isEmpty) {
                        return Center(
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
                            ],
                          ),
                        );
                      }
                      return RefreshIndicator(
                        onRefresh: () async =>
                            ref.refresh(feedbackProvider.future),
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: feedbackList.length,
                          itemBuilder: (context, index) {
                            return FeedbackCard(feedback: feedbackList[index]);
                          },
                        ),
                      );
                    },
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

// Cards
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  feedback.category,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  feedback.status,
                  style: TextStyle(color: statusColor, fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(feedback.description),
            const SizedBox(height: 8),
            Text(
              dateFormat.format(feedback.createdAt),
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }
}
