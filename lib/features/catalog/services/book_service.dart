import 'package:bookstore/common/exceptions/custom_exception.dart';
import 'package:bookstore/features/catalog/models/book_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:image_picker/image_picker.dart';

class BookService {
  final FirebaseFirestore _firestore;

  BookService(this._firestore);

  Future<String> _uploadImage(XFile image, String bookId) async {
    try {
      final cloudinary = CloudinaryPublic('dyktnfgye', 'bookstore');

      final cloudinaryFile = CloudinaryFile.fromFile(
        image.path,
        resourceType: CloudinaryResourceType.Image,
      );
      final response = await cloudinary.uploadFile(cloudinaryFile);
      return response.secureUrl;
    } on CloudinaryException catch (e) {
      throw BookStoreAppException('Upload failed: ${e.message}');
    } catch (e) {
      throw BookStoreAppException(
        'Failed to upload book image. Please try again later.',
      );
    }
  }

  Future<void> createBook(BookModel book, XFile? imageFile) async {
    try {
      final bookData = book.toJson();
      final docRef = _firestore.collection('books').doc();

      if (imageFile != null) {
        final imageUrl = await _uploadImage(imageFile, docRef.id);
        bookData['imageUrl'] = imageUrl;
      }

      await docRef.set(bookData);
    } catch (e) {
      throw BookStoreAppException(
        'We could not add your book. Please try again later.',
      );
    }
  }

  Future<void> updateBook(
    String bookId,
    BookModel book,
    XFile? imageFile,
  ) async {
    try {
      final bookData = book.toJson();

      if (imageFile != null) {
        final imageUrl = await _uploadImage(imageFile, bookId);
        bookData['imageUrl'] = imageUrl;
      }

      await _firestore.collection('books').doc(bookId).update(bookData);
    } catch (e) {
      throw BookStoreAppException(
        'We could not update your book. Please try again later.',
      );
    }
  }

  Future<List<BookModel>> fetchBooks() async {
    try {
      final snapshot = await _firestore.collection('books').get();
      return snapshot.docs
          .map((doc) => BookModel.fromJson({...doc.data(), 'id': doc.id}))
          .toList();
    } catch (e) {
      throw BookStoreAppException(
        'We could not fetch the books. Please try again later.',
      );
    }
  }

  Future<BookModel> fetchBookById(String bookId) async {
    try {
      final doc = await _firestore.collection('books').doc(bookId).get();
      if (doc.exists) {
        return BookModel.fromJson({...doc.data()!, 'id': doc.id});
      } else {
        throw BookStoreAppException('Book not found');
      }
    } catch (e) {
      throw BookStoreAppException(
        'We could not fetch the book. Please try again later.',
      );
    }
  }

  Future<void> deleteBook(String bookId) async {
    try {
      await _firestore.collection('books').doc(bookId).delete();
    } catch (e) {
      throw BookStoreAppException(
        'We could not delete the book. Please try again later.',
      );
    }
  }
}
