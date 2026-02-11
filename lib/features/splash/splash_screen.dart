import 'dart:async';
import 'package:flutter/material.dart';
import '../auth/signup_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override void initState() {
    super.initState();
    Timer(const Duration(seconds: 3), () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const SignUpScreen())));
  }
  @override Widget build(BuildContext context) => const Scaffold(
      backgroundColor: Color(0xFFDB3022),
      body: Center(child: Text("ANGAFIT", style: TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.bold)))
  );
}
