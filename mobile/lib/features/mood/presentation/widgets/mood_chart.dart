import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';

/// Mood Chart - Weekly bar chart visualization
class MoodChart extends StatelessWidget {
  final List<int> moodData; // 1-5 scale
  final List<String> labels;

  const MoodChart({
    super.key,
    required this.moodData,
    required this.labels,
  });

  Color _getMoodColor(int mood) {
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

  String _getMoodEmoji(int mood) {
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

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        children: [
          // Chart
          SizedBox(
            height: 160,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(moodData.length, (index) {
                final mood = moodData[index];
                final height = (mood / 5) * 120;
                final color = _getMoodColor(mood);
                final isToday = index == moodData.length - 1;

                return Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      _getMoodEmoji(mood),
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeOutCubic,
                      width: 32,
                      height: height,
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: isToday
                            ? [
                                BoxShadow(
                                  color: color.withValues(alpha: 0.5),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                            : null,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      labels[index],
                      style: AppTypography.caption.copyWith(
                        color: isToday ? AppColors.textPrimary : AppColors.textTertiary,
                        fontWeight: isToday ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ],
                );
              }),
            ),
          ),

          const SizedBox(height: AppSpacing.md),
          const Divider(color: AppColors.divider),
          const SizedBox(height: AppSpacing.sm),

          // Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildLegendItem('😢', 'Terrible'),
              _buildLegendItem('😔', 'Bad'),
              _buildLegendItem('😐', 'Okay'),
              _buildLegendItem('😊', 'Good'),
              _buildLegendItem('😄', 'Great'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String emoji, String label) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 14)),
        Text(
          label,
          style: AppTypography.caption.copyWith(
            color: AppColors.textTertiary,
            fontSize: 9,
          ),
        ),
      ],
    );
  }
}

/// Mini Mood Chart for dashboard
class MiniMoodChart extends StatelessWidget {
  final List<int> moodData;

  const MiniMoodChart({
    super.key,
    required this.moodData,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: moodData.map((mood) {
        final color = _getMoodColor(mood);
        return Container(
          width: 8,
          height: 8 + (mood * 6).toDouble(),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }).toList(),
    );
  }

  Color _getMoodColor(int mood) {
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
