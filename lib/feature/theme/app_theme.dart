import 'package:flutter/material.dart';

class AppTheme {
  // 1. Define Custom Colors for LIGHT Mode
  static const _lightAppColors = AppColors(
    categoryColor: Color(0xFF757575), // Colors.grey[600]
    statusSuccess: Color(0xFF4CAF50), // Green for success/completed
    statusWarning: Color(0xFFFF9800), // Orange for pending/warning
    statusError: Color(0xFFE53935), // Red for error/cancelled
    statusInfo: Color(0xFF2196F3), // Blue for info
    statusNeutral: Color(0xFF9E9E9E), // Grey for neutral
    feedbackAccent: Color(0xFFFF6B6B), // Pink/red for feedback button
    progressActive: Color(0xFFFFC107), // Amber for active progress
  );

  // 2. Define Custom Colors for DARK Mode
  static const _darkAppColors = AppColors(
    categoryColor: Color(0xFFE0E0E0), // Colors.grey[300]
    statusSuccess: Color(0xFF66BB6A), // Lighter green for dark mode
    statusWarning: Color(0xFFFFB74D), // Lighter orange for dark mode
    statusError: Color(0xFFEF5350), // Lighter red for dark mode
    statusInfo: Color(0xFF42A5F5), // Lighter blue for dark mode
    statusNeutral: Color(0xFFBDBDBD), // Lighter grey for dark mode
    feedbackAccent: Color(0xFFFF8A80), // Lighter pink for dark mode
    progressActive: Color(0xFFFFD54F), // Lighter amber for dark mode
  );

  // --- LIGHT THEME ---
  static final ThemeData lightTheme = ThemeData.light().copyWith(
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.orange,
      brightness: Brightness.light,
    ),
    extensions: [_lightAppColors], // Inject custom colors
  );

  // --- DARK THEME ---
  static final ThemeData darkTheme = ThemeData.dark().copyWith(
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.orange,
      brightness: Brightness.dark,
    ),
    extensions: [_darkAppColors], // Inject custom colors
  );
}

// --- THEME EXTENSION CLASS ---
@immutable
class AppColors extends ThemeExtension<AppColors> {
  final Color categoryColor;
  final Color statusSuccess;
  final Color statusWarning;
  final Color statusError;
  final Color statusInfo;
  final Color statusNeutral;
  final Color feedbackAccent;
  final Color progressActive;

  const AppColors({
    required this.categoryColor,
    required this.statusSuccess,
    required this.statusWarning,
    required this.statusError,
    required this.statusInfo,
    required this.statusNeutral,
    required this.feedbackAccent,
    required this.progressActive,
  });

  @override
  AppColors copyWith({
    Color? categoryColor,
    Color? statusSuccess,
    Color? statusWarning,
    Color? statusError,
    Color? statusInfo,
    Color? statusNeutral,
    Color? feedbackAccent,
    Color? progressActive,
  }) {
    return AppColors(
      categoryColor: categoryColor ?? this.categoryColor,
      statusSuccess: statusSuccess ?? this.statusSuccess,
      statusWarning: statusWarning ?? this.statusWarning,
      statusError: statusError ?? this.statusError,
      statusInfo: statusInfo ?? this.statusInfo,
      statusNeutral: statusNeutral ?? this.statusNeutral,
      feedbackAccent: feedbackAccent ?? this.feedbackAccent,
      progressActive: progressActive ?? this.progressActive,
    );
  }

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) return this;
    return AppColors(
      categoryColor: Color.lerp(categoryColor, other.categoryColor, t)!,
      statusSuccess: Color.lerp(statusSuccess, other.statusSuccess, t)!,
      statusWarning: Color.lerp(statusWarning, other.statusWarning, t)!,
      statusError: Color.lerp(statusError, other.statusError, t)!,
      statusInfo: Color.lerp(statusInfo, other.statusInfo, t)!,
      statusNeutral: Color.lerp(statusNeutral, other.statusNeutral, t)!,
      feedbackAccent: Color.lerp(feedbackAccent, other.feedbackAccent, t)!,
      progressActive: Color.lerp(progressActive, other.progressActive, t)!,
    );
  }
}

// Extension to easily access AppColors from Theme
extension AppColorsExtension on ThemeData {
  AppColors get appColors => extension<AppColors>()!;
}