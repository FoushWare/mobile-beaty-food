import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/notification_service.dart';
import '../../models/notification.dart';

// Service provider
final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

// State class for notifications
class NotificationState {
  final List<Notification> notifications;
  final NotificationPreferences preferences;
  final int unreadCount;
  final bool isLoading;
  final String? error;
  final Map<String, dynamic> stats;

  NotificationState({
    this.notifications = const [],
    NotificationPreferences? preferences,
    this.unreadCount = 0,
    this.isLoading = false,
    this.error,
    this.stats = const {},
  }) : preferences = preferences ?? NotificationPreferences();

  NotificationState copyWith({
    List<Notification>? notifications,
    NotificationPreferences? preferences,
    int? unreadCount,
    bool? isLoading,
    String? error,
    Map<String, dynamic>? stats,
  }) {
    return NotificationState(
      notifications: notifications ?? this.notifications,
      preferences: preferences ?? this.preferences,
      unreadCount: unreadCount ?? this.unreadCount,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      stats: stats ?? this.stats,
    );
  }
}

// Notification notifier
class NotificationNotifier extends StateNotifier<NotificationState> {
  final NotificationService _notificationService;

  NotificationNotifier(this._notificationService) : super(NotificationState());

  /// Load notifications
  Future<void> loadNotifications({bool? isRead, int page = 1}) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final notifications = await _notificationService.getNotifications(
        isRead: isRead,
        page: page,
      );

      state = state.copyWith(
        notifications: page == 1 ? notifications : [...state.notifications, ...notifications],
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Mark notification as read
  Future<void> markAsRead(String notificationId) async {
    try {
      await _notificationService.markAsRead(notificationId);

      // Update local state
      final updatedNotifications = state.notifications.map((notification) {
        if (notification.id == notificationId) {
          return notification.copyWith(isRead: true);
        }
        return notification;
      }).toList();

      state = state.copyWith(
        notifications: updatedNotifications,
        unreadCount: state.unreadCount > 0 ? state.unreadCount - 1 : 0,
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// Mark all notifications as read
  Future<void> markAllAsRead() async {
    try {
      await _notificationService.markAllAsRead();

      // Update local state
      final updatedNotifications = state.notifications.map((notification) {
        return notification.copyWith(isRead: true);
      }).toList();

      state = state.copyWith(
        notifications: updatedNotifications,
        unreadCount: 0,
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// Delete notification
  Future<void> deleteNotification(String notificationId) async {
    try {
      await _notificationService.deleteNotification(notificationId);

      // Remove from local state
      final updatedNotifications = state.notifications
          .where((notification) => notification.id != notificationId)
          .toList();

      // Update unread count if notification was unread
      final deletedNotification = state.notifications
          .firstWhere((notification) => notification.id == notificationId);
      final newUnreadCount = deletedNotification.isRead
          ? state.unreadCount
          : state.unreadCount > 0
              ? state.unreadCount - 1
              : 0;

      state = state.copyWith(
        notifications: updatedNotifications,
        unreadCount: newUnreadCount,
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// Load notification preferences
  Future<void> loadPreferences() async {
    try {
      final preferences = await _notificationService.getNotificationPreferences();
      state = state.copyWith(preferences: preferences);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// Update notification preferences
  Future<void> updatePreferences(NotificationPreferences preferences) async {
    try {
      final updatedPreferences = await _notificationService.updateNotificationPreferences(preferences);
      state = state.copyWith(preferences: updatedPreferences);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// Load unread count
  Future<void> loadUnreadCount() async {
    try {
      final unreadCount = await _notificationService.getUnreadCount();
      state = state.copyWith(unreadCount: unreadCount);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// Load notification statistics
  Future<void> loadStats() async {
    try {
      final stats = await _notificationService.getNotificationStats();
      state = state.copyWith(stats: stats);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// Register device for push notifications
  Future<void> registerDevice(String deviceToken) async {
    try {
      await _notificationService.registerDevice(deviceToken);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// Unregister device from push notifications
  Future<void> unregisterDevice() async {
    try {
      await _notificationService.unregisterDevice();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// Subscribe to topic
  Future<void> subscribeToTopic(String topic) async {
    try {
      await _notificationService.subscribeToTopic(topic);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// Unsubscribe from topic
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _notificationService.unsubscribeFromTopic(topic);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// Send test notification
  Future<void> sendTestNotification() async {
    try {
      await _notificationService.sendTestNotification();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }

  /// Add notification to list (for real-time updates)
  void addNotification(Notification notification) {
    final updatedNotifications = [notification, ...state.notifications];
    final newUnreadCount = notification.isRead ? state.unreadCount : state.unreadCount + 1;

    state = state.copyWith(
      notifications: updatedNotifications,
      unreadCount: newUnreadCount,
    );
  }

  /// Update notification in list
  void updateNotification(Notification notification) {
    final updatedNotifications = state.notifications.map((n) {
      if (n.id == notification.id) {
        return notification;
      }
      return n;
    }).toList();

    state = state.copyWith(notifications: updatedNotifications);
  }
}

// Provider
final notificationProvider = StateNotifierProvider<NotificationNotifier, NotificationState>((ref) {
  final notificationService = ref.watch(notificationServiceProvider);
  return NotificationNotifier(notificationService);
});

// Convenience providers
final notificationsProvider = Provider<List<Notification>>((ref) {
  return ref.watch(notificationProvider).notifications;
});

final unreadCountProvider = Provider<int>((ref) {
  return ref.watch(notificationProvider).unreadCount;
});

final notificationPreferencesProvider = Provider<NotificationPreferences>((ref) {
  return ref.watch(notificationProvider).preferences;
});

final notificationStatsProvider = Provider<Map<String, dynamic>>((ref) {
  return ref.watch(notificationProvider).stats;
});

final notificationErrorProvider = Provider<String?>((ref) {
  return ref.watch(notificationProvider).error;
});

final notificationLoadingProvider = Provider<bool>((ref) {
  return ref.watch(notificationProvider).isLoading;
});
