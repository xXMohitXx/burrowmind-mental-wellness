import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';

/// Sleep Quality Selector - 5-point scale
class SleepQualitySelector extends StatelessWidget {
  final int selectedQuality;
  final ValueChanged<int> onQualitySelected;

  const SleepQualitySelector({
    super.key,
    required this.selectedQuality,
    required this.onQualitySelected,
  });

  static const _qualities = [
    {'emoji': '😫', 'label': 'Terrible', 'color': AppColors.sleepPoor},
    {'emoji': '😪', 'label': 'Poor', 'color': AppColors.moodBad},
    {'emoji': '😐', 'label': 'Fair', 'color': AppColors.sleepFair},
    {'emoji': '😌', 'label': 'Good', 'color': AppColors.sleepGood},
    {'emoji': '😴', 'label': 'Excellent', 'color': AppColors.sleepExcellent},
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(5, (index) {
        final quality = _qualities[index];
        final isSelected = selectedQuality == index + 1;
        final color = quality['color'] as Color;

        return GestureDetector(
          onTap: () => onQualitySelected(index + 1),
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
                  quality['emoji'] as String,
                  style: TextStyle(
                    fontSize: isSelected ? 36 : 28,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  quality['label'] as String,
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

/// Sleep Quality Badge
class SleepQualityBadge extends StatelessWidget {
  final int quality; // 1-5
  final bool showLabel;

  const SleepQualityBadge({
    super.key,
    required this.quality,
    this.showLabel = true,
  });

  String get _emoji {
    switch (quality) {
      case 1: return '😫';
      case 2: return '😪';
      case 3: return '😐';
      case 4: return '😌';
      case 5: return '😴';
      default: return '❓';
    }
  }

  String get _label {
    switch (quality) {
      case 1: return 'Terrible';
      case 2: return 'Poor';
      case 3: return 'Fair';
      case 4: return 'Good';
      case 5: return 'Excellent';
      default: return 'Unknown';
    }
  }

  Color get _color {
    switch (quality) {
      case 1: return AppColors.sleepPoor;
      case 2: return AppColors.moodBad;
      case 3: return AppColors.sleepFair;
      case 4: return AppColors.sleepGood;
      case 5: return AppColors.sleepExcellent;
      default: return AppColors.textTertiary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(AppSpacing.buttonRadiusPill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(_emoji, style: const TextStyle(fontSize: 14)),
          if (showLabel) ...[
            const SizedBox(width: AppSpacing.xxs),
            Text(
              _label,
              style: AppTypography.caption.copyWith(
                color: _color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
