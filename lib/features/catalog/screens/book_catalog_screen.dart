import 'package:bookstore/common/di/dependencies.dart';
import 'package:bookstore/common/exceptions/custom_exception.dart';
import 'package:bookstore/common/widgets/status_message.dart';
import 'package:bookstore/features/cart_wishlist/services/wishlist_service.dart';
import 'package:bookstore/features/catalog/models/book_model.dart';
import 'package:bookstore/features/catalog/screens/book_details_screen.dart';
import 'package:bookstore/features/catalog/screens/search_screen.dart';
import 'package:bookstore/features/catalog/services/book_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';

class BookCatalogScreen extends StatefulWidget {
  const BookCatalogScreen({super.key});

  @override
  State<BookCatalogScreen> createState() => _BookCatalogScreenState();
}

class _BookCatalogScreenState extends State<BookCatalogScreen>
    with SingleTickerProviderStateMixin {
  final BookService _bookService = locator<BookService>();
  late TabController _tabController;
  final List<String> categories = [
    'All',
    'Fiction',
    'Non-Fiction',
    'Sci-Fi',
    'Romance',
    'Mystery',
  ];
  String _selectedCategory = 'All';
  String _selectedTab = 'All Books';
  List<BookModel> _books = [];
  List<BookModel> _filteredBooks = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_handleTabSelection);
    _loadBooks();
  }

  void _handleTabSelection() {
    if (_tabController.indexIsChanging) {
      setState(() {
        _selectedTab =
            _tabController.index == 0
                ? 'All Books'
                : _tabController.index == 1
                ? 'Bestsellers'
                : 'New Arrivals';
        _applyFilters();
      });
    }
  }

  Future<void> _loadBooks() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final books = await _bookService.fetchBooks();
      setState(() {
        _books = books;
        _filteredBooks = books;
      });
    } on BookStoreAppException catch (e) {
      showMessage(e.message, StatusMessage.error);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _applyFilters() {
    setState(() {
      _filteredBooks =
          _books.where((book) {
            // Apply category filter
            if (_selectedCategory != 'All') {
              // Since we don't have genre in BookModel, we'll simulate it
              final simulatedGenre =
                  book.title.length % 2 == 0 ? 'Fiction' : 'Non-Fiction';
              if (_selectedCategory != simulatedGenre) return false;
            }

            // Apply tab filter (simulated since we don't have these fields)
            if (_selectedTab == 'Bestsellers') {
              return book.price >
                  15; // Simulate bestsellers as more expensive books
            } else if (_selectedTab == 'New Arrivals') {
              return book.price < 20; // Simulate new arrivals as cheaper books
            }

            return true;
          }).toList();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Book Catalog',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.black),
            onPressed: () => Get.to(() => const SearchScreen()),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category Chips
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(category),
                    selected: _selectedCategory == category,
                    onSelected: (selected) {
                      setState(() {
                        _selectedCategory = selected ? category : 'All';
                        _applyFilters();
                      });
                    },
                    selectedColor: Colors.black,
                    labelStyle: TextStyle(
                      color:
                          _selectedCategory == category
                              ? Colors.white
                              : Colors.black,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                );
              },
            ),
          ),

          // Tab Bar
          Container(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Colors.grey.shade200, width: 1),
              ),
            ),
            child: TabBar(
              controller: _tabController,
              labelColor: Colors.black,
              unselectedLabelColor: Colors.grey,
              indicatorColor: Colors.black,
              tabs: const [
                Tab(text: 'All Books'),
                Tab(text: 'Bestsellers'),
                Tab(text: 'New Arrivals'),
              ],
            ),
          ),

          // Book Grid
          Expanded(
            child:
                _isLoading
                    ? _buildShimmerLoader()
                    : _filteredBooks.isEmpty
                    ? _buildEmptyState()
                    : GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.7,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                          ),
                      itemCount: _filteredBooks.length,
                      itemBuilder: (context, index) {
                        final book = _filteredBooks[index];
                        return _BookCard(book: book);
                      },
                    ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerLoader() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.7,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: 6,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: Container(
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
          Icon(Icons.book_outlined, size: 48, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            'No books found',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(color: Colors.grey.shade600),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your filters',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }
}

class _BookCard extends StatelessWidget {
  final BookModel book;

  const _BookCard({required this.book});

  @override
  Widget build(BuildContext context) {
    final _wishlistService = locator<WishlistService>();

    return GestureDetector(
      onTap: () {
        Get.to(() => BookDetailsScreen(book: book));
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Book Cover
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.grey.shade100,
                    ),
                    child: book.imageUrl?.isNotEmpty ?? false
                        ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        book.imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Center(
                            child: Icon(
                              Icons.book_outlined,
                              size: 48,
                              color: Colors.grey,
                            ),
                          );
                        },
                      ),
                    )
                        : const Center(
                      child: Icon(
                        Icons.book_outlined,
                        size: 48,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // Book Title
                Text(
                  book.title,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                // Author
                Text(
                  book.author,
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: Colors.grey.shade600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                // Price
                Text(
                  '\$${book.price}',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
            Positioned(
              top: 8,
              right: 8,
              child: StreamBuilder<bool>(
                stream: _wishlistService.isInWishlistStream(book.id),
                builder: (context, snapshot) {
                  final isInWishlist = snapshot.data ?? false;
                  return IconButton(
                    icon: Icon(
                      isInWishlist ? Icons.favorite : Icons.favorite_border,
                      color: isInWishlist ? Colors.red : Colors.black,
                    ),
                    onPressed: () async {
                      await _wishlistService.toggleWishlist(book);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
