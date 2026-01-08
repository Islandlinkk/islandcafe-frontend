import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:island_cafe/core/route/route_name.dart';
import 'package:island_cafe/feature/auth/presentation/widgets/auth_widgets.dart';
import 'package:island_cafe/feature/auth/services/auth_service.dart';
import 'package:island_cafe/feature/history/service/feedback_service.dart';

class FeedbackSubmissionScreen extends StatefulWidget {
  final String? orderId;
  final String? orderNumber;

  const FeedbackSubmissionScreen({super.key, this.orderId, this.orderNumber});

  @override
  State<FeedbackSubmissionScreen> createState() =>
      _FeedbackSubmissionScreenState();
}

class _FeedbackSubmissionScreenState extends State<FeedbackSubmissionScreen> {
  final List<String> _categories = const [
    'Good Environment',
    'Good Service',
    'Good Food',
    'Good Price',
    'Good Location',
    'Good Promotion',
    'Good Customer Service',
    'Good Customer Experience',
    'Good Customer Satisfaction',
    'other',
  ];

  final _descriptionController = TextEditingController();

  String? _selectedCategory;
  bool _isSubmitting = false;
  String? _hoveredCategory;
  bool _isDescriptionHovered = false;

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submitFeedback() async {
    // Dismiss keyboard
    FocusScope.of(context).unfocus();

    if (_selectedCategory == null || _selectedCategory!.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a feedback category')),
        );
      }
      return;
    }

    if (_descriptionController.text.trim().isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter a description')),
        );
      }
      return;
    }

    if (!mounted) return;
    setState(() => _isSubmitting = true);

    try {
      final user = AuthService.currentUser;
      if (user == null) {
        throw Exception('User must be logged in');
      }

      // Submit feedback
      await FeedbackService.submitFeedback(
        userId: user.uid,
        orderId: widget.orderId,
        category: _selectedCategory!,
        description: _descriptionController.text.trim(),
        imageUrls: null,
      );

      // Show success alert - same flow for both with and without images
      if (mounted) {
        // Clear any previous SnackBars first
        ScaffoldMessenger.of(context).clearSnackBars();
        
        // Show success message (same message regardless of images)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check,
                    color: Colors.green,
                    size: 16,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Feedback submitted successfully!',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            duration: const Duration(seconds: 2),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            elevation: 4,
          ),
        );

        // Navigate to menu screen after a short delay (same delay for both cases)
        await Future.delayed(const Duration(milliseconds: 500));

        if (mounted) {
          context.go(menuRoute);
        }
      }
    } catch (e) {
      if (mounted) {
        String errorMessage = 'Failed to submit feedback';
        final errorString = e.toString();

        if (errorString.contains('Exception: ')) {
          errorMessage = errorString.replaceAll('Exception: ', '');
        } else {
          errorMessage = errorString;
        }

        print('❌ Feedback submission error: $e');

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $errorMessage'),
            duration: const Duration(seconds: 4),
            backgroundColor: Colors.red,
            action: SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
              onPressed: () {
                if (mounted) {
                  _submitFeedback();
                }
              },
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Submit Feedback',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Feedback Category Section
            const Text(
              '*Feedback Category',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _categories.map((category) {
                final isSelected = _selectedCategory == category;
                final isHovered = _hoveredCategory == category;
                return Tooltip(
                  message: category,
                  preferBelow: false,
                  child: MouseRegion(
                    onEnter: (_) {
                      if (mounted && !isSelected) {
                        setState(() => _hoveredCategory = category);
                      }
                    },
                    onExit: (_) {
                      if (mounted) {
                        setState(() => _hoveredCategory = null);
                      }
                    },
                    child: InkWell(
                      onTap: () {
                        if (mounted) {
                          setState(() => _selectedCategory = category);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFFFF6B6B)
                              : isHovered
                                  ? Colors.grey[200]
                                  : Colors.grey[100],
                          border: Border.all(
                            color: isSelected
                                ? const Color(0xFFFF6B6B)
                                : isHovered
                                    ? Colors.grey[400]!
                                    : Colors.grey[300]!,
                            width: isSelected ? 2 : isHovered ? 1.5 : 1,
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          category,
                          style: TextStyle(
                            fontSize: 14,
                            color: isSelected ? Colors.white : Colors.black87,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // Description Section
            const Text(
              '*Description',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            MouseRegion(
              onEnter: (_) {
                if (mounted) {
                  setState(() => _isDescriptionHovered = true);
                }
              },
              onExit: (_) {
                if (mounted) {
                  setState(() => _isDescriptionHovered = false);
                }
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(
                    color: _isDescriptionHovered
                        ? Colors.grey[400]!
                        : Colors.grey[300]!,
                    width: _isDescriptionHovered ? 1.5 : 1,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: TextField(
                  controller: _descriptionController,
                  maxLength: 500,
                  maxLines: 6,
                  onChanged: (_) {
                    if (mounted) {
                      setState(() {});
                    }
                  },
                  decoration: InputDecoration(
                    hintText:
                        'Please describe your feedback. For order issues, please contact our Online Customer Service.',
                    hintStyle: TextStyle(color: Colors.grey[500], fontSize: 14),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.all(16),
                    counterText: '',
                  ),
                ),
              ),
            ),
            const SizedBox(height: 4),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                '${_descriptionController.text.length}/500',
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
            ),
            const SizedBox(height: 32),

            // Submit Button
            CoffeeButton(
              text: _isSubmitting ? 'SUBMITTING...' : 'SUBMIT FEEDBACK',
              onPressed: _isSubmitting ? null : _submitFeedback,
              backgroundColor: const Color(0xFFFF6B6B),
              textColor: Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}
