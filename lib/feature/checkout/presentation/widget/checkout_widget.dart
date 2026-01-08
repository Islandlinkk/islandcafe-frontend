import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:island_cafe/feature/cart/data/provider/cart_notifier.dart';
import 'package:island_cafe/feature/cart/data/provider/cart_total_provider.dart';
import 'package:island_cafe/feature/checkout/data/provider/pickup_time_provider.dart';
import 'package:island_cafe/feature/product/presentation/widget/cart_item_widget.dart';
import 'package:island_cafe/feature/theme/app_theme.dart';

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
        _buildProgressIndicator(context),
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
                _buildSummarySection(cart, isDark, context),
                const SizedBox(height: 16),

                // Subtotal
                _buildSubtotal(cartTotal, isDark, context),
                const SizedBox(height: 16),

                // Apply Voucher
                _buildApplyVoucher(context),
                const SizedBox(height: 24),

                // Payment Method
                _buildPaymentMethod(isDark, context),
                const SizedBox(height: 24),

                // Frequently Bought Together
                _buildFrequentlyBoughtTogether(isDark, context),
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

  Widget _buildProgressIndicator(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          _buildProgressStep('CART', true, true, isDark, context),
          _buildProgressLine(true, isDark, context),
          _buildProgressStep('CHECKOUT', true, true, isDark, context),
          _buildProgressLine(false, isDark, context),
          _buildProgressStep('PICKUP', false, true, isDark, context),
        ],
      ),
    );
  }

  Widget _buildProgressStep(String label, bool isCompleted, bool isActive, bool isDark, BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final appColors = theme.appColors;
    return Column(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: isCompleted || isActive
                ? appColors.progressActive
                : colors.surfaceContainerHighest,
            shape: BoxShape.circle,
          ),
          child: isCompleted
              ? Icon(Icons.check, size: 16, color: colors.onPrimary)
              : null,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
            color: isActive
                ? colors.onSurface
                : colors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildProgressLine(bool isCompleted, bool isDark, BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final appColors = theme.appColors;
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.only(bottom: 20),
        color: isCompleted
            ? appColors.progressActive
            : colors.surfaceContainerHighest,
      ),
    );
  }

  Widget _buildPickupTimeSection(WidgetRef ref, String selectedTime, bool isDark, BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final appColors = theme.appColors;
    final times = ['Now', '15 min', '30 min', '60 min'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Pickup Time',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: colors.onSurface,
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
                        ? colors.primaryContainer
                        : colors.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected
                          ? appColors.progressActive
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
                      color: isSelected ? colors.onPrimaryContainer : colors.onSurface,
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

  Widget _buildSummarySection(List cart, bool isDark, BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Summary',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: colors.onSurface,
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

  Widget _buildSubtotal(double total, bool isDark, BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Subtotal',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: colors.onSurface,
          ),
        ),
        Text(
          '\$${total.toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: colors.onSurface,
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
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final appColors = theme.appColors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Payment Method',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: colors.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colors.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: colors.outlineVariant,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: appColors.statusSuccess,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.payments_outlined,
                  color: colors.onPrimary,
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
                        color: colors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Pay when you collect your order',
                      style: TextStyle(
                        fontSize: 13,
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: appColors.progressActive,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.check, size: 16, color: colors.onPrimary),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFrequentlyBoughtTogether(bool isDark, BuildContext context) {
    final colors = Theme.of(context).colorScheme;
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
            color: colors.onSurface,
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
                  color: colors.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: colors.outlineVariant,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 100,
                      decoration: BoxDecoration(
                        color: colors.surfaceContainerHighest,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(12),
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.coffee,
                          size: 40,
                          color: colors.onSurfaceVariant,
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
                              color: colors.onSurface,
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
                              color: colors.onSurfaceVariant,
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
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final appColors = theme.appColors;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
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
                    color: colors.onSurface,
                  ),
                ),
                Text(
                  '\$${total.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: colors.onSurface,
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
                          color: colors.onSurface,
                        ),
                      ),
                      duration: const Duration(seconds: 2),
                      backgroundColor: colors.surface,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: appColors.progressActive,
                  foregroundColor: colors.onPrimary,
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
