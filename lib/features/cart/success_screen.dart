import 'package:flutter/material.dart';
import '../navigation/main_nav_wrapper.dart';

class SuccessScreen extends StatelessWidget {
  const SuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle_outline, size: 100, color: Colors.green),
            const SizedBox(height: 20),
            const Text("Success!", style: TextStyle(fontSize: 34, fontWeight: FontWeight.bold)),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () => Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const MainNavWrapper()), (r) => false),
              child: const Text("CONTINUE SHOPPING"),
            )
          ],
        ),
      ),
    );
  }
}
