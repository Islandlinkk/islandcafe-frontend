import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:go_router/go_router.dart';
import 'package:island_cafe/feature/cart/data/provider/cart_notifier.dart';
import 'package:island_cafe/feature/cart/data/provider/cart_total_provider.dart';
import 'package:island_cafe/feature/checkout/data/model/order_item_model.dart';
import 'package:island_cafe/feature/checkout/data/model/order_model.dart';
import 'package:island_cafe/feature/checkout/data/provider/checkout_provider.dart';
import 'package:island_cafe/feature/checkout/data/provider/order_item_provider.dart';
import 'package:island_cafe/feature/checkout/data/provider/order_provider.dart';
import 'package:island_cafe/feature/product/data/provider/product_provider.dart';
import 'package:island_cafe/feature/product/presentation/widget/related_product_widget.dart';
import 'package:island_cafe/feature/auth/data/providers/auth_provider.dart';
import 'package:island_cafe/feature/voucher/data/provider/my_voucher_provider.dart';

// Loading state provider for place order button
final isPlacingOrderProvider = StateProvider<bool>((ref) => false);

class CheckoutWidget extends ConsumerWidget {
  const CheckoutWidget({super.key});

  void showTopAlert(
    BuildContext context,
    String message, {
    Color backgroundColor = Colors.green,
  }) {
    // Check if context is still mounted before getting overlay
    if (!context.mounted) return;

    final overlay = Overlay.of(context, rootOverlay: false);
    _showOverlayAlert(overlay, message, backgroundColor);
  }

  void _showOverlayAlert(
    OverlayState overlay,
    String message,
    Color backgroundColor,
  ) {
    // Check if overlay is still mounted before inserting
    if (!overlay.mounted) return;

    final overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: 50,
        left: 16,
        right: 16,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              message,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);

    Future.delayed(const Duration(seconds: 2), () {
      // Check if overlay entry is still mounted before removing
      if (overlayEntry.mounted) {
        overlayEntry.remove();
      }
    });
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartProvider);
    final cartTotal = ref.watch(cartTotalProvider);
    final selectedPickupTime = ref.watch(selectedPickupTimeProvider);
    final selectedPaymentMethod = ref.watch(selectedPaymentMethodProvider);
    final productAsyncValue = ref.watch(productByIdProvider);
    final relatedProductsAsyncValue = ref.watch(
      relatedProductsProvider(productAsyncValue.asData?.value.categoryId ?? ''),
    );
    // Dark mode detection
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
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
                _buildPickupTimeSection(
                  ref,
                  selectedPickupTime,
                  isDark,
                  context,
                ),
                const SizedBox(height: 24),

                // Summary Section
                _buildSummarySection(cart, isDark),
                const SizedBox(height: 16),

                // Subtotal
                _buildSubtotal(cartTotal, isDark),
                const SizedBox(height: 16),

                // Applied Voucher Display
                Consumer(
                  builder: (context, ref, _) {
                    final selectedVoucher = ref.watch(selectedVoucherProvider);
                    final voucherDiscount = ref.watch(
                      voucherDiscountAmountProvider,
                    );

                    if (selectedVoucher != null) {
                      return Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(
                                0xFFFFC107,
                              ).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: const Color(0xFFFFC107),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: const Color(
                                      0xFFFFC107,
                                    ).withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Icon(
                                    Icons.local_offer,
                                    color: Color(0xFFFFC107),
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        selectedVoucher.code,
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: isDark
                                              ? Colors.white
                                              : Colors.black,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        selectedVoucher.formattedDiscount,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFFFFC107),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      '-\$${voucherDiscount.toStringAsFixed(2)}',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    GestureDetector(
                                      onTap: () {
                                        ref
                                                .read(
                                                  selectedVoucherProvider
                                                      .notifier,
                                                )
                                                .state =
                                            null;
                                        showTopAlert(
                                          context,
                                          'Voucher removed',
                                        );
                                      },
                                      child: Text(
                                        'Remove',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.red[400],
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),

                // Apply Voucher
                _buildApplyVoucher(context, ref),
                const SizedBox(height: 24),

                // Payment Method
                _buildPaymentMethod(selectedPaymentMethod, isDark, context),
                const SizedBox(height: 24),

                relatedProductsAsyncValue.when(
                  data: (relatedProducts) {
                    if (relatedProducts.isEmpty || cart.isEmpty) {
                      return const SizedBox();
                    }
                    final filteredProducts = relatedProducts
                        .where((p) => p.id != cart[0].productId)
                        .toList();
                    if (filteredProducts.isEmpty) {
                      return const SizedBox();
                    }

                    return Container(
                      margin: const EdgeInsets.only(top: 32),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 0),
                            child: Text(
                              'You May Also Like',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: colors.onSurface,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            height: 130,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: filteredProducts.length,
                              itemBuilder: (context, index) {
                                final relatedProduct = filteredProducts[index];
                                return GestureDetector(
                                  onTap: () {
                                    ref
                                        .read(
                                          selectedProductIdProvider.notifier,
                                        )
                                        .state = relatedProduct
                                        .id;
                                    context.pushReplacementNamed(
                                      '/productDetail',
                                    );
                                  },
                                  child: RelatedProductWidget(
                                    productName: relatedProduct.name,
                                    productImage: relatedProduct.image,
                                    productPrice: relatedProduct.price,
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    );
                  },
                  loading: () => const SizedBox(),
                  error: (_, __) => const SizedBox(),
                ),
              ],
            ),
          ),
        ),

        // Bottom Total & Checkout Button
        Consumer(
          builder: (context, ref, _) {
            final totalWithVoucher = ref.watch(cartTotalWithVoucherProvider);
            return _buildBottomBar(context, totalWithVoucher, isDark);
          },
        ),
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

  Widget _buildProgressStep(
    String label,
    bool isCompleted,
    bool isActive,
    bool isDark,
  ) {
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

  Widget _buildPickupTimeSection(
    WidgetRef ref,
    String selectedTime,
    bool isDark,
    BuildContext context,
  ) {
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
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
        const SizedBox(height: 24),
        ...cart.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          return _buildCheckoutItemCard(item, index, isDark);
        }),
      ],
    );
  }

  Widget _buildCheckoutItemCard(dynamic item, int index, bool isDark) {
    return Consumer(
      builder: (context, ref, _) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Quantity
              Text(
                '${item.quantity}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                '×',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
              ),
              const SizedBox(width: 12),

              // Delete Button
              GestureDetector(
                onTap: () => _removeItem(context, ref, index),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  child: Icon(
                    Icons.delete_outline,
                    size: 20,
                    color: isDark ? Colors.grey[500] : Colors.grey[600],
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // Product Image
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[800] : const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: item.image != null && item.image.isNotEmpty
                      ? Image.network(
                          item.image,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.coffee, size: 30),
                        )
                      : const Icon(Icons.coffee, size: 30),
                ),
              ),
              const SizedBox(width: 12),

              // Product Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      item.productName,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.size.name,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),

              // Price
              Text(
                '\$${item.totalPrice.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _removeItem(BuildContext context, WidgetRef ref, int index) {
    ref.read(cartProvider.notifier).removeItem(index);
    showTopAlert(context, 'Item removed from cart');
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

  Widget _buildApplyVoucher(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () => _showVoucherBottomSheet(context, ref),
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

  void _showVoucherBottomSheet(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);
    final voucherController = TextEditingController();
    bool isLoading = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return Consumer(
            builder: (context, ref, _) {
              // Watch the voucher provider to get user's claimed vouchers
              final voucherState = ref.watch(myVouchersProvider);

              return Container(
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[900] : Colors.white,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                ),
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Apply Voucher',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : Colors.black,
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.close,
                                color: isDark ? Colors.white : Colors.black,
                              ),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Voucher Code Input
                        Text(
                          'Enter Voucher Code',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.grey[400] : Colors.grey[700],
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: voucherController,
                          decoration: InputDecoration(
                            hintText: 'Enter code',
                            hintStyle: TextStyle(
                              color: isDark
                                  ? Colors.grey[600]
                                  : Colors.grey[400],
                            ),
                            filled: true,
                            fillColor: isDark
                                ? Colors.grey[850]
                                : Colors.grey[100],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            suffixIcon: ElevatedButton(
                              onPressed: isLoading
                                  ? null
                                  : () async {
                                      final code = voucherController.text
                                          .trim()
                                          .toUpperCase();
                                      if (code.isEmpty) return;

                                      // Set loading state
                                      setState(() {
                                        isLoading = true;
                                      });

                                      // Capture BuildContext before async operations
                                      final navigator = Navigator.of(context);
                                      final overlay = Overlay.of(context);

                                      try {
                                        // Claim the voucher and get updated list in one go
                                        await ref
                                            .read(myVouchersProvider.notifier)
                                            .claimVoucher(code);

                                        // Get the updated voucher list (invalidate and fetch)
                                        ref.invalidate(myVouchersProvider);
                                        final vouchers = await ref.read(
                                          myVouchersProvider.future,
                                        );

                                        final voucher = vouchers
                                            .where(
                                              (v) =>
                                                  v.code.toUpperCase() == code,
                                            )
                                            .firstOrNull;

                                        if (voucher != null) {
                                          // Check minimum order value
                                          final cartTotal = ref.read(
                                            cartTotalProvider,
                                          );
                                          if (voucher.minOrderValue != null &&
                                              cartTotal <
                                                  voucher.minOrderValue!
                                                      .toDouble()) {
                                            _showOverlayAlert(
                                              overlay,
                                              'Minimum order value of \$${voucher.minOrderValue!.toStringAsFixed(2)} required',
                                              Colors.red,
                                            );
                                            if (context.mounted) {
                                              setState(() {
                                                isLoading = false;
                                              });
                                            }
                                            return;
                                          }

                                          // Apply the voucher
                                          ref
                                                  .read(
                                                    selectedVoucherProvider
                                                        .notifier,
                                                  )
                                                  .state =
                                              voucher;
                                          navigator.pop();
                                          _showOverlayAlert(
                                            overlay,
                                            'Voucher "$code" applied',
                                            Colors.green,
                                          );
                                        }
                                      } catch (e) {
                                        // Handle errors from the API
                                        final errorMessage = e
                                            .toString()
                                            .replaceAll('Exception: ', '');
                                        _showOverlayAlert(
                                          overlay,
                                          errorMessage,
                                          Colors.red,
                                        );
                                      } finally {
                                        // Reset loading state only if still mounted
                                        if (context.mounted) {
                                          setState(() {
                                            isLoading = false;
                                          });
                                        }
                                      }
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isLoading
                                    ? Colors.grey[400]
                                    : const Color(0xFFFFC107),
                                foregroundColor: Colors.black,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 12,
                                ),
                              ),
                              child: isLoading
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              Colors.black,
                                            ),
                                      ),
                                    )
                                  : const Text(
                                      'Apply',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                            ),
                          ),
                          textCapitalization: TextCapitalization.characters,
                        ),
                        const SizedBox(height: 24),

                        // Available Vouchers Section
                        Text(
                          'Select Voucher',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.grey[400] : Colors.grey[700],
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Vouchers List
                        voucherState.when(
                          data: (vouchers) {
                            if (vouchers.isEmpty) {
                              return Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    // Fix: Icon color adapts to dark mode
                                    Icon(
                                      Icons.confirmation_number_outlined,
                                      size: 64,
                                      color: theme
                                          .colorScheme
                                          .surfaceContainerHighest,
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      "You haven't claimed any vouchers yet.",
                                      // Fix: Text color adapts to dark mode
                                      style: TextStyle(
                                        color:
                                            theme.colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }
                            return Column(
                              children: vouchers.map((voucher) {
                                return Container(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? Colors.grey[850]
                                        : Colors.grey[50],
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: isDark
                                          ? Colors.grey[700]!
                                          : Colors.grey[200]!,
                                    ),
                                  ),
                                  child: ListTile(
                                    dense: true,
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 4,
                                    ),
                                    onTap: () {
                                      // Apply selected voucher
                                      ref
                                              .read(
                                                selectedVoucherProvider
                                                    .notifier,
                                              )
                                              .state =
                                          voucher;
                                      Navigator.pop(context);
                                      showTopAlert(
                                        context,
                                        'Voucher "${voucher.code}" applied',
                                      );
                                    },
                                    leading: Container(
                                      width: 36,
                                      height: 36,
                                      decoration: BoxDecoration(
                                        color: const Color(
                                          0xFFFFC107,
                                        ).withValues(alpha: 0.2),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: const Icon(
                                        Icons.local_offer,
                                        color: Color(0xFFFFC107),
                                        size: 18,
                                      ),
                                    ),
                                    title: Text(
                                      voucher.code,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: isDark
                                            ? Colors.white
                                            : Colors.black,
                                      ),
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const SizedBox(height: 2),
                                        Text(
                                          voucher.formattedDiscount,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xFFFFC107),
                                          ),
                                        ),
                                        Text(
                                          voucher.description ??
                                              voucher.minSpendText,
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: isDark
                                                ? Colors.grey[400]
                                                : Colors.grey[600],
                                          ),
                                        ),
                                        Text(
                                          'Exp: ${voucher.formattedExpiry}',
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: isDark
                                                ? Colors.grey[500]
                                                : Colors.grey[500],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }).toList(),
                            );
                          },
                          loading: () => const Center(
                            child: Padding(
                              padding: EdgeInsets.all(32),
                              child: CircularProgressIndicator(),
                            ),
                          ),
                          error: (error, _) => Center(
                            child: Padding(
                              padding: EdgeInsets.all(32),
                              child: Text(
                                'Failed to load vouchers',
                                style: TextStyle(
                                  color: isDark
                                      ? Colors.grey[400]
                                      : Colors.grey[600],
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildPaymentMethod(
    String selectedPaymentMethod,
    bool isDark,
    BuildContext context,
  ) {
    final paymentMethods = [
      {
        'name': 'Cash on Pickup',
        'description': 'Pay when you collect your order',
        'icon': Icons.payments_outlined,
        'color': const Color(0xFF4CAF50),
      },
      // {
      //   'name': 'ABA',
      //   'description': 'Pay online with ABA mobile banking',
      //   'icon': Icons.account_balance,
      //   'color': const Color(0xFF0066CC),
      // },
    ];

    return Consumer(
      builder: (context, ref, _) {
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
            ...paymentMethods.map((method) {
              final isSelected = selectedPaymentMethod == method['name'];
              return GestureDetector(
                onTap: () {
                  ref.read(selectedPaymentMethodProvider.notifier).state =
                      method['name'] as String;
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey[850] : Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFFFFC107)
                          : (isDark ? Colors.grey[700]! : Colors.grey[200]!),
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: method['color'] as Color,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          method['icon'] as IconData,
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
                              method['name'] as String,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: isDark ? Colors.white : Colors.black,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              method['description'] as String,
                              style: TextStyle(
                                fontSize: 13,
                                color: isDark
                                    ? Colors.grey[400]
                                    : Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (isSelected)
                        Container(
                          width: 24,
                          height: 24,
                          decoration: const BoxDecoration(
                            color: Color(0xFFFFC107),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.check,
                            size: 16,
                            color: Colors.white,
                          ),
                        ),
                    ],
                  ),
                ),
              );
            }),
          ],
        );
      },
    );
  }

  Widget _buildBottomBar(BuildContext context, double total, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900] : Colors.white,
        boxShadow: [
          BoxShadow(
            color: (isDark ? Colors.black : Colors.grey).withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
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
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
                Text(
                  '\$${total.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: Consumer(
                builder: (context, ref, _) {
                  final cart = ref.watch(cartProvider);
                  final selectedPickupTime = ref.watch(
                    selectedPickupTimeProvider,
                  );
                  final selectedPaymentMethod = ref.watch(
                    selectedPaymentMethodProvider,
                  );
                  final selectedVoucher = ref.watch(selectedVoucherProvider);
                  final userAsyncValue = ref.watch(authStateProvider);
                  final isPlacingOrder = ref.watch(isPlacingOrderProvider);

                  return ElevatedButton(
                    onPressed: cart.isEmpty || isPlacingOrder
                        ? null
                        : () async {
                            if (userAsyncValue.value == null) {
                              showTopAlert(
                                context,
                                'Please login to place order',
                                backgroundColor: Colors.red,
                              );
                              return;
                            }

                            final user = userAsyncValue.value!;

                            // Capture references before async operations
                            final orderCreator = ref.read(
                              orderCreatorProvider.notifier,
                            );
                            final orderItemCreator = ref.read(
                              orderItemCreatorProvider.notifier,
                            );
                            final cartNotifier = ref.read(
                              cartProvider.notifier,
                            );
                            final voucherNotifier = ref.read(
                              selectedVoucherProvider.notifier,
                            );

                            // Set loading state
                            ref.read(isPlacingOrderProvider.notifier).state =
                                true;

                            try {
                              // Create Order
                              final voucherDiscount = selectedVoucher != null
                                  ? ref.read(voucherDiscountAmountProvider)
                                  : 0.0;

                              final order = OrderModel(
                                userId: user.uid,
                                orderStatus: 'Pending',
                                oderFrom: 'Mobile',
                                paymentStatus: false,
                                paymentMethod: selectedPaymentMethod,
                                total: total,
                                discount: 0,
                                discountVoucher: voucherDiscount is num
                                    ? voucherDiscount.toDouble()
                                    : double.parse(voucherDiscount.toString()),
                                voucherId: selectedVoucher?.id,
                                voucherCode: selectedVoucher?.code,
                                pickupTime: selectedPickupTime,
                              );

                              // Create the order first and get the created order directly
                              final createdOrder = await orderCreator
                                  .createOrder(order);

                              // Map cart items to order items
                              // Use the database ID if available, otherwise fall back to displayId
                              final orderId =
                                  createdOrder.id ??
                                  createdOrder.displayId.toString();

                              final orderItems = cart.map((cartItem) {
                                // Ensure price is a number
                                final priceValue = cartItem.totalPrice is num
                                    ? cartItem.totalPrice as num
                                    : num.parse(cartItem.totalPrice.toString());

                                return OrderItemModel(
                                  orderId: orderId,
                                  productId: cartItem.productId,
                                  quantity: cartItem.quantity,
                                  price: priceValue,
                                  note: cartItem.note,
                                  sizeId: cartItem.size.id,
                                  extraShotId: cartItem.extraShot?.id,
                                  iceId: cartItem.ice?.id,
                                  sugarId: cartItem.sugar?.id,
                                );
                              }).toList();

                              // Create all order items
                              await orderItemCreator.createMultipleOrderItems(
                                orderItems,
                              );

                              // Clear cart
                              cartNotifier.clearCart();

                              // Clear selected voucher
                              voucherNotifier.state = null;

                              // Show success message
                              if (context.mounted) {
                                showTopAlert(
                                  context,
                                  'Order placed successfully!',
                                );

                                // Navigate to order confirmation or home
                                context.go('/home');
                              }
                            } catch (e) {
                              if (context.mounted) {
                                showTopAlert(
                                  context,
                                  'Failed to place order: ${e.toString()}',
                                  backgroundColor: Colors.red,
                                );
                              }
                            } finally {
                              // Reset loading state
                              ref.read(isPlacingOrderProvider.notifier).state =
                                  false;
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: cart.isEmpty || isPlacingOrder
                          ? Colors.grey[400]
                          : const Color(0xFFFFC107),
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: isPlacingOrder
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.black,
                              ),
                            ),
                          )
                        : const Text(
                            'Place Order',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
