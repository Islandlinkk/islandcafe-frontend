import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  static FirebaseAuth get _auth => FirebaseAuth.instance;
  static FirebaseFirestore get _firestore => FirebaseFirestore.instance;

  static Stream<User?> get authStateChanges => _auth.userChanges();

  static Future<UserCredential> registerWithEmail({
    required String email,
    required String password,
  }) {
    return _auth
        .createUserWithEmailAndPassword(email: email, password: password)
        .then((cred) async {
          final user = cred.user;
          if (user != null && !user.emailVerified) {
            await user.sendEmailVerification();
          }
          return cred;
        });
  }

  static Future<void> saveUserDetails({
    required String uid,
    required String name,
    required String phone,
  }) async {
    await _firestore.collection('users').doc(uid).set({
      'name': name,
      'phone': phone,
      'email': _auth.currentUser?.email,
      'createdAt': FieldValue.serverTimestamp(),
      'profileComplete': true,
    }, SetOptions(merge: true));

    final user = _auth.currentUser;
    if (user != null) {
      await user.updateDisplayName(name);
      await user.reload();
    }
  }

  static Future<bool> isUserProfileComplete() async {
    final user = _auth.currentUser;
    if (user == null) return false;

    try {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      return doc.exists && (doc.data()?['profileComplete'] == true);
    } catch (e) {
      return false;
    }
  }

  static Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
  }) {
    return _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  static Future<void> sendPasswordResetEmail({required String email}) {
    return _auth.sendPasswordResetEmail(email: email);
  }

  static Future<UserCredential> signInWithGoogle() {
    final provider = GoogleAuthProvider()
      ..setCustomParameters({'prompt': 'select_account'});
    return kIsWeb
        ? _auth.signInWithPopup(provider)
        : _auth.signInWithProvider(provider);
  }

  static Future<void> signOut() async {
    await _auth.signOut();
  }

  static Future<void> resendEmailVerification() async {
    final user = _auth.currentUser;
    if (user != null && !user.emailVerified) {
      await user.sendEmailVerification();
    }
  }

  static Future<void> reloadCurrentUser() async {
    final user = _auth.currentUser;
    if (user != null) {
      await user.reload();
    }
  }
}
