import 'package:flutter/material.dart'; // Import Flutter UI toolkit

// Stateless widget for Sort Bottom Sheet
class SortBottomSheet extends StatelessWidget {
  const SortBottomSheet({super.key}); // Constructor

  @override
  Widget build(BuildContext context) {

    return Container(

      decoration: const BoxDecoration(
        color: Colors.white, // Background color
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(30) // Rounded top corners
        ),
      ),

      child: Column(
        mainAxisSize: MainAxisSize.min, // Take only required height

        children: [

          const SizedBox(height: 20), // Space from top

          // Title
          const Text(
            "Sort by",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)
          ),

          const SizedBox(height: 12), // Space

          // Sorting options
          _sortTile(context, "Newest"), // Option 1
          _sortTile(context, "Price: low to high"), // Option 2
          _sortTile(context, "Price: high to low"), // Option 3

          const SizedBox(height: 30), // Bottom space
        ],
      ),
    );
  }

  // Function to create each sorting option
  Widget _sortTile(BuildContext context, String title) {

    return ListTile(
      title: Text(title), // Display option text

      // When user taps → close bottom sheet and return selected option
      onTap: () => Navigator.pop(context, title),
    );
  }
}
