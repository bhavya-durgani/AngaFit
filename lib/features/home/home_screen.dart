import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../data/dummy_data.dart';
import '../product_details/product_details_screen.dart';
import 'widgets/product_card.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Immersive Top Banner
            Stack(
              children: [
                Image.network(
                  'https://images.unsplash.com/photo-1445205170230-053b830c6050',
                  height: 550, width: double.infinity, fit: BoxFit.cover,
                ),
                Container(height: 550, width: double.infinity, color: Colors.black26),
                Positioned(
                  bottom: 40, left: 20,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Fashion\nsale", style: TextStyle(color: Colors.white, fontSize: 48, fontWeight: FontWeight.w900, height: 1)),
                      const SizedBox(height: 15),
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryRed, padding: const EdgeInsets.symmetric(horizontal: 30)),
                        child: const Text("Check out"),
                      )
                    ],
                  ),
                )
              ],
            ),

            // New Arrivals Section
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("New", style: TextStyle(fontSize: 34, fontWeight: FontWeight.bold)),
                      Text("You've never seen it before!", style: TextStyle(color: AppColors.grey, fontSize: 11)),
                    ],
                  ),
                  TextButton(onPressed: () {}, child: const Text("View all", style: TextStyle(color: Colors.black))),
                ],
              ),
            ),

            // Product Grid
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, childAspectRatio: 0.6, crossAxisSpacing: 15, mainAxisSpacing: 15,
              ),
              itemCount: appProducts.length,
              itemBuilder: (context, index) {
                return ProductCard(
                  product: appProducts[index],
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ProductDetailsScreen())),
                );
              },
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
