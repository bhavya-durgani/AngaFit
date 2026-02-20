import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class SortBottomSheet extends StatelessWidget {
  const SortBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 20),
          const Text("Sort by", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          _sortTile(context, "Newest"),
          _sortTile(context, "Price: low to high"),
          _sortTile(context, "Price: high to low"),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _sortTile(BuildContext context, String title) {
    return ListTile(
      title: Text(title),
      // Logic: Closes the sheet and sends the title back to ProductListScreen
      onTap: () => Navigator.pop(context, title),
    );
  }
}
