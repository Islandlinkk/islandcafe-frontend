import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          color: Theme.of(context).colorScheme.onSurface,
          onPressed: () => context.pop(),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        title: Text(
          'ABOUT US',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
            color: Theme.of(context).appBarTheme.foregroundColor,
          ),
        ),
      ),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          // Spacer pushes content to center vertically
          const Spacer(flex: 2),

          // Image at center
          Image.asset(
            'assets/images/island_coffee_app.png',
            width: 400,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 16),

          // Version
          Text(
            'Version 1.0.10 (1)',
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
          ),

          const Spacer(flex: 3), // pushes the bottom text to the bottom
          // Copyright text
          Padding(
            padding: const EdgeInsets.only(bottom: 24),
            child: Text(
              '© 2026 ISLAND COFFEE TECH CO., LTD.',
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
