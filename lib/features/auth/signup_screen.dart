import 'package:flutter/material.dart'; // Imports Flutter UI toolkit
import '../../core/constants/app_colors.dart'; // Imports app color constants
import '../../core/utils/error_handler.dart'; // Imports error handling utility
import '../../data/services/auth_service.dart'; // Imports authentication service
import 'login_screen.dart'; // Imports login screen

// Creates a SignUpScreen widget (stateful because UI changes)
class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key}); // Constructor

  @override 
  State<SignUpScreen> createState() => _SignUpScreenState(); // Links to state class
}

// State class where logic and UI handling happens
class _SignUpScreenState extends State<SignUpScreen> {

  final _formKey = GlobalKey<FormState>(); // Key to manage form validation

  final _nameController = TextEditingController(); // Controller for name input
  final _emailController = TextEditingController(); // Controller for email input
  final _passwordController = TextEditingController(); // Controller for password input

  bool _isLoading = false; // Tracks if signup process is running

  // Function to handle signup logic
  Future<void> _handleSignUp() async {

    // Check if form inputs are valid
    if (_formKey.currentState!.validate()) {

      setState(() => _isLoading = true); // Show loading state

      try {
        // Call signup service with user inputs
        await AuthService().signUp(
          _emailController.text.trim(), // Email without extra spaces
          _passwordController.text.trim(), // Password without spaces
          _nameController.text.trim(), // Name without spaces
        );

        // Check if widget is still active in UI
        if (mounted) {
          // Navigate to login screen after signup
          Navigator.pushReplacement(
            context, 
            MaterialPageRoute(builder: (_) => const LoginScreen())
          );
        }

      } catch (e) {
        // If error occurs and widget still active
        if (!mounted) return;

        // Show error message using snackbar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.error, // Error color
            content: Text(ErrorHandler.getErrorMessage(e)), // Error message
          ),
        );

      } finally {
        // Stop loading when done
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {

    // Main UI layout
    return Scaffold(
      backgroundColor: AppColors.background, // Set background color

      body: SingleChildScrollView( // Makes screen scrollable
        padding: const EdgeInsets.all(16.0), // Padding around content

        child: Form(
          key: _formKey, // Attach form key

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, // Align items to left

            children: [

              const SizedBox(height: 80), // Space from top

              const Text(
                "Sign up", 
                style: TextStyle(fontSize: 34, fontWeight: FontWeight.bold)
              ), // Title text

              const SizedBox(height: 50), // Space below title

              // Name field
              _buildField("Name", _nameController, (v) {
                if (v == null || v.isEmpty) return "Please enter your name"; // Empty check
                if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(v)) return "Only letters allowed"; // Only letters
                return null; // Valid input
              }),

              const SizedBox(height: 8), // Small space

              // Email field
              _buildField("Email", _emailController, (v) {
                if (v == null || v.isEmpty) return "Please enter your email"; // Empty check
                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(v)) return "Invalid email format"; // Email format check
                return null;
              }),

              const SizedBox(height: 8), // Space

              // Password field
              _buildField(
                "Password", 
                _passwordController, 
                (v) => (v == null || v.length < 6) 
                    ? "Min 6 characters" // Minimum length check
                    : null, 
                isPass: true // Hide password
              ),

              const SizedBox(height: 16), // Space

              // Link to login screen
              Align(
                alignment: Alignment.centerRight,
                child: InkWell(
                  onTap: () => Navigator.push(
                    context, 
                    MaterialPageRoute(builder: (_) => const LoginScreen())
                  ), // Navigate to login
                  child: const Text("Already have an account? →"), // Text
                )
              ),

              const SizedBox(height: 30), // Space

              // Signup button
              SizedBox(
                width: double.infinity, // Full width

                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleSignUp, 
                  // Disable button if loading

                  child: _isLoading 
                      ? const CircularProgressIndicator(color: Colors.white) 
                      // Show loader if processing
                      : const Text("SIGN UP"), // Button text
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Function to create reusable input fields
  Widget _buildField(
    String l, // Label text
    TextEditingController c, // Controller
    String? Function(String?) v, // Validator function
    {bool isPass = false} // Optional: is it password field
  ) {

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5), 
      // Inner spacing

      decoration: BoxDecoration(
        color: Colors.white, // Background color
        borderRadius: BorderRadius.circular(4), // Rounded corners

        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05), // Light shadow
            blurRadius: 4, // Blur strength
            offset: const Offset(0, 2) // Shadow position
          )
        ]
      ),

      child: TextFormField(
        controller: c, // Attach controller
        validator: v, // Attach validator
        obscureText: isPass, // Hide text if password

        decoration: InputDecoration(
          labelText: l, // Label text
          border: InputBorder.none, // Remove default border
          errorStyle: const TextStyle(color: AppColors.error) // Error text color
        ),
      ),
    );
  }
}
