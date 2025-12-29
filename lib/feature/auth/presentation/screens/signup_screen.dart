import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:island_cafe/feature/auth/presentation/widgets/auth_widgets.dart';
import 'package:island_cafe/feature/auth/services/auth_service.dart';
import 'package:island_cafe/feature/auth/services/validate_service.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showError(dynamic e) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AuthService.getExceptionMessage(e)),
        backgroundColor: Colors.redAccent,
      ),
    );
  }

  Future<void> _handleSignUp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);
    try {
      await AuthService.registerWithEmail(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
    } catch (e) {
      _showError(e);
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _handleGoogleAuth() async {
    setState(() => _loading = true);
    try {
      await AuthService.signInWithGoogle();
    } catch (e) {
      _showError(e);
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return CoffeeAuthLayout(
      title: 'Join Island Cafe',
      subtitle: 'Start your coffee journey today.',
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CoffeeTextField(
              controller: _emailController,
              label: 'Email Address',
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              validator: ValidationService.validateEmail, hintText: '',
            ),
            CoffeeTextField(
              controller: _passwordController,
              label: 'Create Password',
              icon: Icons.lock_outline,
              obscureText: true,
              validator: ValidationService.validatePassword, hintText: '',
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
                  child: Text('OR', style: TextStyle(color: Colors.grey.shade400, fontSize: 12)),
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
                Text("Already a member? ", style: TextStyle(color: Colors.grey[600])),
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
      ),
    );
  }
}