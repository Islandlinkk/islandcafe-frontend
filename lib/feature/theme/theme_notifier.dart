import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

// 1. This connects to the generated file.
// IMPORTANT: This will be red/error until you run the generator command.
part 'theme_notifier.g.dart'; 

@riverpod
class ThemeNotifier extends _$ThemeNotifier {
  @override
  ThemeMode build() {
    // Default to System (uses phone settings)
    return ThemeMode.system; 
  }

  // Called by the Settings Screen to change the theme
  void setTheme(ThemeMode mode) {
    state = mode;
  }
}