import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:island_cafe/feature/auth/presentation/widgets/auth_widgets.dart';
import 'package:island_cafe/feature/auth/services/auth_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleEmailLogin() async {
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
      await AuthService.signInWithEmail(email: email, password: password);
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

  Future<void> _handleGoogleLogin() async {
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
      title: 'Welcome Back!',
      subtitle: 'Grab a cup and sign in.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CoffeeTextField(
            controller: _emailController,
            label: 'Email Address',
            icon: Icons.alternate_email_rounded,
            keyboardType: TextInputType.emailAddress,
          ),
          CoffeeTextField(
            controller: _passwordController,
            label: 'Password',
            icon: Icons.lock_outline_rounded,
            obscureText: true,
          ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              // UPDATE THIS LINE:
              onPressed: () => context.push('/forgot-password'),
              child: Text(
                'Forgot Password?',
                style: TextStyle(
                  color: CoffeeColors.primaryLight.withOpacity(0.8),
                ),
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
          SocialButton(onPressed: _handleGoogleLogin, isLoading: _loading),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("New here? ", style: TextStyle(color: Colors.grey[600])),
              GestureDetector(
                onTap: _loading ? null : () => context.go('/signup'),
                child: const Text("Create Account"),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
