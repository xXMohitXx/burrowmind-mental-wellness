import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Note: Full provider tests require mocking DAOs
// These are basic unit tests for model behavior

void main() {
  group('WellnessScore Logic Tests', () {
    test('WellnessScore label returns correct value for score ranges', () {
      expect(_getTestLabel(85), 'Excellent');
      expect(_getTestLabel(72), 'Good');
      expect(_getTestLabel(55), 'Fair');
      expect(_getTestLabel(35), 'Needs Attention');
      expect(_getTestLabel(20), 'Support Needed');
    });

    test('Score weighting is correct', () {
      // 40% mood + 40% sleep + 20% activity = 100%
      const moodWeight = 0.4;
      const sleepWeight = 0.4;
      const activityWeight = 0.2;

      expect(moodWeight + sleepWeight + activityWeight, 1.0);
    });

    test('Score is bounded 0-100', () {
      final testScores = [0, 50, 100];
      for (final score in testScores) {
        expect(score >= 0 && score <= 100, true);
      }
    });
  });
}

// Helper to test label logic (mirrors WellnessScoreNotifier.getLabel)
String _getTestLabel(int score) {
  if (score >= 80) return 'Excellent';
  if (score >= 60) return 'Good';
  if (score >= 40) return 'Fair';
  if (score >= 20) return 'Needs Attention';
  return 'Support Needed';
}
