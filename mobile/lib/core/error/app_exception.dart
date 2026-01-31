/// Base exception for BurrowMind app
abstract class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;

  const AppException({
    required this.message,
    this.code,
    this.originalError,
  });

  @override
  String toString() => 'AppException: $message (code: $code)';
}

/// Network related exceptions
class NetworkException extends AppException {
  const NetworkException({
    required super.message,
    super.code,
    super.originalError,
  });
}

/// Authentication related exceptions
class AuthException extends AppException {
  const AuthException({
    required super.message,
    super.code,
    super.originalError,
  });
}

/// Validation related exceptions
class ValidationException extends AppException {
  final Map<String, List<String>>? fieldErrors;

  const ValidationException({
    required super.message,
    super.code,
    super.originalError,
    this.fieldErrors,
  });
}

/// Database related exceptions
class DatabaseException extends AppException {
  const DatabaseException({
    required super.message,
    super.code,
    super.originalError,
  });
}

/// Server related exceptions
class ServerException extends AppException {
  final int? statusCode;

  const ServerException({
    required super.message,
    super.code,
    super.originalError,
    this.statusCode,
  });
}

/// Cache related exceptions
class CacheException extends AppException {
  const CacheException({
    required super.message,
    super.code,
    super.originalError,
  });
}

/// AI related exceptions
class AIException extends AppException {
  const AIException({
    required super.message,
    super.code,
    super.originalError,
  });
}
