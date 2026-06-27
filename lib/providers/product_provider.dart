import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logger/logger.dart';
import '../models/watch.dart';
import '../services/firebase_data_service.dart';
import '../services/dynamic_config_service.dart';

class ProductProvider with ChangeNotifier {
  List<Watch> _watches = [];
  List<Watch> _filteredWatches = [];
  String _selectedBrand = 'All';
  String _selectedCategory = 'All';
  String _searchQuery = '';
  bool _isLoading = false;
  bool _hasError = false;
  String _errorMessage = '';
  StreamSubscription<QuerySnapshot>? _watchesSubscription;
  final FirebaseDataService _firebaseDataService = FirebaseDataService();
  final DynamicConfigService _configService = DynamicConfigService();
  final Logger _logger = Logger();

  List<Watch> get watches => _filteredWatches;
  List<Watch> get allWatches => _watches;
  String get selectedBrand => _selectedBrand;
  String get selectedCategory => _selectedCategory;
  bool get isLoading => _isLoading;
  bool get hasError => _hasError;
  String get errorMessage => _errorMessage;

  List<String> get brands => _configService.dynamicBrands
      .map((brand) => brand['name'] as String)
      .toList();

  List<String> get categories => _configService.dynamicCategories
      .map((category) => category['name'] as String)
      .toList();

  // Initialize real-time data sync
  void initializeRealtimeSync() {
    _isLoading = true;
    notifyListeners();

    try {
      // Subscribe to Firestore real-time updates
      _watchesSubscription = FirebaseFirestore.instance
          .collection('products')
          .snapshots()
          .listen(
            (snapshot) {
              if (snapshot.docs.isEmpty) {
                _logger.d('No products in Firestore, using sample data');
                _loadSampleData();
                return;
              }

              _watches = snapshot.docs.map((doc) {
                final data = doc.data();
                final watchData = data['watch'];
                return Watch.fromJson({...watchData, 'id': doc.id});
              }).toList();

              _applyFilters();
              _isLoading = false;
              _hasError = false;
              notifyListeners();
            },
            onError: (error) {
              _logger.d('Real-time sync error: $error');
              _hasError = true;
              _errorMessage = 'Failed to load products: $error';
              _isLoading = false;
              _loadSampleData(); // Fallback to sample data
            },
          );
    } catch (e) {
      _logger.d('Error initializing real-time sync: $e');
      _hasError = true;
      _errorMessage = 'Failed to connect to database';
      _isLoading = false;
      _loadSampleData();
    }
  }

  // Load products from Firebase with fallback to local data (legacy method)
  Future<void> loadProducts() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Try to load from Firebase first
      final firebaseWatches = await _firebaseDataService.getAllWatches();

      if (firebaseWatches.isNotEmpty) {
        _watches = firebaseWatches;
      } else {
        // Fallback to sample data if Firebase is empty
        _loadSampleData();
      }
    } catch (e) {
      _logger.d('Error loading products: $e');
      // Fallback to sample data
      _loadSampleData();
    }

    _applyFilters();
    _isLoading = false;
    notifyListeners();
  }

  // Refresh data manually
  Future<void> refreshProducts() async {
    _isLoading = true;
    _errorMessage = '';
    _hasError = false;
    notifyListeners();

    try {
      final firebaseWatches = await _firebaseDataService.getAllWatches();
      if (firebaseWatches.isNotEmpty) {
        _watches = firebaseWatches;
      } else {
        _loadSampleData();
      }
      _applyFilters();
    } catch (e) {
      _logger.d('Error refreshing products: $e');
      _hasError = true;
      _errorMessage = 'Failed to refresh: $e';
    }

    _isLoading = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _watchesSubscription?.cancel();
    super.dispose();
  }

  void _loadSampleData() {
    _watches = [
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
        name: 'Casio Edifice Chronograph EFR-526L-1AVUDF',
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
        name: 'Fossil Grant Automatic Skeleton Dial',
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
        name: 'Minimalist Business Gold Watch',
        brand: 'Generic',
        price: 89.99,
        images: ['assets/images/watches_new/watch_05_gold_business.jpg'],
        description:
            'Elegant gold watch with brown leather band, minimalist business style.',
        specs: {
          'Movement': 'Quartz',
          'Strap Material': 'Leather',
          'Case Size': '42mm',
          'Water Resistance': '30m',
        },
        category: 'Dress',
        isNew: false,
        style: 'formal',
        caseSize: 42.0,
        colors: ['gold', 'brown'],
      ),
      Watch(
        id: '6',
        name: 'Luxury Galaxy Dial Chronograph',
        brand: 'Generic',
        price: 159.99,
        images: ['assets/images/watches_new/watch_06_galaxy_chronograph.jpg'],
        description:
            'Luxury galaxy dial watch with stainless steel chronograph design.',
        specs: {
          'Movement': 'Quartz Chronograph',
          'Strap Material': 'Stainless Steel',
          'Case Size': '45mm',
          'Water Resistance': '50m',
        },
        category: 'Chronograph',
        isNew: true,
        style: 'luxury',
        caseSize: 45.0,
        colors: ['black', 'silver', 'blue'],
      ),
      Watch(
        id: '7',
        name: 'Luxury Skeleton Black & Gold Automatic',
        brand: 'Generic',
        price: 199.99,
        images: ['assets/images/watches_new/watch_07_skeleton_black_gold.jpg'],
        description:
            'Stunning luxury skeleton watch with black and gold automatic timepiece design.',
        specs: {
          'Movement': 'Automatic Skeleton',
          'Strap Material': 'Stainless Steel',
          'Case Size': '43mm',
          'Water Resistance': '30m',
        },
        category: 'Automatic',
        isNew: true,
        style: 'luxury',
        caseSize: 43.0,
        colors: ['black', 'gold'],
      ),
      Watch(
        id: '8',
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
        id: '9',
        name: 'OLEVS Automatic Mechanical Waterproof',
        brand: 'OLEVS',
        price: 119.99,
        images: ['assets/images/watches_new/watch_09_olevs_automatic.jpg'],
        description:
            'OLEVS luxury automatic mechanical waterproof watch with date and leather strap.',
        specs: {
          'Movement': 'Automatic Mechanical',
          'Strap Material': 'Leather',
          'Case Size': '42mm',
          'Water Resistance': '30m',
        },
        category: 'Automatic',
        isNew: false,
        style: 'classic',
        caseSize: 42.0,
        colors: ['brown', 'silver'],
      ),
      Watch(
        id: '10',
        name: 'LIGE LED + Analog Premium Watch',
        brand: 'LIGE',
        price: 69.99,
        images: ['assets/images/watches_new/watch_10_lige_led.jpg'],
        description:
            'LIGE masculine LED + Analog watch with premium waterproof style.',
        specs: {
          'Display': 'LED + Analog',
          'Strap Material': 'Stainless Steel',
          'Case Size': '44mm',
          'Water Resistance': '30m',
        },
        category: 'Smart Watches',
        isNew: false,
        style: 'sport',
        caseSize: 44.0,
        colors: ['black', 'silver'],
      ),
      Watch(
        id: '12',
        name: 'Stylish Chronograph Business Casual',
        brand: 'Generic',
        price: 139.99,
        images: ['assets/images/watches_new/watch_12_chronograph_business.jpg'],
        description:
            'Stylish chronograph watch with black and brown leather for business casual.',
        specs: {
          'Movement': 'Quartz Chronograph',
          'Strap Material': 'Leather',
          'Case Size': '43mm',
          'Water Resistance': '30m',
        },
        category: 'Chronograph',
        isNew: false,
        style: 'business',
        caseSize: 43.0,
        colors: ['black', 'brown'],
      ),
      Watch(
        id: '13',
        name: 'Grey Smartwatch Fitness Tracker',
        brand: 'Generic',
        price: 49.99,
        images: ['assets/images/watches_new/watch_13_grey_smartwatch.jpg'],
        description:
            'Stylish grey smartwatch with fitness tracker, steps counter, and modern design.',
        specs: {
          'Display': 'LCD Touchscreen',
          'Battery': '7 days',
          'Features': 'Steps, Time, Fitness',
          'Water Resistance': 'IP67',
        },
        category: 'Smart Watches',
        isNew: false,
        style: 'casual',
        caseSize: 40.0,
        colors: ['grey', 'black'],
      ),
      Watch(
        id: '14',
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
      Watch(
        id: '15',
        name: 'boAt Smartwatch for Men & Women',
        brand: 'boAt',
        price: 69.99,
        images: ['assets/images/watches_new/watch_15_boat_smartwatch.jpg'],
        description: 'boAt stylish fitness smart watch for men and women.',
        specs: {
          'Display': '1.69" HD',
          'Battery': '7 days',
          'Features': 'Fitness Tracking, Heart Rate',
          'Water Resistance': 'IP68',
        },
        category: 'Smart Watches',
        isNew: true,
        style: 'sport',
        caseSize: 41.0,
        colors: ['black', 'blue', 'pink'],
      ),
      Watch(
        id: '16',
        name: 'Premium Watch Advertisement',
        brand: 'Premium Collection',
        price: 299.99,
        images: ['assets/images/watches_new/watch_16_premium_ad.jpg'],
        description:
            'Exclusive premium watch collection - luxury timepieces for distinguished individuals.',
        specs: {
          'Movement': 'Swiss Automatic',
          'Strap Material': 'Genuine Leather',
          'Case Size': '42mm',
          'Water Resistance': '50m',
        },
        category: 'Dress',
        isNew: true,
        style: 'luxury',
        caseSize: 42.0,
        colors: ['gold', 'silver', 'black'],
      ),
    ];

    _applyFilters();
    _isLoading = false;
    notifyListeners();
  }

  void filterByBrand(String brand) {
    _selectedBrand = brand;
    _applyFilters();
    notifyListeners();
  }

  void filterByCategory(String category) {
    _selectedCategory = category;
    _applyFilters();
    notifyListeners();
  }

  void applyInitialFilter(String filter) {
    if (categories.contains(filter)) {
      _selectedCategory = filter;
      _selectedBrand = 'All';
    } else if (brands.contains(filter)) {
      _selectedBrand = filter;
      _selectedCategory = 'All';
    } else {
      _selectedBrand = 'All';
      _selectedCategory = 'All';
    }
    _applyFilters();
    notifyListeners();
  }

  void resetFilters() {
    _selectedBrand = 'All';
    _selectedCategory = 'All';
    _searchQuery = '';
    _applyFilters();
    notifyListeners();
  }

  void searchProducts(String query) {
    _searchQuery = query.toLowerCase();
    _applyFilters();
    notifyListeners();
  }

  void _applyFilters() {
    _filteredWatches = _watches.where((watch) {
      final matchesBrand =
          _selectedBrand == 'All' || watch.brand == _selectedBrand;
      final matchesCategory =
          _selectedCategory == 'All' || watch.category == _selectedCategory;
      final matchesSearch =
          _searchQuery.isEmpty ||
          watch.name.toLowerCase().contains(_searchQuery) ||
          watch.brand.toLowerCase().contains(_searchQuery) ||
          watch.category.toLowerCase().contains(_searchQuery);
      return matchesBrand && matchesCategory && matchesSearch;
    }).toList();
  }

  List<Watch> getNewArrivals() {
    return _watches.where((watch) => watch.isNew).toList();
  }

  Watch? getWatchById(String id) {
    try {
      return _watches.firstWhere((watch) => watch.id == id);
    } catch (e) {
      return null;
    }
  }
}
