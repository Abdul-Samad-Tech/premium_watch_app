import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/watch.dart';
import '../core/constants/colors.dart';
import '../screens/product_details_screen.dart';
import '../providers/wishlist_provider.dart';
import '../providers/cart_provider.dart';

class WatchCard extends StatefulWidget {
  final Watch watch;
  final int index;

  const WatchCard({super.key, required this.watch, required this.index});

  @override
  State<WatchCard> createState() => _WatchCardState();
}

class _WatchCardState extends State<WatchCard>
    with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.03).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onHover(bool isHovered) {
    setState(() => _isHovered = isHovered);
    if (isHovered) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimationConfiguration.staggeredGrid(
      position: widget.index,
      columnCount: 2,
      child: ScaleAnimation(
        child: FadeInAnimation(
          child: MouseRegion(
            onEnter: (_) => _onHover(true),
            onExit: (_) => _onHover(false),
            child: AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return Transform.scale(
                  scale: _scaleAnimation.value,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        PageRouteBuilder(
                          pageBuilder:
                              (context, animation, secondaryAnimation) =>
                                  ProductDetailsScreen(watch: widget.watch),
                          transitionsBuilder:
                              (context, animation, secondaryAnimation, child) {
                                return FadeTransition(
                                  opacity: animation,
                                  child: SlideTransition(
                                    position:
                                        Tween<Offset>(
                                          begin: const Offset(0.0, 0.1),
                                          end: Offset.zero,
                                        ).animate(
                                          CurvedAnimation(
                                            parent: animation,
                                            curve: Curves.easeInOut,
                                          ),
                                        ),
                                    child: child,
                                  ),
                                );
                              },
                          transitionDuration: const Duration(milliseconds: 500),
                        ),
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: _isHovered
                              ? AppColors.accent.withValues(alpha:0.3)
                              : Colors.grey.withValues(alpha:0.1),
                          width: _isHovered ? 2 : 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: _isHovered
                                ? AppColors.accent.withValues(alpha:0.4)
                                : Colors.black.withValues(alpha:0.1),
                            blurRadius: _isHovered ? 25 : 15,
                            offset: Offset(0, _isHovered ? 10 : 5),
                            spreadRadius: _isHovered ? -2 : -1,
                          ),
                          if (_isHovered)
                            BoxShadow(
                              color: AppColors.accent.withValues(alpha:0.2),
                              blurRadius: 40,
                              offset: const Offset(0, 15),
                              spreadRadius: -5,
                            ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Product image
                          Expanded(
                            child: Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(20),
                                  ),
                                  child: Image.asset(
                                    widget.watch.images[0],
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            Container(
                                              color: Colors.grey[200],
                                              child: const Icon(
                                                Icons.watch_later,
                                                size: 50,
                                              ),
                                            ),
                                  ),
                                ),
                                // Hover overlay with buttons
                                Positioned.fill(
                                  child: FadeTransition(
                                    opacity: _fadeAnimation,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                          colors: [
                                            Colors.transparent,
                                            Colors.black.withValues(alpha:0.7),
                                          ],
                                        ),
                                      ),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          // Product View Button
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                            ),
                                            child: SizedBox(
                                              width: double.infinity,
                                              child: ElevatedButton.icon(
                                                onPressed: () {
                                                  Navigator.push(
                                                    context,
                                                    PageRouteBuilder(
                                                      pageBuilder:
                                                          (
                                                            context,
                                                            animation,
                                                            secondaryAnimation,
                                                          ) =>
                                                              ProductDetailsScreen(
                                                                watch: widget
                                                                    .watch,
                                                              ),
                                                      transitionsBuilder:
                                                          (
                                                            context,
                                                            animation,
                                                            secondaryAnimation,
                                                            child,
                                                          ) {
                                                            return FadeTransition(
                                                              opacity:
                                                                  animation,
                                                              child: SlideTransition(
                                                                position:
                                                                    Tween<Offset>(
                                                                      begin:
                                                                          const Offset(
                                                                            0.0,
                                                                            0.1,
                                                                          ),
                                                                      end: Offset
                                                                          .zero,
                                                                    ).animate(
                                                                      CurvedAnimation(
                                                                        parent:
                                                                            animation,
                                                                        curve: Curves
                                                                            .easeInOut,
                                                                      ),
                                                                    ),
                                                                child: child,
                                                              ),
                                                            );
                                                          },
                                                      transitionDuration:
                                                          const Duration(
                                                            milliseconds: 500,
                                                          ),
                                                    ),
                                                  );
                                                },
                                                icon: const Icon(
                                                  Icons.visibility,
                                                  size: 18,
                                                ),
                                                label: Text(
                                                  'Product View',
                                                  style: GoogleFonts.inter(
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 13,
                                                  ),
                                                ),
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: Colors.white,
                                                  foregroundColor:
                                                      AppColors.primary,
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        vertical: 12,
                                                      ),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          10,
                                                        ),
                                                  ),
                                                  elevation: 3,
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          // Add to Cart & Wishlist Buttons
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                            ),
                                            child: Row(
                                              children: [
                                                Expanded(
                                                  child: Consumer<CartProvider>(
                                                    builder: (context, cartProvider, child) {
                                                      final isInCart =
                                                          cartProvider.isInCart(
                                                            widget.watch.id,
                                                          );
                                                      return ElevatedButton.icon(
                                                        onPressed: () {
                                                          if (!isInCart) {
                                                            cartProvider
                                                                .addToCart(
                                                                  widget.watch,
                                                                );
                                                            ScaffoldMessenger.of(
                                                              context,
                                                            ).showSnackBar(
                                                              SnackBar(
                                                                content: const Text(
                                                                  'Added to cart',
                                                                ),
                                                                behavior:
                                                                    SnackBarBehavior
                                                                        .floating,
                                                                shape: RoundedRectangleBorder(
                                                                  borderRadius:
                                                                      BorderRadius.circular(
                                                                        10,
                                                                      ),
                                                                ),
                                                              ),
                                                            );
                                                          }
                                                        },
                                                        icon: Icon(
                                                          isInCart
                                                              ? Icons.check
                                                              : Icons
                                                                    .shopping_cart_outlined,
                                                          size: 16,
                                                        ),
                                                        label: Text(
                                                          isInCart
                                                              ? 'In Cart'
                                                              : 'Add to Cart',
                                                          style:
                                                              GoogleFonts.inter(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                                fontSize: 12,
                                                              ),
                                                        ),
                                                        style: ElevatedButton.styleFrom(
                                                          backgroundColor:
                                                              AppColors.accent,
                                                          foregroundColor:
                                                              Colors.white,
                                                          padding:
                                                              const EdgeInsets.symmetric(
                                                                vertical: 12,
                                                              ),
                                                          shape: RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                  10,
                                                                ),
                                                          ),
                                                          elevation: 3,
                                                        ),
                                                      );
                                                    },
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                Consumer<WishlistProvider>(
                                                  builder:
                                                      (
                                                        context,
                                                        wishlistProvider,
                                                        child,
                                                      ) {
                                                        final isInWishlist =
                                                            wishlistProvider
                                                                .isInWishlist(
                                                                  widget
                                                                      .watch
                                                                      .id,
                                                                );
                                                        return Container(
                                                          decoration: BoxDecoration(
                                                            color: isInWishlist
                                                                ? Colors.red
                                                                : Colors.white,
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                  10,
                                                                ),
                                                            boxShadow: [
                                                              BoxShadow(
                                                                color: Colors
                                                                    .black
                                                                    .withValues(alpha:
                                                                      0.2,
                                                                    ),
                                                                blurRadius: 3,
                                                                offset:
                                                                    const Offset(
                                                                      0,
                                                                      2,
                                                                    ),
                                                              ),
                                                            ],
                                                          ),
                                                          child: Material(
                                                            color: Colors
                                                                .transparent,
                                                            child: InkWell(
                                                              onTap: () {
                                                                if (isInWishlist) {
                                                                  wishlistProvider
                                                                      .removeFromWishlist(
                                                                        widget
                                                                            .watch
                                                                            .id,
                                                                      );
                                                                  ScaffoldMessenger.of(
                                                                    context,
                                                                  ).showSnackBar(
                                                                    SnackBar(
                                                                      content:
                                                                          const Text(
                                                                            'Removed from wishlist',
                                                                          ),
                                                                      behavior:
                                                                          SnackBarBehavior
                                                                              .floating,
                                                                      shape: RoundedRectangleBorder(
                                                                        borderRadius:
                                                                            BorderRadius.circular(
                                                                              10,
                                                                            ),
                                                                      ),
                                                                    ),
                                                                  );
                                                                } else {
                                                                  wishlistProvider
                                                                      .addToWishlist(
                                                                        widget
                                                                            .watch,
                                                                      );
                                                                  ScaffoldMessenger.of(
                                                                    context,
                                                                  ).showSnackBar(
                                                                    SnackBar(
                                                                      content:
                                                                          const Text(
                                                                            'Added to wishlist',
                                                                          ),
                                                                      behavior:
                                                                          SnackBarBehavior
                                                                              .floating,
                                                                      shape: RoundedRectangleBorder(
                                                                        borderRadius:
                                                                            BorderRadius.circular(
                                                                              10,
                                                                            ),
                                                                      ),
                                                                    ),
                                                                  );
                                                                }
                                                              },
                                                              borderRadius:
                                                                  BorderRadius.circular(
                                                                    10,
                                                                  ),
                                                              child: Padding(
                                                                padding:
                                                                    const EdgeInsets.all(
                                                                      12,
                                                                    ),
                                                                child: Icon(
                                                                  isInWishlist
                                                                      ? Icons
                                                                            .favorite
                                                                      : Icons
                                                                            .favorite_border,
                                                                  color:
                                                                      isInWishlist
                                                                      ? Colors
                                                                            .white
                                                                      : AppColors
                                                                            .accent,
                                                                  size: 18,
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(height: 12),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                // Wishlist button (hidden on hover)
                                Positioned(
                                  top: 8,
                                  right: 8,
                                  child: FadeTransition(
                                    opacity: Tween<double>(
                                      begin: 1.0,
                                      end: 0.0,
                                    ).animate(_animationController),
                                    child: Consumer<WishlistProvider>(
                                      builder:
                                          (context, wishlistProvider, child) {
                                            final isInWishlist =
                                                wishlistProvider.isInWishlist(
                                                  widget.watch.id,
                                                );
                                            return GestureDetector(
                                              onTap: () {
                                                if (isInWishlist) {
                                                  wishlistProvider
                                                      .removeFromWishlist(
                                                        widget.watch.id,
                                                      );
                                                  ScaffoldMessenger.of(
                                                    context,
                                                  ).showSnackBar(
                                                    const SnackBar(
                                                      content: Text(
                                                        'Removed from wishlist',
                                                      ),
                                                    ),
                                                  );
                                                } else {
                                                  wishlistProvider
                                                      .addToWishlist(
                                                        widget.watch,
                                                      );
                                                  ScaffoldMessenger.of(
                                                    context,
                                                  ).showSnackBar(
                                                    const SnackBar(
                                                      content: Text(
                                                        'Added to wishlist',
                                                      ),
                                                    ),
                                                  );
                                                }
                                              },
                                              child: Container(
                                                padding: const EdgeInsets.all(
                                                  6,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  shape: BoxShape.circle,
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.black
                                                          .withValues(alpha:0.1),
                                                      blurRadius: 4,
                                                      offset: const Offset(
                                                        0,
                                                        2,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                child: Icon(
                                                  isInWishlist
                                                      ? Icons.favorite
                                                      : Icons.favorite_border,
                                                  color: isInWishlist
                                                      ? Colors.red
                                                      : AppColors.textSecondary,
                                                  size: 20,
                                                ),
                                              ),
                                            );
                                          },
                                    ),
                                  ),
                                ),
                                // New badge
                                if (widget.watch.isNew)
                                  Positioned(
                                    top: 8,
                                    left: 8,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.accent,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        'NEW',
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
                          // Product info
                          Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.watch.brand,
                                  style: GoogleFonts.inter(
                                    fontSize: 11,
                                    color: AppColors.textSecondary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  widget.watch.name,
                                  style: GoogleFonts.inter(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                    color: AppColors.textPrimary,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  '\$${widget.watch.price.toStringAsFixed(2)}',
                                  style: GoogleFonts.playfairDisplay(
                                    color: AppColors.accent,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
