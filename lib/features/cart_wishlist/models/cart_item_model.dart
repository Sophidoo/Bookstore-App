import 'package:bookstore/features/catalog/models/book_model.dart';

class CartItemModel {
  final String id;
  final BookModel book;
  int quantity;

  CartItemModel({
    required this.id,
    required this.book,
    this.quantity = 1,
  });

  int get totalPrice => book.price * quantity;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'book': book.toJson(),
      'quantity': quantity,
    };
  }

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      id: json['id'],
      book: BookModel.fromJson(json['book']),
      quantity: json['quantity'],
    );
  }
}