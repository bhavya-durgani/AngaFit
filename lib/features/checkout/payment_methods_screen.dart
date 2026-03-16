import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/constants/app_colors.dart';
import 'add_payment_method_screen.dart';

class PaymentMethodsScreen extends StatelessWidget {
  const PaymentMethodsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text("Payment methods"), centerTitle: true),
      body: uid == null
          ? const Center(child: Text("Please sign in to view payment methods"))
          : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(uid)
                  .collection('paymentMethods')
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                final docs = snapshot.data!.docs;

                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Your payment cards", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 20),
                      if (docs.isEmpty)
                        const Expanded(child: Center(child: Text("No payment methods added.")))
                      else
                        Expanded(
                          child: ListView.builder(
                            itemCount: docs.length,
                            itemBuilder: (context, index) {
                              final data = docs[index].data() as Map<String, dynamic>;
                              final docId = docs[index].id;
                              final isDefault = data['isDefault'] ?? false;
                              final color = isDefault ? Colors.black87 : AppColors.grey;
                              
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 20),
                                child: _buildCard(
                                  context,
                                  uid,
                                  docId,
                                  data['cardNumber'] ?? '**** **** **** ****',
                                  data['cardHolder'] ?? 'Unknown',
                                  data['expiryDate'] ?? 'MM/YY',
                                  color,
                                  isDefault
                                ),
                              );
                            },
                          ),
                        ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: FloatingActionButton(
                          backgroundColor: AppColors.black,
                          onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const AddPaymentMethodScreen())
                          ),
                          child: const Icon(Icons.add, color: Colors.white),
                        ),
                      )
                    ],
                  ),
                );
              },
            ),
    );
  }

  Widget _buildCard(BuildContext context, String uid, String docId, String number, String name, String expiry, Color color, bool isDefault) {
    return GestureDetector(
      onLongPress: () {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Delete Card"),
            content: const Text("Are you sure you want to remove this payment method?"),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
              TextButton(
                onPressed: () {
                  FirebaseFirestore.instance
                      .collection('users')
                      .doc(uid)
                      .collection('paymentMethods')
                      .doc(docId)
                      .delete();
                  Navigator.pop(context);
                },
                child: const Text("Delete", style: TextStyle(color: AppColors.primaryRed)),
              ),
            ],
          ),
        );
      },
      onTap: () async {
        if (!isDefault) {
          final batch = FirebaseFirestore.instance.batch();
          final allDocs = await FirebaseFirestore.instance.collection('users').doc(uid).collection('paymentMethods').get();
          for (var d in allDocs.docs) {
            batch.update(d.reference, {'isDefault': false});
          }
          batch.update(FirebaseFirestore.instance.collection('users').doc(uid).collection('paymentMethods').doc(docId), {'isDefault': true});
          await batch.commit();
        }
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: color.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 4))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Align(alignment: Alignment.centerRight, child: Icon(Icons.credit_card, color: Colors.white, size: 28)),
            const SizedBox(height: 25),
            Text(number, style: const TextStyle(color: Colors.white, fontSize: 22, letterSpacing: 2, fontWeight: FontWeight.bold)),
            const SizedBox(height: 35),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _cardInfo("Card Holder Name", name),
                _cardInfo("Expiry Date", expiry),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _cardInfo(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 10)),
        Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
      ],
    );
  }
}
