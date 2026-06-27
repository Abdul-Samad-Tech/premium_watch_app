import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:convert';
import 'package:logger/logger.dart';
import '../models/watch.dart';
import '../models/cart_item.dart';

class CartProvider with ChangeNotifier {
  final List<CartItem> _items = [];
  static const String _cartKey = 'cart_items';
  final Logger _logger = Logger();
  StreamSubscription<QuerySnapshot>? _cartSubscription;
  String? _userId;

  List<CartItem> get items => _items;

  double get subtotal => _items.fold(0, (sum, item) => sum + item.totalPrice);

  int get itemCount => _items.length;

  double get totalAmount => subtotal;

  bool get isLoading => _items.isEmpty && _userId != null;

  CartProvider() {
    _loadCart();
    _initializeRealtimeSync();
  }

  void _initializeRealtimeSync() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _userId = user.uid;
      _loadCartFromFirebase();
    }

    FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user != null) {
        _userId = user.uid;
        _loadCartFromFirebase();
      } else {
        _userId = null;
        _cartSubscription?.cancel();
        _loadCart(); // Load from local storage
      }
    });
  }

  void _loadCartFromFirebase() {
    if (_userId == null) return;

    _cartSubscription?.cancel();
    _cartSubscription = FirebaseFirestore.instance
        .collection('users')
        .doc(_userId)
        .collection('cart')
        .snapshots()
        .listen(
          (snapshot) {
            _items.clear();
            for (var doc in snapshot.docs) {
              final data = doc.data();
              final watchData = data['watch'] as Map<String, dynamic>;
              final watch = Watch.fromJson(watchData);
              final quantity = data['quantity'] as int? ?? 1;
              _items.add(CartItem(watch: watch, quantity: quantity));
            }
            notifyListeners();
          },
          onError: (error) {
            _logger.d('Error loading cart from Firebase: $error');
            _loadCart(); // Fallback to local storage
          },
        );
  }

  bool isInCart(String watchId) {
    return _items.any((item) => item.watch.id == watchId);
  }

  Future<void> _loadCart() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cartJson = prefs.getString(_cartKey);
      if (cartJson != null) {
        final List<dynamic> decoded = jsonDecode(cartJson);
        _items.clear();
        for (var itemData in decoded) {
          final watchMap = itemData['watch'] as Map<String, dynamic>;
          final watch = Watch.fromJson(watchMap);
          final quantity = itemData['quantity'] as int;
          _items.add(CartItem(watch: watch, quantity: quantity));
        }
        notifyListeners();
      }
    } catch (e) {
      // If loading fails, start with empty cart
      _logger.d('Error loading cart: $e');
    }
  }

  Future<void> _saveCart() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cartJson = jsonEncode(
        _items
            .map(
              (item) => {
                'watch': item.watch.toJson(),
                'quantity': item.quantity,
              },
            )
            .toList(),
      );
      await prefs.setString(_cartKey, cartJson);
    } catch (e) {
      _logger.d('Error saving cart: $e');
    }
  }

  Future<void> addToCart(Watch watch) async {
    try {
      // Add to Firebase if user is logged in
      if (_userId != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(_userId)
            .collection('cart')
            .add({
              'watch': watch.toJson(),
              'quantity': 1,
              'addedAt': FieldValue.serverTimestamp(),
            });
      } else {
        // Fallback to local storage
        _addToCartLocal(watch);
      }

      // Haptic feedback for premium feel
      HapticFeedback.lightImpact();
    } catch (e) {
      _logger.d('Error adding to cart: $e');
      _addToCartLocal(watch);
    }
  }

  void _addToCartLocal(Watch watch) {
    final existingIndex = _items.indexWhere(
      (item) => item.watch.id == watch.id,
    );

    if (existingIndex >= 0) {
      _items[existingIndex].updateQuantity(_items[existingIndex].quantity + 1);
    } else {
      _items.add(CartItem(watch: watch, quantity: 1));
    }

    HapticFeedback.lightImpact();
    _saveCart();
    notifyListeners();
  }

  Future<void> removeFromCart(String watchId) async {
    if (_userId != null) {
      // Remove from Firebase
      final cartDocs = await FirebaseFirestore.instance
          .collection('users')
          .doc(_userId)
          .collection('cart')
          .where('watch.id', isEqualTo: watchId)
          .get();

      for (var doc in cartDocs.docs) {
        await doc.reference.delete();
      }
    } else {
      // Remove from local storage
      _items.removeWhere((item) => item.watch.id == watchId);
      _saveCart();
      notifyListeners();
    }
  }

  Future<void> updateQuantity(String watchId, int quantity) async {
    if (_userId != null) {
      // Update in Firebase
      final cartDocs = await FirebaseFirestore.instance
          .collection('users')
          .doc(_userId)
          .collection('cart')
          .where('watch.id', isEqualTo: watchId)
          .get();

      if (cartDocs.docs.isNotEmpty) {
        await cartDocs.docs.first.reference.update({'quantity': quantity});
      }
    } else {
      // Update locally
      final index = _items.indexWhere((item) => item.watch.id == watchId);
      if (index >= 0 && quantity > 0) {
        _items[index].updateQuantity(quantity);
        _saveCart();
        notifyListeners();
      }
    }
  }

  Future<void> clearCart() async {
    if (_userId != null) {
      // Clear from Firebase
      final cartDocs = await FirebaseFirestore.instance
          .collection('users')
          .doc(_userId)
          .collection('cart')
          .get();

      for (var doc in cartDocs.docs) {
        await doc.reference.delete();
      }
    } else {
      // Clear locally
      _items.clear();
      _saveCart();
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _cartSubscription?.cancel();
    super.dispose();
  }
}
