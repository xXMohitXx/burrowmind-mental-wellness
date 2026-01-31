import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../../core/constants/app_constants.dart';

/// SQLite Database Manager for BurrowMind
/// Handles all local data persistence
class AppDatabase {
  static Database? _database;
  static final AppDatabase instance = AppDatabase._internal();

  AppDatabase._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, AppConstants.databaseName);

    return await openDatabase(
      path,
      version: AppConstants.databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Users table
    await db.execute('''
      CREATE TABLE users (
        id TEXT PRIMARY KEY,
        email TEXT NOT NULL UNIQUE,
        display_name TEXT,
        avatar_url TEXT,
        date_of_birth TEXT,
        gender TEXT,
        bio TEXT,
        onboarding_complete INTEGER DEFAULT 0,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        sync_status TEXT DEFAULT 'synced'
      )
    ''');

    // App Settings table
    await db.execute('''
      CREATE TABLE app_settings (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // Mood Entries table
    await db.execute('''
      CREATE TABLE mood_entries (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        mood_level INTEGER NOT NULL,
        mood_emoji TEXT,
        factors TEXT,
        notes TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        sync_status TEXT DEFAULT 'pending',
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
      )
    ''');

    // Create index for mood entries
    await db.execute('''
      CREATE INDEX idx_mood_entries_user_date 
      ON mood_entries(user_id, created_at DESC)
    ''');

    // Stress Entries table
    await db.execute('''
      CREATE TABLE stress_entries (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        stress_level INTEGER NOT NULL,
        stressors TEXT,
        notes TEXT,
        face_analysis_data TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        sync_status TEXT DEFAULT 'pending',
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
      )
    ''');

    // Create index for stress entries
    await db.execute('''
      CREATE INDEX idx_stress_entries_user_date 
      ON stress_entries(user_id, created_at DESC)
    ''');

    // Sleep Entries table
    await db.execute('''
      CREATE TABLE sleep_entries (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        quality_score INTEGER NOT NULL,
        sleep_start TEXT,
        sleep_end TEXT,
        duration_minutes INTEGER,
        notes TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        sync_status TEXT DEFAULT 'pending',
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
      )
    ''');

    // Create index for sleep entries
    await db.execute('''
      CREATE INDEX idx_sleep_entries_user_date 
      ON sleep_entries(user_id, created_at DESC)
    ''');

    // Mindful Sessions table
    await db.execute('''
      CREATE TABLE mindful_sessions (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        session_type TEXT NOT NULL,
        duration_minutes INTEGER NOT NULL,
        soundscape TEXT,
        completed INTEGER DEFAULT 0,
        notes TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        sync_status TEXT DEFAULT 'pending',
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
      )
    ''');

    // Create index for mindful sessions
    await db.execute('''
      CREATE INDEX idx_mindful_sessions_user_date 
      ON mindful_sessions(user_id, created_at DESC)
    ''');

    // Assessment Results table
    await db.execute('''
      CREATE TABLE assessment_results (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        assessment_type TEXT NOT NULL,
        responses TEXT NOT NULL,
        score INTEGER,
        ai_analysis TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        sync_status TEXT DEFAULT 'pending',
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
      )
    ''');

    // Create index for assessment results
    await db.execute('''
      CREATE INDEX idx_assessment_results_user_date 
      ON assessment_results(user_id, created_at DESC)
    ''');

    // Journal Entries table
    await db.execute('''
      CREATE TABLE journal_entries (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        title TEXT,
        content TEXT NOT NULL,
        mood_id TEXT,
        tags TEXT,
        voice_recording_path TEXT,
        ai_insights TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        sync_status TEXT DEFAULT 'pending',
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
        FOREIGN KEY (mood_id) REFERENCES mood_entries(id) ON DELETE SET NULL
      )
    ''');

    // Create index for journal entries
    await db.execute('''
      CREATE INDEX idx_journal_entries_user_date 
      ON journal_entries(user_id, created_at DESC)
    ''');

    // Create full-text search for journal
    await db.execute('''
      CREATE VIRTUAL TABLE journal_fts USING fts5(
        title,
        content,
        content=journal_entries,
        content_rowid=rowid
      )
    ''');

    // AI Conversations table
    await db.execute('''
      CREATE TABLE ai_conversations (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        session_id TEXT NOT NULL,
        role TEXT NOT NULL,
        content TEXT NOT NULL,
        created_at TEXT NOT NULL,
        sync_status TEXT DEFAULT 'pending',
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
      )
    ''');

    // Create index for ai conversations
    await db.execute('''
      CREATE INDEX idx_ai_conversations_session 
      ON ai_conversations(session_id, created_at ASC)
    ''');

    // Mental Health Scores table (computed daily)
    await db.execute('''
      CREATE TABLE mental_health_scores (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        score INTEGER NOT NULL,
        mood_component INTEGER,
        sleep_component INTEGER,
        stress_component INTEGER,
        activity_component INTEGER,
        date TEXT NOT NULL,
        created_at TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
      )
    ''');

    // Create index for mental health scores
    await db.execute('''
      CREATE INDEX idx_mental_health_scores_user_date 
      ON mental_health_scores(user_id, date DESC)
    ''');

    // Notification Logs table
    await db.execute('''
      CREATE TABLE notification_logs (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        notification_type TEXT NOT NULL,
        title TEXT NOT NULL,
        body TEXT,
        data TEXT,
        read INTEGER DEFAULT 0,
        created_at TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
      )
    ''');

    // Create index for notification logs
    await db.execute('''
      CREATE INDEX idx_notification_logs_user_date 
      ON notification_logs(user_id, created_at DESC)
    ''');

    // Resources Cache table
    await db.execute('''
      CREATE TABLE resources_cache (
        id TEXT PRIMARY KEY,
        type TEXT NOT NULL,
        title TEXT NOT NULL,
        description TEXT,
        content TEXT,
        thumbnail_url TEXT,
        category TEXT,
        author TEXT,
        duration_minutes INTEGER,
        cached_at TEXT NOT NULL
      )
    ''');

    // Community Posts Cache table
    await db.execute('''
      CREATE TABLE community_posts_cache (
        id TEXT PRIMARY KEY,
        author_id TEXT,
        author_name TEXT,
        author_avatar TEXT,
        content TEXT NOT NULL,
        image_url TEXT,
        likes_count INTEGER DEFAULT 0,
        comments_count INTEGER DEFAULT 0,
        cached_at TEXT NOT NULL
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Handle future database migrations here
    // Example:
    // if (oldVersion < 2) {
    //   await db.execute('ALTER TABLE users ADD COLUMN new_field TEXT');
    // }
  }

  /// Close the database
  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }

  /// Delete all data (for development/testing)
  Future<void> deleteAllData() async {
    final db = await database;
    await db.delete('ai_conversations');
    await db.delete('notification_logs');
    await db.delete('mental_health_scores');
    await db.delete('journal_entries');
    await db.delete('assessment_results');
    await db.delete('mindful_sessions');
    await db.delete('sleep_entries');
    await db.delete('stress_entries');
    await db.delete('mood_entries');
    await db.delete('app_settings');
    await db.delete('resources_cache');
    await db.delete('community_posts_cache');
  }

  /// Delete user and all related data
  Future<void> deleteUser(String userId) async {
    final db = await database;
    await db.delete('users', where: 'id = ?', whereArgs: [userId]);
  }
}
