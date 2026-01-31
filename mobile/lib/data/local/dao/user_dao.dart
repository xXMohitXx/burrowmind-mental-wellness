import 'package:uuid/uuid.dart';
import '../database.dart';

/// Data Access Object for User operations
class UserDao {
  final AppDatabase _database;
  static const _uuid = Uuid();

  UserDao(this._database);

  /// Create a new user
  Future<String> createUser({
    required String email,
    String? displayName,
    String? avatarUrl,
    String? dateOfBirth,
    String? gender,
    String? bio,
  }) async {
    final db = await _database.database;
    final id = _uuid.v4();
    final now = DateTime.now().toIso8601String();

    await db.insert('users', {
      'id': id,
      'email': email,
      'display_name': displayName,
      'avatar_url': avatarUrl,
      'date_of_birth': dateOfBirth,
      'gender': gender,
      'bio': bio,
      'onboarding_complete': 0,
      'created_at': now,
      'updated_at': now,
      'sync_status': 'synced',
    });

    return id;
  }

  /// Get user by ID
  Future<Map<String, dynamic>?> getUserById(String id) async {
    final db = await _database.database;
    final results = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    return results.isNotEmpty ? results.first : null;
  }

  /// Get user by email
  Future<Map<String, dynamic>?> getUserByEmail(String email) async {
    final db = await _database.database;
    final results = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
      limit: 1,
    );
    return results.isNotEmpty ? results.first : null;
  }

  /// Update user profile
  Future<void> updateUser(String id, Map<String, dynamic> data) async {
    final db = await _database.database;
    data['updated_at'] = DateTime.now().toIso8601String();
    await db.update(
      'users',
      data,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Mark onboarding complete
  Future<void> completeOnboarding(String id) async {
    await updateUser(id, {'onboarding_complete': 1});
  }

  /// Delete user
  Future<void> deleteUser(String id) async {
    final db = await _database.database;
    await db.delete('users', where: 'id = ?', whereArgs: [id]);
  }

  /// Check if user exists
  Future<bool> userExists(String id) async {
    final user = await getUserById(id);
    return user != null;
  }
}
