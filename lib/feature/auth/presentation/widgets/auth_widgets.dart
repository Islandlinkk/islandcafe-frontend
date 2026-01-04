import 'package:flutter/material.dart';

class CoffeeColors {
  static const Color primary = Color(0xFF4E342E);
  static const Color primaryLight = Color(0xFF795548);
  static const Color accent = Color(0xFFA1887F);
  static const Color background = Color(0xFFEFEBE9);
  static const Color textDark = Color(0xFF3E2723);
  static const Color surface = Colors.white;
}

class CoffeeAuthLayout extends StatelessWidget {
  final Widget child;
  final String title;
  final String subtitle;
  final bool showLogo;

  const CoffeeAuthLayout({
    super.key,
    required this.child,
    required this.title,
    required this.subtitle,
    this.showLogo = true,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (showLogo) ...[
                  Icon(Icons.coffee, size: 64, color: Theme.of(context).colorScheme.primary),
                  const SizedBox(height: 24),
                ],
                Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context).colorScheme.primary,
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        title,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                          fontFamily: 'serif',
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        subtitle,
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 14, color: Theme.of(context).colorScheme.onSurface),
                      ),
                      const SizedBox(height: 32),
                      child,
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
class CoffeeTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final bool readOnly; // <--- ADD THIS

  const CoffeeTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.icon,
    this.obscureText = false,
    this.keyboardType,
    this.validator,
    this.readOnly = false, required String hintText, // <--- ADD THIS DEFAULT
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        validator: validator,
        readOnly: readOnly, // <--- USE IT HERE
        style: TextStyle(
          color: readOnly ? Theme.of(context).colorScheme.onSurface : Theme.of(context).colorScheme.onSurface,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Theme.of(context).colorScheme.onSurface),
          prefixIcon: Icon(icon, color: readOnly ? Theme.of(context).colorScheme.onSurface : Theme.of(context).colorScheme.primary),
          filled: true,
          fillColor: readOnly ? Theme.of(context).colorScheme.surface : Theme.of(context).colorScheme.surface,
          contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: readOnly ? Colors.transparent : Theme.of(context).colorScheme.outline,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Theme.of(context).colorScheme.error),
          ),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
    );
  }
}
class CoffeeButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Color? backgroundColor;
  final Color? textColor;

  const CoffeeButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.backgroundColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? Theme.of(context).colorScheme.primary,
          foregroundColor: textColor ?? Theme.of(context).colorScheme.onPrimary,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: isLoading
            ? SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(color: Theme.of(context).colorScheme.onPrimary, strokeWidth: 2),
              )
            : Text(text, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
class SocialButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool isLoading;

  const SocialButton({super.key, required this.onPressed, this.isLoading = false});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: isLoading ? null : onPressed,
      icon: const Icon(Icons.g_mobiledata, size: 30),
      label: const Text('Continue with Google'),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 14),
        side: BorderSide(color: Theme.of(context).dividerColor),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        foregroundColor: Theme.of(context).colorScheme.onSurface,
      ),
    );
  }
}