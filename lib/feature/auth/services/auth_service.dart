import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:island_cafe/feature/auth/services/user_sync_service.dart';

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
      password: password,
    );
    final user = cred.user;

    if (user != null) {
      String displayName = email.split('@')[0];
      if (displayName.isNotEmpty) {
        displayName = displayName[0].toUpperCase() + displayName.substring(1);
      }

      // 1. Save to Firestore
      await _firestore.collection('users').doc(user.uid).set({
        'email': email,
        'name': displayName,
        'phone': '',
        'photoURL': '',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'profileComplete': true,
      });

      // 2. Sync to External API (CREATE)
      await UserSyncService.createUser(
        uid: user.uid, // Pass UID as ID
        name: displayName,
        email: email,
        phone: "",
        gender: "",
        birthday: "",
        photoURL: "",
      );

      await user.updateDisplayName(displayName);
      await user.reload();
      if (!user.emailVerified) {
        await user.sendEmailVerification();
      }
    }
    return cred;
  }

  static Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      return Future.error(e);
    }
  }

  /// Sign In with Google
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

      // If user document does not exist, it's a NEW user
      if (!docSnapshot.exists) {
        String displayName = user.displayName ?? '';
        if (displayName.isEmpty && user.email != null) {
          String emailPrefix = user.email!.split('@')[0];
          displayName = emailPrefix.isNotEmpty
              ? emailPrefix[0].toUpperCase() + emailPrefix.substring(1)
              : emailPrefix;
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
        
        // 2. Sync to External API (CREATE)
        await UserSyncService.createUser(
          uid: user.uid,
          name: displayName,
          email: user.email!,
          phone: user.phoneNumber ?? "",
          gender: "",
          birthday: "",
          photoURL: user.photoURL ?? "",
        );
      }
    }
    return cred;
  }

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

  /// Save User Details to Firestore AND Update External API
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

    final user = currentUser;
    if (user != null) {
      await user.updateDisplayName(name);

      // 2. Sync to External API (UPDATE via PATCH)
      await UserSyncService.updateUser(
        uid: user.uid, // Use UID to identify record to update
        name: name,
        email: user.email ?? "",
        phone: phone,
        gender: gender,
        birthday: birthday,
        photoURL: user.photoURL,
      );
    }
  }

  static Future<void> deleteAccount() async {
    final user = currentUser;
    if (user != null) {
      String uid = user.uid;

      try {
        // 1. Delete from Firestore
        await _firestore.collection('users').doc(uid).delete();
        await _storage.ref().child('user_images').child('$uid.jpg').delete().catchError((_) {}); 

        // 2. Sync to External API (DELETE)
        await UserSyncService.deleteUser(uid);

        // 3. Delete from Firebase Auth
        await user.delete(); 
      } catch (e) {
        throw Exception('Failed to delete account: $e');
      }
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

  /// Upload a Feedback Image
  /// Returns the download URL of the uploaded image.
  static Future<String> uploadFeedbackImage({
    required XFile file,
    required String uid,
  }) async {
    try {
      // Create a unique filename using a timestamp so images don't overwrite each other
      final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final String fileName = '$timestamp.jpg';

      // Path: feedback_images/USER_ID/17098234234.jpg
      final ref = _storage
          .ref()
          .child('feedback_images')
          .child(uid)
          .child(fileName);

      final metadata = SettableMetadata(
        contentType: 'image/jpeg',
        customMetadata: {
          'picked-file-path': file.path,
          'uploaded-by': uid, // Useful for admin tracking
        },
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
      throw Exception('Feedback image upload failed: $e');
    }
  }

  static String getExceptionMessage(dynamic e) {
    if (e is FirebaseAuthException) {
      switch (e.code) {
        case 'user-not-found':
          return 'We couldn\'t find an account. Want to join us?';
        case 'invalid-credential':
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
