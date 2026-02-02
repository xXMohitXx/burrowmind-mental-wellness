import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/buttons.dart';
import '../../../../core/providers/sleep_provider.dart';
import '../widgets/sleep_chart.dart';
import '../widgets/sleep_quality_selector.dart';

/// Sleep Tracker Screen with Provider Integration
class SleepScreen extends ConsumerStatefulWidget {
  const SleepScreen({super.key});

  @override
  ConsumerState<SleepScreen> createState() => _SleepScreenState();
}

class _SleepScreenState extends ConsumerState<SleepScreen>
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
        title: const Text('Sleep Tracker'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => _showSleepSettings(context),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.info,
          labelColor: AppColors.info,
          unselectedLabelColor: AppColors.textSecondary,
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'History'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(),
          _buildHistoryTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showSleepLogSheet(context),
        backgroundColor: AppColors.info,
        icon: const Icon(Icons.bedtime, color: AppColors.textPrimary),
        label: Text(
          'Log Sleep',
          style: AppTypography.labelMedium.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
      ),
    );
  }

  Widget _buildOverviewTab() {
    final lastNight = ref.watch(lastNightSleepProvider);
    final sleepEntries = ref.watch(sleepEntriesProvider);
    final weeklyAvg = ref.watch(weeklySleepAverageProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.screenPaddingH),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Last night sleep card
          _buildLastNightCard(lastNight),

          const SizedBox(height: AppSpacing.lg),

          // Sleep score ring
          _buildSleepScoreCard(weeklyAvg, sleepEntries),

          const SizedBox(height: AppSpacing.lg),

          // Weekly chart
          Text(
            'Weekly Overview',
            style: AppTypography.titleMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          _buildWeeklyChart(sleepEntries),

          const SizedBox(height: AppSpacing.lg),

          // Sleep stats
          Text(
            'Sleep Statistics',
            style: AppTypography.titleMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          _buildSleepStats(sleepEntries),

          const SizedBox(height: AppSpacing.lg),

          // Sleep tips
          _buildSleepTipsCard(),

          const SizedBox(height: AppSpacing.xxl),
        ],
      ),
    );
  }

  Widget _buildHistoryTab() {
    final sleepEntries = ref.watch(sleepEntriesProvider);

    return sleepEntries.when(
      data: (entries) {
        if (entries.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.nightlight_round,
                  size: 64,
                  color: AppColors.textTertiary,
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'No sleep entries yet',
                  style: AppTypography.titleMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Start tracking your sleep to see your history',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(AppSpacing.screenPaddingH),
          itemCount: entries.length,
          itemBuilder: (context, index) {
            final entry = entries[index];
            return _buildHistoryItem(entry);
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(
        child: Text(
          'Error loading sleep data: $e',
          style: AppTypography.bodyMedium.copyWith(color: AppColors.error),
        ),
      ),
    );
  }

  Widget _buildHistoryItem(SleepEntry entry) {
    final color = _getQualityColor(entry.qualityScore);

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.nightlight_round,
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _formatDate(entry.createdAt),
                  style: AppTypography.titleSmall.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  '${entry.durationFormatted} · ${entry.qualityLabel}',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          if (entry.sleepStart != null && entry.sleepEnd != null)
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  _formatTime(entry.sleepStart!),
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
                Text(
                  _formatTime(entry.sleepEnd!),
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Color _getQualityColor(int quality) {
    switch (quality) {
      case 5:
        return AppColors.sleepExcellent;
      case 4:
        return AppColors.sleepGood;
      case 3:
        return AppColors.sleepFair;
      case 2:
      case 1:
        return AppColors.sleepPoor;
      default:
        return AppColors.sleepFair;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final entryDate = DateTime(date.year, date.month, date.day);

    if (entryDate == today) return 'Today';
    if (entryDate == yesterday) return 'Yesterday';

    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
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

    return '${days[date.weekday - 1]}, ${date.day} ${months[date.month - 1]}';
  }

  String _formatTime(DateTime dt) {
    final hour = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    final minute = dt.minute.toString().padLeft(2, '0');
    return '$hour:$minute $period';
  }

  Widget _buildLastNightCard(AsyncValue<SleepEntry?> lastNight) {
    return lastNight.when(
      data: (entry) {
        final duration = entry?.durationFormatted ?? '--';
        final quality = entry?.qualityLabel ?? 'Not logged';
        final bedtime =
            entry?.sleepStart != null ? _formatTime(entry!.sleepStart!) : '--';

        return Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.info.withValues(alpha: 0.3),
                AppColors.tertiary.withValues(alpha: 0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(AppSpacing.cardRadiusLarge),
            border: Border.all(
              color: AppColors.info.withValues(alpha: 0.3),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: AppColors.info.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.nights_stay,
                      color: AppColors.info,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Text(
                    'Last Night',
                    style: AppTypography.titleMedium.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildSleepMetric('Duration', duration, Icons.access_time),
                  _buildSleepMetric('Quality', quality, Icons.star),
                  _buildSleepMetric('Bedtime', bedtime, Icons.bedtime),
                ],
              ),
            ],
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: const Text('Error loading last night data'),
      ),
    );
  }

  Widget _buildSleepMetric(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: AppColors.info, size: 24),
        const SizedBox(height: AppSpacing.sm),
        Text(
          value,
          style: AppTypography.titleMedium.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        Text(
          label,
          style: AppTypography.caption.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildSleepScoreCard(
    AsyncValue<double?> weeklyAvg,
    AsyncValue<List<SleepEntry>> entries,
  ) {
    return weeklyAvg.when(
      data: (avg) {
        final score = avg != null ? (avg * 20).toInt() : 0;
        final label = score >= 80
            ? 'Excellent Sleep'
            : score >= 60
                ? 'Good Sleep'
                : score >= 40
                    ? 'Fair Sleep'
                    : 'Poor Sleep';
        final color = score >= 80
            ? AppColors.sleepExcellent
            : score >= 60
                ? AppColors.sleepGood
                : score >= 40
                    ? AppColors.sleepFair
                    : AppColors.sleepPoor;

        final entryCount = entries.valueOrNull?.length ?? 0;
        final avgDuration = _calculateAvgDuration(entries.valueOrNull ?? []);

        return Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
            border: Border.all(color: AppColors.divider),
          ),
          child: Row(
            children: [
              // Score ring
              SizedBox(
                width: 100,
                height: 100,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 100,
                      height: 100,
                      child: CircularProgressIndicator(
                        value: score / 100,
                        strokeWidth: 8,
                        backgroundColor: AppColors.surface,
                        color: color,
                      ),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '$score',
                          style: AppTypography.headlineMedium.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Score',
                          style: AppTypography.caption.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: AppTypography.titleLarge.copyWith(
                        color: color,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      entryCount > 0
                          ? 'You\'re averaging $avgDuration of sleep this week.'
                          : 'Start logging to see your weekly average!',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => const Text('Error loading score'),
    );
  }

  String _calculateAvgDuration(List<SleepEntry> entries) {
    if (entries.isEmpty) return '--';
    final totalMinutes = entries
        .where((e) => e.durationMinutes != null)
        .fold<int>(0, (sum, e) => sum + e.durationMinutes!);
    final count = entries.where((e) => e.durationMinutes != null).length;
    if (count == 0) return '--';
    final avgMinutes = totalMinutes ~/ count;
    final hours = avgMinutes ~/ 60;
    final mins = avgMinutes % 60;
    return '${hours}h ${mins}m';
  }

  Widget _buildWeeklyChart(AsyncValue<List<SleepEntry>> entriesAsync) {
    return entriesAsync.when(
      data: (entries) {
        final weekData = _getWeeklyData(entries);
        return SleepChart(
          sleepData: weekData['data'] as List<double>,
          labels: weekData['labels'] as List<String>,
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => const Text('Error loading chart'),
    );
  }

  Map<String, dynamic> _getWeeklyData(List<SleepEntry> entries) {
    final weekDays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final data = <double>[0, 0, 0, 0, 0, 0, 0];
    final counts = <int>[0, 0, 0, 0, 0, 0, 0];

    for (final entry in entries) {
      final now = DateTime.now();
      final daysAgo = now.difference(entry.createdAt).inDays;
      if (daysAgo < 7 && entry.durationMinutes != null) {
        final dayIndex = (entry.createdAt.weekday - 1) % 7;
        data[dayIndex] += entry.durationMinutes! / 60.0;
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

  Widget _buildSleepStats(AsyncValue<List<SleepEntry>> entriesAsync) {
    return entriesAsync.when(
      data: (entries) {
        final avgDuration = _calculateAvgDuration(entries);
        final avgBedtime = _calculateAvgBedtime(entries);

        return Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Avg. Duration',
                avgDuration,
                Icons.access_time,
                AppColors.info,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: _buildStatCard(
                'Avg. Bedtime',
                avgBedtime,
                Icons.bedtime,
                AppColors.tertiary,
              ),
            ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => const Text('Error loading stats'),
    );
  }

  String _calculateAvgBedtime(List<SleepEntry> entries) {
    final withBedtime = entries.where((e) => e.sleepStart != null).toList();
    if (withBedtime.isEmpty) return '--';

    int totalMinutes = 0;
    for (final entry in withBedtime) {
      final hour = entry.sleepStart!.hour;
      final minute = entry.sleepStart!.minute;
      // Convert to minutes past midnight (handling late night times)
      final mins =
          hour >= 12 ? (hour * 60 + minute) : ((hour + 24) * 60 + minute);
      totalMinutes += mins;
    }

    final avgMinutes = totalMinutes ~/ withBedtime.length;
    var hour = (avgMinutes ~/ 60) % 24;
    final minute = avgMinutes % 60;
    final period = hour >= 12 && hour < 24 ? 'PM' : 'AM';
    if (hour > 12) hour -= 12;
    if (hour == 0) hour = 12;

    return '$hour:${minute.toString().padLeft(2, '0')} $period';
  }

  Widget _buildStatCard(
      String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: AppSpacing.sm),
          Text(
            value,
            style: AppTypography.titleLarge.copyWith(
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
      ),
    );
  }

  Widget _buildSleepTipsCard() {
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
                  color: AppColors.secondary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.lightbulb_outline,
                  color: AppColors.secondary,
                  size: 20,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Text(
                'Sleep Tip',
                style: AppTypography.titleMedium.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Try to maintain a consistent sleep schedule, even on weekends. Going to bed and waking up at the same time helps regulate your body\'s internal clock.',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  void _showSleepSettings(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSpacing.modalRadius),
        ),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(AppSpacing.screenPaddingH),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
            Text(
              'Sleep Settings',
              style: AppTypography.headlineSmall.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            ListTile(
              leading: const Icon(Icons.alarm, color: AppColors.textSecondary),
              title: const Text('Bedtime Reminder'),
              subtitle: const Text('10:30 PM'),
              trailing: Switch(value: true, onChanged: (_) {}),
            ),
            ListTile(
              leading: const Icon(Icons.sunny, color: AppColors.textSecondary),
              title: const Text('Wake-up Time'),
              subtitle: const Text('6:30 AM'),
              trailing: const Icon(Icons.chevron_right),
            ),
            ListTile(
              leading: const Icon(Icons.track_changes,
                  color: AppColors.textSecondary),
              title: const Text('Sleep Goal'),
              subtitle: const Text('8 hours'),
              trailing: const Icon(Icons.chevron_right),
            ),
            const SizedBox(height: AppSpacing.lg),
          ],
        ),
      ),
    );
  }

  void _showSleepLogSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const SleepLogSheet(),
    );
  }
}

/// Sleep Log Bottom Sheet with Provider Integration
class SleepLogSheet extends ConsumerStatefulWidget {
  const SleepLogSheet({super.key});

  @override
  ConsumerState<SleepLogSheet> createState() => _SleepLogSheetState();
}

class _SleepLogSheetState extends ConsumerState<SleepLogSheet> {
  TimeOfDay _bedtime = const TimeOfDay(hour: 23, minute: 30);
  TimeOfDay _wakeTime = const TimeOfDay(hour: 7, minute: 0);
  int _quality = 4;
  bool _isSaving = false;

  Future<void> _saveSleep() async {
    setState(() => _isSaving = true);

    try {
      // Create DateTime values for sleep start and end
      final now = DateTime.now();
      final sleepStart = DateTime(
        now.year,
        now.month,
        now.day - 1, // Yesterday
        _bedtime.hour,
        _bedtime.minute,
      );
      final sleepEnd = DateTime(
        now.year,
        now.month,
        now.day,
        _wakeTime.hour,
        _wakeTime.minute,
      );

      // Calculate duration
      var durationMinutes = sleepEnd.difference(sleepStart).inMinutes;
      if (durationMinutes < 0) durationMinutes += 24 * 60;

      await ref.read(sleepEntriesProvider.notifier).addSleepEntry(
            qualityScore: _quality,
            sleepStart: sleepStart,
            sleepEnd: sleepEnd,
            durationMinutes: durationMinutes,
          );

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Sleep logged successfully!'),
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
            content: Text('Error saving sleep: $e'),
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
              'Log Your Sleep',
              style: AppTypography.headlineSmall.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Time pickers
            Row(
              children: [
                Expanded(
                  child: _buildTimePicker(
                    label: 'Bedtime',
                    time: _bedtime,
                    icon: Icons.bedtime,
                    onTap: () => _selectTime(context, true),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: _buildTimePicker(
                    label: 'Wake time',
                    time: _wakeTime,
                    icon: Icons.wb_sunny,
                    onTap: () => _selectTime(context, false),
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.lg),

            // Duration display
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.inputBackground,
                borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.access_time, color: AppColors.info),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    'Sleep Duration: ${_calculateDuration()}',
                    style: AppTypography.titleMedium.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.lg),

            // Quality selector
            Text(
              'How did you sleep?',
              style: AppTypography.titleSmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            SleepQualitySelector(
              selectedQuality: _quality,
              onQualitySelected: (q) => setState(() => _quality = q),
            ),

            const SizedBox(height: AppSpacing.lg),

            // Save button
            PrimaryButton(
              text: _isSaving ? 'Saving...' : 'Save Sleep Log',
              onPressed: _isSaving ? null : _saveSleep,
            ),
            const SizedBox(height: AppSpacing.lg),
          ],
        ),
      ),
    );
  }

  Widget _buildTimePicker({
    required String label,
    required TimeOfDay time,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.inputBackground,
          borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
          border: Border.all(color: AppColors.inputBorder),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.info),
            const SizedBox(height: AppSpacing.sm),
            Text(
              label,
              style: AppTypography.caption.copyWith(
                color: AppColors.textTertiary,
              ),
            ),
            Text(
              _formatTimeOfDay(time),
              style: AppTypography.titleLarge.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTimeOfDay(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute $period';
  }

  String _calculateDuration() {
    final bedMinutes = _bedtime.hour * 60 + _bedtime.minute;
    final wakeMinutes = _wakeTime.hour * 60 + _wakeTime.minute;
    var duration = wakeMinutes - bedMinutes;
    if (duration < 0) duration += 24 * 60;
    final hours = duration ~/ 60;
    final minutes = duration % 60;
    return '${hours}h ${minutes}m';
  }

  Future<void> _selectTime(BuildContext context, bool isBedtime) async {
    final time = await showTimePicker(
      context: context,
      initialTime: isBedtime ? _bedtime : _wakeTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.info,
              surface: AppColors.surface,
            ),
          ),
          child: child!,
        );
      },
    );
    if (time != null) {
      setState(() {
        if (isBedtime) {
          _bedtime = time;
        } else {
          _wakeTime = time;
        }
      });
    }
  }
}
