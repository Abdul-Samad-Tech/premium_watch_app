import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logger/logger.dart';
import 'dart:convert';

class DynamicConfigService {
  static final DynamicConfigService _instance =
      DynamicConfigService._internal();
  factory DynamicConfigService() => _instance;
  DynamicConfigService._internal();

  SharedPreferences? _prefs;
  final Logger _logger = Logger();

  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  // Dynamic app configuration
  Map<String, dynamic> get appConfig => {
    'appName': 'Premium Watch Store',
    'appVersion': '2.0.0',
    'enableFirebase': true,
    'enableCamera': !kIsWeb,
    'enableWristDetection': true,
    'enableAIAssistant': true,
    'enableVirtualTryOn': true,
    'enableRealTimeSync': true,
    'maxCartItems': 50,
    'supportedLanguages': ['en', 'ur', 'hi'],
    'defaultCurrency': 'USD',
    'enableDarkMode': true,
    'enableNotifications': true,
    'enableAnalytics': kDebugMode ? false : true,
  };

  // Dynamic brand configuration
  List<Map<String, dynamic>> get dynamicBrands => [
    {
      'name': 'Rolex',
      'displayName': 'Rolex',
      'description': 'Luxury Swiss watches',
      'logo': 'assets/brands/rolex.png',
      'featured': true,
      'category': 'Luxury',
      'priceRange': {'min': 5000, 'max': 50000},
      'popularity': 95,
    },
    {
      'name': 'Omega',
      'displayName': 'Omega',
      'description': 'Swiss luxury watches',
      'logo': 'assets/brands/omega.png',
      'featured': true,
      'category': 'Luxury',
      'priceRange': {'min': 2000, 'max': 20000},
      'popularity': 90,
    },
    {
      'name': 'Tissot',
      'displayName': 'Tissot',
      'description': 'Affordable Swiss watches',
      'logo': 'assets/brands/tissot.png',
      'featured': true,
      'category': 'Premium',
      'priceRange': {'min': 300, 'max': 2000},
      'popularity': 85,
    },
    {
      'name': 'TAG Heuer',
      'displayName': 'TAG Heuer',
      'description': 'Luxury sport watches',
      'logo': 'assets/brands/tag_heuer.png',
      'featured': true,
      'category': 'Luxury',
      'priceRange': {'min': 1500, 'max': 15000},
      'popularity': 88,
    },
    {
      'name': 'Casio',
      'displayName': 'Casio',
      'description': 'Affordable reliable watches',
      'logo': 'assets/brands/casio.png',
      'featured': true,
      'category': 'Affordable',
      'priceRange': {'min': 50, 'max': 500},
      'popularity': 92,
    },
    {
      'name': 'Fossil',
      'displayName': 'Fossil',
      'description': 'Fashion watches',
      'logo': 'assets/brands/fossil.png',
      'featured': true,
      'category': 'Fashion',
      'priceRange': {'min': 100, 'max': 800},
      'popularity': 80,
    },
    {
      'name': 'Citizen',
      'displayName': 'Citizen',
      'description': 'Eco-Drive technology',
      'logo': 'assets/brands/citizen.png',
      'featured': true,
      'category': 'Premium',
      'priceRange': {'min': 200, 'max': 1500},
      'popularity': 83,
    },
    {
      'name': 'CURREN',
      'displayName': 'CURREN',
      'description': 'Affordable luxury style',
      'logo': 'assets/brands/curren.png',
      'featured': false,
      'category': 'Affordable',
      'priceRange': {'min': 50, 'max': 200},
      'popularity': 75,
    },
    {
      'name': 'LIGE',
      'displayName': 'LIGE',
      'description': 'Modern design watches',
      'logo': 'assets/brands/lige.png',
      'featured': false,
      'category': 'Affordable',
      'priceRange': {'min': 60, 'max': 250},
      'popularity': 70,
    },
    {
      'name': 'Noise',
      'displayName': 'Noise',
      'description': 'Smart watches and fitness',
      'logo': 'assets/brands/noise.png',
      'featured': true,
      'category': 'Smart',
      'priceRange': {'min': 40, 'max': 300},
      'popularity': 78,
    },
    {
      'name': 'boAt',
      'displayName': 'boAt',
      'description': 'Smart wearables',
      'logo': 'assets/brands/boat.png',
      'featured': true,
      'category': 'Smart',
      'priceRange': {'min': 30, 'max': 200},
      'popularity': 76,
    },
    {
      'name': 'OLEVS',
      'displayName': 'OLEVS',
      'description': 'Classic timepieces',
      'logo': 'assets/brands/olevs.png',
      'featured': false,
      'category': 'Affordable',
      'priceRange': {'min': 80, 'max': 300},
      'popularity': 72,
    },
    {
      'name': 'Premium Collection',
      'displayName': 'Premium Collection',
      'description': 'Exclusive luxury watches',
      'logo': 'assets/brands/premium.png',
      'featured': true,
      'category': 'Luxury',
      'priceRange': {'min': 1000, 'max': 100000},
      'popularity': 94,
    },
    {
      'name': 'Generic',
      'displayName': 'Generic',
      'description': 'Various watch styles',
      'logo': 'assets/brands/generic.png',
      'featured': false,
      'category': 'Affordable',
      'priceRange': {'min': 20, 'max': 150},
      'popularity': 65,
    },
  ];

  // Dynamic categories configuration
  List<Map<String, dynamic>> get dynamicCategories => [
    {
      'name': 'All',
      'displayName': 'All Watches',
      'description': 'Browse all available watches',
      'icon': 'watch',
      'color': '#2196F3',
      'featured': true,
    },
    {
      'name': 'Automatic',
      'displayName': 'Automatic',
      'description': 'Self-winding mechanical watches',
      'icon': 'settings',
      'color': '#FF9800',
      'featured': true,
    },
    {
      'name': 'Chronograph',
      'displayName': 'Chronograph',
      'description': 'Watches with stopwatch function',
      'icon': 'timer',
      'color': '#4CAF50',
      'featured': true,
    },
    {
      'name': 'Smart Watches',
      'displayName': 'Smart Watches',
      'description': 'Connected smart timepieces',
      'icon': 'smartphone',
      'color': '#9C27B0',
      'featured': true,
    },
    {
      'name': 'Diver',
      'displayName': 'Diver',
      'description': 'Water-resistant diving watches',
      'icon': 'pool',
      'color': '#00BCD4',
      'featured': false,
    },
    {
      'name': 'Dress',
      'displayName': 'Dress',
      'description': 'Elegant formal watches',
      'icon': 'star',
      'color': '#F44336',
      'featured': true,
    },
  ];

  // Dynamic features configuration
  Map<String, dynamic> get dynamicFeatures => {
    'virtualTryOn': {
      'enabled': !kIsWeb,
      'name': 'Virtual Try-On',
      'description': 'See how watches look on your wrist',
      'icon': 'camera_alt',
      'requiresCamera': true,
      'supportedPlatforms': ['android', 'ios'],
    },
    'aiAssistant': {
      'enabled': true,
      'name': 'AI Assistant',
      'description': 'Get help from our AI chatbot',
      'icon': 'smart_toy',
      'requiresInternet': true,
      'supportedPlatforms': ['web', 'android', 'ios'],
    },
    'realTimeSync': {
      'enabled': true,
      'name': 'Real-time Sync',
      'description': 'Sync data across all devices',
      'icon': 'sync',
      'requiresFirebase': true,
      'supportedPlatforms': ['web', 'android', 'ios'],
    },
    'arView': {
      'enabled': false, // Future feature
      'name': 'AR View',
      'description': 'Augmented reality watch viewing',
      'icon': 'view_in_ar',
      'requiresAR': true,
      'supportedPlatforms': ['android', 'ios'],
    },
  };

  // Dynamic UI configuration
  Map<String, dynamic> get dynamicUI => {
    'theme': {
      'primaryColor': '#D4AF37',
      'secondaryColor': '#1A1A1A',
      'accentColor': '#B8941F',
      'backgroundColor': '#0A0A0A',
      'surfaceColor': '#1A1A1A',
      'textColor': '#FFFFFF',
      'textSecondaryColor': '#B0B0B0',
    },
    'typography': {
      'fontFamily': 'Inter',
      'headingFont': 'Playfair Display',
      'fontSize': {
        'small': 12,
        'medium': 14,
        'large': 16,
        'xlarge': 18,
        'xxlarge': 24,
        'xxxlarge': 32,
      },
    },
    'layout': {
      'gridColumns': 2,
      'cardPadding': 16,
      'screenPadding': 16,
      'borderRadius': 12,
      'elevation': 4,
    },
    'animations': {
      'duration': {'fast': 200, 'medium': 300, 'slow': 500},
      'curve': 'easeInOut',
    },
  };

  // Get featured brands
  List<Map<String, dynamic>> getFeaturedBrands() {
    return dynamicBrands.where((brand) => brand['featured'] == true).toList();
  }

  // Get brands by category
  List<Map<String, dynamic>> getBrandsByCategory(String category) {
    return dynamicBrands
        .where((brand) => brand['category'] == category)
        .toList();
  }

  // Get featured categories
  List<Map<String, dynamic>> getFeaturedCategories() {
    return dynamicCategories
        .where((category) => category['featured'] == true)
        .toList();
  }

  // Get enabled features
  List<Map<String, dynamic>> getEnabledFeatures() {
    final features = <Map<String, dynamic>>[];
    dynamicFeatures.forEach((key, value) {
      if (value['enabled'] == true) {
        features.add(value as Map<String, dynamic>);
      }
    });
    return features;
  }

  // Check if feature is enabled
  bool isFeatureEnabled(String featureName) {
    final feature = dynamicFeatures[featureName];
    return feature != null && feature['enabled'] == true;
  }

  // Get brand by name
  Map<String, dynamic>? getBrandByName(String name) {
    try {
      return dynamicBrands.firstWhere((brand) => brand['name'] == name);
    } catch (e) {
      return null;
    }
  }

  // Get category by name
  Map<String, dynamic>? getCategoryByName(String name) {
    try {
      return dynamicCategories.firstWhere(
        (category) => category['name'] == name,
      );
    } catch (e) {
      return null;
    }
  }

  // Save user preferences
  Future<void> saveUserPreferences(Map<String, dynamic> preferences) async {
    await init();
    await _prefs!.setString('user_preferences', json.encode(preferences));
  }

  // Get user preferences
  Map<String, dynamic> getUserPreferences() {
    final prefsString = _prefs?.getString('user_preferences');
    if (prefsString != null) {
      try {
        return json.decode(prefsString) as Map<String, dynamic>;
      } catch (e) {
        return {};
      }
    }
    return {};
  }

  // Save app settings
  Future<void> saveAppSettings(Map<String, dynamic> settings) async {
    await init();
    await _prefs!.setString('app_settings', json.encode(settings));
  }

  // Get app settings
  Map<String, dynamic> getAppSettings() {
    final settingsString = _prefs?.getString('app_settings');
    if (settingsString != null) {
      try {
        return json.decode(settingsString) as Map<String, dynamic>;
      } catch (e) {
        return {};
      }
    }
    return {};
  }

  // Update configuration dynamically
  void updateConfig(String key, dynamic value) {
    // This can be used to update configuration from remote server
    if (kDebugMode) {
      _logger.d('Error: ');
    }
  }

  // Get all configuration as a single map
  Map<String, dynamic> getAllConfig() {
    return {
      'app': appConfig,
      'brands': dynamicBrands,
      'categories': dynamicCategories,
      'features': dynamicFeatures,
      'ui': dynamicUI,
      'userPreferences': getUserPreferences(),
      'appSettings': getAppSettings(),
    };
  }
}
