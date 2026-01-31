import 'package:freezed_annotation/freezed_annotation.dart';

part 'failure.freezed.dart';

/// Failure class for functional error handling
@freezed
class Failure with _$Failure {
  const factory Failure.network({
    required String message,
    String? code,
  }) = NetworkFailure;

  const factory Failure.auth({
    required String message,
    String? code,
  }) = AuthFailure;

  const factory Failure.validation({
    required String message,
    String? code,
    Map<String, List<String>>? fieldErrors,
  }) = ValidationFailure;

  const factory Failure.database({
    required String message,
    String? code,
  }) = DatabaseFailure;

  const factory Failure.server({
    required String message,
    String? code,
    int? statusCode,
  }) = ServerFailure;

  const factory Failure.cache({
    required String message,
    String? code,
  }) = CacheFailure;

  const factory Failure.ai({
    required String message,
    String? code,
  }) = AIFailure;

  const factory Failure.unknown({
    required String message,
    String? code,
  }) = UnknownFailure;
}
