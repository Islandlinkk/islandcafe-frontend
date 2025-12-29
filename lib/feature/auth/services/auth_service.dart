import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class AuthService {
  static FirebaseAuth get _auth => FirebaseAuth.instance;
  static FirebaseFirestore get _firestore => FirebaseFirestore.instance;
  static FirebaseStorage get _storage => FirebaseStorage.instance;

  static Stream<User?> get authStateChanges => _auth.userChanges();
  static User? get currentUser => _auth.currentUser;

  /// Register with Email/Password
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

  /// Sign In with Email/Password
  static Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
  }) {
    return _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  /// Sign In with Google
  static Future<UserCredential> signInWithGoogle() async {
    final provider = GoogleAuthProvider()
      ..setCustomParameters({'prompt': 'select_account'});

    final UserCredential cred = kIsWeb
        ? await _auth.signInWithPopup(provider)
        : await _auth.signInWithProvider(provider);

    final user = cred.user;
    if (user != null) {
      final docRef = _firestore.collection('users').doc(user.uid);
      final docSnapshot = await docRef.get();

      if (!docSnapshot.exists) {
        await docRef.set({
          'email': user.email,
          'name': user.displayName ?? '',
          'createdAt': FieldValue.serverTimestamp(),
          'profileComplete': false,
        });
      }
    }
    return cred;
  }

  /// Upload Profile Image to Firebase Storage
  static Future<String> uploadProfileImage({required File file, required String uid}) async {
    try {
      // 1. Create the reference
      final ref = _storage.ref().child('user_images/$uid.jpg');
      
      // 2. Define Metadata (Helps Firebase handle the file correctly)
      final metadata = SettableMetadata(
        contentType: 'image/jpeg',
        customMetadata: {'picked-file-path': file.path},
      );

      // 3. Upload and WAIT for the snapshot (Crucial step!)
      final UploadTask uploadTask = ref.putFile(file, metadata);
      final TaskSnapshot snapshot = await uploadTask;

      // 4. Get the URL only after the upload is officially complete
      final url = await snapshot.ref.getDownloadURL();
      return url;
    } catch (e) {
      print("Upload Error: $e");
      throw Exception('Image upload failed: $e');
    }
  }

  /// Update User Photo URL in Auth & Firestore
  static Future<void> updateUserPhoto(String photoUrl) async {
    final user = currentUser;
    if (user != null) {
      // Update Auth Profile
      await user.updatePhotoURL(photoUrl);
      
      // Update Firestore
      await _firestore.collection('users').doc(user.uid).update({
        'photoURL': photoUrl,
      });
    }
  }

  /// Save User Details to Firestore
  static Future<void> saveUserDetails({
    required String uid,
    required String name,
    required String phone,
    String? birthday,
    String? gender,
    String? address,
  }) async {
    // 1. Update Firestore
    await _firestore.collection('users').doc(uid).set({
      'name': name,
      'phone': phone,
      'birthday': birthday,
      'gender': gender,
      'address': address,
      'email': currentUser?.email,
      'updatedAt': FieldValue.serverTimestamp(),
      'profileComplete': true,
    }, SetOptions(merge: true));

    // 2. Update Auth Profile
    final user = currentUser;
    if (user != null) {
      await user.updateDisplayName(name);
    }
  }

  static Stream<DocumentSnapshot<Map<String, dynamic>>> getUserDetailsStream() {
    final user = currentUser;
    if (user == null) return const Stream.empty();
    return _firestore.collection('users').doc(user.uid).snapshots();
  }

  /// Check if Profile is Complete
  static Future<bool> isUserProfileComplete() async {
    final user = currentUser;
    if (user == null) return false;
    try {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      return doc.exists && (doc.data()?['profileComplete'] == true);
    } catch (e) {
      return false;
    }
  }

  static Future<void> sendPasswordResetEmail({required String email}) {
    return _auth.sendPasswordResetEmail(email: email);
  }

  static Future<void> resendEmailVerification() async {
    final user = currentUser;
    if (user != null && !user.emailVerified) {
      await user.sendEmailVerification();
    }
  }

  static Future<void> signOut() async {
    await _auth.signOut();
  }

  static Future<void> reloadCurrentUser() async {
    await currentUser?.reload();
  }
  
  static String getExceptionMessage(dynamic e) {
    if (e is FirebaseAuthException) {
      switch (e.code) {
        case 'user-not-found':
          return 'No user found with this email.';
        case 'wrong-password':
          return 'Incorrect password.';
        case 'email-already-in-use':
          return 'This email is already registered.';
        case 'invalid-email':
          return 'The email address is invalid.';
        case 'weak-password':
          return 'The password is too weak.';
        case 'network-request-failed':
          return 'Please check your internet connection.';
        default:
          return 'Error: ${e.message}';
      }
    }
    return e.toString();
  }
}