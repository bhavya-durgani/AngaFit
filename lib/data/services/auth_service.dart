import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Google Sign In
  Future<User?> signInWithGoogle() async {
    // Trigger the authentication flow
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    // Obtain the auth details from the request
    final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;

    if (googleAuth == null) return null;

    // Create a new credential
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    // Once signed in, return the UserCredential
    UserCredential result = await _auth.signInWithCredential(credential);

    // Ensure user exists in Firestore
    await _createUserProfile(result.user);

    return result.user;
  }

  // Facebook Sign In
  Future<User?> signInWithFacebook() async {
    final LoginResult result = await FacebookAuth.instance.login();

    if (result.status == LoginStatus.success) {
      final OAuthCredential credential = FacebookAuthProvider.credential(result.accessToken!.tokenString);
      UserCredential userCredential = await _auth.signInWithCredential(credential);

      await _createUserProfile(userCredential.user);
      return userCredential.user;
    }
    return null;
  }

  // Helper to create profile in 'users' collection if it doesn't exist
  Future<void> _createUserProfile(User? user) async {
    if (user != null) {
      final userDoc = _db.collection('users').doc(user.uid);
      final doc = await userDoc.get();

      if (!doc.exists) {
        await userDoc.set({
          'uid': user.uid,
          'name': user.displayName ?? "New User",
          'email': user.email,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
    }
  }

  // Standard Email Login
  Future<User?> login(String email, String password) async {
    UserCredential result = await _auth.signInWithEmailAndPassword(email: email, password: password);
    return result.user;
  }
}
