import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../ar_view/ar_try_on_screen.dart'; // Fixed Path
import '../navigation/main_nav_wrapper.dart';

class ProductDetailsScreen extends StatelessWidget {
  const ProductDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Product Details")),
      body: Column(
        children: [
          Image.network(
              'https://images.unsplash.com/photo-1515886657613-9f3515b0c78f',
              height: 350,
              width: double.infinity,
              fit: BoxFit.cover
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
                    onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ARTryOnScreen()) // Removed const
                    ),
                    child: const Text("TRY IT ON YOURSELF"),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => const MainNavWrapper())
                    ),
                    child: const Text("ADD TO CART"),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
