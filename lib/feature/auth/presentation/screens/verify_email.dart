import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:island_cafe/core/route/go_router_provider.dart';
import 'package:island_cafe/feature/auth/services/auth_service.dart';
import 'package:island_cafe/feature/auth/presentation/widgets/auth_widgets.dart';
class VerifyEmailPage extends ConsumerStatefulWidget {
  const VerifyEmailPage({super.key});

  @override
  ConsumerState<VerifyEmailPage> createState() => _VerifyEmailPageState();
}

class _VerifyEmailPageState extends ConsumerState<VerifyEmailPage> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      _checkEmailVerified();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _checkEmailVerified() async {
    try {
      await AuthService.reloadCurrentUser();
      final user = AuthService.currentUser;
      if (user != null && user.emailVerified) {
        _timer?.cancel();
        ref.read(routerRefreshTriggerProvider.notifier).state++;
      }
    } catch (e) {
      debugPrint("Verify Polling Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return CoffeeAuthLayout(
      title: 'Verifying Email',
      subtitle: 'We sent a verification link to your email.\nPlease check your inbox and click the link.',
      child: Center(
        child: Column(
          children: [
            const SizedBox(height: 50),
            const CircularProgressIndicator(color: CoffeeColors.primary),
            const SizedBox(height: 30),
            const Text(
              "Waiting for confirmation...",
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
            const SizedBox(height: 50),
            TextButton(
              onPressed: () {
                AuthService.signOut();
                ref.read(routerRefreshTriggerProvider.notifier).state++;
              },
              child: const Text("Cancel / Sign Out", style: TextStyle(color: Colors.redAccent)),
            ),
          ],
        ),
      ),
    );
  }
}