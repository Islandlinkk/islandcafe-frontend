import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:island_cafe/feature/auth/presentation/widgets/auth_widgets.dart';
import 'package:island_cafe/feature/auth/services/auth_service.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignUp() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    setState(() => _loading = true);
    try {
      await AuthService.registerWithEmail(email: email, password: password);
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

  Future<void> _handleGoogleAuth() async {
    setState(() => _loading = true);
    try {
      await AuthService.signInWithGoogle();
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
      title: 'Join Island Cafe',
      subtitle: 'Start your coffee journey today.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CoffeeTextField(
            controller: _emailController,
            label: 'Email Address',
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
          ),
          CoffeeTextField(
            controller: _passwordController,
            label: 'Create Password',
            icon: Icons.lock_outline,
            obscureText: true,
          ),
          const SizedBox(height: 12),
          CoffeeButton(
            text: 'Create Account',
            onPressed: _handleSignUp,
            isLoading: _loading,
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(child: Divider(color: Colors.grey.shade300)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  'OR',
                  style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
                ),
              ),
              Expanded(child: Divider(color: Colors.grey.shade300)),
            ],
          ),
          const SizedBox(height: 24),
          SocialButton(onPressed: _handleGoogleAuth, isLoading: _loading),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Already a member? ",
                style: TextStyle(color: Colors.grey[600]),
              ),
              GestureDetector(
                onTap: _loading ? null : () => context.go('/login'),
                child: const Text(
                  "Sign In",
                  style: TextStyle(
                    color: CoffeeColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
