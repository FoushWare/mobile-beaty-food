import 'package:dio/dio.dart';
import '../../models/order.dart';
import '../utils/api_client.dart';
import '../utils/storage_service.dart';

class OrderService {
  final ApiClient _apiClient = ApiClient();
  final StorageService _storageService = StorageService();

  Future<List<Order>> getMyOrders({int page = 1, int limit = 10}) async {
    try {
      final token = await _storageService.getToken();
      final response = await _apiClient.dio.get(
        '/orders/my-orders',
        queryParameters: {
          'page': page,
          'limit': limit,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      final List<dynamic> ordersData = response.data['orders'];
      return ordersData.map((json) => Order.fromJson(json)).toList();
    } catch (e) {
      throw Exception('فشل في جلب الطلبات: ${e.toString()}');
    }
  }

  Future<Order> getOrderById(String orderId) async {
    try {
      final token = await _storageService.getToken();
      final response = await _apiClient.dio.get(
        '/orders/$orderId',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      return Order.fromJson(response.data);
    } catch (e) {
      throw Exception('فشل في جلب تفاصيل الطلب: ${e.toString()}');
    }
  }

  Future<Order> createOrder(CreateOrderDto orderData) async {
    try {
      final token = await _storageService.getToken();
      final response = await _apiClient.dio.post(
        '/orders',
        data: orderData.toJson(),
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      return Order.fromJson(response.data);
    } catch (e) {
      throw Exception('فشل في إنشاء الطلب: ${e.toString()}');
    }
  }

  Future<Order> updateOrder(
      String orderId, Map<String, dynamic> updateData) async {
    try {
      final token = await _storageService.getToken();
      final response = await _apiClient.dio.patch(
        '/orders/$orderId',
        data: updateData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      return Order.fromJson(response.data);
    } catch (e) {
      throw Exception('فشل في تحديث الطلب: ${e.toString()}');
    }
  }

  Future<void> cancelOrder(String orderId) async {
    try {
      final token = await _storageService.getToken();
      await _apiClient.dio.delete(
        '/orders/$orderId',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );
    } catch (e) {
      throw Exception('فشل في إلغاء الطلب: ${e.toString()}');
    }
  }

  // For chefs - get orders assigned to them
  Future<List<Order>> getChefOrders({int page = 1, int limit = 10}) async {
    try {
      final token = await _storageService.getToken();
      final response = await _apiClient.dio.get(
        '/orders/chef-orders',
        queryParameters: {
          'page': page,
          'limit': limit,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      final List<dynamic> ordersData = response.data['orders'];
      return ordersData.map((json) => Order.fromJson(json)).toList();
    } catch (e) {
      throw Exception('فشل في جلب طلبات الشيف: ${e.toString()}');
    }
  }
}

// DTO classes for order creation
class CreateOrderItemDto {
  final String recipeId;
  final int quantity;
  final String? specialInstructions;

  CreateOrderItemDto({
    required this.recipeId,
    required this.quantity,
    this.specialInstructions,
  });

  Map<String, dynamic> toJson() {
    return {
      'recipeId': recipeId,
      'quantity': quantity,
      if (specialInstructions != null)
        'specialInstructions': specialInstructions,
    };
  }
}

class CreateOrderDto {
  final String chefId;
  final List<CreateOrderItemDto> items;
  final double subtotal;
  final double deliveryFee;
  final double serviceFee;
  final double totalAmount;
  final String currency;
  final Map<String, dynamic> deliveryAddress;
  final String? deliveryInstructions;
  final String? paymentMethod;

  CreateOrderDto({
    required this.chefId,
    required this.items,
    required this.subtotal,
    required this.deliveryFee,
    required this.serviceFee,
    required this.totalAmount,
    this.currency = 'EGP',
    required this.deliveryAddress,
    this.deliveryInstructions,
    this.paymentMethod,
  });

  Map<String, dynamic> toJson() {
    return {
      'chefId': chefId,
      'items': items.map((item) => item.toJson()).toList(),
      'subtotal': subtotal,
      'deliveryFee': deliveryFee,
      'serviceFee': serviceFee,
      'totalAmount': totalAmount,
      'currency': currency,
      'deliveryAddress': deliveryAddress,
      if (deliveryInstructions != null)
        'deliveryInstructions': deliveryInstructions,
      if (paymentMethod != null) 'paymentMethod': paymentMethod,
    };
  }
}
