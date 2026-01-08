import 'package:flutter/material.dart';

class LoadingIconButton extends StatelessWidget {
  final IconData? icon;
  final VoidCallback? onPressed;
  final Color? color;
  final bool isLoading;
  final double size;
  final Color? loadingColor;

  const LoadingIconButton({
    super.key,
    this.icon,
    required this.onPressed,
    this.color,
    this.isLoading = false,
    this.size = 24,
    this.loadingColor,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: isLoading
          ? Padding(
              padding: const EdgeInsets.all(12.0),
              child: SizedBox(
                width: size,
                height: size,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    loadingColor ?? colors.primary,
                  ),
                ),
              ),
            )
          : IconButton(
              icon: Icon(icon, color: color ?? colors.onSurface),
              onPressed: onPressed,
            ),
    );
  }
}
