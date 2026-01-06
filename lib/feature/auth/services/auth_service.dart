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
  
  // Explicitly use the Firebase Storage bucket: gs://islandcoffeeapp-62b47.firebasestorage.app
  // This ensures images are stored in the correct bucket
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

  /// Upload Feedback Image to Firebase Storage
  /// Stores images in: user_images/feedback/{uid}_{timestamp}.{ext}
  static Future<String> uploadFeedbackImage({
    required XFile file,
    required String uid,
  }) async {
    try {
      // Verify user is authenticated
      final user = currentUser;
      if (user == null) {
        throw Exception('User must be logged in to upload images');
      }

      // Refresh the user's auth token to ensure it's valid
      await user.reload();
      final refreshedUser = currentUser;
      if (refreshedUser == null) {
        throw Exception('User authentication expired. Please log in again.');
      }

      // Verify the uid matches the current user
      if (refreshedUser.uid != uid) {
        throw Exception('User ID mismatch');
      }

      // Check file size (10MB limit as per storage rules)
      int fileSize = 0;
      if (kIsWeb) {
        final bytes = await file.readAsBytes();
        fileSize = bytes.length;
      } else {
        final fileObj = File(file.path);
        fileSize = await fileObj.length();
      }
      const maxSize = 10 * 1024 * 1024; // 10MB
      if (fileSize > maxSize) {
        throw Exception('Image size exceeds 10MB limit. Please choose a smaller image.');
      }

      // Get file extension from original file
      final fileExtension = file.path.split('.').last.toLowerCase();
      final validExtensions = ['jpg', 'jpeg', 'png', 'webp'];
      final ext = validExtensions.contains(fileExtension) ? fileExtension : 'jpg';

      // Use timestamp to ensure unique filenames
      final now = DateTime.now();
      final timestamp = now.millisecondsSinceEpoch;
      final fileName = '${uid}_feedback_$timestamp.$ext';
      
      // Storage path: user_images/feedback/userId_feedback_timestamp.jpg
      final storagePath = 'feedback_images/$fileName';
      final ref = _storage.ref().child(storagePath);

      // Determine content type based on file extension
      String contentType = 'image/jpeg';
      if (ext == 'png') {
        contentType = 'image/png';
      } else if (ext == 'webp') {
        contentType = 'image/webp';
      }

      // Get original filename (fallback to path if name not available)
      final originalFilename = file.name.isNotEmpty 
          ? file.name 
          : file.path.split('/').last;

      final metadata = SettableMetadata(
        contentType: contentType,
        cacheControl: 'public, max-age=31536000', // Cache for 1 year
        customMetadata: {
          'uploaded-by': uid,
          'uploaded-at': now.toIso8601String(),
          'original-filename': originalFilename,
        },
      );

      print('📤 Uploading image to Firebase Storage: $storagePath');
      print('📦 Storage Bucket: ${_storage.bucket}');
      print('🔗 Full Storage Path: gs://${_storage.bucket}/$storagePath');
      print('👤 User ID: ${refreshedUser.uid}');
      print('📏 File size: ${(fileSize / 1024 / 1024).toStringAsFixed(2)} MB');

      final UploadTask uploadTask;

      if (kIsWeb) {
        final bytes = await file.readAsBytes();
        uploadTask = ref.putData(bytes, metadata);
      } else {
        uploadTask = ref.putFile(File(file.path), metadata);
      }

      // Monitor upload progress
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        final progress = (snapshot.bytesTransferred / snapshot.totalBytes) * 100;
        print('📊 Upload progress: ${progress.toStringAsFixed(1)}%');
      });

      final TaskSnapshot snapshot = await uploadTask;
      final url = await snapshot.ref.getDownloadURL();
      
      print('✅ Image uploaded successfully!');
      print('🔗 Download URL: $url');
      print('📁 Storage Path: $storagePath');
      
      return url;
    } catch (e) {
      print('❌ Image upload error: $e');
      print('❌ Error type: ${e.runtimeType}');
      
      // Provide more detailed error message based on error type
      if (e is FirebaseException) {
        final errorCode = e.code;
        final errorMessage = e.message ?? 'Unknown error';
        
        // Handle specific Firebase Storage error codes
        if (errorCode == 'unauthorized' || errorCode == 'permission-denied') {
          throw Exception('Image upload failed: unauthorized - User is not authorized to perform the desired action. Please ensure Firebase Storage rules are deployed and you are logged in.');
        } else if (errorCode == 'unauthenticated') {
          throw Exception('Image upload failed: Authentication expired. Please log in again.');
        } else if (errorCode == 'object-not-found') {
          throw Exception('Image upload failed: Storage path not found.');
        } else if (errorCode == 'quota-exceeded') {
          throw Exception('Image upload failed: Storage quota exceeded.');
        } else {
          throw Exception('Image upload failed: $errorCode - $errorMessage');
        }
      } else if (e is Exception) {
        // Re-throw if it's already an Exception with a message
        rethrow;
      } else {
        throw Exception('Image upload failed: $e');
      }
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
