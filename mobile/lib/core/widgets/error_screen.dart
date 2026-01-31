import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import 'buttons.dart';

/// Error Screen - For displaying various error states
class ErrorScreen extends StatelessWidget {
  final String title;
  final String message;
  final IconData icon;
  final Color? iconColor;
  final String? buttonText;
  final VoidCallback? onButtonPressed;
  final bool showHomeButton;

  const ErrorScreen({
    super.key,
    required this.title,
    required this.message,
    this.icon = Icons.error_outline,
    this.iconColor,
    this.buttonText,
    this.onButtonPressed,
    this.showHomeButton = true,
  });

  /// No Internet Connection
  factory ErrorScreen.noInternet({VoidCallback? onRetry}) {
    return ErrorScreen(
      title: 'No Internet Connection',
      message: 'Please check your connection and try again.',
      icon: Icons.wifi_off_rounded,
      iconColor: AppColors.warning,
      buttonText: 'Try Again',
      onButtonPressed: onRetry,
    );
  }

  /// Server Error (500)
  factory ErrorScreen.serverError({VoidCallback? onRetry}) {
    return ErrorScreen(
      title: 'Server Error',
      message: 'Something went wrong on our end. Please try again later.',
      icon: Icons.cloud_off_rounded,
      iconColor: AppColors.error,
      buttonText: 'Try Again',
      onButtonPressed: onRetry,
    );
  }

  /// Not Found (404)
  factory ErrorScreen.notFound() {
    return ErrorScreen(
      title: 'Page Not Found',
      message: 'The page you\'re looking for doesn\'t exist.',
      icon: Icons.search_off_rounded,
      iconColor: AppColors.textTertiary,
    );
  }

  /// Maintenance
  factory ErrorScreen.maintenance() {
    return ErrorScreen(
      title: 'Under Maintenance',
      message: 'We\'re making some improvements. Please check back soon.',
      icon: Icons.construction_rounded,
      iconColor: AppColors.secondary,
      showHomeButton: false,
    );
  }

  /// Access Denied
  factory ErrorScreen.accessDenied() {
    return ErrorScreen(
      title: 'Access Denied',
      message: 'You don\'t have permission to view this content.',
      icon: Icons.lock_outline_rounded,
      iconColor: AppColors.error,
    );
  }

  /// Session Expired
  factory ErrorScreen.sessionExpired({VoidCallback? onLogin}) {
    return ErrorScreen(
      title: 'Session Expired',
      message: 'Your session has expired. Please sign in again.',
      icon: Icons.timer_off_rounded,
      iconColor: AppColors.warning,
      buttonText: 'Sign In',
      onButtonPressed: onLogin,
      showHomeButton: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.screenPaddingH),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              
              // Icon
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: (iconColor ?? AppColors.error).withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 56,
                  color: iconColor ?? AppColors.error,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              // Title
              Text(
                title,
                style: AppTypography.headlineMedium.copyWith(
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.md),

              // Message
              Text(
                message,
                style: AppTypography.bodyLarge.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),

              const Spacer(),

              // Action button
              if (buttonText != null && onButtonPressed != null)
                PrimaryButton(
                  text: buttonText!,
                  onPressed: onButtonPressed,
                ),
              
              if (buttonText != null && onButtonPressed != null && showHomeButton)
                const SizedBox(height: AppSpacing.md),

              // Home button
              if (showHomeButton)
                PrimaryButton(
                  text: 'Go to Home',
                  isOutlined: true,
                  onPressed: () => context.go('/home'),
                ),

              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }
}

/// Empty State Widget
class EmptyState extends StatelessWidget {
  final String title;
  final String message;
  final IconData icon;
  final String? actionText;
  final VoidCallback? onAction;

  const EmptyState({
    super.key,
    required this.title,
    required this.message,
    this.icon = Icons.inbox_outlined,
    this.actionText,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.surface,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 40,
                color: AppColors.textTertiary,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              title,
              style: AppTypography.titleLarge.copyWith(
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              message,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            if (actionText != null && onAction != null) ...[
              const SizedBox(height: AppSpacing.lg),
              PrimaryButton(
                text: actionText!,
                onPressed: onAction,
                width: 200,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
