import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/constants/colors.dart';
import '../screens/brand_watches_screen.dart';

class BrandChip extends StatelessWidget {
  final String brand;
  final bool isSelected;
  final VoidCallback onTap;

  const BrandChip({
    super.key,
    required this.brand,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Navigate to brand watches screen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BrandWatchesScreen(brand: brand),
          ),
        );
        // Also call the original onTap for filtering
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  colors: [
                    AppColors.accent,
                    AppColors.accent.withValues(alpha:0.8),
                    const Color(0xFFB8941F),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : LinearGradient(
                  colors: [
                    Colors.white.withValues(alpha:0.1),
                    Colors.white.withValues(alpha:0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: isSelected
                ? AppColors.accent
                : Colors.white.withValues(alpha:0.2),
            width: isSelected ? 2 : 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.accent.withValues(alpha:0.5),
                    blurRadius: 15,
                    spreadRadius: 2,
                    offset: const Offset(0, 5),
                  ),
                  BoxShadow(
                    color: AppColors.accent.withValues(alpha:0.3),
                    blurRadius: 30,
                    offset: const Offset(0, 10),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha:0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isSelected)
              Padding(
                padding: const EdgeInsets.only(right: 6),
                child: Icon(
                  Icons.star,
                  size: 14,
                  color: Colors.black.withValues(alpha:0.6),
                ),
              ),
            Text(
              brand,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w700,
                color: isSelected ? Colors.black : Colors.white,
                letterSpacing: 0.8,
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
