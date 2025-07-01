import 'package:bookstore/common/di/dependencies.dart';
import 'package:bookstore/common/exceptions/custom_exception.dart';
import 'package:bookstore/common/widgets/custom_button.dart';
import 'package:bookstore/common/widgets/custom_text_field.dart';
import 'package:bookstore/common/widgets/status_message.dart';
import 'package:bookstore/features/account/services/account_service.dart';
import 'package:flutter/material.dart';

class ShippingEditForm extends StatefulWidget {
  const ShippingEditForm({super.key});

  @override
  State<ShippingEditForm> createState() => _ShippingEditFormState();
}

class _ShippingEditFormState extends State<ShippingEditForm> {
  final _accountService = locator.get<AccountService>();

  final _addressFormKey = GlobalKey<FormState>();

  late TextEditingController _countryController;
  late TextEditingController _stateController;
  late TextEditingController _cityController;
  late TextEditingController _streetAddressController;
  late TextEditingController _apartmentController;

  bool _isLoading = false;
  bool _isAddressLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _loadData();
  }

  void _initializeControllers() {
    _countryController = TextEditingController();
    _stateController = TextEditingController();
    _cityController = TextEditingController();
    _streetAddressController = TextEditingController();
    _apartmentController = TextEditingController();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      await _loadAddress();
    } catch (e) {
      showMessage('Failed to load data', StatusMessage.error);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadAddress() async {
    setState(() => _isAddressLoading = true);
    try {
      final address = await _accountService.getShippingAddress();
      if (address != null) {
        _countryController.text = address['country'] ?? '';
        _stateController.text = address['state'] ?? '';
        _cityController.text = address['city'] ?? '';
        _streetAddressController.text = address['streetAddress'] ?? '';
        _apartmentController.text = address['apartment'] ?? '';
      }
    } catch (e) {
      showMessage('Failed to load address', StatusMessage.error);
    } finally {
      setState(() => _isAddressLoading = false);
    }
  }

  Future<void> _updateAddress() async {
    if (!_addressFormKey.currentState!.validate()) return;

    setState(() => _isAddressLoading = true);
    try {
      await _accountService.updateShippingAddress(
        country: _countryController.text.trim(),
        streetAddress: _streetAddressController.text.trim(),
        apartment: _apartmentController.text.trim(),
        state: _stateController.text.trim(),
        city: _cityController.text.trim(),
      );
      showMessage('Address updated successfully', StatusMessage.success);
    } on BookStoreAppException catch (e) {
      showMessage(e.message, StatusMessage.error);
    } catch (e) {
      showMessage('Failed to update address', StatusMessage.error);
    } finally {
      setState(() => _isAddressLoading = false);
    }
  }

  @override
  void dispose() {
    _countryController.dispose();
    _stateController.dispose();
    _cityController.dispose();
    _streetAddressController.dispose();
    _apartmentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? const Center(child: CircularProgressIndicator())
        : Form(
          key: _addressFormKey,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(15, 15, 15, 15),
            child: Column(
              children: [
                Expanded(
                  child: ListView(
                    children: [
                      CustomTextField(
                        controller: _countryController,
                        label: 'Country',
                        placeholder: 'Enter your country',
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Country is required';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 30),
                      CustomTextField(
                        controller: _stateController,
                        label: 'State',
                        placeholder: 'Enter your state',
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'State is required';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 30),
                      CustomTextField(
                        controller: _cityController,
                        label: 'City',
                        placeholder: 'Enter your city',
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'City is required';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 30),
                      CustomTextField(
                        controller: _streetAddressController,
                        label: 'Street Address',
                        placeholder: 'Enter your street address',
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Street address is required';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 30),
                      CustomTextField(
                        controller: _apartmentController,
                        label: 'Apartment/Building',
                        placeholder: 'Enter apartment or building number',
                      ),
                      const SizedBox(height: 50),
                      CustomButton(
                        onPressed: _updateAddress,
                        buttonText: 'Save Address',
                        isLoading: _isAddressLoading,
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
