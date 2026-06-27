import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:logger/logger.dart';
import '../models/watch.dart';

class FirebaseDataService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Logger _logger = Logger();

  // Collection references
  CollectionReference get _watchesCollection =>
      _firestore.collection('watches');
  CollectionReference get _usersCollection => _firestore.collection('users');
  CollectionReference get _ordersCollection => _firestore.collection('orders');
  CollectionReference get _cartCollection => _firestore.collection('cart');

  // ==================== WATCH MANAGEMENT ====================

  /// Get all watches from Firebase
  Future<List<Watch>> getAllWatches() async {
    try {
      final snapshot = await _watchesCollection.get();
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Watch.fromJson({...data, 'id': doc.id});
      }).toList();
    } catch (e) {
      _logger.d('Error: ');
      return [];
    }
  }

  /// Get watch by ID
  Future<Watch?> getWatchById(String watchId) async {
    try {
      final doc = await _watchesCollection.doc(watchId).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        return Watch.fromJson({...data, 'id': doc.id});
      }
      return null;
    } catch (e) {
      _logger.d('Error: ');
      return null;
    }
  }

  /// Add new watch (Admin only)
  Future<bool> addWatch(Watch watch) async {
    try {
      await _watchesCollection.add(watch.toJson());
      return true;
    } catch (e) {
      _logger.d('Error: ');
      return false;
    }
  }

  /// Update watch (Admin only)
  Future<bool> updateWatch(String watchId, Watch watch) async {
    try {
      await _watchesCollection.doc(watchId).update(watch.toJson());
      return true;
    } catch (e) {
      _logger.d('Error: ');
      return false;
    }
  }

  /// Delete watch (Admin only)
  Future<bool> deleteWatch(String watchId) async {
    try {
      await _watchesCollection.doc(watchId).delete();
      return true;
    } catch (e) {
      _logger.d('Error: ');
      return false;
    }
  }

  // ==================== USER MANAGEMENT ====================

  /// Get current user data
  Future<Map<String, dynamic>?> getCurrentUserData() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;

      final doc = await _usersCollection.doc(user.uid).get();
      if (doc.exists) {
        return doc.data() as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      _logger.d('Error: ');
      return null;
    }
  }

  /// Save user data
  Future<bool> saveUserData(Map<String, dynamic> userData) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      await _usersCollection.doc(user.uid).set({
        ...userData,
        'uid': user.uid,
        'email': user.email,
        'lastUpdated': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      _logger.d('Error: ');
      return false;
    }
  }

  /// Update user data
  Future<bool> updateUserData(Map<String, dynamic> userData) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      await _usersCollection.doc(user.uid).update({
        ...userData,
        'lastUpdated': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      _logger.d('Error: ');
      return false;
    }
  }

  // ==================== CART MANAGEMENT ====================

  /// Get user's cart
  Future<List<Map<String, dynamic>>> getUserCart() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return [];

      final snapshot = await _cartCollection
          .where('userId', isEqualTo: user.uid)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {...data, 'cartItemId': doc.id};
      }).toList();
    } catch (e) {
      _logger.d('Error: ');
      return [];
    }
  }

  /// Add item to cart
  Future<bool> addToCart(Watch watch, int quantity) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      // Check if item already exists in cart
      final existingItems = await _cartCollection
          .where('userId', isEqualTo: user.uid)
          .where('watchId', isEqualTo: watch.id)
          .get();

      if (existingItems.docs.isNotEmpty) {
        // Update quantity
        final doc = existingItems.docs.first;
        final currentQuantity = doc.get('quantity') ?? 1;
        await _cartCollection.doc(doc.id).update({
          'quantity': currentQuantity + quantity,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      } else {
        // Add new item
        await _cartCollection.add({
          'userId': user.uid,
          'watchId': watch.id,
          'watch': watch.toJson(),
          'quantity': quantity,
          'addedAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
      return true;
    } catch (e) {
      _logger.d('Error: ');
      return false;
    }
  }

  /// Update cart item quantity
  Future<bool> updateCartItemQuantity(String cartItemId, int quantity) async {
    try {
      await _cartCollection.doc(cartItemId).update({
        'quantity': quantity,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      _logger.d('Error: ');
      return false;
    }
  }

  /// Remove item from cart
  Future<bool> removeFromCart(String cartItemId) async {
    try {
      await _cartCollection.doc(cartItemId).delete();
      return true;
    } catch (e) {
      _logger.d('Error: ');
      return false;
    }
  }

  /// Clear entire cart
  Future<bool> clearCart() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      final cartItems = await _cartCollection
          .where('userId', isEqualTo: user.uid)
          .get();

      for (final doc in cartItems.docs) {
        await doc.reference.delete();
      }
      return true;
    } catch (e) {
      _logger.d('Error: ');
      return false;
    }
  }

  // ==================== ORDER MANAGEMENT ====================

  /// Create order from cart
  Future<String?> createOrder(Map<String, dynamic> orderData) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;

      final orderRef = await _ordersCollection.add({
        ...orderData,
        'userId': user.uid,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Clear cart after order creation
      await clearCart();

      return orderRef.id;
    } catch (e) {
      _logger.d('Error: ');
      return null;
    }
  }

  /// Get user's orders
  Future<List<Map<String, dynamic>>> getUserOrders() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return [];

      final snapshot = await _ordersCollection
          .where('userId', isEqualTo: user.uid)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {...data, 'orderId': doc.id};
      }).toList();
    } catch (e) {
      _logger.d('Error: ');
      return [];
    }
  }

  // ==================== REAL-TIME STREAMS ====================

  /// Stream of all watches (for real-time updates)
  Stream<List<Watch>> getWatchesStream() {
    return _watchesCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Watch.fromJson({...data, 'id': doc.id});
      }).toList();
    });
  }

  /// Stream of user's cart (for real-time updates)
  Stream<List<Map<String, dynamic>>> getUserCartStream() {
    final user = _auth.currentUser;
    if (user == null) return Stream.value([]);

    return _cartCollection.where('userId', isEqualTo: user.uid).snapshots().map(
      (snapshot) {
        return snapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return {...data, 'cartItemId': doc.id};
        }).toList();
      },
    );
  }

  /// Stream of user's orders (for real-time updates)
  Stream<List<Map<String, dynamic>>> getUserOrdersStream() {
    final user = _auth.currentUser;
    if (user == null) return Stream.value([]);

    return _ordersCollection
        .where('userId', isEqualTo: user.uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return {...data, 'orderId': doc.id};
          }).toList();
        });
  }

  // ==================== WISHLIST MANAGEMENT ====================

  /// Add to wishlist
  Future<bool> addToWishlist(Watch watch) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      await _usersCollection
          .doc(user.uid)
          .collection('wishlist')
          .doc(watch.id)
          .set({
            'watch': watch.toJson(),
            'addedAt': FieldValue.serverTimestamp(),
          });
      return true;
    } catch (e) {
      _logger.d('Error: ');
      return false;
    }
  }

  /// Remove from wishlist
  Future<bool> removeFromWishlist(String watchId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      await _usersCollection
          .doc(user.uid)
          .collection('wishlist')
          .doc(watchId)
          .delete();
      return true;
    } catch (e) {
      _logger.d('Error: ');
      return false;
    }
  }

  /// Get user's wishlist
  Future<List<Watch>> getUserWishlist() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return [];

      final snapshot = await _usersCollection
          .doc(user.uid)
          .collection('wishlist')
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        final watchData = data['watch'];
        return Watch.fromJson({...watchData, 'id': doc.id});
      }).toList();
    } catch (e) {
      _logger.d('Error: ');
      return [];
    }
  }

  /// Check if watch is in wishlist
  Future<bool> isInWishlist(String watchId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      final doc = await _usersCollection
          .doc(user.uid)
          .collection('wishlist')
          .doc(watchId)
          .get();

      return doc.exists;
    } catch (e) {
      _logger.d('Error: ');
      return false;
    }
  }
}
