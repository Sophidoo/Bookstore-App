import 'package:bookstore/features/cart_wishlist/models/cart_item_model.dart';
import 'package:bookstore/features/catalog/models/book_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CartService {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  CartService(this._firestore, this._auth);

  Future<void> addToCart(BookModel book, {int quantity = 1}) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) throw Exception('User not authenticated');

      // Check if item already exists in cart
      final existingItem =
          await _firestore
              .collection('users')
              .doc(userId)
              .collection('cart')
              .where('book.id', isEqualTo: book.id)
              .get();

      if (existingItem.docs.isNotEmpty) {
        // Update quantity if item exists
        await _firestore
            .collection('users')
            .doc(userId)
            .collection('cart')
            .doc(existingItem.docs.first.id)
            .update({'quantity': FieldValue.increment(quantity)});
      } else {
        // Add new item to cart
        await _firestore
            .collection('users')
            .doc(userId)
            .collection('cart')
            .add({
              'book': book.toJson(),
              'quantity': quantity,
              'createdAt': FieldValue.serverTimestamp(),
            });
      }
    } catch (e) {
      throw Exception('Failed to add to cart: ${e.toString()}');
    }
  }

  Future<void> removeFromCart(String cartItemId) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) throw Exception('User not authenticated');

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('cart')
          .doc(cartItemId)
          .delete();
    } catch (e) {
      throw Exception('Failed to remove from cart: ${e.toString()}');
    }
  }

  Future<void> updateQuantity(String cartItemId, int newQuantity) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) throw Exception('User not authenticated');

      if (newQuantity <= 0) {
        await removeFromCart(cartItemId);
        return;
      }

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('cart')
          .doc(cartItemId)
          .update({'quantity': newQuantity});
    } catch (e) {
      throw Exception('Failed to update quantity: ${e.toString()}');
    }
  }

  Future<List<CartItemModel>> getCartItems() async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) throw Exception('User not authenticated');

      final snapshot =
          await _firestore
              .collection('users')
              .doc(userId)
              .collection('cart')
              .orderBy('createdAt', descending: false)
              .get();

      return snapshot.docs.map((doc) {
        return CartItemModel(
          id: doc.id,
          book: BookModel.fromJson(doc.data()['book']),
          quantity: doc.data()['quantity'],
        );
      }).toList();
    } catch (e) {
      throw Exception('Failed to get cart items: ${e.toString()}');
    }
  }

  Future<double> getCartTotal() async {
    final items = await getCartItems();
    double total = 0;
    for (final item in items) {
      total += item.totalPrice;
    }
    return total;
  }

  Future<int> getCartItemCount() async {
    final items = await getCartItems();
    int count = 0;
    for (final item in items) {
      count += item.quantity;
    }
    return count;
  }

  Future<void> clearCart() async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) throw Exception('User not authenticated');

      final batch = _firestore.batch();
      final snapshot =
          await _firestore
              .collection('users')
              .doc(userId)
              .collection('cart')
              .get();

      for (var doc in snapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
    } catch (e) {
      throw Exception('Failed to clear cart: ${e.toString()}');
    }
  }

  Stream<List<CartItemModel>> cartItemsStream() {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      return Stream.error('User not authenticated');
    }

    return _firestore
        .collection('users')
        .doc(userId)
        .collection('cart')
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return CartItemModel(
              id: doc.id,
              book: BookModel.fromJson(doc.data()['book']),
              quantity: doc.data()['quantity'],
            );
          }).toList();
        });
  }

  Stream<int> cartItemCountStream() {
    return cartItemsStream().map((items) {
      return items.fold(0, (count, item) => count + item.quantity);
    });
  }
}
