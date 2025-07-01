import 'dart:ui';

import 'package:bookstore/features/cart_wishlist/models/order_model.dart';

String getStatusText(OrderStatus status) {
  switch (status) {
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

Color getStatusColor(OrderStatus status) {
  switch (status) {
    case OrderStatus.processing:
      return const Color(0xFFF57C00); // Orange
    case OrderStatus.confirmed:
      return const Color(0xFF1976D2); // Blue
    case OrderStatus.shipped:
      return const Color(0xFF7B1FA2); // Purple
    case OrderStatus.outForDelivery:
      return const Color(0xFF0277BD); // Light Blue
    case OrderStatus.delivered:
      return const Color(0xFF388E3C); // Green
    case OrderStatus.cancelled:
      return const Color(0xFFD32F2F); // Red
  }
}
