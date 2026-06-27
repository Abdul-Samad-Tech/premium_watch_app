import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'package:device_preview/device_preview.dart';
import 'providers/cart_provider.dart';
import 'providers/product_provider.dart';
import 'providers/wishlist_provider.dart';
import 'providers/user_provider.dart';
import 'providers/product_crud_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/enhanced_splash_screen.dart';
import 'core/theme/app_theme.dart';
import 'firebase_options.dart';

final logger = Logger();

void main() async {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase for all platforms
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    logger.d('Firebase initialization error: $e');
  }

  // Set preferred orientations
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(
    DevicePreview(
      enabled: !kReleaseMode,
      builder: (context) => const PremiumWatchApp(),
    ),
  );

  // Run comprehensive app test in debug mode
  if (kDebugMode) {
    Future.delayed(const Duration(seconds: 5), () async {
      // Note: This would be called after app is fully initialized
      // In production, you might want to remove this
      logger.d('App initialized successfully');
      // final results = await AppTester.runAllTests(context);
      // AppTester.generateTestReport(results);
    });
  }
}

class PremiumWatchApp extends StatelessWidget {
  const PremiumWatchApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => ProductCRUDProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProxyProvider<ProductProvider, WishlistProvider>(
          create: (_) {
            final wishlistProvider = WishlistProvider();
            wishlistProvider.loadWishlist();
            return wishlistProvider;
          },
          update: (_, productProvider, wishlistProvider) {
            wishlistProvider ??= WishlistProvider();
            wishlistProvider.syncWithCatalog(productProvider.allWatches);
            return wishlistProvider;
          },
        ),
      ],
      child: Consumer2<UserProvider, ThemeProvider>(
        builder: (context, userProvider, themeProvider, child) {
          return DevicePreview.appBuilder(
            context,
            MaterialApp(
              title: 'LUXE TIME',
              debugShowCheckedModeBanner: false,
              theme: appTheme(),
              darkTheme: ThemeData(
                brightness: Brightness.dark,
                primaryColor: const Color(0xFF1A1A1A),
                scaffoldBackgroundColor: const Color(0xFF121212),
                cardColor: const Color(0xFF1E1E1E),
                appBarTheme: const AppBarTheme(
                  backgroundColor: Color(0xFF1E1E1E),
                  elevation: 0,
                  iconTheme: IconThemeData(color: Colors.white),
                  titleTextStyle: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                textTheme: const TextTheme(
                  bodyLarge: TextStyle(color: Colors.white),
                  bodyMedium: TextStyle(color: Colors.white70),
                ),
                iconTheme: const IconThemeData(color: Colors.white),
                dividerColor: Colors.white24,
              ),
              themeMode: themeProvider.themeMode,
              home: const EnhancedSplashScreen(),
              locale: DevicePreview.locale(context),
              builder: DevicePreview.appBuilder,
            ),
          );
        },
      ),
    );
  }
}
