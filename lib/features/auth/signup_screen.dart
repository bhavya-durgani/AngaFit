import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import 'login_screen.dart';

class SignUpScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 80),
            const Text("Sign up", style: TextStyle(fontSize: 34, fontWeight: FontWeight.bold)),
            const SizedBox(height: 50),
            const TextField(decoration: InputDecoration(labelText: "Name", filled: true, fillColor: Colors.white)),
            const SizedBox(height: 8),
            const TextField(decoration: InputDecoration(labelText: "Email", filled: true, fillColor: Colors.white)),
            const SizedBox(height: 8),
            const TextField(decoration: InputDecoration(labelText: "Password", filled: true, fillColor: Colors.white)),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: InkWell(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => LoginScreen())),
                child: const Text("Already have an account? →"),
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginScreen())),
                child: const Text("SIGN UP"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
