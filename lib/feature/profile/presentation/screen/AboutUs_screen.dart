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
          color: Colors.black,
          onPressed: () => context.pop(),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text(
          'ABOUT US',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
            color: Colors.black,
          ),
        ),
      ),
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Spacer pushes content to center vertically
          const Spacer(flex: 2),

          // Image at center
          Image.asset(
            'assets/images/kohsdach.png', // use your actual image path
            width: 400,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 16),

          // Version
          const Text(
            'Version 1.0.10 (1)',
            style: TextStyle(
              fontSize: 14,
              color: Colors.black54,
            ),
          ),

          const Spacer(flex: 3), // pushes the bottom text to the bottom

          // Copyright text
          const Padding(
            padding: EdgeInsets.only(bottom: 24),
            child: Text(
              '© 2025 ISLANDLINK TECH CO., LTD.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.black45,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
