import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:island_cafe/feature/auth/presentation/widgets/auth_widgets.dart';
import 'package:island_cafe/feature/auth/services/auth_service.dart';
import 'package:island_cafe/feature/history/service/feedback_service.dart';

class FeedbackSubmissionScreen extends StatefulWidget {
  final String? orderId;
  final String? orderNumber;

  const FeedbackSubmissionScreen({
    super.key,
    this.orderId,
    this.orderNumber,
  });

  @override
  State<FeedbackSubmissionScreen> createState() =>
      _FeedbackSubmissionScreenState();
}

class _FeedbackSubmissionScreenState extends State<FeedbackSubmissionScreen> {
  final List<String> _categories = const [
    'APP Functionality',
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
  final _picker = ImagePicker();

  String? _selectedCategory;
  List<XFile> _pickedImages = [];
  bool _isSubmitting = false;

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).bottomSheetTheme.backgroundColor,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Gallery'),
              onTap: () async {
                Navigator.of(context).pop();
                final List<XFile> images = await _picker.pickMultiImage();
                if (images.isNotEmpty && mounted) {
                  setState(() {
                    _pickedImages.addAll(images);
                    // Limit to 5 images
                    if (_pickedImages.length > 5) {
                      _pickedImages = _pickedImages.take(5).toList();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Maximum 5 images allowed'),
                        ),
                      );
                    }
                  });
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera'),
              onTap: () async {
                Navigator.of(context).pop();
                final XFile? image = await _picker.pickImage(
                  source: ImageSource.camera,
                );
                if (image != null && mounted) {
                  setState(() {
                    _pickedImages.add(image);
                    // Limit to 5 images
                    if (_pickedImages.length > 5) {
                      _pickedImages = _pickedImages.take(5).toList();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Maximum 5 images allowed'),
                        ),
                      );
                    }
                  });
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _removeImage(int index) {
    setState(() {
      _pickedImages.removeAt(index);
    });
  }

  Future<void> _submitFeedback() async {
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

      List<String> imageUrls = [];
      
      // Upload all images
      if (_pickedImages.isNotEmpty) {
        for (var image in _pickedImages) {
          try {
            final imageUrl = await AuthService.uploadFeedbackImage(
              file: image,
              uid: user.uid,
            );
            if (mounted) {
              imageUrls.add(imageUrl);
            }
          } catch (imageError) {
            // Log error but continue with other images
            print('Failed to upload image: $imageError');
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Failed to upload one image: $imageError'),
                  duration: const Duration(seconds: 2),
                ),
              );
            }
          }
        }
      }

      // Submit feedback
      await FeedbackService.submitFeedback(
        userId: user.uid,
        orderId: widget.orderId,
        category: _selectedCategory!,
        description: _descriptionController.text.trim(),
        imageUrls: imageUrls.isNotEmpty ? imageUrls : null,
      );

      // Show success alert
      if (mounted) {
        // Show success snackbar with icon
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 12),
                Expanded(
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
            duration: const Duration(seconds: 3),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
        
        // Navigate back after a short delay to show the success message
        await Future.delayed(const Duration(milliseconds: 500));
        
        if (mounted) {
          Navigator.of(context).pop(true);
        }
      }
    } catch (e) {
      if (mounted) {
        String errorMessage = 'Failed to submit feedback';
        final errorString = e.toString();
        
        // Extract the actual error message
        if (errorString.contains('Exception: ')) {
          errorMessage = errorString.replaceAll('Exception: ', '');
        } else {
          errorMessage = errorString;
        }
        
        // Provide user-friendly messages for common errors
        if (errorMessage.contains('500') || errorMessage.contains('Internal Server Error')) {
          errorMessage = 'Server error. Please try again later or contact support.';
        } else if (errorMessage.contains('timeout') || errorMessage.contains('Timeout')) {
          errorMessage = 'Request timed out. Please check your internet connection.';
        } else if (errorMessage.contains('Network') || errorMessage.contains('SocketException')) {
          errorMessage = 'Network error. Please check your internet connection.';
        } else if (errorMessage.contains('404') || errorMessage.contains('Not Found')) {
          errorMessage = 'Service not found. Please contact support.';
        } else if (errorMessage.contains('401') || errorMessage.contains('Unauthorized')) {
          errorMessage = 'Authentication failed. Please log in again.';
        } else if (errorMessage.contains('403') || errorMessage.contains('Forbidden')) {
          errorMessage = 'Access denied. Please contact support.';
        } else if (errorMessage.contains('Foreign key constraint') || 
                  errorMessage.contains('userId') && errorMessage.contains('not exist')) {
          errorMessage = 'User account issue. Please contact support.';
        }
        
        // Log the full error for debugging
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
          onPressed: () => Navigator.of(context).pop(),
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
                return Tooltip(
                  message: category,
                  preferBelow: false,
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
                            : Colors.grey[100],
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFFFF6B6B)
                              : Colors.grey[300]!,
                          width: isSelected ? 2 : 1,
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        category,
                        style: TextStyle(
                          fontSize: 14,
                          color: isSelected
                              ? Colors.white
                              : Colors.black87,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.normal,
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
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.grey[300]!),
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
            const SizedBox(height: 4),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                '${_descriptionController.text.length}/500',
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
            ),
            const SizedBox(height: 24),

            // Image Upload Section
            const Text(
              'Images (Optional)',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            
            // Display picked images
            if (_pickedImages.isNotEmpty) ...[
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: List.generate(_pickedImages.length, (index) {
                  return Stack(
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: kIsWeb
                              ? Image.network(
                                  _pickedImages[index].path,
                                  fit: BoxFit.cover,
                                  width: 100,
                                  height: 100,
                                )
                              : Image.file(
                                  File(_pickedImages[index].path),
                                  fit: BoxFit.cover,
                                  width: 100,
                                  height: 100,
                                ),
                        ),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: GestureDetector(
                          onTap: () => _removeImage(index),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                }),
              ),
              const SizedBox(height: 12),
            ],

            // Image Upload Button
            if (_pickedImages.length < 5)
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.camera_alt,
                          color: Colors.grey,
                          size: 32,
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Add Image',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            if (_pickedImages.length >= 5)
              Text(
                'Maximum 5 images reached',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
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

