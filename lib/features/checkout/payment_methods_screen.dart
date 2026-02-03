import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class PaymentMethodsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text("Payment methods")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Your payment cards", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            _buildCreditCard(Colors.black87, "**** **** **** 3947", "Jennyfer Doglas", "05/23"),
            const SizedBox(height: 20),
            _buildCreditCard(Colors.grey, "**** **** **** 4546", "Jennyfer Doglas", "11/22"),
            const Spacer(),
            Align(
              alignment: Alignment.centerRight,
              child: FloatingActionButton(
                onPressed: () {},
                backgroundColor: AppColors.black,
                child: const Icon(Icons.add, color: Colors.white),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildCreditCard(Color color, String number, String name, String date) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(8)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Align(alignment: Alignment.centerRight, child: Icon(Icons.credit_card, color: Colors.white)),
          const SizedBox(height: 30),
          Text(number, style: const TextStyle(color: Colors.white, fontSize: 24, letterSpacing: 2)),
          const SizedBox(height: 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _cardInfo("Card Holder Name", name),
              _cardInfo("Expiry Date", date),
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
        Text(label, style: const TextStyle(color: Colors.white54, fontSize: 10)),
        Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
