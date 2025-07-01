import 'package:bookstore/common/exceptions/custom_exception.dart';
import 'package:bookstore/features/cart_wishlist/models/cart_item_model.dart';
import 'package:bookstore/features/cart_wishlist/models/order_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class OrderService {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  OrderService(this._firestore, this._auth);

  Future<OrderModel> createOrder({
    required List<CartItemModel> items,
    required double totalAmount,
    String? shippingAddress,
    String? paymentMethod,
  }) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) throw Exception('User not authenticated');

      final orderRef = _firestore.collection('orders').doc();
      final now = DateTime.now();

      final initialStatus = OrderStatusUpdate(
        status: OrderStatus.processing,
        timestamp: now,
        message: 'Order received and being processed',
      );

      final order = OrderModel(
        id: orderRef.id,
        userId: userId,
        items: items,
        totalAmount: totalAmount,
        orderDate: now,
        currentStatus: OrderStatus.processing,
        statusHistory: [initialStatus],
        shippingAddress: shippingAddress,
        paymentMethod: paymentMethod,
      );

      await orderRef.set(order.toJson());

      return order;
    } catch (e) {
      throw BookStoreAppException('Failed to create order');
    }
  }

  Future<void> updateOrderStatus({
    required String orderId,
    required OrderStatus newStatus,
    String? message,
    String? trackingNumber,
    String? deliveryLocation,
  }) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) throw Exception('User not authenticated');

      final orderRef = _firestore.collection('orders').doc(orderId);
      final now = DateTime.now();

      final updateData = {
        'currentStatus': newStatus.index,
        'statusHistory': FieldValue.arrayUnion([
          {
            'status': newStatus.index,
            'timestamp': now.toIso8601String(),
            'message': message,
          },
        ]),
      };

      if (trackingNumber != null) {
        updateData['trackingNumber'] = trackingNumber;
      }

      if (deliveryLocation != null) {
        updateData['deliveryLocation'] = deliveryLocation;
      }

      await orderRef.update(updateData);
    } catch (e) {
      throw BookStoreAppException('Failed to update order status');
    }
  }

  Future<List<OrderModel>> getAllOrders() async {
    try {
      final snapshot =
          await _firestore
              .collection('orders')
              .orderBy('orderDate', descending: true)
              .get();

      return snapshot.docs
          .map((doc) => OrderModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      throw BookStoreAppException('Failed to get all orders');
    }
  }

  Stream<List<OrderModel>> getAllOrdersStream() {
    return _firestore
        .collection('orders')
        .orderBy('orderDate', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => OrderModel.fromJson(doc.data()))
              .toList();
        });
  }

  Future<List<OrderModel>> getOrdersByStatus(OrderStatus status) async {
    try {
      final snapshot =
          await _firestore
              .collection('orders')
              .where('currentStatus', isEqualTo: status.index)
              .orderBy('orderDate', descending: true)
              .get();

      return snapshot.docs
          .map((doc) => OrderModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      throw BookStoreAppException('Failed to get orders by status');
    }
  }

  Future<List<OrderModel>> getUserOrders() async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) throw BookStoreAppException('User not authenticated');

      final snapshot =
          await _firestore
              .collection('orders')
              .where('userId', isEqualTo: userId)
              .get();

      // Sort in memory to avoid composite index requirement
      final orders = snapshot.docs
          .map((doc) => OrderModel.fromJson(doc.data()))
          .toList();
      
      orders.sort((a, b) => b.orderDate.compareTo(a.orderDate));

      return orders;
    } catch (e) {
      throw BookStoreAppException('Failed to get user orders:');
    }
  }

  Future<Map<String, int>> getOrderStatistics() async {
    try {
      final snapshot = await _firestore.collection('orders').get();

      final stats = <String, int>{
        'total': 0,
        'processing': 0,
        'confirmed': 0,
        'shipped': 0,
        'outForDelivery': 0,
        'delivered': 0,
        'cancelled': 0,
      };

      for (final doc in snapshot.docs) {
        final order = OrderModel.fromJson(doc.data());
        stats['total'] = stats['total']! + 1;
        stats[order.currentStatus.name.toLowerCase().replaceAll(' ', '')] =
            (stats[order.currentStatus.name.toLowerCase().replaceAll(
                  ' ',
                  '',
                )] ??
                0) +
            1;
      }

      return stats;
    } catch (e) {
      throw Exception('Failed to get order statistics: ${e.toString()}');
    }
  }

  /// Search orders by customer email or order ID
  Future<List<OrderModel>> searchOrders(String query) async {
    try {
      // Search by order ID
      if (query.length > 10) {
        final orderDoc = await _firestore.collection('orders').doc(query).get();
        if (orderDoc.exists) {
          return [OrderModel.fromJson(orderDoc.data()!)];
        }
      }

      final allOrders = await getAllOrders();
      return allOrders
          .where(
            (order) =>
                order.id.toLowerCase().contains(query.toLowerCase()) ||
                order.userId.toLowerCase().contains(query.toLowerCase()),
          )
          .toList();
    } catch (e) {
      throw Exception('Failed to search orders: ${e.toString()}');
    }
  }

  Stream<List<OrderModel>> getUserOrdersStream() {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      return Stream.error('User not authenticated');
    }

    return _firestore
        .collection('orders')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
          final orders = snapshot.docs
              .map((doc) => OrderModel.fromJson(doc.data()))
              .toList();
          
          // Sort in memory to avoid composite index requirement
          orders.sort((a, b) => b.orderDate.compareTo(a.orderDate));
          
          return orders;
        });
  }

  Future<OrderModel> getOrderById(String orderId) async {
    try {
      final snapshot = await _firestore.collection('orders').doc(orderId).get();
      if (!snapshot.exists) throw Exception('Order not found');
      return OrderModel.fromJson(snapshot.data()!);
    } catch (e) {
      throw Exception('Failed to get order: ${e.toString()}');
    }
  }

  Stream<OrderModel> getOrderStream(String orderId) {
    return _firestore.collection('orders').doc(orderId).snapshots().map((
      snapshot,
    ) {
      if (!snapshot.exists) throw Exception('Order not found');
      return OrderModel.fromJson(snapshot.data()!);
    });
  }
}
