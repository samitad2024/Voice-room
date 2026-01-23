import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;

  const Failure(this.message);

  @override
  List<Object> get props => [message];
}

// General failures
class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Server error occurred']);
}

class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Cache error occurred']);
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'No internet connection']);
}

// Auth failures
class AuthFailure extends Failure {
  const AuthFailure([super.message = 'Authentication failed']);
}

class InvalidCredentialsFailure extends Failure {
  const InvalidCredentialsFailure([super.message = 'Invalid credentials']);
}

class UserNotFoundFailure extends Failure {
  const UserNotFoundFailure([super.message = 'User not found']);
}

class WeakPasswordFailure extends Failure {
  const WeakPasswordFailure([super.message = 'Password is too weak']);
}

class EmailAlreadyInUseFailure extends Failure {
  const EmailAlreadyInUseFailure([super.message = 'Email already in use']);
}

class InvalidPhoneNumberFailure extends Failure {
  const InvalidPhoneNumberFailure([super.message = 'Invalid phone number']);
}

class InvalidVerificationCodeFailure extends Failure {
  const InvalidVerificationCodeFailure(
      [super.message = 'Invalid verification code']);
}

class AgeVerificationFailure extends Failure {
  const AgeVerificationFailure([super.message = 'Age verification failed']);
}

// Firestore failures
class FirestoreFailure extends Failure {
  const FirestoreFailure([super.message = 'Database error occurred']);
}

class DocumentNotFoundFailure extends Failure {
  const DocumentNotFoundFailure([super.message = 'Document not found']);
}

// Permission failures
class PermissionDeniedFailure extends Failure {
  const PermissionDeniedFailure([super.message = 'Permission denied']);
}

// Zego failures
class ZegoFailure extends Failure {
  const ZegoFailure([super.message = 'Voice service error']);
}

class ZegoTokenExpiredFailure extends Failure {
  const ZegoTokenExpiredFailure([super.message = 'Voice token expired']);
}

// Payment failures
class PaymentFailure extends Failure {
  const PaymentFailure([super.message = 'Payment failed']);
}

class InsufficientFundsFailure extends Failure {
  const InsufficientFundsFailure([super.message = 'Insufficient coins']);
}
