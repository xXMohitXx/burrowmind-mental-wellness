/// Failure types for functional error handling
sealed class Failure {
  final String message;
  final String? code;

  const Failure({required this.message, this.code});
}

/// Network failure
class NetworkFailure extends Failure {
  const NetworkFailure({required super.message, super.code});
}

/// Authentication failure
class AuthFailure extends Failure {
  const AuthFailure({required super.message, super.code});
}

/// Validation failure
class ValidationFailure extends Failure {
  final Map<String, List<String>>? fieldErrors;

  const ValidationFailure({
    required super.message,
    super.code,
    this.fieldErrors,
  });
}

/// Database failure
class DatabaseFailure extends Failure {
  const DatabaseFailure({required super.message, super.code});
}

/// Server failure
class ServerFailure extends Failure {
  final int? statusCode;

  const ServerFailure({
    required super.message,
    super.code,
    this.statusCode,
  });
}

/// Cache failure
class CacheFailure extends Failure {
  const CacheFailure({required super.message, super.code});
}

/// AI failure
class AIFailure extends Failure {
  const AIFailure({required super.message, super.code});
}

/// Unknown failure
class UnknownFailure extends Failure {
  const UnknownFailure({required super.message, super.code});
}
