import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/providers/wellness_score_provider.dart';

/// Home Screen - Main Dashboard with Reactive Wellness Score
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wellnessScore = ref.watch(wellnessScoreProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // App Bar
            SliverAppBar(
              floating: true,
              backgroundColor: AppColors.background,
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _getGreeting(),
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const Text(
                    'How are you today?',
                    style: AppTypography.titleLarge,
                  ),
                ],
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () => context.push('/search'),
                ),
                IconButton(
                  icon: const Icon(Icons.notifications_outlined),
                  onPressed: () {},
                ),
              ],
            ),

            // Content
            SliverPadding(
              padding: const EdgeInsets.all(AppSpacing.screenPaddingH),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // Mental Health Score Card
                  _buildScoreCard(wellnessScore),

                  const SizedBox(height: AppSpacing.lg),

                  // Quick Actions
                  Text(
                    'Quick Actions',
                    style: AppTypography.titleMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _buildQuickActions(context),

                  const SizedBox(height: AppSpacing.lg),

                  // Daily Trackers
                  Text(
                    'Daily Trackers',
                    style: AppTypography.titleMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _buildTrackerCards(),

                  const SizedBox(height: AppSpacing.lg),

                  // Recent Journal
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Recent Journal',
                        style: AppTypography.titleMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      TextButton(
                        onPressed: () => context.go('/journal'),
                        child: const Text('See All'),
                      ),
                    ],
                  ),
                  _buildJournalPreview(),

                  const SizedBox(height: AppSpacing.xxl),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  Widget _buildScoreCard(AsyncValue<WellnessScore> wellnessScore) {
    return wellnessScore.when(
      data: (score) => Container(
        padding: const EdgeInsets.all(AppSpacing.cardPaddingLarge),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.surface,
              Color(0xFF1E1A18),
            ],
          ),
          borderRadius: BorderRadius.circular(AppSpacing.cardRadiusLarge),
          border: Border.all(color: AppColors.divider),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Mental Wellness',
                  style: AppTypography.titleMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: _getScoreColor(score.overallScore)
                        .withValues(alpha: 0.2),
                    borderRadius:
                        BorderRadius.circular(AppSpacing.buttonRadiusPill),
                  ),
                  child: Text(
                    score.label,
                    style: AppTypography.labelSmall.copyWith(
                      color: _getScoreColor(score.overallScore),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${score.overallScore}',
                  style: AppTypography.scoreDisplay.copyWith(
                    color: _getScoreColor(score.overallScore),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    '/100',
                    style: AppTypography.titleLarge.copyWith(
                      color: AppColors.textTertiary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              score.insight,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.lg),
            // Score components
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildScoreComponent(
                    'Mood', score.moodScore, AppColors.moodGood),
                _buildScoreComponent(
                    'Sleep', score.sleepScore, AppColors.sleepGood),
                _buildScoreComponent(
                    'Activity', score.activityScore, AppColors.primary),
              ],
            ),
          ],
        ),
      ),
      loading: () => Container(
        padding: const EdgeInsets.all(AppSpacing.cardPaddingLarge),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(AppSpacing.cardRadiusLarge),
          border: Border.all(color: AppColors.divider),
        ),
        child: const Center(child: CircularProgressIndicator()),
      ),
      error: (_, __) => Container(
        padding: const EdgeInsets.all(AppSpacing.cardPaddingLarge),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(AppSpacing.cardRadiusLarge),
        ),
        child: const Text('Error loading score'),
      ),
    );
  }

  Color _getScoreColor(int score) {
    if (score >= 80) return AppColors.scoreHigh;
    if (score >= 60) return AppColors.primary;
    if (score >= 40) return AppColors.scoreMedium;
    return AppColors.scoreLow;
  }

  Widget _buildScoreComponent(String label, int score, Color color) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 48,
              height: 48,
              child: CircularProgressIndicator(
                value: score / 100,
                strokeWidth: 4,
                backgroundColor: AppColors.surface,
                color: color,
              ),
            ),
            Text(
              '$score',
              style: AppTypography.labelLarge.copyWith(
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          label,
          style: AppTypography.caption,
        ),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildQuickActionButton(
            icon: Icons.chat_bubble_outline,
            label: 'Talk to AI',
            color: AppColors.primary,
            onTap: () => context.go('/chat'),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: _buildQuickActionButton(
            icon: Icons.edit_note,
            label: 'Journal',
            color: AppColors.secondary,
            onTap: () => context.go('/journal'),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: _buildQuickActionButton(
            icon: Icons.self_improvement,
            label: 'Mindful',
            color: AppColors.tertiary,
            onTap: () {},
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: AppSpacing.sm),
            Text(
              label,
              style: AppTypography.labelMedium.copyWith(color: color),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrackerCards() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: AppSpacing.md,
      crossAxisSpacing: AppSpacing.md,
      childAspectRatio: 1.3,
      children: [
        _buildTrackerCard(
          icon: Icons.mood,
          label: 'Mood',
          value: '😊 Good',
          color: AppColors.moodGood,
        ),
        _buildTrackerCard(
          icon: Icons.nights_stay,
          label: 'Sleep',
          value: '7h 30m',
          color: AppColors.sleepGood,
        ),
        _buildTrackerCard(
          icon: Icons.psychology,
          label: 'Stress',
          value: 'Low',
          color: AppColors.stressLow,
        ),
        _buildTrackerCard(
          icon: Icons.self_improvement,
          label: 'Mindful',
          value: '15 min',
          color: AppColors.tertiary,
        ),
      ],
    );
  }

  Widget _buildTrackerCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: color),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTypography.caption,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                value,
                style: AppTypography.titleMedium.copyWith(color: color),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildJournalPreview() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
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
                  borderRadius:
                      BorderRadius.circular(AppSpacing.cardRadiusSmall),
                ),
                child: const Icon(
                  Icons.edit_note,
                  color: AppColors.secondary,
                  size: 20,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Today\'s Reflection',
                      style: AppTypography.titleSmall,
                    ),
                    Text(
                      '2 hours ago',
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right,
                color: AppColors.textTertiary,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Had a productive morning today. Feeling grateful for the small wins...',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
