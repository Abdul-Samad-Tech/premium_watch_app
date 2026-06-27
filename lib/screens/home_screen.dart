import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import '../core/constants/colors.dart';
import '../core/constants/strings.dart';
import '../providers/product_provider.dart';
import '../providers/cart_provider.dart';
import '../providers/user_provider.dart';
import '../widgets/watch_card.dart';
import '../widgets/shimmer_loader.dart';
import '../widgets/premium_hero_section.dart';
import '../widgets/full_screen_video_background.dart';
import '../services/dynamic_config_service.dart';
import '../models/watch.dart';
import 'cart_screen.dart';
import 'watch_gallery_screen.dart';
import 'try_on_wrist_camera_screen.dart';
import 'user_panel_screen.dart';
import 'admin_panel_screen.dart';
import 'chatbot_screen.dart';
import '../widgets/premium_app_bar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final CarouselSliderController _carouselController =
      CarouselSliderController();
  final PageController _pageController = PageController();
  final TextEditingController _searchController = TextEditingController();
  int _carouselIndex = 0;
  VideoPlayerController? _videoController;
  bool _isVideoInitialized = false;
  late AnimationController _gradientAnimationController;
  late Animation<double> _gradientAnimation;
  int _currentIndex = 0; // For bottom navigation
  final DynamicConfigService _configService = DynamicConfigService();
  Watch? _selectedWatch; // Store currently selected watch
  final Logger _logger = Logger();

  @override
  void initState() {
    super.initState();
    // Initialize dynamic config
    _configService.init();
    // Load products on init with real-time sync
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final productProvider = context.read<ProductProvider>();
      productProvider.initializeRealtimeSync();
    });
    // Initialize video (optional - will gracefully fallback if video doesn't exist)
    _initializeVideo();
    // Initialize gradient animation for premium feel
    _gradientAnimationController = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    )..repeat(reverse: true);
    _gradientAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _gradientAnimationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  Future<void> _initializeVideo() async {
    try {
      _videoController = VideoPlayerController.asset(
        'assets/videos/Hero Section.mp4',
      );
      await _videoController!.initialize();
      // Check if video has actual content
      if (_videoController!.value.duration.inMilliseconds > 0) {
        _videoController!.setLooping(true);
        _videoController!.setVolume(0.0); // Mute for autoplay
        _videoController!.play();
        setState(() {
          _isVideoInitialized = true;
        });
      } else {
        // Empty video file, use animated gradient
        _videoController?.dispose();
        _videoController = null;
      }
    } catch (e) {
      // Video not available, will use animated gradient background
      _logger.d('Video initialization error: $e');
      _videoController?.dispose();
      _videoController = null;
    }
  }

  @override
  void dispose() {
    _gradientAnimationController.dispose();
    _videoController?.dispose();
    _pageController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(90),
        child: Consumer<CartProvider>(
          builder: (context, cartProvider, child) {
            return PremiumAppBar(
              onCartTap: () {
                setState(() {
                  _currentIndex = 2; // Navigate to cart tab
                });
              },
              cartItemCount: cartProvider.items.length,
            );
          },
        ),
      ),
      body: FullScreenVideoBackground(
        videoPath: 'assets/videos/background-app.webm',
        child: Consumer<ProductProvider>(
          builder: (context, productProvider, child) {
            if (productProvider.isLoading) {
              return _buildLoadingState();
            }

            return _getScreenByIndex(_currentIndex, productProvider);
          },
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        selectedItemColor: AppColors.accent,
        unselectedItemColor: Colors.white70,
        backgroundColor: Colors.black87,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.category),
            label: 'Categories',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Cart',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ChatbotScreen()),
          );
        },
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.smart_toy, color: Colors.white),
        label: Text(
          'AI Assistant',
          style: GoogleFonts.inter(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _getScreenByIndex(int index, ProductProvider productProvider) {
    switch (index) {
      case 0:
        return _buildHomeContent(productProvider);
      case 1:
        return _buildCategoriesScreen(productProvider);
      case 2:
        return const CartScreen();
      case 3:
        return _buildProfileScreen();
      default:
        return _buildHomeContent(productProvider);
    }
  }

  Widget _buildHomeContent(ProductProvider productProvider) {
    // Show error state if there's an error
    if (productProvider.hasError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 64),
              const SizedBox(height: 16),
              Text(
                'Unable to load products',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                productProvider.errorMessage,
                style: GoogleFonts.inter(fontSize: 14, color: Colors.white70),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  productProvider.refreshProducts();
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Show loading state
    if (productProvider.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.accent),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await productProvider.refreshProducts();
      },
      child: CustomScrollView(
        slivers: [
          // Search Bar
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              color: Colors.transparent,
              child: TextField(
                controller: _searchController,
                onChanged: (value) {
                  productProvider.searchProducts(value);
                },
                decoration: InputDecoration(
                  hintText: 'Search watches...',
                  hintStyle: GoogleFonts.inter(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                  prefixIcon: const Icon(Icons.search, color: Colors.white70),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, color: Colors.white70),
                          onPressed: () {
                            _searchController.clear();
                            productProvider.searchProducts('');
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: Colors.transparent,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Colors.white30,
                      width: 1,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Colors.white30,
                      width: 1,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: AppColors.accent,
                      width: 1.5,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 16)),

          const SliverToBoxAdapter(child: SizedBox(height: 24)),

          // Premium Hero Section with Video & Glassmorphism Carousel
          SliverToBoxAdapter(
            child: PremiumHeroSection(
              videoController: _videoController,
              isVideoInitialized: _isVideoInitialized,
              gradientAnimation: _gradientAnimation,
              onWatchSelected: (selectedWatch) {
                // Store selected watch for Try Now button
                _selectedWatch = selectedWatch;
              },
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 24)),

          // View All Gallery Button
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const WatchGalleryScreen(),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.primary, AppColors.accent],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.accent.withValues(alpha: 0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Explore Full Collection',
                            style: GoogleFonts.playfairDisplay(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Browse ${productProvider.watches.length} premium timepieces',
                            style: GoogleFonts.inter(
                              color: Colors.white.withValues(alpha: 0.9),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          // Try Now Button
                          ElevatedButton(
                            onPressed: () {
                              // Navigate with a default watch for now
                              final defaultWatch = Watch(
                                id: '1',
                                name: 'Quartz Classic',
                                brand: 'GENERIC',
                                price: 45.99,
                                description: 'Classic quartz timepiece',
                                images: [
                                  'assets/images/watches_new/watch_01_quartz_leather.jpg',
                                ],
                                specs: {
                                  'case': 'Leather',
                                  'movement': 'Quartz',
                                },
                                category: 'Casual',
                                isNew: true,
                                style: 'casual',
                                caseSize: 40.0,
                                colors: ['brown', 'black'],
                              );

                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => TryOnWristCameraScreen(
                                    watch: defaultWatch,
                                  ),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: AppColors.accent,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(
                              'Try Now',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.accent,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Explore Button
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.arrow_forward_ios,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 24)),

          // Trending Categories
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Text(
                    AppStrings.trendingCategories,
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 12)),

          SliverToBoxAdapter(
            child: SizedBox(
              height: 45,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: productProvider.categories.length,
                itemBuilder: (context, index) {
                  final category = productProvider.categories[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              WatchGalleryScreen(initialFilter: category),
                        ),
                      );
                    },
                    child: Container(
                      margin: const EdgeInsets.only(right: 10),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        category,
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 24)),

          // Product Grid
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.7,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              delegate: SliverChildBuilderDelegate((context, index) {
                final watch = productProvider.watches[index];
                return WatchCard(watch: watch, index: index);
              }, childCount: productProvider.watches.length),
            ),
          ),

          if (productProvider.watches.isEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 32,
                ),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.search_off,
                        color: Colors.white70,
                        size: 38,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'No timepieces match your filter',
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Try another brand or clear your search.',
                        style: GoogleFonts.inter(
                          color: Colors.white70,
                          fontSize: 13,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),

          const SliverToBoxAdapter(child: SizedBox(height: 20)),
        ],
      ),
    );
  }

  Widget _buildCategoriesScreen(ProductProvider productProvider) {
    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                'Browse Categories',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              delegate: SliverChildBuilderDelegate((context, index) {
                final category = productProvider.categories[index];
                return _CategoryCard(
                  category: category,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            WatchGalleryScreen(initialFilter: category),
                      ),
                    );
                  },
                );
              }, childCount: productProvider.categories.length),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileScreen() {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        if (userProvider.currentUser == null) {
          return const Center(
            child: Text(
              'Please login to view profile',
              style: TextStyle(color: Colors.white),
            ),
          );
        }
        return userProvider.currentUser!.isAdmin
            ? const AdminPanelScreen()
            : const UserPanelScreen();
      },
    );
  }

  Widget _buildPremiumHeroSection() {
    return Container(
      height: 400,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.accent.withValues(alpha: 0.3),
            blurRadius: 30,
            offset: const Offset(0, 15),
            spreadRadius: 2,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Video or Animated Gradient Background
            if (_isVideoInitialized && _videoController != null)
              Stack(
                children: [
                  // Video with cover fit
                  FittedBox(
                    fit: BoxFit.cover,
                    child: SizedBox(
                      width: _videoController!.value.size.width,
                      height: _videoController!.value.size.height,
                      child: VideoPlayer(_videoController!),
                    ),
                  ),
                  // Play/Pause button
                  Positioned(
                    top: 16,
                    right: 16,
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          if (_videoController!.value.isPlaying) {
                            _videoController!.pause();
                          } else {
                            _videoController!.play();
                          }
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.4),
                            width: 1.5,
                          ),
                        ),
                        child: Icon(
                          _videoController!.value.isPlaying
                              ? Icons.pause_rounded
                              : Icons.play_arrow_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ),
                  ),
                ],
              )
            else
              AnimatedBuilder(
                animation: _gradientAnimation,
                builder: (context, child) {
                  return Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color.lerp(
                            AppColors.primary,
                            AppColors.accent,
                            _gradientAnimation.value,
                          )!,
                          Color.lerp(
                            AppColors.accent,
                            const Color(0xFF1A1A1A),
                            _gradientAnimation.value,
                          )!,
                          Color.lerp(
                            const Color(0xFF1A1A1A),
                            AppColors.primary,
                            _gradientAnimation.value,
                          )!,
                        ],
                      ),
                    ),
                  );
                },
              ),
            // Premium overlay gradient
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.3),
                    Colors.black.withValues(alpha: 0.7),
                  ],
                ),
              ),
            ),
            // Decorative elements
            Positioned(
              top: 30,
              left: 30,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.2),
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Icon(
                    Icons.auto_awesome,
                    color: Colors.white.withValues(alpha: 0.6),
                    size: 40,
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 100,
              right: 40,
              child: Transform.rotate(
                angle: 0.2,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.3),
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'PREMIUM',
                    style: GoogleFonts.inter(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 2,
                    ),
                  ),
                ),
              ),
            ),
            // Content
            Positioned(
              bottom: 40,
              left: 30,
              right: 30,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.accent,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.accent.withValues(alpha: 0.5),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Text(
                      'NEW COLLECTION 2024',
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Premium Watch\nCollection',
                    style: GoogleFonts.playfairDisplay(
                      color: Colors.white,
                      fontSize: 38,
                      fontWeight: FontWeight.w700,
                      height: 1.1,
                      shadows: [
                        Shadow(
                          color: Colors.black.withValues(alpha: 0.5),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Discover our curated selection of premium timepieces',
                    style: GoogleFonts.inter(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          // Scroll to products
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accent,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 28,
                            vertical: 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 5,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Explore Now',
                              style: GoogleFonts.inter(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(Icons.arrow_forward, size: 18),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      OutlinedButton(
                        onPressed: () {
                          // Show video in fullscreen
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: BorderSide(
                            color: Colors.white.withValues(alpha: 0.8),
                            width: 1.5,
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 28,
                            vertical: 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.play_circle_outline, size: 18),
                            const SizedBox(width: 8),
                            Text(
                              'Watch Story',
                              style: GoogleFonts.inter(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturedCarousel(ProductProvider provider) {
    final newArrivals = provider.getNewArrivals();
    if (newArrivals.isEmpty) return const SizedBox.shrink();

    return Column(
      children: [
        CarouselSlider(
          carouselController: _carouselController,
          options: CarouselOptions(
            height: 200,
            autoPlay: true,
            enlargeCenterPage: true,
            viewportFraction: 0.85,
            onPageChanged: (index, reason) {
              setState(() {
                _carouselIndex = index;
              });
            },
          ),
          items: newArrivals.map((watch) {
            return Builder(
              builder: (BuildContext context) {
                return Container(
                  width: MediaQuery.of(context).size.width,
                  margin: const EdgeInsets.symmetric(horizontal: 5),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    image: DecorationImage(
                      image: NetworkImage(watch.images[0]),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.7),
                        ],
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            watch.name,
                            style: GoogleFonts.playfairDisplay(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '\$${watch.price.toStringAsFixed(2)}',
                            style: GoogleFonts.inter(
                              color: AppColors.accent,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          }).toList(),
        ),
        const SizedBox(height: 12),
        SmoothPageIndicator(
          controller: _pageController,
          count: newArrivals.length,
          effect: WormEffect(
            dotColor: Colors.grey.shade300,
            activeDotColor: AppColors.accent,
            dotHeight: 8,
            dotWidth: 8,
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingState() {
    return CustomScrollView(
      slivers: [
        const SliverAppBar(
          expandedHeight: 100,
          floating: true,
          pinned: true,
          backgroundColor: AppColors.background,
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: SizedBox(
            height: 200,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: 4,
              itemBuilder: (context, index) {
                return Container(
                  width: 100,
                  margin: const EdgeInsets.only(right: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25),
                  ),
                );
              },
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.7,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) => const WatchCardShimmer(),
              childCount: 6,
            ),
          ),
        ),
      ],
    );
  }
}

// Category Card Widget
class _CategoryCard extends StatelessWidget {
  final String category;
  final VoidCallback onTap;

  const _CategoryCard({required this.category, required this.onTap});

  @override
  Widget build(BuildContext context) {
    // Icon and Logo mapping for categories
    final Map<String, IconData> categoryIcons = {
      'All': Icons.grid_view,
      'Luxury': Icons.diamond,
      'Sport': Icons.fitness_center,
      'Classic': Icons.watch_later,
      'Smart': Icons.watch,
      'Digital': Icons.devices,
      'Analog': Icons.access_time,
    };

    final Map<String, Color> categoryColors = {
      'All': Colors.blue,
      'Luxury': Colors.amber,
      'Sport': Colors.green,
      'Classic': Colors.purple,
      'Smart': Colors.cyan,
      'Digital': Colors.orange,
      'Analog': Colors.red,
    };

    // Brand logos for categories
    final Map<String, String> categoryLogos = {
      'All': 'assets/images/brands/all_brands.png',
      'Luxury': 'assets/images/brands/rolex.png',
      'Sport': 'assets/images/brands/nike.png',
      'Classic': 'assets/images/brands/seiko.png',
      'Smart': 'assets/images/brands/apple.png',
      'Digital': 'assets/images/brands/casio.png',
      'Analog': 'assets/images/brands/tissot.png',
    };

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              categoryColors[category]?.withValues(alpha: 0.8) ??
                  Colors.blue.withValues(alpha: 0.8),
              categoryColors[category]?.withValues(alpha: 0.5) ??
                  Colors.blue.withValues(alpha: 0.5),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: (categoryColors[category] ?? Colors.blue).withValues(
                alpha: 0.3,
              ),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Background gradient
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      categoryColors[category]?.withValues(alpha: 0.8) ??
                          Colors.blue.withValues(alpha: 0.8),
                      categoryColors[category]?.withValues(alpha: 0.5) ??
                          Colors.blue.withValues(alpha: 0.5),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
            // Brand logo overlay
            Positioned(
              top: 10,
              right: 10,
              child: Container(
                width: 60,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: Image.asset(
                    categoryLogos[category] ??
                        'assets/images/brands/all_brands.png',
                    width: 50,
                    height: 30,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey.withValues(alpha: 0.3),
                        child: Icon(
                          Icons.business,
                          color: Colors.white,
                          size: 20,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            // Content
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    categoryIcons[category] ?? Icons.category,
                    size: 48,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    category,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
