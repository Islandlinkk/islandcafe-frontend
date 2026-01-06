import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:island_cafe/feature/auth/presentation/widgets/auth_widgets.dart';
import 'package:island_cafe/feature/auth/services/auth_service.dart';
import 'package:island_cafe/feature/auth/services/validate_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
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
        backgroundColor: Theme.of(context).colorScheme.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // Inside your Login Screen file
Future<void> _handleEmailLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);
    try {
      // 1. Perform Login
      await AuthService.signInWithEmail(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      // SUCCESS: Do NOTHING here. 
      // The authStateProvider will update -> GoRouter will detect it -> Redirects to /home
    } catch (e) {
      _showError(e);
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _handleGoogleLogin() async {
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
    return Stack(
      children: [
        CoffeeAuthLayout(
      title: 'Welcome Back!',
      subtitle: 'Grab a cup and sign in.',
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CoffeeTextField(
              controller: _emailController,
              label: 'Email Address',
              icon: Icons.alternate_email_rounded,
              keyboardType: TextInputType.emailAddress,
              validator: ValidationService.validateEmail,
              hintText: '',
            ),
            CoffeeTextField(
              controller: _passwordController,
              label: 'Password',
              icon: Icons.lock_outline_rounded,
              obscureText: true,
              validator: (val) =>
                  val?.isEmpty == true ? 'Please enter password' : null,
              hintText: '',
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => context.push('/forgot-password'),
                child: const Text(
                  'Forgot Password?',
                  style: TextStyle(color: CoffeeColors.primaryLight),
                ),
              ),
            ),
            const SizedBox(height: 12),
            CoffeeButton(
              text: 'Sign In',
              onPressed: _handleEmailLogin,
              isLoading: _loading,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(child: Divider(color: Theme.of(context).dividerColor)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    'OR',
                    style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
                  ),
                ),
                Expanded(child: Divider(color: Theme.of(context).dividerColor)),
              ],
            ),
            const SizedBox(height: 24),
            SocialButton(onPressed: _handleGoogleLogin, isLoading: _loading),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("New here? ", style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6))),
                GestureDetector(
                  onTap: _loading ? null : () => context.go('/signup'),
                  child: Text("Create Account", style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
    Positioned(
          top: 40, // Adjust for safe area
          left: 10,
          child: IconButton(
            onPressed: () => context.go('/profile'),
            icon: const Icon(Icons.arrow_back_ios_new, color: CoffeeColors.primary),
          ),
        ),
      ],
    );
  }
}