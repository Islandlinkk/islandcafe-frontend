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
  
  // This method opens the popup (Bottom Sheet)
  void _showClaimSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Needed for keyboard handling
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => const _ClaimVoucherSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final myVouchers = ref.watch(myVouchersProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('My Vouchers')),
      
      // --- 1. THE LIST (Main Content) ---
      body: myVouchers.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.confirmation_number_outlined, size: 64, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  Text(
                    "You haven't claimed any vouchers yet.",
                    style: TextStyle(color: Colors.grey[500]),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 100), // Extra padding at bottom for button
              itemCount: myVouchers.length,
              itemBuilder: (context, index) {
                return VoucherCard(voucher: myVouchers[index]);
              },
            ),

      // --- 2. THE BUTTON (Pinned to Bottom) ---
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: ElevatedButton(
            onPressed: () => _showClaimSheet(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
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

// --- 3. THE POPUP WIDGET ---
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
    
    // Close keyboard
    FocusScope.of(context).unfocus();

    try {
      await ref.read(myVouchersProvider.notifier).claimVoucher(code);
      
      if (mounted) {
        Navigator.pop(context); // Close the popup on success
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
            behavior: SnackBarBehavior.floating, // Floating snackbar so it's visible above keyboard
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
    // This padding makes the popup rise when keyboard opens
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(24, 24, 24, bottomInset + 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Enter Voucher Code',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _codeController,
            autofocus: true, // Auto open keyboard
            textCapitalization: TextCapitalization.characters,
            decoration: InputDecoration(
              hintText: 'e.g. AHJM168',
              filled: true,
              fillColor: Colors.grey[100],
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
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isLoading 
                  ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text('Confirm Claim', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}