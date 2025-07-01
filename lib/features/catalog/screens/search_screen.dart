import 'package:bookstore/common/di/dependencies.dart';
import 'package:bookstore/common/exceptions/custom_exception.dart';
import 'package:bookstore/common/widgets/status_message.dart';
import 'package:bookstore/features/catalog/models/book_model.dart';
import 'package:bookstore/features/catalog/screens/book_details_screen.dart';
import 'package:bookstore/features/catalog/services/book_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final BookService _bookService = locator<BookService>();
  final TextEditingController _searchController = TextEditingController();
  final List<String> _sortOptions = [
    'Relevance',
    'Price: Low to High',
    'Price: High to Low',
    'Title: A-Z',
    'Title: Z-A',
  ];
  String _selectedSort = 'Relevance';
  List<BookModel> _books = [];
  List<BookModel> _searchResults = [];
  bool _isLoading = false;
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _loadBooks();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadBooks() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final books = await _bookService.fetchBooks();
      setState(() {
        _books = books;
        _searchResults = books;
      });
    } on BookStoreAppException catch (e) {
      showMessage(e.message, StatusMessage.error);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _onSearchChanged() {
    final query = _searchController.text.trim();
    if (query.isEmpty) {
      setState(() {
        _isSearching = false;
        _searchResults = _books;
        _sortBooks();
      });
      return;
    }

    setState(() {
      _isSearching = true;
      _searchResults =
          _books.where((book) {
            return book.title.toLowerCase().contains(query.toLowerCase()) ||
                book.author.toLowerCase().contains(query.toLowerCase()) ||
                book.description.toLowerCase().contains(query.toLowerCase());
          }).toList();
      _sortBooks();
    });
  }

  void _sortBooks() {
    setState(() {
      switch (_selectedSort) {
        case 'Price: Low to High':
          _searchResults.sort((a, b) => a.price.compareTo(b.price));
          break;
        case 'Price: High to Low':
          _searchResults.sort((a, b) => b.price.compareTo(a.price));
          break;
        case 'Title: A-Z':
          _searchResults.sort((a, b) => a.title.compareTo(b.title));
          break;
        case 'Title: Z-A':
          _searchResults.sort((a, b) => b.title.compareTo(a.title));
          break;
        default: // Relevance
          // Keep original order (or implement a relevance algorithm)
          break;
      }
    });
  }

  void _showSortOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Sort By',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ..._sortOptions.map((option) {
                return ListTile(
                  title: Text(option),
                  trailing:
                      _selectedSort == option
                          ? const Icon(Icons.check, color: Colors.black)
                          : null,
                  onTap: () {
                    setState(() {
                      _selectedSort = option;
                      _sortBooks();
                    });
                    Navigator.pop(context);
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        title: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Search books...',
            border: InputBorder.none,
            hintStyle: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: Colors.grey.shade500),
          ),
          style: Theme.of(context).textTheme.bodyLarge,
          autofocus: true,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list, color: Colors.black),
            onPressed: _showSortOptions,
          ),
        ],
      ),
      body:
          _isLoading
              ? _buildShimmerLoader()
              : Column(
                children: [
                  if (_isSearching || _searchController.text.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${_searchResults.length} ${_searchResults.length == 1 ? 'result' : 'results'}',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: Colors.grey.shade600),
                          ),
                          TextButton(
                            onPressed: _showSortOptions,
                            child: Row(
                              children: [
                                Text(
                                  _selectedSort,
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(color: Colors.black),
                                ),
                                const SizedBox(width: 4),
                                const Icon(Icons.arrow_drop_down, size: 16),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  Expanded(
                    child:
                        _searchResults.isEmpty
                            ? _buildEmptyState()
                            : ListView.builder(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              itemCount: _searchResults.length,
                              itemBuilder: (context, index) {
                                final book = _searchResults[index];
                                return _SearchResultItem(book: book);
                              },
                            ),
                  ),
                ],
              ),
    );
  }

  Widget _buildShimmerLoader() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 16),
      itemCount: 6,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: Container(
            height: 100,
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 48, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            _searchController.text.isEmpty
                ? 'Search for books'
                : 'No results found',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(color: Colors.grey.shade600),
          ),
          const SizedBox(height: 8),
          if (_searchController.text.isEmpty)
            Text(
              'Try searching by title, author, or description',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade500),
            )
          else
            Text(
              'Try different keywords',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade500),
            ),
        ],
      ),
    );
  }
}

class _SearchResultItem extends StatelessWidget {
  final BookModel book;

  const _SearchResultItem({required this.book});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Get.to(() => BookDetailsScreen(book: book));
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Book Cover
            Container(
              width: 60,
              height: 90,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.grey.shade100,
              ),
              child:
                  book.imageUrl?.isNotEmpty ?? false
                      ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          book.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Center(
                              child: Icon(
                                Icons.book_outlined,
                                size: 24,
                                color: Colors.grey,
                              ),
                            );
                          },
                        ),
                      )
                      : const Center(
                        child: Icon(
                          Icons.book_outlined,
                          size: 24,
                          color: Colors.grey,
                        ),
                      ),
            ),
            const SizedBox(width: 16),

            // Book Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    book.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    book.author,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '\$${book.price}',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
