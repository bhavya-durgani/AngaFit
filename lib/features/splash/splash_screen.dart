import 'dart:async'; 
// Provides Timer functionality (used for splash delay)

import 'package:flutter/material.dart'; 
// Flutter UI framework

import 'package:firebase_auth/firebase_auth.dart'; 
// Firebase Authentication to check logged-in user

import '../../core/constants/app_colors.dart'; 
// Custom colors used in your app

import '../auth/signup_screen.dart'; 
// Screen shown if user is NOT logged in

import '../navigation/main_nav_wrapper.dart'; 
// Main app screen if user IS logged in


// Splash screen is a StatefulWidget because it has logic (timer + navigation)
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}


// State class for SplashScreen
class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    super.initState();
    _handleNavigation(); 
    // Called when screen loads → starts timer + navigation logic
  }

  // Function to control navigation after splash delay
  void _handleNavigation() {

    // 1. Wait for 3 seconds to show the logo
    Timer(const Duration(seconds: 3), () {

      if (!mounted) return; 
      // Safety check: ensures widget is still active before navigating

      // 2. Check Firebase for an existing login session
      User? user = FirebaseAuth.instance.currentUser;
      // Gets currently logged-in user (null if not logged in)

      if (user != null) {
        // If user exists → already logged in

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainNavWrapper()),
        );
        // Navigate to main app screen and REMOVE splash from stack

      } else {
        // If no user → not logged in

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const SignUpScreen()),
        );
        // Navigate to signup/login screen
      }
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: AppColors.primaryRed, 
      // Full screen background color

      body: Center(
        // Center all content vertically and horizontally

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            // App logo icon
            const Icon(
              Icons.shopping_bag,
              size: 100,
              color: Colors.white,
            ),

            const SizedBox(height: 20), 
            // Space between icon and text

            // App name / brand name
            const Text(
              "ANGAFIT",
              style: TextStyle(
                color: Colors.white,
                fontSize: 40,
                fontWeight: FontWeight.w900,
                letterSpacing: 4,
              ),
            ),

            const SizedBox(height: 10), 
            // Space between texts

            // Tagline / subtitle
            Text(
              "AR Style Hub",
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7),
                // Slightly transparent white color
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
