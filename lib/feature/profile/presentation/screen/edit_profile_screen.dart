import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart'; // For kIsWeb
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:island_cafe/feature/auth/presentation/widgets/auth_widgets.dart';
import 'package:island_cafe/feature/auth/services/auth_service.dart';
import 'package:island_cafe/feature/auth/services/validate_service.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _birthdayController = TextEditingController();

  String? _selectedGender;
  bool _loading = false;
  bool _isEditing = false;
  bool _initialLoad = true;
  Map<String, dynamic>? _originalData;

  XFile? _pickedImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _birthdayController.dispose();
    super.dispose();
  }

  void _toggleEdit() {
    setState(() {
      _isEditing = !_isEditing;
      if (!_isEditing) _pickedImage = null;
    });
  }

  void _cancelEdit() {
    if (_originalData != null) {
      _populateFields(_originalData!);
    }
    setState(() {
      _isEditing = false;
      _pickedImage = null;
    });
  }

  void _populateFields(Map<String, dynamic> data) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _nameController.text = data['name'] ?? '';
      _phoneController.text = data['phone'] ?? '';
      _addressController.text = data['address'] ?? '';
      _birthdayController.text = data['birthday'] ?? '';
      setState(() {
        _selectedGender = data['gender'];
      });
    });
  }

  Future<void> _pickImage() async {
    if (!_isEditing) return;

    Future<void> pick(ImageSource source) async {
      Navigator.of(context).pop();
      final XFile? image = await _picker.pickImage(source: source);
      if (image != null) {
        setState(() => _pickedImage = image);
      }
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).bottomSheetTheme.backgroundColor,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Gallery'),
              onTap: () => pick(ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera'),
              onTap: () => pick(ImageSource.camera),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate() async {
    if (!_isEditing) return;
    DateTime initial = DateTime.now();
    if (_birthdayController.text.isNotEmpty) {
      try {
        initial = DateFormat('dd/MM/yyyy').parse(_birthdayController.text);
      } catch (_) {}
    }
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _birthdayController.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);
    try {
      final user = AuthService.currentUser;
      if (user != null) {
        if (_pickedImage != null) {
          final String newPhotoUrl = await AuthService.uploadProfileImage(
            file: _pickedImage!,
            uid: user.uid,
          );
          await AuthService.updateUserPhoto(newPhotoUrl);
        }

        await AuthService.saveUserDetails(
          uid: user.uid,
          name: _nameController.text.trim(),
          phone: _phoneController.text.replaceAll(' ', '').trim(),
          birthday: _birthdayController.text.isEmpty
              ? null
              : _birthdayController.text,
          address: _addressController.text.isEmpty
              ? null
              : _addressController.text.trim(),
          gender: _selectedGender,
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile Updated Successfully')),
          );
          setState(() {
            _isEditing = false;
            _pickedImage = null;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // --- NEW: Handle Account Deletion ---
  Future<void> _handleDeleteAccount() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account?'),
        content: const Text(
          'Are you sure you want to delete your account? This action cannot be undone and all your data will be removed.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() => _loading = true);
      try {
        await AuthService.deleteAccount();
        // Upon success, AuthService signs out. 
        // GoRouter should ideally listen to auth state changes, 
        // but explicit navigation ensures we leave this screen.
        if (mounted) context.go('/login'); 
      } catch (e) {
        if (mounted) {
          setState(() => _loading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to delete account: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  ImageProvider? _getImageProvider(String? currentPhotoUrl) {
    if (_pickedImage != null) {
      if (kIsWeb) {
        return NetworkImage(_pickedImage!.path);
      } else {
        return FileImage(File(_pickedImage!.path));
      }
    }
    if (currentPhotoUrl != null) {
      return NetworkImage(currentPhotoUrl);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          _isEditing ? 'Edit Profile' : 'My Profile',
          style: theme.textTheme.titleLarge?.copyWith(
            color: theme.appBarTheme.foregroundColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.appBarTheme.foregroundColor),
          onPressed: () => context.pop(),
        ),
        actions: [
          if (!_isEditing)
            IconButton(
              icon: Icon(Icons.edit_outlined, color: theme.appBarTheme.foregroundColor),
              onPressed: _toggleEdit,
            ),
        ],
      ),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: AuthService.getUserDetailsStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting && _initialLoad) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasData && _initialLoad) {
            final data = snapshot.data!.data();
            if (data != null) {
              _originalData = data;
              _populateFields(data);
            }
            _initialLoad = false;
          }

          final currentPhotoUrl = AuthService.currentUser?.photoURL;
          final imageProvider = _getImageProvider(currentPhotoUrl);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  // --- 1. Profile Image ---
                  Center(
                    child: GestureDetector(
                      onTap: _pickImage,
                      child: Stack(
                        children: [
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              color: colorScheme.surfaceContainerHighest,
                              shape: BoxShape.circle,
                              image: imageProvider != null
                                  ? DecorationImage(
                                      image: imageProvider,
                                      fit: BoxFit.cover,
                                    )
                                  : null,
                            ),
                            child: imageProvider == null
                                ? Icon(
                                    Icons.person,
                                    size: 50,
                                    color: colorScheme.onSurfaceVariant,
                                  )
                                : null,
                          ),
                          if (_isEditing)
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: colorScheme.primary,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.camera_alt,
                                  color: colorScheme.onPrimary,
                                  size: 20,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),

                  // --- 2. Input Fields ---
                  CoffeeTextField(
                    controller: _nameController,
                    label: 'Full Name',
                    icon: Icons.person_outline,
                    readOnly: !_isEditing,
                    validator: ValidationService.validateName,
                    hintText: '',
                  ),
                  CoffeeTextField(
                    controller: _phoneController,
                    label: 'Phone Number',
                    icon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                    readOnly: !_isEditing,
                    validator: ValidationService.validatePhone,
                    hintText: '',
                  ),
                  GestureDetector(
                    onTap: _selectDate,
                    child: AbsorbPointer(
                      child: CoffeeTextField(
                        controller: _birthdayController,
                        label: 'Birthday',
                        icon: Icons.cake_outlined,
                        readOnly: !_isEditing,
                        hintText: 'dd/mm/yyyy',
                      ),
                    ),
                  ),

                  // Gender Dropdown
                  IgnorePointer(
                    ignoring: !_isEditing,
                    child: DropdownButtonFormField<String>(
                      initialValue: _selectedGender,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface,
                        fontSize: 16,
                      ),
                      icon: _isEditing
                          ? Icon(Icons.arrow_drop_down, color: colorScheme.primary)
                          : const SizedBox.shrink(),
                      dropdownColor: theme.colorScheme.surface,
                      decoration: InputDecoration(
                        labelText: 'Gender',
                        labelStyle: TextStyle(color: theme.colorScheme.onSurface),
                        prefixIcon: Icon(
                          Icons.people_outline,
                          color: !_isEditing
                              ? theme.colorScheme.onSurface
                              : theme.colorScheme.primary,
                        ),
                        filled: true,
                        fillColor: theme.colorScheme.surface,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 16,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(
                            color: !_isEditing
                                ? Colors.transparent
                                : theme.colorScheme.outline,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(
                            color: theme.colorScheme.primary,
                            width: 2,
                          ),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      items: ['Male', 'Female', 'Other'].map((String val) {
                        return DropdownMenuItem<String>(
                          value: val,
                          child: Text(val),
                        );
                      }).toList(),
                      onChanged: _isEditing
                          ? (val) => setState(() => _selectedGender = val)
                          : null,
                      selectedItemBuilder: (context) =>
                          ['Male', 'Female', 'Other'].map((val) {
                        return Text(
                          val,
                          style: TextStyle(color: theme.colorScheme.onSurface),
                        );
                      }).toList(),
                    ),
                  ),

                  const SizedBox(height: 20),
                  CoffeeTextField(
                    controller: _addressController,
                    label: 'Address',
                    icon: Icons.location_on_outlined,
                    readOnly: !_isEditing,
                    hintText: '',
                  ),
                  const SizedBox(height: 30),

                  // --- 3. Action Buttons (Save/Cancel) ---
                  if (_isEditing)
                    Row(
                      children: [
                        Expanded(
                          child: CoffeeButton(
                            text: 'Cancel',
                            backgroundColor: isDarkMode
                                ? Colors.grey[800]
                                : Colors.grey[300],
                            textColor: colorScheme.onSurface,
                            onPressed: _cancelEdit,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: CoffeeButton(
                            text: 'Save Changes',
                            onPressed: _saveProfile,
                            isLoading: _loading,
                          ),
                        ),
                      ],
                    ),

                  // --- 4. NEW: Delete Account Section ---
                  // Only show when not in editing mode (or you can remove the if condition to show always)
                  if (!_isEditing) ...[
                    const SizedBox(height: 40),
                    Divider(color: theme.dividerColor),
                    const SizedBox(height: 10),
                    Center(
                      child: TextButton.icon(
                        onPressed: _loading ? null : _handleDeleteAccount,
                        icon: const Icon(
                          Icons.delete_forever_rounded,
                          color: Colors.redAccent,
                          size: 20,
                        ),
                        label: const Text(
                          'Delete Account',
                          style: TextStyle(
                            color: Colors.redAccent,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
