/// Validation utilities for form inputs
class Validators {
  Validators._();

  /// Email validation
  static String? email(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  /// Password validation
  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return 'Password must contain an uppercase letter';
    }
    if (!RegExp(r'[a-z]').hasMatch(value)) {
      return 'Password must contain a lowercase letter';
    }
    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return 'Password must contain a number';
    }
    return null;
  }

  /// Simple password (for login, not registration)
  static String? simplePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    return null;
  }

  /// Password confirmation
  static String? confirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != password) {
      return 'Passwords do not match';
    }
    return null;
  }

  /// Required field
  static String? required(String? value, [String fieldName = 'This field']) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  /// Name validation
  static String? name(String? value) {
    if (value == null || value.isEmpty) {
      return 'Name is required';
    }
    if (value.length < 2) {
      return 'Name must be at least 2 characters';
    }
    if (value.length > 50) {
      return 'Name must be less than 50 characters';
    }
    return null;
  }

  /// OTP validation
  static String? otp(String? value) {
    if (value == null || value.isEmpty) {
      return 'OTP is required';
    }
    if (value.length != 6) {
      return 'OTP must be 6 digits';
    }
    if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
      return 'OTP must contain only numbers';
    }
    return null;
  }

  /// PIN validation
  static String? pin(String? value) {
    if (value == null || value.isEmpty) {
      return 'PIN is required';
    }
    if (value.length != 4) {
      return 'PIN must be 4 digits';
    }
    if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
      return 'PIN must contain only numbers';
    }
    return null;
  }

  /// Date of birth validation
  static String? dateOfBirth(DateTime? value) {
    if (value == null) {
      return 'Date of birth is required';
    }
    final now = DateTime.now();
    final age = now.year - value.year;
    if (age < 13) {
      return 'You must be at least 13 years old';
    }
    if (age > 120) {
      return 'Please enter a valid date of birth';
    }
    return null;
  }

  /// Phone number validation
  static String? phone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }
    // Remove any non-digit characters for validation
    final digits = value.replaceAll(RegExp(r'[^\d]'), '');
    if (digits.length < 10 || digits.length > 15) {
      return 'Please enter a valid phone number';
    }
    return null;
  }

  /// Journal content validation
  static String? journalContent(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Journal entry cannot be empty';
    }
    if (value.length > 10000) {
      return 'Journal entry is too long';
    }
    return null;
  }

  /// Message validation (for chat)
  static String? message(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Message cannot be empty';
    }
    if (value.length > 2000) {
      return 'Message is too long';
    }
    return null;
  }
}
