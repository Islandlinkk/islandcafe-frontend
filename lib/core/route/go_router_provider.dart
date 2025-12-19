import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:island_cafe/feature/auth/data/providers/auth_provider.dart';
import 'package:island_cafe/feature/auth/presentation/screens/forgot_password_screen.dart';
import 'package:island_cafe/feature/auth/presentation/screens/login_screen.dart';
import 'package:island_cafe/feature/auth/presentation/screens/signup_screen.dart';
import 'package:island_cafe/feature/auth/presentation/screens/user_info_screen.dart';
import 'package:island_cafe/feature/auth/presentation/screens/verify_email.dart';
import 'package:island_cafe/feature/history/presentation/screen/history_screen.dart';
import 'package:island_cafe/feature/home/presentation/screen/home_screen.dart';
import 'package:island_cafe/feature/menu/presentation/screen/menu_screen.dart';
import 'package:island_cafe/feature/profile/presentation/screen/profile_screen.dart';
import 'package:island_cafe/root/root_BottomNavigation_screen.dart';

final goRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);
  final profileState = ref.watch(isProfileCompleteProvider);

  final user = authState.value;
  final isProfileComplete = profileState.value ?? false;

  return GoRouter(
    initialLocation: '/home',
    debugLogDiagnostics: true,
    redirect: (context, state) async {
      final isLoading = authState.isLoading || profileState.isLoading;
      if (isLoading) return null;
      final path = state.uri.path;

      final isLoggingIn = path == '/login';
      final isSigningUp = path == '/signup';
      final isVerifyingEmail = path == '/verify-email';
      final isCompletingProfile = path == '/user-info';
      final isRecoveringPassword = path == '/forgot-password';
      if (user == null) {
        return null;
      }
      if (!user.emailVerified) {
        if (!isVerifyingEmail) return '/verify-email';
        return null;
      }
      if (!isProfileComplete) {
        if (!isCompletingProfile) return '/user-info';
        return null;
      }
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
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/signup',
        name: 'signup',
        builder: (context, state) => const SignUpScreen(),
      ),
      GoRoute(
        path: '/forgot-password',
        name: 'forgot_password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: '/verify-email',
        name: 'verify_email',
        builder: (context, state) => const VerifyEmailPage(),
      ),
      GoRoute(
        path: '/user-info',
        name: 'user_info',
        builder: (context, state) => const UserInfoScreen(),
      ),

      ShellRoute(
        builder: (context, state, child) =>
            RootBottomnavigationScreen(child: child),
        routes: [
          GoRoute(
            path: "/home",
            name: 'home',
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: "/menu",
            name: 'menu',
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
    ],
  );
});
