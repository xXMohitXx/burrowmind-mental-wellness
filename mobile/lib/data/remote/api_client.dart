import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../core/constants/api_endpoints.dart';
import '../../core/constants/app_constants.dart';
import '../../core/error/app_exception.dart';

/// API Client for backend communication
class ApiClient {
  late final Dio _dio;
  String? _accessToken;

  ApiClient() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiEndpoints.baseUrl,
        connectTimeout: AppConstants.apiTimeout,
        receiveTimeout: AppConstants.apiTimeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Add interceptors
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          // Add auth token if available
          if (_accessToken != null) {
            options.headers['Authorization'] = 'Bearer $_accessToken';
          }
          if (kDebugMode) {
            debugPrint('API Request: ${options.method} ${options.path}');
          }
          handler.next(options);
        },
        onResponse: (response, handler) {
          if (kDebugMode) {
            debugPrint('API Response: ${response.statusCode} ${response.requestOptions.path}');
          }
          handler.next(response);
        },
        onError: (error, handler) {
          if (kDebugMode) {
            debugPrint('API Error: ${error.message}');
          }
          handler.next(error);
        },
      ),
    );
  }

  /// Set access token for authenticated requests
  void setAccessToken(String? token) {
    _accessToken = token;
  }

  /// Clear access token (logout)
  void clearAccessToken() {
    _accessToken = null;
  }

  /// GET request
  Future<Map<String, dynamic>> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.get(
        path,
        queryParameters: queryParameters,
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// POST request
  Future<Map<String, dynamic>> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// PUT request
  Future<Map<String, dynamic>> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// DELETE request
  Future<Map<String, dynamic>> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Handle Dio errors and convert to app exceptions
  AppException _handleError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const NetworkException(
          message: 'Connection timed out. Please try again.',
          code: 'TIMEOUT',
        );

      case DioExceptionType.connectionError:
        return const NetworkException(
          message: 'Unable to connect. Please check your internet connection.',
          code: 'NO_CONNECTION',
        );

      case DioExceptionType.badResponse:
        return _handleResponseError(error.response);

      case DioExceptionType.cancel:
        return const NetworkException(
          message: 'Request was cancelled.',
          code: 'CANCELLED',
        );

      default:
        return NetworkException(
          message: error.message ?? 'An unexpected error occurred.',
          code: 'UNKNOWN',
          originalError: error,
        );
    }
  }

  /// Handle HTTP response errors
  AppException _handleResponseError(Response? response) {
    if (response == null) {
      return const ServerException(
        message: 'No response from server.',
        code: 'NO_RESPONSE',
      );
    }

    final statusCode = response.statusCode ?? 0;
    final data = response.data;
    String message = 'An error occurred.';

    if (data is Map && data.containsKey('detail')) {
      message = data['detail'].toString();
    } else if (data is Map && data.containsKey('message')) {
      message = data['message'].toString();
    }

    switch (statusCode) {
      case 400:
        return ValidationException(
          message: message,
          code: 'BAD_REQUEST',
          originalError: response,
        );

      case 401:
        return AuthException(
          message: 'Session expired. Please login again.',
          code: 'UNAUTHORIZED',
          originalError: response,
        );

      case 403:
        return AuthException(
          message: 'You do not have permission to perform this action.',
          code: 'FORBIDDEN',
          originalError: response,
        );

      case 404:
        return ServerException(
          message: 'Resource not found.',
          code: 'NOT_FOUND',
          statusCode: statusCode,
          originalError: response,
        );

      case 422:
        return ValidationException(
          message: message,
          code: 'VALIDATION_ERROR',
          originalError: response,
        );

      case 429:
        return ServerException(
          message: 'Too many requests. Please try again later.',
          code: 'RATE_LIMITED',
          statusCode: statusCode,
          originalError: response,
        );

      case 500:
      case 502:
      case 503:
        return ServerException(
          message: 'Server error. Please try again later.',
          code: 'SERVER_ERROR',
          statusCode: statusCode,
          originalError: response,
        );

      default:
        return ServerException(
          message: message,
          code: 'HTTP_$statusCode',
          statusCode: statusCode,
          originalError: response,
        );
    }
  }
}
