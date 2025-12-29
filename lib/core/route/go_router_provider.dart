import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:island_cafe/core/route/route_name.dart';
import 'package:island_cafe/feature/announcement/presentation/screen/announcement_detail_screen.dart';
import 'package:island_cafe/feature/announcement/presentation/screen/announcement_screen.dart';
import 'package:island_cafe/feature/auth/data/providers/auth_provider.dart';
import 'package:island_cafe/feature/auth/presentation/screens/forgot_password_screen.dart';
import 'package:island_cafe/feature/auth/presentation/screens/login_screen.dart';
import 'package:island_cafe/feature/auth/presentation/screens/signup_screen.dart';
import 'package:island_cafe/feature/auth/presentation/screens/user_info_screen.dart';
import 'package:island_cafe/feature/auth/presentation/screens/verify_email.dart';
import 'package:island_cafe/feature/history/presentation/screen/history_screen.dart';
import 'package:island_cafe/feature/home/presentation/screen/home_screen.dart';
import 'package:island_cafe/feature/menu/presentation/screen/menu_screen.dart';
import 'package:island_cafe/feature/profile/presentation/screen/edit_profile_screen.dart';
import 'package:island_cafe/feature/profile/presentation/screen/profile_screen.dart';
import 'package:island_cafe/feature/profile/presentation/screen/settings_screen.dart';
import 'package:island_cafe/feature/profile/presentation/screen/favorites_screen.dart';
import 'package:island_cafe/root/root_BottomNavigation_screen.dart';
import 'package:island_cafe/feature/theme/loading_screen.dart'; 

final goRouterProvider = Provider<GoRouter>((ref) {
  final notifier = ValueNotifier(0);
  
  // Listen to both providers to trigger router refresh
  ref.listen(authStateProvider, (_, __) => notifier.notifyListeners());
  ref.listen(isProfileCompleteProvider, (_, __) => notifier.notifyListeners());

  return GoRouter(
    initialLocation: '/home',
    debugLogDiagnostics: true,
    refreshListenable: notifier,
    redirect: (context, state) {
      final authState = ref.read(authStateProvider);
      final profileState = ref.read(isProfileCompleteProvider);

      final user = authState.value;
      // Default to false only if we have data and it is explicitly false
      final isProfileComplete = profileState.value == true;
      
      // Combined Loading State
      final isLoading = authState.isLoading || profileState.isLoading;

      // 0. LOADING CHECK:
      // If we are loading, we return null to stay on the current loading wrapper
      if (isLoading) return null;

      final path = state.uri.path;

      // Define auth paths
      final isAuthRoute = path == '/login' || 
                          path == '/signup' || 
                          path == '/forgot-password';
      final isVerifyingEmail = path == '/verify-email';
      final isCompletingProfile = path == '/user-info';

      // 1. GUEST MODE (User is null)
      if (user == null) {
        // Allow access to Auth routes
        if (isAuthRoute) return null;
        
        // If trying to access protected routes, do nothing (or redirect to welcome if needed)
        // Since your guest view is inside Profile/Home, we usually allow /home
        return null;
      }

      // 2. LOGGED IN: Check Email Verification
      if (!user.emailVerified) {
        if (!isVerifyingEmail) return '/verify-email';
        return null;
      }

      // 3. LOGGED IN: Check Profile Completion (Firestore check)
      // If profile is NOT complete, force them to /user-info
      if (!isProfileComplete) {
        if (!isCompletingProfile) return '/user-info';
        return null;
      }

      // 4. FULLY AUTHORIZED: Redirect away from Auth/Setup pages
      if (isAuthRoute || isVerifyingEmail || isCompletingProfile) {
        return '/home';
      }

      return null;
    },
    routes: [
      // --- GLOBAL LOADER SHELL ---
      ShellRoute(
        builder: (context, state, child) {
          return _GlobalLoadingWrapper(child: child);
        },
        routes: [
          // --- AUTH ROUTES ---
          GoRoute(path: '/login', name: loginRoute, builder: (context, state) => const LoginPage()),
          GoRoute(path: '/signup', name: signUpRoute, builder: (context, state) => const SignUpScreen()),
          GoRoute(path: '/verify-email', name: verifyEmailRoute, builder: (context, state) => const VerifyEmailPage()),
          GoRoute(path: '/user-info', name: userInfoRoute, builder: (context, state) => const UserInfoScreen()),
          GoRoute(path: '/forgot-password', name: 'forgot-password', builder: (context, state) => const ForgotPasswordScreen()),
          GoRoute(path: '/edit-profile', name: 'edit-profile', builder: (context, state) => const EditProfileScreen()),

          // --- BOTTOM NAVIGATION ROUTES ---
          ShellRoute(
            builder: (context, state, child) => RootBottomnavigationScreen(child: child),
            routes: [
              GoRoute(path: "/home", name: homeRoute, builder: (context, state) => const HomeScreen()),
              GoRoute(path: "/menu", name: menuRoute, builder: (context, state) => const MenuScreen()),
              GoRoute(path: '/history', name: 'history', builder: (context, state) => const HistoryScreen()),
              GoRoute(path: '/profile', name: 'profile', builder: (context, state) => const ProfileScreen()),
            ],
          ),

          // --- OTHER ROUTES ---
          GoRoute(path: '/announcements', name: announcementRoute, builder: (context, state) => const AnnouncementScreen()),
          GoRoute(path: '/announcementDetail', name: announcementDetailRoute, builder: (context, state) => const AnnouncementDetailScreen()),
          GoRoute(path: '/settings', name: settingsRoute, builder: (context, state) => const SettingsScreen()),
          GoRoute(path: '/favorites', name: favoritesRoute, builder: (context, state) => const FavoritesScreen()),
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

    // Show loading screen if either Auth or Profile Status is fetching
    if (authState.isLoading || profileState.isLoading) {
      return const LoadingScreen();
    }

    return child;
  }
}