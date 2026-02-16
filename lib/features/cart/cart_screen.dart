import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/constants/app_colors.dart';
import '../checkout/checkout_screen.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text("My Bag"), centerTitle: true),
      body: user == null
          ? const Center(child: Text("Please login to view your bag"))
          : StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('users').doc(user.uid).collection('cart').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final docs = snapshot.data!.docs;

          if (docs.isEmpty) return const Center(child: Text("Your bag is empty"));

          double total = 0;
          for (var doc in docs) {
            total += (doc['price'] * doc['quantity']);
          }

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;
                    return _buildCartItem(docs[index].id, data, user.uid);
                  },
                ),
              ),
              _buildSummary(context, total),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCartItem(String docId, Map<String, dynamic> data, String uid) {
    return Container(
      height: 104, margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
      child: Row(children: [
        ClipRRect(borderRadius: const BorderRadius.horizontal(left: Radius.circular(8)), child: Image.network(data['imageUrl'], width: 100, fit: BoxFit.cover)),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
          Text(data['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
          Text("Qty: ${data['quantity']}", style: const TextStyle(color: AppColors.grey, fontSize: 12)),
          Text("₹${data['price']}", style: const TextStyle(fontWeight: FontWeight.bold)),
        ])),
        IconButton(
          icon: const Icon(Icons.delete_outline, color: AppColors.primaryRed),
          onPressed: () => FirebaseFirestore.instance.collection('users').doc(uid).collection('cart').doc(docId).delete(),
        ),
      ]),
    );
  }

  Widget _buildSummary(BuildContext context, double total) {
    return Container(
      padding: const EdgeInsets.all(20),
      color: Colors.white,
      child: Column(children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text("Total amount:"), Text("₹${total.toStringAsFixed(0)}", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold))]),
        const SizedBox(height: 20),
        SizedBox(width: double.infinity, child: ElevatedButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CheckoutScreen())), child: const Text("CHECK OUT")))
      ]),
    );
  }
}
