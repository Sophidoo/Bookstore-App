import 'package:bookstore/common/di/dependencies.dart';
import 'package:bookstore/common/widgets/custom_button.dart';
import 'package:bookstore/common/widgets/status_message.dart';
import 'package:bookstore/features/cart_wishlist/models/cart_item_model.dart';
import 'package:bookstore/features/cart_wishlist/screens/checkout_screen.dart';
import 'package:bookstore/features/cart_wishlist/services/cart_service.dart';
import 'package:bookstore/features/catalog/screens/book_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final _cartService = locator<CartService>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Cart'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () async {
              try {
                await _cartService.clearCart();
                showMessage('Cart cleared', StatusMessage.success);
              } catch (e) {
                showMessage('Failed to clear cart', StatusMessage.error);
              }
            },
          ),
        ],
      ),
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

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: cartItems.length,
                  itemBuilder: (context, index) {
                    final item = cartItems[index];
                    return CartItemCard(item: item);
                  },
                ),
              ),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(top: BorderSide(color: Colors.grey.shade200)),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        Text(
                          '\$${cartItems.fold(0, (total, item) => total + item.totalPrice).toStringAsFixed(2)}',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    CustomButton(
                      onPressed: () {
                        // Implement checkout
                        Get.to(() => const CheckoutScreen());
                      },
                      buttonText: 'Checkout',
                      isEnabled: true,
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class CartItemCard extends StatelessWidget {
  final CartItemModel item;

  const CartItemCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final _cartService = locator<CartService>();

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () {
          Get.to(() => BookDetailsScreen(book: item.book));
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 80,
                height: 100,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
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
                        ? const Icon(Icons.book, size: 40, color: Colors.grey)
                        : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.book.title,
                      style: Theme.of(context).textTheme.titleMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      item.book.author,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '\$${(item.book.price * item.quantity).toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove),
                    onPressed: () async {
                      if (item.quantity > 1) {
                        await _cartService.updateQuantity(
                          item.id,
                          item.quantity - 1,
                        );
                      } else {
                        await _cartService.removeFromCart(item.id);
                      }
                    },
                  ),
                  Text(item.quantity.toString()),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () async {
                      await _cartService.updateQuantity(
                        item.id,
                        item.quantity + 1,
                      );
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: () async {
                      await _cartService.removeFromCart(item.id);
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
