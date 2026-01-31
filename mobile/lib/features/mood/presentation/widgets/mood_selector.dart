import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';

/// Mood Selector Widget - 5 mood scale
class MoodSelector extends StatelessWidget {
  final int selectedMood;
  final ValueChanged<int> onMoodSelected;

  const MoodSelector({
    super.key,
    required this.selectedMood,
    required this.onMoodSelected,
  });

  static const _moods = [
    {'emoji': '😢', 'label': 'Terrible', 'color': AppColors.moodTerrible},
    {'emoji': '😔', 'label': 'Bad', 'color': AppColors.moodBad},
    {'emoji': '😐', 'label': 'Okay', 'color': AppColors.moodNeutral},
    {'emoji': '😊', 'label': 'Good', 'color': AppColors.moodGood},
    {'emoji': '😄', 'label': 'Excellent', 'color': AppColors.moodExcellent},
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(5, (index) {
        final mood = _moods[index];
        final isSelected = selectedMood == index + 1;
        final color = mood['color'] as Color;

        return GestureDetector(
          onTap: () => onMoodSelected(index + 1),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: EdgeInsets.all(isSelected ? AppSpacing.md : AppSpacing.sm),
            decoration: BoxDecoration(
              color: isSelected ? color.withValues(alpha: 0.2) : Colors.transparent,
              shape: BoxShape.circle,
              border: isSelected
                  ? Border.all(color: color, width: 2)
                  : null,
            ),
            child: Column(
              children: [
                Text(
                  mood['emoji'] as String,
                  style: TextStyle(
                    fontSize: isSelected ? 40 : 32,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  mood['label'] as String,
                  style: AppTypography.caption.copyWith(
                    color: isSelected ? color : AppColors.textTertiary,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}

/// Compact Mood Selector for quick logging
class CompactMoodSelector extends StatelessWidget {
  final int? selectedMood;
  final ValueChanged<int> onMoodSelected;

  const CompactMoodSelector({
    super.key,
    this.selectedMood,
    required this.onMoodSelected,
  });

  static const _emojis = ['😢', '😔', '😐', '😊', '😄'];

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: List.generate(5, (index) {
        final isSelected = selectedMood == index + 1;

        return GestureDetector(
          onTap: () => onMoodSelected(index + 1),
          child: AnimatedScale(
            scale: isSelected ? 1.2 : 1.0,
            duration: const Duration(milliseconds: 150),
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary.withValues(alpha: 0.2)
                    : AppColors.surface,
                shape: BoxShape.circle,
                border: isSelected
                    ? Border.all(color: AppColors.primary, width: 2)
                    : Border.all(color: AppColors.divider),
              ),
              child: Center(
                child: Text(
                  _emojis[index],
                  style: const TextStyle(fontSize: 24),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}
