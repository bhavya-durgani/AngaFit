import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/constants/app_colors.dart';
import '../auth/signup_screen.dart';
import '../navigation/main_nav_wrapper.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _handleNavigation();
  }

  void _handleNavigation() {
    // 1. Wait for 3 seconds to show the logo
    Timer(const Duration(seconds: 3), () {
      if (!mounted) return;

      // 2. Check Firebase for an existing login session
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        // User is already logged in -> Go to Home
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainNavWrapper()),
        );
      } else {
        // No user found -> Go to Sign Up flow
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const SignUpScreen()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryRed,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Your brand icon
            const Icon(
              Icons.shopping_bag,
              size: 100,
              color: Colors.white,
            ),
            const SizedBox(height: 20),
            // Your brand name
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
            Text(
              "AR Style Hub",
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
