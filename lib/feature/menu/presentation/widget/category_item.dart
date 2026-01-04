import 'package:flutter/material.dart';
import 'package:island_cafe/feature/product/data/model/category_model.dart';
import 'package:island_cafe/feature/theme/app_theme.dart'; // Import AppTheme

class CategoryItem extends StatelessWidget {
  final CategoryModel category;
  final bool isSelected;
  final VoidCallback onTap;

  const CategoryItem({
    super.key,
    required this.category,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    
    // 1. GET YOUR NEW DYNAMIC COLOR
    final categoryColor = Theme.of(context).extension<AppColors>()?.categoryColor ?? 
        Theme.of(context).colorScheme.onSurface;

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? primaryColor.withValues(alpha: 0.1)
              : Colors.transparent,
          border: Border(
            left: BorderSide(
              color: isSelected ? primaryColor : Colors.transparent,
              width: 3,
            ),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            category.image.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: Image.network(
                      category.image,
                      width: 20,
                      height: 20,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Icon(
                        Icons.category,
                        // 2. Use it here
                        color: isSelected ? primaryColor : categoryColor,
                        size: 20,
                      ),
                    ),
                  )
                : Icon(
                    Icons.category,
                    // 3. Use it here
                    color: isSelected ? primaryColor : categoryColor,
                    size: 20,
                  ),
            const SizedBox(height: 8),
            Text(
              category.name,
              textAlign: TextAlign.center,
              style: TextStyle(
                // 4. Use it here
                color: isSelected ? primaryColor : categoryColor,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}