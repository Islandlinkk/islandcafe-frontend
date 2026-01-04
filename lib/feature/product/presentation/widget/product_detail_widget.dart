import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:island_cafe/feature/cart/data/model/cart_model.dart';
import 'package:island_cafe/feature/cart/data/provider/cart_notifier.dart';
import 'package:island_cafe/feature/cart/data/provider/cart_total_provider.dart';
import 'package:island_cafe/feature/product/data/provider/extraShot_provider.dart';
import 'package:island_cafe/feature/product/data/provider/ice_provider.dart';
import 'package:island_cafe/feature/product/data/provider/product_provider.dart';
import 'package:island_cafe/feature/product/data/provider/size_provider.dart';
import 'package:island_cafe/feature/product/data/provider/sugar_provider.dart';
import 'package:island_cafe/feature/product/presentation/widget/cart_item_widget.dart';
import 'package:island_cafe/feature/product/presentation/widget/related_product_widget.dart';

class ProductDetailWidget extends ConsumerStatefulWidget {
  const ProductDetailWidget({super.key});

  @override
  ConsumerState<ProductDetailWidget> createState() =>
      _ProductDetailWidgetState();
}

class _ProductDetailWidgetState extends ConsumerState<ProductDetailWidget> {
  bool _isFavorite = false;
  int _quantity = 1;
  final ScrollController _scrollController = ScrollController();
  bool _showAppBar = false;

  // Selection states
  String? _selectedSizeId;
  String? _selectedSugarId;
  String? _selectedIceId;
  String? _selectedExtraShotId;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.offset > 200 && !_showAppBar) {
      setState(() => _showAppBar = true);
    } else if (_scrollController.offset <= 200 && _showAppBar) {
      setState(() => _showAppBar = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // 1. Get Dynamic Theme Data
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDarkMode = theme.brightness == Brightness.dark;

    final productAsyncValue = ref.watch(productByIdProvider);
    final relatedProductsAsyncValue = ref.watch(
      relatedProductsProvider(productAsyncValue.asData?.value.categoryId ?? ''),
    );
    final sizesAsyncValue = ref.watch(
      sizesProvider(productAsyncValue.asData?.value.id ?? ''),
    );
    final sugarsAsyncValue = ref.watch(
      sugarsProvider(productAsyncValue.asData?.value.id ?? ''),
    );
    final icesAsyncValue = ref.watch(
      icesProvider(productAsyncValue.asData?.value.id ?? ''),
    );
    final extraShotAsyncValue = ref.watch(
      extraShotsProvider(productAsyncValue.asData?.value.id ?? ''),
    );

    // Check if all data is loaded
    final isLoading =
        productAsyncValue.isLoading ||
        relatedProductsAsyncValue.isLoading ||
        sizesAsyncValue.isLoading ||
        sugarsAsyncValue.isLoading ||
        icesAsyncValue.isLoading ||
        extraShotAsyncValue.isLoading;

    // Set default selections only when data is loaded
    if (!isLoading) {
      if (sizesAsyncValue.asData?.value.isNotEmpty == true &&
          _selectedSizeId == null) {
        Future.microtask(() {
          if (mounted) {
            setState(() {
              _selectedSizeId = sizesAsyncValue.asData!.value.first.id;
            });
          }
        });
      }
      if (sugarsAsyncValue.asData?.value.isNotEmpty == true &&
          _selectedSugarId == null) {
        Future.microtask(() {
          if (mounted) {
            setState(() {
              _selectedSugarId = sugarsAsyncValue.asData!.value.length > 1
                  ? sugarsAsyncValue.asData!.value[1].id
                  : sugarsAsyncValue.asData!.value.first.id;
            });
          }
        });
      }
      if (icesAsyncValue.asData?.value.isNotEmpty == true &&
          _selectedIceId == null) {
        Future.microtask(() {
          if (mounted) {
            setState(() {
              _selectedIceId = icesAsyncValue.asData!.value.length > 1
                  ? icesAsyncValue.asData!.value[1].id
                  : icesAsyncValue.asData!.value.first.id;
            });
          }
        });
      }
    }

    // Show loading screen until all data is loaded
    if (isLoading) {
      return Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor, // Fix: Dynamic BG
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return productAsyncValue.when(
      data: (product) => Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor, // Fix: Dynamic BG
        extendBodyBehindAppBar: true,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: _showAppBar ? theme.appBarTheme.backgroundColor ?? colors.surface : Colors.transparent,
              boxShadow: _showAppBar
                  ? [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8.0,
                  vertical: 8.0,
                ),
                child: Row(
                  children: [
                    _buildIconButton(
                      context,
                      icon: Icons.arrow_back,
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    if (_showAppBar)
                      Expanded(
                        child: Text(
                          product.name,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: colors.onSurface, // Fix: Dynamic text
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      )
                    else
                      const Spacer(),
                    _buildIconButton(
                      context,
                      icon: _isFavorite
                          ? Icons.favorite
                          : Icons.favorite_border,
                      // Fix: Use Primary Color for favorite
                      color: _isFavorite ? colors.primary : colors.onSurface,
                      onPressed: () {
                        setState(() => _isFavorite = !_isFavorite);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              _isFavorite
                                  ? 'Added to favorites'
                                  : 'Removed from favorites',
                            ),
                            duration: const Duration(seconds: 1),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        body: Column(
          children: [
            // Scrollable content
            Expanded(
              child: SingleChildScrollView(
                controller: _scrollController,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product Image
                    Stack(
                      children: [
                        ClipRRect(
                          child: Image.network(
                            product.image,
                            width: double.infinity,
                            height: 300,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Container(
                                  height: 300,
                                  width: double.infinity,
                                  color: colors.surfaceContainerHighest, // Fix: Dynamic
                                  child: Icon(
                                    Icons.image_not_supported,
                                    size: 80,
                                    color: colors.onSurfaceVariant, // Fix: Dynamic
                                  ),
                                ),
                          ),
                        ),
                        if (product.discount != null && product.discount! > 0)
                          Positioned(
                            top: 16,
                            right: 16,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: colors.error, // Fix: Error color
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Text(
                                'SAVE ${product.discount}%',
                                style: TextStyle(
                                  color: colors.onError,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),

                    // Product Details Section
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Product Name
                          Text(
                            product.name,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: colors.onSurface, // Fix: Dynamic
                            ),
                          ),

                          const SizedBox(height: 8),

                          // Price with discount
                          if (product.discount != null && product.discount! > 0)
                            Row(
                              children: [
                                Text(
                                  '\$${product.price.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    fontSize: 16,
                                    decoration: TextDecoration.lineThrough,
                                    color: colors.onSurfaceVariant, // Fix: Dynamic
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  '\$${(product.price - (product.price * product.discount! / 100)).toStringAsFixed(2)}',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: colors.error, // Discounted Price
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: colors.errorContainer,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    'Save ${product.discount}%',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: colors.onErrorContainer,
                                    ),
                                  ),
                                ),
                              ],
                            )
                          else
                            Text(
                              '\$${product.price.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: colors.primary, // Fix: Primary Color
                              ),
                            ),

                          const SizedBox(height: 12),

                          // Description
                          Text(
                            product.description,
                            style: TextStyle(
                              color: colors.onSurfaceVariant, // Fix: Dynamic
                              fontSize: 14,
                              height: 1.5,
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Size Selection
                          sizesAsyncValue.when(
                            data: (sizes) =>
                                _buildSizeSection(context, sizes, product.discount),
                            loading: () => const SizedBox(),
                            error: (_, __) => const SizedBox(),
                          ),

                          const SizedBox(height: 24),

                          // Sugar Level Selection
                          sugarsAsyncValue.when(
                            data: (sugars) => sugars.isNotEmpty
                                ? _buildSugarSection(context, sugars)
                                : const SizedBox(),
                            loading: () => const SizedBox(),
                            error: (_, __) => const SizedBox(),
                          ),

                          const SizedBox(height: 24),

                          // Ice Level Selection
                          icesAsyncValue.when(
                            data: (ices) => ices.isNotEmpty
                                ? _buildIceSection(context, ices)
                                : const SizedBox(),
                            loading: () => const SizedBox(),
                            error: (_, __) => const SizedBox(),
                          ),

                          const SizedBox(height: 24),

                          // Extra Shot Selection
                          extraShotAsyncValue.when(
                            data: (extraShots) => extraShots.isNotEmpty
                                ? _buildExtraShotSection(context, extraShots)
                                : const SizedBox(),
                            loading: () => const SizedBox(),
                            error: (_, __) => const SizedBox(),
                          ),
                          
                          // Related Products
                          relatedProductsAsyncValue.when(
                            data: (relatedProducts) {
                              if (relatedProducts.isEmpty) return const SizedBox();
                              final filteredProducts = relatedProducts
                                  .where((p) => p.id != product.id)
                                  .toList();
                              if (filteredProducts.isEmpty) return const SizedBox();

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
                                      height: 150,
                                      child: ListView.builder(
                                        scrollDirection: Axis.horizontal,
                                        itemCount: filteredProducts.length,
                                        itemBuilder: (context, index) {
                                          final relatedProduct = filteredProducts[index];
                                          return GestureDetector(
                                            onTap: () {
                                              ref.read(selectedProductIdProvider.notifier).state = relatedProduct.id;
                                              context.pushReplacementNamed('/productDetail');
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
                  ],
                ),
              ),
            ),
          ],
        ),

        // Bottom Add to Cart Button
        bottomNavigationBar: SafeArea(
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: theme.cardColor, // Fix: Dynamic Background
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  spreadRadius: 1,
                  blurRadius: 10,
                  offset: const Offset(0, -3),
                ),
              ],
              border: Border(top: BorderSide(color: theme.dividerColor)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Subtotal",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 18,
                          color: colors.onSurface, // Fix: Dynamic
                        ),
                      ),
                      Text(
                        "\$${_calculateCurrentPrice(product, sizesAsyncValue, extraShotAsyncValue).toStringAsFixed(2)}",
                        style: TextStyle(
                          color: colors.primary, // Fix: Use Primary
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        IconButton(
                          icon: Icon(Icons.remove, size: 20, color: colors.onSurface),
                          onPressed: _quantity > 1
                              ? () => setState(() => _quantity--)
                              : null,
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          child: Text(
                            '$_quantity',
                            style: TextStyle(fontSize: 16, color: colors.onSurface),
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.add, size: 20, color: colors.onSurface),
                          onPressed: () => setState(() => _quantity++),
                        ),
                      ],
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: product.status
                            ? () => _addToCart(
                                product,
                                sizesAsyncValue,
                                sugarsAsyncValue,
                                icesAsyncValue,
                                extraShotAsyncValue,
                              )
                            : null,
                        style: ElevatedButton.styleFrom(
                          // Fix: Dynamic Button Color
                          backgroundColor: product.status
                              ? colors.primary
                              : colors.surfaceContainerHighest,
                          foregroundColor: colors.onPrimary,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          disabledBackgroundColor: colors.surfaceContainerHighest,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              product.status ? 'ADD TO CART' : 'OUT OF STOCK',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: product.status
                                    ? colors.onPrimary
                                    : colors.onSurfaceVariant,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                // View Cart Section
                Consumer(
                  builder: (context, ref, child) {
                    final cart = ref.watch(cartProvider);
                    final cartTotal = ref.watch(cartTotalProvider);

                    if (cart.isEmpty) {
                      return const SizedBox.shrink();
                    }

                    return Column(
                      children: [
                        const SizedBox(height: 16),
                        GestureDetector(
                          onTap: () => _showCartBottomSheet(context),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              // Fix: Dynamic Cart Preview Background
                              color: colors.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.shopping_cart,
                                      color: colors.primary, // Fix: Primary
                                      size: 24,
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      'View Cart (${cart.length} ${cart.length == 1 ? "item" : "items"})',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: colors.onSurface, // Fix: Dynamic
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
                                        color: colors.onSurfaceVariant,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Icon(
                                      Icons.chevron_right,
                                      color: colors.onSurfaceVariant,
                                      size: 24,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
      loading: () => Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor, // Fix: Dynamic
        body: Center(child: CircularProgressIndicator(color: colors.primary)),
      ),
      error: (error, stackTrace) => Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor, // Fix: Dynamic
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                'Error loading product',
                style: TextStyle(
                  color: colors.onSurface,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                style: TextStyle(color: colors.onSurfaceVariant),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  double _calculateCurrentPrice(
    dynamic product,
    AsyncValue<dynamic> sizesAsyncValue,
    AsyncValue<dynamic> extraShotAsyncValue,
  ) {
    double price = product.price;
    double extraShotPrice = 0;

    if (_selectedSizeId != null && sizesAsyncValue.hasValue) {
      try {
        final selectedSize = sizesAsyncValue.asData?.value.firstWhere(
          (s) => s.id == _selectedSizeId,
        );
        if (selectedSize != null) {
          price += selectedSize.priceModifier ?? 0;
        }
      } catch (e) {
        // ignore
      }
    }

    if (product.discount != null && product.discount! > 0) {
      price -= price * (product.discount! / 100);
    }

    if (_selectedExtraShotId != null && extraShotAsyncValue.hasValue) {
      try {
        final selectedExtraShot = extraShotAsyncValue.asData?.value.firstWhere(
          (e) => e.id == _selectedExtraShotId,
        );
        if (selectedExtraShot != null) {
          extraShotPrice = selectedExtraShot.priceModifier ?? 0;
        }
      } catch (e) {
        // ignore
      }
    }

    return (price + extraShotPrice) * _quantity;
  }

  Widget _buildIconButton(
    BuildContext context, {
    required IconData icon,
    required VoidCallback onPressed,
    Color? color,
  }) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: colors.surface.withOpacity(0.9), // Dynamic Surface
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(icon, color: color ?? colors.onSurface),
        onPressed: onPressed,
      ),
    );
  }

  // --- REUSABLE SELECTION WIDGETS (FIXED COLORS) ---

  Widget _buildSizeSection(BuildContext context, List sizes, int? discount) {
    final colors = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Size',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: colors.onSurface),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                // Fix: Dynamic Badge (Primary with low opacity)
                color: colors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '1 Required',
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: colors.primary),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: sizes.map((size) {
            final isSelected = _selectedSizeId == size.id;
            final hasDiscount = discount != null && discount > 0;
            final originalPrice = size.fullPrice;
            final discountedPrice = hasDiscount
                ? originalPrice - (originalPrice * discount / 100)
                : originalPrice;

            return GestureDetector(
              onTap: () => setState(() => _selectedSizeId = size.id),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  // Fix: Dynamic Selection Background
                  color: isSelected
                      ? colors.primary.withOpacity(0.1)
                      : colors.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? colors.primary : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 8),
                    Text(
                      size.sizeName == "large"
                          ? "L"
                          : size.sizeName == "medium"
                              ? "M"
                              : "S",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isSelected
                            ? colors.primary
                            : colors.onSurface, // Fix Text Color
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (hasDiscount)
                      Column(
                        children: [
                          Text(
                            '\$${originalPrice.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 11,
                              decoration: TextDecoration.lineThrough,
                              color: colors.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '\$${discountedPrice.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: colors.error,
                            ),
                          ),
                        ],
                      )
                    else
                      Text(
                        '\$${originalPrice.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 14,
                          color: isSelected
                              ? colors.onSurface
                              : colors.onSurfaceVariant,
                        ),
                      ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSugarSection(BuildContext context, List sugars) {
    final colors = Theme.of(context).colorScheme;
    final sugarIcons = {
      'No Sweet': Icons.block,
      'Less Sweet': Icons.grain,
      'Normal Sweet': Icons.eco,
      'More Sweet': Icons.energy_savings_leaf,
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Sugar Level',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: colors.onSurface),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: colors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '1 Required',
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: colors.primary),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: sugars.map((sugar) {
            final isSelected = _selectedSugarId == sugar.id;
            final icon = sugarIcons[sugar.name] ?? Icons.water_drop;
            return GestureDetector(
              onTap: () => setState(() => _selectedSugarId = sugar.id),
              child: Container(
                width: 80,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: isSelected
                      ? colors.primary.withOpacity(0.1)
                      : colors.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? colors.primary : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      icon,
                      size: 32,
                      color: isSelected
                          ? colors.primary
                          : colors.onSurfaceVariant,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      sugar.name,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: isSelected
                            ? colors.onSurface
                            : colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildIceSection(BuildContext context, List ices) {
    final colors = Theme.of(context).colorScheme;
    final iceIcons = {
      'Less Ice': Icons.ac_unit_outlined,
      'No Ice': Icons.block,
      'Normal Ice': Icons.ac_unit,
      'More Ice': Icons.severe_cold,
      'Ice Separate': Icons.ice_skating,
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Ice Level',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: colors.onSurface),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: colors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '1 Required',
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: colors.primary),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: ices.map((ice) {
            final isSelected = _selectedIceId == ice.id;
            final icon = iceIcons[ice.name] ?? Icons.ac_unit;
            return GestureDetector(
              onTap: () => setState(() => _selectedIceId = ice.id),
              child: Container(
                width: 80,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: isSelected
                      ? colors.primary.withOpacity(0.1)
                      : colors.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? colors.primary : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      icon,
                      size: 32,
                      color: isSelected ? colors.primary : colors.onSurfaceVariant,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      ice.name,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: isSelected ? colors.onSurface : colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildExtraShotSection(BuildContext context, List extraShots) {
    final colors = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Extra Shot',
          style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: colors.onSurface),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: extraShots.map((extraShot) {
            final isSelected = _selectedExtraShotId == extraShot.id;
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedExtraShotId = isSelected ? null : extraShot.id;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? colors.primary.withOpacity(0.1)
                      : colors.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? colors.primary : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.coffee_maker,
                      size: 24,
                      color: isSelected ? colors.primary : colors.onSurfaceVariant,
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          extraShot.name,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isSelected
                                ? colors.onSurface
                                : colors.onSurfaceVariant,
                          ),
                        ),
                        if (extraShot.priceModifier > 0)
                          Text(
                            '+\$${extraShot.priceModifier.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 12,
                              color: isSelected
                                  ? colors.onSurface
                                  : colors.onSurfaceVariant,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  void _addToCart(
    dynamic product,
    AsyncValue<dynamic> sizesAsyncValue,
    AsyncValue<dynamic> sugarsAsyncValue,
    AsyncValue<dynamic> icesAsyncValue,
    AsyncValue<dynamic> extraShotAsyncValue,
  ) {
    if (_selectedSizeId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select a size'),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final selectedSize = sizesAsyncValue.asData?.value.firstWhere(
      (s) => s.id == _selectedSizeId,
    );

    final selectedSugar =
        _selectedSugarId != null &&
            sugarsAsyncValue.asData?.value.isNotEmpty == true
        ? sugarsAsyncValue.asData?.value.firstWhere(
            (s) => s.id == _selectedSugarId,
          )
        : null;

    final selectedIce =
        _selectedIceId != null &&
            icesAsyncValue.asData?.value.isNotEmpty == true
        ? icesAsyncValue.asData?.value.firstWhere((i) => i.id == _selectedIceId)
        : null;

    final selectedExtraShot =
        _selectedExtraShotId != null &&
            extraShotAsyncValue.asData?.value.isNotEmpty == true
        ? extraShotAsyncValue.asData?.value.firstWhere(
            (e) => e.id == _selectedExtraShotId,
          )
        : null;

    final cartItem = CartModel(
      productId: product.id,
      productName: product.name,
      image: product.image,
      basePrice: product.price,
      discount: product.discount,
      quantity: _quantity,
      size: CartOption(
        id: selectedSize.id,
        name: selectedSize.sizeName,
        price: selectedSize.priceModifier,
      ),
      sugar: selectedSugar != null
          ? CartOption(id: selectedSugar.id, name: selectedSugar.name)
          : null,
      ice: selectedIce != null
          ? CartOption(id: selectedIce.id, name: selectedIce.name)
          : null,
      extraShot: selectedExtraShot != null
          ? CartOption(
              id: selectedExtraShot.id,
              name: selectedExtraShot.name,
              price: selectedExtraShot.priceModifier,
            )
          : null,
    );

    ref.read(cartProvider.notifier).addToCart(cartItem);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$_quantity x ${product.name} added to cart'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );

    setState(() {
      _quantity = 1;
      _selectedSizeId = null;
      _selectedSugarId = null;
      _selectedIceId = null;
      _selectedExtraShotId = null;
    });
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
              color: theme.cardColor, // Fix: Dynamic Background
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
                      color: theme.cardColor, // Fix: Dynamic Background
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
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
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Proceeding to checkout'),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
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