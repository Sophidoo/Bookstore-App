import 'package:bookstore/common/di/dependencies.dart';
import 'package:bookstore/common/exceptions/custom_exception.dart';
import 'package:bookstore/common/widgets/custom_button.dart';
import 'package:bookstore/common/widgets/custom_text_field.dart';
import 'package:bookstore/common/widgets/status_message.dart';
import 'package:bookstore/features/catalog/models/book_model.dart';
import 'package:bookstore/features/catalog/services/book_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class EditBook extends StatefulWidget {
  const EditBook({super.key});

  @override
  State<EditBook> createState() => _EditBookState();
}

class _EditBookState extends State<EditBook> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _authorController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();

  final _bookService = locator<BookService>();
  final _formKey = GlobalKey<FormState>();
  final _imagePicker = ImagePicker();

  late BookModel book;
  XFile? _selectedImage;

  bool _bookLoadedSuccessfully = false;
  bool _isLoading = true;
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    _fetchBookData();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _fetchBookData() async {
    setState(() {
      _isLoading = true;
    });

    final bookId = Get.parameters['id'];

    try {
      final bookData = await _bookService.fetchBookById(bookId!);
      setState(() {
        book = bookData;
        _bookLoadedSuccessfully = true;
        _populateControllers();
      });
    } on BookStoreAppException {
      setState(() {
        _bookLoadedSuccessfully = false;
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _populateControllers() {
    _titleController.text = book.title;
    _authorController.text = book.author;
    _descriptionController.text = book.description;
    _priceController.text = book.price.toString();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedImage = image;
        });
      }
    } catch (e) {
      showMessage(
        'Failed to pick image. Please try again.',
        StatusMessage.error,
      );
    }
  }

  Future<void> _updateBook() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isUpdating = true;
    });

    try {
      final updatedBook = BookModel(
        id: book.id,
        title: _titleController.text.trim(),
        author: _authorController.text.trim(),
        description: _descriptionController.text.trim(),
        price: int.tryParse(_priceController.text.trim()) ?? 0,
        imageUrl: book.imageUrl,
      );

      await _bookService.updateBook(book.id, updatedBook, _selectedImage);

      showMessage('Book updated successfully!', StatusMessage.success);

      Future.delayed(const Duration(seconds: 1), () {
        Get.toNamed('/book-management');
      });
    } on BookStoreAppException catch (e) {
      // _showSnackBar(e.message);
      showMessage(e.message, StatusMessage.error);
    } catch (e) {
      showMessage(
        "We couln't update book at this time. Please try again",
        StatusMessage.error,
      );
    } finally {
      setState(() {
        _isUpdating = false;
      });
    }
  }

  String? _validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  String? _validatePrice(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Price is required';
    }
    final price = double.tryParse(value.trim());
    if (price == null || price <= 0) {
      return 'Please enter a valid price';
    }
    return null;
  }

  Widget _buildLoadingScreen() {
    return const Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
        ),
      ),
    );
  }

  Widget _buildErrorScreen() {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.black54),
            SizedBox(height: 16),
            Text(
              'Unable to load book',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Please check your connection and try again',
              style: TextStyle(fontSize: 16, color: Colors.black54),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSection() {
    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child:
          _selectedImage != null
              ? ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  _selectedImage!.path,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.image_not_supported,
                        size: 64,
                        color: Colors.grey,
                      ),
                    );
                  },
                ),
              )
              : book.imageUrl != null && book.imageUrl!.isNotEmpty
              ? ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  book.imageUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.image_not_supported,
                        size: 64,
                        color: Colors.grey,
                      ),
                    );
                  },
                ),
              )
              : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add_photo_alternate_outlined,
                    size: 48,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap to add image',
                    style: TextStyle(color: Colors.grey[600], fontSize: 16),
                  ),
                ],
              ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return _buildLoadingScreen();
    }

    if (!_bookLoadedSuccessfully) {
      return _buildErrorScreen();
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Edit '${book.title}'",
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "Update the book details below.",
                        style: TextStyle(fontSize: 16, color: Colors.black54),
                      ),
                      const SizedBox(height: 30),

                      // Image Section
                      GestureDetector(
                        onTap: _pickImage,
                        child: _buildImageSection(),
                      ),
                      const SizedBox(height: 20),

                      // Form Fields
                      CustomTextField(
                        placeholder: 'Title',
                        controller: _titleController,
                        validator: (value) => _validateRequired(value, 'Title'),
                      ),
                      const SizedBox(height: 16),

                      CustomTextField(
                        placeholder: 'Author',
                        controller: _authorController,
                        validator:
                            (value) => _validateRequired(value, 'Author'),
                      ),
                      const SizedBox(height: 16),

                      CustomTextField(
                        placeholder: 'Description',
                        controller: _descriptionController,
                        validator:
                            (value) => _validateRequired(value, 'Description'),
                      ),
                      const SizedBox(height: 16),

                      CustomTextField(
                        placeholder: 'Price',
                        controller: _priceController,
                        validator: _validatePrice,
                      ),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                child: CustomButton(
                  buttonText: 'Update Book',
                  isLoading: _isUpdating,
                  onPressed: _updateBook,
                  isEnabled: !_isUpdating,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
