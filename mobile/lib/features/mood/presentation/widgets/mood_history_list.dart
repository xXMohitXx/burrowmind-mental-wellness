import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';

/// Mood History Entry Model
class MoodEntry {
  final String id;
  final DateTime timestamp;
  final int mood; // 1-5
  final String? note;
  final List<String> factors;

  const MoodEntry({
    required this.id,
    required this.timestamp,
    required this.mood,
    this.note,
    this.factors = const [],
  });

  String get emoji {
    switch (mood) {
      case 1:
        return '😢';
      case 2:
        return '😔';
      case 3:
        return '😐';
      case 4:
        return '😊';
      case 5:
        return '😄';
      default:
        return '❓';
    }
  }

  String get moodLabel {
    switch (mood) {
      case 1:
        return 'Terrible';
      case 2:
        return 'Bad';
      case 3:
        return 'Okay';
      case 4:
        return 'Good';
      case 5:
        return 'Excellent';
      default:
        return 'Unknown';
    }
  }

  Color get color {
    switch (mood) {
      case 1:
        return AppColors.moodTerrible;
      case 2:
        return AppColors.moodBad;
      case 3:
        return AppColors.moodNeutral;
      case 4:
        return AppColors.moodGood;
      case 5:
        return AppColors.moodExcellent;
      default:
        return AppColors.textTertiary;
    }
  }
}

/// Mood History List
class MoodHistoryList extends StatelessWidget {
  const MoodHistoryList({super.key});

  // Mock data
  List<MoodEntry> get _entries => [
        MoodEntry(
          id: '1',
          timestamp: DateTime.now().subtract(const Duration(hours: 2)),
          mood: 4,
          note: 'Good meeting at work',
          factors: ['Work', 'Social'],
        ),
        MoodEntry(
          id: '2',
          timestamp: DateTime.now().subtract(const Duration(hours: 5)),
          mood: 3,
          note: 'Slightly tired after lunch',
          factors: ['Food', 'Sleep'],
        ),
        MoodEntry(
          id: '3',
          timestamp: DateTime.now().subtract(const Duration(days: 1)),
          mood: 5,
          note: 'Great workout session!',
          factors: ['Exercise', 'Health'],
        ),
        MoodEntry(
          id: '4',
          timestamp: DateTime.now().subtract(const Duration(days: 1, hours: 8)),
          mood: 4,
          factors: ['Work'],
        ),
        MoodEntry(
          id: '5',
          timestamp: DateTime.now().subtract(const Duration(days: 2)),
          mood: 2,
          note: 'Stressful day, couldn\'t relax',
          factors: ['Stress', 'Work'],
        ),
        MoodEntry(
          id: '6',
          timestamp: DateTime.now().subtract(const Duration(days: 3)),
          mood: 4,
          note: 'Quiet evening at home',
          factors: ['Relaxation', 'Family'],
        ),
      ];

  @override
  Widget build(BuildContext context) {
    final grouped = _groupByDate(_entries);

    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.screenPaddingH),
      itemCount: grouped.length,
      itemBuilder: (context, index) {
        final group = grouped.entries.elementAt(index);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date header
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
              child: Text(
                group.key,
                style: AppTypography.titleSmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            // Entries
            ...group.value.map((entry) => _MoodHistoryCard(entry: entry)),
          ],
        );
      },
    );
  }

  Map<String, List<MoodEntry>> _groupByDate(List<MoodEntry> entries) {
    final Map<String, List<MoodEntry>> grouped = {};

    for (final entry in entries) {
      final date = _formatDate(entry.timestamp);
      grouped.putIfAbsent(date, () => []);
      grouped[date]!.add(entry);
    }

    return grouped;
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
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];

    return '${days[date.weekday - 1]}, ${date.day} ${months[date.month - 1]}';
  }
}

class _MoodHistoryCard extends StatelessWidget {
  final MoodEntry entry;

  const _MoodHistoryCard({required this.entry});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Emoji
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: entry.color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                entry.emoji,
                style: const TextStyle(fontSize: 24),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),

          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      entry.moodLabel,
                      style: AppTypography.titleSmall.copyWith(
                        color: entry.color,
                      ),
                    ),
                    Text(
                      _formatTime(entry.timestamp),
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),

                // Note
                if (entry.note != null) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    entry.note!,
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],

                // Factors
                if (entry.factors.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.sm),
                  Wrap(
                    spacing: AppSpacing.xs,
                    children: entry.factors.map((factor) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(AppSpacing.buttonRadiusPill),
                        ),
                        child: Text(
                          factor,
                          style: AppTypography.caption.copyWith(
                            color: AppColors.textTertiary,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    final hour = time.hour > 12 ? time.hour - 12 : time.hour;
    final period = time.hour >= 12 ? 'PM' : 'AM';
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute $period';
  }
}
