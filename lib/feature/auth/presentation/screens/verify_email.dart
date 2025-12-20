import 'package:flutter/material.dart';
import 'package:island_cafe/feature/auth/presentation/widgets/auth_widgets.dart';
import 'package:island_cafe/feature/auth/services/auth_service.dart';

class VerifyEmailPage extends StatefulWidget {
  const VerifyEmailPage({super.key});

  @override
  State<VerifyEmailPage> createState() => _VerifyEmailPageState();
}

class _VerifyEmailPageState extends State<VerifyEmailPage> {
  bool _loading = false;

  Future<void> _resend() async {
    await _performAction(
      AuthService.resendEmailVerification,
      'Verification email sent',
    );
  }

  Future<void> _refresh() async {
    await _performAction(AuthService.reloadCurrentUser, 'Status refreshed');
  }

  Future<void> _performAction(
    Future<void> Function() action,
    String successMsg,
  ) async {
    setState(() => _loading = true);
    try {
      await action();
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(successMsg)));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return CoffeeAuthLayout(
      title: 'Check your Inbox',
      subtitle: 'We sent a verification link to your email.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Icon(
            Icons.mark_email_unread_outlined,
            size: 80,
            color: CoffeeColors.accent,
          ),
          const SizedBox(height: 32),
          CoffeeButton(
            text: 'Resend Email',
            onPressed: _resend,
            isLoading: _loading,
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: _loading ? null : _refresh,
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              side: const BorderSide(color: CoffeeColors.primary),
              foregroundColor: CoffeeColors.primary,
            ),
            child: const Text('I verified, Refresh Status'),
          ),
          const SizedBox(height: 24),
          TextButton(
            onPressed: _loading ? null : AuthService.signOut,
            child: const Text('Sign Out', style: TextStyle(color: Colors.grey)),
          ),
        ],
      ),
    );
  }
}
