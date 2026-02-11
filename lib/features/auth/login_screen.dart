import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../navigation/main_nav_wrapper.dart';
import 'forgot_password_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

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
                "Login",
                style: TextStyle(fontSize: 34, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 70),

              // Email Field with Validation
              _buildInputField(
                label: "Email",
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter your email";
                  }
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
                  if (value == null || value.isEmpty) {
                    return "Please enter your password";
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Forgot Password Redirection
              Align(
                alignment: Alignment.centerRight,
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ForgotPasswordScreen()),
                    );
                  },
                  child: const Text(
                    "Forgot your password? →",
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Login Button with Validation Check
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => const MainNavWrapper()),
                            (route) => false,
                      );
                    }
                  },
                  child: const Text("LOGIN"),
                ),
              ),

              const SizedBox(height: 80),

              // Social Login Section
              const Center(
                child: Text(
                  "Or login with social account",
                  style: TextStyle(color: AppColors.grey, fontSize: 14),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _socialIcon(
                    "https://upload.wikimedia.org/wikipedia/commons/thumb/c/c1/Google_%22G%22_logo.svg/1200px-Google_%22G%22_logo.svg.png",
                    onTap: () {},
                  ),
                  const SizedBox(width: 16),
                  _socialIcon(
                    "https://upload.wikimedia.org/wikipedia/commons/thumb/0/05/Facebook_Logo_(2019).png/1200px-Facebook_Logo_(2019).png",
                    onTap: () {},
                  ),
                ],
              )
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

  Widget _socialIcon(String imageUrl, {required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        width: 92,
        height: 64,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2)),
          ],
        ),
        child: Image.network(imageUrl, fit: BoxFit.contain),
      ),
    );
  }
}
