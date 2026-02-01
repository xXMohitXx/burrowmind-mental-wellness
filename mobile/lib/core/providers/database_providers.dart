import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/local/database.dart';
import '../../data/local/dao/mood_dao.dart';
import '../../data/local/dao/sleep_dao.dart';
import '../../data/local/dao/journal_dao.dart';
import '../../data/local/dao/conversation_dao.dart';
import '../../data/local/dao/user_dao.dart';
import '../../data/local/dao/score_dao.dart';

/// Database singleton provider
final databaseProvider = Provider<AppDatabase>((ref) {
  return AppDatabase.instance;
});

/// DAO Providers
final moodDaoProvider = Provider<MoodDao>((ref) {
  return MoodDao(ref.watch(databaseProvider));
});

final sleepDaoProvider = Provider<SleepDao>((ref) {
  return SleepDao(ref.watch(databaseProvider));
});

final journalDaoProvider = Provider<JournalDao>((ref) {
  return JournalDao(ref.watch(databaseProvider));
});

final conversationDaoProvider = Provider<ConversationDao>((ref) {
  return ConversationDao(ref.watch(databaseProvider));
});

final userDaoProvider = Provider<UserDao>((ref) {
  return UserDao(ref.watch(databaseProvider));
});

final scoreDaoProvider = Provider<ScoreDao>((ref) {
  return ScoreDao(ref.watch(databaseProvider));
});
