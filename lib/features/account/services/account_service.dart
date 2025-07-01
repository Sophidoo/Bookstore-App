import 'package:bookstore/common/exceptions/custom_exception.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AccountService {
  final FirebaseFirestore _db;
  final FirebaseAuth _auth;

  AccountService(this._db, this._auth);

  Future<void> updateUserProfile({
    required String firstName,
    required String lastName,
    required String phoneNumber,
  }) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) throw BookStoreAppException('User not authenticated');

      await _db.collection('users').doc(userId).update({
        'firstName': firstName,
        'lastName': lastName,
        'phoneNumber': phoneNumber,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } on FirebaseException catch (e) {
      throw BookStoreAppException(e.message ?? 'Failed to update profile');
    } catch (e) {
      throw BookStoreAppException('Failed to update profile');
    }
  }

  Future<Map<String, dynamic>> getUserProfile() async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) throw BookStoreAppException('User not authenticated');

      final doc = await _db.collection('users').doc(userId).get();
      if (!doc.exists) throw BookStoreAppException('User not found');

      return doc.data() ?? {};
    } on FirebaseException catch (e) {
      throw BookStoreAppException(e.message ?? 'Failed to fetch profile');
    } catch (e) {
      throw BookStoreAppException('Failed to fetch profile');
    }
  }

  Future<void> updateShippingAddress({
    required String country,
    required String streetAddress,
    required String apartment,
    required String state,
    required String city,
  }) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) throw BookStoreAppException('User not authenticated');

      await _db
          .collection('users')
          .doc(userId)
          .collection('shippingAddress')
          .doc('default')
          .set({
            'country': country,
            'streetAddress': streetAddress,
            'apartment': apartment,
            'state': state,
            'city': city,
            'updatedAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
    } on FirebaseException catch (e) {
      throw BookStoreAppException(e.message ?? 'Failed to update address');
    } catch (e) {
      throw BookStoreAppException('Failed to update address');
    }
  }

  Future<Map<String, dynamic>?> getShippingAddress() async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) throw BookStoreAppException('User not authenticated');

      final doc =
          await _db
              .collection('users')
              .doc(userId)
              .collection('shippingAddress')
              .doc('default')
              .get();
      if (!doc.exists) return null;

      return doc.data();
    } on FirebaseException catch (e) {
      throw BookStoreAppException(e.message ?? 'Failed to fetch address');
    } catch (e) {
      throw BookStoreAppException('Failed to fetch address');
    }
  }
}
