/// App-wide Constants for BurrowMind
class AppConstants {
  AppConstants._();

  // App Info
  static const String appName = 'BurrowMind';
  static const String appTagline = 'Your Mental Wellness Companion';
  static const String appVersion = '1.0.0';

  // Storage Keys
  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userIdKey = 'user_id';
  static const String onboardingCompleteKey = 'onboarding_complete';
  static const String themeKey = 'theme_mode';
  static const String notificationsEnabledKey = 'notifications_enabled';
  static const String quietHoursStartKey = 'quiet_hours_start';
  static const String quietHoursEndKey = 'quiet_hours_end';

  // Database
  static const String databaseName = 'burrowmind.db';
  static const int databaseVersion = 1;

  // Validation
  static const int minPasswordLength = 8;
  static const int maxPasswordLength = 128;
  static const int otpLength = 6;
  static const int pinLength = 4;

  // Mood Levels (1-5)
  static const int moodLevelTerrible = 1;
  static const int moodLevelBad = 2;
  static const int moodLevelNeutral = 3;
  static const int moodLevelGood = 4;
  static const int moodLevelExcellent = 5;

  // Stress Levels (1-10)
  static const int stressLevelMin = 1;
  static const int stressLevelMax = 10;

  // Sleep Quality (0-100)
  static const int sleepQualityMin = 0;
  static const int sleepQualityMax = 100;

  // Mental Health Score (0-100)
  static const int mentalScoreMin = 0;
  static const int mentalScoreMax = 100;

  // Score Thresholds
  static const int scoreThresholdLow = 40;
  static const int scoreThresholdMedium = 70;

  // Animation Durations
  static const Duration animationFast = Duration(milliseconds: 200);
  static const Duration animationNormal = Duration(milliseconds: 300);
  static const Duration animationSlow = Duration(milliseconds: 500);

  // Timeouts
  static const Duration apiTimeout = Duration(seconds: 30);
  static const Duration splashDuration = Duration(seconds: 2);

  // Chat
  static const int maxChatHistoryMessages = 50;
  static const int chatContextWindow = 10;

  // Journal
  static const int maxJournalTitleLength = 100;
  static const int maxJournalContentLength = 10000;

  // Pagination
  static const int defaultPageSize = 20;

  // Mood Emoji Map
  static const Map<int, String> moodEmojis = {
    1: '😢',
    2: '😕',
    3: '😐',
    4: '🙂',
    5: '😊',
  };

  // Mood Labels
  static const Map<int, String> moodLabels = {
    1: 'Terrible',
    2: 'Bad',
    3: 'Neutral',
    4: 'Good',
    5: 'Excellent',
  };

  // Stress Labels
  static const Map<int, String> stressLabels = {
    1: 'Very Low',
    2: 'Low',
    3: 'Low',
    4: 'Moderate',
    5: 'Moderate',
    6: 'Moderate',
    7: 'High',
    8: 'High',
    9: 'Very High',
    10: 'Critical',
  };

  // Common Stressors
  static const List<String> commonStressors = [
    'Work',
    'Relationships',
    'Health',
    'Finances',
    'Family',
    'Loneliness',
    'Social',
    'Study',
    'Sleep',
    'Other',
  ];

  // Mood Factors
  static const List<String> moodFactors = [
    'Sleep',
    'Exercise',
    'Work',
    'Social',
    'Weather',
    'Health',
    'Food',
    'Hobbies',
    'Family',
    'Relationships',
  ];

  // Mindful Session Types
  static const List<String> sessionTypes = [
    'Meditation',
    'Breathing',
    'Exercise',
    'Yoga',
    'Walking',
    'Reading',
  ];

  // AI Disclaimer
  static const String aiDisclaimer =
      'This AI companion is designed for reflection and self-awareness, not therapy or medical advice. '
      'If you are in crisis, please contact a mental health professional or emergency services.';

  // Privacy Notice
  static const String privacyNotice =
      'Your data is stored locally on your device. We respect your privacy and do not share your personal information.';
}
