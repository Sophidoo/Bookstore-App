import 'package:bookstore/common/exceptions/custom_exception.dart';
import 'package:bookstore/features/cart_wishlist/models/review_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ReviewService {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  ReviewService(this._firestore, this._auth);

  Future<void> submitReview({
    required String bookId,
    required double rating,
    required String comment,
    String? orderId,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw BookStoreAppException('User not authenticated');

      // Get user details
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      if (!userDoc.exists) throw BookStoreAppException('User not found');

      final userData = userDoc.data()!;
      final userName =
          userData['firstName'] != null && userData['lastName'] != null
              ? '${userData['firstName']} ${userData['lastName']}'
              : userData['email'];

      final reviewRef = _firestore.collection('reviews').doc();

      final review = Review(
        id: reviewRef.id,
        bookId: bookId,
        userId: user.uid,
        userName: userName,
        userImage: userData['profileImage'],
        rating: rating,
        comment: comment,
        createdAt: DateTime.now(),
        orderId: orderId,
      );

      await reviewRef.set(review.toJson());

      // Update book's average rating
      await _updateBookRating(bookId);
    } catch (e) {
      throw BookStoreAppException('Failed to submit review: ${e.toString()}');
    }
  }

  Future<void> _updateBookRating(String bookId) async {
    final reviews = await getReviewsForBook(bookId);
    if (reviews.isEmpty) return;

    final totalRating = reviews.fold(0.0, (sum, review) => sum + review.rating);
    final averageRating = totalRating / reviews.length;

    await _firestore.collection('books').doc(bookId).update({
      'averageRating': averageRating,
      'reviewCount': reviews.length,
    });
  }

  Future<List<Review>> getReviewsForBook(String bookId) async {
    try {
      final snapshot =
          await _firestore
              .collection('reviews')
              .where('bookId', isEqualTo: bookId)
              .orderBy('createdAt', descending: true)
              .get();

      return snapshot.docs.map((doc) => Review.fromJson(doc.data())).toList();
    } catch (e) {
      throw BookStoreAppException('Failed to get reviews: ${e.toString()}');
    }
  }

  Future<List<Review>> getReviewsByUser(String userId) async {
    try {
      final snapshot =
          await _firestore
              .collection('reviews')
              .where('userId', isEqualTo: userId)
              .orderBy('createdAt', descending: true)
              .get();

      return snapshot.docs.map((doc) => Review.fromJson(doc.data())).toList();
    } catch (e) {
      throw BookStoreAppException(
        'Failed to get user reviews: ${e.toString()}',
      );
    }
  }

  Stream<List<Review>> getReviewsForBookStream(String bookId) {
    return _firestore
        .collection('reviews')
        .where('bookId', isEqualTo: bookId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => Review.fromJson(doc.data()))
              .toList();
        });
  }

  Future<bool> hasUserReviewedBook(String bookId) async {
    try {
      final snapshot =
          await _firestore
              .collection('reviews')
              .where('bookId', isEqualTo: bookId)
              .where('userId', isEqualTo: _auth.currentUser?.uid)
              .limit(1)
              .get();

      return snapshot.docs.isNotEmpty;
    } catch (e) {
      throw BookStoreAppException('Failed to check review: ${e.toString()}');
    }
  }
}
