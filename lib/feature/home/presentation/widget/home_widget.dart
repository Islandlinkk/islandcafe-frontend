import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:islandlink_frontend/feature/theme/theme_notifier.dart';

class HomeWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text("Theme Demo"),
        actions: [
          Switch(
            value: themeMode == ThemeMode.dark,
            onChanged: (value) {
              ref.read(themeProvider.notifier).toggleTheme(value);
            },
          )
        ],
      ),
      body: Center(child: Text("Toggle the switch")),
    );
  }
}
