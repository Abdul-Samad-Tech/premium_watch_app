import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'dart:convert';
import '../services/firebase_auth_service.dart';
import '../services/email_service.dart';

class User {
  String id;
  String name;
  String email;
  String phone;
  String address;
  String city;
  String postalCode;
  String role; // 'admin' or 'user'
  DateTime createdAt;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.phone = '',
    this.address = '',
    this.city = '',
    this.postalCode = '',
    this.role = 'user', // Default role is 'user'
    required this.createdAt,
  });

  bool get isAdmin => role == 'admin';
  bool get isUser => role == 'user';

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'address': address,
      'city': city,
      'postalCode': postalCode,
      'role': role,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      address: map['address'] ?? '',
      city: map['city'] ?? '',
      postalCode: map['postalCode'] ?? '',
      role: map['role'] ?? 'user',
      createdAt: DateTime.parse(map['createdAt']),
    );
  }
}

class UserProvider with ChangeNotifier {
  User? _currentUser;
  List<User> _users = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Firebase services - lazy initialization
  FirebaseAuthService? _authService;
  firebase_auth.FirebaseAuth? _firebaseAuth;
  final Logger _logger = Logger();

  UserProvider() {
    // Initialize Firebase services for all platforms
    _authService = FirebaseAuthService();
    _firebaseAuth = firebase_auth.FirebaseAuth.instance;
    _listenToAuthState();

    // Load data from local storage (works on all platforms)
    _loadUsers();
    _loadCurrentUser();
    _createDefaultAdmin();
  }

  User? get currentUser => _currentUser;
  List<User> get users => _users;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _currentUser != null;
  String? get errorMessage => _errorMessage;

  // Listen to Firebase auth state changes
  void _listenToAuthState() {
    _firebaseAuth!.authStateChanges().listen((firebase_auth.User? user) {
      if (user != null) {
        // User is signed in
        _loadUserDataFromFirestore(user.uid);
      } else {
        // User is signed out
        _currentUser = null;
        notifyListeners();
      }
    });
  }

  // Load user data from Firestore
  Future<void> _loadUserDataFromFirestore(String uid) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();
      if (doc.exists) {
        final data = doc.data()!;
        _currentUser = User(
          id: uid,
          name: data['name'] ?? '',
          email: data['email'] ?? '',
          phone: data['phone'] ?? '',
          address: data['address'] ?? '',
          role: data['role'] ?? 'user',
          createdAt:
              (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
        );
        await _saveCurrentUser();
        notifyListeners();
      }
    } catch (e) {
      _logger.d('Error loading users: $e');
    }
  }

  // Load users from Firestore
  Future<void> _loadUsersFromFirestore() async {
    try {
      _isLoading = true;
      notifyListeners();

      final usersCollection = FirebaseFirestore.instance.collection('users');
      final snapshot = await usersCollection.get();

      _users = snapshot.docs.map((doc) {
        final data = doc.data();
        return User(
          id: doc.id,
          name: data['name'] ?? '',
          email: data['email'] ?? '',
          phone: data['phone'] ?? '',
          address: data['address'] ?? '',
          role: data['role'] ?? 'user',
          createdAt:
              (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
        );
      }).toList();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _logger.d('Error loading users from Firestore: $e');
      // Fallback to local storage if Firestore fails
      await _loadUsers();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _createDefaultAdmin() async {
    // NOTE: Default admin should be created via Firebase Console, not in code
    // This method is kept for backward compatibility but should not be used
    // Firebase Authentication handles user creation securely
  }

  Future<void> _loadUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final usersJson = prefs.getStringList('users') ?? [];
    _users = usersJson.map((json) => User.fromMap(jsonDecode(json))).toList();
    notifyListeners();
  }

  Future<void> _saveUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final usersJson = _users.map((user) => jsonEncode(user.toMap())).toList();
    await prefs.setStringList('users', usersJson);
  }

  Future<void> _loadCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('currentUser');
    if (userJson != null) {
      _currentUser = User.fromMap(jsonDecode(userJson));
      notifyListeners();
    }
  }

  Future<void> _saveCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    if (_currentUser != null) {
      await prefs.setString('currentUser', jsonEncode(_currentUser!.toMap()));
    } else {
      await prefs.remove('currentUser');
    }
  }

  // SIGNUP WITH FIREBASE
  Future<bool> signup({
    required String name,
    required String email,
    required String password,
    String? phone,
    String? address,
    String role = 'user',
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    // Always use Firebase for authentication
    try {
      final userCredential = await _authService!.signUpWithEmail(
        email: email,
        password: password,
        name: name,
        phone: phone,
        address: address,
      );

      if (userCredential != null && userCredential.user != null) {
        _currentUser = User(
          id: userCredential.user!.uid,
          name: name,
          email: email,
          phone: phone ?? '',
          address: address ?? '',
          role: role,
          createdAt: DateTime.now(),
        );

        await _saveCurrentUser();

        // Send welcome email (in background)
        EmailService.sendWelcomeEmail(toEmail: email, userName: name);

        _isLoading = false;
        notifyListeners();
        return true;
      }

      _isLoading = false;
      notifyListeners();
      return false;
    } on firebase_auth.FirebaseAuthException catch (e) {
      _errorMessage = e.message ?? 'Signup failed';
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'An error occurred during signup: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // LOGIN WITH FIREBASE
  Future<bool> login({required String email, required String password}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Always use Firebase for authentication
      final userCredential = await _authService!.loginWithEmail(
        email: email,
        password: password,
      );

      if (userCredential != null && userCredential.user != null) {
        // Load user data from Firestore
        await _loadUserDataFromFirestore(userCredential.user!.uid);

        _isLoading = false;
        notifyListeners();
        return true;
      }

      _errorMessage = 'Invalid email or password';
      _isLoading = false;
      notifyListeners();
      return false;
    } on firebase_auth.FirebaseAuthException catch (e) {
      _errorMessage = e.message ?? 'Login failed';
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'An error occurred during login: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // GOOGLE SIGN-IN
  Future<bool> signInWithGoogle() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    // Initialize auth service if not already done
    if (_authService == null) {
      _authService = FirebaseAuthService();
    }

    try {
      final userCredential = await _authService!.signInWithGoogle();

      if (userCredential != null && userCredential.user != null) {
        await _loadUserDataFromFirestore(userCredential.user!.uid);

        _isLoading = false;
        notifyListeners();
        return true;
      }

      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Google sign-in failed: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // PASSWORD RESET
  Future<bool> sendPasswordResetEmail(String email) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authService!.sendPasswordResetEmail(email);

      _isLoading = false;
      notifyListeners();
      return true;
    } on firebase_auth.FirebaseAuthException catch (e) {
      _errorMessage = e.message ?? 'Password reset failed';
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'An error occurred';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // EMAIL VERIFICATION
  Future<bool> sendEmailVerification() async {
    try {
      await _authService!.sendEmailVerification();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to send verification email';
      notifyListeners();
      return false;
    }
  }

  Future<bool> checkEmailVerified() async {
    return await _authService!.isEmailVerified();
  }

  // LOGOUT WITH FIREBASE
  Future<void> logout() async {
    await _authService!.signOut();
    _currentUser = null;
    await _saveCurrentUser();
    notifyListeners();
  }

  // UPDATE PROFILE
  Future<bool> updateProfile({
    String? name,
    String? phone,
    String? address,
  }) async {
    if (_currentUser == null) return false;

    if (name != null) _currentUser!.name = name;
    if (phone != null) _currentUser!.phone = phone;
    if (address != null) _currentUser!.address = address;

    // Update in users list
    final index = _users.indexWhere((u) => u.id == _currentUser!.id);
    if (index != -1) {
      _users[index] = _currentUser!;
    }

    await _saveUsers();
    await _saveCurrentUser();
    notifyListeners();
    return true;
  }

  // CHANGE PASSWORD
  Future<bool> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    // Password changes should be handled via Firebase Auth
    // User must be reauthenticated before changing password
    try {
      final user = _firebaseAuth!.currentUser;
      if (user == null) {
        _errorMessage = 'No user logged in';
        notifyListeners();
        return false;
      }

      // Reauthenticate with old password
      final credential = firebase_auth.EmailAuthProvider.credential(
        email: user.email!,
        password: oldPassword,
      );
      await user.reauthenticateWithCredential(credential);

      // Update password
      await user.updatePassword(newPassword);
      return true;
    } on firebase_auth.FirebaseAuthException catch (e) {
      _errorMessage = 'Failed to update password: ${e.message}';
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'An error occurred: $e';
      notifyListeners();
      return false;
    }
  }

  // DELETE ACCOUNT
  Future<void> deleteAccount() async {
    if (_currentUser == null) return;

    _users.removeWhere((u) => u.id == _currentUser!.id);
    _currentUser = null;

    await _saveUsers();
    await _saveCurrentUser();
    notifyListeners();
  }

  // CRUD: Get all users (for admin)
  Future<List<User>> getAllUsers() async {
    await _loadUsers();
    return _users;
  }

  // CRUD: Update user (for admin)
  Future<bool> updateUser(String userId, Map<String, dynamic> updates) async {
    final index = _users.indexWhere((u) => u.id == userId);
    if (index == -1) return false;

    if (updates['name'] != null) _users[index].name = updates['name'];
    if (updates['email'] != null) _users[index].email = updates['email'];
    if (updates['phone'] != null) _users[index].phone = updates['phone'];
    if (updates['address'] != null) _users[index].address = updates['address'];

    await _saveUsers();
    notifyListeners();
    return true;
  }

  // CRUD: Delete user (for admin)
  Future<bool> deleteUser(String userId) async {
    final initialLength = _users.length;
    _users.removeWhere((u) => u.id == userId);

    if (_users.length < initialLength) {
      await _saveUsers();
      notifyListeners();
      return true;
    }
    return false;
  }
}
