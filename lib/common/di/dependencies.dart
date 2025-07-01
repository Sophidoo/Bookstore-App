import 'package:bookstore/features/account/services/account_service.dart';
import 'package:bookstore/features/admin/services/admin_service.dart';
import 'package:bookstore/features/authentication/services/auth_service.dart';
import 'package:bookstore/features/cart_wishlist/services/cart_service.dart';
import 'package:bookstore/features/cart_wishlist/services/order_service.dart';
import 'package:bookstore/features/cart_wishlist/services/review_service.dart';
import 'package:bookstore/features/cart_wishlist/services/wishlist_service.dart';
import 'package:bookstore/features/catalog/services/book_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get_it/get_it.dart';

final locator = GetIt.instance;

void setUpDependencies() {
  locator.registerSingleton<FirebaseAuth>(FirebaseAuth.instance);
  locator.registerSingleton<FirebaseApp>(Firebase.app());
  locator.registerSingleton<FirebaseFirestore>(FirebaseFirestore.instance);
  locator.registerSingleton<FirebaseStorage>(FirebaseStorage.instance);

  // Register dependencies
  locator.registerSingleton<AuthService>(
    AuthService(locator<FirebaseAuth>(), locator<FirebaseFirestore>()),
  );
  locator.registerSingleton<AdminService>(
    AdminService(locator<FirebaseFirestore>()),
  );
  locator.registerSingleton<BookService>(
    BookService(locator<FirebaseFirestore>()),
  );
  locator.registerSingleton<AccountService>(
    AccountService(locator<FirebaseFirestore>(), locator<FirebaseAuth>()),
  );
  locator.registerSingleton<CartService>(
    CartService(FirebaseFirestore.instance, FirebaseAuth.instance),
  );
  locator.registerSingleton<WishlistService>(
    WishlistService(FirebaseFirestore.instance, FirebaseAuth.instance),
  );
  locator.registerSingleton<OrderService>(
    OrderService(FirebaseFirestore.instance, FirebaseAuth.instance),
  );
  locator.registerSingleton<ReviewService>(
    ReviewService(locator<FirebaseFirestore>(), locator<FirebaseAuth>()),
  );
}
