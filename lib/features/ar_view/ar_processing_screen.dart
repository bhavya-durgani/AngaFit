import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class ARProcessingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.search, size: 60, color: AppColors.primaryRed),
            const SizedBox(height: 20),
            const Text(
              "Processing\nyour\nfit",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 34, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
