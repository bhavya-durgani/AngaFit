import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:local_auth/local_auth.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../core/constants/app_colors.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _nameController = TextEditingController();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _auth = LocalAuthentication();

  final _uid = FirebaseAuth.instance.currentUser?.uid;
  bool _isLoading = false;

  // Preferences
  bool _pushNotifications = true;
  bool _emailNewsletter = false;
  bool _biometricLogin = false;
  bool _biometricAvailable = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
    _checkBiometricAvailability();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    super.dispose();
  }

  // ── Load ──────────────────────────────────────────────────────────────────

  Future<void> _loadProfile() async {
    if (_uid == null) return;
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(_uid)
        .get();
    if (!mounted) return;
    if (doc.exists) {
      final data = doc.data() as Map<String, dynamic>;
      setState(() {
        _nameController.text = data['name'] ?? '';
        _pushNotifications = data['pushNotifications'] ?? true;
        _emailNewsletter = data['emailNewsletter'] ?? false;
        _biometricLogin = data['biometricLogin'] ?? false;
      });
    }
  }

  Future<void> _checkBiometricAvailability() async {
    try {
      final canCheck = await _auth.canCheckBiometrics;
      final isSupported = await _auth.isDeviceSupported();
      if (mounted) {
        setState(() => _biometricAvailable = canCheck && isSupported);
      }
    } catch (_) {
      if (mounted) setState(() => _biometricAvailable = false);
    }
  }

  // ── Push notification toggle ──────────────────────────────────────────────

  Future<void> _handleNotificationToggle(bool value) async {
    if (value) {
      // Request permission when enabling
      final status = await Permission.notification.request();
      if (!mounted) return;
      if (status.isDenied || status.isPermanentlyDenied) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.primaryRed,
            content: const Text('Notification permission denied. Enable it in App Settings.'),
            action: SnackBarAction(
              label: 'Open Settings',
              textColor: Colors.white,
              onPressed: openAppSettings,
            ),
          ),
        );
        return; // Don't toggle on if permission refused
      }
    }
    setState(() => _pushNotifications = value);
  }

  // ── Biometric toggle ──────────────────────────────────────────────────────

  Future<void> _handleBiometricToggle(bool value) async {
    if (value) {
      // Verify biometrics before enabling
      try {
        final authenticated = await _auth.authenticate(
          localizedReason: 'Confirm your identity to enable biometric login',
          options: const AuthenticationOptions(
            biometricOnly: false,
            stickyAuth: true,
          ),
        );
        if (!mounted) return;
        if (!authenticated) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              backgroundColor: AppColors.primaryRed,
              content: Text('Biometric authentication failed. Try again.'),
            ),
          );
          return;
        }
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.primaryRed,
            content: Text('Biometrics not available: $e'),
          ),
        );
        return;
      }
    }
    setState(() => _biometricLogin = value);
  }

  // ── Save ──────────────────────────────────────────────────────────────────

  Future<void> _updateProfile() async {
    if (_uid == null) return;
    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser!;

      // 1. Handle password change with re-authentication
      if (_newPasswordController.text.isNotEmpty) {
        if (_currentPasswordController.text.isEmpty) {
          throw FirebaseAuthException(
            code: 'missing-current-pwd',
            message: 'Please enter your current password to set a new one.',
          );
        }
        final credential = EmailAuthProvider.credential(
          email: user.email!,
          password: _currentPasswordController.text,
        );
        await user.reauthenticateWithCredential(credential);
        await user.updatePassword(_newPasswordController.text);
      }

      // 2. Sync display name to FirebaseAuth so it appears everywhere immediately
      final newName = _nameController.text.trim();
      if (newName.isNotEmpty && user.displayName != newName) {
        await user.updateDisplayName(newName);
      }

      // 3. Persist all prefs to Firestore
      await FirebaseFirestore.instance.collection('users').doc(_uid).update({
        'name': newName,
        'pushNotifications': _pushNotifications,
        'emailNewsletter': _emailNewsletter,
        'biometricLogin': _biometricLogin,
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: AppColors.success,
          content: Text('Settings saved!'),
        ),
      );
      _currentPasswordController.clear();
      _newPasswordController.clear();
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.primaryRed,
          content: Text(e.message ?? 'Failed to update profile'),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.primaryRed,
          content: Text('An error occurred: $e'),
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Settings')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Personal Information ──────────────────────────────────────
            const Text('Personal Information',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextField(
              controller: _nameController,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Full Name',
                filled: true,
                fillColor: Colors.white,
                border: InputBorder.none,
                prefixIcon: Icon(Icons.person_outline),
              ),
            ),

            const SizedBox(height: 30),

            // ── Change Password ───────────────────────────────────────────
            const Text('Change Password',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('To change your password, provide your current password.',
                style: TextStyle(fontSize: 12, color: AppColors.grey)),
            const SizedBox(height: 16),
            TextField(
              controller: _currentPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Current Password',
                filled: true,
                fillColor: Colors.white,
                border: InputBorder.none,
                prefixIcon: Icon(Icons.lock_outline),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _newPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'New Password',
                hintText: 'Leave blank to keep current',
                filled: true,
                fillColor: Colors.white,
                border: InputBorder.none,
                prefixIcon: Icon(Icons.lock_reset),
              ),
            ),

            const SizedBox(height: 30),

            // ── App Preferences ───────────────────────────────────────────
            const Text('App Preferences',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  // Push Notifications — actually requests OS permission
                  SwitchListTile(
                    activeColor: AppColors.primaryRed,
                    secondary: const Icon(Icons.notifications_outlined),
                    title: const Text('Push Notifications'),
                    subtitle: const Text('Order updates & promotions',
                        style: TextStyle(fontSize: 11, color: AppColors.grey)),
                    value: _pushNotifications,
                    onChanged: _handleNotificationToggle,
                  ),
                  const Divider(height: 1, indent: 16, endIndent: 16),

                  // Email Newsletter — persisted to Firestore
                  SwitchListTile(
                    activeColor: AppColors.primaryRed,
                    secondary: const Icon(Icons.email_outlined),
                    title: const Text('Email Newsletters'),
                    subtitle: const Text('Style tips & exclusive deals',
                        style: TextStyle(fontSize: 11, color: AppColors.grey)),
                    value: _emailNewsletter,
                    onChanged: (val) => setState(() => _emailNewsletter = val),
                  ),
                  const Divider(height: 1, indent: 16, endIndent: 16),

                  // Biometric Login — verifies via local_auth before enabling
                  SwitchListTile(
                    activeColor: AppColors.primaryRed,
                    secondary: const Icon(Icons.fingerprint),
                    title: const Text('Fingerprint / Face ID Login'),
                    subtitle: Text(
                      _biometricAvailable
                          ? 'Use biometrics to log in faster'
                          : 'Not available on this device',
                      style: const TextStyle(fontSize: 11, color: AppColors.grey),
                    ),
                    value: _biometricLogin,
                    onChanged: _biometricAvailable ? _handleBiometricToggle : null,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _updateProfile,
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2))
                    : const Text('SAVE CHANGES'),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
