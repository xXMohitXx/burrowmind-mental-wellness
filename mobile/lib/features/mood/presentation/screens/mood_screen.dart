import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/buttons.dart';
import '../../../../core/providers/mood_provider.dart';
import '../widgets/mood_selector.dart';
import '../widgets/mood_chart.dart';

/// Mood Tracker Screen - Main Dashboard with Provider Integration
class MoodScreen extends ConsumerStatefulWidget {
  const MoodScreen({super.key});

  @override
  ConsumerState<MoodScreen> createState() => _MoodScreenState();
}

class _MoodScreenState extends ConsumerState<MoodScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: const Text('Mood Tracker'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () => _showDatePicker(context),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          tabs: const [
            Tab(text: 'Today'),
            Tab(text: 'History'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTodayTab(),
          _buildHistoryTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showMoodLogSheet(context),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: AppColors.textPrimary),
        label: Text(
          'Log Mood',
          style: AppTypography.labelMedium.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
      ),
    );
  }

  Widget _buildTodayTab() {
    final todaysMood = ref.watch(todaysMoodProvider);
    final weeklyMoods = ref.watch(moodEntriesProvider);
    final weeklyAvg = ref.watch(weeklyMoodAverageProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.screenPaddingH),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Current mood card
          _buildCurrentMoodCard(todaysMood, weeklyAvg, weeklyMoods),

          const SizedBox(height: AppSpacing.lg),

          // Today's mood timeline
          Text(
            'Today\'s Moods',
            style: AppTypography.titleMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          _buildMoodTimeline(weeklyMoods),

          const SizedBox(height: AppSpacing.lg),

          // Weekly overview
          Text(
            'Weekly Overview',
            style: AppTypography.titleMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          _buildWeeklyChart(weeklyMoods),

          const SizedBox(height: AppSpacing.lg),

          // Insights
          _buildInsightsCard(weeklyAvg),

          const SizedBox(height: AppSpacing.xxl),
        ],
      ),
    );
  }

  Widget _buildHistoryTab() {
    final moodEntries = ref.watch(moodEntriesProvider);

    return moodEntries.when(
      data: (entries) {
        if (entries.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.sentiment_neutral,
                  size: 64,
                  color: AppColors.textTertiary,
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'No mood entries yet',
                  style: AppTypography.titleMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Start tracking your mood to see your history',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(AppSpacing.screenPaddingH),
          itemCount: entries.length,
          separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
          itemBuilder: (context, index) {
            final entry = entries[index];
            return _buildHistoryItem(entry);
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(
        child: Text(
          'Error loading moods: $e',
          style: AppTypography.bodyMedium.copyWith(color: AppColors.error),
        ),
      ),
    );
  }

  Widget _buildHistoryItem(MoodEntry entry) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          Text(entry.emoji, style: const TextStyle(fontSize: 32)),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.moodLabel,
                  style: AppTypography.titleSmall.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                if (entry.notes != null && entry.notes!.isNotEmpty)
                  Text(
                    entry.notes!,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                Text(
                  _formatDateTime(entry.createdAt),
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
          if (entry.factors.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: 2,
              ),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius:
                    BorderRadius.circular(AppSpacing.buttonRadiusPill),
              ),
              child: Text(
                '${entry.factors.length} factors',
                style: AppTypography.caption.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCurrentMoodCard(
    AsyncValue<MoodEntry?> todaysMood,
    AsyncValue<double?> weeklyAvg,
    AsyncValue<List<MoodEntry>> entries,
  ) {
    return todaysMood.when(
      data: (mood) {
        final emoji = mood?.emoji ?? '😐';
        final label = mood?.moodLabel ?? 'Not logged yet';
        final timeSince = mood != null
            ? _formatTimeSince(mood.createdAt)
            : 'Log your first mood!';

        final avgPercent = weeklyAvg.valueOrNull;
        final entryCount = entries.valueOrNull?.length ?? 0;

        return Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                _getMoodColor(mood?.moodLevel ?? 3).withValues(alpha: 0.3),
                _getMoodColor(mood?.moodLevel ?? 3).withValues(alpha: 0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(AppSpacing.cardRadiusLarge),
            border: Border.all(
              color: _getMoodColor(mood?.moodLevel ?? 3).withValues(alpha: 0.3),
            ),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: _getMoodColor(mood?.moodLevel ?? 3)
                          .withValues(alpha: 0.3),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        emoji,
                        style: const TextStyle(fontSize: 32),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          label,
                          style: AppTypography.headlineSmall.copyWith(
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xxs),
                        Text(
                          timeSince,
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildMoodStat(
                    'Avg. Mood',
                    '📊',
                    avgPercent != null ? '${(avgPercent * 20).toInt()}%' : '--',
                  ),
                  _buildMoodStat('Streak', '🔥', _calculateStreak(entries)),
                  _buildMoodStat('Logs', '📝', '$entryCount'),
                ],
              ),
            ],
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: const Text('Error loading mood'),
      ),
    );
  }

  String _calculateStreak(AsyncValue<List<MoodEntry>> entries) {
    final data = entries.valueOrNull ?? [];
    if (data.isEmpty) return '0 days';

    int streak = 0;
    DateTime? lastDate;

    for (final entry in data) {
      final entryDate = DateTime(
        entry.createdAt.year,
        entry.createdAt.month,
        entry.createdAt.day,
      );

      if (lastDate == null) {
        streak = 1;
        lastDate = entryDate;
      } else {
        final diff = lastDate.difference(entryDate).inDays;
        if (diff == 1) {
          streak++;
          lastDate = entryDate;
        } else if (diff > 1) {
          break;
        }
      }
    }

    return '$streak days';
  }

  Color _getMoodColor(int level) {
    switch (level) {
      case 5:
        return AppColors.moodExcellent;
      case 4:
        return AppColors.moodGood;
      case 3:
        return AppColors.moodNeutral;
      case 2:
        return AppColors.moodBad;
      case 1:
        return AppColors.moodBad;
      default:
        return AppColors.moodNeutral;
    }
  }

  Widget _buildMoodStat(String label, String emoji, String value) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 24)),
        const SizedBox(height: AppSpacing.xs),
        Text(
          value,
          style: AppTypography.titleMedium.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        Text(
          label,
          style: AppTypography.caption.copyWith(
            color: AppColors.textTertiary,
          ),
        ),
      ],
    );
  }

  Widget _buildMoodTimeline(AsyncValue<List<MoodEntry>> entriesAsync) {
    return entriesAsync.when(
      data: (entries) {
        final today = DateTime.now();
        final todayEntries = entries
            .where((e) =>
                e.createdAt.year == today.year &&
                e.createdAt.month == today.month &&
                e.createdAt.day == today.day)
            .toList();

        if (todayEntries.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
              border: Border.all(color: AppColors.divider),
            ),
            child: Center(
              child: Text(
                'No moods logged today. Tap + to add one!',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textTertiary,
                ),
              ),
            ),
          );
        }

        return Column(
          children: todayEntries.map((entry) {
            return Container(
              margin: const EdgeInsets.only(bottom: AppSpacing.sm),
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
                border: Border.all(color: AppColors.divider),
              ),
              child: Row(
                children: [
                  Text(entry.emoji, style: const TextStyle(fontSize: 28)),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          entry.notes ?? entry.moodLabel,
                          style: AppTypography.bodyMedium.copyWith(
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          _formatTime(entry.createdAt),
                          style: AppTypography.caption.copyWith(
                            color: AppColors.textTertiary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => const Text('Error loading timeline'),
    );
  }

  Widget _buildWeeklyChart(AsyncValue<List<MoodEntry>> entriesAsync) {
    return entriesAsync.when(
      data: (entries) {
        final weekData = _getWeeklyData(entries);
        return MoodChart(
          moodData: weekData['data'] as List<double>,
          labels: weekData['labels'] as List<String>,
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => const Text('Error loading chart'),
    );
  }

  Map<String, dynamic> _getWeeklyData(List<MoodEntry> entries) {
    final now = DateTime.now();
    final weekDays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final data = <double>[0, 0, 0, 0, 0, 0, 0];
    final counts = <int>[0, 0, 0, 0, 0, 0, 0];

    for (final entry in entries) {
      final daysAgo = now.difference(entry.createdAt).inDays;
      if (daysAgo < 7) {
        final dayIndex = (entry.createdAt.weekday - 1) % 7;
        data[dayIndex] += entry.moodLevel;
        counts[dayIndex]++;
      }
    }

    for (int i = 0; i < 7; i++) {
      if (counts[i] > 0) {
        data[i] = data[i] / counts[i];
      }
    }

    return {'data': data, 'labels': weekDays};
  }

  Widget _buildInsightsCard(AsyncValue<double?> weeklyAvg) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: AppColors.tertiary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.auto_awesome,
                  color: AppColors.tertiary,
                  size: 20,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Text(
                'AI Insights',
                style: AppTypography.titleMedium.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          weeklyAvg.when(
            data: (avg) {
              if (avg == null) {
                return Text(
                  'Log more moods to unlock personalized insights!',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                );
              }
              return Text(
                avg >= 3.5
                    ? 'Great job! Your mood has been consistently positive this week. Keep up the good habits!'
                    : 'Your mood has been variable. Consider adding relaxation or mindfulness activities.',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              );
            },
            loading: () => const CircularProgressIndicator(),
            error: (_, __) => const Text('Unable to load insights'),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final hour = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    final minute = dt.minute.toString().padLeft(2, '0');
    return '$hour:$minute $period';
  }

  String _formatDateTime(DateTime dt) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${months[dt.month - 1]} ${dt.day}, ${_formatTime(dt)}';
  }

  String _formatTimeSince(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    } else {
      return '${diff.inDays}d ago';
    }
  }

  void _showDatePicker(BuildContext context) async {
    await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.primary,
              surface: AppColors.surface,
            ),
          ),
          child: child!,
        );
      },
    );
  }

  void _showMoodLogSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const MoodLogSheet(),
    );
  }
}

/// Mood Log Bottom Sheet - Connected to Provider
class MoodLogSheet extends ConsumerStatefulWidget {
  const MoodLogSheet({super.key});

  @override
  ConsumerState<MoodLogSheet> createState() => _MoodLogSheetState();
}

class _MoodLogSheetState extends ConsumerState<MoodLogSheet> {
  int _selectedMood = 3;
  final _noteController = TextEditingController();
  final List<String> _selectedFactors = [];
  bool _isSaving = false;

  static const _factors = [
    'Work',
    'Family',
    'Health',
    'Sleep',
    'Exercise',
    'Weather',
    'Social',
    'Food',
    'Stress',
    'Relaxation',
  ];

  static const _moodEmojis = ['😢', '😔', '😐', '🙂', '😊'];

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _saveMood() async {
    setState(() => _isSaving = true);

    try {
      await ref.read(moodEntriesProvider.notifier).addMood(
            moodLevel: _selectedMood,
            moodEmoji: _moodEmojis[_selectedMood - 1],
            factors: _selectedFactors,
            notes:
                _noteController.text.isNotEmpty ? _noteController.text : null,
          );

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Mood saved successfully!'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSpacing.cardRadiusSmall),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving mood: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSpacing.modalRadius),
        ),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.screenPaddingH),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Title
            Text(
              'How are you feeling?',
              style: AppTypography.headlineSmall.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Mood selector
            MoodSelector(
              selectedMood: _selectedMood,
              onMoodSelected: (mood) => setState(() => _selectedMood = mood),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Factors
            Text(
              'What\'s affecting your mood?',
              style: AppTypography.titleSmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: _factors.map((factor) {
                final isSelected = _selectedFactors.contains(factor);
                return InkWell(
                  onTap: () {
                    setState(() {
                      if (isSelected) {
                        _selectedFactors.remove(factor);
                      } else {
                        _selectedFactors.add(factor);
                      }
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary.withValues(alpha: 0.2)
                          : AppColors.inputBackground,
                      borderRadius:
                          BorderRadius.circular(AppSpacing.buttonRadiusPill),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.inputBorder,
                      ),
                    ),
                    child: Text(
                      factor,
                      style: AppTypography.labelMedium.copyWith(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.textSecondary,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Note
            Text(
              'Add a note (optional)',
              style: AppTypography.titleSmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            TextField(
              controller: _noteController,
              maxLines: 3,
              style: AppTypography.bodyMedium,
              decoration: InputDecoration(
                hintText: 'What\'s on your mind?',
                hintStyle: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textTertiary,
                ),
                filled: true,
                fillColor: AppColors.inputBackground,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Save button
            PrimaryButton(
              text: _isSaving ? 'Saving...' : 'Save Mood',
              onPressed: _isSaving ? null : _saveMood,
            ),
            const SizedBox(height: AppSpacing.lg),
          ],
        ),
      ),
    );
  }
}
