enum OrderStatus {
  pending,
  confirmed,
  preparing,
  ready,
  out_for_delivery,
  delivered,
  cancelled,
  refunded,
}

enum PaymentStatus {
  pending,
  paid,
  failed,
  refunded,
  partially_refunded,
}

enum PaymentMethod {
  cash,
  card,
  wallet,
  bank_transfer,
}

class OrderItem {
  final String id;
  final String orderId;
  final String recipeId;
  final String recipeTitle;
  final String? recipeImage;
  final int quantity;
  final double unitPrice;
  final double totalPrice;
  final String? specialInstructions;
  final DateTime createdAt;

  OrderItem({
    required this.id,
    required this.orderId,
    required this.recipeId,
    required this.recipeTitle,
    this.recipeImage,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
    this.specialInstructions,
    required this.createdAt,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id'],
      orderId: json['orderId'],
      recipeId: json['recipeId'],
      recipeTitle: json['recipeTitle'],
      recipeImage: json['recipeImage'],
      quantity: json['quantity'],
      unitPrice: (json['unitPrice'] as num).toDouble(),
      totalPrice: (json['totalPrice'] as num).toDouble(),
      specialInstructions: json['specialInstructions'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'orderId': orderId,
      'recipeId': recipeId,
      'recipeTitle': recipeTitle,
      'recipeImage': recipeImage,
      'quantity': quantity,
      'unitPrice': unitPrice,
      'totalPrice': totalPrice,
      'specialInstructions': specialInstructions,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  OrderItem copyWith({
    String? id,
    String? orderId,
    String? recipeId,
    String? recipeTitle,
    String? recipeImage,
    int? quantity,
    double? unitPrice,
    double? totalPrice,
    String? specialInstructions,
    DateTime? createdAt,
  }) {
    return OrderItem(
      id: id ?? this.id,
      orderId: orderId ?? this.orderId,
      recipeId: recipeId ?? this.recipeId,
      recipeTitle: recipeTitle ?? this.recipeTitle,
      recipeImage: recipeImage ?? this.recipeImage,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      totalPrice: totalPrice ?? this.totalPrice,
      specialInstructions: specialInstructions ?? this.specialInstructions,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class User {
  final String id;
  final String fullName;
  final String phone;
  final String? email;

  User({
    required this.id,
    required this.fullName,
    required this.phone,
    this.email,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      fullName: json['fullName'],
      phone: json['phone'],
      email: json['email'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'phone': phone,
      'email': email,
    };
  }
}

class Order {
  final String id;
  final String customerId;
  final String chefId;
  final List<OrderItem> items;
  final double subtotal;
  final double deliveryFee;
  final double serviceFee;
  final double totalAmount;
  final String currency;
  final String status;
  final String paymentStatus;
  final String? paymentMethod;
  final String deliveryAddress;
  final String? deliveryInstructions;
  final DateTime? estimatedDeliveryTime;
  final DateTime? actualDeliveryTime;
  final double commission;
  final DateTime createdAt;
  final DateTime updatedAt;
  final User customer;
  final User chef;

  Order({
    required this.id,
    required this.customerId,
    required this.chefId,
    required this.items,
    required this.subtotal,
    required this.deliveryFee,
    required this.serviceFee,
    required this.totalAmount,
    required this.currency,
    required this.status,
    required this.paymentStatus,
    this.paymentMethod,
    required this.deliveryAddress,
    this.deliveryInstructions,
    this.estimatedDeliveryTime,
    this.actualDeliveryTime,
    required this.commission,
    required this.createdAt,
    required this.updatedAt,
    required this.customer,
    required this.chef,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'],
      customerId: json['customerId'],
      chefId: json['chefId'],
      items: (json['items'] as List)
          .map((item) => OrderItem.fromJson(item))
          .toList(),
      subtotal: (json['subtotal'] as num).toDouble(),
      deliveryFee: (json['deliveryFee'] as num).toDouble(),
      serviceFee: (json['serviceFee'] as num).toDouble(),
      totalAmount: (json['totalAmount'] as num).toDouble(),
      currency: json['currency'],
      status: json['status'],
      paymentStatus: json['paymentStatus'],
      paymentMethod: json['paymentMethod'],
      deliveryAddress: json['deliveryAddress'],
      deliveryInstructions: json['deliveryInstructions'],
      estimatedDeliveryTime: json['estimatedDeliveryTime'] != null
          ? DateTime.parse(json['estimatedDeliveryTime'])
          : null,
      actualDeliveryTime: json['actualDeliveryTime'] != null
          ? DateTime.parse(json['actualDeliveryTime'])
          : null,
      commission: (json['commission'] as num).toDouble(),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      customer: User.fromJson(json['customer']),
      chef: User.fromJson(json['chef']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customerId': customerId,
      'chefId': chefId,
      'items': items.map((item) => item.toJson()).toList(),
      'subtotal': subtotal,
      'deliveryFee': deliveryFee,
      'serviceFee': serviceFee,
      'totalAmount': totalAmount,
      'currency': currency,
      'status': status,
      'paymentStatus': paymentStatus,
      'paymentMethod': paymentMethod,
      'deliveryAddress': deliveryAddress,
      'deliveryInstructions': deliveryInstructions,
      'estimatedDeliveryTime': estimatedDeliveryTime?.toIso8601String(),
      'actualDeliveryTime': actualDeliveryTime?.toIso8601String(),
      'commission': commission,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'customer': customer.toJson(),
      'chef': chef.toJson(),
    };
  }

  Order copyWith({
    String? id,
    String? customerId,
    String? chefId,
    List<OrderItem>? items,
    double? subtotal,
    double? deliveryFee,
    double? serviceFee,
    double? totalAmount,
    String? currency,
    String? status,
    String? paymentStatus,
    String? paymentMethod,
    String? deliveryAddress,
    String? deliveryInstructions,
    DateTime? estimatedDeliveryTime,
    DateTime? actualDeliveryTime,
    double? commission,
    DateTime? createdAt,
    DateTime? updatedAt,
    User? customer,
    User? chef,
  }) {
    return Order(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      chefId: chefId ?? this.chefId,
      items: items ?? this.items,
      subtotal: subtotal ?? this.subtotal,
      deliveryFee: deliveryFee ?? this.deliveryFee,
      serviceFee: serviceFee ?? this.serviceFee,
      totalAmount: totalAmount ?? this.totalAmount,
      currency: currency ?? this.currency,
      status: status ?? this.status,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      deliveryInstructions: deliveryInstructions ?? this.deliveryInstructions,
      estimatedDeliveryTime:
          estimatedDeliveryTime ?? this.estimatedDeliveryTime,
      actualDeliveryTime: actualDeliveryTime ?? this.actualDeliveryTime,
      commission: commission ?? this.commission,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      customer: customer ?? this.customer,
      chef: chef ?? this.chef,
    );
  }

  String get statusText {
    switch (status) {
      case 'pending':
        return 'في الانتظار';
      case 'confirmed':
        return 'مؤكد';
      case 'preparing':
        return 'قيد التحضير';
      case 'ready':
        return 'جاهز';
      case 'out_for_delivery':
        return 'في الطريق';
      case 'delivered':
        return 'تم التوصيل';
      case 'cancelled':
        return 'ملغي';
      case 'refunded':
        return 'مسترد';
      default:
        return status;
    }
  }

  String get paymentStatusText {
    switch (paymentStatus) {
      case 'pending':
        return 'في الانتظار';
      case 'paid':
        return 'مدفوع';
      case 'failed':
        return 'فشل';
      case 'refunded':
        return 'مسترد';
      case 'partially_refunded':
        return 'مسترد جزئياً';
      default:
        return paymentStatus;
    }
  }

  bool get isActive => status != 'delivered' && status != 'cancelled';
  bool get canCancel => status == 'pending' || status == 'confirmed';
}
