import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';

class ErrorHandler {
  static String getErrorMessage(dynamic e) {
    if (e is FirebaseAuthException) {
      switch (e.code) {
        case 'user-not-found':
          return 'No user found with this email. Please sign up first.';
        case 'wrong-password':
          return 'Incorrect password. Please try again.';
        case 'email-already-in-use':
          return 'This email is already registered. Try logging in.';
        case 'invalid-email':
          return 'The email address is not valid.';
        case 'weak-password':
          return 'The password is too weak. Use at least 6 characters.';
        case 'user-disabled':
          return 'This user account has been disabled.';
        case 'too-many-requests':
          return 'Too many attempts. Please try again later.';
        case 'network-request-failed':
          return 'Network error. Please check your internet connection.';
        default:
          return e.message ?? 'An unexpected authentication error occurred.';
      }
    } else if (e is FirebaseException) {
      return 'Database error: ${e.message}';
    } else if (e is PlatformException) {
      // Google Sign-In throws PlatformException (e.g. sign_in_failed)
      final code = e.code;
      final detail = e.message ?? '';
      if (code == 'sign_in_canceled' || code == 'canceled') {
        return 'Sign-in was cancelled.';
      }
      if (detail.contains('10:') || code == 'sign_in_failed') {
        return 'Google Sign-In failed (developer error 10).\nSHA-1 fingerprint not registered in Firebase.\nCode: $code';
      }
      if (detail.contains('7:') || detail.contains('network')) {
        return 'Network error. Please check your internet connection.';
      }
      return 'Google Sign-In error ($code): $detail';
    }
    return 'Error: ${e.toString()}';
  }
}
