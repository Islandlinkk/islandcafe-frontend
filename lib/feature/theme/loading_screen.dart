import 'package:flutter/material.dart';
import 'package:island_cafe/feature/auth/presentation/widgets/auth_widgets.dart';

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CoffeeColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Coffee Icon
            const Icon(
              Icons.coffee,
              size: 80,
              color: CoffeeColors.primary,
            ),
            const SizedBox(height: 40),

            // Spinner
            const SizedBox(
              height: 40,
              width: 40,
              child: CircularProgressIndicator(
                color: CoffeeColors.primary,
                strokeWidth: 3,
              ),
            ),
            const SizedBox(height: 24),

            // Loading Text
            const Text(
              'Brewing...',
              style: TextStyle(
                color: CoffeeColors.textDark,
                fontSize: 18,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}