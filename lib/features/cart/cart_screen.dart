import 'package:flutter/material.dart';
import 'success_screen.dart';

class CartScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => SuccessScreen())),
          child: const Text("CHECK OUT (USD 124.00)"),
        ),
      ),
    );
  }
}
