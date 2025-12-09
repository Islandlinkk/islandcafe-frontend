import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:island_cafe/feature/menu/data/menu_data.dart';
import 'package:island_cafe/feature/menu/presentation/widget/category_item.dart';
import 'package:island_cafe/feature/menu/presentation/widget/menu_item_card.dart';

class MenuScreen extends ConsumerStatefulWidget {
  const MenuScreen({super.key});

  @override
  ConsumerState<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends ConsumerState<MenuScreen> {
  String selectedCategoryId = MenuData.categories.first.id;
  String selectedOrderType = 'Pickup'; // 'Pickup' or 'Delivery'
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final blueColor = Colors.blue;
    final selectedItems = MenuData.getItemsByCategory(selectedCategoryId);
    final selectedCategory = MenuData.categories.firstWhere(
      (cat) => cat.id == selectedCategoryId,
    );

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar
            _buildTopBar(context, blueColor),
            // Location Selector
            _buildLocationSelector(context, blueColor),
            // Main Content
            Expanded(
              child: Row(
                children: [
                  // Categories Sidebar
                  Container(
                    width: 140,

                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      border: Border(
                        right: BorderSide(color: Colors.grey[300]!),
                      ),
                    ),
                    child: ListView.builder(
                      itemCount: MenuData.categories.length,
                      itemBuilder: (context, index) {
                        final category = MenuData.categories[index];
                        return CategoryItem(
                          category: category,
                          isSelected: category.id == selectedCategoryId,
                          onTap: () {
                            setState(() {
                              selectedCategoryId = category.id;
                            });
                          },
                        );
                      },
                    ),
                  ),
                  // Menu Items
                  Expanded(
                    child: ListView(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(16),
                      children: [
                        // Category Header
                        Row(
                          children: [
                            Icon(
                              selectedCategory.icon,
                              color: blueColor,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              selectedCategory.name,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Menu Items List
                        ...selectedItems.map(
                          (item) => MenuItemCard(
                            item: item,
                            onTap: () {
                              // Handle item tap - could navigate to detail screen
                            },
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context, Color blueColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey[200]!),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'MENU',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              IconButton(
                icon: const Icon(Icons.search),
                onPressed: () {
                  // Handle search
                },
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Pickup/Delivery Toggle
          Row(
            children: [
              Expanded(
                child: _buildOrderTypeButton(
                  context,
                  'Pickup',
                  selectedOrderType == 'Pickup',
                  blueColor,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildOrderTypeButton(
                  context,
                  'Delivery',
                  selectedOrderType == 'Delivery',
                  blueColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOrderTypeButton(
    BuildContext context,
    String label,
    bool isSelected,
    Color blueColor,
  ) {
    return InkWell(
      onTap: () {
        setState(() {
          selectedOrderType = label;
        });
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
            color: isSelected ? blueColor : Colors.grey[600],
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildLocationSelector(BuildContext context, Color blueColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey[200]!),
        ),
      ),
      // child: Row(
      //   children: [
      //     Text(
      //       'TOUL KORK',
      //       style: TextStyle(
      //         color: blueColor,
      //         fontWeight: FontWeight.w600,
      //       ),
      //     ),
      //     const SizedBox(width: 4),
      //     Icon(
      //       Icons.add,
      //       color: blueColor,
      //       size: 20,
      //     ),
      //     const Spacer(),
      //     Icon(
      //       Icons.keyboard_arrow_down,
      //       color: blueColor,
      //       size: 20,
      //     ),
      //   ],
      // ),
    );
  }
}