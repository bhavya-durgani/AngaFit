import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class PaymentMethodsScreen extends StatelessWidget {
  const PaymentMethodsScreen({super.key});

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
            const Text("Your payment cards", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            _buildCreditCard(const Color(0xFF222222), "**** **** **** 3947", "Jennyfer Doglas", "05/23"),
            const SizedBox(height: 24),
            _buildCreditCard(const Color(0xFF9B9B9B), "**** **** **** 4546", "Jennyfer Doglas", "11/22"),
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
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(8), boxShadow: [BoxShadow(color: color.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5))]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Align(alignment: Alignment.centerRight, child: Icon(Icons.credit_card, color: Colors.white)),
          const SizedBox(height: 20),
          Text(number, style: const TextStyle(color: Colors.white, fontSize: 24, letterSpacing: 2)),
          const SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _labelValue("Card Holder Name", name),
              _labelValue("Expiry Date", date),
            ],
          )
        ],
      ),
    );
  }

  Widget _labelValue(String l, String v) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(l, style: const TextStyle(color: Colors.white70, fontSize: 10)),
      Text(v, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
    ]);
  }
}
