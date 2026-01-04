import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:island_cafe/feature/auth/presentation/widgets/auth_widgets.dart';
import 'package:island_cafe/feature/history/data/model/order_model.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

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
    OrderModel(
      id: '2',
      orderNumber: '8005470707328249914',
      totalAmount: 28.75,
      orderDate: DateTime.now().subtract(const Duration(days: 5)),
      status: 'completed',
      userId: 'mock_user',
      items: [
        OrderItem(
          productId: '4',
          productName: 'Espresso',
          quantity: 1,
          price: 8.50,
          size: 'Small',
        ),
        OrderItem(
          productId: '5',
          productName: 'Muffin',
          quantity: 2,
          price: 10.125,
        ),
      ],
    ),
    OrderModel(
      id: '3',
      orderNumber: '8005470707328249915',
      totalAmount: 15.00,
      orderDate: DateTime.now().subtract(const Duration(days: 1)),
      status: 'pending',
      userId: 'mock_user',
      items: [
        OrderItem(
          productId: '6',
          productName: 'Americano',
          quantity: 1,
          price: 15.00,
          size: 'Large',
        ),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final orders = _mockOrders;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
        elevation: 0,
        title: Text(
          'History',
          style: TextStyle(
            color: Theme.of(context).textTheme.titleLarge?.color,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: orders.isEmpty
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
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Your order history will appear here',
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).textTheme.bodyMedium?.color,
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
        ? Theme.of(context).colorScheme.primary
        : order.status == 'pending'
        ? Theme.of(context).colorScheme.tertiary
        : Theme.of(context).colorScheme.error;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Theme.of(context).colorScheme.outline, width: 1),
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
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).textTheme.titleLarge?.color,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            dateFormat.format(order.orderDate),
                            style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(context).textTheme.bodyMedium?.color,
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
                        color: statusColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        order.status.toUpperCase(),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.onPrimary,
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
                                color: Theme.of(context).textTheme.bodyMedium?.color,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                item.productName,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Theme.of(context).textTheme.bodyMedium?.color,
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
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                const SizedBox(height: 12),
                Text(
                  'Total: \$${order.totalAmount.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                  ),
                ),
              ],
            ),
          ),

          // Divider
          if (order.status == 'completed') const Divider(height: 1),

          // Feedback Section (only for completed orders)
          if (order.status == 'completed')
            _StaticFeedbackForm(orderNumber: order.orderNumber),
        ],
      ),
    );
  }
}

// Static Feedback Form UI Component
class _StaticFeedbackForm extends StatelessWidget {
  final String orderNumber;

  const _StaticFeedbackForm({required this.orderNumber});

  final List<String> _categories = const [
    'APP Function',
    'Software',
    'Order Delivery',
    'Merchant Cooperation & Entry',
    'Coupon & Red Envelope',
    'Food/Item Quality',
    'Refund',
    'Service Attitude',
    'other',
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Order Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Order',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                  ),
                ),
                Row(
                  children: [
                    Text(
                      orderNumber,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Feedback Category Section
          Text(
            '*Feedback Category',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).textTheme.bodyMedium?.color,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _categories.map((category) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  border: Border.all(color: Colors.grey[300]!, width: 1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  category,
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),

          // Description Section
          Text(
            '*Description',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).textTheme.bodyMedium?.color,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: TextField(
              maxLength: 150,
              maxLines: 6,
              decoration: InputDecoration(
                hintText:
                    'Please describe your issues. For order issues, please contact our Online Customer Service.',
                hintStyle: TextStyle(color: Colors.grey[500], fontSize: 14),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.all(16),
                counterText: '',
              ),
            ),
          ),
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              '0/150',
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
          ),
          const SizedBox(height: 16),

          // Image Upload and Send Button Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image Upload Button
              // The image upload currently does nothing because onTap is empty.
              // To enable image upload, you need to implement image picking logic.
              // For now, this button is just a placeholder and does not upload.
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: InkWell(
                  // No image upload implemented yet
                  onTap: () {
                    // TODO: Implement image upload functionality here.
                    // e.g. use image_picker package to pick image from gallery or camera
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: const Center(
                    child: Icon(Icons.camera_alt, color: Colors.grey, size: 32),
                  ),
                ),
              ),
              const Spacer(),
              // Send Button
              Expanded(
                flex: 2,
                child: CoffeeButton(
                  text: 'SEND',
                  onPressed: () {},
                  backgroundColor: const Color(0xFFFF6B6B),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}