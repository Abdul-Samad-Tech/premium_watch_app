import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:logger/logger.dart';
import 'dart:typed_data';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Logger _logger = Logger();

  // Get current user UID
  String? get currentUserId => _auth.currentUser?.uid;

  // ============================================
  // PRODUCTS COLLECTION
  // ============================================

  // Stream all products (real-time)
  Stream<QuerySnapshot> productsStream() {
    return _firestore
        .collection('products')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // Get all products once
  Future<List<QueryDocumentSnapshot>> getProducts() async {
    final snapshot = await _firestore
        .collection('products')
        .orderBy('createdAt', descending: true)
        .get();
    return snapshot.docs;
  }

  // Add product with image bytes
  Future<String> addProduct({
    required Map<String, dynamic> productData,
    required List<Uint8List> imageBytes,
    required List<String> imageNames,
  }) async {
    try {
      // Upload images to Firebase Storage
      List<String> imageUrls = [];

      for (int i = 0; i < imageBytes.length; i++) {
        final String fileName =
            '${DateTime.now().millisecondsSinceEpoch}_${i}_${imageNames[i]}';
        final ref = _storage.ref().child('products/$fileName');

        await ref.putData(
          imageBytes[i],
          SettableMetadata(contentType: 'image/jpeg'),
        );

        final downloadUrl = await ref.getDownloadURL();
        imageUrls.add(downloadUrl);
      }

      // Add product data to Firestore
      productData['images'] = imageUrls;
      productData['createdAt'] = FieldValue.serverTimestamp();
      productData['updatedAt'] = FieldValue.serverTimestamp();

      final docRef = await _firestore.collection('products').add(productData);
      return docRef.id;
    } catch (e) {
      _logger.d('Error: ');
      rethrow;
    }
  }

  // Update product
  Future<void> updateProduct(
    String productId,
    Map<String, dynamic> data,
  ) async {
    data['updatedAt'] = FieldValue.serverTimestamp();
    await _firestore.collection('products').doc(productId).update(data);
  }

  // Delete product
  Future<void> deleteProduct(String productId) async {
    // Get product images
    final doc = await _firestore.collection('products').doc(productId).get();
    if (doc.exists) {
      final images = doc.data()?['images'] as List<dynamic>? ?? [];

      // Delete images from storage
      for (String imageUrl in images) {
        try {
          final ref = _storage.refFromURL(imageUrl);
          await ref.delete();
        } catch (e) {
          _logger.d('Error: ');
        }
      }
    }

    await _firestore.collection('products').doc(productId).delete();
  }

  // Get product count
  Stream<int> productsCountStream() {
    return _firestore
        .collection('products')
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  // ============================================
  // USERS COLLECTION
  // ============================================

  // Stream all users (real-time)
  Stream<QuerySnapshot> usersStream() {
    return _firestore
        .collection('users')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // Get user by ID
  Future<DocumentSnapshot> getUser(String userId) async {
    return await _firestore.collection('users').doc(userId).get();
  }

  // Get user count
  Stream<int> usersCountStream() {
    return _firestore
        .collection('users')
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  // ============================================
  // ORDERS COLLECTION
  // ============================================

  // Stream user orders (real-time)
  Stream<QuerySnapshot> userOrdersStream(String userId) {
    return _firestore
        .collection('orders')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // Add order
  Future<String> addOrder({
    required String userId,
    required List<Map<String, dynamic>> items,
    required double totalAmount,
    required Map<String, String> shippingAddress,
    required String paymentMethod,
  }) async {
    try {
      final orderData = {
        'userId': userId,
        'items': items,
        'totalAmount': totalAmount,
        'shippingAddress': shippingAddress,
        'paymentMethod': paymentMethod,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
        'orderNumber': 'LT${DateTime.now().millisecondsSinceEpoch}',
      };

      final docRef = await _firestore.collection('orders').add(orderData);
      return docRef.id;
    } catch (e) {
      _logger.d('Error: ');
      rethrow;
    }
  }

  // Get all orders (admin only)
  Stream<QuerySnapshot> allOrdersStream() {
    return _firestore
        .collection('orders')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // Get order count
  Stream<int> ordersCountStream() {
    return _firestore
        .collection('orders')
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  // Update order status
  Future<void> updateOrderStatus(String orderId, String status) async {
    await _firestore.collection('orders').doc(orderId).update({
      'status': status,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // ============================================
  // COLLECTION-BASED AUTHENTICATION (DEPRECATED)
  // ============================================
  // NOTE: Custom auth methods removed for security.
  // Use Firebase Authentication exclusively.
  // All user authentication is now handled by FirebaseAuthService.

  // ============================================
  // FIRESTORE RULES (for reference)
  // ============================================
  /*
  rules_version = '2';
  service cloud.firestore {
    match /databases/{database}/documents {
      // Products - Anyone can read, only admins can write
      match /products/{productId} {
        allow read: if true;
        allow write: if request.auth != null && 
                     get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
      }
      
      // Users - Users can read their own data, admins can read all
      match /users/{userId} {
        allow read: if request.auth != null && (request.auth.uid == userId || 
                     get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin');
        allow create: if true;
        allow update, delete: if request.auth != null && request.auth.uid == userId;
      }
      
      // Orders - Users can only see their orders, admins can see all
      match /orders/{orderId} {
        allow read: if request.auth != null && 
                     (resource.data.userId == request.auth.uid || 
                      get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin');
        allow create: if request.auth != null;
        allow update, delete: if request.auth != null && 
                               get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
      }
    }
  }
  */
}
