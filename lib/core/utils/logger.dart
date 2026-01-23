import 'dart:developer' as developer;

/// Simple logger for development
class AppLogger {
  static const String _prefix = '[SocialVoice]';

  static void log(String message, {String? tag}) {
    developer.log(
      message,
      name: tag != null ? '$_prefix $tag' : _prefix,
    );
  }

  static void error(String message, {Object? error, StackTrace? stackTrace}) {
    developer.log(
      message,
      name: '$_prefix ERROR',
      error: error,
      stackTrace: stackTrace,
    );
  }

  static void debug(String message) {
    developer.log(
      message,
      name: '$_prefix DEBUG',
    );
  }

  static void info(String message) {
    developer.log(
      message,
      name: '$_prefix INFO',
    );
  }

  static void warning(String message) {
    developer.log(
      message,
      name: '$_prefix WARNING',
    );
  }
}
