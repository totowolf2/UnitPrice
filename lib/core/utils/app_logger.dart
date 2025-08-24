import 'dart:developer' as developer;

class AppLogger {
  static const String _tag = 'UnitPrice';
  
  static void logEvent(String event, {Map<String, dynamic>? parameters}) {
    developer.log(
      'Event: $event${parameters != null ? ' - $parameters' : ''}',
      name: _tag,
    );
  }
  
  static void logScreenView(String screenName) {
    developer.log(
      'Screen View: $screenName',
      name: _tag,
    );
  }
  
  static void logUserAction(String action, {Map<String, dynamic>? context}) {
    developer.log(
      'User Action: $action${context != null ? ' - $context' : ''}',
      name: _tag,
    );
  }
  
  static void logError(String error, {String? stackTrace}) {
    developer.log(
      'Error: $error${stackTrace != null ? '\nStack: $stackTrace' : ''}',
      name: _tag,
      level: 1000, // Severe level
    );
  }
  
  static void logDebug(String message) {
    developer.log(
      'Debug: $message',
      name: _tag,
      level: 500, // Fine level
    );
  }
}