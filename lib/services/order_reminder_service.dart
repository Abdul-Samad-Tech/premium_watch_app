import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:logger/logger.dart';
import 'email_service.dart';

class OrderReminderService {
  static final Logger _logger = Logger();
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // Check and send reminders for pending orders
  static Future<void> checkAndSendReminders({
    int reminderIntervalHours = 25,
  }) async {
    try {
      _logger.d('Checking for pending orders...');

      // Get all pending orders
      final pendingOrdersQuery = await _firestore
          .collection('orders')
          .where('status', isEqualTo: 'pending')
          .get();

      if (pendingOrdersQuery.docs.isEmpty) {
        _logger.d('No pending orders found');
        return;
      }

      _logger.d('Found ${pendingOrdersQuery.docs.length} pending orders');

      for (var orderDoc in pendingOrdersQuery.docs) {
        final orderData = orderDoc.data();
        final orderNumber = orderData['orderNumber'] as String? ?? '';
        final userId = orderData['userId'] as String? ?? '';
        final orderDate = orderData['createdAt'] as Timestamp?;
        final items = orderData['items'] as List<dynamic>? ?? [];
        final totalAmount = orderData['totalAmount'] as double? ?? 0.0;

        if (orderDate == null) continue;

        // Calculate hours elapsed
        final now = DateTime.now();
        final orderDateTime = orderDate.toDate();
        final hoursElapsed = now.difference(orderDateTime).inHours;

        _logger.d('Order $orderNumber: $hoursElapsed hours elapsed');

        // Send reminder if 25+ hours have passed
        if (hoursElapsed >= reminderIntervalHours) {
          // Get user details
          final userDoc = await _firestore
              .collection('users')
              .doc(userId)
              .get();
          if (!userDoc.exists) continue;

          final userData = userDoc.data();
          final userEmail = userData?['email'] as String? ?? '';
          final userName = userData?['name'] as String? ?? 'Customer';

          // Convert items to proper format
          final itemsList = items.map((item) {
            return {
              'name': item['name'] as String? ?? '',
              'quantity': item['quantity'] as int? ?? 1,
              'price': item['price'] as double? ?? 0.0,
            };
          }).toList();

          // Send reminder email
          final emailSent = await EmailService.sendOrderReminderEmail(
            toEmail: userEmail,
            userName: userName,
            orderNumber: orderNumber,
            items: itemsList,
            totalAmount: totalAmount,
            hoursSinceOrder: hoursElapsed,
          );

          if (emailSent) {
            _logger.d('Reminder email sent for order $orderNumber');

            // Update last reminder timestamp in Firestore
            await orderDoc.reference.update({
              'lastReminderSent': FieldValue.serverTimestamp(),
              'reminderCount': FieldValue.increment(1),
            });
          }
        }
      }
    } catch (e) {
      _logger.d('Error checking order reminders: $e');
    }
  }

  // Check reminders for current user's orders only
  static Future<void> checkCurrentUserReminders() async {
    final user = _auth.currentUser;
    if (user == null) {
      _logger.d('No user logged in');
      return;
    }

    try {
      _logger.d('Checking pending orders for user ${user.uid}');

      // Get user's pending orders
      final pendingOrdersQuery = await _firestore
          .collection('orders')
          .where('userId', isEqualTo: user.uid)
          .where('status', isEqualTo: 'pending')
          .get();

      if (pendingOrdersQuery.docs.isEmpty) {
        _logger.d('No pending orders for current user');
        return;
      }

      for (var orderDoc in pendingOrdersQuery.docs) {
        final orderData = orderDoc.data();
        final orderNumber = orderData['orderNumber'] as String? ?? '';
        final orderDate = orderData['createdAt'] as Timestamp?;
        final lastReminderSent = orderData['lastReminderSent'] as Timestamp?;
        final items = orderData['items'] as List<dynamic>? ?? [];
        final totalAmount = orderData['totalAmount'] as double? ?? 0.0;

        if (orderDate == null) continue;

        final now = DateTime.now();
        final orderDateTime = orderDate.toDate();
        final hoursElapsed = now.difference(orderDateTime).inHours;

        // Check if we should send a reminder (25+ hours and not sent recently)
        bool shouldSendReminder = hoursElapsed >= 25;

        if (lastReminderSent != null) {
          final lastReminderDateTime = lastReminderSent.toDate();
          final hoursSinceLastReminder = now
              .difference(lastReminderDateTime)
              .inHours;
          // Only send reminder if 25+ hours since last reminder
          shouldSendReminder = hoursSinceLastReminder >= 25;
        }

        if (shouldSendReminder) {
          final itemsList = items.map((item) {
            return {
              'name': item['name'] as String? ?? '',
              'quantity': item['quantity'] as int? ?? 1,
              'price': item['price'] as double? ?? 0.0,
            };
          }).toList();

          final emailSent = await EmailService.sendOrderReminderEmail(
            toEmail: user.email ?? '',
            userName: user.displayName ?? 'Customer',
            orderNumber: orderNumber,
            items: itemsList,
            totalAmount: totalAmount,
            hoursSinceOrder: hoursElapsed,
          );

          if (emailSent) {
            await orderDoc.reference.update({
              'lastReminderSent': FieldValue.serverTimestamp(),
              'reminderCount': FieldValue.increment(1),
            });
          }
        }
      }
    } catch (e) {
      _logger.d('Error checking user order reminders: $e');
    }
  }

  // Manual trigger for testing
  static Future<void> sendTestReminder(String orderNumber) async {
    try {
      final orderDoc = await _firestore
          .collection('orders')
          .where('orderNumber', isEqualTo: orderNumber)
          .get();

      if (orderDoc.docs.isEmpty) {
        _logger.d('Order not found: $orderNumber');
        return;
      }

      final orderData = orderDoc.docs.first.data();
      final userId = orderData['userId'] as String? ?? '';
      final orderDate = orderData['createdAt'] as Timestamp?;
      final items = orderData['items'] as List<dynamic>? ?? [];
      final totalAmount = orderData['totalAmount'] as double? ?? 0.0;

      final userDoc = await _firestore.collection('users').doc(userId).get();
      if (!userDoc.exists) return;

      final userData = userDoc.data();
      final userEmail = userData?['email'] as String? ?? '';
      final userName = userData?['name'] as String? ?? 'Customer';

      final itemsList = items.map((item) {
        return {
          'name': item['name'] as String? ?? '',
          'quantity': item['quantity'] as int? ?? 1,
          'price': item['price'] as double? ?? 0.0,
        };
      }).toList();

      final hoursElapsed = orderDate != null
          ? DateTime.now().difference(orderDate.toDate()).inHours
          : 0;

      await EmailService.sendOrderReminderEmail(
        toEmail: userEmail,
        userName: userName,
        orderNumber: orderNumber,
        items: itemsList,
        totalAmount: totalAmount,
        hoursSinceOrder: hoursElapsed,
      );

      _logger.d('Test reminder sent for order $orderNumber');
    } catch (e) {
      _logger.d('Error sending test reminder: $e');
    }
  }
}
