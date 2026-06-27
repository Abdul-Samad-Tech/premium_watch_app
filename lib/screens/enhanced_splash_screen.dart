import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../core/constants/colors.dart';
import '../widgets/premium_loading_widget.dart';
import '../providers/user_provider.dart';
import 'home_screen.dart';
import 'login_screen.dart';

class EnhancedSplashScreen extends StatefulWidget {
  const EnhancedSplashScreen({super.key});

  @override
  State<EnhancedSplashScreen> createState() => _EnhancedSplashScreenState();
}

class _EnhancedSplashScreenState extends State<EnhancedSplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _textController;
  late AnimationController _progressController;

  late Animation<double> _logoScaleAnimation;
  late Animation<double> _logoFadeAnimation;
  late Animation<double> _textSlideAnimation;
  late Animation<double> _textFadeAnimation;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimations();
  }

  void _initializeAnimations() {
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _textController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _progressController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );

    // Logo animations
    _logoScaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
    );

    _logoFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeInOut),
    );

    // Text animations
    _textSlideAnimation = Tween<double>(begin: 50.0, end: 0.0).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeOutBack),
    );

    _textFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeInOut),
    );

    // Progress animation
    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeInOut),
    );
  }

  void _startAnimations() async {
    // Start logo animation
    _logoController.forward();

    // Wait for logo animation to complete
    await Future.delayed(const Duration(milliseconds: 800));

    // Start text animation
    _textController.forward();

    // Start progress animation
    _progressController.forward();

    // Navigate to home screen after all animations
    await Future.delayed(const Duration(milliseconds: 3000));

    if (mounted) {
      _navigateToHome();
    }
  }

  void _navigateToHome() {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    // Check if user is already logged in
    if (userProvider.currentUser != null) {
      // User is logged in, go to home
      Navigator.of(context).pushAndRemoveUntil(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const HomeScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position:
                    Tween<Offset>(
                      begin: const Offset(0, 0.1),
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
          transitionDuration: const Duration(milliseconds: 800),
        ),
        (route) => false,
      );
    } else {
      // User not logged in, go to login
      Navigator.of(context).pushAndRemoveUntil(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const LoginScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position:
                    Tween<Offset>(
                      begin: const Offset(0, 0.1),
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
          transitionDuration: const Duration(milliseconds: 800),
        ),
        (route) => false,
      );
    }
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1A1A2E),
              Color(0xFF16213E),
              Color(0xFF0F3460),
              Color(0xFF16213E),
              Color(0xFF1A1A2E),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo Section
                Expanded(
                  flex: 2,
                  child: Center(
                    child: AnimatedBuilder(
                      animation: _logoController,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _logoScaleAnimation.value,
                          child: FadeTransition(
                            opacity: _logoFadeAnimation,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // Premium Watch Icon
                                Container(
                                  width: 120,
                                  height: 120,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        AppColors.accent,
                                        AppColors.accent.withValues(alpha:0.8),
                                        AppColors.accent.withValues(alpha:0.6),
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.accent.withValues(alpha:
                                          0.4,
                                        ),
                                        blurRadius: 30,
                                        spreadRadius: 5,
                                      ),
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha:0.3),
                                        blurRadius: 20,
                                        spreadRadius: 2,
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.watch,
                                    size: 60,
                                    color: Colors.white,
                                  ),
                                ),

                                const SizedBox(height: 32),

                                // Brand Name
                                AnimatedBuilder(
                                  animation: _textController,
                                  builder: (context, child) {
                                    return Transform.translate(
                                      offset: Offset(
                                        0,
                                        _textSlideAnimation.value,
                                      ),
                                      child: FadeTransition(
                                        opacity: _textFadeAnimation,
                                        child: Text(
                                          'LUXE TIME',
                                          style: GoogleFonts.playfairDisplay(
                                            fontSize: 42,
                                            fontWeight: FontWeight.w800,
                                            color: Colors.white,
                                            letterSpacing: 2.0,
                                            shadows: [
                                              Shadow(
                                                color: AppColors.accent
                                                    .withValues(alpha:0.5),
                                                blurRadius: 20,
                                                offset: const Offset(0, 2),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),

                                const SizedBox(height: 8),

                                // Tagline
                                AnimatedBuilder(
                                  animation: _textController,
                                  builder: (context, child) {
                                    return FadeTransition(
                                      opacity: _textFadeAnimation,
                                      child: Text(
                                        'Premium Timepieces',
                                        style: GoogleFonts.inter(
                                          fontSize: 16,
                                          color: Colors.white.withValues(alpha:0.8),
                                          letterSpacing: 2.0,
                                          fontWeight: FontWeight.w300,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),

                // Loading Section
                Expanded(
                  flex: 1,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Progress Bar
                      AnimatedBuilder(
                        animation: _progressController,
                        builder: (context, child) {
                          return Container(
                            height: 4,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(2),
                              color: Colors.white.withValues(alpha:0.1),
                            ),
                            child: FractionallySizedBox(
                              alignment: Alignment.centerLeft,
                              widthFactor: _progressAnimation.value,
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(2),
                                  gradient: LinearGradient(
                                    colors: [
                                      AppColors.accent,
                                      AppColors.accent.withValues(alpha:0.8),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 24),

                      // Loading Message
                      AnimatedBuilder(
                        animation: _progressController,
                        builder: (context, child) {
                          return FadeTransition(
                            opacity: _progressAnimation,
                            child: Text(
                              'Preparing your luxury experience...',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                color: Colors.white.withValues(alpha:0.7),
                                letterSpacing: 0.5,
                              ),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 16),

                      // Premium Loading Widget
                      const PremiumLoadingWidget(
                        size: 40,
                        color: AppColors.accent,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
