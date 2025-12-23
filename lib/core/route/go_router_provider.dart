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
import 'package:island_cafe/feature/product/presentation/screen/product_detail_screen.dart';
import 'package:island_cafe/feature/profile/presentation/screen/profile_screen.dart';
import 'package:island_cafe/feature/profile/presentation/screen/settings_screen.dart';
import 'package:island_cafe/feature/profile/presentation/screen/favorites_screen.dart';
import 'package:island_cafe/root/root_BottomNavigation_screen.dart';

final goRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);
  final profileState = ref.watch(isProfileCompleteProvider);

  final user = authState.value;
  final isProfileComplete = profileState.value ?? false;

  return GoRouter(
    initialLocation: '/home', // <--- Ensures app starts at Home
    debugLogDiagnostics: true,
    redirect: (context, state) async {
      final isLoading = authState.isLoading || profileState.isLoading;
      if (isLoading) return null;
      
      final path = state.uri.path;

      // Define auth paths
      final isLoggingIn = path == '/login';
      final isSigningUp = path == '/signup';
      final isVerifyingEmail = path == '/verify-email';
      final isCompletingProfile = path == '/user-info';
      final isRecoveringPassword = path == '/forgot-password';

      // 1. GUEST MODE: If user is NOT logged in
      if (user == null) {
        // If the user is currently on an auth screen, let them stay there
        if (isLoggingIn || isSigningUp || isRecoveringPassword) {
          return null; 
        }
        
        // If they are on any other screen (like /home), let them stay there.
        // We do NOT return '/login' here, allowing the app to open Home first.
        return null; 
      }

      // 2. LOGGED IN: Check Email Verification
      if (!user.emailVerified) {
        if (!isVerifyingEmail) return '/verify-email';
        return null;
      }

      // 3. LOGGED IN: Check Profile Completion
      if (!isProfileComplete) {
        if (!isCompletingProfile) return '/user-info';
        return null;
      }

      // 4. LOGGED IN & VERIFIED: Redirect away from auth pages
      if (isLoggingIn ||
          isSigningUp ||
          isVerifyingEmail ||
          isCompletingProfile ||
          isRecoveringPassword) {
        return '/home';
      }

      return null;
    },

    routes: [
      // --- AUTH ROUTES (Added these so navigation works) ---
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
        path: '/user-info',
        name: userInfoRoute,
        builder: (context, state) => const UserInfoScreen(),
      ),
      GoRoute(
        path: '/forgot-password',
        name: 'forgot-password', 
        builder: (context, state) => const ForgotPasswordScreen(),
      ),

      // --- BOTTOM NAVIGATION ROUTES ---
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

      // --- OTHER ROUTES ---
      GoRoute(
        path: "/announcements",
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
        path: "/productDetail",
        name: productDetailRoute,
        builder: (context, state) => const ProductDetailScreen(),
      ),
    ],
  );
});