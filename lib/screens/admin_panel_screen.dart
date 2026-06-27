import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/constants/colors.dart';
import '../providers/product_crud_provider.dart';
import '../providers/user_provider.dart';
import '../widgets/full_screen_video_background.dart';
import '../models/watch.dart';
import 'product_form_screen.dart';
import 'home_screen.dart';

class AdminPanelScreen extends StatefulWidget {
  const AdminPanelScreen({super.key});

  @override
  State<AdminPanelScreen> createState() => _AdminPanelScreenState();
}

class _AdminPanelScreenState extends State<AdminPanelScreen> {
  int _selectedIndex = 0;

  void _onScreenSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FullScreenVideoBackground(
        child: AdminDashboard(onScreenSelected: _onScreenSelected),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: _onScreenSelected,
        selectedItemColor: AppColors.accent,
        unselectedItemColor: Colors.white70,
        backgroundColor: Colors.black87,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.watch_later),
            label: 'Products',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Users'),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag),
            label: 'Orders',
          ),
        ],
      ),
    );
  }
}

// Admin Dashboard Home
class AdminDashboard extends StatelessWidget {
  final Function(int)? onScreenSelected;

  const AdminDashboard({super.key, this.onScreenSelected});

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final productCRUD = context.watch<ProductCRUDProvider>();

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Admin Panel',
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Welcome back, ${userProvider.currentUser?.name ?? 'Admin'}',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.logout, color: Colors.white),
                  onPressed: () async {
                    await userProvider.logout();
                    if (context.mounted) {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                          builder: (context) => const HomeScreen(),
                        ),
                        (route) => false,
                      );
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 30),

            // Stats Cards
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.5,
              children: [
                _StatCard(
                  icon: Icons.watch_later,
                  title: 'Total Products',
                  value: '${productCRUD.products.length}',
                  color: Colors.blue,
                ),
                _StatCard(
                  icon: Icons.people,
                  title: 'Total Users',
                  value: '${userProvider.users.length}',
                  color: Colors.green,
                ),
                _StatCard(
                  icon: Icons.shopping_cart,
                  title: 'Total Orders',
                  value: '0',
                  color: Colors.orange,
                ),
                _StatCard(
                  icon: Icons.attach_money,
                  title: 'Revenue',
                  value: '\$0',
                  color: Colors.purple,
                ),
              ],
            ),
            const SizedBox(height: 30),

            // Quick Actions
            Text(
              'Quick Actions',
              style: GoogleFonts.playfairDisplay(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Admin Panel',
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Welcome back, ${userProvider.currentUser?.name ?? 'Admin'}',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.logout, color: Colors.white),
                  onPressed: () async {
                    await userProvider.logout();
                    if (context.mounted) {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                          builder: (context) => const HomeScreen(),
                        ),
                        (route) => false,
                      );
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 30),

            // Stats Cards
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.5,
              children: [
                _StatCard(
                  icon: Icons.watch_later,
                  title: 'Total Products',
                  value: '${productCRUD.products.length}',
                  color: Colors.blue,
                ),
                _StatCard(
                  icon: Icons.people,
                  title: 'Total Users',
                  value: '${userProvider.users.length}',
                  color: Colors.green,
                ),
                _StatCard(
                  icon: Icons.shopping_cart,
                  title: 'Total Orders',
                  value: '0',
                  color: Colors.orange,
                ),
                _StatCard(
                  icon: Icons.attach_money,
                  title: 'Revenue',
                  value: '\$0',
                  color: Colors.purple,
                ),
              ],
            ),
            const SizedBox(height: 30),

            // Quick Actions
            Text(
              'Quick Actions',
              style: GoogleFonts.playfairDisplay(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),

            _QuickActionCard(
              icon: Icons.add_circle,
              title: 'Add New Product',
              subtitle: 'Create a new product listing',
              color: Colors.blue,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ProductFormScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),

            _QuickActionCard(
              icon: Icons.edit,
              title: 'Manage Products',
              subtitle: 'Edit or delete existing products',
              color: Colors.green,
              onTap: () {
                onScreenSelected?.call(1);
              },
            ),
            const SizedBox(height: 12),

            _QuickActionCard(
              icon: Icons.analytics,
              title: 'View Analytics',
              subtitle: 'Check sales and performance',
              color: Colors.orange,
              onTap: () {
                _showAnalyticsDialog(context, productCRUD, userProvider);
              },
            ),
            const SizedBox(height: 12),

            _QuickActionCard(
              icon: Icons.people,
              title: 'Manage Users',
              subtitle: 'View and manage user accounts',
              color: Colors.purple,
              onTap: () {
                onScreenSelected?.call(2);
              },
            ),
            const SizedBox(height: 12),

            _QuickActionCard(
              icon: Icons.shopping_bag,
              title: 'View Orders',
              subtitle: 'Track customer orders',
              color: Colors.teal,
              onTap: () {
                onScreenSelected?.call(3);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showAnalyticsDialog(
    BuildContext context,
    ProductCRUDProvider productCRUD,
    UserProvider userProvider,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: Text(
          'Analytics Overview',
          style: GoogleFonts.playfairDisplay(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _AnalyticsRow(
              label: 'Total Products',
              value: '${productCRUD.products.length}',
            ),
            const SizedBox(height: 8),
            _AnalyticsRow(
              label: 'Total Users',
              value: '${userProvider.users.length}',
            ),
            const SizedBox(height: 8),
            _AnalyticsRow(label: 'Total Orders', value: '0'),
            const SizedBox(height: 8),
            _AnalyticsRow(label: 'Revenue', value: '\$0.00'),
            const SizedBox(height: 16),
            Text(
              'Note: Connect Firebase for real-time analytics',
              style: GoogleFonts.inter(fontSize: 11, color: Colors.white54),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'Close',
              style: TextStyle(color: AppColors.accent),
            ),
          ),
        ],
      ),
    );
  }
}

class _AnalyticsRow extends StatelessWidget {
  final String label;
  final String value;

  const _AnalyticsRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.white70)),
        Text(
          value,
          style: GoogleFonts.inter(
            color: AppColors.accent,
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: color, size: 32),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: GoogleFonts.inter(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              Text(
                title,
                style: GoogleFonts.inter(fontSize: 12, color: Colors.white70),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              color: Colors.white54,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}

// Admin Products Screen
class AdminProducts extends StatelessWidget {
  const AdminProducts({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Consumer<ProductCRUDProvider>(
        builder: (context, productCRUD, child) {
          if (productCRUD.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Manage Products',
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.add_circle,
                        color: AppColors.accent,
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ProductFormScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              // Products List
              Expanded(
                child: productCRUD.products.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.watch_later,
                              size: 80,
                              color: Colors.white.withValues(alpha: 0.3),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No products yet',
                              style: GoogleFonts.playfairDisplay(
                                fontSize: 20,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: () => productCRUD.loadProducts(),
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          itemCount: productCRUD.products.length,
                          itemBuilder: (context, index) {
                            final product = productCRUD.products[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              color: Colors.white.withValues(alpha: 0.1),
                              child: ListTile(
                                leading: Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    color: Colors.white.withValues(alpha: 0.2),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.asset(
                                      product.images[0],
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                            return const Icon(
                                              Icons.watch_later,
                                              color: Colors.white54,
                                            );
                                          },
                                    ),
                                  ),
                                ),
                                title: Text(
                                  product.name,
                                  style: GoogleFonts.inter(
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 4),
                                    Text(
                                      product.brand,
                                      style: const TextStyle(
                                        color: Colors.white70,
                                      ),
                                    ),
                                    Text(
                                      '\$${product.price.toStringAsFixed(2)}',
                                      style: GoogleFonts.inter(
                                        color: AppColors.accent,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(
                                        Icons.edit,
                                        color: Colors.blue,
                                      ),
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                ProductFormScreen(
                                                  product: product,
                                                ),
                                          ),
                                        );
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.delete,
                                        color: Colors.red,
                                      ),
                                      onPressed: () {
                                        _showDeleteDialog(
                                          context,
                                          productCRUD,
                                          product,
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showDeleteDialog(
    BuildContext context,
    ProductCRUDProvider productCRUD,
    Watch product,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: Text(
          'Delete Product',
          style: GoogleFonts.playfairDisplay(color: Colors.white),
        ),
        content: Text(
          'Are you sure you want to delete "${product.name}"?',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.white70),
            ),
          ),
          TextButton(
            onPressed: () async {
              await productCRUD.deleteProduct(product.id);
              if (context.mounted) {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Product deleted successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

// Admin Users Screen
class AdminUsers extends StatelessWidget {
  const AdminUsers({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();

    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              'Manage Users',
              style: GoogleFonts.playfairDisplay(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
          Expanded(
            child: userProvider.users.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.people,
                          size: 80,
                          color: Colors.white.withValues(alpha: 0.3),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No users yet',
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 20,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: userProvider.users.length,
                    itemBuilder: (context, index) {
                      final user = userProvider.users[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        color: Colors.white.withValues(alpha: 0.1),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: user.isAdmin
                                ? Colors.orange
                                : Colors.blue,
                            child: Text(
                              user.name[0].toUpperCase(),
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                          title: Text(
                            user.name,
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          subtitle: Text(
                            user.email,
                            style: const TextStyle(color: Colors.white70),
                          ),
                          trailing: user.isAdmin
                              ? const Chip(
                                  label: Text(
                                    'Admin',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                    ),
                                  ),
                                  backgroundColor: Colors.orange,
                                )
                              : const Chip(
                                  label: Text(
                                    'User',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                    ),
                                  ),
                                  backgroundColor: Colors.blue,
                                ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

// Admin Orders Screen
class AdminOrders extends StatelessWidget {
  const AdminOrders({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              'Manage Orders',
              style: GoogleFonts.playfairDisplay(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_bag,
                    size: 80,
                    color: Colors.white.withValues(alpha: 0.3),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No orders yet',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 20,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Orders will appear here when customers make purchases',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: Colors.white54,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
