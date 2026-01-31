import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/buttons.dart';

/// Profile Screen
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => _showSettings(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.screenPaddingH),
        child: Column(
          children: [
            // Profile header
            _buildProfileHeader(),

            const SizedBox(height: AppSpacing.lg),

            // Stats overview
            _buildStatsCard(),

            const SizedBox(height: AppSpacing.lg),

            // Menu sections
            _buildMenuSection(context, 'Account', [
              _MenuItem(Icons.person_outline, 'Edit Profile', () {}),
              _MenuItem(Icons.lock_outline, 'Privacy & Security', () {}),
              _MenuItem(Icons.notifications_outlined, 'Notification Settings', () => context.push('/notifications')),
            ]),

            const SizedBox(height: AppSpacing.md),

            _buildMenuSection(context, 'Preferences', [
              _MenuItem(Icons.palette_outlined, 'Appearance', () {}),
              _MenuItem(Icons.language, 'Language', () {}),
              _MenuItem(Icons.access_time, 'Reminders', () {}),
            ]),

            const SizedBox(height: AppSpacing.md),

            _buildMenuSection(context, 'Data & Backup', [
              _MenuItem(Icons.download_outlined, 'Export My Data', () {}),
              _MenuItem(Icons.cloud_sync, 'Sync Settings', () {}),
            ]),

            const SizedBox(height: AppSpacing.md),

            _buildMenuSection(context, 'Support', [
              _MenuItem(Icons.help_outline, 'Help Center', () => _showHelpCenter(context)),
              _MenuItem(Icons.feedback_outlined, 'Send Feedback', () {}),
              _MenuItem(Icons.info_outline, 'About', () => _showAbout(context)),
            ]),

            const SizedBox(height: AppSpacing.lg),

            // Sign out button
            SizedBox(
              width: double.infinity,
              child: SecondaryButton(
                text: 'Sign Out',
                icon: Icons.logout,
                onPressed: () => _showSignOutConfirmation(context),
              ),
            ),

            const SizedBox(height: AppSpacing.md),

            // Version
            Text(
              'BurrowMind v1.0.0',
              style: AppTypography.caption.copyWith(
                color: AppColors.textTertiary,
              ),
            ),

            const SizedBox(height: AppSpacing.xxl),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: AppColors.primary.withValues(alpha: 0.2),
              child: Text(
                'M',
                style: AppTypography.displaySmall.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppColors.secondary,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.background, width: 2),
              ),
              child: const Icon(
                Icons.edit,
                size: 16,
                color: Colors.white,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          'Mohit',
          style: AppTypography.headlineSmall.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppSpacing.xxs),
        Text(
          'Member since Jan 2026',
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.textTertiary,
          ),
        ),
      ],
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
            AppColors.primary.withValues(alpha: 0.2),
            AppColors.secondary.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(AppSpacing.cardRadiusLarge),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStat('Days Active', '42'),
          _buildStatDivider(),
          _buildStat('Journal Entries', '28'),
          _buildStatDivider(),
          _buildStat('Mindful Min', '156'),
        ],
      ),
    );
  }

  Widget _buildStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: AppTypography.headlineSmall.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppSpacing.xxs),
        Text(
          label,
          style: AppTypography.caption.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildStatDivider() {
    return Container(
      width: 1,
      height: 40,
      color: AppColors.divider,
    );
  }

  Widget _buildMenuSection(BuildContext context, String title, List<_MenuItem> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: AppSpacing.sm, bottom: AppSpacing.sm),
          child: Text(
            title,
            style: AppTypography.labelMedium.copyWith(
              color: AppColors.textTertiary,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
            border: Border.all(color: AppColors.divider),
          ),
          child: Column(
            children: items.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              final isLast = index == items.length - 1;

              return Column(
                children: [
                  ListTile(
                    leading: Icon(item.icon, color: AppColors.textSecondary),
                    title: Text(
                      item.title,
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                    trailing: const Icon(
                      Icons.chevron_right,
                      color: AppColors.textTertiary,
                    ),
                    onTap: item.onTap,
                  ),
                  if (!isLast)
                    const Divider(
                      height: 1,
                      indent: 56,
                      color: AppColors.divider,
                    ),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  void _showSettings(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSpacing.modalRadius),
        ),
      ),
      builder: (context) => Padding(
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
              'Settings',
              style: AppTypography.headlineSmall.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            SwitchListTile(
              title: const Text('Dark Mode'),
              subtitle: const Text('Use dark theme'),
              value: true,
              onChanged: (v) {},
              activeColor: AppColors.secondary,
            ),
            SwitchListTile(
              title: const Text('Haptic Feedback'),
              subtitle: const Text('Vibrations on interactions'),
              value: true,
              onChanged: (v) {},
              activeColor: AppColors.secondary,
            ),
            SwitchListTile(
              title: const Text('Biometric Lock'),
              subtitle: const Text('Require fingerprint to open'),
              value: false,
              onChanged: (v) {},
              activeColor: AppColors.secondary,
            ),
            const SizedBox(height: AppSpacing.lg),
          ],
        ),
      ),
    );
  }

  void _showHelpCenter(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const HelpCenterScreen(),
      ),
    );
  }

  void _showAbout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.psychology,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Text(
              'BurrowMind',
              style: AppTypography.titleLarge.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Version 1.0.0',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Your AI-powered mental wellness companion. Track your mood, journal your thoughts, and practice mindfulness with personalized guidance.',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textTertiary,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              '© 2026 BurrowMind',
              style: AppTypography.caption.copyWith(
                color: AppColors.textTertiary,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showSignOutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        ),
        title: Text(
          'Sign Out?',
          style: AppTypography.titleLarge.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        content: Text(
          'Are you sure you want to sign out? Your data will remain safe and synced.',
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.go('/sign-in');
            },
            child: Text(
              'Sign Out',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuItem {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  _MenuItem(this.icon, this.title, this.onTap);
}

/// Help Center Screen
class HelpCenterScreen extends StatelessWidget {
  const HelpCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: const Text('Help Center'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.screenPaddingH),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search
            TextField(
              decoration: InputDecoration(
                hintText: 'Search for help...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: AppColors.inputBackground,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.lg),

            // Quick actions
            Text(
              'Quick Actions',
              style: AppTypography.titleMedium.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            Row(
              children: [
                Expanded(
                  child: _buildQuickAction(
                    Icons.chat_bubble_outline,
                    'Chat Support',
                    AppColors.primary,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: _buildQuickAction(
                    Icons.email_outlined,
                    'Email Us',
                    AppColors.secondary,
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.lg),

            // FAQ sections
            Text(
              'Frequently Asked Questions',
              style: AppTypography.titleMedium.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            _buildFaqCard('Getting Started', [
              'How do I track my mood?',
              'What is the Freud Score?',
              'How does AI chat work?',
            ]),

            const SizedBox(height: AppSpacing.md),

            _buildFaqCard('Account & Privacy', [
              'How is my data protected?',
              'Can I export my data?',
              'How do I delete my account?',
            ]),

            const SizedBox(height: AppSpacing.md),

            _buildFaqCard('Features', [
              'How do breathing exercises work?',
              'What are mindful activities?',
              'How do I use the journal?',
            ]),

            const SizedBox(height: AppSpacing.xxl),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAction(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: AppSpacing.sm),
          Text(
            label,
            style: AppTypography.labelMedium.copyWith(
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFaqCard(String title, List<String> questions) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        border: Border.all(color: AppColors.divider),
      ),
      child: ExpansionTile(
        title: Text(
          title,
          style: AppTypography.titleSmall.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        children: questions.map((q) => ListTile(
          title: Text(
            q,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          trailing: const Icon(
            Icons.chevron_right,
            color: AppColors.textTertiary,
          ),
          onTap: () {},
        )).toList(),
      ),
    );
  }
}
