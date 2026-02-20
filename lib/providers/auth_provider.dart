import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../config/app_constants.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService;
  final FirestoreService _firestoreService;

  UserModel? _currentUser;
  bool _isLoading = false;
  String? _error;

  AuthProvider(this._authService, this._firestoreService);

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _currentUser != null;
  bool get isArtist => _currentUser?.role == AppConstants.roleArtist;
  bool get isCustomer => _currentUser?.role == AppConstants.roleCustomer;
  String? get error => _error;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    _setLoading(true);
    _error = null;

    try {
      final credential = await _authService.loginWithEmail(email, password);
      final uid = credential.user!.uid;

      final userDoc = await _firestoreService.getUserDocument(uid);
      if (userDoc == null) {
        await _authService.signOut();
        _error = 'Account not found. Please register first.';
        _setLoading(false);
        return false;
      }

      if (userDoc.isSuspended) {
        await _authService.signOut();
        _error = 'Your account has been suspended. Contact support.';
        _setLoading(false);
        return false;
      }

      _currentUser = userDoc;
      _setLoading(false);
      return true;
    } catch (e) {
      _error = _getAuthErrorMessage(e);
      _setLoading(false);
      return false;
    }
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
    required String role,
    String? category,
  }) async {
    _setLoading(true);
    _error = null;

    try {
      final credential =
          await _authService.registerWithEmail(email, password);
      final uid = credential.user!.uid;

      final user = UserModel(
        uid: uid,
        name: name,
        email: email,
        role: role,
        status: AppConstants.statusActive,
        category: role == AppConstants.roleArtist ? category : null,
        averageRating: role == AppConstants.roleArtist ? 0.0 : null,
      );

      await _firestoreService.createUserDocument(uid, user.toFirestore());

      _currentUser = user;
      _setLoading(false);
      return true;
    } catch (e) {
      _error = _getAuthErrorMessage(e);
      _setLoading(false);
      return false;
    }
  }

  Future<void> signOut() async {
    await _authService.signOut();
    _currentUser = null;
    notifyListeners();
  }

  Future<bool> sendPasswordReset(String email) async {
    _setLoading(true);
    _error = null;

    try {
      await _authService.sendPasswordReset(email);
      _setLoading(false);
      return true;
    } catch (e) {
      _error = _getAuthErrorMessage(e);
      _setLoading(false);
      return false;
    }
  }

  Future<void> refreshUser() async {
    final user = _authService.currentUser;
    if (user == null) {
      _currentUser = null;
      notifyListeners();
      return;
    }

    final userDoc = await _firestoreService.getUserDocument(user.uid);
    _currentUser = userDoc;
    notifyListeners();
  }

  Future<bool> updateProfile(Map<String, dynamic> data) async {
    if (_currentUser == null) return false;

    _setLoading(true);
    _error = null;

    try {
      await _firestoreService.updateUserDocument(_currentUser!.uid, data);
      await refreshUser();
      _setLoading(false);
      return true;
    } catch (e) {
      _error = 'Failed to update profile. Please try again.';
      _setLoading(false);
      return false;
    }
  }

  String _getAuthErrorMessage(dynamic error) {
    if (error is! Exception) return 'An unexpected error occurred.';

    final errorStr = error.toString();

    if (errorStr.contains('invalid-email')) {
      return 'Invalid email address format.';
    } else if (errorStr.contains('user-disabled')) {
      return 'This account has been disabled.';
    } else if (errorStr.contains('user-not-found')) {
      return 'No account found with this email.';
    } else if (errorStr.contains('wrong-password')) {
      return 'Incorrect password.';
    } else if (errorStr.contains('invalid-credential') ||
        errorStr.contains('invalid-login-credentials')) {
      return 'Incorrect email or password.';
    } else if (errorStr.contains('email-already-in-use')) {
      return 'An account already exists with this email.';
    } else if (errorStr.contains('weak-password')) {
      return 'Password is too weak. Use at least 6 characters.';
    } else if (errorStr.contains('too-many-requests')) {
      return 'Too many attempts. Please try again later.';
    } else if (errorStr.contains('network-request-failed')) {
      return 'Network error. Check your internet connection.';
    }

    return 'An unexpected error occurred. Please try again.';
  }
}
