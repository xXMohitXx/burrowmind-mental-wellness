import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'database_providers.dart';

/// Current user ID provider (simulated - would come from auth)
final currentUserIdProvider = StateProvider<String>((ref) {
  return 'user-001'; // Placeholder - replace with actual auth
});

/// Mood Entry State
class MoodEntry {
  final String id;
  final int moodLevel;
  final String? moodEmoji;
  final List<String> factors;
  final String? notes;
  final DateTime createdAt;

  MoodEntry({
    required this.id,
    required this.moodLevel,
    this.moodEmoji,
    required this.factors,
    this.notes,
    required this.createdAt,
  });

  factory MoodEntry.fromMap(Map<String, dynamic> map) {
    return MoodEntry(
      id: map['id'] as String,
      moodLevel: map['mood_level'] as int,
      moodEmoji: map['mood_emoji'] as String?,
      factors: (map['factors'] as List<dynamic>?)?.cast<String>() ?? [],
      notes: map['notes'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  String get moodLabel {
    switch (moodLevel) {
      case 5:
        return 'Excellent';
      case 4:
        return 'Good';
      case 3:
        return 'Okay';
      case 2:
        return 'Low';
      case 1:
        return 'Bad';
      default:
        return 'Unknown';
    }
  }

  String get emoji {
    return moodEmoji ?? _defaultEmoji;
  }

  String get _defaultEmoji {
    switch (moodLevel) {
      case 5:
        return '😊';
      case 4:
        return '🙂';
      case 3:
        return '😐';
      case 2:
        return '😔';
      case 1:
        return '😢';
      default:
        return '😐';
    }
  }
}

/// Mood state notifier
class MoodNotifier extends StateNotifier<AsyncValue<List<MoodEntry>>> {
  final Ref _ref;

  MoodNotifier(this._ref) : super(const AsyncValue.loading()) {
    loadMoods();
  }

  Future<void> loadMoods() async {
    try {
      state = const AsyncValue.loading();
      final userId = _ref.read(currentUserIdProvider);
      final moodDao = _ref.read(moodDaoProvider);
      final entries = await moodDao.getMoodEntries(userId: userId, limit: 50);
      state =
          AsyncValue.data(entries.map((e) => MoodEntry.fromMap(e)).toList());
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<MoodEntry?> getTodaysMood() async {
    final userId = _ref.read(currentUserIdProvider);
    final moodDao = _ref.read(moodDaoProvider);
    final mood = await moodDao.getTodaysMood(userId);
    return mood != null ? MoodEntry.fromMap(mood) : null;
  }

  Future<void> addMood({
    required int moodLevel,
    String? moodEmoji,
    List<String>? factors,
    String? notes,
  }) async {
    final userId = _ref.read(currentUserIdProvider);
    final moodDao = _ref.read(moodDaoProvider);

    await moodDao.createMoodEntry(
      userId: userId,
      moodLevel: moodLevel,
      moodEmoji: moodEmoji,
      factors: factors,
      notes: notes,
    );

    await loadMoods();
  }

  Future<double?> getWeeklyAverage() async {
    final userId = _ref.read(currentUserIdProvider);
    final moodDao = _ref.read(moodDaoProvider);
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));
    return await moodDao.getAverageMood(
      userId: userId,
      startDate: weekAgo,
      endDate: now,
    );
  }

  Future<List<MoodEntry>> getWeeklyMoods() async {
    final userId = _ref.read(currentUserIdProvider);
    final moodDao = _ref.read(moodDaoProvider);
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));
    final entries = await moodDao.getMoodEntriesInRange(
      userId: userId,
      startDate: weekAgo,
      endDate: now,
    );
    return entries.map((e) => MoodEntry.fromMap(e)).toList();
  }
}

/// Mood entries provider
final moodEntriesProvider =
    StateNotifierProvider<MoodNotifier, AsyncValue<List<MoodEntry>>>((ref) {
  return MoodNotifier(ref);
});

/// Today's mood provider
final todaysMoodProvider = FutureProvider<MoodEntry?>((ref) async {
  final notifier = ref.watch(moodEntriesProvider.notifier);
  return await notifier.getTodaysMood();
});

/// Weekly average mood
final weeklyMoodAverageProvider = FutureProvider<double?>((ref) async {
  final notifier = ref.watch(moodEntriesProvider.notifier);
  return await notifier.getWeeklyAverage();
});
