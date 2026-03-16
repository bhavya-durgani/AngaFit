import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../search/search_results_screen.dart';

class ProcessingFitScreen extends StatefulWidget {
  const ProcessingFitScreen({super.key});

  @override
  State<ProcessingFitScreen> createState() => _ProcessingFitScreenState();
}

class _ProcessingFitScreenState extends State<ProcessingFitScreen> {
  @override
  void initState() {
    super.initState();

    // Redirect to results after 3 seconds
    Timer(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const SearchResultsScreen(query: "Found for you"),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search, size: 80, color: AppColors.primaryRed),
            SizedBox(height: 30),
            Text(
              "Processing\nyour fit",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 34, fontWeight: FontWeight.w900, height: 1.2),
            ),
            SizedBox(height: 40),
            CircularProgressIndicator(color: AppColors.primaryRed),
          ],
        ),
      ),
    );
  }
}
