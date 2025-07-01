import 'package:bookstore/common/di/dependencies.dart';
import 'package:bookstore/common/exceptions/custom_exception.dart';
import 'package:bookstore/common/widgets/custom_button.dart';
import 'package:bookstore/common/widgets/custom_text_field.dart';
import 'package:bookstore/common/widgets/status_message.dart';
import 'package:bookstore/features/account/services/account_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ProfileEditForm extends StatefulWidget {
  const ProfileEditForm({super.key});

  @override
  State<ProfileEditForm> createState() => _ProfileEditFormState();
}

class _ProfileEditFormState extends State<ProfileEditForm> {
  final _accountService = locator.get<AccountService>();

  final _profileFormKey = GlobalKey<FormState>();

  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _phoneNumberController;
  late TextEditingController _emailController;

  bool _isLoading = false;
  bool _isProfileLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _loadData();
  }

  void _initializeControllers() {
    _firstNameController = TextEditingController();
    _lastNameController = TextEditingController();
    _phoneNumberController = TextEditingController();
    _emailController = TextEditingController(
      text: FirebaseAuth.instance.currentUser?.email,
    );
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      await _loadProfile();
    } catch (e) {
      showMessage('Failed to load data', StatusMessage.error);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadProfile() async {
    setState(() => _isProfileLoading = true);
    try {
      final profile = await _accountService.getUserProfile();
      _firstNameController.text = profile['firstName'] ?? '';
      _lastNameController.text = profile['lastName'] ?? '';
      _phoneNumberController.text = profile['phoneNumber'] ?? '';
    } catch (e) {
      showMessage('Failed to load profile', StatusMessage.error);
    } finally {
      setState(() => _isProfileLoading = false);
    }
  }

  Future<void> _updateProfile() async {
    if (!_profileFormKey.currentState!.validate()) return;

    setState(() => _isProfileLoading = true);
    try {
      await _accountService.updateUserProfile(
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        phoneNumber: _phoneNumberController.text.trim(),
      );
      showMessage('Profile updated successfully', StatusMessage.success);
    } on BookStoreAppException catch (e) {
      showMessage(e.message, StatusMessage.error);
    } catch (e) {
      showMessage('Failed to update profile', StatusMessage.error);
    } finally {
      setState(() => _isProfileLoading = false);
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneNumberController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? const Center(child: CircularProgressIndicator())
        : Form(
          key: _profileFormKey,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(15, 15, 15, 15),
            child: Column(
              children: [
                Expanded(
                  child: ListView(
                    children: [
                      CustomTextField(
                        controller: _firstNameController,
                        label: 'First Name',
                        placeholder: 'Enter your first name',
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'First name is required';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 30),
                      CustomTextField(
                        controller: _lastNameController,
                        label: 'Last Name',
                        placeholder: 'Enter your last name',
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Last name is required';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 30),
                      CustomTextField(
                        controller: _emailController,
                        label: 'Email',
                        placeholder: 'Enter your email',
                        enabled: false,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Email is required';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 30),
                      CustomTextField(
                        controller: _phoneNumberController,
                        label: 'Phone Number',
                        placeholder: 'Enter your phone number',
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Phone number is required';
                          }
                          if (value.length < 10) {
                            return 'Enter a valid phone number';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 50),
                      CustomButton(
                        onPressed: _updateProfile,
                        buttonText: 'Update Profile',
                        isLoading: _isProfileLoading,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
  }
}
