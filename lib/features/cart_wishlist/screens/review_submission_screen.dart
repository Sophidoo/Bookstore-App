import 'package:bookstore/common/di/dependencies.dart';
import 'package:bookstore/common/widgets/custom_button.dart';
import 'package:bookstore/common/widgets/status_message.dart';
import 'package:bookstore/features/cart_wishlist/services/review_service.dart';
import 'package:bookstore/features/cart_wishlist/widgets/loading_indicator.dart';
import 'package:bookstore/features/catalog/models/book_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class ReviewSubmissionScreen extends StatefulWidget {
  final BookModel book;
  final String? orderId;

  const ReviewSubmissionScreen({super.key, required this.book, this.orderId});

  @override
  State<ReviewSubmissionScreen> createState() => _ReviewSubmissionScreenState();
}

class _ReviewSubmissionScreenState extends State<ReviewSubmissionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _commentController = TextEditingController();
  final _reviewService = locator<ReviewService>();
  double _rating = 0;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Write a Review'), elevation: 0),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeaderSection(),
                const SizedBox(height: 24),
                _buildRatingSection(),
                const SizedBox(height: 32),
                _buildReviewForm(),
                const SizedBox(height: 32),
                _buildSubmitButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Rate Your Experience',
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          'Share your thoughts about "${widget.book.title}"',
          style: Theme.of(
            context,
          ).textTheme.bodyLarge?.copyWith(color: Colors.grey.shade600),
        ),
      ],
    );
  }

  Widget _buildRatingSection() {
    return Column(
      children: [
        Text(
          'How would you rate this book?',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 16),
        RatingBar.builder(
          initialRating: _rating,
          minRating: 1,
          glow: false,
          allowHalfRating: true,
          itemCount: 5,
          itemSize: 40,
          itemPadding: const EdgeInsets.symmetric(horizontal: 4),
          itemBuilder:
              (context, _) =>
                  const Icon(Icons.star_rounded, color: Colors.amber),
          onRatingUpdate: (rating) {
            setState(() {
              _rating = rating;
            });
          },
          updateOnDrag: true,
        ),
        const SizedBox(height: 8),
        Text(
          _rating == 0 ? 'Tap to rate' : '${_rating.toStringAsFixed(1)} Stars',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600),
        ),
      ],
    );
  }

  Widget _buildReviewForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Your Review', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),
        TextFormField(
          controller: _commentController,
          decoration: InputDecoration(
            hintText: 'What did you like or dislike about this book?',
            hintStyle: TextStyle(color: Colors.grey.shade500),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Theme.of(context).primaryColor),
            ),
            contentPadding: const EdgeInsets.all(16),
          ),
          maxLines: 6,
          minLines: 4,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please share your thoughts about this book';
            }
            if (value.length < 20) {
              return 'Please write at least 20 characters';
            }
            return null;
          },
        ),
        const SizedBox(height: 8),
        Text(
          'Minimum 20 characters',
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: Colors.grey.shade500),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child:
          _isSubmitting
              ? const LoadingIndicator()
              : CustomButton(
                onPressed: _submitReview,
                buttonText: 'Submit Review',
                isEnabled: _rating > 0,
              ),
    );
  }

  Future<void> _submitReview() async {
    if (!_formKey.currentState!.validate() || _rating == 0) return;

    setState(() => _isSubmitting = true);

    try {
      await _reviewService.submitReview(
        bookId: widget.book.id,
        rating: _rating,
        comment: _commentController.text.trim(),
        orderId: widget.orderId,
      );

      if (mounted) {
        showMessage('Review submitted successfully!', StatusMessage.success);
        Navigator.pop(context, true); // Return success flag
      }
    } catch (e) {
      if (mounted) {
        showMessage(
          e.toString().replaceAll('Exception: ', ''),
          StatusMessage.error,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }
}
