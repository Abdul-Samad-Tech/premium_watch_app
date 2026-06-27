import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/constants/colors.dart';
import '../providers/user_provider.dart';
import '../providers/cart_provider.dart';
import 'orders_screen.dart';
import 'wishlist_screen.dart';
import 'addresses_screen.dart';
import 'payment_methods_screen.dart';
import 'settings_screen.dart';
import 'help_support_screen.dart';
import 'profile_edit_screen.dart';

class UserPanelScreen extends StatelessWidget {
  const UserPanelScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'My Profile',
          style: GoogleFonts.playfairDisplay(fontWeight: FontWeight.w700),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ProfileEditScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer<UserProvider>(
        builder: (context, userProvider, child) {
          final user = userProvider.currentUser;
          if (user == null) {
            return const Center(child: Text('Please login to view profile'));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile Header
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.primary, AppColors.accent],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.accent.withValues(alpha: 0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: Colors.white,
                        child: Text(
                          user.name.isNotEmpty
                              ? user.name[0].toUpperCase()
                              : 'U',
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user.name,
                              style: GoogleFonts.playfairDisplay(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              user.email,
                              style: GoogleFonts.inter(
                                color: Colors.white.withValues(alpha: 0.9),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Personal Information
                _buildSectionCard('Personal Information', Icons.person, [
                  _buildInfoRow('Full Name', user.name),
                  _buildInfoRow('Email', user.email),
                  _buildInfoRow('Phone', user.phone ?? 'Not provided'),
                  _buildInfoRow('Member Since', _formatDate(user.createdAt)),
                ]),

                const SizedBox(height: 16),

                // Address Information
                _buildSectionCard('Address Information', Icons.location_on, [
                  _buildInfoRow('Default Address', user.address ?? 'Not set'),
                  _buildInfoRow('City', user.city ?? 'Not provided'),
                  _buildInfoRow(
                    'Postal Code',
                    user.postalCode ?? 'Not provided',
                  ),
                ]),

                const SizedBox(height: 16),

                // Quick Actions
                _buildSectionCard('Quick Actions', Icons.dashboard, [
                  _buildActionTile(
                    'My Orders',
                    Icons.shopping_bag,
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const OrdersScreen(),
                      ),
                    ),
                  ),
                  _buildActionTile(
                    'Wishlist',
                    Icons.favorite,
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const WishlistScreen(),
                      ),
                    ),
                  ),
                  _buildActionTile(
                    'Addresses',
                    Icons.location_on,
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AddressesScreen(),
                      ),
                    ),
                  ),
                  _buildActionTile(
                    'Payment Methods',
                    Icons.payment,
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PaymentMethodsScreen(),
                      ),
                    ),
                  ),
                ]),

                const SizedBox(height: 16),

                // Account Settings
                _buildSectionCard('Account Settings', Icons.settings, [
                  _buildActionTile(
                    'Settings',
                    Icons.settings,
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SettingsScreen(),
                      ),
                    ),
                  ),
                  _buildActionTile(
                    'Help & Support',
                    Icons.help,
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const HelpSupportScreen(),
                      ),
                    ),
                  ),
                ]),

                const SizedBox(height: 24),

                // Cart Summary
                Consumer<CartProvider>(
                  builder: (context, cartProvider, child) {
                    return _buildSectionCard(
                      'Shopping Cart',
                      Icons.shopping_cart,
                      [
                        _buildInfoRow('Items', '${cartProvider.itemCount}'),
                        _buildInfoRow(
                          'Total',
                          '\$${cartProvider.totalAmount.toStringAsFixed(2)}',
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionCard(String title, IconData icon, List<Widget> children) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(icon, color: AppColors.primary, size: 20),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile(String title, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primary, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              color: AppColors.textSecondary,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Unknown';
    return '${date!.day}/${date!.month}/${date!.year}';
  }
}
