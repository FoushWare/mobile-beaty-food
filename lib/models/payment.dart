enum PaymentMethodType {
  cash,
  card,
  wallet,
  bankTransfer,
}

enum PaymentStatus {
  pending,
  processing,
  completed,
  failed,
  cancelled,
  refunded,
  partiallyRefunded,
}

class PaymentMethod {
  final String id;
  final String name;
  final PaymentMethodType type;
  final String? icon;
  final bool isEnabled;
  final Map<String, dynamic>? metadata;

  const PaymentMethod({
    required this.id,
    required this.name,
    required this.type,
    this.icon,
    this.isEnabled = true,
    this.metadata,
  });

  factory PaymentMethod.fromJson(Map<String, dynamic> json) {
    return PaymentMethod(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      type: PaymentMethodType.values.firstWhere(
        (type) => type.name == json['type'],
        orElse: () => PaymentMethodType.cash,
      ),
      icon: json['icon'],
      isEnabled: json['isEnabled'] ?? true,
      metadata: json['metadata'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type.name,
      'icon': icon,
      'isEnabled': isEnabled,
      'metadata': metadata,
    };
  }
}

class Payment {
  final String id;
  final String orderId;
  final double amount;
  final String currency;
  final PaymentMethodType method;
  final PaymentStatus status;
  final String? transactionId;
  final String? failureReason;
  final DateTime createdAt;
  final DateTime? completedAt;
  final Map<String, dynamic>? metadata;

  const Payment({
    required this.id,
    required this.orderId,
    required this.amount,
    required this.currency,
    required this.method,
    required this.status,
    this.transactionId,
    this.failureReason,
    required this.createdAt,
    this.completedAt,
    this.metadata,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: json['id'] ?? '',
      orderId: json['orderId'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      currency: json['currency'] ?? 'EGP',
      method: PaymentMethodType.values.firstWhere(
        (type) => type.name == json['method'],
        orElse: () => PaymentMethodType.cash,
      ),
      status: PaymentStatus.values.firstWhere(
        (status) => status.name == json['status'],
        orElse: () => PaymentStatus.pending,
      ),
      transactionId: json['transactionId'],
      failureReason: json['failureReason'],
      createdAt:
          DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'])
          : null,
      metadata: json['metadata'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'orderId': orderId,
      'amount': amount,
      'currency': currency,
      'method': method.name,
      'status': status.name,
      'transactionId': transactionId,
      'failureReason': failureReason,
      'createdAt': createdAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'metadata': metadata,
    };
  }

  Payment copyWith({
    String? id,
    String? orderId,
    double? amount,
    String? currency,
    PaymentMethodType? method,
    PaymentStatus? status,
    String? transactionId,
    String? failureReason,
    DateTime? createdAt,
    DateTime? completedAt,
    Map<String, dynamic>? metadata,
  }) {
    return Payment(
      id: id ?? this.id,
      orderId: orderId ?? this.orderId,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      method: method ?? this.method,
      status: status ?? this.status,
      transactionId: transactionId ?? this.transactionId,
      failureReason: failureReason ?? this.failureReason,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
      metadata: metadata ?? this.metadata,
    );
  }
}

class PaymentRequest {
  final String orderId;
  final double amount;
  final String currency;
  final PaymentMethodType method;
  final Map<String, dynamic>? metadata;

  const PaymentRequest({
    required this.orderId,
    required this.amount,
    required this.currency,
    required this.method,
    this.metadata,
  });

  Map<String, dynamic> toJson() {
    return {
      'orderId': orderId,
      'amount': amount,
      'currency': currency,
      'method': method.name,
      'metadata': metadata,
    };
  }
}

class PaymentResponse {
  final bool success;
  final String? paymentId;
  final String? transactionId;
  final String? message;
  final PaymentStatus? status;
  final Map<String, dynamic>? data;

  const PaymentResponse({
    required this.success,
    this.paymentId,
    this.transactionId,
    this.message,
    this.status,
    this.data,
  });

  factory PaymentResponse.fromJson(Map<String, dynamic> json) {
    return PaymentResponse(
      success: json['success'] ?? false,
      paymentId: json['paymentId'],
      transactionId: json['transactionId'],
      message: json['message'],
      status: json['status'] != null
          ? PaymentStatus.values.firstWhere(
              (status) => status.name == json['status'],
              orElse: () => PaymentStatus.pending,
            )
          : null,
      data: json['data'],
    );
  }
}
