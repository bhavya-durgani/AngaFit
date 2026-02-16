import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../data/services/auth_service.dart';
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
  bool _isLoading = false;

  // Handle Social Login Redirection
  Future<void> _handleSocialLogin(Future<dynamic> loginMethod) async {
    setState(() => _isLoading = true);
    try {
      final user = await loginMethod;
      if (user != null && mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const MainNavWrapper()),
              (route) => false,
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()), backgroundColor: AppColors.error));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

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
              const Text("Login", style: TextStyle(fontSize: 34, fontWeight: FontWeight.bold)),
              const SizedBox(height: 70),

              _buildInputField(
                label: "Email",
                controller: _emailController,
                validator: (value) {
                  if (value == null || value.isEmpty) return "Please enter your email";
                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) return "Enter a valid email";
                  return null;
                },
              ),
              const SizedBox(height: 8),
              _buildInputField(
                label: "Password",
                controller: _passwordController,
                isPassword: true,
                validator: (value) => (value == null || value.isEmpty) ? "Please enter your password" : null,
              ),

              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: InkWell(
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ForgotPasswordScreen())),
                  child: const Text("Forgot your password? →", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                ),
              ),

              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : () async {
                    if (_formKey.currentState!.validate()) {
                      _handleSocialLogin(AuthService().login(_emailController.text, _passwordController.text));
                    }
                  },
                  child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text("LOGIN"),
                ),
              ),

              const SizedBox(height: 80),
              const Center(child: Text("Or login with social account", style: TextStyle(color: AppColors.grey, fontSize: 14))),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _socialIcon(
                    "https://upload.wikimedia.org/wikipedia/commons/thumb/c/c1/Google_%22G%22_logo.svg/1200px-Google_%22G%22_logo.svg.png",
                    onTap: () => _handleSocialLogin(AuthService().signInWithGoogle()),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({required String label, required TextEditingController controller, required String? Function(String?) validator, bool isPassword = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2))]),
      child: TextFormField(controller: controller, obscureText: isPassword, validator: validator, decoration: InputDecoration(labelText: label, border: InputBorder.none, errorStyle: const TextStyle(color: AppColors.error, fontSize: 12))),
    );
  }

  Widget _socialIcon(String imageUrl, {required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12), width: 92, height: 64,
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)]),
        child: Image.network(imageUrl, fit: BoxFit.contain),
      ),
    );
  }
}
