import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class FilterSheet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      height: MediaQuery.of(context).size.height * 0.8,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Center(child: Text("Filters", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
          const SizedBox(height: 24),
          const Text("Price range", style: TextStyle(fontWeight: FontWeight.bold)),
          RangeSlider(values: const RangeValues(78, 143), min: 0, max: 200, onChanged: (v){}, activeColor: AppColors.primaryRed),
          const SizedBox(height: 24),
          const Text("Colors", style: TextStyle(fontWeight: FontWeight.bold)),
          Row(
            children: [
              _colorCircle(Colors.black),
              _colorCircle(Colors.white),
              _colorCircle(Colors.red),
              _colorCircle(Colors.brown),
            ],
          ),
          const Spacer(),
          Row(
            children: [
              Expanded(child: OutlinedButton(onPressed: () {}, child: const Text("Discard"))),
              const SizedBox(width: 16),
              Expanded(child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryRed),
                child: const Text("Apply", style: TextStyle(color: Colors.white)),
              )),
            ],
          )
        ],
      ),
    );
  }

  Widget _colorCircle(Color color) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      width: 36, height: 36,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle, border: Border.all(color: Colors.grey.shade300)),
    );
  }
}
