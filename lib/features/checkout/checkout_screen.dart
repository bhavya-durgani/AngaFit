import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../cart/success_screen.dart';

class CheckoutScreen extends StatelessWidget {
  const CheckoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Checkout"), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text("Shipping Address", style: TextStyle(fontWeight: FontWeight.bold)),
          const Card(child: ListTile(title: Text("Jane Doe"), subtitle: Text("3 Newbridge Court, Chino Hills, CA 91709, USA"))),
          const SizedBox(height: 20),
          const Text("Payment Method", style: TextStyle(fontWeight: FontWeight.bold)),
          const Card(child: ListTile(leading: Icon(Icons.credit_card), title: Text("**** **** **** 3947"), trailing: Icon(Icons.check_circle, color: Colors.green))),
          const Spacer(),
          const Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text("Order Total:"), Text("₹4,098", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold))]),
          const SizedBox(height: 20),
          SizedBox(width: double.infinity, child: ElevatedButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SuccessScreen())), child: const Text("SUBMIT ORDER")))
        ]),
      ),
    );
  }
}
