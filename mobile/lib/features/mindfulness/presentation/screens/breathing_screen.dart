import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/buttons.dart';

/// Breathing Exercise Types
enum BreathingExercise {
  relaxation,
  focus,
  sleep,
  stress,
  energy,
}

extension BreathingExerciseExt on BreathingExercise {
  String get name {
    switch (this) {
      case BreathingExercise.relaxation: return 'Relaxation';
      case BreathingExercise.focus: return 'Focus';
      case BreathingExercise.sleep: return 'Sleep';
      case BreathingExercise.stress: return 'Stress Relief';
      case BreathingExercise.energy: return 'Energy Boost';
    }
  }

  String get description {
    switch (this) {
      case BreathingExercise.relaxation: return '4-7-8 technique for deep relaxation';
      case BreathingExercise.focus: return 'Box breathing for concentration';
      case BreathingExercise.sleep: return 'Gentle rhythm for better sleep';
      case BreathingExercise.stress: return 'Quick relief from anxiety';
      case BreathingExercise.energy: return 'Energizing breath pattern';
    }
  }

  IconData get icon {
    switch (this) {
      case BreathingExercise.relaxation: return Icons.spa;
      case BreathingExercise.focus: return Icons.center_focus_strong;
      case BreathingExercise.sleep: return Icons.nightlight_round;
      case BreathingExercise.stress: return Icons.self_improvement;
      case BreathingExercise.energy: return Icons.bolt;
    }
  }

  Color get color {
    switch (this) {
      case BreathingExercise.relaxation: return AppColors.primary;
      case BreathingExercise.focus: return AppColors.info;
      case BreathingExercise.sleep: return AppColors.tertiary;
      case BreathingExercise.stress: return AppColors.secondary;
      case BreathingExercise.energy: return AppColors.moodExcellent;
    }
  }

  // Breathing pattern: [inhale, hold, exhale, hold] in seconds
  List<int> get pattern {
    switch (this) {
      case BreathingExercise.relaxation: return [4, 7, 8, 0];
      case BreathingExercise.focus: return [4, 4, 4, 4];
      case BreathingExercise.sleep: return [4, 7, 8, 0];
      case BreathingExercise.stress: return [4, 4, 6, 0];
      case BreathingExercise.energy: return [6, 0, 2, 0];
    }
  }
}

/// Breathing Exercise Screen
class BreathingScreen extends ConsumerStatefulWidget {
  final BreathingExercise exercise;

  const BreathingScreen({
    super.key,
    required this.exercise,
  });

  @override
  ConsumerState<BreathingScreen> createState() => _BreathingScreenState();
}

class _BreathingScreenState extends ConsumerState<BreathingScreen>
    with TickerProviderStateMixin {
  late AnimationController _breathController;
  late Animation<double> _scaleAnimation;
  
  bool _isRunning = false;
  int _currentPhase = 0; // 0=inhale, 1=hold, 2=exhale, 3=hold
  int _cyclesCompleted = 0;
  int _targetCycles = 5;
  int _countdown = 0;

  static const _phases = ['Breathe In', 'Hold', 'Breathe Out', 'Hold'];

  @override
  void initState() {
    super.initState();
    _breathController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );

    _scaleAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _breathController, curve: Curves.easeInOut),
    );

    _breathController.addStatusListener(_onAnimationStatus);
  }

  @override
  void dispose() {
    _breathController.dispose();
    super.dispose();
  }

  void _onAnimationStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed || status == AnimationStatus.dismissed) {
      if (_isRunning) {
        _nextPhase();
      }
    }
  }

  void _nextPhase() {
    final pattern = widget.exercise.pattern;
    
    setState(() {
      _currentPhase = (_currentPhase + 1) % 4;
      if (_currentPhase == 0) {
        _cyclesCompleted++;
        if (_cyclesCompleted >= _targetCycles) {
          _completeExercise();
          return;
        }
      }
    });

    final duration = pattern[_currentPhase];
    if (duration == 0) {
      _nextPhase();
      return;
    }

    _countdown = duration;
    _startCountdown();

    _breathController.duration = Duration(seconds: duration);
    
    if (_currentPhase == 0) {
      // Inhale - scale up
      _breathController.forward(from: 0);
    } else if (_currentPhase == 2) {
      // Exhale - scale down
      _breathController.reverse(from: 1);
    }
    // Hold phases just wait
  }

  void _startCountdown() {
    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted || !_isRunning) return;
      setState(() => _countdown--);
      if (_countdown > 0) {
        _startCountdown();
      }
    });
  }

  void _startExercise() {
    HapticFeedback.mediumImpact();
    setState(() {
      _isRunning = true;
      _currentPhase = 0;
      _cyclesCompleted = 0;
    });
    
    final duration = widget.exercise.pattern[0];
    _countdown = duration;
    _startCountdown();
    
    _breathController.duration = Duration(seconds: duration);
    _breathController.forward(from: 0);
  }

  void _pauseExercise() {
    HapticFeedback.lightImpact();
    setState(() => _isRunning = false);
    _breathController.stop();
  }

  void _completeExercise() {
    HapticFeedback.heavyImpact();
    setState(() => _isRunning = false);
    _breathController.stop();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        ),
        title: Text(
          'Great job! 🎉',
          style: AppTypography.titleLarge.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        content: Text(
          'You completed $_targetCycles breathing cycles. How do you feel?',
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Done'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _startExercise();
            },
            child: const Text('Again'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final exercise = widget.exercise;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => _showSettings(),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.screenPaddingH),
          child: Column(
            children: [
              // Title
              Text(
                exercise.name,
                style: AppTypography.headlineMedium.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                exercise.description,
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),

              const Spacer(),

              // Breathing circle
              _buildBreathingCircle(exercise),

              const Spacer(),

              // Phase indicator
              if (_isRunning) ...[
                Text(
                  _phases[_currentPhase],
                  style: AppTypography.headlineSmall.copyWith(
                    color: exercise.color,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  '$_countdown',
                  style: AppTypography.displayLarge.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ] else ...[
                Text(
                  'Tap to begin',
                  style: AppTypography.bodyLarge.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],

              const Spacer(),

              // Progress
              if (_isRunning)
                Column(
                  children: [
                    Text(
                      'Cycle ${_cyclesCompleted + 1} of $_targetCycles',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textTertiary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    LinearProgressIndicator(
                      value: (_cyclesCompleted + 1) / _targetCycles,
                      backgroundColor: AppColors.surface,
                      color: exercise.color,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ],
                ),

              const SizedBox(height: AppSpacing.xl),

              // Control button
              if (_isRunning)
                SecondaryButton(
                  text: 'Pause',
                  onPressed: _pauseExercise,
                )
              else
                SizedBox(
                  width: double.infinity,
                  child: PrimaryButton(
                    text: _cyclesCompleted > 0 ? 'Resume' : 'Start',
                    onPressed: _startExercise,
                  ),
                ),

              const SizedBox(height: AppSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBreathingCircle(BreathingExercise exercise) {
    return GestureDetector(
      onTap: _isRunning ? _pauseExercise : _startExercise,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Container(
            width: 250,
            height: 250,
            alignment: Alignment.center,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Outer glow
                Container(
                  width: 250 * _scaleAnimation.value,
                  height: 250 * _scaleAnimation.value,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: exercise.color.withValues(alpha: 0.3),
                        blurRadius: 60,
                        spreadRadius: 20,
                      ),
                    ],
                  ),
                ),

                // Main circle
                Container(
                  width: 200 * _scaleAnimation.value,
                  height: 200 * _scaleAnimation.value,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        exercise.color.withValues(alpha: 0.8),
                        exercise.color.withValues(alpha: 0.4),
                      ],
                    ),
                    border: Border.all(
                      color: exercise.color,
                      width: 3,
                    ),
                  ),
                ),

                // Inner circle
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.background,
                    boxShadow: [
                      BoxShadow(
                        color: exercise.color.withValues(alpha: 0.5),
                        blurRadius: 20,
                      ),
                    ],
                  ),
                  child: Icon(
                    exercise.icon,
                    color: exercise.color,
                    size: 32,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showSettings() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSpacing.modalRadius),
        ),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) => Padding(
          padding: const EdgeInsets.all(AppSpacing.screenPaddingH),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.divider,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'Exercise Settings',
                style: AppTypography.headlineSmall.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'Number of Cycles',
                style: AppTypography.titleSmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [3, 5, 7, 10].map((cycles) {
                  final isSelected = _targetCycles == cycles;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: InkWell(
                        onTap: () {
                          setSheetState(() {});
                          setState(() => _targetCycles = cycles);
                        },
                        borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? widget.exercise.color
                                : AppColors.card,
                            borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
                            border: Border.all(
                              color: isSelected
                                  ? widget.exercise.color
                                  : AppColors.divider,
                            ),
                          ),
                          child: Text(
                            '$cycles',
                            style: AppTypography.titleMedium.copyWith(
                              color: isSelected
                                  ? AppColors.textPrimary
                                  : AppColors.textSecondary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'Pattern: ${widget.exercise.pattern[0]}s in, '
                '${widget.exercise.pattern[1]}s hold, '
                '${widget.exercise.pattern[2]}s out',
                style: AppTypography.caption.copyWith(
                  color: AppColors.textTertiary,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }
}

/// Mindfulness Exercises List Screen
class MindfulnessScreen extends StatelessWidget {
  const MindfulnessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: const Text('Mindfulness'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.screenPaddingH),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Stats card
            _buildStatsCard(),

            const SizedBox(height: AppSpacing.lg),

            // Breathing exercises section
            Text(
              'Breathing Exercises',
              style: AppTypography.titleMedium.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            ...BreathingExercise.values.map((exercise) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: _buildExerciseCard(context, exercise),
            )),

            const SizedBox(height: AppSpacing.lg),

            // Guided meditations
            Text(
              'Guided Meditations',
              style: AppTypography.titleMedium.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            _buildMeditationCard(
              title: '5-Minute Calm',
              duration: '5 min',
              icon: Icons.spa,
              color: AppColors.primary,
            ),
            const SizedBox(height: AppSpacing.md),
            _buildMeditationCard(
              title: 'Body Scan Relaxation',
              duration: '10 min',
              icon: Icons.accessibility_new,
              color: AppColors.tertiary,
            ),
            const SizedBox(height: AppSpacing.md),
            _buildMeditationCard(
              title: 'Sleep Stories',
              duration: '15 min',
              icon: Icons.nightlight,
              color: AppColors.info,
            ),

            const SizedBox(height: AppSpacing.xxl),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCard() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withValues(alpha: 0.3),
            AppColors.tertiary.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(AppSpacing.cardRadiusLarge),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.self_improvement,
                  color: AppColors.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Text(
                'Mindful Minutes',
                style: AppTypography.titleMedium.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStat('Today', '12 min', Icons.today),
              _buildStat('This Week', '45 min', Icons.date_range),
              _buildStat('Streak', '7 days', Icons.local_fire_department),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStat(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: AppColors.primary, size: 24),
        const SizedBox(height: AppSpacing.sm),
        Text(
          value,
          style: AppTypography.titleMedium.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        Text(
          label,
          style: AppTypography.caption.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildExerciseCard(BuildContext context, BreathingExercise exercise) {
    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => BreathingScreen(exercise: exercise),
          ),
        );
      },
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
                color: exercise.color.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                exercise.icon,
                color: exercise.color,
                size: 24,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    exercise.name,
                    style: AppTypography.titleSmall.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    exercise.description,
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.play_circle_outline,
              color: AppColors.textTertiary,
              size: 28,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMeditationCard({
    required String title,
    required String duration,
    required IconData icon,
    required Color color,
  }) {
    return Container(
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
              borderRadius: BorderRadius.circular(12),
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
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  duration,
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(AppSpacing.buttonRadiusPill),
            ),
            child: Text(
              'Play',
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
