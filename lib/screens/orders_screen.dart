import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/constants/colors.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            'My Orders',
            style: GoogleFonts.playfairDisplay(fontWeight: FontWeight.w700),
          ),
          backgroundColor: Colors.white,
          elevation: 0,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.login_outlined,
                size: 64,
                color: AppColors.textSecondary,
              ),
              const SizedBox(height: 16),
              Text(
                'Please login to view your orders',
                style: GoogleFonts.inter(
                  color: AppColors.textSecondary,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'My Orders',
          style: GoogleFonts.playfairDisplay(fontWeight: FontWeight.w700),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('orders')
            .where('userId', isEqualTo: userId)
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error loading orders: ${snapshot.error}',
                style: GoogleFonts.inter(color: Colors.red),
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_bag_outlined,
                    size: 64,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No orders yet',
                    style: GoogleFonts.inter(
                      color: AppColors.textSecondary,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Start shopping to see your orders here',
                    style: GoogleFonts.inter(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            );
          }

          final orders = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final orderDoc = orders[index];
              final orderData = orderDoc.data() as Map<String, dynamic>;

              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _OrderCard(
                  orderId: orderData['orderNumber'] ?? orderDoc.id,
                  date: _formatDate(orderData['createdAt']),
                  status: orderData['status'] ?? 'Processing',
                  total: (orderData['totalAmount'] as num?)?.toDouble() ?? 0.0,
                  currentStep: _getStatusStep(orderData['status']),
                  items: orderData['items'] as List<dynamic>? ?? [],
                ),
              );
            },
          );
        },
      ),
    );
  }

  String _formatDate(dynamic timestamp) {
    if (timestamp is Timestamp) {
      final date = timestamp.toDate();
      return '${date.day} ${_getMonthName(date.month)} ${date.year}';
    }
    return 'Unknown date';
  }

  String _getMonthName(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return months[month - 1];
  }

  int _getStatusStep(String? status) {
    switch (status?.toLowerCase()) {
      case 'pending':
      case 'processing':
        return 1;
      case 'shipped':
      case 'in transit':
        return 2;
      case 'delivered':
        return 3;
      default:
        return 0;
    }
  }
}

class _OrderCard extends StatelessWidget {
  final String orderId;
  final String date;
  final String status;
  final double total;
  final int currentStep;
  final List<dynamic> items;

  const _OrderCard({
    required this.orderId,
    required this.date,
    required this.status,
    required this.total,
    required this.currentStep,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                orderId,
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: _getStatusColor(status).withValues(alpha:0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  status,
                  style: GoogleFonts.inter(
                    color: _getStatusColor(status),
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Order placed on $date',
            style: GoogleFonts.inter(
              color: AppColors.textSecondary,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Total: \$${total.toStringAsFixed(2)}',
            style: GoogleFonts.playfairDisplay(
              color: AppColors.accent,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 12),

          // Order Tracking Stepper
          Stepper(
            currentStep: currentStep,
            controlsBuilder: (context, details) {
              return const SizedBox.shrink(); // Hide default controls
            },
            steps: [
              Step(
                title: Text('Placed', style: GoogleFonts.inter(fontSize: 12)),
                content: const Text('Order confirmed'),
                isActive: currentStep >= 0,
                state: currentStep > 0 ? StepState.complete : StepState.editing,
              ),
              Step(
                title: Text(
                  'Processing',
                  style: GoogleFonts.inter(fontSize: 12),
                ),
                content: const Text('Preparing your watch'),
                isActive: currentStep >= 1,
                state: currentStep > 1 ? StepState.complete : StepState.editing,
              ),
              Step(
                title: Text('Shipped', style: GoogleFonts.inter(fontSize: 12)),
                content: const Text('In transit'),
                isActive: currentStep >= 2,
                state: currentStep > 2 ? StepState.complete : StepState.editing,
              ),
              Step(
                title: Text(
                  'Delivered',
                  style: GoogleFonts.inter(fontSize: 12),
                ),
                content: const Text('Pending'),
                isActive: currentStep >= 3,
                state: currentStep == 3
                    ? StepState.complete
                    : StepState.indexed,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Delivered':
        return Colors.green;
      case 'In Transit':
        return Colors.blue;
      case 'Processing':
        return Colors.orange;
      default:
        return AppColors.textSecondary;
    }
  }
}
