
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';

final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeMode>((ref) {
  return ThemeNotifier();
});
class ThemeNotifier extends StateNotifier<ThemeMode> {
 ThemeNotifier(): super(ThemeMode.system);

 void toggleTheme(bool isDark){
  state = isDark? ThemeMode.dark : ThemeMode.light;
 }
}