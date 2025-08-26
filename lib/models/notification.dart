enum NotificationType {
  orderUpdate,
  paymentConfirmation,
  deliveryUpdate,
  newOrder,
  reviewReceived,
  paymentReceived,
  systemAnnouncement,
  promotional,
}

class Notification {
  final String id;
  final String userId;
  final NotificationType type;
  final String title;
  final String message;
  final Map<String, dynamic>? data;
  final bool isRead;
  final DateTime createdAt;
  final DateTime? readAt;

  Notification({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.message,
    this.data,
    required this.isRead,
    required this.createdAt,
    this.readAt,
  });

  factory Notification.fromJson(Map<String, dynamic> json) {
    return Notification(
      id: json['id'],
      userId: json['userId'],
      type: NotificationType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => NotificationType.systemAnnouncement,
      ),
      title: json['title'],
      message: json['message'],
      data: json['data'],
      isRead: json['isRead'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
      readAt: json['readAt'] != null ? DateTime.parse(json['readAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'type': type.name,
      'title': title,
      'message': message,
      'data': data,
      'isRead': isRead,
      'createdAt': createdAt.toIso8601String(),
      'readAt': readAt?.toIso8601String(),
    };
  }

  Notification copyWith({
    String? id,
    String? userId,
    NotificationType? type,
    String? title,
    String? message,
    Map<String, dynamic>? data,
    bool? isRead,
    DateTime? createdAt,
    DateTime? readAt,
  }) {
    return Notification(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      title: title ?? this.title,
      message: message ?? this.message,
      data: data ?? this.data,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
      readAt: readAt ?? this.readAt,
    );
  }
}

class NotificationPreferences {
  final bool orderUpdates;
  final bool paymentConfirmations;
  final bool deliveryUpdates;
  final bool newOrders;
  final bool reviews;
  final bool payments;
  final bool systemAnnouncements;
  final bool promotional;
  final bool pushEnabled;
  final bool emailEnabled;
  final bool smsEnabled;

  NotificationPreferences({
    this.orderUpdates = true,
    this.paymentConfirmations = true,
    this.deliveryUpdates = true,
    this.newOrders = true,
    this.reviews = true,
    this.payments = true,
    this.systemAnnouncements = true,
    this.promotional = false,
    this.pushEnabled = true,
    this.emailEnabled = false,
    this.smsEnabled = false,
  });

  factory NotificationPreferences.fromJson(Map<String, dynamic> json) {
    return NotificationPreferences(
      orderUpdates: json['orderUpdates'] ?? true,
      paymentConfirmations: json['paymentConfirmations'] ?? true,
      deliveryUpdates: json['deliveryUpdates'] ?? true,
      newOrders: json['newOrders'] ?? true,
      reviews: json['reviews'] ?? true,
      payments: json['payments'] ?? true,
      systemAnnouncements: json['systemAnnouncements'] ?? true,
      promotional: json['promotional'] ?? false,
      pushEnabled: json['pushEnabled'] ?? true,
      emailEnabled: json['emailEnabled'] ?? false,
      smsEnabled: json['smsEnabled'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'orderUpdates': orderUpdates,
      'paymentConfirmations': paymentConfirmations,
      'deliveryUpdates': deliveryUpdates,
      'newOrders': newOrders,
      'reviews': reviews,
      'payments': payments,
      'systemAnnouncements': systemAnnouncements,
      'promotional': promotional,
      'pushEnabled': pushEnabled,
      'emailEnabled': emailEnabled,
      'smsEnabled': smsEnabled,
    };
  }

  NotificationPreferences copyWith({
    bool? orderUpdates,
    bool? paymentConfirmations,
    bool? deliveryUpdates,
    bool? newOrders,
    bool? reviews,
    bool? payments,
    bool? systemAnnouncements,
    bool? promotional,
    bool? pushEnabled,
    bool? emailEnabled,
    bool? smsEnabled,
  }) {
    return NotificationPreferences(
      orderUpdates: orderUpdates ?? this.orderUpdates,
      paymentConfirmations: paymentConfirmations ?? this.paymentConfirmations,
      deliveryUpdates: deliveryUpdates ?? this.deliveryUpdates,
      newOrders: newOrders ?? this.newOrders,
      reviews: reviews ?? this.reviews,
      payments: payments ?? this.payments,
      systemAnnouncements: systemAnnouncements ?? this.systemAnnouncements,
      promotional: promotional ?? this.promotional,
      pushEnabled: pushEnabled ?? this.pushEnabled,
      emailEnabled: emailEnabled ?? this.emailEnabled,
      smsEnabled: smsEnabled ?? this.smsEnabled,
    );
  }
}

class NotificationAction {
  final String id;
  final String title;
  final String action;
  final Map<String, dynamic>? data;

  NotificationAction({
    required this.id,
    required this.title,
    required this.action,
    this.data,
  });

  factory NotificationAction.fromJson(Map<String, dynamic> json) {
    return NotificationAction(
      id: json['id'],
      title: json['title'],
      action: json['action'],
      data: json['data'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'action': action,
      'data': data,
    };
  }
}

