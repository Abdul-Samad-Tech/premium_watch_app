import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/constants/colors.dart';
import '../core/constants/strings.dart';
import '../models/watch.dart';
import '../providers/cart_provider.dart';
import 'cart_screen.dart';
import 'checkout_wizard_screen.dart';
import 'try_on_wrist_camera_screen.dart';

class ProductDetailsScreen extends StatefulWidget {
  final Watch watch;

  const ProductDetailsScreen({super.key, required this.watch});

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  final PageController _imageController = PageController();
  int _currentImageIndex = 0;

  @override
  void dispose() {
    _imageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Hero Image Section
          SliverToBoxAdapter(
            child: Stack(
              children: [
                SizedBox(
                  height: 400,
                  child: PageView.builder(
                    controller: _imageController,
                    itemCount: widget.watch.images.length,
                    onPageChanged: (index) {
                      setState(() {
                        _currentImageIndex = index;
                      });
                    },
                    itemBuilder: (context, index) {
                      return Hero(
                        tag: 'watch_${widget.watch.id}',
                        child: Image.asset(
                          widget.watch.images[index],
                          fit: BoxFit.cover,
                          width: double.infinity,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                                color: Colors.grey[200],
                                child: const Icon(Icons.watch_later, size: 100),
                              ),
                        ),
                      );
                    },
                  ),
                ),
                // Page indicator
                if (widget.watch.images.length > 1)
                  Positioned(
                    bottom: 20,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: SmoothPageIndicator(
                        controller: _imageController,
                        count: widget.watch.images.length,
                        effect: WormEffect(
                          dotColor: Colors.white.withValues(alpha: 0.5),
                          activeDotColor: AppColors.accent,
                          dotHeight: 10,
                          dotWidth: 10,
                        ),
                      ),
                    ),
                  ),
                // Back button
                Positioned(
                  top: 16,
                  left: 16,
                  child: CircleAvatar(
                    backgroundColor: Colors.white,
                    child: IconButton(
                      icon: const Icon(
                        Icons.arrow_back,
                        color: AppColors.textPrimary,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ),
                // Cart button
                Positioned(
                  top: 16,
                  right: 16,
                  child: Stack(
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.white,
                        child: IconButton(
                          icon: const Icon(
                            Icons.shopping_cart_outlined,
                            color: AppColors.textPrimary,
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const CartScreen(),
                              ),
                            );
                          },
                        ),
                      ),
                      if (context.watch<CartProvider>().itemCount > 0)
                        Positioned(
                          right: 0,
                          top: 0,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: AppColors.accent,
                              shape: BoxShape.circle,
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 16,
                              minHeight: 16,
                            ),
                            child: Text(
                              '${context.watch<CartProvider>().itemCount}',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.inter(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Product Details
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Brand
                Text(
                  widget.watch.brand,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),

                // Product name
                Text(
                  widget.watch.name,
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
                const SizedBox(height: 12),

                // Price
                Text(
                  '\$${widget.watch.price.toStringAsFixed(2)}',
                  style: GoogleFonts.playfairDisplay(
                    color: AppColors.accent,
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 24),

                // Specifications
                Text(
                  AppStrings.specifications,
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: widget.watch.specs.entries.map((spec) {
                    return _SpecCard(label: spec.key, value: spec.value);
                  }).toList(),
                ),
                const SizedBox(height: 24),

                // AR Try-On Button
                GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            TryOnWristCameraScreen(watch: widget.watch),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.accent, width: 2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.camera_alt,
                          color: AppColors.accent,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          AppStrings.tryOnWrist,
                          style: GoogleFonts.inter(
                            color: AppColors.accent,
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Description
                Text(
                  AppStrings.description,
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  widget.watch.description,
                  style: GoogleFonts.inter(
                    color: AppColors.textSecondary,
                    height: 1.6,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 100), // Space for bottom action bar
              ]),
            ),
          ),
        ],
      ),

      // Sticky Action Bar
      bottomSheet: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  context.read<CartProvider>().addToCart(widget.watch);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${widget.watch.name} added to cart'),
                      duration: const Duration(seconds: 2),
                      backgroundColor: AppColors.primary,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(
                  AppStrings.addToCart,
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  context.read<CartProvider>().addToCart(widget.watch);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CheckoutWizardScreen(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(
                  AppStrings.buyNow,
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SpecCard extends StatelessWidget {
  final String label;
  final String value;

  const _SpecCard({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
