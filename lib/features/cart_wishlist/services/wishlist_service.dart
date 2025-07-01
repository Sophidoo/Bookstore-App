import 'package:bookstore/features/catalog/models/book_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class WishlistService {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  WishlistService(this._firestore, this._auth);

  Future<void> toggleWishlist(BookModel book) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) throw Exception('User not authenticated');

      final querySnapshot =
          await _firestore
              .collection('users')
              .doc(userId)
              .collection('wishlist')
              .where('id', isEqualTo: book.id)
              .limit(1)
              .get();

      if (querySnapshot.docs.isNotEmpty) {
        // Remove from wishlist
        await _firestore
            .collection('users')
            .doc(userId)
            .collection('wishlist')
            .doc(querySnapshot.docs.first.id)
            .delete();
      } else {
        // Add to wishlist with the book ID as document ID to prevent duplicates
        await _firestore
            .collection('users')
            .doc(userId)
            .collection('wishlist')
            .doc(book.id)
            .set(book.toJson());
      }
    } catch (e) {
      throw Exception('Failed to toggle wishlist: ${e.toString()}');
    }
  }

  Future<bool> isInWishlist(String bookId) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) throw Exception('User not authenticated');

      final snapshot =
          await _firestore
              .collection('users')
              .doc(userId)
              .collection('wishlist')
              .doc(bookId)
              .get();

      return snapshot.exists;
    } catch (e) {
      throw Exception('Failed to check wishlist: ${e.toString()}');
    }
  }

  Future<List<BookModel>> getWishlist() async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) throw Exception('User not authenticated');

      final snapshot =
          await _firestore
              .collection('users')
              .doc(userId)
              .collection('wishlist')
              .get();

      return snapshot.docs
          .map((doc) => BookModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Failed to get wishlist: ${e.toString()}');
    }
  }

  Stream<List<BookModel>> wishlistStream() {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      return Stream.error('User not authenticated');
    }

    return _firestore
        .collection('users')
        .doc(userId)
        .collection('wishlist')
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => BookModel.fromJson(doc.data()))
              .toList();
        });
  }

  Stream<bool> isInWishlistStream(String bookId) {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      return Stream.error('User not authenticated');
    }

    return _firestore
        .collection('users')
        .doc(userId)
        .collection('wishlist')
        .doc(bookId)
        .snapshots()
        .map((snapshot) => snapshot.exists);
  }
}
