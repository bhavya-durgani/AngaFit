import 'package:flutter/material.dart'; // Flutter UI
import 'package:cloud_firestore/cloud_firestore.dart'; // Firestore database
import 'package:firebase_auth/firebase_auth.dart'; // Firebase authentication
import 'package:local_auth/local_auth.dart'; // Biometric authentication (fingerprint/face)

import '../../core/constants/app_colors.dart'; // App colors
import '../../core/utils/error_handler.dart'; // Custom error handler
import '../../data/services/auth_service.dart'; // Your auth service (login/google)
import '../navigation/main_nav_wrapper.dart'; // Main app screen after login
import 'forgot_password_screen.dart'; // Forgot password screen

// Stateful widget because login involves dynamic state (loading, biometrics)
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState(); // Create state
}

class _LoginScreenState extends State<LoginScreen> {

  final _formKey = GlobalKey<FormState>(); // Form validation key

  final _emailController = TextEditingController(); // Email input controller
  final _passwordController = TextEditingController(); // Password input controller

  final _localAuth = LocalAuthentication(); // Biometric auth instance

  bool _isLoading = false; // Loading state (disable buttons)
  bool _biometricEnabled = false;   // Whether user enabled biometrics (from Firestore)
  bool _biometricAvailable = false; // Whether device supports biometrics

  @override
  void initState() {
    super.initState();
    _checkBiometric(); // Check biometric support + user setting
  }

  @override
  void dispose() {
    _emailController.dispose(); // Clean up controller
    _passwordController.dispose(); // Clean up controller
    super.dispose();
  }

  // ── Check if biometrics are available AND enabled for user ───────────────
  Future<void> _checkBiometric() async {
    try {
      final canCheck = await _localAuth.canCheckBiometrics; // Device has biometric hardware
      final isSupported = await _localAuth.isDeviceSupported(); // OS supports it

      if (!mounted) return;

      // Set availability (true only if both conditions are true)
      setState(() => _biometricAvailable = canCheck && isSupported);

      // Check current logged-in user
      final uid = FirebaseAuth.instance.currentUser?.uid;

      if (uid != null) {
        // Fetch user settings from Firestore
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .get();

        if (mounted && doc.exists) {
          // Read biometricLogin flag
          setState(() =>
              _biometricEnabled = doc.data()?['biometricLogin'] ?? false);
        }
      }
    } catch (_) {} // Ignore errors silently
  }

  // ── Email + Password Login ───────────────────────────────────────────────
  Future<void> _handleLogin() async {

    // Validate form fields
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true); // Show loading

    try {
      // Call login service
      await AuthService().login(
        _emailController.text.trim(), // Email
        _passwordController.text.trim(), // Password
      );

      if (mounted) {
        // Navigate to main app and clear stack
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const MainNavWrapper()),
          (r) => false,
        );
      }

    } catch (e) {

      if (!mounted) return;

      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: AppColors.error,
        content: Text(ErrorHandler.getErrorMessage(e)),
      ));

    } finally {
      if (mounted) setState(() => _isLoading = false); // Stop loading
    }
  }

  // ── Google Login ─────────────────────────────────────────────────────────
  Future<void> _handleGoogleLogin() async {
    setState(() => _isLoading = true);

    try {
      await AuthService().signInWithGoogle(); // Google auth

      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const MainNavWrapper()),
          (r) => false,
        );
      }

    } catch (e) {

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: AppColors.error,
        content: Text(ErrorHandler.getErrorMessage(e)),
      ));

    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ── Biometric Login ──────────────────────────────────────────────────────
  Future<void> _handleBiometricLogin() async {
    setState(() => _isLoading = true);

    try {
      final authenticated = await _localAuth.authenticate(
        localizedReason: 'Verify your identity to log in to AngaFit', // Message
        options: const AuthenticationOptions(
          biometricOnly: false, // Allow PIN/Pattern fallback
          stickyAuth: true, // Keep auth active across app pauses
        ),
      );

      if (!mounted) return;

      if (authenticated) {
        // If success → go to main screen
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const MainNavWrapper()),
          (r) => false,
        );
      } else {
        // If failed
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: AppColors.primaryRed,
            content: Text('Biometric authentication failed.'),
          ),
        );
      }

    } catch (e) {

      if (!mounted) return;

      // Error during biometric auth
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.primaryRed,
          content: Text('Biometrics error: $e'),
        ),
      );

    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ── UI ───────────────────────────────────────────────────────────────────
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
        padding: const EdgeInsets.all(16.0),

        child: Form(
          key: _formKey,

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [

              const SizedBox(height: 18),

              const Text('Login',
                  style: TextStyle(fontSize: 34, fontWeight: FontWeight.bold)),

              const SizedBox(height: 50),

              // Email field
              _buildField(
                'Email',
                _emailController,
                (v) => (v == null || !v.contains('@'))
                    ? 'Enter a valid email'
                    : null,
              ),

              const SizedBox(height: 8),

              // Password field
              _buildField(
                'Password',
                _passwordController,
                (v) => (v == null || v.isEmpty) ? 'Enter password' : null,
                isPass: true,
              ),

              const SizedBox(height: 16),

              // Forgot password navigation
              Align(
                alignment: Alignment.centerRight,
                child: InkWell(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const ForgotPasswordScreen()),
                  ),
                  child: const Text('Forgot your password? →'),
                ),
              ),

              const SizedBox(height: 32),

              // LOGIN BUTTON
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleLogin,
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('LOGIN'),
                ),
              ),

              // BIOMETRIC LOGIN BUTTON (only if available + enabled)
              if (_biometricAvailable && _biometricEnabled) ...[
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _isLoading ? null : _handleBiometricLogin,
                    icon: const Icon(Icons.fingerprint),
                    label: const Text('Login with Biometrics'),
                  ),
                ),
              ],

              const SizedBox(height: 60),

              const Center(
                child: Text('Or login with social account'),
              ),

              const SizedBox(height: 24),

              // GOOGLE LOGIN BUTTON
              Center(
                child: InkWell(
                  onTap: _isLoading ? null : _handleGoogleLogin,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    width: 92,
                    height: 64,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Image.network(
                      'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c1/Google_%22G%22_logo.svg/1200px-Google_%22G%22_logo.svg.png',
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Reusable Input Field Widget ──────────────────────────────────────────
  Widget _buildField(
    String label,
    TextEditingController controller,
    String? Function(String?) validator, {
    bool isPass = false, // Password field toggle
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          )
        ],
      ),

      child: TextFormField(
        controller: controller, // Attach controller
        validator: validator, // Validation logic
        obscureText: isPass, // Hide password if true

        decoration: InputDecoration(
          labelText: label,
          border: InputBorder.none,
          errorStyle: const TextStyle(color: AppColors.error),
        ),
      ),
    );
  }
}
