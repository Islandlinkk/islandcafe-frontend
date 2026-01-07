import 'package:flutter/material.dart';
import 'package:hive_ce/hive.dart'; // Import hive_ce
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'theme_notifier.g.dart';

@riverpod
class ThemeNotifier extends _$ThemeNotifier {
  // Define the box name and key
  static const _boxName = 'settings';
  static const _key = 'theme_mode';

  @override
  ThemeMode build() {
    // 1. Get the already opened box
    final box = Hive.box(_boxName);

    // 2. Read the saved string (defaults to null if not found)
    final savedString = box.get(_key) as String?;

    // 3. Convert String -> ThemeMode
    if (savedString == 'light') return ThemeMode.light;
    if (savedString == 'dark') return ThemeMode.dark;
    
    // Default if nothing is saved
    return ThemeMode.system;
  }

  void setTheme(ThemeMode mode) {
    // 1. Update UI immediately
    state = mode;

    // 2. Save to Hive
    final box = Hive.box(_boxName);
    box.put(_key, mode.name); // Saves 'light', 'dark', or 'system'
  }
}