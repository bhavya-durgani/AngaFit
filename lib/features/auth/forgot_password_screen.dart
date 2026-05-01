import 'package:flutter/material.dart'; // Flutter UI framework
import 'package:firebase_auth/firebase_auth.dart'; // Firebase Authentication (for reset email)
import '../../core/constants/app_colors.dart'; // App color constants
import '../../core/utils/error_handler.dart'; // Custom error handler utility

// Stateful widget because we need dynamic UI (loading state, form validation)
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key}); // Constructor

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState(); // Create state
}

// State class for ForgotPasswordScreen
class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {

  final _formKey = GlobalKey<FormState>(); // Key to manage form validation
  final _emailController = TextEditingController(); // Controller for email input
  bool _isLoading = false; // Loading state (button spinner)

  // Function to send password reset email
  Future<void> _sendResetEmail() async {

    // Validate form fields before proceeding
    if (_formKey.currentState!.validate()) {

      setState(() => _isLoading = true); // Show loading spinner

      try {
        // Call Firebase API to send reset email
        await FirebaseAuth.instance.sendPasswordResetEmail(
          email: _emailController.text.trim(), // Trim spaces from email
        );

        // Check if widget is still mounted before updating UI
        if (mounted) {

          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              backgroundColor: AppColors.success,
              content: Text("Reset link sent to your email ID!"),
            ),
          );

          Navigator.pop(context); // Go back to previous screen
        }

      } catch (e) {

        // If widget is not mounted, stop execution
        if (!mounted) return;

        // Show error message using custom error handler
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.error,
            content: Text(ErrorHandler.getErrorMessage(e)),
          ),
        );

      } finally {

        // Stop loading spinner (only if widget is still active)
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      backgroundColor: AppColors.background, // Set background color

      // App bar with back button
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, size: 32), // Back icon
          onPressed: () => Navigator.pop(context), // Go back
        ),
      ),

      // Scrollable content (important for smaller screens)
      body: SingleChildScrollView(

        padding: const EdgeInsets.all(16.0), // Page padding

        child: Form(
          key: _formKey, // Attach form key for validation

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, // Align left

            children: [

              const SizedBox(height: 18), // Space from top

              // Title text
              const Text(
                "Forgot password",
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 70), // Large spacing

              // Instruction text
              const Text(
                "Please, enter your email address. You will receive a link to create a new password via email.",
                style: TextStyle(fontSize: 14, height: 1.4),
              ),

              const SizedBox(height: 16),

              // Input field container (with shadow + styling)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),

                decoration: BoxDecoration(
                  color: Colors.white, // Background color
                  borderRadius: BorderRadius.circular(4), // Rounded corners

                  // Shadow effect
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    )
                  ],
                ),

                // Email input field
                child: TextFormField(
                  controller: _emailController, // Attach controller

                  // Validator function for email
                  validator: (v) =>
                      (v == null || !v.contains("@"))
                          ? "Not a valid email address"
                          : null,

                  // Input field decoration
                  decoration: const InputDecoration(
                    labelText: "Email", // Label
                    labelStyle: TextStyle(
                      color: AppColors.grey,
                      fontSize: 14,
                    ),
                    border: InputBorder.none, // Remove underline
                    errorStyle: TextStyle(color: AppColors.error),
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // Full-width button
              SizedBox(
                width: double.infinity,

                child: ElevatedButton(

                  // Disable button if loading
                  onPressed: _isLoading ? null : _sendResetEmail,

                  // Show spinner or text based on loading state
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("SEND"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
