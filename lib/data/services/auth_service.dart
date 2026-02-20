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

  Future<User?> signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;
    if (googleAuth == null) return null;

    final credential = GoogleAuthProvider.credential(accessToken: googleAuth.accessToken, idToken: googleAuth.idToken);
    UserCredential result = await _auth.signInWithCredential(credential);

    // Check if profile exists, if not create it
    final doc = await _db.collection('users').doc(result.user!.uid).get();
    if (!doc.exists) {
      await _db.collection('users').doc(result.user!.uid).set({
        'name': result.user!.displayName ?? "User",
        'email': result.user!.email,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
    return result.user;
  }

  Future<void> signOut() async {
    await GoogleSignIn().signOut();
    await _auth.signOut();
  }
}
