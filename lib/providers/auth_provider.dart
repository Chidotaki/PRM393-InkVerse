import 'dart:async';

import 'package:flutter/foundation.dart';

import '../core/errors/app_exception.dart';
import '../models/app_user.dart';
import '../repositories/user_repository.dart';
import '../services/auth_service.dart';

/// Manages authentication state, user profile synchronization, and role capabilities.
class AuthProvider extends ChangeNotifier {
  final AuthService authService;
  final UserRepository userRepository;

  StreamSubscription<String?>? _authSubscription;
  StreamSubscription<AppUser?>? _profileSubscription;

  AppUser? _currentUser;
  bool _initialized = false;
  bool _loading = false;
  bool _submitting = false;
  String? _error;

  AuthProvider({required this.authService, required this.userRepository}) {
    _listenToAuthChanges();
  }

  // Getters
  AppUser? get currentUser => _currentUser;
  String? get currentUid => _currentUser?.uid ?? authService.currentUserId;
  bool get initialized => _initialized;
  bool get loading => _loading;
  bool get submitting => _submitting;
  String? get error => _error;

  bool get isAuthenticated =>
      authService.currentUserId != null && _currentUser != null;
  bool get isReader => _currentUser?.isReader ?? false;
  bool get isAuthor => _currentUser?.isAuthor ?? false;
  bool get isAdmin => _currentUser?.isAdmin ?? false;
  bool get isActive => _currentUser?.isActive ?? true;

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void _listenToAuthChanges() {
    _authSubscription?.cancel();
    _authSubscription = authService.authStateChanges.listen((uid) async {
      if (uid == null) {
        _currentUser = null;
        _profileSubscription?.cancel();
        _initialized = true;
        notifyListeners();
      } else {
        await _subscribeToProfile(uid);
      }
    });
  }

  Future<void> _subscribeToProfile(String uid) async {
    _profileSubscription?.cancel();
    _loading = true;
    notifyListeners();

    try {
      final profile = await userRepository.getUserProfile(uid);
      if (profile == null) {
        // Recovery edge-case: Auth user exists (session restore or partial register)
        // but users/{uid} document is missing in Firestore.
        // Safely recreate minimal reader profile; never auto-promote to admin or author.
        final email = authService.currentUserEmail ?? '';
        final fallbackName = email.contains('@')
            ? email.split('@').first
            : 'InkVerse Reader';
        final fallback = AppUser(
          uid: uid,
          fullName: fallbackName,
          email: email,
          role: UserRole.reader,
          isActive: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        await userRepository.createUserProfile(fallback);
        _currentUser = fallback;
      } else {
        _currentUser = profile;
      }
    } catch (e) {
      _error = AppException.from(e).message;
    } finally {
      _loading = false;
      _initialized = true;
      notifyListeners();
    }

    _profileSubscription = userRepository
        .streamUserProfile(uid)
        .listen(
          (profile) {
            if (profile != null) {
              _currentUser = profile;
              notifyListeners();
            }
          },
          onError: (err) {
            _error = AppException.from(err).message;
            notifyListeners();
          },
        );
  }

  /// Registers a new user and sets up default reader profile document.
  Future<void> register({
    required String fullName,
    required String email,
    required String password,
  }) async {
    _submitting = true;
    _error = null;
    notifyListeners();

    try {
      final trimmedName = fullName.trim();
      final trimmedEmail = email.trim();

      if (trimmedName.isEmpty) {
        throw const ValidationException('Full name is required.');
      }
      if (trimmedEmail.isEmpty) {
        throw const ValidationException('Email is required.');
      }
      if (password.length < 6) {
        throw const ValidationException(
          'Password must be at least 6 characters.',
        );
      }

      final uid = await authService.register(
        email: trimmedEmail,
        password: password,
      );

      final newUser = AppUser(
        uid: uid,
        fullName: trimmedName,
        email: trimmedEmail,
        role: UserRole.reader,
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await userRepository.createUserProfile(newUser);
      _currentUser = newUser;
    } catch (e) {
      _error = AppException.from(e).message;
      rethrow;
    } finally {
      _submitting = false;
      notifyListeners();
    }
  }

  /// Signs in user and fetches profile.
  Future<void> login({required String email, required String password}) async {
    _submitting = true;
    _error = null;
    notifyListeners();

    try {
      final trimmedEmail = email.trim();
      if (trimmedEmail.isEmpty) {
        throw const ValidationException('Email is required.');
      }
      if (password.isEmpty) {
        throw const ValidationException('Password is required.');
      }

      final uid = await authService.login(
        email: trimmedEmail,
        password: password,
      );

      final profile = await userRepository.getUserProfile(uid);
      if (profile == null) {
        // Fallback user profile creation if missing
        final fallback = AppUser(
          uid: uid,
          fullName: trimmedEmail.split('@').first,
          email: trimmedEmail,
          role: UserRole.reader,
          isActive: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        await userRepository.createUserProfile(fallback);
        _currentUser = fallback;
      } else {
        _currentUser = profile;
      }
    } catch (e) {
      _error = AppException.from(e).message;
      rethrow;
    } finally {
      _submitting = false;
      notifyListeners();
    }
  }

  /// Logs out the user.
  Future<void> logout() async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      _profileSubscription?.cancel();
      await authService.logout();
      _currentUser = null;
    } catch (e) {
      _error = AppException.from(e).message;
      rethrow;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  /// Refreshes current user profile from remote.
  Future<void> refreshProfile() async {
    final uid = currentUid;
    if (uid == null) return;

    try {
      final profile = await userRepository.getUserProfile(uid);
      if (profile != null) {
        _currentUser = profile;
        notifyListeners();
      }
    } catch (e) {
      _error = AppException.from(e).message;
      notifyListeners();
    }
  }

  /// Updates allowed profile fields (fullName, bio, avatarUrl).
  Future<void> updateProfile({
    required String fullName,
    required String bio,
    required String avatarUrl,
  }) async {
    final uid = currentUid;
    if (uid == null) throw const AuthException('Not authenticated.');

    _submitting = true;
    _error = null;
    notifyListeners();

    try {
      await userRepository.updateProfile(
        uid: uid,
        fullName: fullName,
        bio: bio,
        avatarUrl: avatarUrl,
      );
      await refreshProfile();
    } catch (e) {
      _error = AppException.from(e).message;
      rethrow;
    } finally {
      _submitting = false;
      notifyListeners();
    }
  }

  /// Transitions a reader to author.
  Future<void> becomeAuthor() async {
    final uid = currentUid;
    if (uid == null) throw const AuthException('Not authenticated.');

    if (_currentUser?.role != UserRole.reader) {
      throw const ConflictException(
        'Only users with the reader role can become an author.',
      );
    }

    _submitting = true;
    _error = null;
    notifyListeners();

    try {
      await userRepository.becomeAuthor(uid);
      await refreshProfile();
    } catch (e) {
      _error = AppException.from(e).message;
      rethrow;
    } finally {
      _submitting = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    _profileSubscription?.cancel();
    super.dispose();
  }
}
