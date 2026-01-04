import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

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
  }) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email, 
      password: password
    );
    final user = cred.user;

    if (user != null) {
      String displayName = email.split('@')[0];
      if (displayName.isNotEmpty) {
        displayName = displayName[0].toUpperCase() + displayName.substring(1);
      }
      await _firestore.collection('users').doc(user.uid).set({
        'email': email,
        'name': displayName, 
        'phone': '',       
        'photoURL': '',    
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'profileComplete': true, 
      });
      await user.updateDisplayName(displayName); 
      await user.reload();
      if (!user.emailVerified) {
        await user.sendEmailVerification();
      }
    }
    return cred;
  }

  /// Sign In with Email/Password
  static Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
  }) {
    return _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  /// Sign In with Google (Updated with Name Fix)
  static Future<UserCredential> signInWithGoogle() async {
    final provider = GoogleAuthProvider()
      ..addScope('profile')
      ..setCustomParameters({'prompt': 'select_account'});

    final UserCredential cred = kIsWeb
        ? await _auth.signInWithPopup(provider)
        : await _auth.signInWithProvider(provider);

    final user = cred.user;

    if (user != null) {
      final docRef = _firestore.collection('users').doc(user.uid);
      final docSnapshot = await docRef.get();
      
      if (!docSnapshot.exists) {
        String displayName = user.displayName ?? '';
        
        // Fallback: Use email prefix if name is missing
        if (displayName.isEmpty && user.email != null) {
          String emailPrefix = user.email!.split('@')[0];
          if (emailPrefix.isNotEmpty) {
            displayName = emailPrefix[0].toUpperCase() + emailPrefix.substring(1);
          } else {
            displayName = emailPrefix;
          }
        }

        await docRef.set({
          'email': user.email,
          'name': displayName,
          'photoURL': user.photoURL ?? '', 
          'phone': user.phoneNumber ?? '',
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
          'profileComplete': true,
          'birthday': null,
          'gender': null,
          'address': null,
        });
      }
    }
    return cred;
  }

  /// Upload Profile Image to Firebase Storage & Update Firestore
  static Future<String> uploadProfileImage({
    required XFile file,
    required String uid,
  }) async {
    try {
      final ref = _storage.ref().child('user_images').child('$uid.jpg');

      final metadata = SettableMetadata(
        contentType: 'image/jpeg',
        customMetadata: {'picked-file-path': file.path},
      );

      final UploadTask uploadTask;

      if (kIsWeb) {
        final bytes = await file.readAsBytes();
        uploadTask = ref.putData(bytes, metadata);
      } else {
        uploadTask = ref.putFile(File(file.path), metadata);
      }

      final TaskSnapshot snapshot = await uploadTask;
      final url = await snapshot.ref.getDownloadURL();
      return url;
    } catch (e) {
      throw Exception('Image upload failed: $e');
    }
  }

  /// Update User Photo URL in Auth & Firestore
  static Future<void> updateUserPhoto(String photoUrl) async {
    final user = currentUser;
    if (user != null) {
      await user.updatePhotoURL(photoUrl);
      await _firestore.collection('users').doc(user.uid).set({
        'photoURL': photoUrl,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
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

  static Future<void> signOut() async {
    await _auth.signOut();
  }

  static Future<void> reloadCurrentUser() async {
    await currentUser?.reload();
  }

  // ----------- THEMED ERROR MESSAGES -----------
  static String getExceptionMessage(dynamic e) {
    if (e is FirebaseAuthException) {
      switch (e.code) {
        case 'user-not-found':
          return 'We couldn\'t find an account. Want to join us?';
        case 'wrong-password':
          return 'That password didn\'t match. Try again?';
        case 'email-already-in-use':
          return 'That email is already sipping coffee with us. Try logging in.';
        case 'invalid-email':
          return 'That email looks incomplete. Please check it.';
        case 'weak-password':
          return 'Your password needs to be a bit stronger.';
        case 'account-exists-with-different-credential':
          return 'You already have an account with a different login method.';
        case 'network-request-failed':
          return 'Connection lost. We can\'t reach the roastery.';
        case 'ERROR_ABORTED_BY_USER':
          return 'Sign in cancelled.';
        default:
          return 'Something went wrong: ${e.message}';
      }
    }
    return 'Oops! Spilled the coffee. Please try again.';
  }
}