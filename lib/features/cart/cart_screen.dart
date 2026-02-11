import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../data/dummy_data.dart';
import '../product_details/product_details_screen.dart';
import '../checkout/checkout_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});
  @override State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("My Bag"), centerTitle: true),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: 2,
              itemBuilder: (context, index) => _buildCartItem(appProducts[index]),
            ),
          ),
          _buildSummary(),
        ],
      ),
    );
  }

  Widget _buildCartItem(Product p) {
    return InkWell(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ProductDetailsScreen(product: p))),
      child: Container(
        height: 104, margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
        child: Row(children: [
          ClipRRect(borderRadius: const BorderRadius.horizontal(left: Radius.circular(8)), child: Image.network(p.imageUrl, width: 100, fit: BoxFit.cover)),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
            Text(p.name, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Row(children: [
              _circleIcon(Icons.remove, () {}),
              const Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: Text("1")),
              _circleIcon(Icons.add, () {}),
              const Spacer(),
              Text(p.price, style: const TextStyle(fontWeight: FontWeight.bold)),
            ])
          ])),
          IconButton(icon: const Icon(Icons.delete_outline, color: AppColors.primaryRed), onPressed: () {}),
        ]),
      ),
    );
  }

  Widget _circleIcon(IconData icon, VoidCallback onTap) {
    return InkWell(onTap: onTap, child: Container(padding: const EdgeInsets.all(4), decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.grey)), child: Icon(icon, size: 16)));
  }

  Widget _buildSummary() {
    return Container(
      padding: const EdgeInsets.all(20),
      color: Colors.white,
      child: Column(children: [
        const Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text("Total amount:"), Text("₹4,098", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))]),
        const SizedBox(height: 20),
        SizedBox(width: double.infinity, child: ElevatedButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CheckoutScreen())), child: const Text("CHECK OUT")))
      ]),
    );
  }
}
