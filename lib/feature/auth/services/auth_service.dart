import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:island_cafe/feature/auth/services/user_sync_service.dart';

class AuthService {
  static FirebaseAuth get _auth => FirebaseAuth.instance;
  static FirebaseFirestore get _firestore => FirebaseFirestore.instance;
  static FirebaseStorage get _storage => FirebaseStorage.instanceFor(
    app: Firebase.app(),
    bucket: 'islandcoffeeapp-62b47.firebasestorage.app',
  );

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
        uid: user.uid,
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

  /// Upload Profile Image to Firebase Storage
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
      await user.reload();

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
        uid: user.uid,
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
        // 1. Delete from Firestore (Requires the rule update above!)
        await _firestore.collection('users').doc(uid).delete();

        // 2. Delete Profile Image (Best effort - ignore error if image doesn't exist)
        await _storage
            .ref()
            .child('user_images')
            .child('$uid.jpg')
            .delete()
            .catchError(
              (_) {},
            ); // catchError prevents crash if image is missing

        // 3. Sync to External API
        await UserSyncService.deleteUser(uid);

        // 4. Delete from Firebase Auth
        await user.delete();
      } on FirebaseAuthException catch (e) {
        if (e.code == 'requires-recent-login') {
          // Throw a specific message so the UI knows to ask for re-login
          throw Exception(
            'Please log out and log in again to delete your account.',
          );
        }
        // Re-throw other auth errors
        throw Exception('Auth Error: ${e.message}');
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
