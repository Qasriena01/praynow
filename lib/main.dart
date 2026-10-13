import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:praynow/auth/onboarding.dart';
import 'package:praynow/screens/splash_screen.dart';
import 'package:praynow/auth/forgot_password.dart';
import 'package:praynow/screens/home_navigation.dart';
import 'package:praynow/auth/login.dart';
import 'package:praynow/auth/register.dart';
import 'package:praynow/theme/app_theme.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:praynow/services/notification_service.dart'; // ADD THIS LINE

// Import Firebase options if using FlutterFire CLI
// import 'firebase_options.dart';

/// Main entry point of the PrayNow application
void main() async {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables from .env file
  try {
    await dotenv.load(fileName: ".env");
    debugPrint('✅ Environment variables loaded successfully');
  } catch (e) {
    debugPrint('⚠️ No .env file found or error loading: $e');
  }

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  // Set preferred orientations (portrait only)
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize Firebase
  try {
    await Firebase.initializeApp(
      // If using FlutterFire CLI, uncomment this:
      // options: DefaultFirebaseOptions.currentPlatform,
    );
    debugPrint('✅ Firebase initialized successfully');
  } catch (e) {
    debugPrint('❌ Firebase initialization error: $e');
  }

  // Initialize notifications
  try {
    await NotificationService.initialize();
    debugPrint('✅ Notifications initialized successfully');
  } catch (e) {
    debugPrint('❌ Notification initialization error: $e');
  }

  // Run the app
  runApp(const PrayNowApp());
}

/// Main application widget
class PrayNowApp extends StatelessWidget {
  const PrayNowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // App configuration
      title: 'PrayNow',
      debugShowCheckedModeBanner: false,

      // Theme configuration
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light, // or ThemeMode.system for auto

      // Localization (if needed)
      // locale: const Locale('en', 'US'),
      // supportedLocales: const [
      //   Locale('en', 'US'),
      //   Locale('ms', 'MY'),
      // ],

      // Route configuration
      initialRoute: '/',
      onGenerateRoute: _generateRoute,
      
      // Handle unknown routes
      onUnknownRoute: (settings) {
        return MaterialPageRoute(
          builder: (context) => const Scaffold(
            body: Center(
              child: Text('Page not found'),
            ),
          ),
        );
      },

      // Navigation observers (for analytics if needed)
      // navigatorObservers: [
      //   FirebaseAnalyticsObserver(analytics: analytics),
      // ],

      // Builder for global UI configuration
      builder: (context, child) {
        return MediaQuery(
          // Prevent text scaling issues
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(MediaQuery.of(context).textScaleFactor.clamp(0.8, 1.2)),
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }

  /// Generate routes with enhanced navigation
  Route<dynamic>? _generateRoute(RouteSettings settings) {
    // Log navigation for debugging
    debugPrint('📱 Navigating to: ${settings.name}');

    switch (settings.name) {
      case '/':
        return _buildRoute(
          const SplashScreen(),
          settings: settings,
        );

      case '/onboarding':
        return _buildRoute(
          const OnboardingPage(),
          settings: settings,
        );

      case '/login':
        return _buildRoute(
          const LoginPage(),
          settings: settings,
        );

      case '/register':
        return _buildRoute(
          const RegisterPage(),
          settings: settings,
        );

      case '/forgot':
        return _buildRoute(
          const ForgotPasswordPage(),
          settings: settings,
        );

      case '/home':
        // Check authentication before navigating to home
        return _buildAuthenticatedRoute(
          const HomeNavigation(),
          settings: settings,
        );

      default:
        return null;
    }
  }

  /// Build standard route with page transition
  PageRoute _buildRoute(Widget page, {required RouteSettings settings}) {
    return MaterialPageRoute(
      builder: (context) => page,
      settings: settings,
    );
  }

  /// Build authenticated route with auth check
  PageRoute _buildAuthenticatedRoute(Widget page, {required RouteSettings settings}) {
    return MaterialPageRoute(
      builder: (context) {
        // Check if user is authenticated
        final user = FirebaseAuth.instance.currentUser;
        
        if (user != null) {
          // User is authenticated, show the page
          return page;
        } else {
          // User is not authenticated, redirect to login
          debugPrint('⚠️ User not authenticated, redirecting to login');
          
          // Show login page with a message
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Row(
                  children: [
                    Icon(Icons.lock, color: Colors.white),
                    SizedBox(width: 12),
                    Text('Please login to continue'),
                  ],
                ),
                backgroundColor: Colors.orange[600],
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            );
          });
          
          return const LoginPage();
        }
      },
      settings: settings,
    );
  }
}
