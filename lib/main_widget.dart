import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:island_cafe/core/route/go_router_provider.dart';
import 'package:island_cafe/feature/theme/app_theme.dart';
import 'package:island_cafe/feature/theme/theme_notifier.dart';

class MainWidget extends ConsumerWidget {
  const MainWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. Watch the Router (Navigation)
    final goRouter = ref.watch(goRouterProvider);
    
    // 2. Watch the Theme (Appearance)
    // This provider comes from the generated 'theme_notifier.g.dart' file
    final themeMode = ref.watch(themeProvider); 

    return MaterialApp.router(
      title: 'Island Cafe',
      debugShowCheckedModeBanner: false,
      
      // 3. Connect the Themes
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      
      // 4. Apply the Current Mode (Light/Dark/System)
      themeMode: themeMode, 
      
      // 5. Connect the Router
      routerConfig: goRouter,
    );
  }
}