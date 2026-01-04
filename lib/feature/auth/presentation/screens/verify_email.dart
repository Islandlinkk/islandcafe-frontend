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
    // Start polling immediately
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      _checkEmailVerified();
    });
  }

  @override
  void dispose() {
    // Always clean up timers
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _checkEmailVerified() async {
    try {
      // 1. Force Firebase Server Update
      // This pulls the latest data (e.g., emailVerified = true) from the backend
      await AuthService.reloadCurrentUser();
      
      final user = AuthService.currentUser;
      if (user != null && user.emailVerified) {
        // Stop checking
        _timer?.cancel();
        
        // 2. RING THE DOORBELL
        // We increment the trigger provider. 
        // GoRouter is listening to this, so it will wake up immediately.
        ref.read(routerRefreshTriggerProvider.notifier).state++;
      }
    } catch (e) {
      // If network fails during poll, just ignore and try again in 3 seconds
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
            
            // Simple loading spinner
            const CircularProgressIndicator(color: CoffeeColors.primary),
            
            const SizedBox(height: 30),
            
            const Text(
              "Waiting for confirmation...",
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
            
            const SizedBox(height: 50),
            
            // Cancel button in case user is stuck
            TextButton(
              onPressed: () {
                AuthService.signOut();
                // The router will automatically detect logout and redirect to login
              },
              child: const Text("Cancel / Sign Out", style: TextStyle(color: Colors.redAccent)),
            ),
          ],
        ),
      ),
    );
  }
}