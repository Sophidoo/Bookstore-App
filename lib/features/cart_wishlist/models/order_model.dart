import 'package:bookstore/features/cart_wishlist/models/cart_item_model.dart';

enum OrderStatus {
  processing,
  confirmed,
  shipped,
  outForDelivery,
  delivered,
  cancelled,
}

extension OrderStatusExtension on OrderStatus {
  String get name {
    switch (this) {
      case OrderStatus.processing:
        return 'Processing';
      case OrderStatus.confirmed:
        return 'Confirmed';
      case OrderStatus.shipped:
        return 'Shipped';
      case OrderStatus.outForDelivery:
        return 'Out for Delivery';
      case OrderStatus.delivered:
        return 'Delivered';
      case OrderStatus.cancelled:
        return 'Cancelled';
    }
  }

  int get progress {
    switch (this) {
      case OrderStatus.processing:
        return 0;
      case OrderStatus.confirmed:
        return 1;
      case OrderStatus.shipped:
        return 2;
      case OrderStatus.outForDelivery:
        return 3;
      case OrderStatus.delivered:
        return 4;
      case OrderStatus.cancelled:
        return 0;
    }
  }
}

class OrderStatusUpdate {
  final OrderStatus status;
  final DateTime timestamp;
  final String? message;

  OrderStatusUpdate({
    required this.status,
    required this.timestamp,
    this.message,
  });

  Map<String, dynamic> toJson() {
    return {
      'status': status.index,
      'timestamp': timestamp.toIso8601String(),
      'message': message,
    };
  }

  factory OrderStatusUpdate.fromJson(Map<String, dynamic> json) {
    return OrderStatusUpdate(
      status: OrderStatus.values[json['status']],
      timestamp: DateTime.parse(json['timestamp']),
      message: json['message'],
    );
  }
}

class OrderModel {
  final String id;
  final String userId;
  final List<CartItemModel> items;
  final double totalAmount;
  final DateTime orderDate;
  final OrderStatus currentStatus;
  final List<OrderStatusUpdate> statusHistory;
  final String? shippingAddress;
  final String? paymentMethod;
  final String? trackingNumber;
  final String? deliveryLocation;

  OrderModel({
    required this.id,
    required this.userId,
    required this.items,
    required this.totalAmount,
    required this.orderDate,
    required this.currentStatus,
    required this.statusHistory,
    this.shippingAddress,
    this.paymentMethod,
    this.trackingNumber,
    this.deliveryLocation,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'items': items.map((item) => item.toJson()).toList(),
      'totalAmount': totalAmount,
      'orderDate': orderDate.toIso8601String(),
      'currentStatus': currentStatus.index,
      'statusHistory': statusHistory.map((update) => update.toJson()).toList(),
      'shippingAddress': shippingAddress,
      'paymentMethod': paymentMethod,
      'trackingNumber': trackingNumber,
      'deliveryLocation': deliveryLocation,
    };
  }

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'],
      userId: json['userId'],
      items: (json['items'] as List)
          .map((item) => CartItemModel.fromJson(item))
          .toList(),
      totalAmount: json['totalAmount'].toDouble(),
      orderDate: DateTime.parse(json['orderDate']),
      currentStatus: OrderStatus.values[json['currentStatus']],
      statusHistory: (json['statusHistory'] as List)
          .map((update) => OrderStatusUpdate.fromJson(update))
          .toList(),
      shippingAddress: json['shippingAddress'],
      paymentMethod: json['paymentMethod'],
      trackingNumber: json['trackingNumber'],
      deliveryLocation: json['deliveryLocation'],
    );
  }
}