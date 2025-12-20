import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:island_cafe/feature/auth/services/auth_service.dart';

final authStateProvider = StreamProvider<User?>((ref) {
  return AuthService.authStateChanges;
});

final isProfileCompleteProvider = FutureProvider<bool>((ref) async {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return false;
  return await AuthService.isUserProfileComplete();
});
