import 'package:firebase_auth/firebase_auth.dart';

import '../core/errors/app_exception.dart';

/// Interface defining authentication service operations.
abstract class AuthService {
  /// Stream that emits the current user's UID or null on auth state change.
  Stream<String?> get authStateChanges;

  /// Current authenticated user ID or null.
  String? get currentUserId;

  /// Current authenticated user email or null.
  String? get currentUserEmail;

  /// Register a new user with email and password. Returns the new UID.
  Future<String> register({required String email, required String password});

  /// Login with email and password. Returns the user's UID.
  Future<String> login({required String email, required String password});

  /// Log out the currently authenticated user.
  Future<void> logout();

  /// Reloads current user session state.
  Future<void> reloadUser();
}

/// Firebase implementation of [AuthService].
class FirebaseAuthService implements AuthService {
  final FirebaseAuth _firebaseAuth;

  FirebaseAuthService({FirebaseAuth? firebaseAuth})
    : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  @override
  Stream<String?> get authStateChanges =>
      _firebaseAuth.authStateChanges().map((user) => user?.uid);

  @override
  String? get currentUserId => _firebaseAuth.currentUser?.uid;

  @override
  String? get currentUserEmail => _firebaseAuth.currentUser?.email;

  @override
  Future<String> register({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final user = credential.user;
      if (user == null) {
        throw const AuthException('Registration failed: no user returned.');
      }
      return user.uid;
    } catch (e) {
      throw AppException.from(e);
    }
  }

  @override
  Future<String> login({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final user = credential.user;
      if (user == null) {
        throw const AuthException('Login failed: user not found.');
      }
      return user.uid;
    } catch (e) {
      throw AppException.from(e);
    }
  }

  @override
  Future<void> logout() async {
    try {
      await _firebaseAuth.signOut();
    } catch (e) {
      throw AppException.from(e);
    }
  }

  @override
  Future<void> reloadUser() async {
    try {
      await _firebaseAuth.currentUser?.reload();
    } catch (e) {
      throw AppException.from(e);
    }
  }
}
