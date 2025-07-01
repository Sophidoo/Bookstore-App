class BookModel {
  final String id;
  final String title;
  final String author;
  final String description;
  final int price;
  final String? imageUrl;
  final double? averageRating;
  final int? reviewCount;

  BookModel({
    required this.id,
    required this.title,
    required this.author,
    required this.description,
    required this.price,
    this.imageUrl,
    this.averageRating,
    this.reviewCount,
  });

  factory BookModel.fromJson(Map<String, dynamic> json) {
    return BookModel(
      id: json['id'],
      title: json['title'],
      author: json['author'],
      description: json['description'],
      price: json['price'],
      imageUrl: json['imageUrl'],
      averageRating: json['averageRating']?.toDouble(),
      reviewCount: json['reviewCount'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'author': author,
      'description': description,
      'price': price,
      'imageUrl': imageUrl,
      'averageRating': averageRating,
      'reviewCount': reviewCount,
    };
  }
}
