import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';

/// Sleep Chart - Weekly bar chart visualization
class SleepChart extends StatelessWidget {
  final List<double> sleepData; // Hours of sleep
  final List<String> labels;

  const SleepChart({
    super.key,
    required this.sleepData,
    required this.labels,
  });

  Color _getSleepColor(double hours) {
    if (hours >= 7.5) return AppColors.sleepExcellent;
    if (hours >= 7.0) return AppColors.sleepGood;
    if (hours >= 6.0) return AppColors.sleepFair;
    return AppColors.sleepPoor;
  }

  @override
  Widget build(BuildContext context) {
    final maxHours = sleepData.reduce((a, b) => a > b ? a : b);
    final goal = 8.0;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        children: [
          // Goal line indicator
          Row(
            children: [
              Expanded(
                child: Stack(
                  children: [
                    // Goal line
                    Positioned(
                      left: 0,
                      right: 0,
                      top: 160 - (goal / (maxHours > goal ? maxHours : goal) * 140),
                      child: Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: 1,
                              color: AppColors.primary.withValues(alpha: 0.5),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.xs,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              '${goal}h goal',
                              style: AppTypography.caption.copyWith(
                                color: AppColors.primary,
                                fontSize: 9,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Chart
                    SizedBox(
                      height: 180,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: List.generate(sleepData.length, (index) {
                          final hours = sleepData[index];
                          final height = (hours / (maxHours > goal ? maxHours : goal)) * 140;
                          final color = _getSleepColor(hours);
                          final isToday = index == sleepData.length - 1;

                          return Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                '${hours.toStringAsFixed(1)}h',
                                style: AppTypography.caption.copyWith(
                                  color: color,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 10,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.xxs),
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 500),
                                curve: Curves.easeOutCubic,
                                width: 28,
                                height: height,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      color,
                                      color.withValues(alpha: 0.6),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(14),
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
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.md),
          const Divider(color: AppColors.divider),
          const SizedBox(height: AppSpacing.sm),

          // Stats row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStat('Avg', '${_calculateAverage().toStringAsFixed(1)}h'),
              _buildStat('Best', '${sleepData.reduce((a, b) => a > b ? a : b).toStringAsFixed(1)}h'),
              _buildStat('Worst', '${sleepData.reduce((a, b) => a < b ? a : b).toStringAsFixed(1)}h'),
            ],
          ),
        ],
      ),
    );
  }

  double _calculateAverage() {
    return sleepData.reduce((a, b) => a + b) / sleepData.length;
  }

  Widget _buildStat(String label, String value) {
    return Column(
      children: [
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
}

/// Mini Sleep Chart for dashboard
class MiniSleepChart extends StatelessWidget {
  final List<double> sleepData;

  const MiniSleepChart({
    super.key,
    required this.sleepData,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: sleepData.map((hours) {
        final color = _getColor(hours);
        return Container(
          width: 6,
          height: (hours / 10) * 30,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        );
      }).toList(),
    );
  }

  Color _getColor(double hours) {
    if (hours >= 7.5) return AppColors.sleepExcellent;
    if (hours >= 7.0) return AppColors.sleepGood;
    if (hours >= 6.0) return AppColors.sleepFair;
    return AppColors.sleepPoor;
  }
}
