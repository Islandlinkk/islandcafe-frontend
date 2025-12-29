import 'dart:io'; // Needed for File
import 'package:cloud_firestore/cloud_firestore.dart';
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

  // --- NEW: Image Picker Variables ---
  File? _pickedImage;
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
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Gallery'),
              onTap: () async {
                Navigator.of(context).pop();
                final XFile? image = await _picker.pickImage(
                  source: ImageSource.gallery,
                );
                if (image != null)
                  setState(() => _pickedImage = File(image.path));
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
                if (image != null)
                  setState(() => _pickedImage = File(image.path));
              },
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
        initial = DateFormat('dd/mm/yyyy').parse(_birthdayController.text);
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
        _birthdayController.text = DateFormat('dd/mm/yyyy').format(picked);
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
          phone: _phoneController.text.trim(),
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
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          _isEditing ? 'Edit Profile' : 'My Profile',
          style: const TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => context.pop(),
        ),
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit_outlined, color: Colors.black),
              onPressed: _toggleEdit,
            ),
        ],
      ),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: AuthService.getUserDetailsStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting &&
              _initialLoad) {
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

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Center(
                    child: GestureDetector(
                      onTap: _pickImage,
                      child: Stack(
                        children: [
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              shape: BoxShape.circle,
                              image: _pickedImage != null
                                  ? DecorationImage(
                                      image: FileImage(_pickedImage!),
                                      fit: BoxFit.cover,
                                    )
                                  : (currentPhotoUrl != null
                                        ? DecorationImage(
                                            image: NetworkImage(
                                              currentPhotoUrl,
                                            ),
                                            fit: BoxFit.cover,
                                          )
                                        : null),
                            ),
                            child:
                                (_pickedImage == null &&
                                    currentPhotoUrl == null)
                                ? Icon(
                                    Icons.person,
                                    size: 50,
                                    color: Colors.grey[400],
                                  )
                                : null,
                          ),
                          if (_isEditing)
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: const BoxDecoration(
                                  color: CoffeeColors.primary,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.camera_alt,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),

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
                        // Display stored date in dd/MM/yyyy format
                        // (the controller's text is already set in _selectDate with DateFormat('dd/MM/yyyy'))
                      ),
                    ),
                  ),
                  IgnorePointer(
                    ignoring: !_isEditing,
                    child: DropdownButtonFormField<String>(
                      initialValue: _selectedGender,
                      decoration: InputDecoration(
                        labelText: 'Gender',
                        prefixIcon: Icon(
                          Icons.people_outline,
                          color: _isEditing
                              ? const Color(0xFFA1887F)
                              : Colors.grey,
                        ),
                        filled: true,
                        fillColor: _isEditing
                            ? Colors.grey[50]
                            : Colors.grey[100],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(
                            color: _isEditing
                                ? Colors.grey.shade200
                                : Colors.transparent,
                          ),
                        ),
                      ),
                      items: ['Male', 'Female', 'Other'].map((String val) {
                        return DropdownMenuItem(value: val, child: Text(val));
                      }).toList(),
                      onChanged: _isEditing
                          ? (val) => setState(() => _selectedGender = val)
                          : null,
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
                  if (_isEditing)
                    Row(
                      children: [
                        Expanded(
                          child: CoffeeButton(
                            text: 'Cancel',
                            backgroundColor: Colors.grey[300],
                            textColor: Colors.black87,
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
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
