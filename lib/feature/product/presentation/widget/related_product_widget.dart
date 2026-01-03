import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RelatedProductWidget extends ConsumerWidget {
  final String productName;
  final String productImage;
  final double productPrice;

  const RelatedProductWidget({
    super.key,
    required this.productName,
    required this.productImage,
    required this.productPrice,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. Get Dynamic Theme Data
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDarkMode = theme.brightness == Brightness.dark;

    return Container(
      width: 280,
      margin: const EdgeInsets.only(right: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor, // Fix: Dynamic Background (Dark Grey in Dark Mode)
        borderRadius: BorderRadius.circular(12),
        // Fix: Hide shadow in Dark Mode (use border instead for cleaner look)
        boxShadow: isDarkMode 
            ? [] 
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
        // Optional: Add subtle border in dark mode
        border: isDarkMode ? Border.all(color: theme.dividerColor) : null,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  productName,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: colors.onSurface, // Fix: Dynamic Text
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Text(
                  '\$${productPrice.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: colors.onSurfaceVariant, // Fix: Dynamic Subtitle
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              productImage,
              width: 100,
              height: 100,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  // Fix: Dynamic Placeholder Background
                  color: colors.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.coffee, 
                  size: 40, 
                  color: colors.onSurfaceVariant, // Fix: Dynamic Icon
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}