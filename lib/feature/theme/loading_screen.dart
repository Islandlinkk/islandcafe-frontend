import 'package:flutter/material.dart';

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Coffee Icon
            // Island Coffee Logo Image
            Container(
              constraints: const BoxConstraints(
                maxWidth: 140,
                maxHeight: 140,
              ),
              child: Image.asset(
                'assets/images/island_coffee.png',
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  // Fallback to coffee icon if logo asset is missing
                  return Image.asset(
                    'assets/images/island_coffee.png',
                    fit: BoxFit.contain,
                  );
                },
              ),
            ),
            const SizedBox(height: 20),

            // Spinner
            SizedBox(
              height: 40,
              width: 40,
              child: CircularProgressIndicator(
                color: Theme.of(context).colorScheme.primary,
                strokeWidth: 3,
              ),
            ),
            const SizedBox(height: 24),

            // Loading Text
            Text(
              'Brewing...',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
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
