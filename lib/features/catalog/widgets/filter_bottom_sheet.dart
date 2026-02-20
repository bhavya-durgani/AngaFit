import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class FilterBottomSheet extends StatefulWidget {
  final RangeValues initialRange;
  final String? initialSize;
  final String? initialColor;

  const FilterBottomSheet({
    super.key,
    required this.initialRange,
    this.initialSize,
    this.initialColor
  });

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  late RangeValues _currentRange;
  String? _selectedSize;
  String? _selectedColor;

  final List<String> sizes = ["XS", "S", "M", "L", "XL"];
  final List<Map<String, dynamic>> colors = [
    {"name": "Black", "color": Colors.black},
    {"name": "White", "color": Colors.white},
    {"name": "Red", "color": Colors.red},
    {"name": "Blue", "color": Colors.blue},
    {"name": "Beige", "color": const Color(0xFFF5F5DC)},
  ];

  @override
  void initState() {
    super.initState();
    _currentRange = widget.initialRange;
    _selectedSize = widget.initialSize;
    _selectedColor = widget.initialColor;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(child: Text("Filters", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
            const SizedBox(height: 30),

            // 1. PRICE RANGE
            const Text("Price range", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("₹${_currentRange.start.round()}"),
                Text("₹${_currentRange.end.round()}"),
              ],
            ),
            RangeSlider(
              values: _currentRange,
              max: 10000, min: 0,
              activeColor: AppColors.primaryRed,
              onChanged: (v) => setState(() => _currentRange = v),
            ),

            const SizedBox(height: 30),

            // 2. COLORS
            const Text("Colors", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 15),
            Wrap(
              spacing: 12,
              children: colors.map((c) => GestureDetector(
                onTap: () => setState(() => _selectedColor = c['name']),
                child: Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: _selectedColor == c['name'] ? AppColors.primaryRed : Colors.transparent,
                        width: 2
                    ),
                  ),
                  child: CircleAvatar(backgroundColor: c['color'], radius: 15),
                ),
              )).toList(),
            ),

            const SizedBox(height: 30),

            // 3. SIZES
            const Text("Sizes", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 15),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: sizes.map((s) => _buildChoiceChip(s, _selectedSize == s, (selected) {
                setState(() => _selectedSize = selected ? s : null);
              })).toList(),
            ),

            const SizedBox(height: 60),

            // APPLY BUTTON
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context, {
                    'range': _currentRange,
                    'size': _selectedSize,
                    'color': _selectedColor,
                  });
                },
                child: const Text("Apply"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChoiceChip(String label, bool isSelected, Function(bool) onSelected) {
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: onSelected,
      selectedColor: AppColors.primaryRed,
      labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black),
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    );
  }
}
