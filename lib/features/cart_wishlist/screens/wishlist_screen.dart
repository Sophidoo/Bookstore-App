import 'package:bookstore/common/di/dependencies.dart';
import 'package:bookstore/features/cart_wishlist/services/cart_service.dart';
import 'package:bookstore/features/cart_wishlist/services/wishlist_service.dart';
import 'package:bookstore/features/catalog/models/book_model.dart';
import 'package:bookstore/features/catalog/screens/book_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class WishlistScreen extends StatelessWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final _wishlistService = locator<WishlistService>();

    return Scaffold(
      appBar: AppBar(title: const Text('Your Wishlist')),
      body: StreamBuilder<List<BookModel>>(
        stream: _wishlistService.wishlistStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final wishlistItems = snapshot.data ?? [];

          if (wishlistItems.isEmpty) {
            return const Center(child: Text('Your wishlist is empty'));
          }

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.7,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: wishlistItems.length,
            itemBuilder: (context, index) {
              final book = wishlistItems[index];
              return WishlistItemCard(book: book);
            },
          );
        },
      ),
    );
  }
}

class WishlistItemCard extends StatelessWidget {
  final BookModel book;

  const WishlistItemCard({super.key, required this.book});

  @override
  Widget build(BuildContext context) {
    final _wishlistService = locator<WishlistService>();
    final _cartService = locator<CartService>();

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Get.to(() => BookDetailsScreen(book: book));
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.grey.shade200,
                    image:
                        book.imageUrl != null
                            ? DecorationImage(
                              image: NetworkImage(book.imageUrl!),
                              fit: BoxFit.cover,
                            )
                            : null,
                  ),
                  child:
                      book.imageUrl == null
                          ? const Center(
                            child: Icon(
                              Icons.book,
                              size: 40,
                              color: Colors.grey,
                            ),
                          )
                          : null,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                book.title,
                style: Theme.of(context).textTheme.titleMedium,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                book.author,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: Colors.grey.shade600),
              ),
              const SizedBox(height: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '\$${book.price.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.shopping_cart),
                        onPressed: () async {
                          try {
                            await _cartService.addToCart(book);
                            Get.snackbar(
                              'Added to Cart',
                              '${book.title} has been added to your cart',
                              snackPosition: SnackPosition.BOTTOM,
                            );
                          } catch (e) {
                            Get.snackbar(
                              'Error',
                              'Failed to add to cart',
                              snackPosition: SnackPosition.BOTTOM,
                            );
                          }
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.favorite, color: Colors.red),
                        onPressed: () async {
                          await _wishlistService.toggleWishlist(book);
                        },
                      ),
                    ],
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
