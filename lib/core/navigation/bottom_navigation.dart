import 'package:bookstore/common/di/dependencies.dart';
import 'package:bookstore/features/account/screens/profile_screen.dart';
import 'package:bookstore/features/cart_wishlist/screens/cart_screen.dart';
import 'package:bookstore/features/cart_wishlist/screens/order_history.dart';
import 'package:bookstore/features/cart_wishlist/screens/wishlist_screen.dart';
import 'package:bookstore/features/cart_wishlist/services/cart_service.dart';
import 'package:bookstore/features/catalog/screens/book_catalog_screen.dart';
import 'package:bookstore/features/catalog/screens/search_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const BookCatalogScreen(),
    const SearchScreen(),
    const OrderHistoryScreen(),
    const WishlistScreen(),
    const ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final _cartService = locator<CartService>();

    return Scaffold(
      body: _screens[_selectedIndex],
      floatingActionButton:
          _selectedIndex == 0
              ? StreamBuilder<int>(
                stream: _cartService.cartItemCountStream(),
                builder: (context, snapshot) {
                  final count = snapshot.data ?? 0;
                  return FloatingActionButton(
                    onPressed: () {
                      Get.to(() => const CartScreen());
                    },
                    child: Badge(
                      label: Text(count.toString()),
                      child: const Icon(Icons.shopping_cart),
                    ),
                  );
                },
              )
              : null,
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          enableFeedback: false,
          iconSize: 27,
          selectedItemColor: Colors.black,
          unselectedItemColor: Theme.of(
            context,
          ).colorScheme.onSurface.withValues(alpha: 0.6),
          onTap: _onItemTapped,
          items: [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'home'),
            BottomNavigationBarItem(icon: Icon(Icons.search), label: 'search'),
            BottomNavigationBarItem(icon: Icon(Icons.history), label: 'orders'),
            BottomNavigationBarItem(
              icon: Icon(Icons.shopping_bag_outlined),
              label: 'wishlist',
            ),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'profile'),
          ],
        ),
      ),
    );
  }
}
