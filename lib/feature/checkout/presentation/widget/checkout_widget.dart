import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:island_cafe/feature/cart/data/provider/cart_notifier.dart';
import 'package:island_cafe/feature/cart/data/provider/cart_total_provider.dart';
import 'package:island_cafe/feature/checkout/data/provider/pickup_time_provider.dart';
import 'package:island_cafe/feature/product/presentation/widget/cart_item_widget.dart';

class CheckoutWidget extends ConsumerWidget {
  const CheckoutWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartProvider);
    final cartTotal = ref.watch(cartTotalProvider);
    final selectedPickupTime = ref.watch(selectedPickupTimeProvider);

    // Dark mode detection
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        // Progress indicator
        _buildProgressIndicator(isDark),
        const SizedBox(height: 24),

        // Main content
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Pickup Time Section
                _buildPickupTimeSection(ref, selectedPickupTime, isDark, context),
                const SizedBox(height: 24),

                // Summary Section
                _buildSummarySection(cart, isDark),
                const SizedBox(height: 16),

                // Subtotal
                _buildSubtotal(cartTotal, isDark),
                const SizedBox(height: 16),

                // Apply Voucher
                _buildApplyVoucher(context),
                const SizedBox(height: 24),

                // Payment Method
                _buildPaymentMethod(isDark, context),
                const SizedBox(height: 24),

                // Frequently Bought Together
                _buildFrequentlyBoughtTogether(isDark),
                const SizedBox(height: 100), // Space for bottom bar
              ],
            ),
          ),
        ),

        // Bottom Total & Checkout Button
        _buildBottomBar(context, cartTotal, isDark),
      ],
    );
  }

  Widget _buildProgressIndicator(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          _buildProgressStep('CART', true, true, isDark),
          _buildProgressLine(true, isDark),
          _buildProgressStep('CHECKOUT', true, true, isDark),
          _buildProgressLine(false, isDark),
          _buildProgressStep('PICKUP', false, true, isDark),
        ],
      ),
    );
  }

  Widget _buildProgressStep(String label, bool isCompleted, bool isActive, bool isDark) {
    return Column(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: isCompleted || isActive
                ? const Color(0xFFFFC107)
                : (isDark ? Colors.grey[700] : Colors.grey[300]),
            shape: BoxShape.circle,
          ),
          child: isCompleted
              ? const Icon(Icons.check, size: 16, color: Colors.white)
              : null,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
            color: isActive
                ? (isDark ? Colors.white : Colors.black)
                : Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildProgressLine(bool isCompleted, bool isDark) {
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.only(bottom: 20),
        color: isCompleted
            ? const Color(0xFFFFC107)
            : (isDark ? Colors.grey[700] : Colors.grey[300]),
      ),
    );
  }

  Widget _buildPickupTimeSection(WidgetRef ref, String selectedTime, bool isDark, BuildContext context) {
    final times = ['Now', '15 min', '30 min', '60 min'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Pickup Time',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).textTheme.titleLarge?.color,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: times.map((time) {
            final isSelected = time == selectedTime;
            return Expanded(
              child: GestureDetector(
                onTap: () =>
                    ref.read(selectedPickupTimeProvider.notifier).state = time,
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Theme.of(context).colorScheme.primaryContainer
                        : (isDark ? Colors.grey[800] : Colors.grey[100]),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFFFFC107)
                          : Colors.transparent,
                      width: 1,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    time,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.normal,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSummarySection(List cart, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Summary',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
        const SizedBox(height: 16),
        ...cart.map((item) {
          final options = [
            item.size.name,
            if (item.sugar != null) item.sugar!.name,
            if (item.ice != null) item.ice!.name,
            if (item.extraShot != null) item.extraShot!.name,
          ].join(', ');

          return CartItemWidget(
            name: item.productName,
            options: options,
            quantity: item.quantity,
            price: item.totalPrice,
            image: item.image,
            index: cart.indexOf(item),
          );
        }),
      ],
    );
  }

  Widget _buildSubtotal(double total, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Subtotal',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
        Text(
          '\$${total.toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
      ],
    );
  }

  Widget _buildApplyVoucher(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // TODO: Implement voucher dialog
      },
      child: Text(
        'Apply Voucher',
        style: TextStyle(
          fontSize: 16,
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildPaymentMethod(bool isDark, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Payment Method',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).textTheme.titleLarge?.color,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? Colors.grey[850] : Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark ? Colors.grey[700]! : Colors.grey[200]!,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: const Color(0xFF4CAF50),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.payments_outlined,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Cash on Pickup',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Pay when you collect your order',
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 24,
                height: 24,
                decoration: const BoxDecoration(
                  color: Color(0xFFFFC107),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, size: 16, color: Colors.white),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFrequentlyBoughtTogether(bool isDark) {
    // Mock data - replace with actual product data
    final recommendations = [
      {'name': 'Iced Caramel Macchiato', 'price': 3.41, 'image': ''},
      {'name': 'Iced Latte', 'price': 2.85, 'image': ''},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Frequently Bought Together',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 180,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: recommendations.length,
            itemBuilder: (context, index) {
              final item = recommendations[index];
              return Container(
                width: 140,
                margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[850] : Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark ? Colors.grey[700]! : Colors.grey[200]!,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 100,
                      decoration: BoxDecoration(
                        color: isDark ? Colors.grey[700] : Colors.grey[300],
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(12),
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.coffee,
                          size: 40,
                          color: isDark ? Colors.grey[500] : Colors.grey,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item['name'] as String,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.white : Colors.black,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '\$${(item['price'] as double).toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.grey[300] : Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBottomBar(BuildContext context, double total, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900] : Colors.white,
        boxShadow: [
          BoxShadow(
            color: (isDark ? Colors.black : Colors.grey),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
                Text(
                  '\$${total.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // TODO: Implement checkout logic
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Processing checkout...',
                        style: TextStyle(
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),
                      duration: const Duration(seconds: 2),
                      backgroundColor: isDark ? Colors.grey[800] : Colors.white,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFC107),
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'CHECK OUT',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
