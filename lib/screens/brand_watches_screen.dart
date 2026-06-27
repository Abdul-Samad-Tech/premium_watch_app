import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../core/constants/colors.dart';
import '../providers/product_provider.dart';
import '../widgets/watch_card.dart';
import 'product_details_screen.dart';

class BrandWatchesScreen extends StatelessWidget {
  final String brand;

  const BrandWatchesScreen({super.key, required this.brand});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0A0A0A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.accent.withValues(alpha:0.5)),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.arrow_back_ios,
              color: AppColors.accent,
              size: 18,
            ),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          brand,
          style: GoogleFonts.playfairDisplay(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
      ),
      body: Consumer<ProductProvider>(
        builder: (context, productProvider, child) {
          // Filter products by brand
          final brandWatches = productProvider.watches
              .where(
                (watch) => watch.brand.toLowerCase() == brand.toLowerCase(),
              )
              .toList();

          if (brandWatches.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.watch_later,
                    size: 80,
                    color: AppColors.accent.withValues(alpha:0.3),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'No watches available',
                    style: GoogleFonts.playfairDisplay(
                      color: Colors.white,
                      fontSize: 24,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Check back soon for $brand watches',
                    style: GoogleFonts.inter(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            );
          }

          return GridView.builder(
            padding: EdgeInsets.all(16),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.7,
            ),
            itemCount: brandWatches.length,
            itemBuilder: (context, index) {
              final watch = brandWatches[index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProductDetailsScreen(watch: watch),
                    ),
                  );
                },
                child: WatchCard(watch: watch, index: index),
              );
            },
          );
        },
      ),
    );
  }
}
