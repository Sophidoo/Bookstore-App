import 'dart:io';

import 'package:bookstore/common/exceptions/custom_exception.dart';
import 'package:bookstore/common/widgets/custom_button.dart';
import 'package:bookstore/common/widgets/custom_text_field.dart';
import 'package:bookstore/common/widgets/status_message.dart';
import 'package:bookstore/features/catalog/models/book_model.dart';
import 'package:bookstore/features/catalog/services/book_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../../common/di/dependencies.dart';

class AddBookScreen extends StatefulWidget {
  const AddBookScreen({super.key});

  @override
  State<AddBookScreen> createState() => _AddBookScreenState();
}

class _AddBookScreenState extends State<AddBookScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _authorController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final _bookService = locator<BookService>();
  final ImagePicker _picker = ImagePicker();
  XFile? _selectedImage;
  bool _loading = false;

  Future<void> _pickImage() async {
    try {
      final image = await _picker.pickImage(source: ImageSource.gallery);
      setState(() {
        _selectedImage = image;
      });
    } catch (e) {
      showMessage('Failed to pick image', StatusMessage.error);
    }
  }

  Future<void> _addBook() async {
    if (_titleController.text.isEmpty ||
        _authorController.text.isEmpty ||
        _descriptionController.text.isEmpty ||
        _priceController.text.isEmpty) {
      showMessage('Please fill in all fields', StatusMessage.error);
      return;
    }

    final int? price = int.tryParse(_priceController.text);
    if (price == null) {
      showMessage('Please enter a valid price', StatusMessage.error);
      return;
    }

    setState(() {
      _loading = true;
    });

    try {
      final newBook = BookModel(
        id: '',
        title: _titleController.text,
        author: _authorController.text,
        description: _descriptionController.text,
        price: price,
      );

      await _bookService.createBook(newBook, _selectedImage);
      showMessage('Book added successfully', StatusMessage.success);
      Get.back();
      return;
    } on BookStoreAppException catch (e) {
      showMessage(e.message, StatusMessage.error);
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(
          'Add a New Book',
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.toNamed('/book-management'),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image picker section
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.black12,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.black26),
                ),
                child:
                    _selectedImage == null
                        ? const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add_a_photo,
                              color: Colors.black54,
                              size: 40,
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Tap to select book cover',
                              style: TextStyle(
                                color: Colors.black54,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        )
                        : ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(
                            File(_selectedImage!.path),
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: 200,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(
                                Icons.book,
                                color: Colors.black54,
                                size: 40,
                              );
                            },
                          ),
                        ),
              ),
            ),
            const SizedBox(height: 24),
            // Title field
            CustomTextField(
              placeholder: 'Book Title',
              controller: _titleController,
              prefixIcon: const Icon(Icons.book, color: Colors.black54),
            ),
            const SizedBox(height: 16),
            CustomTextField(
              placeholder: 'Author',
              controller: _authorController,
              prefixIcon: const Icon(Icons.person, color: Colors.black54),
            ),
            const SizedBox(height: 16),
            // Description field
            CustomTextField(
              placeholder: 'Description',
              controller: _descriptionController,
              prefixIcon: const Icon(Icons.description, color: Colors.black54),
            ),
            const SizedBox(height: 16),
            // Price field
            CustomTextField(
              placeholder: 'Price',
              controller: _priceController,
              prefixIcon: const Icon(Icons.attach_money, color: Colors.black54),
            ),
            const SizedBox(height: 24),
            CustomButton(
              onPressed: _addBook,
              buttonText: 'Add Book',
              isLoading: _loading,
              isEnabled: !_loading,
            ),
          ],
        ),
      ),
    );
  }
}
