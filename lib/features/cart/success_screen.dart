import 'package:flutter/material.dart'; // Import Flutter UI toolkit
import '../navigation/main_nav_wrapper.dart'; // Import main navigation screen

// Stateless widget for Success screen
class SuccessScreen extends StatelessWidget {
  const SuccessScreen({super.key}); // Constructor

  @override
  Widget build(BuildContext context) {

    // Main UI structure
    return Scaffold(

      body: Center( // Center everything on screen

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // Center vertically

          children: [

            // Success icon (green tick)
            const Icon(
              Icons.check_circle_outline,
              size: 100,
              color: Colors.green
            ),

            const SizedBox(height: 20), // Space

            // Success text
            const Text(
              "Success!",
              style: TextStyle(fontSize: 34, fontWeight: FontWeight.bold)
            ),

            const SizedBox(height: 40), // Space

            // Button to go back to main shopping screen
            ElevatedButton(

              // When pressed → go to main navigation and remove all previous screens
              onPressed: () => Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (_) => const MainNavWrapper() // Go to main screen
                ),
                (r) => false // Remove all previous routes (no back button)
              ),

              child: const Text("CONTINUE SHOPPING"), // Button text
            )
          ],
        ),
      ),
    );
  }
}
