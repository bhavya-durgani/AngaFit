import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/error_handler.dart';
import '../../data/services/auth_service.dart';
import 'login_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});
  @override State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _handleSignUp() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        await AuthService().signUp(
          _emailController.text.trim(),
          _passwordController.text.trim(),
          _nameController.text.trim(),
        );
        if (mounted) {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(backgroundColor: AppColors.error, content: Text(ErrorHandler.getErrorMessage(e))),
        );
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

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
              const Text("Sign up", style: TextStyle(fontSize: 34, fontWeight: FontWeight.bold)),
              const SizedBox(height: 50),
              _buildField("Name", _nameController, (v) {
                if (v == null || v.isEmpty) return "Please enter your name";
                if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(v)) return "Only letters allowed";
                return null;
              }),
              const SizedBox(height: 8),
              _buildField("Email", _emailController, (v) {
                if (v == null || v.isEmpty) return "Please enter your email";
                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(v)) return "Invalid email format";
                return null;
              }),
              const SizedBox(height: 8),
              _buildField("Password", _passwordController, (v) => (v == null || v.length < 6) ? "Min 6 characters" : null, isPass: true),
              const SizedBox(height: 16),
              Align(alignment: Alignment.centerRight, child: InkWell(onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen())), child: const Text("Already have an account? →"))),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleSignUp,
                  child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text("SIGN UP"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(String l, TextEditingController c, String? Function(String?) v, {bool isPass = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2))]),
      child: TextFormField(controller: c, validator: v, obscureText: isPass, decoration: InputDecoration(labelText: l, border: InputBorder.none, errorStyle: const TextStyle(color: AppColors.error))),
    );
  }
}
