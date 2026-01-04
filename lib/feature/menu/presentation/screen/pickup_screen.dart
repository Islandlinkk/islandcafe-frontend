import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/rendering.dart';
import 'package:island_cafe/feature/product/data/provider/category_provider.dart';
import 'package:island_cafe/feature/product/data/provider/product_provider.dart';
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
                      Icon(Icons.search_off, size: 64, color: Theme.of(context).colorScheme.onSurface),
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
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
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
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(fontWeight: FontWeight.bold),
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
            return Row(
              children: [
                Container(
                  width: 120,
                  decoration: BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    border: Border(right: BorderSide(color: Theme.of(context).dividerColor)),
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
                          WidgetsBinding.instance.addPostFrameCallback((_) {
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
                                        ?.copyWith(fontWeight: FontWeight.bold),
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
                                  (item) =>
                                      MenuItemCard(item: item, onTap: () {}),
                                ),
                            const SizedBox(height: 16),
                          ],
                        ],
                      ),
                    ),
                  ),
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
}
