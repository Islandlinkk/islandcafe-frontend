import 'package:flutter/material.dart';

class AppTheme {
  // 1. Define Custom Colors for LIGHT Mode (Dark Grey for contrast)
  static const _lightAppColors = AppColors(
    categoryColor: Color(0xFF757575), // Colors.grey[600]
  );

  // 2. Define Custom Colors for DARK Mode (Bright Grey for visibility)
  static const _darkAppColors = AppColors(
    categoryColor: Color(0xFFE0E0E0), // Colors.grey[300]
  );

  // --- LIGHT THEME ---
  static final ThemeData lightTheme = ThemeData.light().copyWith(
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.orange, // <--- CHANGED BACK TO ORANGE
      brightness: Brightness.light,
    ),
    extensions: [_lightAppColors], // Inject custom colors
  );

  // --- DARK THEME ---
  static final ThemeData darkTheme = ThemeData.dark().copyWith(
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.orange, // <--- CHANGED BACK TO ORANGE
      brightness: Brightness.dark,
    ),
    extensions: [_darkAppColors], // Inject custom colors
  );
}

// --- THEME EXTENSION CLASS ---
@immutable
class AppColors extends ThemeExtension<AppColors> {
  final Color categoryColor;

  const AppColors({required this.categoryColor});

  @override
  AppColors copyWith({Color? categoryColor}) {
    return AppColors(
      categoryColor: categoryColor ?? this.categoryColor,
    );
  }

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) return this;
    return AppColors(
      categoryColor: Color.lerp(categoryColor, other.categoryColor, t)!,
    );
  }
}