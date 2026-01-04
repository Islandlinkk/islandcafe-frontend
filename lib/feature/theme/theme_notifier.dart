import 'package:flutter/material.dart';
import 'package:hive_ce/hive.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

// 1. This connects to the generated file.
// IMPORTANT: This will be red/error until you run the generator command.
part 'theme_notifier.g.dart'; 

@riverpod
class ThemeNotifier extends _$ThemeNotifier {
  @override
  ThemeMode build() {
    final box = Hive.box('voucher_box');
    final savedTheme = box.get('theme_mode', defaultValue: 'system');
    return ThemeMode.values.firstWhere(
      (e) => e.name == savedTheme, 
      orElse: () => ThemeMode.system
    );
  }

  void setTheme(ThemeMode mode) {
    state = mode;
    final box = Hive.box('voucher_box');
    box.put('theme_mode', mode.name); 
  }
}