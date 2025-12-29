import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:island_cafe/feature/auth/data/providers/auth_provider.dart';
import 'package:island_cafe/feature/auth/presentation/widgets/auth_widgets.dart';
import 'package:island_cafe/feature/auth/services/auth_service.dart';
import 'package:island_cafe/feature/auth/services/validate_service.dart';
import 'package:intl/intl.dart';

class UserInfoScreen extends ConsumerStatefulWidget {
  const UserInfoScreen({super.key});

  @override
  ConsumerState<UserInfoScreen> createState() => _UserInfoScreenState();
}

class _UserInfoScreenState extends ConsumerState<UserInfoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _birthdayController = TextEditingController();
  
  String? _selectedGender;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = AuthService.currentUser;
      if (user?.displayName != null) {
        _nameController.text = user!.displayName!;
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _birthdayController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 18)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _birthdayController.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  Future<void> _submitData() async {
    // 1. Only validate Name and Phone
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    try {
      final user = AuthService.currentUser;
      if (user == null) return;

      await AuthService.saveUserDetails(
        uid: user.uid,
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        birthday: _birthdayController.text.isEmpty ? null : _birthdayController.text.trim(),
        address: _addressController.text.isEmpty ? null : _addressController.text.trim(),
        gender: _selectedGender,
      );
      
      ref.invalidate(isProfileCompleteProvider);
      
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return CoffeeAuthLayout(
      title: 'Complete Profile',
      subtitle: 'Tell us a bit more about yourself.',
      showLogo: false,
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CoffeeTextField(
              controller: _nameController,
              label: 'Full Name',
              icon: Icons.person_outline,
              validator: ValidationService.validateName, hintText: '',
            ),
            CoffeeTextField(
              controller: _phoneController,
              label: 'Phone Number',
              icon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
              validator: ValidationService.validatePhone, hintText: '',
            ),
            
            // Birthday Field (Optional)
            GestureDetector(
              onTap: _selectDate,
              child: AbsorbPointer(
                child: CoffeeTextField(
                  controller: _birthdayController,
                  label: 'Birthday (Optional)',
                  icon: Icons.cake_outlined,
                  hintText: 'dd/MM/yyyy',
                ),
              ),
            ),


            // Gender (Optional)
            DropdownButtonFormField<String>(
              initialValue: _selectedGender,
              decoration: InputDecoration(
                labelText: 'Gender (Optional)',
              ),
              items: ['Male', 'Female', 'Other'].map((String val) {
                return DropdownMenuItem(value: val, child: Text(val));
              }).toList(),
              onChanged: (val) => setState(() => _selectedGender = val),
            ),
            
            // Address
            const SizedBox(height: 20),
            CoffeeTextField(
              controller: _addressController,
              label: 'Address (Optional)',
              icon: Icons.location_on_outlined, hintText: '',
            ),

            const SizedBox(height: 24),
            CoffeeButton(
              text: 'Complete Profile',
              onPressed: _submitData,
              isLoading: _loading,
            ),
          ],
        ),
      ),
    );
  }
}