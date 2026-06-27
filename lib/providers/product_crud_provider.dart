import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/watch.dart';

class ProductCRUDProvider with ChangeNotifier {
  List<Watch> _products = [];
  bool _isLoading = false;

  List<Watch> get products => _products;
  bool get isLoading => _isLoading;

  ProductCRUDProvider() {
    loadProducts();
  }

  // READ: Load products from storage
  Future<void> loadProducts() async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 300));

    final prefs = await SharedPreferences.getInstance();
    final productsJson = prefs.getStringList('products');

    if (productsJson != null && productsJson.isNotEmpty) {
      _products = productsJson
          .map((json) => Watch.fromJson(jsonDecode(json)))
          .toList();
    } else {
      // Initialize with default products if none exist
      _products = _getDefaultProducts();
      await saveAllProducts();
    }

    _isLoading = false;
    notifyListeners();
  }

  // CREATE: Add new product
  Future<bool> addProduct(Watch product) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 300));

    _products.add(product);
    final success = await saveAllProducts();

    _isLoading = false;
    notifyListeners();
    return success;
  }

  // UPDATE: Edit existing product
  Future<bool> updateProduct(String productId, Watch updatedProduct) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 300));

    final index = _products.indexWhere((p) => p.id == productId);
    if (index == -1) {
      _isLoading = false;
      notifyListeners();
      return false;
    }

    _products[index] = updatedProduct.copyWith(id: productId);
    final success = await saveAllProducts();

    _isLoading = false;
    notifyListeners();
    return success;
  }

  // DELETE: Remove product
  Future<bool> deleteProduct(String productId) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 300));

    final initialLength = _products.length;
    _products.removeWhere((p) => p.id == productId);

    if (_products.length < initialLength) {
      final success = await saveAllProducts();
      _isLoading = false;
      notifyListeners();
      return success;
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  // Save all products to storage
  Future<bool> saveAllProducts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final productsJson = _products
          .map((product) => jsonEncode(product.toJson()))
          .toList();
      await prefs.setStringList('products', productsJson);
      return true;
    } catch (e) {
      return false;
    }
  }

  // Get product by ID
  Watch? getProductById(String id) {
    try {
      return _products.firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
    }
  }

  // Get default products
  List<Watch> _getDefaultProducts() {
    return [
      Watch(
        id: '1',
        name: 'Quartz Wrist Watch with PU Leather Strap',
        brand: 'Generic',
        price: 45.99,
        images: ['assets/images/watches_new/watch_01_quartz_leather.jpg'],
        description:
            'Fashionable quartz wrist watch with PU leather strap, perfect gift for students.',
        specs: {
          'Movement': 'Quartz',
          'Strap Material': 'PU Leather',
          'Case Size': '40mm',
          'Water Resistance': '30m',
        },
        category: 'Dress',
        isNew: true,
        style: 'casual',
        caseSize: 40.0,
        colors: ['brown', 'silver'],
      ),
      Watch(
        id: '2',
        name: 'Casio Edifice Chronograph',
        brand: 'Casio',
        price: 129.99,
        images: ['assets/images/watches_new/watch_02_casio_edifice.jpg'],
        description:
            'Casio Edifice chronograph with black dial and leather strap sport watch.',
        specs: {
          'Movement': 'Quartz Chronograph',
          'Strap Material': 'Leather',
          'Case Size': '44mm',
          'Water Resistance': '100m',
        },
        category: 'Chronograph',
        isNew: true,
        style: 'sport',
        caseSize: 44.0,
        colors: ['black', 'silver'],
      ),
      Watch(
        id: '3',
        name: 'Citizen Eco-Drive Chronograph',
        brand: 'Citizen',
        price: 295.00,
        images: ['assets/images/watches_new/watch_03_citizen_ecodrive.jpg'],
        description:
            'Premium Citizen Eco-Drive chronograph with black dial, powered by light.',
        specs: {
          'Movement': 'Eco-Drive Quartz',
          'Strap Material': 'Stainless Steel',
          'Case Size': '43mm',
          'Water Resistance': '100m',
        },
        category: 'Chronograph',
        isNew: true,
        style: 'luxury',
        caseSize: 43.0,
        colors: ['black', 'silver'],
      ),
      Watch(
        id: '4',
        name: 'Fossil Grant Automatic',
        brand: 'Fossil',
        price: 185.00,
        images: ['assets/images/watches_new/watch_04_fossil_grant.jpg'],
        description:
            'Classic Fossil Grant automatic skeleton dial watch with brown leather strap.',
        specs: {
          'Movement': 'Automatic',
          'Strap Material': 'Leather',
          'Case Size': '44mm',
          'Water Resistance': '50m',
        },
        category: 'Automatic',
        isNew: false,
        style: 'classic',
        caseSize: 44.0,
        colors: ['brown', 'silver'],
      ),
      Watch(
        id: '5',
        name: 'Noise ColorFit Icon 4 Smartwatch',
        brand: 'Noise',
        price: 79.99,
        images: ['assets/images/watches_new/watch_08_noise_colorfit.jpg'],
        description:
            'Noise ColorFit Icon 4 with 1.96" AMOLED display and Bluetooth calling.',
        specs: {
          'Display': '1.96" AMOLED',
          'Battery': '7 days',
          'Features': 'BT Calling, Heart Rate',
          'Water Resistance': '50m',
        },
        category: 'Smart Watches',
        isNew: true,
        style: 'sport',
        caseSize: 42.0,
        colors: ['black', 'blue'],
      ),
      Watch(
        id: '6',
        name: 'CURREN 8355 Luxury Sport Watch',
        brand: 'CURREN',
        price: 89.99,
        images: ['assets/images/watches_new/watch_14_curren_sport.jpg'],
        description:
            'CURREN 8355 luxury sport watch with chronograph and auto date.',
        specs: {
          'Movement': 'Quartz Chronograph',
          'Strap Material': 'Stainless Steel',
          'Case Size': '45mm',
          'Water Resistance': '30m',
        },
        category: 'Chronograph',
        isNew: true,
        style: 'sport',
        caseSize: 45.0,
        colors: ['black', 'silver', 'blue'],
      ),
    ];
  }
}
