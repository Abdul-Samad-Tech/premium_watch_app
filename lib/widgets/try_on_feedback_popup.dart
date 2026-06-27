import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/watch.dart';
import '../core/constants/colors.dart';

class TryOnFeedbackPopup extends StatefulWidget {
  final Watch watch;
  final VoidCallback onAddToCart;
  final VoidCallback onRequestRecommendations;
  final String? userFeedback;

  const TryOnFeedbackPopup({
    super.key,
    required this.watch,
    required this.onAddToCart,
    required this.onRequestRecommendations,
    this.userFeedback,
  });

  @override
  State<TryOnFeedbackPopup> createState() => _TryOnFeedbackPopupState();
}

class _TryOnFeedbackPopupState extends State<TryOnFeedbackPopup>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  String? _selectedFeedback;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppColors.accent.withValues(alpha:0.3),
              width: 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Text(
                'How does this watch look?',
                style: GoogleFonts.playfairDisplay(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              // Watch Info
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha:0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: widget.watch.images.isNotEmpty
                          ? Image.asset(
                              widget.watch.images[0],
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                            )
                          : Container(
                              width: 60,
                              height: 60,
                              color: Colors.grey,
                              child: const Icon(Icons.watch, color: Colors.white),
                            ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.watch.name,
                            style: GoogleFonts.inter(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            widget.watch.brand,
                            style: GoogleFonts.inter(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            '\$${widget.watch.price.toStringAsFixed(2)}',
                            style: GoogleFonts.inter(
                              color: AppColors.accent,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Feedback Options
              Text(
                'Your feedback helps us improve recommendations',
                style: GoogleFonts.inter(
                  color: Colors.white70,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: _FeedbackButton(
                      icon: Icons.thumb_up,
                      label: 'Looks Good',
                      color: Colors.green,
                      isSelected: _selectedFeedback == 'good',
                      onTap: () {
                        setState(() {
                          _selectedFeedback = 'good';
                        });
                        _handleFeedback('good');
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _FeedbackButton(
                      icon: Icons.thumb_down,
                      label: 'Not Good',
                      color: Colors.red,
                      isSelected: _selectedFeedback == 'not_good',
                      onTap: () {
                        setState(() {
                          _selectedFeedback = 'not_good';
                        });
                        _handleFeedback('not_good');
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Action Buttons
              if (_selectedFeedback == 'good') ...[
                _ActionButton(
                  label: 'Add to Cart',
                  icon: Icons.shopping_cart,
                  onPressed: widget.onAddToCart,
                ),
              ] else if (_selectedFeedback == 'not_good') ...[
                _ActionButton(
                  label: 'Get Recommendations',
                  icon: Icons.lightbulb,
                  onPressed: widget.onRequestRecommendations,
                ),
              ],

              // Close Button
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  'Try Another Watch',
                  style: GoogleFonts.inter(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleFeedback(String feedback) {
    Future.delayed(const Duration(milliseconds: 500), () {
      if (feedback == 'good') {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Great choice! This watch suits you perfectly.',
              style: GoogleFonts.inter(),
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      } else {
        // Show recommendation message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Finding better watches for you...',
              style: GoogleFonts.inter(),
            ),
            backgroundColor: AppColors.accent,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    });
  }
}

class _FeedbackButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _FeedbackButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha:0.2) : Colors.black.withValues(alpha:0.3),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : Colors.white24,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? color : Colors.white70,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: GoogleFonts.inter(
                color: isSelected ? color : Colors.white70,
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, color: Colors.black),
        label: Text(
          label,
          style: GoogleFonts.inter(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accent,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
