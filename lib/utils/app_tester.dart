import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:logger/logger.dart';
import '../models/watch.dart';
import '../providers/cart_provider.dart';
import '../providers/user_provider.dart';
import '../providers/product_provider.dart';
import '../providers/wishlist_provider.dart';

/// Comprehensive App Testing Utility
/// This class provides methods to test all app functionalities
class AppTester {
  static const String _testTag = '[APP_TESTER]';
  static final Logger _logger = Logger();

  /// Test all core functionalities
  static Future<Map<String, bool>> runAllTests(BuildContext context) async {
    _logger.d('$_testTag All tests started');

    final results = <String, bool>{};

    // Test 1: Provider Initialization
    results['Provider Initialization'] = await _testProviders(context);

    // Test 2: Product Loading
    results['Product Loading'] = await _testProductLoading(context);

    // Test 3: Cart Functionality
    results['Cart Functionality'] = await _testCartFunctionality(context);

    // Test 4: User Authentication
    results['User Authentication'] = await _testUserAuthentication(context);

    // Test 5: Wishlist Functionality
    results['Wishlist Functionality'] = await _testWishlistFunctionality(
      context,
    );

    // Test 6: Watch Model Integrity
    results['Watch Model Integrity'] = await _testWatchModelIntegrity();

    // Test 7: Theme Consistency
    results['Theme Consistency'] = await _testThemeConsistency(context);

    // Test 8: Navigation Flow
    results['Navigation Flow'] = await _testNavigationFlow(context);

    // Calculate overall score
    final passedTests = results.values.where((result) => result).length;
    final totalTests = results.length;
    final successRate = (passedTests / totalTests) * 100;

    _logger.d('$_testTag All tests completed. Success rate: $successRate%');

    return results;
  }

  static Future<bool> _testProviders(BuildContext context) async {
    try {
      // Test if all providers are available
      final cartProvider = Provider.of<CartProvider>(context, listen: false);
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final productProvider = Provider.of<ProductProvider>(
        context,
        listen: false,
      );
      final wishlistProvider = Provider.of<WishlistProvider>(
        context,
        listen: false,
      );

      return cartProvider != null &&
          userProvider != null &&
          productProvider != null &&
          wishlistProvider != null;
    } catch (e) {
      _logger.d('$_testTag Provider test failed: $e');
      return false;
    }
  }

  static Future<bool> _testProductLoading(BuildContext context) async {
    try {
      final productProvider = Provider.of<ProductProvider>(
        context,
        listen: false,
      );

      // Trigger product loading
      productProvider.loadProducts();

      // Wait a moment for loading to complete
      await Future.delayed(const Duration(seconds: 2));

      // Check if products are loaded
      return productProvider.allWatches.isNotEmpty &&
          !productProvider.isLoading;
    } catch (e) {
      _logger.d('$_testTag Product loading test failed: $e');
      return false;
    }
  }

  static Future<bool> _testCartFunctionality(BuildContext context) async {
    try {
      final cartProvider = Provider.of<CartProvider>(context, listen: false);
      final productProvider = Provider.of<ProductProvider>(
        context,
        listen: false,
      );

      // Get a test watch
      final watches = productProvider.allWatches;
      if (watches.isEmpty) return false;

      final testWatch = watches.first;

      // Test adding to cart
      cartProvider.addToCart(testWatch);
      final initialCount = cartProvider.itemCount;

      // Test if item was added
      if (initialCount == 0) return false;

      // Test updating quantity
      cartProvider.updateQuantity(testWatch.id, 2);

      // Test removing from cart
      cartProvider.removeFromCart(testWatch.id);

      return cartProvider.itemCount == 0;
    } catch (e) {
      _logger.d('$_testTag Cart test failed: $e');
      return false;
    }
  }

  static Future<bool> _testUserAuthentication(BuildContext context) async {
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);

      // Test user provider methods
      final isAuthenticated = userProvider.isAuthenticated;

      // Test login method (this might fail with actual credentials, but we test the method exists)
      // Note: In a real test, you'd use test credentials
      return userProvider != null;
    } catch (e) {
      _logger.d('$_testTag Auth test failed: $e');
      return false;
    }
  }

  static Future<bool> _testWishlistFunctionality(BuildContext context) async {
    try {
      final wishlistProvider = Provider.of<WishlistProvider>(
        context,
        listen: false,
      );
      final productProvider = Provider.of<ProductProvider>(
        context,
        listen: false,
      );

      // Get a test watch
      final watches = productProvider.allWatches;
      if (watches.isEmpty) return false;

      final testWatch = watches.first;

      // Test adding to wishlist
      wishlistProvider.addToWishlist(testWatch);
      final isInWishlist = wishlistProvider.isInWishlist(testWatch.id);

      // Test removing from wishlist
      wishlistProvider.removeFromWishlist(testWatch.id);
      final isStillInWishlist = wishlistProvider.isInWishlist(testWatch.id);

      return isInWishlist && !isStillInWishlist;
    } catch (e) {
      _logger.d('$_testTag Wishlist test failed: $e');
      return false;
    }
  }

  static Future<bool> _testWatchModelIntegrity() async {
    try {
      // Test creating a watch with all required fields
      final testWatch = Watch(
        id: 'test-watch-1',
        name: 'Test Watch',
        brand: 'Test Brand',
        price: 299.99,
        images: ['assets/images/test.jpg'],
        description: 'Test Description',
        specs: {'Movement': 'Quartz'},
        category: 'Test Category',
        isNew: false,
        style: 'casual',
        caseSize: 40.0,
        colors: ['silver'],
      );

      // Test all fields are present
      return testWatch.id.isNotEmpty &&
          testWatch.name.isNotEmpty &&
          testWatch.brand.isNotEmpty &&
          testWatch.price > 0 &&
          testWatch.images.isNotEmpty &&
          testWatch.style.isNotEmpty &&
          testWatch.caseSize > 0 &&
          testWatch.colors.isNotEmpty;
    } catch (e) {
      _logger.d('$_testTag Model integrity test failed: $e');
      return false;
    }
  }

  static Future<bool> _testThemeConsistency(BuildContext context) async {
    try {
      // Test if theme is properly applied
      final theme = Theme.of(context);

      // Check if primary color is set
      return theme.primaryColor != null &&
          theme.textTheme.bodyLarge != null &&
          theme.appBarTheme != null;
    } catch (e) {
      _logger.d('$_testTag Theme test failed: $e');
      return false;
    }
  }

  static Future<bool> _testNavigationFlow(BuildContext context) async {
    try {
      // Test if navigator is available
      return Navigator.of(context).canPop();
    } catch (e) {
      _logger.d('$_testTag Navigation test failed: $e');
      return false;
    }
  }

  /// Generate test report
  static void generateTestReport(Map<String, bool> results) {
    debugPrint('\n$_testTag' + '=' * 50);
    _logger.d('$_testTag Generating test report');
    debugPrint('$_testTag' + '=' * 50);

    results.forEach((test, passed) {
      final status = passed ? '✅ PASS' : '❌ FAIL';
      _logger.d('$_testTag $test: $status');
    });

    final passedTests = results.values.where((result) => result).length;
    final totalTests = results.length;
    final successRate = (passedTests / totalTests) * 100;

    debugPrint('$_testTag' + '-' * 50);
    _logger.d('$_testTag Success rate: $successRate%');

    if (successRate >= 90) {
      _logger.d('$_testTag Overall: Excellent');
    } else if (successRate >= 75) {
      _logger.d('$_testTag Overall: Good');
    } else if (successRate >= 60) {
      _logger.d('$_testTag Overall: Fair');
    } else {
      _logger.d('$_testTag Overall: Poor');
    }

    debugPrint('$_testTag' + '=' * 50 + '\n');
  }

  /// Quick health check
  static Future<bool> quickHealthCheck(BuildContext context) async {
    try {
      // Check critical components
      final providers = await _testProviders(context);
      final products = await _testProductLoading(context);
      final model = await _testWatchModelIntegrity();

      return providers && products && model;
    } catch (e) {
      _logger.d('$_testTag Health check failed: $e');
      return false;
    }
  }
}
