import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:island_cafe/feature/menu/presentation/screen/delivery_screen.dart';
import 'package:island_cafe/feature/menu/presentation/screen/pickup_screen.dart';
import 'package:island_cafe/feature/product/data/provider/product_provider.dart';

// OrderType enum
enum OrderType { pickup, delivery }

// Provider to manage order type
final orderTypeProvider = StateProvider<OrderType>((ref) => OrderType.pickup);

// Main Menu Screen that switches between Pickup and Delivery
class MenuScreen extends ConsumerWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orderType = ref.watch(orderTypeProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Header with toggle
            _buildHeader(context, ref),

            // Show different UI based on selection
            Expanded(
              child: orderType == OrderType.pickup
                  ? const PickupMenuView()
                  : const DeliveryMenuView(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, WidgetRef ref) {
    final orderType = ref.watch(orderTypeProvider);
    final blueColor = Theme.of(context).colorScheme.primary;

    return Column(
      children: [
        // Title and Search
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(width: 48),
              Text(
                'MENU',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: Icon(ref.watch(isSearchActiveProvider) ? Icons.close : Icons.search),
                onPressed: () {
                  final isActive = ref.read(isSearchActiveProvider);
                  ref.read(isSearchActiveProvider.notifier).state = !isActive;
                  if (!isActive) {
                    // Clear search when closing
                    ref.read(searchQueryProvider.notifier).state = '';
                  }
                },
              ),
            ],
          ),
        ),
        
        // Search Bar
        if (ref.watch(isSearchActiveProvider))
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Search products...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: ref.watch(searchQueryProvider).isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          ref.read(searchQueryProvider.notifier).state = '';
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Theme.of(context).colorScheme.outline),
                ),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surface,
              ),
              onChanged: (value) {
                ref.read(searchQueryProvider.notifier).state = value;
              },
            ),
          ),

        // Location and Order Type Toggle
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Location Selector (changes based on order type)
            Container(
              width: 130,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                border: Border(bottom: BorderSide(color: Theme.of(context).dividerColor)),
              ),
              child: Row(
                children: [
                  Text(
                    orderType == OrderType.pickup ? 'TOUL KORK' : 'TOUL KORK',
                    style: TextStyle(
                      color: blueColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Spacer(),
                  Icon(Icons.keyboard_arrow_down, color: blueColor, size: 20),
                ],
              ),
            ),

            // Pickup/Delivery Toggle
            Container(
              width: 140,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                border: Border(bottom: BorderSide(color: Theme.of(context).dividerColor)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _buildOrderTypeButton(
                      context,
                      ref,
                      'Pickup',
                      orderType == OrderType.pickup,
                      blueColor,
                    ),
                  ),
                  Expanded(
                    child: _buildOrderTypeButton(
                      context,
                      ref,
                      'Delivery',
                      orderType == OrderType.delivery,
                      blueColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildOrderTypeButton(
    BuildContext context,
    WidgetRef ref,
    String label,
    bool isSelected,
    Color blueColor,
  ) {
    return InkWell(
      onTap: () {
        final newType = label == 'Pickup'
            ? OrderType.pickup
            : OrderType.delivery;
        ref.read(orderTypeProvider.notifier).state = newType;
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isSelected ? blueColor : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isSelected ? blueColor : Theme.of(context).colorScheme.onSurface,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}
