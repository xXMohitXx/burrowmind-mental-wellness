import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Date utility extensions and functions
extension DateTimeExtension on DateTime {
  /// Format as 'Jan 15, 2024'
  String toDisplayDate() {
    return DateFormat('MMM d, yyyy').format(this);
  }

  /// Format as 'January 15, 2024'
  String toFullDate() {
    return DateFormat('MMMM d, yyyy').format(this);
  }

  /// Format as '15 Jan'
  String toShortDate() {
    return DateFormat('d MMM').format(this);
  }

  /// Format as '3:30 PM'
  String toTime() {
    return DateFormat('h:mm a').format(this);
  }

  /// Format as '15:30'
  String to24HourTime() {
    return DateFormat('HH:mm').format(this);
  }

  /// Format as 'Jan 15, 2024 at 3:30 PM'
  String toDateTimeDisplay() {
    return DateFormat('MMM d, yyyy \'at\' h:mm a').format(this);
  }

  /// Format as relative time (e.g., '2 hours ago', 'Yesterday')
  String toRelativeTime() {
    final now = DateTime.now();
    final difference = now.difference(this);

    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      final minutes = difference.inMinutes;
      return '$minutes ${minutes == 1 ? 'minute' : 'minutes'} ago';
    } else if (difference.inHours < 24) {
      final hours = difference.inHours;
      return '$hours ${hours == 1 ? 'hour' : 'hours'} ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks ${weeks == 1 ? 'week' : 'weeks'} ago';
    } else {
      return toDisplayDate();
    }
  }

  /// Check if date is today
  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  /// Check if date is yesterday
  bool get isYesterday {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return year == yesterday.year &&
        month == yesterday.month &&
        day == yesterday.day;
  }

  /// Get start of day
  DateTime get startOfDay => DateTime(year, month, day);

  /// Get end of day
  DateTime get endOfDay => DateTime(year, month, day, 23, 59, 59, 999);

  /// Get start of week (Monday)
  DateTime get startOfWeek {
    final daysToSubtract = weekday - 1;
    return subtract(Duration(days: daysToSubtract)).startOfDay;
  }

  /// Get start of month
  DateTime get startOfMonth => DateTime(year, month, 1);

  /// Get end of month
  DateTime get endOfMonth => DateTime(year, month + 1, 0, 23, 59, 59, 999);

  /// Format for database storage (ISO 8601)
  String toIso8601() => toIso8601String();
}

/// String extensions
extension StringExtension on String {
  /// Capitalize first letter
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }

  /// Capitalize each word
  String capitalizeWords() {
    return split(' ').map((word) => word.capitalize()).join(' ');
  }

  /// Check if string is a valid email
  bool get isValidEmail {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(this);
  }

  /// Truncate string with ellipsis
  String truncate(int maxLength) {
    if (length <= maxLength) return this;
    return '${substring(0, maxLength)}...';
  }

  /// Parse to DateTime or null
  DateTime? toDateTime() {
    try {
      return DateTime.parse(this);
    } catch (_) {
      return null;
    }
  }
}

/// Number extensions
extension IntExtension on int {
  /// Format with leading zero (e.g., 9 -> "09")
  String padLeft2() => toString().padLeft(2, '0');

  /// Format as duration (e.g., 90 -> "1h 30m")
  String toDurationString() {
    if (this < 60) return '$this min';
    final hours = this ~/ 60;
    final minutes = this % 60;
    if (minutes == 0) return '${hours}h';
    return '${hours}h ${minutes}m';
  }

  /// Format score with label
  String toScoreLabel() {
    if (this >= 80) return 'Excellent';
    if (this >= 60) return 'Good';
    if (this >= 40) return 'Fair';
    if (this >= 20) return 'Low';
    return 'Critical';
  }
}

extension DoubleExtension on double {
  /// Format as percentage
  String toPercentage([int decimals = 0]) {
    return '${(this * 100).toStringAsFixed(decimals)}%';
  }
}

/// Context extensions
extension ContextExtension on BuildContext {
  /// Get screen width
  double get screenWidth => MediaQuery.of(this).size.width;

  /// Get screen height
  double get screenHeight => MediaQuery.of(this).size.height;

  /// Get safe area padding
  EdgeInsets get safeAreaPadding => MediaQuery.of(this).padding;

  /// Check if keyboard is visible
  bool get isKeyboardVisible => MediaQuery.of(this).viewInsets.bottom > 0;

  /// Get theme
  ThemeData get theme => Theme.of(this);

  /// Get color scheme
  ColorScheme get colorScheme => Theme.of(this).colorScheme;

  /// Get text theme
  TextTheme get textTheme => Theme.of(this).textTheme;
}

/// List extensions
extension ListExtension<T> on List<T> {
  /// Get element at index or null
  T? getOrNull(int index) {
    if (index < 0 || index >= length) return null;
    return this[index];
  }
}
