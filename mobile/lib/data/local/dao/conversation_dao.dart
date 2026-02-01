import 'package:uuid/uuid.dart';
import '../database.dart';

/// Data Access Object for AI Conversation operations
class ConversationDao {
  final AppDatabase _database;
  static const _uuid = Uuid();

  ConversationDao(this._database);

  /// Create a new conversation message
  Future<String> createMessage({
    required String userId,
    required String sessionId,
    required String role,
    required String content,
  }) async {
    final db = await _database.database;
    final id = _uuid.v4();
    final now = DateTime.now().toIso8601String();

    await db.insert('ai_conversations', {
      'id': id,
      'user_id': userId,
      'session_id': sessionId,
      'role': role,
      'content': content,
      'created_at': now,
      'sync_status': 'pending',
    });

    return id;
  }

  /// Get messages for a session
  Future<List<Map<String, dynamic>>> getSessionMessages({
    required String sessionId,
    int? limit,
  }) async {
    final db = await _database.database;
    return await db.query(
      'ai_conversations',
      where: 'session_id = ?',
      whereArgs: [sessionId],
      orderBy: 'created_at ASC',
      limit: limit,
    );
  }

  /// Get recent sessions for a user
  Future<List<String>> getRecentSessions({
    required String userId,
    int limit = 10,
  }) async {
    final db = await _database.database;
    final results = await db.rawQuery('''
      SELECT DISTINCT session_id, MAX(created_at) as last_message
      FROM ai_conversations
      WHERE user_id = ?
      GROUP BY session_id
      ORDER BY last_message DESC
      LIMIT ?
    ''', [userId, limit]);

    return results.map((r) => r['session_id'] as String).toList();
  }

  /// Get context window (last N messages for a session)
  Future<List<Map<String, dynamic>>> getContextWindow({
    required String sessionId,
    int windowSize = 10,
  }) async {
    final db = await _database.database;
    return await db.rawQuery('''
      SELECT * FROM (
        SELECT * FROM ai_conversations
        WHERE session_id = ?
        ORDER BY created_at DESC
        LIMIT ?
      ) ORDER BY created_at ASC
    ''', [sessionId, windowSize]);
  }

  /// Delete a session
  Future<void> deleteSession(String sessionId) async {
    final db = await _database.database;
    await db.delete(
      'ai_conversations',
      where: 'session_id = ?',
      whereArgs: [sessionId],
    );
  }

  /// Delete all sessions for a user
  Future<void> deleteUserConversations(String userId) async {
    final db = await _database.database;
    await db.delete(
      'ai_conversations',
      where: 'user_id = ?',
      whereArgs: [userId],
    );
  }

  /// Get message count for user
  Future<int> getMessageCount(String userId) async {
    final db = await _database.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM ai_conversations WHERE user_id = ?',
      [userId],
    );
    return (result.first['count'] as int?) ?? 0;
  }

  /// Alias for getSessionMessages - for compatibility
  Future<List<Map<String, dynamic>>> getConversation({
    required String sessionId,
  }) async {
    return getSessionMessages(sessionId: sessionId);
  }

  /// Alias for createMessage - for compatibility
  Future<String> addMessage({
    required String userId,
    required String sessionId,
    required String role,
    required String content,
  }) async {
    return createMessage(
      userId: userId,
      sessionId: sessionId,
      role: role,
      content: content,
    );
  }
}
