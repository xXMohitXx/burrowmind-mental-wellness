import 'dart:convert';
import 'package:uuid/uuid.dart';
import '../database.dart';

/// Data Access Object for Journal Entry operations
class JournalDao {
  final AppDatabase _database;
  static const _uuid = Uuid();

  JournalDao(this._database);

  /// Create a new journal entry
  Future<String> createJournalEntry({
    required String userId,
    String? title,
    required String content,
    String? moodId,
    List<String>? tags,
    String? voiceRecordingPath,
    String? aiInsights,
  }) async {
    final db = await _database.database;
    final id = _uuid.v4();
    final now = DateTime.now().toIso8601String();

    await db.insert('journal_entries', {
      'id': id,
      'user_id': userId,
      'title': title,
      'content': content,
      'mood_id': moodId,
      'tags': tags != null ? jsonEncode(tags) : null,
      'voice_recording_path': voiceRecordingPath,
      'ai_insights': aiInsights,
      'created_at': now,
      'updated_at': now,
      'sync_status': 'pending',
    });

    return id;
  }

  /// Get journal entry by ID
  Future<Map<String, dynamic>?> getJournalById(String id) async {
    final db = await _database.database;
    final results = await db.query(
      'journal_entries',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    return results.isNotEmpty ? _parseJournalEntry(results.first) : null;
  }

  /// Get journal entries for a user with pagination
  Future<List<Map<String, dynamic>>> getJournalEntries({
    required String userId,
    int limit = 20,
    int offset = 0,
  }) async {
    final db = await _database.database;
    final results = await db.query(
      'journal_entries',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'created_at DESC',
      limit: limit,
      offset: offset,
    );
    return results.map(_parseJournalEntry).toList();
  }

  /// Get journal entries for a date range
  Future<List<Map<String, dynamic>>> getJournalEntriesInRange({
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final db = await _database.database;
    final results = await db.query(
      'journal_entries',
      where: 'user_id = ? AND created_at >= ? AND created_at <= ?',
      whereArgs: [
        userId,
        startDate.toIso8601String(),
        endDate.toIso8601String(),
      ],
      orderBy: 'created_at DESC',
    );
    return results.map(_parseJournalEntry).toList();
  }

  /// Search journal entries
  Future<List<Map<String, dynamic>>> searchJournals({
    required String userId,
    required String query,
    int limit = 20,
  }) async {
    final db = await _database.database;
    final searchTerm = '%$query%';
    final results = await db.query(
      'journal_entries',
      where:
          'user_id = ? AND (title LIKE ? OR content LIKE ? OR tags LIKE ?)',
      whereArgs: [userId, searchTerm, searchTerm, searchTerm],
      orderBy: 'created_at DESC',
      limit: limit,
    );
    return results.map(_parseJournalEntry).toList();
  }

  /// Get journal entries by tag
  Future<List<Map<String, dynamic>>> getJournalsByTag({
    required String userId,
    required String tag,
  }) async {
    final db = await _database.database;
    final results = await db.query(
      'journal_entries',
      where: 'user_id = ? AND tags LIKE ?',
      whereArgs: [userId, '%"$tag"%'],
      orderBy: 'created_at DESC',
    );
    return results.map(_parseJournalEntry).toList();
  }

  /// Get journal count for user
  Future<int> getJournalCount(String userId) async {
    final db = await _database.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM journal_entries WHERE user_id = ?',
      [userId],
    );
    return (result.first['count'] as int?) ?? 0;
  }

  /// Get journals for a specific month (for calendar view)
  Future<Map<int, int>> getJournalCountsByDayInMonth({
    required String userId,
    required int year,
    required int month,
  }) async {
    final db = await _database.database;
    final startDate = DateTime(year, month, 1);
    final endDate = DateTime(year, month + 1, 0, 23, 59, 59);

    final results = await db.rawQuery('''
      SELECT 
        CAST(strftime('%d', created_at) AS INTEGER) as day,
        COUNT(*) as count
      FROM journal_entries
      WHERE user_id = ? AND created_at >= ? AND created_at <= ?
      GROUP BY day
    ''', [userId, startDate.toIso8601String(), endDate.toIso8601String()]);

    return {
      for (var row in results) row['day'] as int: row['count'] as int,
    };
  }

  /// Update journal entry
  Future<void> updateJournalEntry(String id, Map<String, dynamic> data) async {
    final db = await _database.database;
    if (data.containsKey('tags') && data['tags'] is List) {
      data['tags'] = jsonEncode(data['tags']);
    }
    data['updated_at'] = DateTime.now().toIso8601String();
    data['sync_status'] = 'pending';
    await db.update(
      'journal_entries',
      data,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Delete journal entry
  Future<void> deleteJournalEntry(String id) async {
    final db = await _database.database;
    await db.delete('journal_entries', where: 'id = ?', whereArgs: [id]);
  }

  /// Parse journal entry from database
  Map<String, dynamic> _parseJournalEntry(Map<String, dynamic> row) {
    final entry = Map<String, dynamic>.from(row);
    if (entry['tags'] != null && entry['tags'] is String) {
      entry['tags'] = jsonDecode(entry['tags'] as String);
    }
    return entry;
  }
}
