import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';

/// Mindfulness Activity Model
class MindfulnessActivity {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final int durationMinutes;
  final String category;

  const MindfulnessActivity({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.durationMinutes,
    required this.category,
  });
}

/// Default activities
final List<MindfulnessActivity> defaultActivities = [
  MindfulnessActivity(
    id: '1',
    title: 'Deep Breathing',
    description: 'Calm your mind with guided breathing',
    icon: Icons.air,
    color: AppColors.primary,
    durationMinutes: 5,
    category: 'Breathing',
  ),
  MindfulnessActivity(
    id: '2',
    title: 'Body Scan',
    description: 'Release tension from head to toe',
    icon: Icons.accessibility_new,
    color: AppColors.tertiary,
    durationMinutes: 10,
    category: 'Meditation',
  ),
  MindfulnessActivity(
    id: '3',
    title: 'Gratitude Journal',
    description: 'Write 3 things you\'re grateful for',
    icon: Icons.favorite,
    color: AppColors.secondary,
    durationMinutes: 5,
    category: 'Writing',
  ),
  MindfulnessActivity(
    id: '4',
    title: 'Mindful Walk',
    description: 'Take a peaceful walk outdoors',
    icon: Icons.directions_walk,
    color: AppColors.success,
    durationMinutes: 15,
    category: 'Movement',
  ),
  MindfulnessActivity(
    id: '5',
    title: 'Sleep Stories',
    description: 'Drift off with calming narratives',
    icon: Icons.bedtime,
    color: AppColors.info,
    durationMinutes: 20,
    category: 'Sleep',
  ),
  MindfulnessActivity(
    id: '6',
    title: 'Focus Timer',
    description: 'Pomodoro technique for concentration',
    icon: Icons.timer,
    color: AppColors.warning,
    durationMinutes: 25,
    category: 'Focus',
  ),
];

/// Mindfulness Activity Card
class MindfulnessActivityCard extends StatelessWidget {
  final MindfulnessActivity activity;
  final VoidCallback? onTap;
  final bool isCompact;

  const MindfulnessActivityCard({
    super.key,
    required this.activity,
    this.onTap,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isCompact) {
      return _buildCompactCard();
    }
    return _buildFullCard();
  }

  Widget _buildCompactCard() {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
      child: Container(
        width: 140,
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
          border: Border.all(color: AppColors.divider),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: activity.color.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                activity.icon,
                color: activity.color,
                size: 20,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              activity.title,
              style: AppTypography.labelMedium.copyWith(
                color: AppColors.textPrimary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: AppSpacing.xxs),
            Text(
              '${activity.durationMinutes} min',
              style: AppTypography.caption.copyWith(
                color: AppColors.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFullCard() {
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
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: activity.color.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                activity.icon,
                color: activity.color,
                size: 28,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    activity.title,
                    style: AppTypography.titleSmall.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    activity.description,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xxs,
                  ),
                  decoration: BoxDecoration(
                    color: activity.color.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(AppSpacing.buttonRadiusPill),
                  ),
                  child: Text(
                    '${activity.durationMinutes} min',
                    style: AppTypography.caption.copyWith(
                      color: activity.color,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Icon(
                  Icons.play_circle_fill,
                  color: activity.color,
                  size: 28,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Mindfulness Activities Horizontal List
class MindfulnessActivitiesList extends StatelessWidget {
  final List<MindfulnessActivity> activities;
  final Function(MindfulnessActivity)? onActivityTap;

  const MindfulnessActivitiesList({
    super.key,
    required this.activities,
    this.onActivityTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 130,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPaddingH),
        itemCount: activities.length,
        separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.md),
        itemBuilder: (context, index) {
          final activity = activities[index];
          return MindfulnessActivityCard(
            activity: activity,
            isCompact: true,
            onTap: () => onActivityTap?.call(activity),
          );
        },
      ),
    );
  }
}
