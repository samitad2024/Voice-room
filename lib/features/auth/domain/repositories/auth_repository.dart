import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/user.dart';

/// Auth repository interface
abstract class AuthRepository {
  /// Get current authenticated user
  Future<Either<Failure, User>> getCurrentUser();

  /// Login with phone number (sends OTP)
  Future<Either<Failure, String>> loginWithPhone(String phoneNumber);

  /// Verify phone OTP code
  Future<Either<Failure, User>> verifyPhoneCode({
    required String verificationId,
    required String smsCode,
  });

  /// Login with Google
  Future<Either<Failure, User>> loginWithGoogle();

  /// Login with email and password
  Future<Either<Failure, User>> loginWithEmail({
    required String email,
    required String password,
  });

  /// Register with email and password
  Future<Either<Failure, User>> registerWithEmail({
    required String email,
    required String password,
    required String name,
  });

  /// Verify user age
  Future<Either<Failure, User>> verifyAge({
    required String uid,
    required DateTime dateOfBirth,
  });

  /// Logout
  Future<Either<Failure, void>> logout();

  /// Check if user is authenticated
  Future<bool> isAuthenticated();
}
