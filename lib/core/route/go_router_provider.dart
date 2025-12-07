import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:islandlink_frontend/core/route/route_name.dart';
import 'package:islandlink_frontend/feature/history/presentation/screen/history_screen.dart';
import 'package:islandlink_frontend/feature/home/presentation/screen/home_screen.dart';
import 'package:islandlink_frontend/feature/menu/presentation/screen/menu_screen.dart';
import 'package:islandlink_frontend/feature/profile/presentation/screen/profile_screen.dart';
import 'package:islandlink_frontend/root/root_BottomNavigation_screen.dart';

final goRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: homeRoute,
    routes: [
      //Bottom navigation routes
      ShellRoute(
        builder: (context, state, child) =>
            RootBottomnavigationScreen(child: child),
        routes: [
          GoRoute(
            path: "/home",
            name: homeRoute,
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: "/menu",
            name: menuRoute,
            builder: (context, state) => const MenuScreen(),
          ),
          GoRoute(
            path: '/history',
            name: historyRoute,
            builder: (context, state) => const HistoryScreen(),
          ),
          GoRoute(
            path: '/profile',
            name: profileRoute,
            builder: (context, state) => const ProfileScreen(),
          ),
        ],
      ),
    ],
  );
});
