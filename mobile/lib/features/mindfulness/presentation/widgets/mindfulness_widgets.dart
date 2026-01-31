import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';

/// Soundscape selector for meditation
class SoundscapeSelector extends StatelessWidget {
  final String? selectedSoundscape;
  final ValueChanged<String?> onSelected;

  const SoundscapeSelector({
    super.key,
    this.selectedSoundscape,
    required this.onSelected,
  });

  static const _soundscapes = [
    {'id': 'none', 'name': 'No Sound', 'icon': Icons.volume_off},
    {'id': 'rain', 'name': 'Rain', 'icon': Icons.water_drop},
    {'id': 'ocean', 'name': 'Ocean Waves', 'icon': Icons.waves},
    {'id': 'forest', 'name': 'Forest', 'icon': Icons.forest},
    {'id': 'fire', 'name': 'Fireplace', 'icon': Icons.local_fire_department},
    {'id': 'wind', 'name': 'Wind', 'icon': Icons.air},
    {'id': 'thunder', 'name': 'Thunder', 'icon': Icons.bolt},
    {'id': 'birds', 'name': 'Birds', 'icon': Icons.flutter_dash},
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Background Sound',
          style: AppTypography.titleSmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        SizedBox(
          height: 100,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _soundscapes.length,
            separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.md),
            itemBuilder: (context, index) {
              final soundscape = _soundscapes[index];
              final id = soundscape['id'] as String;
              final isSelected = selectedSoundscape == id || 
                                 (selectedSoundscape == null && id == 'none');

              return GestureDetector(
                onTap: () => onSelected(id == 'none' ? null : id),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 80,
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary.withValues(alpha: 0.2)
                        : AppColors.card,
                    borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
                    border: Border.all(
                      color: isSelected ? AppColors.primary : AppColors.divider,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        soundscape['icon'] as IconData,
                        color: isSelected ? AppColors.primary : AppColors.textSecondary,
                        size: 28,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        soundscape['name'] as String,
                        style: AppTypography.caption.copyWith(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

/// Timer duration selector
class TimerDurationSelector extends StatelessWidget {
  final int selectedMinutes;
  final ValueChanged<int> onSelected;

  const TimerDurationSelector({
    super.key,
    required this.selectedMinutes,
    required this.onSelected,
  });

  static const _durations = [1, 3, 5, 10, 15, 20, 30];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Duration',
          style: AppTypography.titleSmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: _durations.map((minutes) {
            final isSelected = selectedMinutes == minutes;

            return InkWell(
              onTap: () => onSelected(minutes),
              borderRadius: BorderRadius.circular(AppSpacing.buttonRadiusPill),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : AppColors.card,
                  borderRadius: BorderRadius.circular(AppSpacing.buttonRadiusPill),
                  border: Border.all(
                    color: isSelected ? AppColors.primary : AppColors.divider,
                  ),
                ),
                child: Text(
                  '$minutes min',
                  style: AppTypography.labelMedium.copyWith(
                    color: isSelected ? AppColors.textPrimary : AppColors.textSecondary,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

/// Exercise completion card
class ExerciseCompletionCard extends StatelessWidget {
  final String exerciseName;
  final int duration;
  final DateTime completedAt;
  final VoidCallback? onTap;

  const ExerciseCompletionCard({
    super.key,
    required this.exerciseName,
    required this.duration,
    required this.completedAt,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
          border: Border.all(color: AppColors.divider),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.check_circle,
                color: AppColors.success,
                size: 22,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    exerciseName,
                    style: AppTypography.titleSmall.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    '$duration minutes • ${_formatTime(completedAt)}',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final hour = time.hour > 12 ? time.hour - 12 : (time.hour == 0 ? 12 : time.hour);
    final period = time.hour >= 12 ? 'PM' : 'AM';
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute $period';
  }
}

/// Mindfulness streak widget
class MindfulnessStreak extends StatelessWidget {
  final int streak;
  final int goal;

  const MindfulnessStreak({
    super.key,
    required this.streak,
    this.goal = 7,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.moodExcellent.withValues(alpha: 0.2),
            AppColors.secondary.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        border: Border.all(
          color: AppColors.moodExcellent.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: AppColors.moodExcellent.withValues(alpha: 0.3),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.local_fire_department,
              color: AppColors.moodExcellent,
              size: 24,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$streak Day Streak!',
                  style: AppTypography.titleMedium.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  streak >= goal
                      ? 'Goal reached! Keep it going!'
                      : '${goal - streak} more days to reach your goal',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          // Progress ring
          SizedBox(
            width: 50,
            height: 50,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: streak / goal,
                  strokeWidth: 4,
                  backgroundColor: AppColors.surface,
                  color: AppColors.moodExcellent,
                ),
                Text(
                  '${(streak / goal * 100).toInt()}%',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
