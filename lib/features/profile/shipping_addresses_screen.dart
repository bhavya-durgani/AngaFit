import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/constants/app_colors.dart';
import 'add_shipping_address_screen.dart';

class ShippingAddressesScreen extends StatelessWidget {
  const ShippingAddressesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text("Shipping Addresses"), centerTitle: true),
      body: uid == null
          ? const Center(child: Text("Please sign in to view addresses"))
          : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(uid)
                  .collection('addresses')
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                final docs = snapshot.data!.docs;

                if (docs.isEmpty) {
                  return const Center(child: Text("No shipping addresses found. Add one!"));
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;
                    final docId = docs[index].id;
                    final isDefault = data['isDefault'] ?? false;
                    return _addressCard(
                      context,
                      uid,
                      docId,
                      data['name'] ?? '',
                      data['address'] ?? '',
                      "${data['city'] ?? ''}, ${data['state'] ?? ''} ${data['zip'] ?? ''}",
                      isDefault,
                    );
                  },
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.black,
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddShippingAddressScreen())),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _addressCard(BuildContext context, String uid, String docId, String name, String street, String cityStateZip, bool isSelected) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [if (isSelected) BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
              GestureDetector(
                onTap: () {
                  FirebaseFirestore.instance
                      .collection('users')
                      .doc(uid)
                      .collection('addresses')
                      .doc(docId)
                      .delete();
                },
                child: const Text("Delete", style: TextStyle(color: AppColors.primaryRed)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(street),
          Text(cityStateZip),
          const SizedBox(height: 12),
          Row(
            children: [
              Checkbox(
                value: isSelected,
                activeColor: Colors.black,
                onChanged: (v) async {
                  if (v == true) {
                    // Turn off others
                    final batch = FirebaseFirestore.instance.batch();
                    final allDocs = await FirebaseFirestore.instance.collection('users').doc(uid).collection('addresses').get();
                    for (var d in allDocs.docs) {
                      batch.update(d.reference, {'isDefault': false});
                    }
                    batch.update(FirebaseFirestore.instance.collection('users').doc(uid).collection('addresses').doc(docId), {'isDefault': true});
                    await batch.commit();
                  }
                },
              ),
              const Text("Use as the shipping address"),
            ],
          )
        ],
      ),
    );
  }
}
