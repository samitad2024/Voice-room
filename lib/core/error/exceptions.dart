class ServerException implements Exception {
  final String message;
  ServerException([this.message = 'Server error occurred']);
}

class CacheException implements Exception {
  final String message;
  CacheException([this.message = 'Cache error occurred']);
}

class NetworkException implements Exception {
  final String message;
  NetworkException([this.message = 'No internet connection']);
}

class AuthException implements Exception {
  final String message;
  AuthException([this.message = 'Authentication failed']);
}

class FirestoreException implements Exception {
  final String message;
  FirestoreException([this.message = 'Database error occurred']);
}

class ZegoException implements Exception {
  final String message;
  ZegoException([this.message = 'Voice service error']);
}

class PaymentException implements Exception {
  final String message;
  PaymentException([this.message = 'Payment failed']);
}
