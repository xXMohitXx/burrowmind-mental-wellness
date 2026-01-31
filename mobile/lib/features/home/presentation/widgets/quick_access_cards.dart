import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';

/// Quick Access Card Widget
class QuickAccessCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;
  final Widget? trailing;

  const QuickAccessCard({
    super.key,
    required this.title,
    this.subtitle,
    required this.icon,
    required this.color,
    this.onTap,
    this.trailing,
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
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.titleSmall.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      subtitle!,
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            trailing ??
                const Icon(
                  Icons.chevron_right,
                  color: AppColors.textTertiary,
                ),
          ],
        ),
      ),
    );
  }
}

/// Quick Actions Grid
class QuickActionsGrid extends StatelessWidget {
  final VoidCallback? onMoodTap;
  final VoidCallback? onSleepTap;
  final VoidCallback? onJournalTap;
  final VoidCallback? onStressTap;
  final VoidCallback? onBreatheTap;
  final VoidCallback? onChatTap;

  const QuickActionsGrid({
    super.key,
    this.onMoodTap,
    this.onSleepTap,
    this.onJournalTap,
    this.onStressTap,
    this.onBreatheTap,
    this.onChatTap,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: AppSpacing.md,
      crossAxisSpacing: AppSpacing.md,
      children: [
        _QuickActionItem(
          title: 'Mood',
          icon: Icons.mood,
          color: AppColors.moodGood,
          onTap: onMoodTap,
        ),
        _QuickActionItem(
          title: 'Sleep',
          icon: Icons.nightlight_round,
          color: AppColors.info,
          onTap: onSleepTap,
        ),
        _QuickActionItem(
          title: 'Journal',
          icon: Icons.book,
          color: AppColors.secondary,
          onTap: onJournalTap,
        ),
        _QuickActionItem(
          title: 'Stress',
          icon: Icons.water_drop,
          color: AppColors.warning,
          onTap: onStressTap,
        ),
        _QuickActionItem(
          title: 'Breathe',
          icon: Icons.air,
          color: AppColors.primary,
          onTap: onBreatheTap,
        ),
        _QuickActionItem(
          title: 'AI Chat',
          icon: Icons.chat_bubble,
          color: AppColors.tertiary,
          onTap: onChatTap,
        ),
      ],
    );
  }
}

class _QuickActionItem extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const _QuickActionItem({
    required this.title,
    required this.icon,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
          border: Border.all(color: AppColors.divider),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              title,
              style: AppTypography.labelMedium.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Daily Tip Card
class DailyTipCard extends StatelessWidget {
  final String tip;
  final String? source;
  final VoidCallback? onTap;

  const DailyTipCard({
    super.key,
    required this.tip,
    this.source,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.secondary.withValues(alpha: 0.3),
              AppColors.secondary.withValues(alpha: 0.1),
            ],
          ),
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
          border: Border.all(
            color: AppColors.secondary.withValues(alpha: 0.3),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xxs,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(AppSpacing.buttonRadiusPill),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.lightbulb,
                        size: 14,
                        color: AppColors.secondary,
                      ),
                      const SizedBox(width: AppSpacing.xxs),
                      Text(
                        'Daily Tip',
                        style: AppTypography.caption.copyWith(
                          color: AppColors.secondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                if (onTap != null)
                  const Icon(
                    Icons.share,
                    size: 18,
                    color: AppColors.textTertiary,
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              '"$tip"',
              style: AppTypography.bodyLarge.copyWith(
                color: AppColors.textPrimary,
                fontStyle: FontStyle.italic,
              ),
            ),
            if (source != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                '— $source',
                style: AppTypography.caption.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
