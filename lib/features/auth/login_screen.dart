import 'package:flutter/material.dart';
import '../navigation/main_nav_wrapper.dart';

class LoginScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 80),
            const Text("Login", style: TextStyle(fontSize: 34, fontWeight: FontWeight.bold)),
            const SizedBox(height: 50),
            const TextField(decoration: InputDecoration(labelText: "Email", filled: true, fillColor: Colors.white)),
            const SizedBox(height: 8),
            const TextField(decoration: InputDecoration(labelText: "Password", filled: true, fillColor: Colors.white)),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const MainNavWrapper())),
                child: const Text("LOGIN"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
