import 'package:bookstore/common/widgets/custom_button.dart';
import 'package:bookstore/common/widgets/status_message.dart';
import 'package:flutter/material.dart';
import 'package:bookstore/features/cart_wishlist/models/order_model.dart';
import 'package:bookstore/features/cart_wishlist/services/order_service.dart';
import 'package:bookstore/common/di/dependencies.dart';

class AdminUpdateOrderScreen extends StatefulWidget {
  final OrderModel order;

  const AdminUpdateOrderScreen({super.key, required this.order});

  @override
  State<AdminUpdateOrderScreen> createState() => _AdminUpdateOrderScreenState();
}

class _AdminUpdateOrderScreenState extends State<AdminUpdateOrderScreen> {
  final OrderService _orderService = locator<OrderService>();
  final TextEditingController _messageController = TextEditingController();
  final TextEditingController _trackingController = TextEditingController();
  final TextEditingController _deliveryLocationController =
      TextEditingController();

  OrderStatus? _selectedStatus;
  OrderStatus? _currentStatus;
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    _currentStatus = widget.order.currentStatus;
    _selectedStatus = widget.order.currentStatus;
    _trackingController.text = widget.order.trackingNumber ?? '';
    _deliveryLocationController.text = widget.order.deliveryLocation ?? '';
  }

  @override
  void dispose() {
    _messageController.dispose();
    _trackingController.dispose();
    _deliveryLocationController.dispose();
    super.dispose();
  }

  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.processing:
        return Colors.orange;
      case OrderStatus.confirmed:
        return Colors.blue;
      case OrderStatus.shipped:
        return Colors.purple;
      case OrderStatus.outForDelivery:
        return Colors.indigo;
      case OrderStatus.delivered:
        return Colors.green;
      case OrderStatus.cancelled:
        return Colors.red;
    }
  }

  IconData _getStatusIcon(OrderStatus status) {
    switch (status) {
      case OrderStatus.processing:
        return Icons.hourglass_empty;
      case OrderStatus.confirmed:
        return Icons.check_circle_outline;
      case OrderStatus.shipped:
        return Icons.local_shipping;
      case OrderStatus.outForDelivery:
        return Icons.delivery_dining;
      case OrderStatus.delivered:
        return Icons.done_all;
      case OrderStatus.cancelled:
        return Icons.cancel;
    }
  }

  Future<void> _updateOrder() async {
    if (_selectedStatus == null) return;

    setState(() {
      _isUpdating = true;
    });

    try {
      await _orderService.updateOrderStatus(
        orderId: widget.order.id,
        newStatus: _selectedStatus!,
        message:
            _messageController.text.trim().isNotEmpty
                ? _messageController.text.trim()
                : null,
        trackingNumber:
            _trackingController.text.trim().isNotEmpty
                ? _trackingController.text.trim()
                : null,
        deliveryLocation:
            _deliveryLocationController.text.trim().isNotEmpty
                ? _deliveryLocationController.text.trim()
                : null,
      );

      setState(() {
        _currentStatus = _selectedStatus;
      });

      showMessage('Order updated successfully', StatusMessage.success);
    } catch (e) {
      if (mounted) {
        showMessage(
          'Failed to update order: ${e.toString()}',
          StatusMessage.error,
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUpdating = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'Update Order #${widget.order.id.substring(0, 8).toUpperCase()}',
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: Colors.grey[300], height: 1.0),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Current Status Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Current Status',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: _getStatusColor(
                          _currentStatus!,
                        ).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: _getStatusColor(
                            _currentStatus!,
                          ).withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _getStatusIcon(_currentStatus!),
                            color: _getStatusColor(_currentStatus!),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            _currentStatus!.name,
                            style: TextStyle(
                              color: _getStatusColor(_currentStatus!),
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Update Status Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Update Status',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Status Selection
                    const Text(
                      'New Status',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children:
                          OrderStatus.values.map((status) {
                            final isSelected = _selectedStatus == status;
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedStatus = status;
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                      isSelected
                                          ? _getStatusColor(
                                            status,
                                          ).withValues(alpha: 0.1)
                                          : Colors.grey[100],
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color:
                                        isSelected
                                            ? _getStatusColor(status)
                                            : Colors.grey[300]!,
                                    width: isSelected ? 2 : 1,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      _getStatusIcon(status),
                                      size: 16,
                                      color:
                                          isSelected
                                              ? _getStatusColor(status)
                                              : Colors.grey[600],
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      status.name,
                                      style: TextStyle(
                                        color:
                                            isSelected
                                                ? _getStatusColor(status)
                                                : Colors.grey[600],
                                        fontWeight:
                                            isSelected
                                                ? FontWeight.w600
                                                : FontWeight.normal,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                    ),
                    const SizedBox(height: 20),

                    // Message Field
                    const Text(
                      'Update Message (Optional)',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _messageController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: 'Enter a message about this status update...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Colors.black),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Tracking Number Field
                    const Text(
                      'Tracking Number (Optional)',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _trackingController,
                      decoration: InputDecoration(
                        hintText: 'Enter tracking number...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Colors.black),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Delivery Location Field
                    const Text(
                      'Delivery Location (Optional)',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _deliveryLocationController,
                      decoration: InputDecoration(
                        hintText: 'Enter delivery location...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Colors.black),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              CustomButton(
                onPressed: _isUpdating ? () {} : _updateOrder,
                buttonText: 'Update Order Status',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
