import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class RootBottomnavigationScreen extends ConsumerWidget {
  final Widget child;
  const RootBottomnavigationScreen({super.key, required this.child});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location = GoRouterState.of(context).uri.toString();

    int currentIndex = 0;
    if (location.startsWith('/home')) currentIndex = 0;
    if (location.startsWith('/menu')) currentIndex = 1;
    if (location.startsWith('/history')) currentIndex = 2;
    if (location.startsWith('/profile')) currentIndex = 3;

    void onTap(int index) {
      if (index == 0) context.go('/home');
      if (index == 1) context.go('/menu');
      if (index == 2) context.go('/history');
      if (index == 3) context.go('/profile');
    }

    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        indicatorColor: Colors.transparent,
        onDestinationSelected: onTap,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home, color: Colors.grey),
            selectedIcon: Icon(Icons.home, color: Colors.blue),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.menu, color: Colors.grey),
            selectedIcon: Icon(Icons.menu, color: Colors.blue),
            label: 'Menu',
          ),
          NavigationDestination(
            icon: Icon(Icons.history, color: Colors.grey),
            selectedIcon: Icon(Icons.history, color: Colors.blue),
            label: 'History',
          ),
          NavigationDestination(
            icon: Icon(Icons.person, color: Colors.grey),
            selectedIcon: Icon(Icons.person, color: Colors.blue),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
