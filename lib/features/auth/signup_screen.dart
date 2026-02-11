import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import 'login_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 80),
              const Text(
                "Sign up",
                style: TextStyle(fontSize: 34, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 50),

              // Name Field - Only Letters Validation
              _buildInputField(
                label: "Name",
                controller: _nameController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter your name";
                  }
                  // RegEx: Allows only uppercase and lowercase letters and spaces
                  if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value)) {
                    return "Only letters are allowed";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 8),

              // Email Field - Proper Email Validation
              _buildInputField(
                label: "Email",
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter an email";
                  }
                  // Standard Email RegEx
                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                    return "Please enter a valid email address";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 8),

              // Password Field
              _buildInputField(
                label: "Password",
                controller: _passwordController,
                isPassword: true,
                validator: (value) {
                  if (value == null || value.length < 6) {
                    return "Password must be at least 6 characters";
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: InkWell(
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen())),
                  child: const Text("Already have an account? →", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                ),
              ),
              const SizedBox(height: 30),

              // Sign Up Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      // Redirect to Login if form is valid
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => const LoginScreen()),
                      );
                    }
                  },
                  child: const Text("SIGN UP"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required String? Function(String?) validator,
    bool isPassword = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2)),
        ],
      ),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword,
        keyboardType: keyboardType,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: AppColors.grey, fontSize: 14),
          border: InputBorder.none,
          errorStyle: const TextStyle(color: AppColors.error, fontSize: 12),
        ),
      ),
    );
  }
}
