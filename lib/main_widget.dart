import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:island_cafe/core/route/go_router_provider.dart';
import 'package:island_cafe/feature/theme/app_theme.dart';
import 'package:island_cafe/feature/theme/theme_notifier.dart';
import 'package:island_cafe/feature/theme/splash_screen.dart';

class MainWidget extends ConsumerStatefulWidget {
  const MainWidget({super.key});

  @override
  ConsumerState<MainWidget> createState() => _MainWidgetState();
}

class _MainWidgetState extends ConsumerState<MainWidget> {
  bool _showSplash = true;

  void _onSplashComplete() {
    setState(() {
      _showSplash = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Show splash screen first
    if (_showSplash) {
      return MaterialApp(
        title: 'Island Cafe',
        debugShowCheckedModeBanner: false,
        home: SplashScreen(onComplete: _onSplashComplete),
      );
    }

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