import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import 'add_payment_method_screen.dart';

class PaymentMethodsScreen extends StatelessWidget {
  const PaymentMethodsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text("Payment methods"), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Your payment cards", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 20),
            _buildCard("**** **** **** 3947", "Jane Doe", "05/26", Colors.black87),
            const SizedBox(height: 20),
            _buildCard("**** **** **** 4546", "Jane Doe", "11/24", AppColors.grey),
            const Spacer(),
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
      ),
    );
  }

  Widget _buildCard(String number, String name, String expiry, Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: color.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))],
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
