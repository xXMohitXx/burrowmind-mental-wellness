import 'package:uuid/uuid.dart';
import '../database.dart';

/// Data Access Object for Mental Health Score operations
class ScoreDao {
  final AppDatabase _database;
  static const _uuid = Uuid();

  ScoreDao(this._database);

  /// Create or update daily score
  Future<String> upsertDailyScore({
    required String userId,
    required int score,
    int? moodComponent,
    int? sleepComponent,
    int? stressComponent,
    int? activityComponent,
    required DateTime date,
  }) async {
    final db = await _database.database;
    final dateStr = DateTime(date.year, date.month, date.day)
        .toIso8601String()
        .split('T')[0];

    // Check if score exists for this date
    final existing = await db.query(
      'mental_health_scores',
      where: 'user_id = ? AND date = ?',
      whereArgs: [userId, dateStr],
      limit: 1,
    );

    final now = DateTime.now().toIso8601String();

    if (existing.isNotEmpty) {
      // Update existing
      await db.update(
        'mental_health_scores',
        {
          'score': score,
          'mood_component': moodComponent,
          'sleep_component': sleepComponent,
          'stress_component': stressComponent,
          'activity_component': activityComponent,
        },
        where: 'id = ?',
        whereArgs: [existing.first['id']],
      );
      return existing.first['id'] as String;
    } else {
      // Create new
      final id = _uuid.v4();
      await db.insert('mental_health_scores', {
        'id': id,
        'user_id': userId,
        'score': score,
        'mood_component': moodComponent,
        'sleep_component': sleepComponent,
        'stress_component': stressComponent,
        'activity_component': activityComponent,
        'date': dateStr,
        'created_at': now,
      });
      return id;
    }
  }

  /// Get today's score
  Future<Map<String, dynamic>?> getTodaysScore(String userId) async {
    final db = await _database.database;
    final today = DateTime.now();
    final dateStr = DateTime(today.year, today.month, today.day)
        .toIso8601String()
        .split('T')[0];

    final results = await db.query(
      'mental_health_scores',
      where: 'user_id = ? AND date = ?',
      whereArgs: [userId, dateStr],
      limit: 1,
    );

    return results.isNotEmpty ? results.first : null;
  }

  /// Get score history
  Future<List<Map<String, dynamic>>> getScoreHistory({
    required String userId,
    int limit = 30,
  }) async {
    final db = await _database.database;
    return await db.query(
      'mental_health_scores',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'date DESC',
      limit: limit,
    );
  }

  /// Get scores for date range
  Future<List<Map<String, dynamic>>> getScoresInRange({
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final db = await _database.database;
    final startStr = DateTime(startDate.year, startDate.month, startDate.day)
        .toIso8601String()
        .split('T')[0];
    final endStr = DateTime(endDate.year, endDate.month, endDate.day)
        .toIso8601String()
        .split('T')[0];

    return await db.query(
      'mental_health_scores',
      where: 'user_id = ? AND date >= ? AND date <= ?',
      whereArgs: [userId, startStr, endStr],
      orderBy: 'date ASC',
    );
  }

  /// Get average score for date range
  Future<double?> getAverageScore({
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final db = await _database.database;
    final startStr = DateTime(startDate.year, startDate.month, startDate.day)
        .toIso8601String()
        .split('T')[0];
    final endStr = DateTime(endDate.year, endDate.month, endDate.day)
        .toIso8601String()
        .split('T')[0];

    final result = await db.rawQuery('''
      SELECT AVG(score) as average
      FROM mental_health_scores
      WHERE user_id = ? AND date >= ? AND date <= ?
    ''', [userId, startStr, endStr]);

    if (result.isNotEmpty && result.first['average'] != null) {
      return (result.first['average'] as num).toDouble();
    }
    return null;
  }
}
