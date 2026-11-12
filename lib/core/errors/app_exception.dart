import 'package:firebase_core/firebase_core.dart';

/// Base class for all user-friendly application domain exceptions.
class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic details;

  const AppException(this.message, {this.code, this.details});

  @override
  String toString() => message;

  /// Helper factory to convert FirebaseException and other generic errors
  /// into user-friendly domain messages.
  factory AppException.from(dynamic error) {
    if (error is AppException) {
      return error;
    }

    if (error is FirebaseException) {
      switch (error.code) {
        case 'user-not-found':
        case 'wrong-password':
        case 'invalid-credential':
          return const AuthException('Invalid email or password.');
        case 'email-already-in-use':
          return const AuthException('This email is already registered.');
        case 'invalid-email':
          return const AuthException('The email address is badly formatted.');
        case 'weak-password':
          return const AuthException(
            'The password must be at least 6 characters.',
          );
        case 'user-disabled':
          return const AuthException('This account has been disabled.');
        case 'permission-denied':
          return const PermissionDeniedException(
            'You do not have permission to perform this action.',
          );
        case 'not-found':
          return const NotFoundException(
            'The requested resource was not found.',
          );
        case 'already-exists':
          return const ConflictException('This record already exists.');
        case 'unavailable':
          return const AppException(
            'Service is temporarily unavailable. Please try again later.',
            code: 'unavailable',
          );
        default:
          return AppException(
            error.message ?? 'An unexpected error occurred. Please try again.',
            code: error.code,
          );
      }
    }

    return AppException(
      error?.toString() ?? 'Unable to complete operation. Please try again.',
    );
  }
}

class AuthException extends AppException {
  const AuthException(super.message, {super.code, super.details});
}

class PermissionDeniedException extends AppException {
  const PermissionDeniedException(
    super.message, {
    super.code = 'permission-denied',
    super.details,
  });
}

class NotFoundException extends AppException {
  const NotFoundException(
    super.message, {
    super.code = 'not-found',
    super.details,
  });
}

class ValidationException extends AppException {
  const ValidationException(
    super.message, {
    super.code = 'validation-error',
    super.details,
  });
}

class ConflictException extends AppException {
  const ConflictException(
    super.message, {
    super.code = 'conflict',
    super.details,
  });
}
