import 'package:firebase_auth/firebase_auth.dart';  
// Imports Firebase Authentication (login, signup, logout)

import 'package:cloud_firestore/cloud_firestore.dart';  
// Imports Firestore database (to store user data)

import 'package:google_sign_in/google_sign_in.dart';  
// Imports Google Sign-In package (for login with Google)

class AuthService {  
  // Service class to handle all authentication logic

  final FirebaseAuth _auth = FirebaseAuth.instance;  
  // Get Firebase Auth instance

  final FirebaseFirestore _db = FirebaseFirestore.instance;  
  // Get Firestore database instance

  // Stream to listen to Auth changes (Login/Logout)
  Stream<User?> get userStream => _auth.authStateChanges();  
  // Provides real-time updates when user logs in or logs out

  // Get current User ID
  String? get currentUid => _auth.currentUser?.uid;  
  // Returns current logged-in user's UID (or null if not logged in)

  Future<User?> signUp(String email, String password, String name) async {  
    // Function to register a new user

    UserCredential result = await _auth.createUserWithEmailAndPassword(
      email: email, 
      password: password
    );  
    // Create user in Firebase Auth

    await _db.collection('users').doc(result.user!.uid).set({
      'name': name,  
      // Store user's name

      'email': email,  
      // Store user's email

      'createdAt': FieldValue.serverTimestamp(),  
      // Store account creation time
    });

    return result.user;  
    // Return created user
  }

  Future<User?> login(String email, String password) async =>  
      (await _auth.signInWithEmailAndPassword(
        email: email, 
        password: password
      )).user;  
  // Function to login user and return user object

  /// Signs in with Google using native Google Play Services.
  /// Fixed: Replaced browser-based signInWithProvider (which was throwing 
  /// 'missing initial state' due to Chrome storage partitioning/cookies)
  /// with the native google_sign_in plugin.
  Future<User?> signInWithGoogle() async {  
    // Function to login using Google account

    final GoogleSignInAccount? gUser = await GoogleSignIn().signIn();  
    // Open Google account selection

    if (gUser == null) return null;  
    // If user cancels login, return null

    final GoogleSignInAuthentication gAuth = await gUser.authentication;  
    // Get authentication tokens (access + ID token)

    final OAuthCredential credential = GoogleAuthProvider.credential(
      accessToken: gAuth.accessToken,  
      // Access token from Google

      idToken: gAuth.idToken,  
      // ID token from Google
    );

    final UserCredential result = await _auth.signInWithCredential(credential);  
    // Login to Firebase using Google credentials

    // Create Firestore profile if this is a new user
    if (result.user != null) {  
      final doc = await _db.collection('users').doc(result.user!.uid).get();  
      // Check if user already exists in Firestore

      if (!doc.exists) {  
        // If user is new

        await _db.collection('users').doc(result.user!.uid).set({
          'name': result.user!.displayName ?? 'User',  
          // Store name (fallback to "User" if null)

          'email': result.user!.email,  
          // Store email

          'createdAt': FieldValue.serverTimestamp(),  
          // Store account creation time
        });
      }
    }

    return result.user;  
    // Return logged-in user
  }

  Future<void> signOut() async {  
    // Function to log out user

    await GoogleSignIn().signOut();  
    // Sign out from Google account

    await _auth.signOut();  
    // Sign out from Firebase
  }
}
