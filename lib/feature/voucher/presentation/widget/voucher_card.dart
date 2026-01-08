import 'package:flutter/material.dart';
import 'package:island_cafe/feature/voucher/data/model/voucher_model.dart';

class VoucherCard extends StatelessWidget {
  final VoucherModel voucher;
  final VoidCallback? onTap;

  const VoucherCard({super.key, required this.voucher, this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[850] : Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark ? Colors.grey[700]! : Colors.grey[200]!,
        ),
      ),
      child: ListTile(
        dense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        onTap: onTap,
        leading: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: const Color(0xFFFFC107).withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(6),
          ),
          child: const Icon(
            Icons.local_offer,
            color: Color(0xFFFFC107),
            size: 18,
          ),
        ),
        title: Text(
          voucher.code,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 2),
            Text(
              voucher.formattedDiscount,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFFFFC107),
              ),
            ),
            Text(
              voucher.description ?? voucher.minSpendText,
              style: TextStyle(
                fontSize: 11,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
            Text(
              'Exp: ${voucher.formattedExpiry}',
              style: TextStyle(
                fontSize: 10,
                color: isDark ? Colors.grey[500] : Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
