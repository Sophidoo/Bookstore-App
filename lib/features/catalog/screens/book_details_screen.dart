import 'package:bookstore/common/di/dependencies.dart';
import 'package:bookstore/common/widgets/custom_button.dart';
import 'package:bookstore/features/cart_wishlist/screens/review_submission_screen.dart';
import 'package:bookstore/features/cart_wishlist/screens/reviews_list_screen.dart';
import 'package:bookstore/features/cart_wishlist/services/cart_service.dart';
import 'package:bookstore/features/cart_wishlist/services/review_service.dart';
import 'package:bookstore/features/cart_wishlist/services/wishlist_service.dart';
import 'package:bookstore/features/catalog/models/book_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:get/get.dart';

class BookDetailsScreen extends StatelessWidget {
  final BookModel book;

  const BookDetailsScreen({super.key, required this.book});

  @override
  Widget build(BuildContext context) {
    final _wishlistService = locator<WishlistService>();
    final _cartService = locator<CartService>();
    final _reviewService = locator<ReviewService>();

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background:
                  book.imageUrl?.isNotEmpty ?? false
                      ? Image.network(
                        book.imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey.shade200,
                            child: const Center(
                              child: Icon(
                                Icons.book_outlined,
                                size: 64,
                                color: Colors.grey,
                              ),
                            ),
                          );
                        },
                      )
                      : Container(
                        color: Colors.grey.shade200,
                        child: const Center(
                          child: Icon(
                            Icons.book_outlined,
                            size: 64,
                            color: Colors.grey,
                          ),
                        ),
                      ),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Get.back(),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    book.title,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'by ${book.author}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          '\$${book.price}',
                          style: Theme.of(
                            context,
                          ).textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const Spacer(),
                      StreamBuilder<bool>(
                        stream: _wishlistService.isInWishlistStream(book.id),
                        builder: (context, snapshot) {
                          final isInWishlist = snapshot.data ?? false;
                          return IconButton(
                            icon: Icon(
                              isInWishlist
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: isInWishlist ? Colors.red : null,
                            ),
                            onPressed: () async {
                              await _wishlistService.toggleWishlist(book);
                            },
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildRatingSection(context, book),
                  const SizedBox(height: 24),
                  Text(
                    'Description',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    book.description,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 32),
                  CustomButton(
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
                    buttonText: 'Add to Cart',
                    isEnabled: true,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingSection(BuildContext context, BookModel book) {
    final _reviewService = locator<ReviewService>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Rating',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    RatingBarIndicator(
                      rating: book.averageRating ?? 0,
                      itemBuilder:
                          (context, index) =>
                              const Icon(Icons.star, color: Colors.amber),
                      itemCount: 5,
                      itemSize: 20,
                      direction: Axis.horizontal,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${book.averageRating?.toStringAsFixed(1) ?? '0.0'} (${book.reviewCount ?? 0})',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ],
            ),
            const Spacer(),
            // Only show "See all reviews" button if there are reviews
            if (book.reviewCount != null && book.reviewCount! > 0)
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ReviewsListScreen(book: book),
                    ),
                  );
                },
                child: const Text('See all reviews'),
              ),
          ],
        ),
        const SizedBox(height: 8),
        // Show "No reviews yet" message if there are no reviews
        if (book.reviewCount == null || book.reviewCount == 0)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              'No reviews yet',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey.shade600,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        // Show "Write a review" button if user hasn't reviewed yet
        if (book.reviewCount != null && book.reviewCount! > 0)
          FutureBuilder<bool>(
            future: _reviewService.hasUserReviewedBook(book.id),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SizedBox();
              }

              if (snapshot.hasData && !snapshot.data!) {
                return TextButton(
                  onPressed: () => _submitReview(context, book),
                  child: const Text('Write a review'),
                );
              }

              return const SizedBox();
            },
          ),
      ],
    );
  }

  Future<void> _submitReview(BuildContext context, BookModel book) async {
    final _reviewService = locator<ReviewService>();

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReviewSubmissionScreen(book: book),
      ),
    );

    if (result != null) {
      try {
        await _reviewService.submitReview(
          bookId: book.id,
          rating: result['rating'],
          comment: result['comment'],
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Review submitted successfully')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to submit review: ${e.toString()}')),
        );
      }
    }
  }
}
