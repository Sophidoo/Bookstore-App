import 'package:bookstore/common/widgets/custom_button.dart';
import 'package:bookstore/core/navigation/bottom_navigation.dart';
import 'package:bookstore/features/cart_wishlist/models/order_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OrderSuccessScreen extends StatelessWidget {
  final OrderModel order;

  const OrderSuccessScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.green.shade100,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check,
                size: 60,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Order Placed Successfully!',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Your order #${order.id.substring(0, 8).toUpperCase()} has been placed successfully.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'We will notify you when your order is shipped.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: CustomButton(
                    onPressed: () {
                      Get.offAll(() => const MainScreen());
                    },
                    buttonText: 'Continue Shopping',
                    isEnabled: true,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: CustomButton(
                    onPressed: () {
                      // Navigate to order details
                      // Get.to(() => OrderDetailsScreen(orderId: order.id));
                    },
                    buttonText: 'View Order',
                    isEnabled: true,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}