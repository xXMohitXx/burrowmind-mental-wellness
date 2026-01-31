import 'package:flutter/material.dart';
import 'app_exception.dart';

/// Global error handler for the app
class ErrorHandler {
  ErrorHandler._();

  /// Get user-friendly error message from exception
  static String getErrorMessage(dynamic error) {
    if (error is AppException) {
      return error.message;
    }

    if (error is NetworkException) {
      return 'Please check your internet connection and try again.';
    }

    if (error is AuthException) {
      return error.message.isNotEmpty
          ? error.message
          : 'Authentication failed. Please login again.';
    }

    if (error is ServerException) {
      return 'Something went wrong on our end. Please try again later.';
    }

    if (error is DatabaseException) {
      return 'Failed to save data. Please try again.';
    }

    if (error is AIException) {
      return 'AI service is temporarily unavailable. Please try again.';
    }

    return 'An unexpected error occurred. Please try again.';
  }

  /// Get error icon based on exception type
  static IconData getErrorIcon(dynamic error) {
    if (error is NetworkException) {
      return Icons.wifi_off_rounded;
    }

    if (error is AuthException) {
      return Icons.lock_outline_rounded;
    }

    if (error is ServerException) {
      return Icons.cloud_off_rounded;
    }

    if (error is AIException) {
      return Icons.smart_toy_outlined;
    }

    return Icons.error_outline_rounded;
  }

  /// Log error for debugging (can be extended for crash reporting)
  static void logError(dynamic error, [StackTrace? stackTrace]) {
    debugPrint('Error: $error');
    if (stackTrace != null) {
      debugPrint('Stack trace: $stackTrace');
    }
  }

  /// Show error snackbar
  static void showErrorSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Show success snackbar
  static void showSuccessSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.primary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
