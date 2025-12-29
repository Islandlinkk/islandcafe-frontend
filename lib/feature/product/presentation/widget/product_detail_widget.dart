import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:island_cafe/feature/cart/data/model/cart_model.dart';
import 'package:island_cafe/feature/cart/data/provider/cart_notifier.dart';
import 'package:island_cafe/feature/cart/data/provider/cart_total_provider.dart';
import 'package:island_cafe/feature/product/data/provider/extraShot_provider.dart';
import 'package:island_cafe/feature/product/data/provider/ice_provider.dart';
import 'package:island_cafe/feature/product/data/provider/product_provider.dart';
import 'package:island_cafe/feature/product/data/provider/size_provider.dart';
import 'package:island_cafe/feature/product/data/provider/sugar_provider.dart';
import 'package:island_cafe/feature/product/presentation/widget/cart_item_widget.dart';

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
    final productAsyncValue = ref.watch(productByIdProvider);
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
        sizesAsyncValue.isLoading ||
        sugarsAsyncValue.isLoading ||
        icesAsyncValue.isLoading ||
        extraShotAsyncValue.isLoading;

    // Set default selections only when data is loaded
    if (!isLoading) {
      if (sizesAsyncValue.asData?.value.isNotEmpty == true &&
          _selectedSizeId == null) {
        Future.microtask(() {
          setState(() {
            _selectedSizeId = sizesAsyncValue.asData!.value.first.id;
          });
        });
      }
      if (sugarsAsyncValue.asData?.value.isNotEmpty == true &&
          _selectedSugarId == null) {
        Future.microtask(() {
          setState(() {
            _selectedSugarId = sugarsAsyncValue.asData!.value[1].id;
          });
        });
      }
      if (icesAsyncValue.asData?.value.isNotEmpty == true &&
          _selectedIceId == null) {
        Future.microtask(() {
          setState(() {
            _selectedIceId = icesAsyncValue.asData!.value[1].id;
          });
        });
      }
    }

    // Show loading screen until all data is loaded
    if (isLoading) {
      return const Scaffold(
        backgroundColor: Colors.grey,
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFFFFC107)),
        ),
      );
    }

    return productAsyncValue.when(
      data: (product) => Scaffold(
        backgroundColor: Colors.grey[50],
        extendBodyBehindAppBar: true,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: _showAppBar ? Colors.white : Colors.transparent,
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
                      icon: Icons.arrow_back,
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    if (_showAppBar)
                      Expanded(
                        child: Text(
                          product.name,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      )
                    else
                      const Spacer(),
                    _buildIconButton(
                      icon: _isFavorite
                          ? Icons.favorite
                          : Icons.favorite_border,
                      color: _isFavorite ? const Color(0xFFFFC107) : null,
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
                    ClipRRect(
                      child: Image.network(
                        product.image,
                        width: double.infinity,
                        height: 300,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: Colors.grey[300],
                          child: const Icon(
                            Icons.image_not_supported,
                            size: 80,
                          ),
                        ),
                      ),
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
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 12),

                          // Description
                          Text(
                            product.description,
                            style: TextStyle(
                              color: Colors.black54,
                              fontSize: 14,
                              height: 1.5,
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Size Selection
                          sizesAsyncValue.when(
                            data: (sizes) => _buildSizeSection(sizes),
                            loading: () => const SizedBox(),
                            error: (_, __) => const SizedBox(),
                          ),

                          const SizedBox(height: 24),

                          // Sugar Level Selection
                          sugarsAsyncValue.when(
                            data: (sugars) => sugars.isNotEmpty
                                ? _buildSugarSection(sugars)
                                : const SizedBox(),
                            loading: () => const SizedBox(),
                            error: (_, __) => const SizedBox(),
                          ),

                          const SizedBox(height: 24),

                          // Ice Level Selection
                          icesAsyncValue.when(
                            data: (ices) => ices.isNotEmpty
                                ? _buildIceSection(ices)
                                : const SizedBox(),
                            loading: () => const SizedBox(),
                            error: (_, __) => const SizedBox(),
                          ),

                          const SizedBox(height: 24),

                          // Extra Shot Selection
                          extraShotAsyncValue.when(
                            data: (extraShots) => extraShots.isNotEmpty
                                ? _buildExtraShotSection(extraShots)
                                : const SizedBox(),
                            loading: () => const SizedBox(),
                            error: (_, __) => const SizedBox(),
                          ),

                          const SizedBox(height: 100),
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
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  spreadRadius: 1,
                  blurRadius: 10,
                  offset: const Offset(0, -3),
                ),
              ],
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
                        ),
                      ),
                      Text(
                        "\$${_calculateCurrentPrice(product, sizesAsyncValue, extraShotAsyncValue).toStringAsFixed(2)}",
                        style: TextStyle(
                          color: Colors.black54,
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
                          icon: const Icon(Icons.remove, size: 20),
                          onPressed: _quantity > 1
                              ? () {
                                  setState(() {
                                    _quantity--;
                                  });
                                }
                              : null,
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          child: Text(
                            '$_quantity',
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add, size: 20),
                          onPressed: () {
                            setState(() {
                              _quantity++;
                            });
                          },
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
                          backgroundColor: product.status
                              ? const Color(0xFFFFC107)
                              : Colors.grey,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          disabledBackgroundColor: Colors.grey[400],
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
                                    ? Colors.black
                                    : Colors.white,
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
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.shopping_cart,
                                      color: Color(0xFFFFC107),
                                      size: 24,
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      'View Cart (${cart.length} ${cart.length == 1 ? "item" : "items"})',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Text(
                                      '\$${cartTotal.toStringAsFixed(2)}',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black54,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Icon(
                                      Icons.chevron_right,
                                      color: Colors.grey[400],
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
              ],
            ),
          ),
        ),
      ),
      loading: () => const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator(color: Colors.blue)),
      ),
      error: (error, stackTrace) => Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              const Text(
                'Error loading product',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                style: TextStyle(color: Colors.grey[400]),
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

    // Add size price modifier
    if (_selectedSizeId != null && sizesAsyncValue.hasValue) {
      try {
        final selectedSize = sizesAsyncValue.asData?.value.firstWhere(
          (s) => s.id == _selectedSizeId,
        );
        if (selectedSize != null) {
          price += selectedSize.priceModifier ?? 0;
        }
      } catch (e) {
        // Size not found, continue with base price
      }
    }

    // Add extra shot price modifier
    if (_selectedExtraShotId != null && extraShotAsyncValue.hasValue) {
      try {
        final selectedExtraShot = extraShotAsyncValue.asData?.value.firstWhere(
          (e) => e.id == _selectedExtraShotId,
        );
        if (selectedExtraShot != null) {
          price += selectedExtraShot.priceModifier ?? 0;
        }
      } catch (e) {
        // Extra shot not found, continue without it
      }
    }

    // Apply discount
    if (product.discount != null && product.discount! > 0) {
      price -= price * (product.discount! / 100);
    }

    // Multiply by quantity
    return price * _quantity;
  }

  Widget _buildIconButton({
    required IconData icon,
    required VoidCallback onPressed,
    Color? color,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
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
        icon: Icon(icon, color: color ?? Colors.grey[800]),
        onPressed: onPressed,
      ),
    );
  }

  Widget _buildSizeSection(List sizes) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Size',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF3CD),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                '1 Required',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
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
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedSizeId = size.id;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFFFFF3CD)
                      : Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFFFFC107)
                        : Colors.transparent,
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
                        color: isSelected ? Colors.black : Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '\$${size.fullPrice.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 14,
                        color: isSelected ? Colors.black87 : Colors.grey[600],
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

  Widget _buildSugarSection(List sugars) {
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
            const Text(
              'Sugar Level',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF3CD),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                '1 Required',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
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
              onTap: () {
                setState(() {
                  _selectedSugarId = sugar.id;
                });
              },
              child: Container(
                width: 80,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFFFFF3CD)
                      : Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFFFFC107)
                        : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      icon,
                      size: 32,
                      color: isSelected
                          ? const Color(0xFFFFC107)
                          : Colors.grey[400],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      sugar.name,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: isSelected ? Colors.black : Colors.grey[600],
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

  Widget _buildIceSection(List ices) {
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
            const Text(
              'Ice Level',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF3CD),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                '1 Required',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
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
              onTap: () {
                setState(() {
                  _selectedIceId = ice.id;
                });
              },
              child: Container(
                width: 80,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFFFFF3CD)
                      : Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFFFFC107)
                        : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      icon,
                      size: 32,
                      color: isSelected ? Colors.blue : Colors.grey[400],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      ice.name,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: isSelected ? Colors.black : Colors.grey[600],
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

  Widget _buildExtraShotSection(List extraShots) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Extra Shot',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                      ? const Color(0xFFFFF3CD)
                      : Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFFFFC107)
                        : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.coffee_maker,
                      size: 24,
                      color: isSelected
                          ? const Color(0xFFFFC107)
                          : Colors.grey[400],
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
                            color: isSelected ? Colors.black : Colors.grey[600],
                          ),
                        ),
                        if (extraShot.priceModifier > 0)
                          Text(
                            '+\$${extraShot.priceModifier.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 12,
                              color: isSelected
                                  ? Colors.black87
                                  : Colors.grey[500],
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
    // Validation
    if (_selectedSizeId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a size'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // Get selected options
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

    // Create cart item
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

    // Add to cart
    ref.read(cartProvider.notifier).addToCart(cartItem);

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$_quantity x ${product.name} added to cart'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );

    // Reset selections and quantity
    setState(() {
      _quantity = 1;
      _selectedSizeId = null;
      _selectedSugarId = null;
      _selectedIceId = null;
      _selectedExtraShotId = null;
    });
  }

  void _showCartBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Consumer(
        builder: (context, ref, child) {
          final cart = ref.watch(cartProvider);
          final cartTotal = ref.watch(cartTotalProvider);

          return Container(
            height: MediaQuery.of(context).size.height * 1,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Column(
              children: [
                // Handle bar
                Container(
                  margin: const EdgeInsets.only(top: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),

                // Header
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Cart (${cart.length})',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),

                const Divider(height: 1),

                // Cart Items
                Expanded(
                  child: cart.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.shopping_cart_outlined,
                                size: 80,
                                color: Colors.grey[300],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Your cart is empty',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey[500],
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

                // Bottom Section
                if (cart.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3),
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
                            const Text(
                              'Total',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '\$${cartTotal.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
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
                            backgroundColor: const Color(0xFFFFC107),
                            foregroundColor: Colors.black,
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
