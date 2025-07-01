import 'package:bookstore/common/di/dependencies.dart';
import 'package:bookstore/common/widgets/custom_button.dart';
import 'package:bookstore/common/widgets/status_message.dart';
import 'package:bookstore/features/account/services/account_service.dart';
import 'package:bookstore/features/cart_wishlist/models/cart_item_model.dart';
import 'package:bookstore/features/cart_wishlist/screens/order_success_screen.dart';
import 'package:bookstore/features/cart_wishlist/services/cart_service.dart';
import 'package:bookstore/features/cart_wishlist/services/order_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _cartService = locator<CartService>();
  final _orderService = locator<OrderService>();
  final _formKey = GlobalKey<FormState>();

  String _selectedPaymentMethod = 'Credit Card';
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _zipController = TextEditingController();
  final _countryController = TextEditingController();

  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _loadSavedAddress();
  }

  Future<void> _loadSavedAddress() async {
    try {
      final accountService = locator<AccountService>();
      final addressData = await accountService.getShippingAddress();

      if (addressData != null) {
        setState(() {
          _addressController.text = addressData['streetAddress'] ?? '';
          _cityController.text = addressData['city'] ?? '';
          _stateController.text = addressData['state'] ?? '';
          _zipController.text =
              ''; // ZIP code isn't stored in the current schema
          _countryController.text = addressData['country'] ?? '';
          // Optional: Handle apartment if needed
          // _addressController.text += addressData['apartment'] != null ? '\n${addressData['apartment']}' : '';
        });
      } else {
        // Keep placeholder values if no address is found
        setState(() {
          _addressController.text = '123 Main St';
          _cityController.text = 'City';
          _stateController.text = 'NY';
          _zipController.text = '10001';
          _countryController.text = 'United States';
        });
      }
    } catch (e) {
      // Handle error, e.g., show error message or use default values
      showMessage('Failed to load address', StatusMessage.error);
      setState(() {
        _addressController.text = '123 Main St';
        _cityController.text = 'New York';
        _stateController.text = 'NY';
        _zipController.text = '10001';
        _countryController.text = 'United States';
      });
    }
  }

  Future<void> _processPayment() async {
    setState(() {
      _isProcessing = true;
    });

    // Simulate payment processing delay
    await Future.delayed(const Duration(seconds: 2));

    // Randomly decide if payment succeeds (80% chance) or fails (20% chance)
    final random = DateTime.now().millisecond % 10;
    final paymentSuccess = random < 8; // 80% success rate

    setState(() {
      _isProcessing = false;
    });

    if (paymentSuccess) {
      return _createOrder();
    } else {
      showMessage('Payment failed. Please try again.', StatusMessage.error);
    }
  }

  Future<void> _createOrder() async {
    try {
      final cartItems = await _cartService.getCartItems();
      final total = cartItems.fold(
        0,
        (sum, item) => sum + (item.book.price * item.quantity),
      );

      final shippingAddress = '''
${_addressController.text}
${_cityController.text}, ${_stateController.text} ${_zipController.text}
${_countryController.text}
''';

      final order = await _orderService.createOrder(
        items: cartItems,
        totalAmount: total.toDouble(),
        shippingAddress: shippingAddress,
        paymentMethod: _selectedPaymentMethod,
      );

      // Clear cart after successful order
      await _cartService.clearCart();

      // Navigate to order success screen
      Get.off(() => OrderSuccessScreen(order: order));
    } catch (e) {
      showMessage(
        'Failed to create order: ${e.toString()}',
        StatusMessage.error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: StreamBuilder<List<CartItemModel>>(
        stream: _cartService.cartItemsStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final cartItems = snapshot.data ?? [];

          if (cartItems.isEmpty) {
            return const Center(child: Text('Your cart is empty'));
          }

          final total = cartItems.fold(
            0,
            (sum, item) => sum + (item.book.price * item.quantity),
          );

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Shipping Address',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _addressController,
                    decoration: const InputDecoration(
                      labelText: 'Street Address',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your address';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _cityController,
                          decoration: const InputDecoration(
                            labelText: 'City',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your city';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _stateController,
                          decoration: const InputDecoration(
                            labelText: 'State',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your state';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _zipController,
                          decoration: const InputDecoration(
                            labelText: 'ZIP Code',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your ZIP code';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _countryController,
                          decoration: const InputDecoration(
                            labelText: 'Country',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your country';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Payment Method',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  PaymentMethodCard(
                    icon: Icons.credit_card,
                    title: 'Credit Card',
                    isSelected: _selectedPaymentMethod == 'Credit Card',
                    onTap: () {
                      setState(() {
                        _selectedPaymentMethod = 'Credit Card';
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  PaymentMethodCard(
                    icon: Icons.paypal,
                    title: 'PayPal',
                    isSelected: _selectedPaymentMethod == 'PayPal',
                    onTap: () {
                      setState(() {
                        _selectedPaymentMethod = 'PayPal';
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  PaymentMethodCard(
                    icon: Icons.account_balance_wallet,
                    title: 'Bank Transfer',
                    isSelected: _selectedPaymentMethod == 'Bank Transfer',
                    onTap: () {
                      setState(() {
                        _selectedPaymentMethod = 'Bank Transfer';
                      });
                    },
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Order Summary',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: cartItems.length,
                    itemBuilder: (context, index) {
                      final item = cartItems[index];
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Container(
                          width: 50,
                          height: 70,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                            color: Colors.grey.shade200,
                            image:
                                item.book.imageUrl != null
                                    ? DecorationImage(
                                      image: NetworkImage(item.book.imageUrl!),
                                      fit: BoxFit.cover,
                                    )
                                    : null,
                          ),
                          child:
                              item.book.imageUrl == null
                                  ? const Icon(
                                    Icons.book,
                                    size: 24,
                                    color: Colors.grey,
                                  )
                                  : null,
                        ),
                        title: Text(item.book.title),
                        subtitle: Text('Qty: ${item.quantity}'),
                        trailing: Text(
                          '\$${(item.book.price * item.quantity).toStringAsFixed(2)}',
                        ),
                      );
                    },
                  ),
                  const Divider(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Subtotal', style: TextStyle(fontSize: 16)),
                      Text(
                        '\$${total.toStringAsFixed(2)}',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Shipping', style: TextStyle(fontSize: 16)),
                      Text('\$5.99', style: const TextStyle(fontSize: 16)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Tax', style: TextStyle(fontSize: 16)),
                      Text(
                        '\$${(total * 0.08).toStringAsFixed(2)}',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '\$${(total + 5.99 + (total * 0.08)).toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  CustomButton(
                    onPressed: _processPayment,
                    buttonText: _isProcessing ? 'Processing...' : 'Place Order',
                    isEnabled: !_isProcessing,
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

class PaymentMethodCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  const PaymentMethodCard({
    super.key,
    required this.icon,
    required this.title,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color:
              isSelected
                  ? Theme.of(context).primaryColor
                  : Colors.grey.shade300,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(
                icon,
                color:
                    isSelected ? Theme.of(context).primaryColor : Colors.grey,
                size: 30,
              ),
              const SizedBox(width: 16),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color:
                      isSelected
                          ? Theme.of(context).primaryColor
                          : Colors.black,
                ),
              ),
              const Spacer(),
              if (isSelected)
                Icon(Icons.check_circle, color: Theme.of(context).primaryColor),
            ],
          ),
        ),
      ),
    );
  }
}
