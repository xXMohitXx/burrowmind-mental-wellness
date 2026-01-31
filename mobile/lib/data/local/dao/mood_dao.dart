import 'dart:convert';
import 'package:uuid/uuid.dart';
import '../database.dart';

/// Data Access Object for Mood Entry operations
class MoodDao {
  final AppDatabase _database;
  static const _uuid = Uuid();

  MoodDao(this._database);

  /// Create a new mood entry
  Future<String> createMoodEntry({
    required String userId,
    required int moodLevel,
    String? moodEmoji,
    List<String>? factors,
    String? notes,
  }) async {
    final db = await _database.database;
    final id = _uuid.v4();
    final now = DateTime.now().toIso8601String();

    await db.insert('mood_entries', {
      'id': id,
      'user_id': userId,
      'mood_level': moodLevel,
      'mood_emoji': moodEmoji,
      'factors': factors != null ? jsonEncode(factors) : null,
      'notes': notes,
      'created_at': now,
      'updated_at': now,
      'sync_status': 'pending',
    });

    return id;
  }

  /// Get mood entry by ID
  Future<Map<String, dynamic>?> getMoodById(String id) async {
    final db = await _database.database;
    final results = await db.query(
      'mood_entries',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    return results.isNotEmpty ? _parseMoodEntry(results.first) : null;
  }

  /// Get mood entries for a user with pagination
  Future<List<Map<String, dynamic>>> getMoodEntries({
    required String userId,
    int limit = 20,
    int offset = 0,
  }) async {
    final db = await _database.database;
    final results = await db.query(
      'mood_entries',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'created_at DESC',
      limit: limit,
      offset: offset,
    );
    return results.map(_parseMoodEntry).toList();
  }

  /// Get mood entries for a date range
  Future<List<Map<String, dynamic>>> getMoodEntriesInRange({
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final db = await _database.database;
    final results = await db.query(
      'mood_entries',
      where: 'user_id = ? AND created_at >= ? AND created_at <= ?',
      whereArgs: [
        userId,
        startDate.toIso8601String(),
        endDate.toIso8601String(),
      ],
      orderBy: 'created_at DESC',
    );
    return results.map(_parseMoodEntry).toList();
  }

  /// Get today's mood entry
  Future<Map<String, dynamic>?> getTodaysMood(String userId) async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final entries = await getMoodEntriesInRange(
      userId: userId,
      startDate: startOfDay,
      endDate: endOfDay,
    );

    return entries.isNotEmpty ? entries.first : null;
  }

  /// Get average mood for a date range
  Future<double?> getAverageMood({
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final db = await _database.database;
    final result = await db.rawQuery('''
      SELECT AVG(mood_level) as average
      FROM mood_entries
      WHERE user_id = ? AND created_at >= ? AND created_at <= ?
    ''', [userId, startDate.toIso8601String(), endDate.toIso8601String()]);

    if (result.isNotEmpty && result.first['average'] != null) {
      return (result.first['average'] as num).toDouble();
    }
    return null;
  }

  /// Update mood entry
  Future<void> updateMoodEntry(String id, Map<String, dynamic> data) async {
    final db = await _database.database;
    if (data.containsKey('factors') && data['factors'] is List) {
      data['factors'] = jsonEncode(data['factors']);
    }
    data['updated_at'] = DateTime.now().toIso8601String();
    data['sync_status'] = 'pending';
    await db.update(
      'mood_entries',
      data,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Delete mood entry
  Future<void> deleteMoodEntry(String id) async {
    final db = await _database.database;
    await db.delete('mood_entries', where: 'id = ?', whereArgs: [id]);
  }

  /// Get mood count for user
  Future<int> getMoodCount(String userId) async {
    final db = await _database.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM mood_entries WHERE user_id = ?',
      [userId],
    );
    return (result.first['count'] as int?) ?? 0;
  }

  /// Parse mood entry from database
  Map<String, dynamic> _parseMoodEntry(Map<String, dynamic> row) {
    final entry = Map<String, dynamic>.from(row);
    if (entry['factors'] != null && entry['factors'] is String) {
      entry['factors'] = jsonDecode(entry['factors'] as String);
    }
    return entry;
  }
}
