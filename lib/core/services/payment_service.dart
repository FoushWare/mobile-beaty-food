import 'package:dio/dio.dart';
import '../utils/api_client.dart';
import '../utils/storage_service.dart';
import '../../models/payment.dart';

class PaymentService {
  final ApiClient _apiClient = ApiClient();
  final StorageService _storageService = StorageService();

  Future<Map<String, dynamic>> _getHeaders() async {
    final token = await _storageService.getToken();
    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
  }

  Future<PaymentResponse> processPayment(PaymentRequest request) async {
    try {
      final headers = await _getHeaders();
      final response = await _apiClient.dio.post(
        '/payments/process',
        data: request.toJson(),
        options: Options(headers: headers),
      );

      return PaymentResponse.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to process payment: ${e.toString()}');
    }
  }

  Future<List<PaymentMethod>> getPaymentMethods() async {
    try {
      final response = await _apiClient.dio.get('/payments/methods');
      final List<dynamic> data = response.data;
      return data.map((json) => PaymentMethod.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to get payment methods: ${e.toString()}');
    }
  }

  Future<Map<String, dynamic>> getPaymentHistory({
    int page = 1,
    int limit = 10,
    String? status,
  }) async {
    try {
      final headers = await _getHeaders();
      final queryParameters = {
        'page': page.toString(),
        'limit': limit.toString(),
        if (status != null) 'status': status,
      };

      final response = await _apiClient.dio.get(
        '/payments/history',
        queryParameters: queryParameters,
        options: Options(headers: headers),
      );

      return response.data;
    } catch (e) {
      throw Exception('Failed to get payment history: ${e.toString()}');
    }
  }

  Future<Payment> getPaymentById(String paymentId) async {
    try {
      final headers = await _getHeaders();
      final response = await _apiClient.dio.get(
        '/payments/$paymentId',
        options: Options(headers: headers),
      );

      return Payment.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to get payment: ${e.toString()}');
    }
  }

  Future<Map<String, dynamic>> getPaymentStatus(String paymentId) async {
    try {
      final headers = await _getHeaders();
      final response = await _apiClient.dio.get(
        '/payments/$paymentId/status',
        options: Options(headers: headers),
      );

      return response.data;
    } catch (e) {
      throw Exception('Failed to get payment status: ${e.toString()}');
    }
  }

  Future<Map<String, dynamic>> requestRefund(
    String paymentId,
    double amount,
    String reason,
  ) async {
    try {
      final headers = await _getHeaders();
      final response = await _apiClient.dio.post(
        '/payments/$paymentId/refund',
        data: {
          'amount': amount,
          'reason': reason,
        },
        options: Options(headers: headers),
      );

      return response.data;
    } catch (e) {
      throw Exception('Failed to request refund: ${e.toString()}');
    }
  }

  Future<PaymentMethod> savePaymentMethod(
      Map<String, dynamic> methodData) async {
    try {
      final headers = await _getHeaders();
      final response = await _apiClient.dio.post(
        '/payments/methods',
        data: methodData,
        options: Options(headers: headers),
      );

      return PaymentMethod.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to save payment method: ${e.toString()}');
    }
  }

  Future<List<PaymentMethod>> getSavedPaymentMethods() async {
    try {
      final headers = await _getHeaders();
      final response = await _apiClient.dio.get(
        '/payments/methods/saved',
        options: Options(headers: headers),
      );

      final List<dynamic> data = response.data;
      return data.map((json) => PaymentMethod.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to get saved payment methods: ${e.toString()}');
    }
  }

  Future<bool> deletePaymentMethod(String methodId) async {
    try {
      final headers = await _getHeaders();
      await _apiClient.dio.delete(
        '/payments/methods/$methodId',
        options: Options(headers: headers),
      );

      return true;
    } catch (e) {
      throw Exception('Failed to delete payment method: ${e.toString()}');
    }
  }

  Future<bool> validatePaymentMethod(Map<String, dynamic> methodData) async {
    try {
      final headers = await _getHeaders();
      final response = await _apiClient.dio.post(
        '/payments/methods/validate',
        data: methodData,
        options: Options(headers: headers),
      );

      return response.data['valid'] ?? false;
    } catch (e) {
      throw Exception('Failed to validate payment method: ${e.toString()}');
    }
  }
}
