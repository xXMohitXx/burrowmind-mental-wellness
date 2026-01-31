import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/buttons.dart';

/// Welcome Screen - First screen after splash
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.surface,
              AppColors.background,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.screenPaddingH),
            child: Column(
              children: [
                const Spacer(flex: 1),
                
                // Illustration placeholder
                Container(
                  width: 280,
                  height: 280,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppSpacing.cardRadiusLarge),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.self_improvement,
                          size: 56,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      Text(
                        '🧘',
                        style: AppTypography.displayMedium,
                      ),
                    ],
                  ),
                ),
                
                const Spacer(flex: 1),
                
                // Title and description
                Text(
                  'Welcome to BurrowMind',
                  style: AppTypography.headlineMedium.copyWith(
                    color: AppColors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Your personal companion for mental wellness, reflection, and self-awareness.',
                  style: AppTypography.bodyLarge.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const Spacer(flex: 2),
                
                // Buttons
                PrimaryButton(
                  text: 'Get Started',
                  onPressed: () => context.go('/sign-up'),
                ),
                const SizedBox(height: AppSpacing.md),
                PrimaryButton(
                  text: 'I already have an account',
                  isOutlined: true,
                  onPressed: () => context.go('/sign-in'),
                ),
                
                const SizedBox(height: AppSpacing.xl),
                
                // Privacy notice
                Text(
                  'By continuing, you agree to our Terms of Service\nand Privacy Policy',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textTertiary,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: AppSpacing.lg),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
