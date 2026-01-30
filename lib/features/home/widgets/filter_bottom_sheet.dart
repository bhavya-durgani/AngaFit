import 'package:flutter/material.dart';
class FilterBottomSheet extends StatefulWidget {
  const FilterBottomSheet({super.key});

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}
class _FilterBottomSheetState extends State<FilterBottomSheet> {
  RangeValues _priceRange = const RangeValues(20, 200);
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(30),
      height: MediaQuery.of(context).size.height * 0.6,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Filter Options", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 30),
          const Text("Price Range"),
          RangeSlider(
            values: _priceRange,
            max: 1000,
            activeColor: Colors.black,
            labels: RangeLabels("USD ${_priceRange.start}", "USD ${_priceRange.end}"),
            onChanged: (v) => setState(() => _priceRange = v),
          ),
          const SizedBox(height: 20),
          const Text("Sizes"),
          const SizedBox(height: 10),
          Row(
            children: ['S', 'M', 'L', 'XL'].map((s) => Container(
              margin: const EdgeInsets.only(right: 10),
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(border: Border.all(color: Colors.grey[300]!), borderRadius: BorderRadius.circular(10)),
              child: Text(s),
            )).toList(),
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.black, padding: const EdgeInsets.all(20)),
              child: const Text("Apply Filters", style: TextStyle(color: Colors.white)),
            ),
          )
        ],
      ),
    );
  }
}