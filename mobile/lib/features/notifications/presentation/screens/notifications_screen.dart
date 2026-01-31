import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';

/// Notification Model
class AppNotification {
  final String id;
  final String title;
  final String message;
  final String type; // 'reminder', 'achievement', 'insight', 'community', 'system'
  final DateTime timestamp;
  final bool isRead;
  final String? actionRoute;

  const AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.timestamp,
    this.isRead = false,
    this.actionRoute,
  });
}

/// Mock data provider
final notificationsProvider = StateProvider<List<AppNotification>>((ref) {
  return [
    AppNotification(
      id: '1',
      title: 'Time for your evening check-in',
      message: 'How are you feeling? Log your mood to track your progress.',
      type: 'reminder',
      timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
      actionRoute: '/mood',
    ),
    AppNotification(
      id: '2',
      title: '🎉 7-Day Streak!',
      message: 'Congratulations! You\'ve journaled for 7 days in a row. Keep it up!',
      type: 'achievement',
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      isRead: true,
    ),
    AppNotification(
      id: '3',
      title: 'Weekly Insight',
      message: 'Your mood has improved 15% compared to last week. Great progress!',
      type: 'insight',
      timestamp: DateTime.now().subtract(const Duration(hours: 5)),
      actionRoute: '/mood',
    ),
    AppNotification(
      id: '4',
      title: 'Sarah M. liked your post',
      message: 'Your post in the community received a like.',
      type: 'community',
      timestamp: DateTime.now().subtract(const Duration(hours: 8)),
      isRead: true,
    ),
    AppNotification(
      id: '5',
      title: 'Bedtime Reminder',
      message: 'Wind down and prepare for a good night\'s sleep.',
      type: 'reminder',
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
      isRead: true,
    ),
  ];
});

/// Notifications Screen
class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  String _selectedFilter = 'All';

  static const _filters = ['All', 'Unread', 'Reminders', 'Insights'];

  @override
  Widget build(BuildContext context) {
    final notifications = ref.watch(notificationsProvider);
    final filtered = _filterNotifications(notifications);
    final unreadCount = notifications.where((n) => !n.isRead).length;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: const Text('Notifications'),
        actions: [
          if (unreadCount > 0)
            TextButton(
              onPressed: _markAllAsRead,
              child: Text(
                'Mark all read',
                style: AppTypography.labelMedium.copyWith(
                  color: AppColors.secondary,
                ),
              ),
            ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => _showNotificationSettings(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter chips
          SizedBox(
            height: 56,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screenPaddingH,
                vertical: AppSpacing.sm,
              ),
              itemCount: _filters.length,
              separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
              itemBuilder: (context, index) {
                final filter = _filters[index];
                final isSelected = _selectedFilter == filter;

                return InkWell(
                  onTap: () => setState(() => _selectedFilter = filter),
                  borderRadius: BorderRadius.circular(AppSpacing.buttonRadiusPill),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.secondary : AppColors.card,
                      borderRadius: BorderRadius.circular(AppSpacing.buttonRadiusPill),
                      border: isSelected
                          ? null
                          : Border.all(color: AppColors.divider),
                    ),
                    child: Text(
                      filter,
                      style: AppTypography.labelMedium.copyWith(
                        color: isSelected
                            ? AppColors.textPrimary
                            : AppColors.textSecondary,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Notifications list
          Expanded(
            child: filtered.isEmpty
                ? _buildEmptyState()
                : ListView.separated(
                    padding: const EdgeInsets.all(AppSpacing.screenPaddingH),
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
                    itemBuilder: (context, index) {
                      return _buildNotificationCard(filtered[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  List<AppNotification> _filterNotifications(List<AppNotification> notifications) {
    switch (_selectedFilter) {
      case 'Unread':
        return notifications.where((n) => !n.isRead).toList();
      case 'Reminders':
        return notifications.where((n) => n.type == 'reminder').toList();
      case 'Insights':
        return notifications.where((n) => n.type == 'insight' || n.type == 'achievement').toList();
      default:
        return notifications;
    }
  }

  Widget _buildNotificationCard(AppNotification notification) {
    return InkWell(
      onTap: () => _handleNotificationTap(notification),
      borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: notification.isRead ? AppColors.card : AppColors.card,
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
          border: Border.all(
            color: notification.isRead ? AppColors.divider : AppColors.secondary,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _getTypeColor(notification.type).withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _getTypeIcon(notification.type),
                color: _getTypeColor(notification.type),
                size: 20,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          notification.title,
                          style: AppTypography.titleSmall.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: notification.isRead
                                ? FontWeight.normal
                                : FontWeight.bold,
                          ),
                        ),
                      ),
                      if (!notification.isRead)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.secondary,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    notification.message,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    _formatTimestamp(notification.timestamp),
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_none,
            size: 64,
            color: AppColors.textTertiary,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'No notifications',
            style: AppTypography.titleMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'You\'re all caught up!',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'reminder': return AppColors.primary;
      case 'achievement': return AppColors.moodExcellent;
      case 'insight': return AppColors.tertiary;
      case 'community': return AppColors.secondary;
      case 'system': return AppColors.info;
      default: return AppColors.textSecondary;
    }
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'reminder': return Icons.notifications_active;
      case 'achievement': return Icons.emoji_events;
      case 'insight': return Icons.insights;
      case 'community': return Icons.people;
      case 'system': return Icons.settings;
      default: return Icons.notifications;
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final diff = now.difference(timestamp);

    if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    } else if (diff.inDays == 1) {
      return 'Yesterday';
    } else {
      return '${diff.inDays}d ago';
    }
  }

  void _handleNotificationTap(AppNotification notification) {
    // Mark as read and navigate if there's an action
    if (notification.actionRoute != null) {
      // Navigate to route
    }
  }

  void _markAllAsRead() {
    // Mark all as read
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('All notifications marked as read'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showNotificationSettings() {
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
              'Notification Settings',
              style: AppTypography.headlineSmall.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            _buildSettingSwitch('Mood Reminders', true),
            _buildSettingSwitch('Bedtime Reminders', true),
            _buildSettingSwitch('Weekly Insights', true),
            _buildSettingSwitch('Community Activity', false),
            _buildSettingSwitch('Achievements', true),
            const SizedBox(height: AppSpacing.lg),
            ListTile(
              leading: const Icon(Icons.schedule, color: AppColors.textSecondary),
              title: const Text('Quiet Hours'),
              subtitle: const Text('10:00 PM - 7:00 AM'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {},
            ),
            const SizedBox(height: AppSpacing.lg),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingSwitch(String title, bool value) {
    return SwitchListTile(
      title: Text(title),
      value: value,
      onChanged: (v) {},
      activeColor: AppColors.secondary,
    );
  }
}
