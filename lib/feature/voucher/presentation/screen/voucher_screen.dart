import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:island_cafe/feature/voucher/data/provider/my_voucher_provider.dart';
import 'package:island_cafe/feature/voucher/presentation/widget/voucher_card.dart';

class VoucherScreen extends ConsumerStatefulWidget {
  const VoucherScreen({super.key});

  @override
  ConsumerState<VoucherScreen> createState() => _VoucherScreenState();
}

class _VoucherScreenState extends ConsumerState<VoucherScreen> {
  
  void _showClaimSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).cardColor, // Fix: Dynamic Sheet Background
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => const _ClaimVoucherSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final voucherState = ref.watch(myVouchersProvider);
    
    // 1. Get Theme Data
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor, // Fix: Dynamic Background
      appBar: AppBar(
        title: Text(
          'My Vouchers', 
          style: TextStyle(color: theme.appBarTheme.foregroundColor)
        ),
        backgroundColor: theme.appBarTheme.backgroundColor,
      ),
      
      body: voucherState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        
        error: (err, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 48, color: Colors.red[300]),
              const SizedBox(height: 16),
              Text(
                'Error: ${err.toString().replaceAll('Exception: ', '')}',
                style: TextStyle(color: theme.colorScheme.onSurface),
              ),
              TextButton(
                onPressed: () => ref.refresh(myVouchersProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),

        data: (myVouchers) {
          if (myVouchers.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Fix: Icon color adapts to dark mode
                  Icon(
                    Icons.confirmation_number_outlined, 
                    size: 64, 
                    color: theme.colorScheme.surfaceContainerHighest, 
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "You haven't claimed any vouchers yet.",
                    // Fix: Text color adapts to dark mode
                    style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
                  ),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            itemCount: myVouchers.length,
            itemBuilder: (context, index) {
              return VoucherCard(voucher: myVouchers[index]);
            },
          );
        },
      ),

      // --- 2. FIXED BOTTOM BAR ---
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          // Fix: Use Card Color (Dark Grey in Dark Mode, White in Light Mode)
          color: theme.cardColor, 
          boxShadow: isDarkMode 
              ? [] // No shadow in dark mode (cleaner)
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
          // Optional: Top border for Dark Mode separation
          border: isDarkMode 
              ? Border(top: BorderSide(color: theme.dividerColor)) 
              : null,
        ),
        child: SafeArea(
          child: ElevatedButton(
            onPressed: () => _showClaimSheet(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary, // Orange
              foregroundColor: theme.colorScheme.onPrimary, // White/Black text
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(vertical: 16),
              elevation: 0,
            ),
            child: const Text(
              'Claim New Voucher',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }
}

class _ClaimVoucherSheet extends ConsumerStatefulWidget {
  const _ClaimVoucherSheet();

  @override
  ConsumerState<_ClaimVoucherSheet> createState() => _ClaimVoucherSheetState();
}

class _ClaimVoucherSheetState extends ConsumerState<_ClaimVoucherSheet> {
  final TextEditingController _codeController = TextEditingController();
  bool _isLoading = false;

  Future<void> _handleClaim() async {
    final code = _codeController.text.trim();
    if (code.isEmpty) return;

    setState(() => _isLoading = true);
    FocusScope.of(context).unfocus();

    try {
      await ref.read(myVouchersProvider.notifier).claimVoucher(code);
      
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Voucher Claimed Successfully!'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')), 
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              left: 16, 
              right: 16
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(24, 24, 24, bottomInset + 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Enter Voucher Code',
            style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          
          // --- 3. FIXED INPUT FIELD ---
          TextField(
            controller: _codeController,
            autofocus: true,
            textCapitalization: TextCapitalization.characters,
            style: TextStyle(color: theme.colorScheme.onSurface), // Fix: Input text color
            decoration: InputDecoration(
              hintText: 'e.g. AHJM168',
              hintStyle: TextStyle(color: theme.hintColor),
              filled: true,
              // Fix: Dynamic background (Light Grey in Light Mode, Dark Grey in Dark Mode)
              fillColor: theme.colorScheme.surfaceContainerHighest,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _handleClaim,
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary, // Orange
                foregroundColor: theme.colorScheme.onPrimary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isLoading 
                  ? SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: theme.colorScheme.onPrimary, strokeWidth: 2))
                  : const Text('Confirm Claim', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}