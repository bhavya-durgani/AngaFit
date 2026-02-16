import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/constants/app_colors.dart';
import '../cart/success_screen.dart';

class CheckoutScreen extends StatelessWidget {
  const CheckoutScreen({super.key});

  Future<void> _placeOrder(BuildContext context) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final cartRef = FirebaseFirestore.instance.collection('users').doc(uid).collection('cart');
    final orderRef = FirebaseFirestore.instance.collection('users').doc(uid).collection('orders');

    // 1. Get all items from cart
    final cartSnapshot = await cartRef.get();

    // 2. Create the order
    await orderRef.add({
      'total': 4098, // In a real app, pass the calculated total here
      'status': 'Delivered',
      'createdAt': FieldValue.serverTimestamp(),
      'itemsCount': cartSnapshot.docs.length,
    });

    // 3. Clear the cart
    for (var doc in cartSnapshot.docs) {
      await doc.reference.delete();
    }

    // 4. Redirect to Success
    if (context.mounted) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const SuccessScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Checkout"), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Shipping Address", style: TextStyle(fontWeight: FontWeight.bold)),
            const Card(child: ListTile(title: Text("Jane Doe"), subtitle: Text("3 Newbridge Court, Chino Hills, CA 91709, USA"))),
            const SizedBox(height: 20),
            const Text("Payment Method", style: TextStyle(fontWeight: FontWeight.bold)),
            const Card(child: ListTile(leading: Icon(Icons.credit_card), title: Text("**** **** **** 3947"), trailing: Icon(Icons.check_circle, color: Colors.green))),
            const Spacer(),
            const Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text("Order Total:"), Text("₹4,098", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold))]),
            const SizedBox(height: 20),
            SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                    onPressed: () => _placeOrder(context),
                    child: const Text("SUBMIT ORDER")
                )
            )
          ],
        ),
      ),
    );
  }
}
