import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'mood_provider.dart';
import 'sleep_provider.dart';
import 'journal_provider.dart';

/// User Context Provider - Summarizes recent user data for AI context injection
///
/// Generates a concise summary of the user's last 7-14 days of:
/// - Mood patterns and trends
/// - Sleep quality and duration
/// - Journal themes and concerns

class UserContext {
  final String summary;
  final Map<String, dynamic> rawData;
  final DateTime generatedAt;

  UserContext({
    required this.summary,
    required this.rawData,
    required this.generatedAt,
  });

  factory UserContext.empty() => UserContext(
        summary: '',
        rawData: {},
        generatedAt: DateTime.now(),
      );

  bool get isEmpty => summary.isEmpty;
  bool get isNotEmpty => summary.isNotEmpty;
}

class UserContextNotifier extends StateNotifier<AsyncValue<UserContext>> {
  final Ref _ref;
  static const int contextDays = 7; // Look back 7 days

  UserContextNotifier(this._ref) : super(const AsyncValue.loading()) {
    generateContext();
    // Regenerate when underlying data changes
    _ref.listen(moodEntriesProvider, (_, __) => generateContext());
    _ref.listen(sleepEntriesProvider, (_, __) => generateContext());
  }

  Future<void> generateContext() async {
    try {
      state = const AsyncValue.loading();

      final now = DateTime.now();
      final cutoff = now.subtract(const Duration(days: contextDays));

      // Gather mood data
      final moodAsync = _ref.read(moodEntriesProvider);
      final moodEntries = moodAsync.valueOrNull ?? [];
      final recentMoods =
          moodEntries.where((e) => e.createdAt.isAfter(cutoff)).toList();

      // Gather sleep data
      final sleepAsync = _ref.read(sleepEntriesProvider);
      final sleepEntries = sleepAsync.valueOrNull ?? [];
      final recentSleep =
          sleepEntries.where((e) => e.createdAt.isAfter(cutoff)).toList();

      // Gather journal data
      final journalAsync = _ref.read(journalEntriesProvider);
      final journalEntries = journalAsync.valueOrNull ?? [];
      final recentJournals =
          journalEntries.where((e) => e.createdAt.isAfter(cutoff)).toList();

      // Build summary
      final summary = _buildSummary(recentMoods, recentSleep, recentJournals);

      // Store raw data for potential API use
      final rawData = {
        'mood_count': recentMoods.length,
        'mood_avg': recentMoods.isEmpty
            ? null
            : recentMoods.map((e) => e.moodLevel).reduce((a, b) => a + b) /
                recentMoods.length,
        'mood_trend': _calculateMoodTrend(recentMoods),
        'sleep_count': recentSleep.length,
        'sleep_avg_quality': recentSleep.isEmpty
            ? null
            : recentSleep.map((e) => e.qualityScore).reduce((a, b) => a + b) /
                recentSleep.length,
        'sleep_avg_duration': _calculateAvgSleepDuration(recentSleep),
        'journal_count': recentJournals.length,
        'journal_themes': _extractJournalThemes(recentJournals),
        'context_days': contextDays,
      };

      state = AsyncValue.data(UserContext(
        summary: summary,
        rawData: rawData,
        generatedAt: DateTime.now(),
      ));
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  String _buildSummary(
    List<MoodEntry> moods,
    List<SleepEntry> sleeps,
    List<JournalEntry> journals,
  ) {
    final parts = <String>[];

    // Mood summary
    if (moods.isNotEmpty) {
      final avgMood =
          moods.map((e) => e.moodLevel).reduce((a, b) => a + b) / moods.length;
      final moodLabel = _getMoodLabel(avgMood);
      final trend = _calculateMoodTrend(moods);

      parts.add(
          'Over the past $contextDays days, the user has logged ${moods.length} mood entries. '
          'Their average mood is $moodLabel ($avgMood out of 5). '
          '${trend.isNotEmpty ? 'Mood trend: $trend.' : ''}');

      // Add factors if present
      final allFactors = moods.expand((m) => m.factors).toList();
      if (allFactors.isNotEmpty) {
        final factorCounts = <String, int>{};
        for (final factor in allFactors) {
          factorCounts[factor] = (factorCounts[factor] ?? 0) + 1;
        }
        final topFactors = (factorCounts.entries.toList()
              ..sort((a, b) => b.value.compareTo(a.value)))
            .take(3)
            .map((e) => e.key)
            .toList();
        if (topFactors.isNotEmpty) {
          parts.add('Common mood factors: ${topFactors.join(', ')}.');
        }
      }
    }

    // Sleep summary
    if (sleeps.isNotEmpty) {
      final avgQuality =
          sleeps.map((e) => e.qualityScore).reduce((a, b) => a + b) /
              sleeps.length;
      final qualityLabel = _getSleepQualityLabel(avgQuality);
      final avgDuration = _calculateAvgSleepDuration(sleeps);

      parts.add('Sleep: ${sleeps.length} entries logged. '
          'Average quality is $qualityLabel. '
          '${avgDuration != null ? 'Average duration: ${avgDuration.toStringAsFixed(1)} hours.' : ''}');
    }

    // Journal summary
    if (journals.isNotEmpty) {
      parts
          .add('Journal: ${journals.length} entries written in the past week.');

      // Extract keywords from content
      final themes = _extractJournalThemes(journals);
      if (themes.isNotEmpty) {
        parts.add('Recurring themes: ${themes.join(', ')}.');
      }
    }

    if (parts.isEmpty) {
      return 'The user has not logged any mood, sleep, or journal entries in the past $contextDays days.';
    }

    return parts.join(' ');
  }

  String _calculateMoodTrend(List<MoodEntry> moods) {
    if (moods.length < 2) return '';

    // Sort by date
    final sorted = moods.toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));

    // Compare first half vs second half
    final midpoint = sorted.length ~/ 2;
    final firstHalf = sorted.sublist(0, midpoint);
    final secondHalf = sorted.sublist(midpoint);

    final firstAvg = firstHalf.map((e) => e.moodLevel).reduce((a, b) => a + b) /
        firstHalf.length;
    final secondAvg =
        secondHalf.map((e) => e.moodLevel).reduce((a, b) => a + b) /
            secondHalf.length;

    final diff = secondAvg - firstAvg;
    if (diff > 0.5) return 'improving';
    if (diff < -0.5) return 'declining';
    return 'stable';
  }

  String _getMoodLabel(double avg) {
    if (avg >= 4.5) return 'excellent';
    if (avg >= 3.5) return 'good';
    if (avg >= 2.5) return 'moderate';
    if (avg >= 1.5) return 'low';
    return 'very low';
  }

  String _getSleepQualityLabel(double avg) {
    if (avg >= 4.5) return 'excellent';
    if (avg >= 3.5) return 'good';
    if (avg >= 2.5) return 'fair';
    if (avg >= 1.5) return 'poor';
    return 'very poor';
  }

  double? _calculateAvgSleepDuration(List<SleepEntry> sleeps) {
    final withDuration =
        sleeps.where((e) => e.durationMinutes != null).toList();
    if (withDuration.isEmpty) return null;
    final totalMinutes =
        withDuration.map((e) => e.durationMinutes!).reduce((a, b) => a + b);
    return totalMinutes / withDuration.length / 60; // Convert to hours
  }

  List<String> _extractJournalThemes(List<JournalEntry> journals) {
    final keywords = <String, int>{};
    final keywordList = [
      'work',
      'stress',
      'family',
      'happy',
      'anxious',
      'tired',
      'grateful',
      'sad',
      'exercise',
      'health',
      'sleep',
      'relationship',
      'money',
      'career',
      'friends',
      'lonely',
      'productive',
      'overwhelmed'
    ];

    for (final journal in journals) {
      final lowerContent = journal.content.toLowerCase();
      for (final keyword in keywordList) {
        if (lowerContent.contains(keyword)) {
          keywords[keyword] = (keywords[keyword] ?? 0) + 1;
        }
      }
      // Also count tags
      for (final tag in journal.tags) {
        keywords[tag.toLowerCase()] = (keywords[tag.toLowerCase()] ?? 0) + 1;
      }
    }

    // Return top 5 themes
    return (keywords.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value)))
        .take(5)
        .map((e) => e.key)
        .toList();
  }
}

/// User context provider
final userContextProvider =
    StateNotifierProvider<UserContextNotifier, AsyncValue<UserContext>>((ref) {
  return UserContextNotifier(ref);
});

/// Simple text summary for AI injection
final userContextSummaryProvider = Provider<String>((ref) {
  final context = ref.watch(userContextProvider);
  return context.valueOrNull?.summary ?? '';
});
