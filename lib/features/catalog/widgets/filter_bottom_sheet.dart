import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class FilterBottomSheet extends StatefulWidget {
  const FilterBottomSheet({super.key});

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  RangeValues _currentRange = const RangeValues(500, 5000);
  String selectedSize = "M";

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Center(child: Text("Filters", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
          const SizedBox(height: 30),

          const Text("Price range", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("₹${_currentRange.start.round()}"),
              Text("₹${_currentRange.end.round()}"),
            ],
          ),
          RangeSlider(
            values: _currentRange,
            max: 10000,
            min: 0,
            activeColor: AppColors.primaryRed,
            onChanged: (v) => setState(() => _currentRange = v),
          ),

          const SizedBox(height: 30),
          const Text("Sizes", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 15),
          Wrap(
            spacing: 12,
            children: ["XS", "S", "M", "L", "XL"].map((s) => _sizeChip(s)).toList(),
          ),

          const Spacer(),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Discard"),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Apply"),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _sizeChip(String size) {
    bool isSelected = selectedSize == size;
    return GestureDetector(
      onTap: () => setState(() => selectedSize = size),
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryRed : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: isSelected ? AppColors.primaryRed : Colors.grey.shade300),
        ),
        child: Center(
          child: Text(size, style: TextStyle(color: isSelected ? Colors.white : Colors.black)),
        ),
      ),
    );
  }
}
