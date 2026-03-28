import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Stream to listen to Auth changes (Login/Logout)
  Stream<User?> get userStream => _auth.authStateChanges();

  // Get current User ID
  String? get currentUid => _auth.currentUser?.uid;

  Future<User?> signUp(String email, String password, String name) async {
    UserCredential result = await _auth.createUserWithEmailAndPassword(email: email, password: password);
    await _db.collection('users').doc(result.user!.uid).set({
      'name': name,
      'email': email,
      'createdAt': FieldValue.serverTimestamp(),
    });
    return result.user;
  }

  Future<User?> login(String email, String password) async => (await _auth.signInWithEmailAndPassword(email: email, password: password)).user;

  /// Signs in with Google using native Google Play Services.
  /// Fixed: Replaced browser-based signInWithProvider (which was throwing 
  /// 'missing initial state' due to Chrome storage partitioning/cookies)
  /// with the native google_sign_in plugin.
  Future<User?> signInWithGoogle() async {
    final GoogleSignInAccount? gUser = await GoogleSignIn().signIn();
    if (gUser == null) return null; // User canceled the sign-in

    final GoogleSignInAuthentication gAuth = await gUser.authentication;
    final OAuthCredential credential = GoogleAuthProvider.credential(
      accessToken: gAuth.accessToken,
      idToken: gAuth.idToken,
    );

    final UserCredential result = await _auth.signInWithCredential(credential);

    // Create Firestore profile if this is a new user
    if (result.user != null) {
      final doc = await _db.collection('users').doc(result.user!.uid).get();
      if (!doc.exists) {
        await _db.collection('users').doc(result.user!.uid).set({
          'name': result.user!.displayName ?? 'User',
          'email': result.user!.email,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
    }
    return result.user;
  }

  Future<void> signOut() async {
    await GoogleSignIn().signOut();
    await _auth.signOut();
  }
}

