import 'package:flutter/material.dart'; 
// Import Flutter UI framework

import 'package:firebase_core/firebase_core.dart'; 
// Required to initialize Firebase in the app

import 'package:provider/provider.dart'; 
// State management library (used for CartProvider)

import 'core/theme/app_theme.dart'; 
// Your custom app theme (colors, styles)

import 'core/utils/cart_provider.dart'; 
// Cart state logic (add/remove items, etc.)

import 'features/splash/splash_screen.dart'; 
// First screen shown when app starts

import 'firebase_options.dart'; 
// AUTO-GENERATED Firebase configuration file

import 'package:flutter_dotenv/flutter_dotenv.dart'; 
// Used to load environment variables from .env file


void main() async {
  // Entry point of Flutter app

  WidgetsFlutterBinding.ensureInitialized(); 
  // Ensures Flutter engine is initialized before async calls

  await dotenv.load(fileName: ".env"); 
  // Load environment variables (API keys, etc.)

  try {
    // Try initializing Firebase

    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
      // Use platform-specific Firebase config (Android/iOS/Web)
    );

  } catch (e) {
    // Catch error if Firebase fails

    debugPrint("Firebase Initialization Error: $e"); 
    // Print error in console (debug only)
  }

  runApp(
    // Starts the Flutter app

    MultiProvider(
      // Used to provide multiple global states

      providers: [
        ChangeNotifierProvider(
          create: (_) => CartProvider(),
          // Create CartProvider and make it available everywhere
        ),
      ],

      child: const AngaFit(),
      // Root widget of your app
    ),
  );
}


// Root widget of the application
class AngaFit extends StatelessWidget {
  const AngaFit({super.key});

  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      // Main app configuration

      debugShowCheckedModeBanner: false,
      // Removes "debug" banner from top-right

      title: 'AngaFit',
      // App name

      theme: AppTheme.lightTheme,
      // Apply your custom theme

      home: const SplashScreen(),
      // First screen → decides navigation (login/home)
    );
  }
}
