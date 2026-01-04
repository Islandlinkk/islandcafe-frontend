import 'package:flutter/material.dart';
import 'package:island_cafe/feature/voucher/data/model/voucher_model.dart';

class VoucherCard extends StatelessWidget {
  final VoucherModel voucher;
  final VoidCallback? onTap;

  const VoucherCard({super.key, required this.voucher, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // --- LEFT SIDE: THE DISCOUNT ---
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.withOpacity(0.3)),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.local_offer, color: Colors.orange, size: 24),
                    const SizedBox(height: 4),
                    Text(
                      voucher.discountType == 'percentage' 
                          ? '${voucher.discountValue}%' 
                          : '\$${voucher.discountValue}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.orange,
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(width: 16),

              // --- RIGHT SIDE: DETAILS ---
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Code & Badge
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          voucher.code,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        if (voucher.minOrderValue != null && voucher.minOrderValue! > 0)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'Min \$${voucher.minOrderValue}',
                              style: TextStyle(fontSize: 10, color: Colors.grey[800]),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    
                    // Description
                    if (voucher.description != null)
                      Text(
                        voucher.description!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: Colors.grey[600], fontSize: 13),
                      ),
                      
                    const SizedBox(height: 8),
                    
                    // Expiry Date
                    Row(
                      children: [
                        Icon(Icons.access_time, size: 14, color: Colors.grey[500]),
                        const SizedBox(width: 4),
                        Text(
                          'Valid until ${voucher.formattedExpiry}',
                          style: TextStyle(color: Colors.grey[500], fontSize: 12),
                        ),
                      ],
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
}