import 'package:firebase_auth/firebase_auth.dart';  
// Imports Firebase Authentication exceptions

import 'package:flutter/services.dart';  
// Imports PlatformException (used for Google Sign-In errors)

class ErrorHandler {  
  // Class used to convert technical errors into user-friendly messages

  static String getErrorMessage(dynamic e) {  
    // Function takes any error (e) and returns readable message

    if (e is FirebaseAuthException) {  
      // Check if error is from Firebase Authentication

      switch (e.code) {  
        // Check specific error codes

        case 'user-not-found':
          return 'No user found with this email. Please sign up first.';  
          // When user email is not registered

        case 'wrong-password':
          return 'Incorrect password. Please try again.';  
          // When password is wrong

        case 'email-already-in-use':
          return 'This email is already registered. Try logging in.';  
          // When email is already used

        case 'invalid-email':
          return 'The email address is not valid.';  
          // When email format is incorrect

        case 'weak-password':
          return 'The password is too weak. Use at least 6 characters.';  
          // When password is too short/weak

        case 'user-disabled':
          return 'This user account has been disabled.';  
          // When user account is disabled

        case 'too-many-requests':
          return 'Too many attempts. Please try again later.';  
          // Too many login attempts

        case 'network-request-failed':
          return 'Network error. Please check your internet connection.';  
          // Internet issue

        default:
          return e.message ?? 'An unexpected authentication error occurred.';  
          // Default message if error code not matched
      }

    } else if (e is FirebaseException) {  
      // Check if error is from Firebase database (Firestore, etc.)

      return 'Database error: ${e.message}';  
      // Return database-related error message

    } else if (e is PlatformException) {  
      // Handles platform-specific errors (like Google Sign-In)

      // Google Sign-In throws PlatformException (e.g. sign_in_failed)
      final code = e.code;  
      // Get error code

      final detail = e.message ?? '';  
      // Get detailed error message

      if (code == 'sign_in_canceled' || code == 'canceled') {
        return 'Sign-in was cancelled.';  
        // User cancelled Google Sign-In
      }

      if (detail.contains('10:') || code == 'sign_in_failed') {
        return 'Google Sign-In failed (developer error 10).\nSHA-1 fingerprint not registered in Firebase.\nCode: $code';  
        // Error 10 = Firebase SHA-1 not configured
      }

      if (detail.contains('7:') || detail.contains('network')) {
        return 'Network error. Please check your internet connection.';  
        // Network-related issue
      }

      return 'Google Sign-In error ($code): $detail';  
      // Default message for other platform errors
    }

    return 'Error: ${e.toString()}';  
    // Fallback for any unknown errors
  }
}
