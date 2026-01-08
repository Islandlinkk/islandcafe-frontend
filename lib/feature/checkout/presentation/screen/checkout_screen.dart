import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:island_cafe/feature/checkout/presentation/widget/checkout_widget.dart';
import 'package:island_cafe/feature/product/presentation/widget/product_detail_widget.dart';

class CheckoutScreen extends StatelessWidget {
  const CheckoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.appBarTheme.foregroundColor),
          onPressed: () async {
            context.go('/menu');
            
            await Future.delayed(const Duration(milliseconds: 100));
            if (context.mounted) {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (context) => CartBottomSheetContent(
                  onClose: () => context.pop(),
                ),
              );
            }
          },
        ),
        title: Column(
          children: [
            Text(
              'CHECKOUT',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: theme.appBarTheme.foregroundColor,
              ),
            ),
            Text(
              'PICKUP',
              style: TextStyle(
                fontSize: 12,
                color: colors.onSurfaceVariant,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
      body: const CheckoutWidget(),
    );
  }
}
