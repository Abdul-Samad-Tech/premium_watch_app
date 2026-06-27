import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

class EmailService {
  // SECURITY WARNING: Email sending should be done via Firebase Cloud Functions
  // Client-side SMTP is insecure as credentials can be extracted from the app
  // For production: Move all email logic to Cloud Functions
  // For development: Set SMTP credentials via --dart-define
  static final Logger _logger = Logger();

  static String get _smtpUsername {
    const username = String.fromEnvironment('SMTP_USERNAME');
    if (username.isNotEmpty) {
      return username;
    }
    if (kDebugMode) {
      _logger.d('Error: ');
    }
    return '';
  }

  static String get _smtpPassword {
    const password = String.fromEnvironment('SMTP_PASSWORD');
    if (password.isNotEmpty) {
      return password;
    }
    if (kDebugMode) {
      _logger.d('Error: ');
    }
    return '';
  }

  static SmtpServer? get _smtpServer {
    if (_smtpUsername.isEmpty || _smtpPassword.isEmpty) {
      return null;
    }
    return gmail(_smtpUsername, _smtpPassword);
  }

  // SEND WELCOME EMAIL
  static Future<bool> sendWelcomeEmail({
    required String toEmail,
    required String userName,
  }) async {
    if (_smtpServer == null) {
      if (kDebugMode) {
        _logger.d('Error: ');
      }
      return false;
    }

    try {
      final message = Message()
        ..from = Address(_smtpUsername, 'LUXE TIME')
        ..recipients.add(toEmail)
        ..subject = 'Welcome to LUXE TIME - Your Luxury Watch Destination!'
        ..html =
            '''
          <html>
            <body style="font-family: Arial, sans-serif; background-color: #f4f4f4; padding: 20px;">
              <div style="max-width: 600px; margin: 0 auto; background-color: white; padding: 30px; border-radius: 10px;">
                <h1 style="color: #D4AF37; text-align: center;">Welcome to LUXE TIME!</h1>
                <p>Dear $userName,</p>
                <p>Thank you for joining LUXE TIME, your premier destination for luxury timepieces.</p>
                <p>We're excited to have you as part of our exclusive community. Here's what you can do:</p>
                <ul>
                  <li>Browse our curated collection of premium watches</li>
                  <li>Add your favorites to wishlist</li>
                  <li>Use our AR feature to try watches on your wrist</li>
                  <li>Enjoy exclusive member discounts</li>
                </ul>
                <p style="text-align: center; margin: 30px 0;">
                  <a href="#" style="background-color: #D4AF37; color: white; padding: 12px 30px; text-decoration: none; border-radius: 5px;">Start Shopping</a>
                </p>
                <p>If you have any questions, feel free to contact our support team.</p>
                <p>Best regards,<br/>The LUXE TIME Team</p>
                <hr style="margin-top: 30px; border: none; border-top: 1px solid #ddd;"/>
                <p style="font-size: 12px; color: #999; text-align: center;">
                  © 2026 LUXE TIME. All rights reserved.
                </p>
              </div>
            </body>
          </html>
        ''';

      await send(message, _smtpServer!);
      if (kDebugMode) {
        _logger.d('Error: ');
      }
      return true;
    } catch (e) {
      if (kDebugMode) {
        _logger.d('Error: ');
      }
      return false;
    }
  }

  // SEND PASSWORD RESET EMAIL
  static Future<bool> sendPasswordResetEmail({
    required String toEmail,
    required String userName,
    required String resetLink,
  }) async {
    if (_smtpServer == null) {
      if (kDebugMode) {
        _logger.d('Error: ');
      }
      return false;
    }

    try {
      final message = Message()
        ..from = Address(_smtpUsername, 'LUXE TIME')
        ..recipients.add(toEmail)
        ..subject = 'Reset Your LUXE TIME Password'
        ..html =
            '''
          <html>
            <body style="font-family: Arial, sans-serif; background-color: #f4f4f4; padding: 20px;">
              <div style="max-width: 600px; margin: 0 auto; background-color: white; padding: 30px; border-radius: 10px;">
                <h1 style="color: #D4AF37; text-align: center;">Password Reset Request</h1>
                <p>Dear $userName,</p>
                <p>We received a request to reset your password for your LUXE TIME account.</p>
                <p style="text-align: center; margin: 30px 0;">
                  <a href="$resetLink" style="background-color: #D4AF37; color: white; padding: 12px 30px; text-decoration: none; border-radius: 5px;">Reset Password</a>
                </p>
                <p>This link will expire in 1 hour. If you didn't request a password reset, please ignore this email.</p>
                <p>Best regards,<br/>The LUXE TIME Team</p>
                <hr style="margin-top: 30px; border: none; border-top: 1px solid #ddd;"/>
                <p style="font-size: 12px; color: #999; text-align: center;">
                  © 2026 LUXE TIME. All rights reserved.
                </p>
              </div>
            </body>
          </html>
        ''';

      await send(message, _smtpServer!);
      if (kDebugMode) {
        _logger.d('Error: ');
      }
      return true;
    } catch (e) {
      if (kDebugMode) {
        _logger.d('Error: ');
      }
      return false;
    }
  }

  // SEND ORDER REMINDER EMAIL (25-hour reminder for pending orders)
  static Future<bool> sendOrderReminderEmail({
    required String toEmail,
    required String userName,
    required String orderNumber,
    required List<Map<String, dynamic>> items,
    required double totalAmount,
    required int hoursSinceOrder,
  }) async {
    if (_smtpServer == null) {
      if (kDebugMode) {
        _logger.d(
          'Email service not configured. Order reminder email not sent.',
        );
      }
      return false;
    }

    try {
      // Build items list HTML
      String itemsHtml = '';
      for (var item in items) {
        itemsHtml +=
            '''
          <tr>
            <td style="padding: 10px; border-bottom: 1px solid #ddd;">${item['name']}</td>
            <td style="padding: 10px; border-bottom: 1px solid #ddd; text-align: center;">${item['quantity']}</td>
            <td style="padding: 10px; border-bottom: 1px solid #ddd; text-align: right;">\$${item['price'].toStringAsFixed(2)}</td>
          </tr>
        ''';
      }

      final message = Message()
        ..from = Address(_smtpUsername, 'LUXE TIME')
        ..recipients.add(toEmail)
        ..subject = 'Order Update - #$orderNumber - Still Pending'
        ..html =
            '''
          <html>
            <body style="font-family: Arial, sans-serif; background-color: #f4f4f4; padding: 20px;">
              <div style="max-width: 600px; margin: 0 auto; background-color: white; padding: 30px; border-radius: 10px;">
                <h1 style="color: #D4AF37; text-align: center;">Order Status Update</h1>
                <p>Dear $userName,</p>
                <p>This is a friendly reminder about your order <strong>#$orderNumber</strong>.</p>
                
                <div style="background-color: #fff3cd; padding: 15px; border-radius: 5px; margin: 20px 0; border-left: 4px solid #ffc107;">
                  <p style="margin: 0; color: #856404;"><strong>⏰ Time Elapsed:</strong> $hoursSinceOrder hours since order placement</p>
                  <p style="margin: 5px 0 0 0; color: #856404;"><strong>Status:</strong> Pending - Awaiting processing</p>
                </div>

                <h2 style="color: #333;">Order Items</h2>
                <table style="width: 100%; border-collapse: collapse; margin: 20px 0;">
                  <thead>
                    <tr style="background-color: #f4f4f4;">
                      <th style="padding: 10px; text-align: left;">Product</th>
                      <th style="padding: 10px; text-align: center;">Qty</th>
                      <th style="padding: 10px; text-align: right;">Price</th>
                    </tr>
                  </thead>
                  <tbody>
                    $itemsHtml
                  </tbody>
                </table>

                <div style="text-align: right; margin: 20px 0;">
                  <p style="font-size: 18px;"><strong>Total: \$${totalAmount.toStringAsFixed(2)}</strong></p>
                </div>

                <p>We're working hard to process your order. You will receive another notification once your order is shipped.</p>
                
                <p style="text-align: center; margin: 30px 0;">
                  <a href="#" style="background-color: #D4AF37; color: white; padding: 12px 30px; text-decoration: none; border-radius: 5px;">Track Order</a>
                </p>

                <p>If you have any questions or concerns, please don't hesitate to contact our support team.</p>
                
                <p>Best regards,<br/>The LUXE TIME Team</p>
                <hr style="margin-top: 30px; border: none; border-top: 1px solid #ddd;"/>
                <p style="font-size: 12px; color: #999; text-align: center;">
                  © 2026 LUXE TIME. All rights reserved.
                </p>
              </div>
            </body>
          </html>
        ''';

      await send(message, _smtpServer!);
      if (kDebugMode) {
        _logger.d('Order reminder email sent successfully to $toEmail');
      }
      return true;
    } catch (e) {
      if (kDebugMode) {
        _logger.d('Error sending order reminder email: $e');
      }
      return false;
    }
  }

  // SEND PURCHASE CONFIRMATION EMAIL
  static Future<bool> sendPurchaseConfirmationEmail({
    required String toEmail,
    required String userName,
    required String orderNumber,
    required List<Map<String, dynamic>> items,
    required double totalAmount,
    required String shippingAddress,
  }) async {
    if (_smtpServer == null) {
      if (kDebugMode) {
        print(
          'Email service not configured. Purchase confirmation email not sent.',
        );
      }
      return false;
    }

    try {
      // Build items list HTML
      String itemsHtml = '';
      for (var item in items) {
        itemsHtml +=
            '''
          <tr>
            <td style="padding: 10px; border-bottom: 1px solid #ddd;">${item['name']}</td>
            <td style="padding: 10px; border-bottom: 1px solid #ddd; text-align: center;">${item['quantity']}</td>
            <td style="padding: 10px; border-bottom: 1px solid #ddd; text-align: right;">\$${item['price'].toStringAsFixed(2)}</td>
          </tr>
        ''';
      }

      final message = Message()
        ..from = Address(_smtpUsername, 'LUXE TIME')
        ..recipients.add(toEmail)
        ..subject = 'Order Confirmation - #$orderNumber'
        ..html =
            '''
          <html>
            <body style="font-family: Arial, sans-serif; background-color: #f4f4f4; padding: 20px;">
              <div style="max-width: 600px; margin: 0 auto; background-color: white; padding: 30px; border-radius: 10px;">
                <h1 style="color: #D4AF37; text-align: center;">Order Confirmed!</h1>
                <p>Dear $userName,</p>
                <p>Thank you for your purchase! Your order has been confirmed and is being processed.</p>
                
                <div style="background-color: #f9f9f9; padding: 20px; border-radius: 5px; margin: 20px 0;">
                  <h2 style="color: #333; margin-top: 0;">Order Details</h2>
                  <p><strong>Order Number:</strong> #$orderNumber</p>
                  <p><strong>Order Date:</strong> ${DateTime.now().toString().split(' ')[0]}</p>
                </div>

                <h2 style="color: #333;">Items Ordered</h2>
                <table style="width: 100%; border-collapse: collapse; margin: 20px 0;">
                  <thead>
                    <tr style="background-color: #f4f4f4;">
                      <th style="padding: 10px; text-align: left;">Product</th>
                      <th style="padding: 10px; text-align: center;">Qty</th>
                      <th style="padding: 10px; text-align: right;">Price</th>
                    </tr>
                  </thead>
                  <tbody>
                    $itemsHtml
                  </tbody>
                </table>

                <div style="text-align: right; margin: 20px 0;">
                  <p style="font-size: 18px;"><strong>Total: \$${totalAmount.toStringAsFixed(2)}</strong></p>
                </div>

                <div style="background-color: #f9f9f9; padding: 20px; border-radius: 5px; margin: 20px 0;">
                  <h3 style="color: #333; margin-top: 0;">Shipping Address</h3>
                  <p>$shippingAddress</p>
                </div>

                <p>You will receive a shipping confirmation email with tracking details once your order is dispatched.</p>
                
                <p style="text-align: center; margin: 30px 0;">
                  <a href="#" style="background-color: #D4AF37; color: white; padding: 12px 30px; text-decoration: none; border-radius: 5px;">Track Order</a>
                </p>

                <p>Best regards,<br/>The LUXE TIME Team</p>
                <hr style="margin-top: 30px; border: none; border-top: 1px solid #ddd;"/>
                <p style="font-size: 12px; color: #999; text-align: center;">
                  © 2026 LUXE TIME. All rights reserved.
                </p>
              </div>
            </body>
          </html>
        ''';

      await send(message, _smtpServer!);
      if (kDebugMode) {
        _logger.d('Error: ');
      }
      return true;
    } catch (e) {
      if (kDebugMode) {
        _logger.d('Error: ');
      }
      return false;
    }
  }
}
