import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'database_providers.dart';
import 'auth_lifecycle_provider.dart';

/// In-memory storage for web platform (SQLite not supported)
final List<SleepEntry> _webSleepStorage = [];

/// Sleep Entry State
class SleepEntry {
  final String id;
  final int qualityScore;
  final DateTime? sleepStart;
  final DateTime? sleepEnd;
  final int? durationMinutes;
  final String? notes;
  final DateTime createdAt;

  SleepEntry({
    required this.id,
    required this.qualityScore,
    this.sleepStart,
    this.sleepEnd,
    this.durationMinutes,
    this.notes,
    required this.createdAt,
  });

  factory SleepEntry.fromMap(Map<String, dynamic> map) {
    return SleepEntry(
      id: map['id'] as String,
      qualityScore: map['quality_score'] as int,
      sleepStart: map['sleep_start'] != null
          ? DateTime.parse(map['sleep_start'] as String)
          : null,
      sleepEnd: map['sleep_end'] != null
          ? DateTime.parse(map['sleep_end'] as String)
          : null,
      durationMinutes: map['duration_minutes'] as int?,
      notes: map['notes'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  String get qualityLabel {
    switch (qualityScore) {
      case 5:
        return 'Excellent';
      case 4:
        return 'Good';
      case 3:
        return 'Fair';
      case 2:
        return 'Poor';
      case 1:
        return 'Very Poor';
      default:
        return 'Unknown';
    }
  }

  String get durationFormatted {
    if (durationMinutes == null) return '--';
    final hours = durationMinutes! ~/ 60;
    final mins = durationMinutes! % 60;
    return '${hours}h ${mins}m';
  }
}

/// Sleep state notifier
class SleepNotifier extends StateNotifier<AsyncValue<List<SleepEntry>>> {
  final Ref _ref;

  SleepNotifier(this._ref) : super(const AsyncValue.loading()) {
    loadSleepEntries();
  }

  Future<void> loadSleepEntries() async {
    try {
      state = const AsyncValue.loading();

      // Web platform: use in-memory storage
      if (kIsWeb) {
        state = AsyncValue.data(List.from(_webSleepStorage));
        return;
      }

      final userId = _ref.read(currentUserIdProvider);
      final sleepDao = _ref.read(sleepDaoProvider);
      final entries = await sleepDao.getSleepEntries(userId: userId, limit: 30);
      state =
          AsyncValue.data(entries.map((e) => SleepEntry.fromMap(e)).toList());
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<SleepEntry?> getLastNightSleep() async {
    final userId = _ref.read(currentUserIdProvider);
    final sleepDao = _ref.read(sleepDaoProvider);
    final sleep = await sleepDao.getLastNightSleep(userId);
    return sleep != null ? SleepEntry.fromMap(sleep) : null;
  }

  Future<void> addSleepEntry({
    required int qualityScore,
    DateTime? sleepStart,
    DateTime? sleepEnd,
    int? durationMinutes,
    String? notes,
  }) async {
    final userId = _ref.read(currentUserIdProvider);
    final sleepDao = _ref.read(sleepDaoProvider);

    await sleepDao.createSleepEntry(
      userId: userId,
      qualityScore: qualityScore,
      sleepStart: sleepStart,
      sleepEnd: sleepEnd,
      durationMinutes: durationMinutes,
      notes: notes,
    );

    await loadSleepEntries();
  }

  Future<double?> getWeeklyAverage() async {
    final userId = _ref.read(currentUserIdProvider);
    final sleepDao = _ref.read(sleepDaoProvider);
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));
    return await sleepDao.getAverageSleepQuality(
      userId: userId,
      startDate: weekAgo,
      endDate: now,
    );
  }

  Future<double?> getAverageDuration() async {
    final userId = _ref.read(currentUserIdProvider);
    final sleepDao = _ref.read(sleepDaoProvider);
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));
    return await sleepDao.getAverageSleepDuration(
      userId: userId,
      startDate: weekAgo,
      endDate: now,
    );
  }
}

/// Sleep entries provider
final sleepEntriesProvider =
    StateNotifierProvider<SleepNotifier, AsyncValue<List<SleepEntry>>>((ref) {
  return SleepNotifier(ref);
});

/// Last night's sleep
final lastNightSleepProvider = FutureProvider<SleepEntry?>((ref) async {
  final notifier = ref.watch(sleepEntriesProvider.notifier);
  return await notifier.getLastNightSleep();
});

/// Weekly sleep average
final weeklySleepAverageProvider = FutureProvider<double?>((ref) async {
  final notifier = ref.watch(sleepEntriesProvider.notifier);
  return await notifier.getWeeklyAverage();
});
