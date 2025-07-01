import 'package:bookstore/common/exceptions/custom_exception.dart';
import 'package:bookstore/common/widgets/custom_button.dart';
import 'package:bookstore/common/widgets/custom_text_field.dart';
import 'package:bookstore/common/widgets/status_message.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../common/di/dependencies.dart';
import '../services/auth_service.dart';

class ForgottenPasswordForm extends StatefulWidget {
  const ForgottenPasswordForm({super.key});

  @override
  State<ForgottenPasswordForm> createState() => _ForgottenPasswordFormState();
}

class _ForgottenPasswordFormState extends State<ForgottenPasswordForm> {
  final TextEditingController _emailController = TextEditingController();
  final _authService = locator<AuthService>();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isLoading = true;
    });

    try {
      await _authService.resetPassword(_emailController.text.trim());
      Get.toNamed(
        '/reset-password-email-sent',
        arguments: {'email': _emailController.text.trim()},
      );
    } on BookStoreAppException catch (e) {
      showMessage(e.message, StatusMessage.error);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(15, 50, 15, 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Reset Your Password',
                    style: Theme.of(context).textTheme.headlineLarge,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Please enter the email you used when you joined us",
                    style: Theme.of(
                      context,
                    ).textTheme.titleMedium?.copyWith(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 25),
                  CustomTextField(
                    placeholder: "Enter your email",
                    label: "Email",
                    prefixIcon: const Icon(Icons.email_outlined),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Email is required';
                      }
                      return null;
                    },
                    controller: _emailController,
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 30),
            child: Column(
              children: [
                GestureDetector(
                  onTap: () {
                    FocusManager.instance.primaryFocus?.unfocus();
                    Get.toNamed('login');
                  },
                  child: RichText(
                    text: TextSpan(
                      style: const TextStyle(
                        fontWeight: FontWeight.normal,
                        fontSize: 15,
                      ),
                      children: [
                        TextSpan(
                          text: "You remember your password? ",
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: Colors.grey[600]),
                        ),
                        TextSpan(
                          text: "login",
                          style: Theme.of(
                            context,
                          ).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                CustomButton(
                  onPressed: _handleSubmit,
                  isLoading: _isLoading,
                  buttonText: "Continue",
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
