import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';
import '../core/constants/colors.dart';
import '../models/watch.dart';

class TryOnWristScreen extends StatefulWidget {
  final Watch watch;

  const TryOnWristScreen({super.key, required this.watch});

  @override
  State<TryOnWristScreen> createState() => _TryOnWristScreenState();
}

class _TryOnWristScreenState extends State<TryOnWristScreen> {
  bool _isARMode = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // Simulate loading
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E1E1E),
        elevation: 0,
        title: Text(
          'AR Try-On',
          style: GoogleFonts.playfairDisplay(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 24,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isARMode ? Icons.view_in_ar : Icons.threed_rotation,
              color: AppColors.accent,
            ),
            onPressed: () {
              setState(() {
                _isARMode = !_isARMode;
              });
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.accent),
            )
          : Column(
              children: [
                // 3D Model Viewer
                Expanded(
                  flex: 3,
                  child: Container(
                    margin: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E1E1E),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.accent.withValues(alpha:0.3),
                        width: 2,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: _buildModelViewer(),
                    ),
                  ),
                ),

                // Watch Info
                Container(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.watch.name,
                        style: GoogleFonts.playfairDisplay(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '\$${widget.watch.price.toStringAsFixed(2)}',
                        style: GoogleFonts.inter(
                          color: AppColors.accent,
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Instructions
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.accent.withValues(alpha:0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.accent.withValues(alpha:0.3),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.lightbulb_outline,
                                  color: AppColors.accent,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'How to Use',
                                  style: GoogleFonts.inter(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            _buildInstructionStep(
                              '1',
                              'Rotate the watch by dragging with one finger',
                            ),
                            _buildInstructionStep(
                              '2',
                              'Zoom in/out by pinching with two fingers',
                            ),
                            _buildInstructionStep(
                              '3',
                              'Tap AR button to place on your wrist',
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Action Buttons
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            // Add to cart logic
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Added to cart'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          },
                          icon: const Icon(Icons.shopping_cart_outlined),
                          label: Text(
                            'Add to Cart',
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            side: const BorderSide(
                              color: AppColors.accent,
                              width: 2,
                            ),
                            foregroundColor: AppColors.accent,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            // Purchase logic
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Proceeding to checkout'),
                                backgroundColor: AppColors.accent,
                              ),
                            );
                          },
                          icon: const Icon(Icons.flash_on),
                          label: Text(
                            'Buy Now',
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            backgroundColor: AppColors.accent,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildModelViewer() {
    // Try to load 3D model if available, otherwise show image
    final firstImage = widget.watch.images.isNotEmpty
        ? widget.watch.images[0]
        : '';

    return Stack(
      children: [
        // 3D Model or Image
        firstImage.endsWith('.glb') || firstImage.endsWith('.gltf')
            ? ModelViewer(
                src: firstImage,
                alt: 'A 3D model of ${widget.watch.name}',
                ar: true,
                arModes: const ['scene-viewer', 'arquicklook', 'webxr'],
                autoRotate: true,
                cameraControls: true,
                backgroundColor: const Color(0xFF1E1E1E),
              )
            : Center(
                child: Image.asset(
                  firstImage,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.watch_later,
                          size: 120,
                          color: AppColors.accent.withValues(alpha:0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          '3D Model Not Available',
                          style: GoogleFonts.inter(
                            color: Colors.white70,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),

        // AR Mode Indicator
        if (_isARMode)
          Positioned(
            top: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.accent,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.view_in_ar, size: 16, color: Colors.white),
                  const SizedBox(width: 4),
                  Text(
                    'AR Mode',
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildInstructionStep(String number, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: AppColors.accent,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.inter(
                color: Colors.white70,
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
