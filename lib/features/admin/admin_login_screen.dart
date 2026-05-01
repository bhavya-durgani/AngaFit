import 'package:flutter/material.dart';  
// Imports Flutter UI components

import '../../core/constants/app_colors.dart';  
// Imports custom colors

import 'admin_dashboard_screen.dart';  
// Imports dashboard screen (after successful login)

class AdminLoginScreen extends StatefulWidget {  
  // Admin login screen

  const AdminLoginScreen({super.key});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();  
  // Creates state for this screen
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {  
  // State class (handles UI + logic)

  final _formKey = GlobalKey<FormState>();  
  // Key to validate form fields

  final _emailController = TextEditingController();  
  // Controller for email input

  final _passwordController = TextEditingController();  
  // Controller for password input

  bool _isLoading = false;  
  // Loading state for button

  void _handleAdminLogin() {  
    // Function to handle login

    if (!_formKey.currentState!.validate()) return;  
    // Validate form (if empty → stop)

    setState(() => _isLoading = true);  
    // Show loading indicator

    Future.delayed(const Duration(milliseconds: 800), () {  
      // Fake delay (simulate API call)

      if (!mounted) return;  
      // Check widget still active

      setState(() => _isLoading = false);  
      // Stop loading

      final email = _emailController.text.trim();  
      // Get email input

      final password = _passwordController.text.trim();  
      // Get password input

      if (email == 'admin@angafit.com' && password == 'admin123') {  
        // Hardcoded admin credentials check

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const AdminDashboardScreen()),
        );  
        // Navigate to dashboard (replace current screen)

      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: AppColors.error,
            content: Text("Invalid admin credentials!"),
          ),
        );  
        // Show error message if login fails
      }
    });
  }

  @override
  void dispose() {  
    // Cleanup controllers when screen is removed

    _emailController.dispose();  
    _passwordController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {  
    // Builds UI

    return Scaffold(
      backgroundColor: AppColors.background,  
      // Set background color

      appBar: AppBar(
        title: const Text(
          "Admin Portal", 
          style: TextStyle(color: AppColors.black)
        ),  
        // Title

        centerTitle: true,  
        // Center title

        leading: IconButton(
          icon: const Icon(
            Icons.chevron_left, 
            size: 32, 
            color: AppColors.black
          ),  
          // Back button

          onPressed: () => Navigator.pop(context),  
          // Go back
        ),
      ),

      body: SingleChildScrollView(  
        // Makes screen scrollable (prevents overflow)

        padding: const EdgeInsets.all(24.0),

        child: Form(
          key: _formKey,  
          // Attach form key for validation

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [

              const SizedBox(height: 40),  
              // Top spacing

              const Center(
                child: Icon(
                  Icons.shield, 
                  size: 80, 
                  color: AppColors.primaryRed
                ),
              ),  
              // Admin icon

              const SizedBox(height: 20),

              const Center(
                child: Text(
                  'Admin Login',
                  style: TextStyle(
                    fontSize: 28, 
                    fontWeight: FontWeight.bold
                  ),
                ),
              ),  
              // Title text

              const SizedBox(height: 40),

              _buildField('Admin Email', _emailController),  
              // Email input field

              const SizedBox(height: 16),

              _buildField('Password', _passwordController, isPass: true),  
              // Password input field

              const SizedBox(height: 40),

              SizedBox(
                width: double.infinity,  
                // Button full width

                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleAdminLogin,  
                  // Disable button if loading

                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white, 
                            strokeWidth: 2
                          ),
                        )  
                      // Show loader

                      : const Text('LOGIN TO DASHBOARD'),  
                      // Show button text
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(
    String label, 
    TextEditingController controller, 
    {bool isPass = false}
  ) {  
    // Reusable input field widget

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),  
      // Inner spacing

      decoration: BoxDecoration(
        color: Colors.white,  
        // Background

        borderRadius: BorderRadius.circular(8),  
        // Rounded corners

        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),  
            // Light shadow

            blurRadius: 4,  
            offset: const Offset(0, 2),
          )
        ],
      ),

      child: TextFormField(
        controller: controller,  
        // Attach controller

        obscureText: isPass,  
        // Hide text if password field

        validator: (v) => v!.isEmpty ? 'Required' : null,  
        // Validation: field must not be empty

        decoration: InputDecoration(
          labelText: label,  
          // Label text

          border: InputBorder.none,  
          // Remove default border
        ),
      ),
    );
  }
}
