import 'package:bookstore/common/exceptions/custom_exception.dart';
import 'package:bookstore/features/admin/models/quickStat_model.dart';
import 'package:bookstore/features/authentication/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminService {
  final FirebaseFirestore _firestore;

  AdminService(this._firestore);

  Future<QuickStat> fetchQuickOverview() async {
    try {
      final results = await Future.wait([
        _getCollectionCount('books'),
        _getCollectionCount('users'),
        _getCollectionCount('orders'),
        _getRevenue(),
      ]);

      final booksCount = results[0] as int;
      final usersCount = results[1] as int;
      final ordersCount = results[2] as int;
      final revenue = results[3] as double;

      return QuickStat(booksCount, usersCount, ordersCount, revenue);
    } catch (e) {
      throw BookStoreAppException(
        'We could not fetch the quick overview. Please try again later.',
      );
    }
  }

  Future<int> _getCollectionCount(String collectionName) async {
    try {
      final snapshot = await _firestore.collection(collectionName).get();
      return snapshot.docs.length;
    } catch (e) {
      return 0;
    }
  }

  Future<List<UserModel>> fetchUsers() async {
    try {
      final snapshot = await _firestore.collection('users').get();
      return snapshot.docs
          .map((doc) => UserModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      throw BookStoreAppException(
        'We could not fetch users. Please try again later.',
      );
    }
  }

  Future<double> _getRevenue() async {
    try {
      final snapshot =
          await _firestore
              .collection('orders')
              .where('currentStatus', isEqualTo: 5)
              .get();

      double totalRevenue = 0.0;
      for (final doc in snapshot.docs) {
        final data = doc.data();
        if (data.containsKey('totalPrice')) {
          totalRevenue += data['totalPrice'] as double;
        }
      }
      return totalRevenue;
    } catch (e) {
      return 0.0;
    }
  }
}
