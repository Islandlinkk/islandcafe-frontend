import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/rendering.dart';
import 'package:go_router/go_router.dart';
import 'package:island_cafe/feature/cart/data/provider/cart_notifier.dart';
import 'package:island_cafe/feature/cart/data/provider/cart_total_provider.dart';
import 'package:island_cafe/feature/product/data/provider/category_provider.dart';
import 'package:island_cafe/feature/product/data/provider/product_provider.dart';
import 'package:island_cafe/feature/product/presentation/widget/cart_item_widget.dart';
import 'package:island_cafe/feature/menu/presentation/widget/category_item.dart';
import 'package:island_cafe/feature/menu/presentation/widget/menu_item_card.dart';
import 'package:island_cafe/feature/theme/loading_screen.dart';

class PickupMenuView extends ConsumerStatefulWidget {
  const PickupMenuView({super.key});

  @override
  ConsumerState<PickupMenuView> createState() => _PickupMenuViewState();
}

class _PickupMenuViewState extends ConsumerState<PickupMenuView> {
  String selectedCategoryId = '';
  String selectedOrderType = 'Pickup';
  final ScrollController _scrollController = ScrollController();
  final Map<String, GlobalKey> _categoryKeys = {};
  final GlobalKey _listViewKey = GlobalKey();

  // Flag to prevent scroll listener from interfering with programmatic scrolling
  bool _isAutoScrolling = false;

  @override
  void initState() {
    super.initState();
    // Category keys will be initialized after data is loaded
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final blueColor = Theme.of(context).colorScheme.primary;
    final categoriesAsync = ref.watch(categoryProvider);
    final isSearchActive = ref.watch(isSearchActiveProvider);
    final searchQuery = ref.watch(searchQueryProvider);
    final productsAsync = isSearchActive
        ? ref.watch(filteredProductsProvider)
        : ref.watch(productProvider);

    return categoriesAsync.when(
      loading: () => const LoadingScreen(),
      error: (error, stack) =>
          Center(child: Text('Error loading categories: $error')),
      data: (categories) {
        if (categories.isEmpty) {
          return const Center(child: Text('No categories available'));
        }

        // Initialize category keys and selected category
        for (final c in categories) {
          _categoryKeys.putIfAbsent(c.id, () => GlobalKey());
        }
        if (selectedCategoryId.isEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              setState(() {
                selectedCategoryId = categories.first.id;
              });
            }
          });
        }

        return productsAsync.when(
          loading: () => const LoadingScreen(),
          error: (error, stack) =>
              Center(child: Text('Error loading products: $error')),
          data: (products) {
            if (isSearchActive && searchQuery.isNotEmpty) {
              if (products.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.search_off,
                        size: 64,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No products found',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Try a different search term',
                        style: TextStyle(
                          fontSize: 14,
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withOpacity(0.5),
                        ),
                      ),
                    ],
                  ),
                );
              }

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Search Results (${products.length})',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ...products.map(
                      (item) => MenuItemCard(item: item, onTap: () {}),
                    ),
                  ],
                ),
              );
            }

            // Normal category view
            return Column(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        width: 120,
                        decoration: BoxDecoration(
                          color: Theme.of(context).scaffoldBackgroundColor,
                          border: Border(
                            right: BorderSide(
                              color: Theme.of(context).dividerColor,
                            ),
                          ),
                        ),
                        child: ListView.builder(
                          itemCount: categories.length,
                          itemBuilder: (context, index) {
                            final category = categories[index];
                            return CategoryItem(
                              category: category,
                              isSelected: category.id == selectedCategoryId,
                              onTap: () {
                                setState(() {
                                  selectedCategoryId = category.id;
                                  _isAutoScrolling = true;
                                });
                                WidgetsBinding.instance.addPostFrameCallback((
                                  _,
                                ) {
                                  _scrollToCategory(category.id);
                                });
                              },
                            );
                          },
                        ),
                      ),
                      Expanded(
                        child: NotificationListener<ScrollNotification>(
                          onNotification: (notification) {
                            if (!_isAutoScrolling &&
                                (notification is ScrollUpdateNotification ||
                                    notification is ScrollEndNotification)) {
                              _updateSelectedCategoryFromScroll(categories);
                            }
                            return false;
                          },
                          child: SingleChildScrollView(
                            key: _listViewKey,
                            controller: _scrollController,
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                for (final category in categories) ...[
                                  Container(
                                    key: _categoryKeys[category.id],
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.category,
                                          color: blueColor,
                                          size: 20,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          category.name,
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleLarge
                                              ?.copyWith(
                                                fontWeight: FontWeight.bold,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  ...products
                                      .where(
                                        (product) =>
                                            product.categoryId == category.id,
                                      )
                                      .map(
                                        (item) => MenuItemCard(
                                          item: item,
                                          onTap: () {},
                                        ),
                                      ),
                                  const SizedBox(height: 16),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // View Cart Section - Same as product detail screen
                Consumer(
                  builder: (context, ref, child) {
                    final cart = ref.watch(cartProvider);
                    final cartTotal = ref.watch(cartTotalProvider);

                    if (cart.isEmpty) {
                      return const SizedBox.shrink();
                    }

                    return Container(
                      margin: const EdgeInsets.all(16),
                      child: GestureDetector(
                        onTap: () => _showCartBottomSheet(context),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.shopping_cart,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                    size: 24,
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    'View Cart (${cart.length} ${cart.length == 1 ? "item" : "items"})',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurface,
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Text(
                                    '\$${cartTotal.toStringAsFixed(2)}',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Icon(
                                    Icons.chevron_right,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant,
                                    size: 24,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _scrollToCategory(String id) {
    final headerKey = _categoryKeys[id];
    final ctx = headerKey?.currentContext;
    final ro = ctx?.findRenderObject();
    if (ro == null) {
      _isAutoScrolling = false;
      return;
    }
    final viewport = RenderAbstractViewport.of(ro);
    final reveal = viewport.getOffsetToReveal(ro, 0.0).offset;
    final min = _scrollController.position.minScrollExtent;
    final max = _scrollController.position.maxScrollExtent;

    final listBox =
        _listViewKey.currentContext?.findRenderObject() as RenderBox?;
    double target = reveal;
    if (listBox != null && ro is RenderBox) {
      final globalTop = ro.localToGlobal(const Offset(0, 0)).dy;
      final relativeTop = listBox.globalToLocal(Offset(0, globalTop)).dy;
      const paddingTop = 16.0;
      final alt = _scrollController.offset + relativeTop - paddingTop;
      final deltaReveal = (target - _scrollController.offset).abs();
      final deltaAlt = (alt - _scrollController.offset).abs();
      target = deltaAlt > deltaReveal ? alt : target;
    }
    final clamped = target.clamp(min, max).toDouble();

    if ((clamped - _scrollController.offset).abs() < 1.0) {
      final nudge = (clamped - min) > 10 ? clamped - 10 : (clamped + 10);
      final forced = nudge.clamp(min, max).toDouble();
      _scrollController.jumpTo(forced);
      _scrollController
          .animateTo(
            clamped,
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOut,
          )
          .whenComplete(() {
            _isAutoScrolling = false;
          });
    } else {
      _scrollController
          .animateTo(
            clamped,
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeOutCubic,
          )
          .whenComplete(() {
            _isAutoScrolling = false;
          });
    }
  }

  void _updateSelectedCategoryFromScroll(List<dynamic> categories) {
    final listBox =
        _listViewKey.currentContext?.findRenderObject() as RenderBox?;
    if (listBox == null || categories.isEmpty) return;

    // Robustness: If at the very top, select the first category
    if (_scrollController.hasClients && _scrollController.offset <= 10) {
      if (selectedCategoryId != categories.first.id) {
        setState(() {
          selectedCategoryId = categories.first.id;
        });
      }
      return;
    }

    String? nearestId;
    double nearestTop = double.infinity;
    for (final entry in _categoryKeys.entries) {
      final ctx = entry.value.currentContext;
      final box = ctx?.findRenderObject() as RenderBox?;
      if (box == null) continue;
      final globalTop = box.localToGlobal(Offset.zero).dy;
      final relativeTop = listBox.globalToLocal(Offset(0, globalTop)).dy;
      if (relativeTop >= -20 && relativeTop < nearestTop) {
        nearestTop = relativeTop;
        nearestId = entry.key;
      }
    }
    if (nearestId != null && nearestId != selectedCategoryId) {
      setState(() {
        selectedCategoryId = nearestId!;
      });
    }
  }

  void _showCartBottomSheet(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Consumer(
        builder: (context, ref, child) {
          final cart = ref.watch(cartProvider);
          final cartTotal = ref.watch(cartTotalProvider);

          return Container(
            height: MediaQuery.of(context).size.height * 0.9,
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.dividerColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Cart (${cart.length})',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: colors.onSurface,
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.close, color: colors.onSurface),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),

                Divider(height: 1, color: theme.dividerColor),

                Expanded(
                  child: cart.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.shopping_cart_outlined,
                                size: 80,
                                color: colors.surfaceContainerHighest,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Your cart is empty',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: colors.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(20),
                          itemCount: cart.length,
                          itemBuilder: (context, index) {
                            final item = cart[index];
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
                              index: index,
                            );
                          },
                        ),
                ),

                if (cart.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black,
                          blurRadius: 10,
                          offset: const Offset(0, -3),
                        ),
                      ],
                    ),
                    child: Column(
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
                              '\$${cartTotal.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: colors.primary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            context.pushReplacementNamed('/checkout');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colors.primary,
                            foregroundColor: colors.onPrimary,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            minimumSize: const Size(double.infinity, 50),
                          ),
                          child: const Text(
                            'CHECKOUT',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
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
    );
  }
}
