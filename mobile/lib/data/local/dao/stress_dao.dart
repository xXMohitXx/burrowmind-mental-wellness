import 'dart:convert';
import 'package:uuid/uuid.dart';
import '../database.dart';

/// Data Access Object for Stress Entry operations
class StressDao {
  final AppDatabase _database;
  static const _uuid = Uuid();

  StressDao(this._database);

  /// Create a new stress entry
  Future<String> createStressEntry({
    required String userId,
    required int stressLevel,
    List<String>? stressors,
    String? notes,
    Map<String, dynamic>? faceAnalysisData,
  }) async {
    final db = await _database.database;
    final id = _uuid.v4();
    final now = DateTime.now().toIso8601String();

    await db.insert('stress_entries', {
      'id': id,
      'user_id': userId,
      'stress_level': stressLevel,
      'stressors': stressors != null ? jsonEncode(stressors) : null,
      'notes': notes,
      'face_analysis_data':
          faceAnalysisData != null ? jsonEncode(faceAnalysisData) : null,
      'created_at': now,
      'updated_at': now,
      'sync_status': 'pending',
    });

    return id;
  }

  /// Get stress entries for a user
  Future<List<Map<String, dynamic>>> getStressEntries({
    required String userId,
    int limit = 20,
    int offset = 0,
  }) async {
    final db = await _database.database;
    final results = await db.query(
      'stress_entries',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'created_at DESC',
      limit: limit,
      offset: offset,
    );
    return results.map(_parseStressEntry).toList();
  }

  /// Get stress entries for a date range
  Future<List<Map<String, dynamic>>> getStressEntriesInRange({
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final db = await _database.database;
    final results = await db.query(
      'stress_entries',
      where: 'user_id = ? AND created_at >= ? AND created_at <= ?',
      whereArgs: [
        userId,
        startDate.toIso8601String(),
        endDate.toIso8601String(),
      ],
      orderBy: 'created_at DESC',
    );
    return results.map(_parseStressEntry).toList();
  }

  /// Get average stress for a date range
  Future<double?> getAverageStress({
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final db = await _database.database;
    final result = await db.rawQuery('''
      SELECT AVG(stress_level) as average
      FROM stress_entries
      WHERE user_id = ? AND created_at >= ? AND created_at <= ?
    ''', [userId, startDate.toIso8601String(), endDate.toIso8601String()]);

    if (result.isNotEmpty && result.first['average'] != null) {
      return (result.first['average'] as num).toDouble();
    }
    return null;
  }

  /// Update stress entry
  Future<void> updateStressEntry(String id, Map<String, dynamic> data) async {
    final db = await _database.database;
    if (data.containsKey('stressors') && data['stressors'] is List) {
      data['stressors'] = jsonEncode(data['stressors']);
    }
    if (data.containsKey('face_analysis_data') &&
        data['face_analysis_data'] is Map) {
      data['face_analysis_data'] = jsonEncode(data['face_analysis_data']);
    }
    data['updated_at'] = DateTime.now().toIso8601String();
    data['sync_status'] = 'pending';
    await db.update(
      'stress_entries',
      data,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Delete stress entry
  Future<void> deleteStressEntry(String id) async {
    final db = await _database.database;
    await db.delete('stress_entries', where: 'id = ?', whereArgs: [id]);
  }

  /// Parse stress entry from database
  Map<String, dynamic> _parseStressEntry(Map<String, dynamic> row) {
    final entry = Map<String, dynamic>.from(row);
    if (entry['stressors'] != null && entry['stressors'] is String) {
      entry['stressors'] = jsonDecode(entry['stressors'] as String);
    }
    if (entry['face_analysis_data'] != null &&
        entry['face_analysis_data'] is String) {
      entry['face_analysis_data'] =
          jsonDecode(entry['face_analysis_data'] as String);
    }
    return entry;
  }
}
