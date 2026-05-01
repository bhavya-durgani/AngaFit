import 'package:flutter/material.dart'; // Import Flutter UI toolkit
import '../../../core/constants/app_colors.dart'; // Import app colors

// Stateful widget for filter bottom sheet
class FilterBottomSheet extends StatefulWidget {

  final RangeValues initialRange; // Initial price range
  final String? initialSize; // Initial selected size (optional)
  final String? initialColor; // Initial selected color (optional)

  const FilterBottomSheet({
    super.key,
    required this.initialRange, // Required price range
    this.initialSize, // Optional size
    this.initialColor // Optional color
  });

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState(); // Link to state
}

// State class (handles UI updates)
class _FilterBottomSheetState extends State<FilterBottomSheet> {

  late RangeValues _currentRange; // Current selected price range
  String? _selectedSize; // Selected size
  String? _selectedColor; // Selected color

  // List of available sizes
  final List<String> sizes = ["XS", "S", "M", "L", "XL"];

  // List of colors with name + actual color value
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

    // Set initial values from widget
    _currentRange = widget.initialRange;
    _selectedSize = widget.initialSize;
    _selectedColor = widget.initialColor;
  }

  @override
  Widget build(BuildContext context) {

    return Container(
      padding: const EdgeInsets.all(20), // Padding inside sheet

      height: MediaQuery.of(context).size.height * 0.85, 
      // Take 85% of screen height

      decoration: const BoxDecoration(
        color: AppColors.background, // Background color
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)), // Rounded top corners
      ),

      child: SingleChildScrollView( // Makes content scrollable

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, // Align left

          children: [

            // Title
            const Center(
              child: Text(
                "Filters",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)
              )
            ),

            const SizedBox(height: 30), // Space

            // 1. PRICE RANGE
            const Text(
              "Price range",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)
            ),

            // Show selected range values
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("₹${_currentRange.start.round()}"), // Start value
                Text("₹${_currentRange.end.round()}"), // End value
              ],
            ),

            // Slider to select range
            RangeSlider(
              values: _currentRange, // Current range
              max: 10000, // Max value
              min: 0, // Min value
              activeColor: AppColors.primaryRed, // Slider color

              // Update range when user moves slider
              onChanged: (v) => setState(() => _currentRange = v),
            ),

            const SizedBox(height: 30),

            // 2. COLORS
            const Text(
              "Colors",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)
            ),

            const SizedBox(height: 15),

            // Display colors in wrap layout
            Wrap(
              spacing: 12,

              children: colors.map((c) => GestureDetector(

                // When color tapped
                onTap: () => setState(() => _selectedColor = c['name']),

                child: Container(
                  padding: const EdgeInsets.all(3),

                  decoration: BoxDecoration(
                    shape: BoxShape.circle,

                    // Highlight selected color
                    border: Border.all(
                      color: _selectedColor == c['name']
                          ? AppColors.primaryRed
                          : Colors.transparent,
                      width: 2
                    ),
                  ),

                  // Color circle
                  child: CircleAvatar(
                    backgroundColor: c['color'],
                    radius: 15
                  ),
                ),
              )).toList(),
            ),

            const SizedBox(height: 30),

            // 3. SIZES
            const Text(
              "Sizes",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)
            ),

            const SizedBox(height: 15),

            // Display sizes as selectable chips
            Wrap(
              spacing: 12,
              runSpacing: 12,

              children: sizes.map((s) => _buildChoiceChip(

                s, // Label
                _selectedSize == s, // Check if selected

                (selected) {
                  // Toggle selection
                  setState(() => _selectedSize = selected ? s : null);
                }

              )).toList(),
            ),

            const SizedBox(height: 60),

            // APPLY / CLEAR BUTTONS
            Row(
              children: [

                // Clear button
                Expanded(
                  child: OutlinedButton(

                    onPressed: () {
                      // Reset all filters
                      setState(() {
                        _currentRange = const RangeValues(0, 10000);
                        _selectedSize = null;
                        _selectedColor = null;
                      });
                    },

                    child: const Text("Clear All"),
                  ),
                ),

                const SizedBox(width: 16),

                // Apply button
                Expanded(
                  child: ElevatedButton(

                    onPressed: () {
                      // Return selected filters to previous screen
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
          ],
        ),
      ),
    );
  }

  // Reusable function to build size chips
  Widget _buildChoiceChip(
    String label, // Text on chip
    bool isSelected, // Whether selected
    Function(bool) onSelected // Callback
  ) {

    return ChoiceChip(
      label: Text(label), // Display label

      selected: isSelected, // Selected state
      onSelected: onSelected, // Action on tap

      selectedColor: AppColors.primaryRed, // Color when selected

      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.black // Text color
      ),

      backgroundColor: Colors.white, // Default background

      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8) // Rounded corners
      ),
    );
  }
}
