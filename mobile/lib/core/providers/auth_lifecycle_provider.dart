import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/local/database.dart';
import 'mood_provider.dart';
import 'sleep_provider.dart';
import 'journal_provider.dart';
import 'chat_provider.dart';
import 'wellness_score_provider.dart';
import 'user_context_provider.dart';

/// Auth Lifecycle Service - Manages data clearing and provider resets
///
/// Ensures complete user isolation:
/// - Clears all SQLite data for a user on logout
/// - Resets all Riverpod providers to initial state
/// - Clears AI context cache

class AuthLifecycleService {
  final Ref _ref;

  AuthLifecycleService(this._ref);

  /// Clear all user data on logout
  /// Call this BEFORE clearing auth state
  Future<void> clearUserData(String userId) async {
    // 1. Clear database data for user
    await _clearDatabaseData(userId);

    // 2. Reset all providers to initial state
    _resetProviders();
  }

  /// Clear all database data for a specific user
  Future<void> _clearDatabaseData(String userId) async {
    final db = await AppDatabase.instance.database;

    // Delete all user-specific data from each table
    await db.delete('mood_entries', where: 'user_id = ?', whereArgs: [userId]);
    await db.delete('sleep_entries', where: 'user_id = ?', whereArgs: [userId]);
    await db
        .delete('journal_entries', where: 'user_id = ?', whereArgs: [userId]);
    await db
        .delete('ai_conversations', where: 'user_id = ?', whereArgs: [userId]);
    await db.delete('mental_health_scores',
        where: 'user_id = ?', whereArgs: [userId]);
    await db.delete('assessment_results',
        where: 'user_id = ?', whereArgs: [userId]);
    await db
        .delete('mindful_sessions', where: 'user_id = ?', whereArgs: [userId]);
    await db
        .delete('stress_entries', where: 'user_id = ?', whereArgs: [userId]);
    await db
        .delete('notification_logs', where: 'user_id = ?', whereArgs: [userId]);
    await db.delete('app_settings', where: 'user_id = ?', whereArgs: [userId]);

    // Finally delete the user record
    await db.delete('users', where: 'id = ?', whereArgs: [userId]);
  }

  /// Reset all Riverpod providers to their initial state
  void _resetProviders() {
    // Invalidate all user-data providers to reset them
    _ref.invalidate(moodEntriesProvider);
    _ref.invalidate(sleepEntriesProvider);
    _ref.invalidate(journalEntriesProvider);
    _ref.invalidate(chatProvider);
    _ref.invalidate(wellnessScoreProvider);
    _ref.invalidate(userContextProvider);
  }

  /// Called when a new user logs in - ensures fresh state
  Future<void> onUserLogin(String userId) async {
    // Update the current user ID
    _ref.read(currentUserIdProvider.notifier).state = userId;

    // Refresh all user data providers
    _ref.invalidate(moodEntriesProvider);
    _ref.invalidate(sleepEntriesProvider);
    _ref.invalidate(journalEntriesProvider);
    _ref.invalidate(chatProvider);
    _ref.invalidate(wellnessScoreProvider);
    _ref.invalidate(userContextProvider);
  }
}

/// Auth lifecycle service provider
final authLifecycleServiceProvider = Provider<AuthLifecycleService>((ref) {
  return AuthLifecycleService(ref);
});

/// Current user ID provider - should be updated on auth changes
/// This is now the source of truth for user identity
final currentUserIdProvider = StateProvider<String>((ref) {
  return ''; // Empty by default, set on login
});
