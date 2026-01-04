import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:go_router/go_router.dart';
import 'package:island_cafe/core/route/route_name.dart';
import 'package:island_cafe/feature/announcement/presentation/screen/announcement_detail_screen.dart';
import 'package:island_cafe/feature/announcement/presentation/screen/announcement_screen.dart';
import 'package:island_cafe/feature/auth/data/providers/auth_provider.dart';
import 'package:island_cafe/feature/auth/presentation/screens/forgot_password_screen.dart';
import 'package:island_cafe/feature/auth/presentation/screens/login_screen.dart';
import 'package:island_cafe/feature/auth/presentation/screens/signup_screen.dart';
import 'package:island_cafe/feature/auth/presentation/screens/verify_email.dart';
import 'package:island_cafe/feature/history/presentation/screen/history_screen.dart';
import 'package:island_cafe/feature/home/presentation/screen/home_screen.dart';
import 'package:island_cafe/feature/menu/presentation/screen/menu_screen.dart';
import 'package:island_cafe/feature/product/presentation/screen/product_detail_screen.dart';
import 'package:island_cafe/feature/profile/presentation/screen/edit_profile_screen.dart';
import 'package:island_cafe/feature/profile/presentation/screen/profile_screen.dart';
import 'package:island_cafe/feature/profile/presentation/screen/settings_screen.dart';
import 'package:island_cafe/feature/profile/presentation/screen/favorites_screen.dart';
import 'package:island_cafe/feature/voucher/presentation/screen/voucher_screen.dart';
import 'package:island_cafe/root/root_BottomNavigation_screen.dart';
import 'package:island_cafe/feature/theme/loading_screen.dart';
import 'package:island_cafe/feature/auth/services/auth_service.dart';

final routerRefreshTriggerProvider = StateProvider<int>((ref) => 0);

class RouterNotifier extends ChangeNotifier {
  final Ref _ref;
  RouterNotifier(this._ref) {
    _ref.listen(authStateProvider, (_, _) => notifyListeners());
    _ref.listen(isProfileCompleteProvider, (_, _) => notifyListeners());
    _ref.listen(routerRefreshTriggerProvider, (_, _) => notifyListeners());
  }
}

final goRouterProvider = Provider<GoRouter>((ref) {
  final notifier = RouterNotifier(ref);

  return GoRouter(
    initialLocation: '/home',
    debugLogDiagnostics: true,
    refreshListenable: notifier,
    redirect: (context, state) {
      final String location = state.uri.toString();
      if (location.startsWith('com.googleusercontent.apps')) {
        return '/login';
      }
      final authState = ref.read(authStateProvider);
      final profileState = ref.read(isProfileCompleteProvider);
      final liveUser = AuthService.currentUser;
      final isLoggedIn = liveUser != null;

      final path = state.uri.path;

      // Define Restricted Routes
      final isStrictlyProtected =
          path.startsWith('/history') ||
          path.startsWith('/favorites') ||
          path.startsWith('/settings') ||
          path.startsWith('/edit-profile');

      final isAuthRoute =
          path == '/login' || path == '/signup' || path == '/forgot-password';
      final isVerifyRoute = path == '/verify-email';

      // 1. Loading State
      if (authState.isLoading || profileState.isLoading) return null;

      // 2. UNAUTHENTICATED FLOW (Guest)
      if (!isLoggedIn) {
        if (isStrictlyProtected) return '/login';
        return null;
      }

      // 3. AUTHENTICATED FLOW
      if (!liveUser.emailVerified) {
        if (!isVerifyRoute) return '/verify-email';
        return null;
      }

      // If logged in and verified, prevent access to auth pages
      if (isAuthRoute || isVerifyRoute) {
        return '/home';
      }

      return null;
    },
    routes: [
      ShellRoute(
        builder: (context, state, child) {
          return _GlobalLoadingWrapper(child: child);
        },
        routes: [
          GoRoute(
            path: '/login',
            name: loginRoute,
            builder: (context, state) => const LoginPage(),
          ),
          GoRoute(
            path: '/signup',
            name: signUpRoute,
            builder: (context, state) => const SignUpScreen(),
          ),
          GoRoute(
            path: '/verify-email',
            name: verifyEmailRoute,
            builder: (context, state) => const VerifyEmailPage(),
          ),
          GoRoute(
            path: '/forgot-password',
            name: 'forgot-password',
            builder: (context, state) => const ForgotPasswordScreen(),
          ),
          GoRoute(
            path: '/edit-profile',
            name: 'edit-profile',
            builder: (context, state) => const EditProfileScreen(),
          ),
          // ... Bottom Nav Routes ...
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
                name: 'history',
                builder: (context, state) => const HistoryScreen(),
              ),
              GoRoute(
                path: '/profile',
                name: 'profile',
                builder: (context, state) => const ProfileScreen(),
              ),
            ],
          ),

          // ... Other Routes (INSIDE Global Wrapper) ...
          GoRoute(
            path: '/announcements',
            name: announcementRoute,
            builder: (context, state) => const AnnouncementScreen(),
          ),
          GoRoute(
            path: '/announcementDetail',
            name: announcementDetailRoute,
            builder: (context, state) => const AnnouncementDetailScreen(),
          ),
          GoRoute(
            path: '/settings',
            name: settingsRoute,
            builder: (context, state) => const SettingsScreen(),
          ),
          GoRoute(
            path: '/favorites',
            name: favoritesRoute,
            builder: (context, state) => const FavoritesScreen(),
          ),
          GoRoute(
            path: '/voucher',
            name: voucherRoute,
            builder: (context, state) => const VoucherScreen(),
          ),
          GoRoute(
            path: "/productDetail",
            name: productDetailRoute,
            builder: (context, state) => const ProductDetailScreen(),
          ),
        ],
      ),
    ],
  );
});

// =========================================================
// HELPER WIDGET: Handles Global Loading State
// =========================================================
class _GlobalLoadingWrapper extends ConsumerWidget {
  final Widget child;
  const _GlobalLoadingWrapper({required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final profileState = ref.watch(isProfileCompleteProvider);

    if (authState.isLoading || profileState.isLoading) {
      return const LoadingScreen();
    }

    return child;
  }
}
