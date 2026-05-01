import 'package:flutter/material.dart'; // Flutter UI toolkit
import 'package:cloud_firestore/cloud_firestore.dart'; // Firestore database
import 'package:firebase_auth/firebase_auth.dart'; // Firebase authentication
import '../../core/constants/app_colors.dart'; // App colors
import 'add_payment_method_screen.dart'; // Screen to add new card

// Stateless widget (UI does not manage its own changing state)
class PaymentMethodsScreen extends StatelessWidget {
  const PaymentMethodsScreen({super.key}); // Constructor

  @override
  Widget build(BuildContext context) {

    // Get current user ID
    final uid = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      backgroundColor: AppColors.background, // Background color

      appBar: AppBar(
        title: const Text("Payment methods"), // Title
        centerTitle: true
      ),

      // BODY
      body: uid == null
          // If user not logged in
          ? const Center(child: Text("Please sign in to view payment methods"))

          // If user is logged in
          : StreamBuilder<QuerySnapshot>(

              // Listen to paymentMethods collection in Firestore
              stream: FirebaseFirestore.instance
                  .collection('users') // users collection
                  .doc(uid) // current user
                  .collection('paymentMethods') // subcollection
                  .orderBy('createdAt', descending: true) // newest first
                  .snapshots(), // live updates

              builder: (context, snapshot) {

                // Show loading while fetching data
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final docs = snapshot.data!.docs; // List of payment methods

                return Padding(
                  padding: const EdgeInsets.all(16.0),

                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [

                      // Title
                      const Text(
                        "Your payment cards",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)
                      ),

                      const SizedBox(height: 20),

                      // If no cards exist
                      if (docs.isEmpty)
                        const Expanded(
                          child: Center(child: Text("No payment methods added."))
                        )

                      // If cards exist → show list
                      else
                        Expanded(
                          child: ListView.builder(

                            itemCount: docs.length,

                            itemBuilder: (context, index) {

                              // Get card data
                              final data = docs[index].data() as Map<String, dynamic>;

                              final docId = docs[index].id; // Document ID

                              final isDefault = data['isDefault'] ?? false; // Default card

                              // Color based on default
                              final color = isDefault
                                  ? Colors.black87
                                  : AppColors.grey;

                              return Padding(
                                padding: const EdgeInsets.only(bottom: 20),

                                // Build card UI
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

                      // Add new card button
                      Align(
                        alignment: Alignment.centerRight,

                        child: FloatingActionButton(
                          backgroundColor: AppColors.black,

                          // Navigate to Add Payment Screen
                          onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const AddPaymentMethodScreen())
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

  // Widget to build each payment card
  Widget _buildCard(
      BuildContext context,
      String uid,
      String docId,
      String number,
      String name,
      String expiry,
      Color color,
      bool isDefault) {

    return GestureDetector(

      // Long press → delete card
      onLongPress: () {

        showDialog(
          context: context,

          builder: (context) => AlertDialog(

            title: const Text("Delete Card"),

            content: const Text(
                "Are you sure you want to remove this payment method?"),

            actions: [

              // Cancel button
              TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel")
              ),

              // Delete button
              TextButton(
                onPressed: () {

                  // Delete card from Firestore
                  FirebaseFirestore.instance
                      .collection('users')
                      .doc(uid)
                      .collection('paymentMethods')
                      .doc(docId)
                      .delete();

                  Navigator.pop(context); // Close dialog
                },

                child: const Text(
                  "Delete",
                  style: TextStyle(color: AppColors.primaryRed)
                ),
              ),
            ],
          ),
        );
      },

      // Tap → set as default card
      onTap: () async {

        // Only if not already default
        if (!isDefault) {

          final batch = FirebaseFirestore.instance.batch(); // Batch operation

          // Get all cards
          final allDocs = await FirebaseFirestore.instance
              .collection('users')
              .doc(uid)
              .collection('paymentMethods')
              .get();

          // Set all cards to not default
          for (var d in allDocs.docs) {
            batch.update(d.reference, {'isDefault': false});
          }

          // Set selected card as default
          batch.update(
            FirebaseFirestore.instance
                .collection('users')
                .doc(uid)
                .collection('paymentMethods')
                .doc(docId),
            {'isDefault': true}
          );

          await batch.commit(); // Apply changes
        }
      },

      // CARD UI
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),

        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),

          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 4)
            )
          ],
        ),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [

            // Card icon
            const Align(
              alignment: Alignment.centerRight,
              child: Icon(Icons.credit_card, color: Colors.white, size: 28)
            ),

            const SizedBox(height: 25),

            // Card number
            Text(
              number,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                letterSpacing: 2,
                fontWeight: FontWeight.bold
              )
            ),

            const SizedBox(height: 35),

            // Name + expiry
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

  // Small widget for card info (label + value)
  Widget _cardInfo(String label, String value) {

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [

        // Label (small text)
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 10)
        ),

        // Value (bold text)
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 14
          )
        ),
      ],
    );
  }
}
