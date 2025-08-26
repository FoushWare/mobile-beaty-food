import 'dart:convert';
import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import '../utils/storage_service.dart';
import '../utils/api_client.dart';

enum NotificationType {
  orderUpdate,
  newRecipe,
  promotion,
  reminder,
  general,
}

class NotificationData {
  final String id;
  final String title;
  final String body;
  final NotificationType type;
  final Map<String, dynamic>? data;
  final DateTime timestamp;
  final bool isRead;

  const NotificationData({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    this.data,
    required this.timestamp,
    this.isRead = false,
  });

  factory NotificationData.fromJson(Map<String, dynamic> json) {
    return NotificationData(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      body: json['body'] ?? '',
      type: _parseNotificationType(json['type']),
      data: json['data'],
      timestamp:
          DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()),
      isRead: json['isRead'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'type': type.name,
      'data': data,
      'timestamp': timestamp.toIso8601String(),
      'isRead': isRead,
    };
  }

  static NotificationType _parseNotificationType(String? type) {
    switch (type) {
      case 'order_update':
        return NotificationType.orderUpdate;
      case 'new_recipe':
        return NotificationType.newRecipe;
      case 'promotion':
        return NotificationType.promotion;
      case 'reminder':
        return NotificationType.reminder;
      default:
        return NotificationType.general;
    }
  }

  NotificationData copyWith({
    String? id,
    String? title,
    String? body,
    NotificationType? type,
    Map<String, dynamic>? data,
    DateTime? timestamp,
    bool? isRead,
  }) {
    return NotificationData(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      type: type ?? this.type,
      data: data ?? this.data,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
    );
  }
}

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  final StorageService _storageService = StorageService();
  final ApiClient _apiClient = ApiClient();

  String? _fcmToken;
  bool _isInitialized = false;

  // Notification channels
  static const String _orderChannelId = 'order_notifications';
  static const String _recipeChannelId = 'recipe_notifications';
  static const String _promotionChannelId = 'promotion_notifications';
  static const String _generalChannelId = 'general_notifications';

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Initialize Firebase
      await Firebase.initializeApp();

      // Initialize local notifications
      await _initializeLocalNotifications();

      // Request permissions
      await _requestPermissions();

      // Get FCM token
      await _getFcmToken();

      // Set up message handlers
      await _setupMessageHandlers();

      _isInitialized = true;
    } catch (e) {
      debugPrint('Failed to initialize notification service: $e');
    }
  }

  Future<void> _initializeLocalNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _localNotifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Create notification channels for Android
    if (Platform.isAndroid) {
      await _createNotificationChannels();
    }
  }

  Future<void> _createNotificationChannels() async {
    const AndroidNotificationChannel orderChannel = AndroidNotificationChannel(
      _orderChannelId,
      'Order Updates',
      description: 'Notifications for order status updates',
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
    );

    const AndroidNotificationChannel recipeChannel = AndroidNotificationChannel(
      _recipeChannelId,
      'New Recipes',
      description: 'Notifications for new recipes and updates',
      importance: Importance.defaultImportance,
      playSound: true,
      enableVibration: true,
    );

    const AndroidNotificationChannel promotionChannel =
        AndroidNotificationChannel(
      _promotionChannelId,
      'Promotions',
      description: 'Notifications for promotions and offers',
      importance: Importance.low,
      playSound: false,
      enableVibration: false,
    );

    const AndroidNotificationChannel generalChannel =
        AndroidNotificationChannel(
      _generalChannelId,
      'General',
      description: 'General app notifications',
      importance: Importance.defaultImportance,
      playSound: true,
      enableVibration: true,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(orderChannel);

    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(recipeChannel);

    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(promotionChannel);

    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(generalChannel);
  }

  Future<void> _requestPermissions() async {
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    debugPrint('User granted permission: ${settings.authorizationStatus}');
  }

  Future<void> _getFcmToken() async {
    try {
      _fcmToken = await _firebaseMessaging.getToken();
      if (_fcmToken != null) {
        await _saveFcmToken();
        await _registerTokenWithServer();
      }
    } catch (e) {
      debugPrint('Failed to get FCM token: $e');
    }
  }

  Future<void> _saveFcmToken() async {
    if (_fcmToken != null) {
      await _storageService.setString('fcm_token', _fcmToken!);
    }
  }

  Future<void> _registerTokenWithServer() async {
    if (_fcmToken == null) return;

    try {
      final token = await _storageService.getToken();
      if (token == null) return;

      await _apiClient.dio.post(
        '/notifications/register-token',
        data: {
          'fcmToken': _fcmToken,
          'platform': Platform.isIOS ? 'ios' : 'android',
        },
      );
    } catch (e) {
      debugPrint('Failed to register FCM token with server: $e');
    }
  }

  Future<void> _setupMessageHandlers() async {
    // Handle messages when app is in foreground
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Handle messages when app is opened from notification
    FirebaseMessaging.onMessageOpenedApp.listen(_handleBackgroundMessage);

    // Handle initial message when app is opened from terminated state
    RemoteMessage? initialMessage =
        await _firebaseMessaging.getInitialMessage();
    if (initialMessage != null) {
      _handleBackgroundMessage(initialMessage);
    }
  }

  void _handleForegroundMessage(RemoteMessage message) {
    debugPrint('Got a message whilst in the foreground!');
    debugPrint('Message data: ${message.data}');

    if (message.notification != null) {
      debugPrint(
          'Message also contained a notification: ${message.notification}');
      _showLocalNotification(message);
    }
  }

  void _handleBackgroundMessage(RemoteMessage message) {
    debugPrint('Handling a background message: ${message.messageId}');
    // Navigate to appropriate screen based on message data
    _handleNotificationNavigation(message.data);
  }

  Future<void> _showLocalNotification(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;

    final channelId = _getChannelId(message.data['type']);
    final notificationData = NotificationData(
      id: message.messageId ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: notification.title ?? 'New Notification',
      body: notification.body ?? '',
      type: _parseNotificationType(message.data['type']),
      data: message.data,
      timestamp: DateTime.now(),
    );

    // Save notification locally
    await _saveNotification(notificationData);

    // Show local notification
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      _orderChannelId,
      'Order Updates',
      channelDescription: 'Notifications for order status updates',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
    );

    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await _localNotifications.show(
      notificationData.id.hashCode,
      notificationData.title,
      notificationData.body,
      platformChannelSpecifics,
      payload: jsonEncode(notificationData.toJson()),
    );
  }

  String _getChannelId(String? type) {
    switch (type) {
      case 'order_update':
        return _orderChannelId;
      case 'new_recipe':
        return _recipeChannelId;
      case 'promotion':
        return _promotionChannelId;
      default:
        return _generalChannelId;
    }
  }

  NotificationType _parseNotificationType(String? type) {
    switch (type) {
      case 'order_update':
        return NotificationType.orderUpdate;
      case 'new_recipe':
        return NotificationType.newRecipe;
      case 'promotion':
        return NotificationType.promotion;
      case 'reminder':
        return NotificationType.reminder;
      default:
        return NotificationType.general;
    }
  }

  void _onNotificationTapped(NotificationResponse response) {
    if (response.payload != null) {
      try {
        final notificationData = NotificationData.fromJson(
          jsonDecode(response.payload!),
        );
        _handleNotificationNavigation(notificationData.data ?? {});
      } catch (e) {
        debugPrint('Failed to parse notification payload: $e');
      }
    }
  }

  void _handleNotificationNavigation(Map<String, dynamic> data) {
    // This will be implemented to navigate to appropriate screens
    // based on notification type and data
    final type = data['type'];
    final id = data['id'];

    switch (type) {
      case 'order_update':
        // Navigate to order details
        break;
      case 'new_recipe':
        // Navigate to recipe details
        break;
      case 'promotion':
        // Navigate to promotions
        break;
      default:
        // Navigate to notifications screen
        break;
    }
  }

  // Local notification storage
  Future<void> _saveNotification(NotificationData notification) async {
    final notifications = await getNotifications();
    notifications.insert(0, notification);

    // Keep only last 100 notifications
    if (notifications.length > 100) {
      notifications.removeRange(100, notifications.length);
    }

    final notificationsJson = notifications.map((n) => n.toJson()).toList();
    await _storageService.setString(
        'notifications', jsonEncode(notificationsJson));
  }

  Future<List<NotificationData>> getNotifications() async {
    try {
      final notificationsJson =
          await _storageService.getString('notifications');
      if (notificationsJson == null) return [];

      final List<dynamic> decoded = jsonDecode(notificationsJson);
      return decoded.map((json) => NotificationData.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> markNotificationAsRead(String notificationId) async {
    final notifications = await getNotifications();
    final index = notifications.indexWhere((n) => n.id == notificationId);

    if (index >= 0) {
      notifications[index] = notifications[index].copyWith(isRead: true);
      final notificationsJson = notifications.map((n) => n.toJson()).toList();
      await _storageService.setString(
          'notifications', jsonEncode(notificationsJson));
    }
  }

  Future<void> markAllNotificationsAsRead() async {
    final notifications = await getNotifications();
    final updatedNotifications =
        notifications.map((n) => n.copyWith(isRead: true)).toList();

    final notificationsJson =
        updatedNotifications.map((n) => n.toJson()).toList();
    await _storageService.setString(
        'notifications', jsonEncode(notificationsJson));
  }

  Future<void> deleteNotification(String notificationId) async {
    final notifications = await getNotifications();
    notifications.removeWhere((n) => n.id == notificationId);

    final notificationsJson = notifications.map((n) => n.toJson()).toList();
    await _storageService.setString(
        'notifications', jsonEncode(notificationsJson));
  }

  Future<void> clearAllNotifications() async {
    await _storageService.remove('notifications');
  }

  Future<int> getUnreadCount() async {
    final notifications = await getNotifications();
    return notifications.where((n) => !n.isRead).length;
  }

  // Manual notification sending (for testing)
  Future<void> sendLocalNotification({
    required String title,
    required String body,
    NotificationType type = NotificationType.general,
    Map<String, dynamic>? data,
  }) async {
    final notificationData = NotificationData(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      body: body,
      type: type,
      data: data,
      timestamp: DateTime.now(),
    );

    await _saveNotification(notificationData);

    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      _generalChannelId,
      'General',
      channelDescription: 'General app notifications',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
      showWhen: true,
    );

    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await _localNotifications.show(
      notificationData.id.hashCode,
      notificationData.title,
      notificationData.body,
      platformChannelSpecifics,
      payload: jsonEncode(notificationData.toJson()),
    );
  }

  // Token management
  Future<String?> getFcmToken() async {
    return _fcmToken ?? await _storageService.getString('fcm_token');
  }

  Future<void> refreshFcmToken() async {
    await _getFcmToken();
  }

  // Notification preferences
  Future<void> updateNotificationPreferences({
    bool? orderUpdates,
    bool? newRecipes,
    bool? promotions,
    bool? reminders,
  }) async {
    final preferences = {
      'order_updates': orderUpdates,
      'new_recipes': newRecipes,
      'promotions': promotions,
      'reminders': reminders,
    };

    await _storageService.setString(
        'notification_preferences', jsonEncode(preferences));

    // Update server preferences
    try {
      final token = await _storageService.getToken();
      if (token != null) {
        await _apiClient.dio.patch(
          '/notifications/preferences',
          data: preferences,
        );
      }
    } catch (e) {
      debugPrint('Failed to update notification preferences on server: $e');
    }
  }

  Future<Map<String, bool>> getNotificationPreferences() async {
    try {
      final preferencesJson =
          await _storageService.getString('notification_preferences');
      if (preferencesJson == null) {
        return {
          'order_updates': true,
          'new_recipes': true,
          'promotions': false,
          'reminders': true,
        };
      }

      final Map<String, dynamic> decoded = jsonDecode(preferencesJson);
      return {
        'order_updates': decoded['order_updates'] ?? true,
        'new_recipes': decoded['new_recipes'] ?? true,
        'promotions': decoded['promotions'] ?? false,
        'reminders': decoded['reminders'] ?? true,
      };
    } catch (e) {
      return {
        'order_updates': true,
        'new_recipes': true,
        'promotions': false,
        'reminders': true,
      };
    }
  }
}
