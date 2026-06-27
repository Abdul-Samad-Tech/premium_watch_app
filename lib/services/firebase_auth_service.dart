import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logger/logger.dart';
import 'package:flutter/foundation.dart';
import 'email_service.dart';

class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: kIsWeb
        ? '710232845165-6i9curersprquvvusc44v82sikaac4qu.apps.googleusercontent.com'
        : null,
    scopes: ['email', 'profile'],
  );
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Logger _logger = Logger();

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Auth state changes stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // EMAIL/PASSWORD SIGNUP
  Future<UserCredential?> signUpWithEmail({
    required String email,
    required String password,
    required String name,
    String? phone,
    String? address,
  }) async {
    try {
      _logger.d('Signing up user: $email');
      // Create user with email and password
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);
      _logger.d('User created successfully');

      // Send email verification
      await userCredential.user?.sendEmailVerification();

      // Send welcome email
      await EmailService.sendWelcomeEmail(toEmail: email, userName: name);

      // Save user data to Firestore
      if (userCredential.user != null) {
        await _firestore.collection('users').doc(userCredential.user!.uid).set({
          'uid': userCredential.user!.uid,
          'name': name,
          'email': email,
          'phone': phone ?? '',
          'address': address ?? '',
          'role': 'user',
          'createdAt': FieldValue.serverTimestamp(),
          'emailVerified': false,
        });
        _logger.d('User data saved to Firestore');
      }

      return userCredential;
    } on FirebaseAuthException catch (e) {
      _logger.d('Signup error: ${e.code} - ${e.message}');
      rethrow;
    }
  }

  // EMAIL/PASSWORD LOGIN
  Future<UserCredential?> loginWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      _logger.d('Logging in user: $email');
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      _logger.d('Login successful');

      return userCredential;
    } on FirebaseAuthException catch (e) {
      _logger.d('Login error: ${e.code} - ${e.message}');
      rethrow;
    }
  }

  // GOOGLE SIGN-IN
  Future<UserCredential?> signInWithGoogle() async {
    try {
      _logger.d('Starting Google sign-in...');

      // Check if running on web
      if (kIsWeb) {
        _logger.d(
          'Google sign-in not available on web due to OAuth configuration',
        );
        throw Exception(
          'Google sign-in requires OAuth configuration on web. '
          'Please configure Authorized JavaScript Origins in Google Cloud Console. '
          'For now, please use email/password login.',
        );
      }

      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      _logger.d('Google user: ${googleUser?.email}');

      if (googleUser == null) {
        _logger.d('User canceled Google sign-in');
        return null; // User canceled the sign-in
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      _logger.d('Got Google auth tokens');

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      UserCredential userCredential = await _auth.signInWithCredential(
        credential,
      );
      _logger.d('Firebase sign-in successful: ${userCredential.user?.email}');

      // Save or update user data in Firestore
      if (userCredential.user != null) {
        final userDoc = await _firestore
            .collection('users')
            .doc(userCredential.user!.uid)
            .get();

        if (!userDoc.exists) {
          // New user - create document
          await _firestore
              .collection('users')
              .doc(userCredential.user!.uid)
              .set({
                'uid': userCredential.user!.uid,
                'name': userCredential.user!.displayName ?? '',
                'email': userCredential.user!.email ?? '',
                'phone': userCredential.user!.phoneNumber ?? '',
                'address': '',
                'role': 'user',
                'createdAt': FieldValue.serverTimestamp(),
                'emailVerified': userCredential.user!.emailVerified,
                'photoURL': userCredential.user!.photoURL ?? '',
              });
          _logger.d('Created new user document in Firestore');
        }
      }

      return userCredential;
    } on FirebaseAuthException catch (e) {
      _logger.d(
        'Firebase auth error during Google sign-in: ${e.code} - ${e.message}',
      );
      rethrow;
    } catch (e) {
      _logger.d('Google sign-in error: $e');
      rethrow;
    }
  }

  // FACEBOOK LOGIN (Requires additional setup)
  // Note: Facebook login requires Facebook SDK setup
  // This is a placeholder for future implementation

  // PASSWORD RESET
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      _logger.d('Sending password reset email to: $email');
      await _auth.sendPasswordResetEmail(email: email);
      _logger.d('Password reset email sent');
    } on FirebaseAuthException catch (e) {
      _logger.d('Password reset error: ${e.code} - ${e.message}');
      rethrow;
    }
  }

  // EMAIL VERIFICATION
  Future<void> sendEmailVerification() async {
    try {
      if (_auth.currentUser != null && !_auth.currentUser!.emailVerified) {
        await _auth.currentUser!.sendEmailVerification();
        _logger.d('Email verification sent');
      }
    } on FirebaseAuthException catch (e) {
      _logger.d('Email verification error: ${e.code} - ${e.message}');
      rethrow;
    }
  }

  // CHECK EMAIL VERIFIED
  Future<bool> isEmailVerified() async {
    if (_auth.currentUser != null) {
      await _auth.currentUser!.reload();
      return _auth.currentUser!.emailVerified;
    }
    return false;
  }

  // LOGOUT
  Future<void> signOut() async {
    try {
      _logger.d('Signing out...');
      await Future.wait([_auth.signOut(), _googleSignIn.signOut()]);
      _logger.d('Sign out successful');
    } catch (e) {
      _logger.d('Sign out error: $e');
    }
  }

  // DELETE ACCOUNT
  Future<void> deleteAccount() async {
    try {
      if (_auth.currentUser != null) {
        _logger.d('Deleting account: ${_auth.currentUser!.uid}');
        // Delete user data from Firestore
        await _firestore
            .collection('users')
            .doc(_auth.currentUser!.uid)
            .delete();

        // Delete user account
        await _auth.currentUser!.delete();
        _logger.d('Account deleted successfully');
      }
    } on FirebaseAuthException catch (e) {
      _logger.d('Delete account error: ${e.code} - ${e.message}');
      rethrow;
    }
  }

  // GET USER DATA FROM FIRESTORE
  Future<Map<String, dynamic>?> getUserData() async {
    if (_auth.currentUser != null) {
      try {
        final doc = await _firestore
            .collection('users')
            .doc(_auth.currentUser!.uid)
            .get();
        return doc.data();
      } catch (e) {
        _logger.d('Get user data error: $e');
        return null;
      }
    }
    return null;
  }

  // UPDATE USER DATA IN FIRESTORE
  Future<void> updateUserData(Map<String, dynamic> data) async {
    if (_auth.currentUser != null) {
      try {
        await _firestore
            .collection('users')
            .doc(_auth.currentUser!.uid)
            .update(data);
        _logger.d('User data updated successfully');
      } catch (e) {
        _logger.d('Update user data error: $e');
        rethrow;
      }
    }
  }
}
