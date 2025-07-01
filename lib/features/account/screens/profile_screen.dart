import 'package:bookstore/common/di/dependencies.dart';
import 'package:bookstore/common/widgets/custom_confirmation_modal.dart';
import 'package:bookstore/features/authentication/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:get/get.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _authService = locator.get<AuthService>();

  @override
  void initState() {
    super.initState();
  }

  void _showLogoutConfirmation() {
    showDialog(
      context: context,
      builder:
          (context) => ConfirmationModal(
            title: 'Confirm Logout',
            message: 'Are you sure you want to log out?',
            confirmText: 'Logout',
            cancelText: 'Cancel',
            onConfirm: handleLogout,
          ),
    );
  }

  Future<void> handleLogout() async {
    await _authService.signOut();
    Get.toNamed('/login');
  }

  String _getInitials() {
    return FirebaseAuth.instance.currentUser?.email
            ?.substring(0, 1)
            .toUpperCase() ??
        'U';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: Container(),
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  _getInitials(),
                  style: const TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Center(
            child: Text(
              '${FirebaseAuth.instance.currentUser?.email}',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w300),
            ),
          ),
          const SizedBox(height: 40),
          _buildSettingsItem(
            context,
            icon: Icons.person,
            title: 'Personal Information',
            onTap: () => Get.toNamed('/personal-information'),
          ),
          _buildDivider(context),
          _buildSettingsItem(
            context,
            icon: Icons.car_crash_outlined,
            title: 'Shipping Address',
            onTap: () => Get.toNamed('/shipping-address'),
          ),
          _buildDivider(context),
          _buildSettingsItem(
            context,
            icon: Icons.logout,
            title: 'Logout',
            showTrailing: false,
            onTap: _showLogoutConfirmation,
          ),
        ],
      ),
    );
  }

  Widget _buildDivider(BuildContext context) {
    return Divider(
      height: 1,
      thickness: 1,
      indent: 12,
      endIndent: 12,
      color: Colors.black26,
    );
  }

  Widget _buildSettingsItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    Widget? trailing,
    required VoidCallback onTap,
    Color? textColor,
    Color? iconColor,
    bool showTrailing = true,
  }) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color:
              iconColor ??
              Theme.of(context).colorScheme.surface.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(child: Icon(icon, size: 20)),
      ),
      title: Text(
        title,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w600,
          color: textColor ?? Theme.of(context).colorScheme.onSurface,
        ),
      ),
      trailing:
          showTrailing
              ? (trailing ??
                  Icon(
                    Icons.chevron_right,
                    color: Theme.of(context).colorScheme.surface,
                  ))
              : null,
    );
  }
}
