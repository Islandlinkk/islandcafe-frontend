import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:island_cafe/core/route/route_name.dart';
import 'package:island_cafe/feature/auth/data/providers/auth_provider.dart';
import 'package:island_cafe/feature/profile/presentation/data/provider/favorite_provider.dart';
import 'package:island_cafe/feature/product/data/provider/product_provider.dart';

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. Get User ID safely
    final user = ref.watch(authStateProvider).value;
    final userId = user?.uid ?? '';

    if (user == null) return const _NoUserScreen();

    // 2. Watch the favorites state
    final favState = ref.watch(favoritesProvider(userId));

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          color: Colors.black,
          onPressed: () =>
              context.canPop() ? context.pop() : context.go(profileRoute),
        ),
        title: const Text(
          'FAVORITES',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
      ),
      // 3. Added RefreshIndicator for better UX
      body: RefreshIndicator(
        onRefresh: () =>
            ref.read(favoritesProvider(userId).notifier).fetchRemote(),
        color: const Color(0xFF006064), // Match your cafe theme
        child: SizedBox.expand(
          child: favState.isLoading && favState.items.isEmpty
              ? _loadingSkeleton()
              : favState.items.isEmpty
              ? _emptyState()
              : ListView.separated(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 30),
                  itemCount: favState.items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final item = favState.items[index];
                    return _FavoriteMenuCard(item: item, userId: userId);
                  },
                ),
        ),
      ),
    );
  }

  Widget _emptyState() => LayoutBuilder(
    builder: (context, constraints) => SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: constraints.maxHeight),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.favorite_border, size: 80, color: Colors.grey),
              SizedBox(height: 12),
              Text(
                'No favorites yet',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              SizedBox(height: 4),
              Text('Tap the heart on any item to save it'),
            ],
          ),
        ),
      ),
    ),
  );

  Widget _loadingSkeleton() => ListView.separated(
    padding: const EdgeInsets.all(16),
    itemCount: 6,
    separatorBuilder: (_, __) => const SizedBox(height: 10),
    itemBuilder: (_, __) => Container(
      height: 90,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
      ),
    ),
  );
}

class _FavoriteMenuCard extends ConsumerWidget {
  final dynamic item;
  final String userId;

  const _FavoriteMenuCard({required this.item, required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Helper to safely extract product data whether nested or not
    final Map<String, dynamic> productData =
        (item is Map && item.containsKey('product'))
        ? Map<String, dynamic>.from(item['product'])
        : Map<String, dynamic>.from(item is Map ? item : {});

    final id = (productData['id'] ?? productData['_id'] ?? '').toString();
    final name = productData['name'] ?? 'Unknown Item';
    final description = productData['description'] ?? '';
    final image = productData['image'] ?? productData['imageUrl'] ?? '';
    final price = _parsePrice(productData['price'] ?? productData['fullPrice']);

    return Dismissible(
      key: Key('fav_$id'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.red.shade400,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      onDismissed: (_) {
        ref
            .read(favoritesProvider(userId).notifier)
            .toggleFavorite(productData);
      },
      child: InkWell(
        onTap: () {
          if (id.isNotEmpty) {
            ref.read(selectedProductIdProvider.notifier).state = id;
            context.pushNamed(productDetailRoute);
          }
        },
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade100),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha((0.02 * 255).round()),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Text(
                          '\$${price.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const _CircleIcon(
                          assetPath: 'assets/icons/add-to-cart.png',
                        ),
                        const SizedBox(width: 8),
                        const _CircleIcon(
                          assetPath: 'assets/icons/lightning.png',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: image.isNotEmpty
                    ? Image.network(
                        image,
                        width: 80,
                        height: 100,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _imagePlaceholder(),
                      )
                    : _imagePlaceholder(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  double _parsePrice(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    if (value is String) {
      final clean = value.replaceAll(RegExp(r'[^\d.]'), '');
      return double.tryParse(clean) ?? 0.0;
    }
    return 0.0;
  }

  Widget _imagePlaceholder() => Container(
    width: 80,
    height: 100,
    color: Colors.grey.shade200,
    child: const Icon(Icons.image_not_supported, color: Colors.grey),
  );
}

class _NoUserScreen extends StatelessWidget {
  const _NoUserScreen();
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white,
      body: Center(child: Text('Please log in to view favorites')),
    );
  }
}

class _CircleIcon extends StatelessWidget {
  final String assetPath;
  const _CircleIcon({required this.assetPath});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: const BoxDecoration(
        color: Color(0xFFE0F7FA),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Image.asset(
          assetPath,
          width: 18,
          height: 18,
          errorBuilder: (context, error, stackTrace) =>
              const Icon(Icons.add, size: 18),
        ),
      ),
    );
  }
}