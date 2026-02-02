import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'database_providers.dart';
import 'auth_lifecycle_provider.dart';

/// In-memory storage for web platform (SQLite not supported)
final List<JournalEntry> _webJournalStorage = [];

/// Journal Entry State
class JournalEntry {
  final String id;
  final String? title;
  final String content;
  final String? moodId;
  final List<String> tags;
  final String? voiceRecordingPath;
  final String? aiInsights;
  final DateTime createdAt;
  final DateTime updatedAt;

  JournalEntry({
    required this.id,
    this.title,
    required this.content,
    this.moodId,
    required this.tags,
    this.voiceRecordingPath,
    this.aiInsights,
    required this.createdAt,
    required this.updatedAt,
  });

  factory JournalEntry.fromMap(Map<String, dynamic> map) {
    return JournalEntry(
      id: map['id'] as String,
      title: map['title'] as String?,
      content: map['content'] as String,
      moodId: map['mood_id'] as String?,
      tags: (map['tags'] as List<dynamic>?)?.cast<String>() ?? [],
      voiceRecordingPath: map['voice_recording_path'] as String?,
      aiInsights: map['ai_insights'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  String get preview {
    if (content.length <= 100) return content;
    return '${content.substring(0, 100)}...';
  }

  String get displayTitle {
    return title ?? 'Journal Entry';
  }
}

/// Journal state notifier
class JournalNotifier extends StateNotifier<AsyncValue<List<JournalEntry>>> {
  final Ref _ref;

  JournalNotifier(this._ref) : super(const AsyncValue.loading()) {
    loadJournalEntries();
  }

  Future<void> loadJournalEntries() async {
    try {
      state = const AsyncValue.loading();

      // Web platform: use in-memory storage
      if (kIsWeb) {
        state = AsyncValue.data(List.from(_webJournalStorage));
        return;
      }

      final userId = _ref.read(currentUserIdProvider);
      final journalDao = _ref.read(journalDaoProvider);
      final entries =
          await journalDao.getJournalEntries(userId: userId, limit: 50);
      state =
          AsyncValue.data(entries.map((e) => JournalEntry.fromMap(e)).toList());
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<JournalEntry?> getById(String id) async {
    // Web platform: find in memory
    if (kIsWeb) {
      try {
        return _webJournalStorage.firstWhere((e) => e.id == id);
      } catch (_) {
        return null;
      }
    }

    final journalDao = _ref.read(journalDaoProvider);
    final entry = await journalDao.getJournalById(id);
    return entry != null ? JournalEntry.fromMap(entry) : null;
  }

  Future<void> addEntry({
    String? title,
    required String content,
    String? moodId,
    List<String>? tags,
    String? voiceRecordingPath,
    String? aiInsights,
  }) async {
    final userId = _ref.read(currentUserIdProvider);
    final journalDao = _ref.read(journalDaoProvider);

    await journalDao.createJournalEntry(
      userId: userId,
      title: title,
      content: content,
      moodId: moodId,
      tags: tags,
      voiceRecordingPath: voiceRecordingPath,
      aiInsights: aiInsights,
    );

    await loadJournalEntries();
  }

  Future<void> updateEntry(
    String id, {
    String? title,
    String? content,
    List<String>? tags,
    String? aiInsights,
  }) async {
    final journalDao = _ref.read(journalDaoProvider);
    final data = <String, dynamic>{};
    if (title != null) data['title'] = title;
    if (content != null) data['content'] = content;
    if (tags != null) data['tags'] = tags;
    if (aiInsights != null) data['ai_insights'] = aiInsights;

    await journalDao.updateJournalEntry(id, data);
    await loadJournalEntries();
  }

  Future<void> deleteEntry(String id) async {
    final journalDao = _ref.read(journalDaoProvider);
    await journalDao.deleteJournalEntry(id);
    await loadJournalEntries();
  }

  Future<List<JournalEntry>> searchEntries(String query) async {
    final userId = _ref.read(currentUserIdProvider);
    final journalDao = _ref.read(journalDaoProvider);
    final entries =
        await journalDao.searchJournals(userId: userId, query: query);
    return entries.map((e) => JournalEntry.fromMap(e)).toList();
  }

  Future<Map<int, int>> getMonthCounts(int year, int month) async {
    final userId = _ref.read(currentUserIdProvider);
    final journalDao = _ref.read(journalDaoProvider);
    return await journalDao.getJournalCountsByDayInMonth(
      userId: userId,
      year: year,
      month: month,
    );
  }
}

/// Journal entries provider
final journalEntriesProvider =
    StateNotifierProvider<JournalNotifier, AsyncValue<List<JournalEntry>>>(
        (ref) {
  return JournalNotifier(ref);
});

/// Journal count provider
final journalCountProvider = FutureProvider<int>((ref) async {
  final userId = ref.watch(currentUserIdProvider);
  final journalDao = ref.watch(journalDaoProvider);
  return await journalDao.getJournalCount(userId);
});
