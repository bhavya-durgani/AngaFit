import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:local_auth/local_auth.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/error_handler.dart';
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
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _localAuth = LocalAuthentication();

  bool _isLoading = false;
  bool _biometricEnabled = false;   // loaded from Firestore for current user
  bool _biometricAvailable = false; // device supports biometrics

  @override
  void initState() {
    super.initState();
    _checkBiometric();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _checkBiometric() async {
    try {
      final canCheck = await _localAuth.canCheckBiometrics;
      final isSupported = await _localAuth.isDeviceSupported();
      if (!mounted) return;
      setState(() => _biometricAvailable = canCheck && isSupported);

      // Check if the currently signed-in user (if any) has biometrics enabled
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .get();
        if (mounted && doc.exists) {
          setState(() =>
              _biometricEnabled = doc.data()?['biometricLogin'] ?? false);
        }
      }
    } catch (_) {}
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      await AuthService().login(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );
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

  Future<void> _handleGoogleLogin() async {
    setState(() => _isLoading = true);
    try {
      await AuthService().signInWithGoogle();
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

  /// Biometric quick-login: only available when the user previously checked
  /// "Enable Biometric Login" in Settings AND is already signed in (session).
  Future<void> _handleBiometricLogin() async {
    setState(() => _isLoading = true);
    try {
      final authenticated = await _localAuth.authenticate(
        localizedReason: 'Verify your identity to log in to AngaFit',
        options: const AuthenticationOptions(
          biometricOnly: false,
          stickyAuth: true,
        ),
      );
      if (!mounted) return;
      if (authenticated) {
        // User session is still active (Firebase persists auth across app restarts)
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const MainNavWrapper()),
          (r) => false,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: AppColors.primaryRed,
            content: Text('Biometric authentication failed.'),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
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

              _buildField('Email', _emailController,
                  (v) => (v == null || !v.contains('@'))
                      ? 'Enter a valid email'
                      : null),
              const SizedBox(height: 8),
              _buildField('Password', _passwordController,
                  (v) => (v == null || v.isEmpty) ? 'Enter password' : null,
                  isPass: true),
              const SizedBox(height: 16),

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

              // ── LOGIN BUTTON ──────────────────────────────────────────────
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleLogin,
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('LOGIN'),
                ),
              ),

              // ── BIOMETRIC QUICK LOGIN (shown only when available & enabled) ─
              if (_biometricAvailable && _biometricEnabled) ...[
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _isLoading ? null : _handleBiometricLogin,
                    icon: const Icon(Icons.fingerprint, size: 22),
                    label: const Text('Login with Biometrics'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primaryRed,
                      side: const BorderSide(color: AppColors.primaryRed),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 60),
              const Center(
                child: Text('Or login with social account',
                    style: TextStyle(color: AppColors.grey)),
              ),
              const SizedBox(height: 24),
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
                      boxShadow: const [
                        BoxShadow(color: Colors.black12, blurRadius: 8)
                      ],
                    ),
                    child: Image.network(
                      'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c1/Google_%22G%22_logo.svg/1200px-Google_%22G%22_logo.svg.png',
                      fit: BoxFit.contain,
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

  Widget _buildField(
    String label,
    TextEditingController controller,
    String? Function(String?) validator, {
    bool isPass = false,
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
        controller: controller,
        validator: validator,
        obscureText: isPass,
        decoration: InputDecoration(
          labelText: label,
          border: InputBorder.none,
          errorStyle: const TextStyle(color: AppColors.error),
        ),
      ),
    );
  }
}
