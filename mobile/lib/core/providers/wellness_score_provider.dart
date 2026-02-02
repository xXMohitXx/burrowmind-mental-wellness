import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'mood_provider.dart';
import 'sleep_provider.dart';

/// Wellness Score Provider - Calculates overall wellness from mood, sleep, and other factors
///
/// Score Formula:
/// - Mood: 40% weight (1-5 scale normalized to 0-100)
/// - Sleep Quality: 30% weight (1-5 scale normalized to 0-100)
/// - Sleep Duration: 20% weight (7-9 hours = 100, <6 or >10 = lower)
/// - Journaling Activity: 10% weight (logged today = 100, otherwise 0)

class WellnessScore {
  final int overallScore;
  final int moodScore;
  final int sleepScore;
  final int activityScore;
  final String label;
  final String insight;

  WellnessScore({
    required this.overallScore,
    required this.moodScore,
    required this.sleepScore,
    required this.activityScore,
    required this.label,
    required this.insight,
  });

  factory WellnessScore.empty() => WellnessScore(
        overallScore: 0,
        moodScore: 0,
        sleepScore: 0,
        activityScore: 0,
        label: 'No Data',
        insight:
            'Start tracking your mood and sleep to see your wellness score.',
      );
}

class WellnessScoreNotifier extends StateNotifier<AsyncValue<WellnessScore>> {
  final Ref _ref;

  WellnessScoreNotifier(this._ref) : super(const AsyncValue.loading()) {
    calculateScore();
    // Listen for changes and recalculate
    _ref.listen(moodEntriesProvider, (_, __) => calculateScore());
    _ref.listen(sleepEntriesProvider, (_, __) => calculateScore());
  }

  Future<void> calculateScore() async {
    try {
      state = const AsyncValue.loading();

      // Get mood data
      final moodAsync = _ref.read(moodEntriesProvider);
      final moodEntries = moodAsync.valueOrNull ?? [];

      // Get sleep data
      final sleepAsync = _ref.read(sleepEntriesProvider);
      final sleepEntries = sleepAsync.valueOrNull ?? [];

      // Calculate mood score (average of last 7 days)
      int moodScore = 0;
      if (moodEntries.isNotEmpty) {
        final recentMoods = moodEntries.where((e) {
          return DateTime.now().difference(e.createdAt).inDays < 7;
        }).toList();

        if (recentMoods.isNotEmpty) {
          final avgMood =
              recentMoods.map((e) => e.moodLevel).reduce((a, b) => a + b) /
                  recentMoods.length;
          moodScore = ((avgMood - 1) / 4 * 100).round();
        }
      }

      // Calculate sleep score
      int sleepScore = 0;
      if (sleepEntries.isNotEmpty) {
        final recentSleep = sleepEntries.where((e) {
          return DateTime.now().difference(e.createdAt).inDays < 7;
        }).toList();

        if (recentSleep.isNotEmpty) {
          // Quality component (50%)
          final avgQuality =
              recentSleep.map((e) => e.qualityScore).reduce((a, b) => a + b) /
                  recentSleep.length;
          final qualityScore = ((avgQuality - 1) / 4 * 100).round();

          // Duration component (50%)
          final withDuration =
              recentSleep.where((e) => e.durationMinutes != null).toList();
          int durationScore = 50; // Default if no duration data
          if (withDuration.isNotEmpty) {
            final avgMinutes = withDuration
                    .map((e) => e.durationMinutes!)
                    .reduce((a, b) => a + b) /
                withDuration.length;
            final avgHours = avgMinutes / 60;
            // Optimal is 7-9 hours
            if (avgHours >= 7 && avgHours <= 9) {
              durationScore = 100;
            } else if (avgHours >= 6 && avgHours < 7) {
              durationScore = 75;
            } else if (avgHours > 9 && avgHours <= 10) {
              durationScore = 75;
            } else if (avgHours >= 5 && avgHours < 6) {
              durationScore = 50;
            } else {
              durationScore = 25;
            }
          }

          sleepScore = ((qualityScore + durationScore) / 2).round();
        }
      }

      // Activity score (did they log anything today?)
      int activityScore = 0;
      final today = DateTime.now();
      final todayStart = DateTime(today.year, today.month, today.day);

      final loggedMoodToday =
          moodEntries.any((e) => e.createdAt.isAfter(todayStart));
      final loggedSleepToday =
          sleepEntries.any((e) => e.createdAt.isAfter(todayStart));

      if (loggedMoodToday && loggedSleepToday) {
        activityScore = 100;
      } else if (loggedMoodToday || loggedSleepToday) {
        activityScore = 50;
      }

      // Calculate overall score with weights
      final overallScore =
          (moodScore * 0.4 + sleepScore * 0.4 + activityScore * 0.2).round();

      // Generate label and insight
      String label;
      String insight;

      if (overallScore >= 80) {
        label = 'Excellent';
        insight = 'You\'re doing great! Keep up the healthy habits.';
      } else if (overallScore >= 60) {
        label = 'Good';
        insight = 'You\'re on track. Consider focusing on sleep quality.';
      } else if (overallScore >= 40) {
        label = 'Fair';
        insight =
            'There\'s room for improvement. Try logging your daily mood and sleep.';
      } else if (overallScore > 0) {
        label = 'Needs Attention';
        insight =
            'Start with small steps - log your mood and aim for 7-8 hours of sleep.';
      } else {
        label = 'No Data';
        insight =
            'Start tracking your mood and sleep to see your wellness score.';
      }

      state = AsyncValue.data(WellnessScore(
        overallScore: overallScore,
        moodScore: moodScore,
        sleepScore: sleepScore,
        activityScore: activityScore,
        label: label,
        insight: insight,
      ));
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

/// Wellness score provider
final wellnessScoreProvider =
    StateNotifierProvider<WellnessScoreNotifier, AsyncValue<WellnessScore>>(
        (ref) {
  return WellnessScoreNotifier(ref);
});

/// Simple wellness score for quick access
final simpleWellnessScoreProvider = Provider<int>((ref) {
  final score = ref.watch(wellnessScoreProvider);
  return score.valueOrNull?.overallScore ?? 0;
});
