import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/services/notification_service.dart';

class NotificationState {
  final List<NotificationData> notifications;
  final int unreadCount;
  final bool isLoading;
  final String? error;
  final Map<String, bool> preferences;

  const NotificationState({
    this.notifications = const [],
    this.unreadCount = 0,
    this.isLoading = false,
    this.error,
    this.preferences = const {},
  });

  NotificationState copyWith({
    List<NotificationData>? notifications,
    int? unreadCount,
    bool? isLoading,
    String? error,
    Map<String, bool>? preferences,
  }) {
    return NotificationState(
      notifications: notifications ?? this.notifications,
      unreadCount: unreadCount ?? this.unreadCount,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      preferences: preferences ?? this.preferences,
    );
  }
}

class NotificationNotifier extends StateNotifier<NotificationState> {
  final NotificationService _notificationService = NotificationService();

  NotificationNotifier() : super(const NotificationState()) {
    _initialize();
  }

  Future<void> _initialize() async {
    await _loadNotifications();
    await _loadPreferences();
  }

  Future<void> _loadNotifications() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final notifications = await _notificationService.getNotifications();
      final unreadCount = await _notificationService.getUnreadCount();

      state = state.copyWith(
        notifications: notifications,
        unreadCount: unreadCount,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> _loadPreferences() async {
    try {
      final preferences =
          await _notificationService.getNotificationPreferences();
      state = state.copyWith(preferences: preferences);
    } catch (e) {
      // Use default preferences if loading fails
      state = state.copyWith(
        preferences: {
          'order_updates': true,
          'new_recipes': true,
          'promotions': false,
          'reminders': true,
        },
      );
    }
  }

  Future<void> refreshNotifications() async {
    await _loadNotifications();
  }

  Future<void> markAsRead(String notificationId) async {
    try {
      await _notificationService.markNotificationAsRead(notificationId);

      // Update local state
      final updatedNotifications = state.notifications.map((notification) {
        if (notification.id == notificationId) {
          return notification.copyWith(isRead: true);
        }
        return notification;
      }).toList();

      final unreadCount = updatedNotifications.where((n) => !n.isRead).length;

      state = state.copyWith(
        notifications: updatedNotifications,
        unreadCount: unreadCount,
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> markAllAsRead() async {
    try {
      await _notificationService.markAllNotificationsAsRead();

      // Update local state
      final updatedNotifications = state.notifications
          .map((notification) => notification.copyWith(isRead: true))
          .toList();

      state = state.copyWith(
        notifications: updatedNotifications,
        unreadCount: 0,
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> deleteNotification(String notificationId) async {
    try {
      await _notificationService.deleteNotification(notificationId);

      // Update local state
      final updatedNotifications = state.notifications
          .where((notification) => notification.id != notificationId)
          .toList();

      final unreadCount = updatedNotifications.where((n) => !n.isRead).length;

      state = state.copyWith(
        notifications: updatedNotifications,
        unreadCount: unreadCount,
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> clearAllNotifications() async {
    try {
      await _notificationService.clearAllNotifications();
      state = state.copyWith(
        notifications: [],
        unreadCount: 0,
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> updatePreferences({
    bool? orderUpdates,
    bool? newRecipes,
    bool? promotions,
    bool? reminders,
  }) async {
    try {
      await _notificationService.updateNotificationPreferences(
        orderUpdates: orderUpdates,
        newRecipes: newRecipes,
        promotions: promotions,
        reminders: reminders,
      );

      // Update local state
      final updatedPreferences = Map<String, bool>.from(state.preferences);
      if (orderUpdates != null)
        updatedPreferences['order_updates'] = orderUpdates;
      if (newRecipes != null) updatedPreferences['new_recipes'] = newRecipes;
      if (promotions != null) updatedPreferences['promotions'] = promotions;
      if (reminders != null) updatedPreferences['reminders'] = reminders;

      state = state.copyWith(preferences: updatedPreferences);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> sendTestNotification({
    required String title,
    required String body,
    NotificationType type = NotificationType.general,
    Map<String, dynamic>? data,
  }) async {
    try {
      await _notificationService.sendLocalNotification(
        title: title,
        body: body,
        type: type,
        data: data,
      );

      // Refresh notifications to show the new one
      await _loadNotifications();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> initializeNotificationService() async {
    try {
      await _notificationService.initialize();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<String?> getFcmToken() async {
    return await _notificationService.getFcmToken();
  }

  Future<void> refreshFcmToken() async {
    await _notificationService.refreshFcmToken();
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  // Filter notifications by type
  List<NotificationData> getNotificationsByType(NotificationType type) {
    return state.notifications
        .where((notification) => notification.type == type)
        .toList();
  }

  // Get unread notifications
  List<NotificationData> get unreadNotifications {
    return state.notifications
        .where((notification) => !notification.isRead)
        .toList();
  }

  // Get recent notifications (last 7 days)
  List<NotificationData> get recentNotifications {
    final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));
    return state.notifications
        .where((notification) => notification.timestamp.isAfter(sevenDaysAgo))
        .toList();
  }

  // Check if a specific notification type is enabled
  bool isNotificationTypeEnabled(NotificationType type) {
    switch (type) {
      case NotificationType.orderUpdate:
        return state.preferences['order_updates'] ?? true;
      case NotificationType.newRecipe:
        return state.preferences['new_recipes'] ?? true;
      case NotificationType.promotion:
        return state.preferences['promotions'] ?? false;
      case NotificationType.reminder:
        return state.preferences['reminders'] ?? true;
      case NotificationType.general:
        return true; // General notifications are always enabled
    }
  }
}

// Provider
final notificationProvider =
    StateNotifierProvider<NotificationNotifier, NotificationState>((ref) {
  return NotificationNotifier();
});

// Convenience providers
final notificationsListProvider = Provider<List<NotificationData>>((ref) {
  return ref.watch(notificationProvider).notifications;
});

final unreadCountProvider = Provider<int>((ref) {
  return ref.watch(notificationProvider).unreadCount;
});

final notificationPreferencesProvider = Provider<Map<String, bool>>((ref) {
  return ref.watch(notificationProvider).preferences;
});

final isLoadingNotificationsProvider = Provider<bool>((ref) {
  return ref.watch(notificationProvider).isLoading;
});

final notificationErrorProvider = Provider<String?>((ref) {
  return ref.watch(notificationProvider).error;
});

// Filtered providers
final unreadNotificationsProvider = Provider<List<NotificationData>>((ref) {
  final notifier = ref.watch(notificationProvider.notifier);
  return notifier.unreadNotifications;
});

final recentNotificationsProvider = Provider<List<NotificationData>>((ref) {
  final notifier = ref.watch(notificationProvider.notifier);
  return notifier.recentNotifications;
});

// Notification type providers
final orderUpdateNotificationsProvider =
    Provider<List<NotificationData>>((ref) {
  final notifier = ref.watch(notificationProvider.notifier);
  return notifier.getNotificationsByType(NotificationType.orderUpdate);
});

final newRecipeNotificationsProvider = Provider<List<NotificationData>>((ref) {
  final notifier = ref.watch(notificationProvider.notifier);
  return notifier.getNotificationsByType(NotificationType.newRecipe);
});

final promotionNotificationsProvider = Provider<List<NotificationData>>((ref) {
  final notifier = ref.watch(notificationProvider.notifier);
  return notifier.getNotificationsByType(NotificationType.promotion);
});

final reminderNotificationsProvider = Provider<List<NotificationData>>((ref) {
  final notifier = ref.watch(notificationProvider.notifier);
  return notifier.getNotificationsByType(NotificationType.reminder);
});
