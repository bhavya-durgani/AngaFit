import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
  bool _isLoading = false;

  Future<void> _handleSignUp() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        // 1. Create account in Firebase Authentication
        UserCredential result = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        // 2. Create user profile in Cloud Firestore
        await FirebaseFirestore.instance.collection('users').doc(result.user!.uid).set({
          'name': _nameController.text.trim(),
          'email': _emailController.text.trim(),
          'createdAt': FieldValue.serverTimestamp(),
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(backgroundColor: AppColors.success, content: Text("Account created! Please login.")),
          );
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
        }
      } on FirebaseAuthException catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message ?? "Sign up failed"), backgroundColor: AppColors.error));
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
              _buildInputField(
                label: "Name",
                controller: _nameController,
                validator: (v) {
                  if (v == null || v.isEmpty) return "Please enter your name";
                  if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(v)) return "Only letters are allowed";
                  return null;
                },
              ),
              const SizedBox(height: 8),
              _buildInputField(
                label: "Email",
                controller: _emailController,
                validator: (v) {
                  if (v == null || v.isEmpty) return "Please enter your email";
                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(v)) return "Enter a valid email";
                  return null;
                },
              ),
              const SizedBox(height: 8),
              _buildInputField(
                label: "Password",
                controller: _passwordController,
                isPassword: true,
                validator: (v) => (v == null || v.length < 6) ? "Password must be at least 6 characters" : null,
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

  Widget _buildInputField({required String label, required TextEditingController controller, required String? Function(String?) validator, bool isPassword = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2))]),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword,
        validator: validator,
        decoration: InputDecoration(labelText: label, labelStyle: const TextStyle(color: AppColors.grey, fontSize: 14), border: InputBorder.none, errorStyle: const TextStyle(color: AppColors.error, fontSize: 12)),
      ),
    );
  }
}
