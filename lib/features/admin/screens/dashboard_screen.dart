import 'package:bookstore/common/exceptions/custom_exception.dart';
import 'package:bookstore/common/widgets/status_message.dart';
import 'package:bookstore/features/admin/services/admin_service.dart';
import 'package:bookstore/features/authentication/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../common/di/dependencies.dart';
import '../widgets/management_card.dart';
import '../widgets/skeleton_stat_card.dart';
import '../widgets/stat_card.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _authService = locator<AuthService>();
  final _adminService = locator<AdminService>();

  bool _isLoading = true;

  // Quick overview data
  int booksCount = 0;
  int usersCount = 0;
  int ordersCount = 0;
  double revenue = 0.0;

  Future<void> _handleLogout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Confirm Logout',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
          ),
          content: const Text(
            'Are you sure you want to log out of your admin account?',
            style: TextStyle(fontSize: 14),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
              ),
              child: const Text(
                'Logout',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        );
      },
    );

    if (shouldLogout == true) {
      try {
        await _authService.signOut();
        Get.offAllNamed('/login');
      } catch (e) {
        showMessage('Failed to logout. Please try again.', StatusMessage.error);
      }
    }
  }

  Future<void> _fetchQuickOverview() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final quickStats = await _adminService.fetchQuickOverview();

      setState(() {
        booksCount = quickStats.books;
        usersCount = quickStats.users;
        ordersCount = quickStats.orders;
        revenue = quickStats.revenue;
        _isLoading = false;
      });
    } on BookStoreAppException catch (e) {
      setState(() {
        _isLoading = false;
      });
      showMessage(e.message, StatusMessage.error);
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchQuickOverview();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Admin Dashboard',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              'Manage your store efficiently here',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: IconButton(
              onPressed: _handleLogout,
              icon: const Icon(Icons.logout, color: Colors.black),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 50),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Welcome Section
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome back to your dashboard',
                        style: Theme.of(
                          context,
                        ).textTheme.headlineSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Here's what's been happening in your store",
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Quick Stats
                const Text(
                  'Quick Overview',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),

                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child:
                          _isLoading
                              ? SkeletonStatCard()
                              : StatCard(
                                icon: Icons.book,
                                title: 'Total Books',
                                value: booksCount.toString(),
                                color: Colors.blue,
                              ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child:
                          _isLoading
                              ? SkeletonStatCard()
                              : StatCard(
                                icon: Icons.people,
                                title: 'Users',
                                value: usersCount.toString(),
                                color: Colors.green,
                              ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child:
                          _isLoading
                              ? SkeletonStatCard()
                              : StatCard(
                                icon: Icons.shopping_cart,
                                title: 'Orders',
                                value: ordersCount.toString(),
                                color: Colors.orange,
                              ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child:
                          _isLoading
                              ? SkeletonStatCard()
                              : StatCard(
                                icon: Icons.money,
                                title: 'Revenue',
                                value: '₦${revenue.toStringAsFixed(1)}',
                                color: Colors.purple,
                              ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                const Text(
                  'Management',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 16),
                Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: 120,
                      child: ManagementCard(
                        icon: Icons.library_books,
                        title: 'Books',
                        subtitle:
                            'Manage your book inventory, add new books, and update existing ones',
                        onTap: () {
                          Get.toNamed('/book-management');
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 120,
                      child: ManagementCard(
                        icon: Icons.person_outline,
                        title: 'Users',
                        subtitle: 'View users enrolled in your book store',
                        onTap: () {
                          Get.toNamed('/user-management');
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 120,
                      child: ManagementCard(
                        icon: Icons.receipt_long,
                        title: 'Orders',
                        subtitle:
                            'Track and manage customer orders, update order status',
                        onTap: () {
                          Get.toNamed('/admin-order-management');
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
