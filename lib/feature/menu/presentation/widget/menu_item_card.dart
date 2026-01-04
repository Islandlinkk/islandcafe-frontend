import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:island_cafe/feature/product/data/model/product_model.dart';
import 'package:island_cafe/feature/product/data/provider/product_provider.dart';

class MenuItemCard extends ConsumerWidget {
  final ProductModel item;
  final VoidCallback? onTap;

  const MenuItemCard({super.key, required this.item, this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. Grab theme colors
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return InkWell(
      onTap: () {
        ref.read(selectedProductIdProvider.notifier).state = item.id;
        context.pushNamed('/productDetail');
      },
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      // Automatically becomes White in dark mode
                      color: colors.onSurface, 
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.description,
                    style: textTheme.bodySmall?.copyWith(
                      // 2. Use 'onSurfaceVariant' instead of Colors.grey[600]
                      color: colors.onSurfaceVariant, 
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  if (item.discount != null && item.discount! > 0)
                    Row(
                      children: [
                        Text(
                          '\$${item.price.toStringAsFixed(2)}',
                          style: textTheme.bodySmall?.copyWith(
                            decoration: TextDecoration.lineThrough,
                            // 3. Make the old price subtly visible
                            color: colors.onSurface.withValues(alpha: 0.5),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '\$${(item.price - (item.price * item.discount! / 100)).toStringAsFixed(2)}',
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.green, // Red is usually fine in dark mode
                          ),
                        ),
                      ],
                    )
                  else
                    Text(
                      '\$${item.price.toStringAsFixed(2)}',
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        // 4. Use primary color (Orange/Blue) instead of hardcoded Blue
                        color: colors.primary, 
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    item.image,
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 100,
                        height: 100,
                        // 5. Placeholder background adapts to dark mode
                        color: colors.surfaceContainerHighest,
                        child: Icon(Icons.image_not_supported, color: colors.onSurfaceVariant),
                      );
                    },
                  ),
                ),
                if (item.discount != null && item.discount! > 0)
                  Positioned(
                    top: 4,
                    right: 4,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '-${item.discount}%',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}