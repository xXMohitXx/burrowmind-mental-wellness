import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import 'dart:math' as math;

/// Mental Health Score Provider
class MentalHealthScore {
  final int overallScore;
  final int moodScore;
  final int sleepScore;
  final int stressScore;
  final int anxietyScore;
  final int energyScore;
  final String message;
  final List<String> suggestions;
  final DateTime lastUpdated;

  const MentalHealthScore({
    required this.overallScore,
    required this.moodScore,
    required this.sleepScore,
    required this.stressScore,
    required this.anxietyScore,
    required this.energyScore,
    required this.message,
    required this.suggestions,
    required this.lastUpdated,
  });

  Color get scoreColor {
    if (overallScore >= 80) return AppColors.moodExcellent;
    if (overallScore >= 60) return AppColors.moodGood;
    if (overallScore >= 40) return AppColors.moodNeutral;
    if (overallScore >= 20) return AppColors.moodBad;
    return AppColors.moodTerrible;
  }

  String get scoreLabel {
    if (overallScore >= 80) return 'Excellent';
    if (overallScore >= 60) return 'Good';
    if (overallScore >= 40) return 'Fair';
    if (overallScore >= 20) return 'Low';
    return 'Critical';
  }
}

/// Provider for mental health score
final mentalHealthScoreProvider = StateProvider<MentalHealthScore>((ref) {
  return MentalHealthScore(
    overallScore: 72,
    moodScore: 75,
    sleepScore: 65,
    stressScore: 70,
    anxietyScore: 68,
    energyScore: 80,
    message: 'You\'re doing well! Keep up the positive habits.',
    suggestions: [
      'Try a 10-minute meditation session',
      'Take a short walk outside',
      'Practice deep breathing exercises',
    ],
    lastUpdated: DateTime.now(),
  );
});

/// Mental Health Score Ring Widget
class ScoreRing extends StatefulWidget {
  final int score;
  final double size;
  final double strokeWidth;
  final bool showLabel;
  final bool animate;

  const ScoreRing({
    super.key,
    required this.score,
    this.size = 160,
    this.strokeWidth = 12,
    this.showLabel = true,
    this.animate = true,
  });

  @override
  State<ScoreRing> createState() => _ScoreRingState();
}

class _ScoreRingState extends State<ScoreRing>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = Tween<double>(
      begin: 0,
      end: widget.score / 100,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));
    if (widget.animate) {
      _controller.forward();
    } else {
      _controller.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(ScoreRing oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.score != widget.score) {
      _animation = Tween<double>(
        begin: _animation.value,
        end: widget.score / 100,
      ).animate(CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ));
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color get _scoreColor {
    if (widget.score >= 80) return AppColors.moodExcellent;
    if (widget.score >= 60) return AppColors.moodGood;
    if (widget.score >= 40) return AppColors.moodNeutral;
    if (widget.score >= 20) return AppColors.moodBad;
    return AppColors.moodTerrible;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return SizedBox(
          width: widget.size,
          height: widget.size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Background ring
              CustomPaint(
                size: Size(widget.size, widget.size),
                painter: _RingPainter(
                  progress: 1.0,
                  color: AppColors.surface,
                  strokeWidth: widget.strokeWidth,
                ),
              ),
              // Progress ring
              CustomPaint(
                size: Size(widget.size, widget.size),
                painter: _RingPainter(
                  progress: _animation.value,
                  color: _scoreColor,
                  strokeWidth: widget.strokeWidth,
                ),
              ),
              // Score label
              if (widget.showLabel)
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${(widget.score * _animation.value / (widget.score / 100)).round()}',
                      style: AppTypography.displayMedium.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Wellness Score',
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        );
      },
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  final Color color;
  final double strokeWidth;

  _RingPainter({
    required this.progress,
    required this.color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}

/// Individual Score Card
class ScoreCard extends StatelessWidget {
  final String title;
  final int score;
  final IconData icon;
  final Color? color;

  const ScoreCard({
    super.key,
    required this.title,
    required this.score,
    required this.icon,
    this.color,
  });

  Color get _color {
    if (score >= 80) return AppColors.moodExcellent;
    if (score >= 60) return AppColors.moodGood;
    if (score >= 40) return AppColors.moodNeutral;
    if (score >= 20) return AppColors.moodBad;
    return AppColors.moodTerrible;
  }

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? _color;

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
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: effectiveColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  size: 16,
                  color: effectiveColor,
                ),
              ),
              const Spacer(),
              Text(
                '$score',
                style: AppTypography.titleLarge.copyWith(
                  color: effectiveColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            title,
            style: AppTypography.caption.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          // Mini progress bar
          LinearProgressIndicator(
            value: score / 100,
            backgroundColor: AppColors.surface,
            valueColor: AlwaysStoppedAnimation(effectiveColor),
            borderRadius: BorderRadius.circular(2),
            minHeight: 4,
          ),
        ],
      ),
    );
  }
}

/// Score History Chart
class ScoreHistoryChart extends StatelessWidget {
  final List<int> scores;
  final List<String> labels;

  const ScoreHistoryChart({
    super.key,
    required this.scores,
    required this.labels,
  });

  @override
  Widget build(BuildContext context) {
    final maxScore = scores.reduce((a, b) => a > b ? a : b);

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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Score History',
                style: AppTypography.titleMedium.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                'Last 7 days',
                style: AppTypography.caption.copyWith(
                  color: AppColors.textTertiary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          SizedBox(
            height: 120,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(scores.length, (index) {
                final score = scores[index];
                final height = (score / maxScore) * 100;
                final color = score >= 60
                    ? AppColors.moodGood
                    : score >= 40
                        ? AppColors.moodNeutral
                        : AppColors.moodBad;

                return Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      width: 24,
                      height: height,
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      labels[index],
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textTertiary,
                        fontSize: 10,
                      ),
                    ),
                  ],
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

/// AI Suggestion Card
class AISuggestionCard extends StatelessWidget {
  final String suggestion;
  final VoidCallback? onTap;

  const AISuggestionCard({
    super.key,
    required this.suggestion,
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
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primary.withValues(alpha: 0.2),
              AppColors.tertiary.withValues(alpha: 0.1),
            ],
          ),
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.auto_awesome,
                color: AppColors.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'AI Suggestion',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    suggestion,
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
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
      ),
    );
  }
}
