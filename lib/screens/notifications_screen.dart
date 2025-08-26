import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../core/providers/notification_provider.dart';
import '../models/notification.dart' as app_notification;

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(notificationProvider.notifier).loadNotifications();
      ref.read(notificationProvider.notifier).loadUnreadCount();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final notificationState = ref.watch(notificationProvider);
    final notifications = notificationState.notifications;
    final isLoading = notificationState.isLoading;
    final error = notificationState.error;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          if (notifications.isNotEmpty)
            PopupMenuButton<String>(
              onSelected: (value) {
                switch (value) {
                  case 'mark_all_read':
                    ref.read(notificationProvider.notifier).markAllAsRead();
                    break;
                  case 'preferences':
                    _showPreferencesDialog();
                    break;
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'mark_all_read',
                  child: Row(
                    children: [
                      Icon(Icons.mark_email_read),
                      SizedBox(width: 8),
                      Text('Mark all as read'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'preferences',
                  child: Row(
                    children: [
                      Icon(Icons.settings),
                      SizedBox(width: 8),
                      Text('Preferences'),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
      body: Column(
        children: [
          // Filter tabs
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: _buildFilterChip('All', null, notifications.length),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildFilterChip(
                    'Unread',
                    false,
                    notifications.where((n) => !n.isRead).length,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildFilterChip(
                    'Read',
                    true,
                    notifications.where((n) => n.isRead).length,
                  ),
                ),
              ],
            ),
          ),
          // Notifications list
          Expanded(
            child: _buildNotificationsList(notifications, isLoading, error),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, bool? isRead, int count) {
    return FilterChip(
      label: Text('$label ($count)'),
      selected: false,
      onSelected: (selected) {
        ref.read(notificationProvider.notifier).loadNotifications(isRead: isRead);
      },
      backgroundColor: Colors.grey[200],
      selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
    );
  }

  Widget _buildNotificationsList(List<app_notification.Notification> notifications, bool isLoading, String? error) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to load notifications',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                ref.read(notificationProvider.notifier).clearError();
                ref.read(notificationProvider.notifier).loadNotifications();
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (notifications.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.notifications_none,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No notifications yet',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'You\'ll see notifications about your orders, payments, and updates here.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(notificationProvider.notifier).loadNotifications();
      },
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final notification = notifications[index];
          return _buildNotificationCard(notification);
        },
      ),
    );
  }

  Widget _buildNotificationCard(app_notification.Notification notification) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getNotificationColor(notification.type),
          child: Icon(
            _getNotificationIcon(notification.type),
            color: Colors.white,
            size: 20,
          ),
        ),
        title: Text(
          notification.title,
          style: TextStyle(
            fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              notification.message,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              _formatDateTime(notification.createdAt),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case 'mark_read':
                if (!notification.isRead) {
                  ref.read(notificationProvider.notifier).markAsRead(notification.id);
                }
                break;
              case 'delete':
                _showDeleteDialog(notification);
                break;
            }
          },
          itemBuilder: (context) => [
            if (!notification.isRead)
              const PopupMenuItem(
                value: 'mark_read',
                child: Row(
                  children: [
                    Icon(Icons.mark_email_read),
                    SizedBox(width: 8),
                    Text('Mark as read'),
                  ],
                ),
              ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Delete', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
        ),
        onTap: () {
          if (!notification.isRead) {
            ref.read(notificationProvider.notifier).markAsRead(notification.id);
          }
          _handleNotificationTap(notification);
        },
      ),
    );
  }

  Color _getNotificationColor(app_notification.NotificationType type) {
    switch (type) {
      case app_notification.NotificationType.orderUpdate:
        return Colors.blue;
      case app_notification.NotificationType.paymentConfirmation:
        return Colors.green;
      case app_notification.NotificationType.deliveryUpdate:
        return Colors.orange;
      case app_notification.NotificationType.newOrder:
        return Colors.purple;
      case app_notification.NotificationType.reviewReceived:
        return Colors.amber;
      case app_notification.NotificationType.paymentReceived:
        return Colors.teal;
      case app_notification.NotificationType.systemAnnouncement:
        return Colors.grey;
      case app_notification.NotificationType.promotional:
        return Colors.pink;
    }
  }

  IconData _getNotificationIcon(app_notification.NotificationType type) {
    switch (type) {
      case app_notification.NotificationType.orderUpdate:
        return Icons.shopping_bag;
      case app_notification.NotificationType.paymentConfirmation:
        return Icons.payment;
      case app_notification.NotificationType.deliveryUpdate:
        return Icons.local_shipping;
      case app_notification.NotificationType.newOrder:
        return Icons.add_shopping_cart;
      case app_notification.NotificationType.reviewReceived:
        return Icons.star;
      case app_notification.NotificationType.paymentReceived:
        return Icons.account_balance_wallet;
      case app_notification.NotificationType.systemAnnouncement:
        return Icons.announcement;
      case app_notification.NotificationType.promotional:
        return Icons.local_offer;
    }
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
    } else {
      return 'Just now';
    }
  }

  void _handleNotificationTap(app_notification.Notification notification) {
    // Handle navigation based on notification type and data
    switch (notification.type) {
      case app_notification.NotificationType.orderUpdate:
      case app_notification.NotificationType.newOrder:
        if (notification.data?['orderId'] != null) {
          context.push('/orders/${notification.data!['orderId']}');
        }
        break;
      case app_notification.NotificationType.paymentConfirmation:
      case app_notification.NotificationType.paymentReceived:
        if (notification.data?['paymentId'] != null) {
          context.push('/payments/${notification.data!['paymentId']}');
        }
        break;
      case app_notification.NotificationType.reviewReceived:
        if (notification.data?['recipeId'] != null) {
          context.push('/recipes/${notification.data!['recipeId']}');
        }
        break;
      default:
        // For other types, just mark as read
        break;
    }
  }

  void _showDeleteDialog(app_notification.Notification notification) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Notification'),
        content: Text('Are you sure you want to delete "${notification.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              ref.read(notificationProvider.notifier).deleteNotification(notification.id);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showPreferencesDialog() {
    final preferences = ref.read(notificationPreferencesProvider);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Notification Preferences'),
        content: SizedBox(
          width: double.maxFinite,
          child: StatefulBuilder(
            builder: (context, setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildPreferenceSwitch(
                    'Order Updates',
                    preferences.orderUpdates,
                    (value) => setState(() {}),
                  ),
                  _buildPreferenceSwitch(
                    'Payment Confirmations',
                    preferences.paymentConfirmations,
                    (value) => setState(() {}),
                  ),
                  _buildPreferenceSwitch(
                    'Delivery Updates',
                    preferences.deliveryUpdates,
                    (value) => setState(() {}),
                  ),
                  _buildPreferenceSwitch(
                    'New Orders',
                    preferences.newOrders,
                    (value) => setState(() {}),
                  ),
                  _buildPreferenceSwitch(
                    'Reviews',
                    preferences.reviews,
                    (value) => setState(() {}),
                  ),
                  _buildPreferenceSwitch(
                    'System Announcements',
                    preferences.systemAnnouncements,
                    (value) => setState(() {}),
                  ),
                  _buildPreferenceSwitch(
                    'Promotional',
                    preferences.promotional,
                    (value) => setState(() {}),
                  ),
                ],
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: Update preferences
              Navigator.of(context).pop();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Widget _buildPreferenceSwitch(String title, bool value, ValueChanged<bool> onChanged) {
    return SwitchListTile(
      title: Text(title),
      value: value,
      onChanged: onChanged,
      contentPadding: EdgeInsets.zero,
    );
  }
}
