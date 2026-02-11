import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, size: 32),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 18),
              const Text(
                "Forgot password",
                style: TextStyle(fontSize: 34, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 70),

              const Text(
                "Please, enter your email address. You will receive a link to create a new password via email.",
                style: TextStyle(fontSize: 14, color: AppColors.black, height: 1.4),
              ),
              const SizedBox(height: 16),

              // Email Field with Validation
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter your email";
                    }
                    // Email RegEx
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                      return "Not a valid email address. Should be your@email.com";
                    }
                    return null;
                  },
                  decoration: const InputDecoration(
                    labelText: "Email",
                    labelStyle: TextStyle(color: AppColors.grey, fontSize: 14),
                    border: InputBorder.none,
                    errorStyle: TextStyle(color: AppColors.error, fontSize: 12),
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // Send Button with Validation Check
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      // If valid, show success and go back
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          backgroundColor: AppColors.success,
                          content: Text("Reset link sent! Please check your inbox."),
                        ),
                      );
                      Navigator.pop(context);
                    }
                  },
                  child: const Text("SEND"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }
}
