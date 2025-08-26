import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/notification_provider.dart';
import '../../core/services/notification_service.dart';

class NotificationSettingsScreen extends ConsumerStatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  ConsumerState<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends ConsumerState<NotificationSettingsScreen> {
  bool _orderUpdates = true;
  bool _newRecipes = true;
  bool _promotions = false;
  bool _reminders = true;
  String? _fcmToken;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
    _loadFcmToken();
  }

  Future<void> _loadPreferences() async {
    final preferences = ref.read(notificationProvider).preferences;
    setState(() {
      _orderUpdates = preferences['order_updates'] ?? true;
      _newRecipes = preferences['new_recipes'] ?? true;
      _promotions = preferences['promotions'] ?? false;
      _reminders = preferences['reminders'] ?? true;
    });
  }

  Future<void> _loadFcmToken() async {
    final token = await ref.read(notificationProvider.notifier).getFcmToken();
    setState(() {
      _fcmToken = token;
    });
  }

  @override
  Widget build(BuildContext context) {
    final notificationState = ref.watch(notificationProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification Settings'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(notificationProvider.notifier).refreshNotifications();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Notification Status Banner
          if (notificationState.error != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              color: Colors.red.withOpacity(0.1),
              child: Row(
                children: [
                  Icon(Icons.error, color: Colors.red),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      notificationState.error!,
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: Colors.red),
                    onPressed: () {
                      ref.read(notificationProvider.notifier).clearError();
                    },
                  ),
                ],
              ),
            ),

          // Settings List
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Notification Types Section
                _buildSectionHeader(theme, 'Notification Types'),
                const SizedBox(height: 16),

                // Order Updates
                _buildSwitchTile(
                  theme,
                  'Order Updates',
                  'Get notified about order status changes',
                  Icons.shopping_cart,
                  _orderUpdates,
                  (value) {
                    setState(() {
                      _orderUpdates = value;
                    });
                    ref.read(notificationProvider.notifier).updatePreferences(
                          orderUpdates: value,
                        );
                  },
                ),

                // New Recipes
                _buildSwitchTile(
                  theme,
                  'New Recipes',
                  'Get notified when chefs add new recipes',
                  Icons.restaurant,
                  _newRecipes,
                  (value) {
                    setState(() {
                      _newRecipes = value;
                    });
                    ref.read(notificationProvider.notifier).updatePreferences(
                          newRecipes: value,
                        );
                  },
                ),

                // Promotions
                _buildSwitchTile(
                  theme,
                  'Promotions & Offers',
                  'Get notified about special offers and discounts',
                  Icons.local_offer,
                  _promotions,
                  (value) {
                    setState(() {
                      _promotions = value;
                    });
                    ref.read(notificationProvider.notifier).updatePreferences(
                          promotions: value,
                        );
                  },
                ),

                // Reminders
                _buildSwitchTile(
                  theme,
                  'Reminders',
                  'Get reminded about your favorite recipes and orders',
                  Icons.notifications_active,
                  _reminders,
                  (value) {
                    setState(() {
                      _reminders = value;
                    });
                    ref.read(notificationProvider.notifier).updatePreferences(
                          reminders: value,
                        );
                  },
                ),

                const SizedBox(height: 24),

                // Notification Management Section
                _buildSectionHeader(theme, 'Notification Management'),
                const SizedBox(height: 16),

                // Unread Count
                _buildInfoCard(
                  theme,
                  'Unread Notifications',
                  '${notificationState.unreadCount} unread',
                  Icons.mark_email_unread,
                  Colors.orange,
                ),

                const SizedBox(height: 8),

                // Total Notifications
                _buildInfoCard(
                  theme,
                  'Total Notifications',
                  '${notificationState.notifications.length} total',
                  Icons.notifications,
                  Colors.blue,
                ),

                const SizedBox(height: 16),

                // Action Buttons
                _buildActionButton(
                  theme,
                  'Mark All as Read',
                  'Mark all notifications as read',
                  Icons.done_all,
                  notificationState.unreadCount == 0,
                  () {
                    ref.read(notificationProvider.notifier).markAllAsRead();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('All notifications marked as read')),
                    );
                  },
                ),

                const SizedBox(height: 8),

                _buildActionButton(
                  theme,
                  'Clear All Notifications',
                  'Delete all notifications',
                  Icons.clear_all,
                  notificationState.notifications.isEmpty,
                  () {
                    _showClearAllDialog(context, theme);
                  },
                ),

                const SizedBox(height: 8),

                _buildActionButton(
                  theme,
                  'Send Test Notification',
                  'Send a test notification',
                  Icons.send,
                  false,
                  () {
                    _showTestNotificationDialog(context, theme);
                  },
                ),

                const SizedBox(height: 24),

                // Technical Information Section
                _buildSectionHeader(theme, 'Technical Information'),
                const SizedBox(height: 16),

                // FCM Token
                _buildInfoCard(
                  theme,
                  'Device Token',
                  _fcmToken != null
                      ? '${_fcmToken!.substring(0, 20)}...'
                      : 'Not available',
                  Icons.device_hub,
                  Colors.green,
                  onTap: () {
                    if (_fcmToken != null) {
                      _showFcmTokenDialog(context, theme);
                    }
                  },
                ),

                const SizedBox(height: 8),

                _buildActionButton(
                  theme,
                  'Refresh Device Token',
                  'Get a new device token',
                  Icons.refresh,
                  false,
                  () async {
                    await ref
                        .read(notificationProvider.notifier)
                        .refreshFcmToken();
                    await _loadFcmToken();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Device token refreshed')),
                    );
                  },
                ),

                const SizedBox(height: 16),

                // Notification Statistics
                if (notificationState.notifications.isNotEmpty) ...[
                  _buildSectionHeader(theme, 'Recent Activity'),
                  const SizedBox(height: 16),
                  _buildNotificationStats(theme, notificationState),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(ThemeData theme, String title) {
    return Text(
      title,
      style: theme.textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.bold,
        color: Colors.grey[700],
      ),
    );
  }

  Widget _buildSwitchTile(
    ThemeData theme,
    String title,
    String subtitle,
    IconData icon,
    bool value,
    Function(bool) onChanged,
  ) {
    return Card(
      elevation: 2,
      child: SwitchListTile(
        title: Text(title),
        subtitle: Text(subtitle),
        secondary: Icon(icon, color: Colors.blue),
        value: value,
        onChanged: onChanged,
        activeColor: Colors.blue,
      ),
    );
  }

  Widget _buildInfoCard(
    ThemeData theme,
    String title,
    String subtitle,
    IconData icon,
    Color color, {
    VoidCallback? onTap,
  }) {
    return Card(
      elevation: 2,
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: onTap != null
            ? const Icon(Icons.arrow_forward_ios, size: 16)
            : null,
        onTap: onTap,
      ),
    );
  }

  Widget _buildActionButton(
    ThemeData theme,
    String title,
    String subtitle,
    IconData icon,
    bool isDisabled,
    VoidCallback onPressed,
  ) {
    return Card(
      elevation: 2,
      child: ListTile(
        leading: Icon(icon, color: isDisabled ? Colors.grey : Colors.blue),
        title: Text(
          title,
          style: TextStyle(
            color: isDisabled ? Colors.grey : null,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            color: isDisabled ? Colors.grey : null,
          ),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: isDisabled ? null : onPressed,
      ),
    );
  }

  Widget _buildNotificationStats(ThemeData theme, dynamic notificationState) {
    final recentNotifications = notificationState.notifications
        .where((n) => n.timestamp
            .isAfter(DateTime.now().subtract(const Duration(days: 7))))
        .toList();

    final typeStats = <NotificationType, int>{};
    for (final notification in recentNotifications) {
      typeStats[notification.type] = (typeStats[notification.type] ?? 0) + 1;
    }

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.analytics, color: Colors.blue),
                const SizedBox(width: 8),
                Text(
                  'Last 7 Days',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...typeStats.entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Icon(_getNotificationTypeIcon(entry.key), size: 16),
                    const SizedBox(width: 8),
                    Text(
                      _getNotificationTypeName(entry.key),
                      style: theme.textTheme.bodySmall,
                    ),
                    const Spacer(),
                    Text(
                      '${entry.value}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  IconData _getNotificationTypeIcon(NotificationType type) {
    switch (type) {
      case NotificationType.orderUpdate:
        return Icons.shopping_cart;
      case NotificationType.newRecipe:
        return Icons.restaurant;
      case NotificationType.promotion:
        return Icons.local_offer;
      case NotificationType.reminder:
        return Icons.notifications_active;
      case NotificationType.general:
        return Icons.notifications;
    }
  }

  String _getNotificationTypeName(NotificationType type) {
    switch (type) {
      case NotificationType.orderUpdate:
        return 'Order Updates';
      case NotificationType.newRecipe:
        return 'New Recipes';
      case NotificationType.promotion:
        return 'Promotions';
      case NotificationType.reminder:
        return 'Reminders';
      case NotificationType.general:
        return 'General';
    }
  }

  void _showClearAllDialog(BuildContext context, ThemeData theme) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Notifications'),
        content: const Text(
            'This will delete all notifications. This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              ref.read(notificationProvider.notifier).clearAllNotifications();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('All notifications cleared')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }

  void _showTestNotificationDialog(BuildContext context, ThemeData theme) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Send Test Notification'),
        content:
            const Text('This will send a test notification to your device.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              ref.read(notificationProvider.notifier).sendTestNotification(
                    title: 'Test Notification',
                    body: 'This is a test notification from Beaty Food app!',
                    type: NotificationType.general,
                  );
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Test notification sent')),
              );
            },
            child: const Text('Send Test'),
          ),
        ],
      ),
    );
  }

  void _showFcmTokenDialog(BuildContext context, ThemeData theme) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Device Token'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Your device token (FCM):'),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(4),
              ),
              child: SelectableText(
                _fcmToken ?? 'Not available',
                style: theme.textTheme.bodySmall,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
