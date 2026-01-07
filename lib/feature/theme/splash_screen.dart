import 'package:flutter/material.dart';
import 'dart:async';

class SplashScreen extends StatefulWidget {
  final VoidCallback onComplete;
  
  const SplashScreen({
    super.key,
    required this.onComplete,
  });

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Delay for 3 seconds
    Timer(const Duration(seconds: 3), () {
      if (mounted) {
        widget.onComplete();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Island Coffee Logo
              _buildLogo(),
              const SizedBox(height: 50),
            
              // Loading Text
              Text(
                'Welcome to Island Coffee',
                style: TextStyle(
                  color: Colors.grey[700],
                  fontSize: 24,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.5,
                  height: 1.2,
                  shadows: [
                    Shadow(
                      blurRadius: 4,
                      color: Theme.of(context).colorScheme.onSurface,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    // Try to load the Island Coffee logo image with multiple format support
    return Container(
      constraints: const BoxConstraints(
        maxWidth: 240,
        maxHeight: 240,
      ),
      child: Image.asset(
        'assets/images/island_coffee.png',
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          // Try alternative formats if PNG doesn't exist
          return Image.asset(
            'assets/images/island_coffee.png',
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return Image.asset(
                'assets/images/island_coffee.png',
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  // Final fallback to coffee icon if no logo image is foundR
                  return Container(
                    width: 240,
                    height: 240,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(0xFF8B4513),
                        width: 2,
                      ),
                    ),
                    child: const Icon(
                      Icons.coffee,
                      size: 120,
                      color: Color(0xFF8B4513),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

