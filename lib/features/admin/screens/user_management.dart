import 'package:bookstore/common/di/dependencies.dart';
import 'package:bookstore/common/exceptions/custom_exception.dart';
import 'package:bookstore/features/admin/services/admin_service.dart';
import 'package:bookstore/features/admin/widgets/user_card.dart';
import 'package:bookstore/features/authentication/models/user_model.dart';
import 'package:flutter/material.dart';

class UserManagement extends StatefulWidget {
  const UserManagement({super.key});

  @override
  State<UserManagement> createState() => _UserManagementState();
}

class _UserManagementState extends State<UserManagement> {
  List<UserModel> _users = [];
  List<UserModel> _filteredUsers = [];
  final _adminService = locator<AdminService>();
  final _searchController = TextEditingController();
  bool _isLoading = true;
  bool _hasError = false;
  String _selectedFilter = 'All';

  Future<void> _fetchUsers() async {
    try {
      setState(() {
        _isLoading = true;
        _hasError = false;
      });

      final users = await _adminService.fetchUsers();
      setState(() {
        _users = users;
        _filteredUsers = users;
      });
    } on BookStoreAppException {
      setState(() {
        _hasError = true;
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _filterUsers(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredUsers = _users;
      } else {
        _filteredUsers =
            _users.where((user) {
              final fullName =
                  '${user.firstName ?? ''} ${user.lastName ?? ''}'
                      .toLowerCase();
              final email = user.email.toLowerCase();
              final role = user.role.toLowerCase();
              final searchQuery = query.toLowerCase();

              return fullName.contains(searchQuery) ||
                  email.contains(searchQuery) ||
                  role.contains(searchQuery);
            }).toList();
      }
    });
  }

  void _filterByRole(String role) {
    setState(() {
      _selectedFilter = role;
      if (role == 'All') {
        _filteredUsers = _users;
      } else {
        _filteredUsers = _users.where((user) => user.role == role).toList();
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchUsers();
    _searchController.addListener(() => _filterUsers(_searchController.text));
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
            strokeWidth: 3,
          ),
          SizedBox(height: 16),
          Text(
            'Loading users...',
            style: TextStyle(color: Colors.black54, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.black54),
          const SizedBox(height: 24),
          Text(
            'Unable to fetch users',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.black,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Please check your connection and try again',
            style: TextStyle(color: Colors.black54, fontSize: 16),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _fetchUsers,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilter() {
    final roles = [
      'All',
      ...{..._users.map((u) => u.role)},
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Column(
        children: [
          // Search Bar
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search by name, email, or role...',
              hintStyle: const TextStyle(color: Colors.black54),
              prefixIcon: const Icon(Icons.search, color: Colors.black54),
              suffixIcon:
                  _searchController.text.isNotEmpty
                      ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.black54),
                        onPressed: () {
                          _searchController.clear();
                          _filterUsers('');
                        },
                      )
                      : null,
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.black, width: 2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Role Filter
          Row(
            children: [
              const Text(
                'Filter by role: ',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children:
                        roles.map((role) {
                          final isSelected = _selectedFilter == role;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: FilterChip(
                              label: Text(role),
                              selected: isSelected,
                              onSelected: (_) => _filterByRole(role),
                              backgroundColor: Colors.white,
                              selectedColor: Colors.black,
                              labelStyle: TextStyle(
                                color: isSelected ? Colors.white : Colors.black,
                                fontWeight: FontWeight.w500,
                              ),
                              side: BorderSide(
                                color:
                                    isSelected
                                        ? Colors.black
                                        : Colors.grey.shade300,
                              ),
                            ),
                          );
                        }).toList(),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            'No users found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your search or filter criteria',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          'View your users',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 20),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: Colors.grey.shade200),
        ),
        actions: [
          IconButton(
            onPressed: _fetchUsers,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body:
          _isLoading
              ? _buildLoadingState()
              : _hasError
              ? _buildErrorState(context)
              : Column(
                children: [
                  _buildSearchAndFilter(),
                  // Results Count
                  if (_filteredUsers.isNotEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: Text(
                        '${_filteredUsers.length} user${_filteredUsers.length == 1 ? '' : 's'} found',
                        style: const TextStyle(
                          color: Colors.black54,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  Expanded(
                    child:
                        _filteredUsers.isEmpty
                            ? _buildEmptyState()
                            : ListView.builder(
                              padding: const EdgeInsets.only(bottom: 16),
                              itemCount: _filteredUsers.length,
                              itemBuilder: (context, index) {
                                final user = _filteredUsers[index];
                                return UserCard(
                                  firstName: user.firstName,
                                  lastName: user.lastName,
                                  email: user.email,
                                  role: user.role,
                                  createdAt: user.createdAt,
                                );
                              },
                            ),
                  ),
                ],
              ),
    );
  }
}
