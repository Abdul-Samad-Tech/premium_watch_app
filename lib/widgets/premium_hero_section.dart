import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:video_player/video_player.dart';
import 'dart:ui';
import '../models/watch.dart';

class PremiumHeroSection extends StatefulWidget {
  final VideoPlayerController? videoController;
  final bool isVideoInitialized;
  final Animation<double> gradientAnimation;
  final Function(Watch)? onWatchSelected;

  const PremiumHeroSection({
    super.key,
    required this.videoController,
    required this.isVideoInitialized,
    required this.gradientAnimation,
    this.onWatchSelected,
  });

  @override
  State<PremiumHeroSection> createState() => _PremiumHeroSectionState();
}

class _PremiumHeroSectionState extends State<PremiumHeroSection> {
  final CarouselSliderController _carouselController =
      CarouselSliderController();
  int _currentIndex = 0;

  // Sample premium watches data for carousel
  final List<Map<String, dynamic>> _featuredWatches = [
    {
      'image': 'assets/images/watches_new/watch_01_quartz_leather.jpg',
      'name': 'Quartz Classic',
      'price': '\$45.99',
      'brand': 'GENERIC',
    },
    {
      'image': 'assets/images/watches_new/watch_06_galaxy_chronograph.jpg',
      'name': 'Galaxy Chrono',
      'price': '\$159.99',
      'brand': 'LUXURY',
    },
    {
      'image': 'assets/images/watches_new/watch_07_skeleton_black_gold.jpg',
      'name': 'Skeleton Gold',
      'price': '\$199.99',
      'brand': 'PREMIUM',
    },
    {
      'image': 'assets/images/watches_new/watch_14_curren_sport.jpg',
      'name': 'CURREN Sport',
      'price': '\$89.99',
      'brand': 'CURREN',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 520,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Layer 1: Video Background
            _buildVideoBackground(),

            // Layer 2: Banner Image
            _buildBanner(),

            // Layer 3: Semi-transparent Overlay
            _buildOverlay(),

            // Layer 4: Glassmorphism Carousel
            _buildGlassmorphismCarousel(),

            // Layer 5: Content & CTA
            _buildContentOverlay(),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoBackground() {
    return Stack(
      children: [
        if (widget.isVideoInitialized && widget.videoController != null)
          // Video with cover fit
          FittedBox(
            fit: BoxFit.cover,
            child: SizedBox(
              width: widget.videoController!.value.size.width,
              height: widget.videoController!.value.size.height,
              child: VideoPlayer(widget.videoController!),
            ),
          )
        else
          // Animated Gradient Fallback
          AnimatedBuilder(
            animation: widget.gradientAnimation,
            builder: (context, child) {
              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color.lerp(
                        const Color(0xFF0A0A0A),
                        const Color(0xFF1A1A2E),
                        widget.gradientAnimation.value,
                      )!,
                      Color.lerp(
                        const Color(0xFF1A1A2E),
                        const Color(0xFF16213E),
                        widget.gradientAnimation.value,
                      )!,
                      Color.lerp(
                        const Color(0xFF16213E),
                        const Color(0xFF0A0A0A),
                        widget.gradientAnimation.value,
                      )!,
                    ],
                  ),
                ),
              );
            },
          ),
      ],
    );
  }

  Widget _buildBanner() {
    return Positioned.fill(
      child: Image.asset(
        'assets/images/banners/Whisk_ednxazmlntnyetmy0iniltytqwo5qtl2ugn20cn.jpeg',
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF0A0A0A),
                  const Color(0xFF1A1A2E),
                  const Color(0xFF16213E),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildOverlay() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withValues(alpha:0.4),
            Colors.black.withValues(alpha:0.7),
          ],
        ),
      ),
    );
  }

  Widget _buildGlassmorphismCarousel() {
    return Positioned(
      top: 60,
      left: 0,
      right: 0,
      child: CarouselSlider(
        carouselController: _carouselController,
        options: CarouselOptions(
          height: 200,
          autoPlay: true,
          autoPlayInterval: const Duration(seconds: 4),
          enlargeCenterPage: true,
          viewportFraction: 0.65,
          onPageChanged: (index, reason) {
            setState(() {
              _currentIndex = index;
            });
            // Call callback when watch is selected
            if (widget.onWatchSelected != null) {
              final watchData = _featuredWatches[index];
              final selectedWatch = Watch(
                id: (index + 1).toString(),
                name: watchData['name']!,
                brand: watchData['brand']!,
                price: double.parse(watchData['price']!.replaceFirst('\$', '')),
                description:
                    '${watchData['brand']} ${watchData['name']} - Premium timepiece',
                images: [watchData['image']!],
                specs: {'case': 'Premium', 'movement': 'Automatic'},
                category: 'Luxury',
                isNew: true,
                style: 'luxury',
                caseSize: 42.0,
                colors: ['silver', 'gold'],
              );
              widget.onWatchSelected!(selectedWatch);
            }
          },
        ),
        items: _featuredWatches.map((watch) {
          return Builder(
            builder: (BuildContext context) {
              return _GlassmorphismCard(
                image: watch['image']!,
                name: watch['name']!,
                price: watch['price']!,
                brand: watch['brand']!,
              );
            },
          );
        }).toList(),
      ),
    );
  }

  Widget _buildContentOverlay() {
    return Stack(
      children: [
        // App Title and Logo
        Positioned(
          top: 20,
          left: 20,
          child: Row(
            children: [
              // Logo
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha:0.9),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha:0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Icon(
                    Icons.watch,
                    size: 30,
                    color: const Color(0xFFD4AF37), // Gold color
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // App Title
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Premium',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          color: Colors.black.withValues(alpha:0.5),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    'Watches',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFFD4AF37), // Gold accent
                      shadows: [
                        Shadow(
                          color: Colors.black.withValues(alpha:0.5),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        // Bottom Content
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Colors.black.withValues(alpha:0.8)],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Carousel Indicator
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    _featuredWatches.length,
                    (index) => AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: _currentIndex == index ? 24 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: _currentIndex == index
                            ? const Color(0xFFD4AF37)
                            : Colors.white.withValues(alpha:0.4),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD4AF37),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFD4AF37).withValues(alpha:0.5),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Text(
                    'NEW COLLECTION 2024',
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 2,
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Title
                Text(
                  'Discover Luxury\nTimepieces',
                  style: GoogleFonts.playfairDisplay(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    height: 1.1,
                    shadows: [
                      Shadow(
                        color: Colors.black.withValues(alpha:0.6),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // CTA Buttons
                Row(
                  children: [
                    // Try Now Button with Glow Effect
                    Expanded(
                      child: _GlowButton(
                        text: 'Try Now',
                        icon: Icons.auto_awesome,
                        onPressed: () {
                          // Navigate to AR or Try-on feature
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Explore Button
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          // Scroll to products or navigate to gallery
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: const BorderSide(
                            color: Color(0xFFD4AF37),
                            width: 2,
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Explore',
                              style: GoogleFonts.inter(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Icon(Icons.arrow_forward, size: 18),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// Glassmorphism Card Widget
class _GlassmorphismCard extends StatelessWidget {
  final String image;
  final String name;
  final String price;
  final String brand;

  const _GlassmorphismCard({
    required this.image,
    required this.name,
    required this.price,
    required this.brand,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha:0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withValues(alpha:0.2),
              width: 1.5,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Watch Image
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha:0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      image,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: Colors.grey[800],
                        child: const Icon(
                          Icons.watch_later,
                          size: 60,
                          color: Colors.white54,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Brand
              Text(
                brand,
                style: GoogleFonts.inter(
                  color: const Color(0xFFD4AF37),
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 4),

              // Name
              Text(
                name,
                style: GoogleFonts.playfairDisplay(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),

              // Price
              Text(
                price,
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Glow Button Widget
class _GlowButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final VoidCallback onPressed;

  const _GlowButton({
    required this.text,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFD4AF37).withValues(alpha:0.6),
            blurRadius: 15,
            spreadRadius: 2,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFD4AF37),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18),
            const SizedBox(width: 8),
            Text(
              text,
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
