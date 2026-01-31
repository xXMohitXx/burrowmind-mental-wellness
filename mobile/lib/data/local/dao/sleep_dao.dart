import 'package:uuid/uuid.dart';
import '../database.dart';

/// Data Access Object for Sleep Entry operations
class SleepDao {
  final AppDatabase _database;
  static const _uuid = Uuid();

  SleepDao(this._database);

  /// Create a new sleep entry
  Future<String> createSleepEntry({
    required String userId,
    required int qualityScore,
    DateTime? sleepStart,
    DateTime? sleepEnd,
    int? durationMinutes,
    String? notes,
  }) async {
    final db = await _database.database;
    final id = _uuid.v4();
    final now = DateTime.now().toIso8601String();

    await db.insert('sleep_entries', {
      'id': id,
      'user_id': userId,
      'quality_score': qualityScore,
      'sleep_start': sleepStart?.toIso8601String(),
      'sleep_end': sleepEnd?.toIso8601String(),
      'duration_minutes': durationMinutes,
      'notes': notes,
      'created_at': now,
      'updated_at': now,
      'sync_status': 'pending',
    });

    return id;
  }

  /// Get sleep entries for a user
  Future<List<Map<String, dynamic>>> getSleepEntries({
    required String userId,
    int limit = 20,
    int offset = 0,
  }) async {
    final db = await _database.database;
    final results = await db.query(
      'sleep_entries',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'created_at DESC',
      limit: limit,
      offset: offset,
    );
    return results;
  }

  /// Get sleep entries for a date range
  Future<List<Map<String, dynamic>>> getSleepEntriesInRange({
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final db = await _database.database;
    final results = await db.query(
      'sleep_entries',
      where: 'user_id = ? AND created_at >= ? AND created_at <= ?',
      whereArgs: [
        userId,
        startDate.toIso8601String(),
        endDate.toIso8601String(),
      ],
      orderBy: 'created_at DESC',
    );
    return results;
  }

  /// Get average sleep quality for a date range
  Future<double?> getAverageSleepQuality({
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final db = await _database.database;
    final result = await db.rawQuery('''
      SELECT AVG(quality_score) as average
      FROM sleep_entries
      WHERE user_id = ? AND created_at >= ? AND created_at <= ?
    ''', [userId, startDate.toIso8601String(), endDate.toIso8601String()]);

    if (result.isNotEmpty && result.first['average'] != null) {
      return (result.first['average'] as num).toDouble();
    }
    return null;
  }

  /// Get average sleep duration for a date range
  Future<double?> getAverageSleepDuration({
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final db = await _database.database;
    final result = await db.rawQuery('''
      SELECT AVG(duration_minutes) as average
      FROM sleep_entries
      WHERE user_id = ? AND created_at >= ? AND created_at <= ?
        AND duration_minutes IS NOT NULL
    ''', [userId, startDate.toIso8601String(), endDate.toIso8601String()]);

    if (result.isNotEmpty && result.first['average'] != null) {
      return (result.first['average'] as num).toDouble();
    }
    return null;
  }

  /// Update sleep entry
  Future<void> updateSleepEntry(String id, Map<String, dynamic> data) async {
    final db = await _database.database;
    if (data.containsKey('sleep_start') && data['sleep_start'] is DateTime) {
      data['sleep_start'] = (data['sleep_start'] as DateTime).toIso8601String();
    }
    if (data.containsKey('sleep_end') && data['sleep_end'] is DateTime) {
      data['sleep_end'] = (data['sleep_end'] as DateTime).toIso8601String();
    }
    data['updated_at'] = DateTime.now().toIso8601String();
    data['sync_status'] = 'pending';
    await db.update(
      'sleep_entries',
      data,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Delete sleep entry
  Future<void> deleteSleepEntry(String id) async {
    final db = await _database.database;
    await db.delete('sleep_entries', where: 'id = ?', whereArgs: [id]);
  }
}
