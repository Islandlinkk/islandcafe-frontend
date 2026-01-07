import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:island_cafe/feature/cart/data/provider/cart_notifier.dart';

class CartItemWidget extends ConsumerWidget {
  final String name;
  final String options;
  final int quantity;
  final double price;
  final String image;
  final int index;

  const CartItemWidget({
    super.key,
    required this.name,
    required this.options,
    required this.quantity,
    required this.price,
    required this.image,
    required this.index,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. Get Theme Data
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        // Dynamic Background (Off-white in Light, Dark Grey in Dark)
        color: theme.cardColor, 
        borderRadius: BorderRadius.circular(12),
        // Dynamic Border
        border: Border.all(color: theme.dividerColor), 
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- IMAGE ---
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              image,
              width: 60,
              height: 60,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  // Dynamic Placeholder Background
                  color: colors.surfaceContainerHighest, 
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.coffee, 
                  size: 30, 
                  // Dynamic Icon Color
                  color: colors.onSurfaceVariant, 
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          
          // --- CONTENT ---
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name and Delete Button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        name,
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colors.onSurface, // Dynamic Black/White
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, size: 20),
                      // Dynamic Red
                      color: colors.error, 
                      onPressed: () {
                        ref.read(cartProvider.notifier).removeItem(index);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Item removed from cart',
                              // Ensure text on SnackBar is readable
                              style: TextStyle(color: colors.onError), 
                            ),
                            backgroundColor: colors.error,
                            behavior: SnackBarBehavior.floating,
                            duration: const Duration(seconds: 1),
                          ),
                        );
                      },
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                
                // Options Text
                Text(
                  options,
                  style: textTheme.bodySmall?.copyWith(
                    // Dynamic Grey
                    color: colors.onSurfaceVariant, 
                  ),
                ),
                const SizedBox(height: 8),
                
                // Quantity and Price
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Quantity Controller
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: theme.dividerColor),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          _QuantityButton(
                            icon: Icons.remove,
                            onTap: () {
                              ref
                                  .read(cartProvider.notifier)
                                  .updateQuantity(index, quantity - 1);
                            },
                            color: colors.onSurface,
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Text(
                              '$quantity',
                              style: textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: colors.onSurface,
                              ),
                            ),
                          ),
                          _QuantityButton(
                            icon: Icons.add,
                            onTap: () {
                              ref
                                  .read(cartProvider.notifier)
                                  .updateQuantity(index, quantity + 1);
                            },
                            color: colors.onSurface,
                          ),
                        ],
                      ),
                    ),
                    
                    // Price
                    Text(
                      '\$${price.toStringAsFixed(2)}',
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colors.primary, // Dynamic Brand Color (Orange)
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Small helper widget to keep code clean
class _QuantityButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color color;

  const _QuantityButton({
    required this.icon,
    required this.onTap,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(icon, size: 16),
      color: color,
      onPressed: onTap,
      padding: const EdgeInsets.all(4),
      constraints: const BoxConstraints(),
    );
  }
}