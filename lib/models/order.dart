import 'package:baty_bites/models/address.dart';
import 'package:baty_bites/models/recipe.dart';
import 'package:baty_bites/models/review.dart';

enum OrderStatus { pending, confirmed, preparing, ready, delivering, delivered, cancelled }
enum PaymentStatus { pending, paid, failed, refunded }
enum PaymentMethod { cash, card, wallet }

class Order {
  final String id;
  final String customerId;
  final String customerName;
  final String customerImage;
  final String chefId;
  final String chefName;
  final String chefImage;
  final String recipeId;
  final String recipeTitle;
  final String recipeImage;
  final int quantity;
  final double unitPrice;
  final double deliveryFee;
  final double totalPrice;
  final OrderStatus status;
  final Address deliveryAddress;
  final String deliveryInstructions;
  final PaymentMethod paymentMethod;
  final PaymentStatus paymentStatus;
  final double commission;
  final DateTime? estimatedDeliveryTime;
  final DateTime? actualDeliveryTime;
  final Review? customerReview;
  final Review? chefReview;
  final List<OrderStatusUpdate> statusHistory;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Order({
    required this.id,
    required this.customerId,
    required this.customerName,
    this.customerImage = '',
    required this.chefId,
    required this.chefName,
    this.chefImage = '',
    required this.recipeId,
    required this.recipeTitle,
    required this.recipeImage,
    required this.quantity,
    required this.unitPrice,
    this.deliveryFee = 0.0,
    required this.totalPrice,
    required this.status,
    required this.deliveryAddress,
    this.deliveryInstructions = '',
    required this.paymentMethod,
    this.paymentStatus = PaymentStatus.pending,
    this.commission = 0.0,
    this.estimatedDeliveryTime,
    this.actualDeliveryTime,
    this.customerReview,
    this.chefReview,
    this.statusHistory = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] ?? '',
      customerId: json['customerId'] ?? '',
      customerName: json['customerName'] ?? '',
      customerImage: json['customerImage'] ?? '',
      chefId: json['chefId'] ?? '',
      chefName: json['chefName'] ?? '',
      chefImage: json['chefImage'] ?? '',
      recipeId: json['recipeId'] ?? '',
      recipeTitle: json['recipeTitle'] ?? '',
      recipeImage: json['recipeImage'] ?? '',
      quantity: json['quantity'] ?? 1,
      unitPrice: (json['unitPrice'] ?? 0).toDouble(),
      deliveryFee: (json['deliveryFee'] ?? 0).toDouble(),
      totalPrice: (json['totalPrice'] ?? 0).toDouble(),
      status: OrderStatus.values.firstWhere(
        (s) => s.name == json['status'],
        orElse: () => OrderStatus.pending,
      ),
      deliveryAddress: Address.fromJson(json['deliveryAddress'] ?? {}),
      deliveryInstructions: json['deliveryInstructions'] ?? '',
      paymentMethod: PaymentMethod.values.firstWhere(
        (p) => p.name == json['paymentMethod'],
        orElse: () => PaymentMethod.cash,
      ),
      paymentStatus: PaymentStatus.values.firstWhere(
        (p) => p.name == json['paymentStatus'],
        orElse: () => PaymentStatus.pending,
      ),
      commission: (json['commission'] ?? 0).toDouble(),
      estimatedDeliveryTime: json['estimatedDeliveryTime'] != null
          ? DateTime.parse(json['estimatedDeliveryTime'])
          : null,
      actualDeliveryTime: json['actualDeliveryTime'] != null
          ? DateTime.parse(json['actualDeliveryTime'])
          : null,
      customerReview: json['customerReview'] != null
          ? Review.fromJson(json['customerReview'])
          : null,
      chefReview: json['chefReview'] != null
          ? Review.fromJson(json['chefReview'])
          : null,
      statusHistory: (json['statusHistory'] as List<dynamic>? ?? [])
          .map((e) => OrderStatusUpdate.fromJson(e))
          .toList(),
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customerId': customerId,
      'customerName': customerName,
      'customerImage': customerImage,
      'chefId': chefId,
      'chefName': chefName,
      'chefImage': chefImage,
      'recipeId': recipeId,
      'recipeTitle': recipeTitle,
      'recipeImage': recipeImage,
      'quantity': quantity,
      'unitPrice': unitPrice,
      'deliveryFee': deliveryFee,
      'totalPrice': totalPrice,
      'status': status.name,
      'deliveryAddress': deliveryAddress.toJson(),
      'deliveryInstructions': deliveryInstructions,
      'paymentMethod': paymentMethod.name,
      'paymentStatus': paymentStatus.name,
      'commission': commission,
      'estimatedDeliveryTime': estimatedDeliveryTime?.toIso8601String(),
      'actualDeliveryTime': actualDeliveryTime?.toIso8601String(),
      'customerReview': customerReview?.toJson(),
      'chefReview': chefReview?.toJson(),
      'statusHistory': statusHistory.map((e) => e.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  String get statusText {
    switch (status) {
      case OrderStatus.pending:
        return 'في انتظار الموافقة';
      case OrderStatus.confirmed:
        return 'مؤكد';
      case OrderStatus.preparing:
        return 'قيد التحضير';
      case OrderStatus.ready:
        return 'جاهز للتوصيل';
      case OrderStatus.delivering:
        return 'في الطريق';
      case OrderStatus.delivered:
        return 'تم التوصيل';
      case OrderStatus.cancelled:
        return 'ملغى';
    }
  }

  String get paymentMethodText {
    switch (paymentMethod) {
      case PaymentMethod.cash:
        return 'الدفع عند الاستلام';
      case PaymentMethod.card:
        return 'بطاقة ائتمان';
      case PaymentMethod.wallet:
        return 'محفظة رقمية';
    }
  }

  bool get canBeCancelled {
    return status == OrderStatus.pending || status == OrderStatus.confirmed;
  }

  bool get isCompleted {
    return status == OrderStatus.delivered;
  }

  bool get canBeReviewed {
    return isCompleted && customerReview == null;
  }

  double get subtotal => unitPrice * quantity;
}

class OrderStatusUpdate {
  final OrderStatus status;
  final String message;
  final DateTime timestamp;

  const OrderStatusUpdate({
    required this.status,
    required this.message,
    required this.timestamp,
  });

  factory OrderStatusUpdate.fromJson(Map<String, dynamic> json) {
    return OrderStatusUpdate(
      status: OrderStatus.values.firstWhere(
        (s) => s.name == json['status'],
        orElse: () => OrderStatus.pending,
      ),
      message: json['message'] ?? '',
      timestamp: DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status.name,
      'message': message,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}

class CartItem {
  final Recipe recipe;
  final int quantity;
  final String? specialInstructions;

  const CartItem({
    required this.recipe,
    this.quantity = 1,
    this.specialInstructions,
  });

  double get total => recipe.price * quantity;

  CartItem copyWith({
    Recipe? recipe,
    int? quantity,
    String? specialInstructions,
  }) {
    return CartItem(
      recipe: recipe ?? this.recipe,
      quantity: quantity ?? this.quantity,
      specialInstructions: specialInstructions ?? this.specialInstructions,
    );
  }
}