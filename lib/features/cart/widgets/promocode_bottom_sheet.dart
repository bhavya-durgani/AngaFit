import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class PromocodeBottomSheet extends StatelessWidget {
  const PromocodeBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      height: 450,
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(width: 60, height: 6, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10))),
          ),
          const SizedBox(height: 24),
          _buildPromoInput(),
          const SizedBox(height: 32),
          const Text("Your Promo Codes", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 18),
          Expanded(
            child: ListView(
              children: [
                _promoCard("Personal offer", "mypromocode2025", "10% off", Colors.red),
                _promoCard("Summer Sale", "summer2025", "15% off", Colors.black),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPromoInput() {
    return Container(
      padding: const EdgeInsets.only(left: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: Row(
        children: [
          const Expanded(child: TextField(decoration: InputDecoration(hintText: "Enter your promo code", border: InputBorder.none))),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(color: AppColors.black, shape: BoxShape.circle),
            child: const Icon(Icons.arrow_forward, color: Colors.white),
          )
        ],
      ),
    );
  }

  Widget _promoCard(String title, String code, String discount, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
      child: Row(
        children: [
          Container(
            width: 80, height: 80,
            decoration: BoxDecoration(color: color, borderRadius: const BorderRadius.horizontal(left: Radius.circular(8))),
            child: Center(child: Text(discount, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(code, style: const TextStyle(fontSize: 11)),
            ],
          ),
          const Spacer(),
          TextButton(onPressed: () {}, child: const Text("Apply", style: TextStyle(color: AppColors.primaryRed))),
        ],
      ),
    );
  }
}
