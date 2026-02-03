import 'package:flutter/material.dart';
import '../auth/signup_screen.dart';

class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: TextButton(
          onPressed: () => Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => SignUpScreen()), (route) => false),
          child: const Text("LOGOUT", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }
}
