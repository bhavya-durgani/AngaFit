import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../navigation/main_nav_wrapper.dart';

class SuccessScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle_outline, size: 100, color: AppColors.success),
            const SizedBox(height: 20),
            const Text("Success!", style: TextStyle(fontSize: 34, fontWeight: FontWeight.bold)),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () => Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const MainNavWrapper()), (route) => false),
              child: const Text("CONTINUE SHOPPING"),
            )
          ],
        ),
      ),
    );
  }
}
