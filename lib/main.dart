import 'package:bookstore/common/di/dependencies.dart';
import 'package:bookstore/common/theme/theme_constants.dart';
import 'package:bookstore/core/navigation/bottom_navigation.dart';
import 'package:bookstore/features/account/screens/personal_information_screen.dart';
import 'package:bookstore/features/account/screens/profile_screen.dart';
import 'package:bookstore/features/account/screens/shipping_address_screen.dart';
import 'package:bookstore/features/admin/screens/add_book.dart';
import 'package:bookstore/features/admin/screens/admin_order_management_screen.dart';
import 'package:bookstore/features/admin/screens/edit_book.dart';
import 'package:bookstore/features/admin/screens/user_management.dart';
import 'package:bookstore/features/catalog/screens/book_catalog_screen.dart';
import 'package:bookstore/features/catalog/screens/search_screen.dart';
import 'package:bookstore/features/splash/splash_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:toastification/toastification.dart';

import 'features/admin/screens/book_management.dart';
import 'features/admin/screens/dashboard_screen.dart';
import 'features/authentication/screens/forgot_password_screen.dart';
import 'features/authentication/screens/login_screen.dart';
import 'features/authentication/screens/reset_password_email_sent.dart';
import 'features/authentication/screens/signup_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  setUpDependencies();
  runApp(ToastificationWrapper(child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemStatusBarContrastEnforced: false,
        systemNavigationBarContrastEnforced: false,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );

    return GetMaterialApp(
      title: 'BookStore App',
      debugShowCheckedModeBanner: false,
      transitionDuration: const Duration(milliseconds: 200),
      defaultTransition: Transition.rightToLeft,
      theme: lightTheme,
      initialRoute: '/splash',
      getPages: [
        GetPage(
          name: '/splash',
          page: () => const SplashPage(),
          transition: Transition.fadeIn,
        ),
        GetPage(name: '/signup', page: () => const SignupScreen()),
        GetPage(name: '/login', page: () => const LoginScreen()),
        GetPage(
          name: '/forgot-password',
          page: () => const ForgotPasswordScreen(),
        ),
        GetPage(
          name: '/reset-password-email-sent',
          page: () => const ResetPasswordEmailSent(),
        ),

        GetPage(name: '/main', page: () => const MainScreen()),
        GetPage(name: '/book-catalog', page: () => const BookCatalogScreen()),
        GetPage(name: '/book-search', page: () => const SearchScreen()),
        GetPage(name: '/profile', page: () => const ProfileScreen()),
        GetPage(
          name: '/personal-information',
          page: () => const PersonalInformation(),
        ),
        GetPage(
          name: '/shipping-address',
          page: () => const ShippingAddressScreen(),
        ),

        // admin
        GetPage(name: '/admin', page: () => const DashboardScreen()),
        GetPage(name: '/book-management', page: () => const BookManagement()),
        GetPage(name: '/add-book', page: () => const AddBookScreen()),
        GetPage(name: '/edit-book/:id', page: () => const EditBook()),
        GetPage(name: '/user-management', page: () => const UserManagement()),
        GetPage(
          name: '/admin-order-management',
          page: () => const AdminOrderManagementScreen(),
        ),
      ],
    );
  }
}
