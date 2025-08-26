import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/services/payment_service.dart';
import '../models/payment.dart';

class PaymentState {
  final List<Payment> paymentHistory;
  final Payment? currentPayment;
  final List<PaymentMethod> savedMethods;
  final bool isLoading;
  final String? error;

  const PaymentState({
    this.paymentHistory = const [],
    this.currentPayment,
    this.savedMethods = const [],
    this.isLoading = false,
    this.error,
  });

  PaymentState copyWith({
    List<Payment>? paymentHistory,
    Payment? currentPayment,
    List<PaymentMethod>? savedMethods,
    bool? isLoading,
    String? error,
  }) {
    return PaymentState(
      paymentHistory: paymentHistory ?? this.paymentHistory,
      currentPayment: currentPayment ?? this.currentPayment,
      savedMethods: savedMethods ?? this.savedMethods,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class PaymentNotifier extends StateNotifier<PaymentState> {
  final PaymentService _paymentService = PaymentService();

  PaymentNotifier() : super(const PaymentState());

  /// Load payment history
  Future<void> loadPaymentHistory({
    int page = 1,
    int limit = 10,
    String? status,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await _paymentService.getPaymentHistory(
        page: page,
        limit: limit,
        status: status,
      );

      // Parse the response to extract payment list
      final List<dynamic> paymentsData = response['data'] ?? [];
      final List<Payment> history =
          paymentsData.map((data) => Payment.fromJson(data)).toList();

      // If it's the first page, replace the list, otherwise append
      final updatedHistory =
          page == 1 ? history : [...state.paymentHistory, ...history];

      state = state.copyWith(
        paymentHistory: updatedHistory,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Process a payment
  Future<PaymentResponse?> processPayment(PaymentRequest request) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await _paymentService.processPayment(request);

      if (response.success) {
        // Load the payment details
        await loadPaymentById(response.paymentId!);
      }

      state = state.copyWith(isLoading: false);
      return response;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return null;
    }
  }

  /// Load payment by ID
  Future<void> loadPaymentById(String paymentId) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final payment = await _paymentService.getPaymentById(paymentId);
      state = state.copyWith(
        currentPayment: payment,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Request a refund
  Future<PaymentResponse?> requestRefund(
    String paymentId,
    double amount,
    String reason,
  ) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await _paymentService.requestRefund(
        paymentId,
        amount,
        reason,
      );

      // Create a PaymentResponse from the map response
      final paymentResponse = PaymentResponse(
        success: response['success'] ?? false,
        message: response['message'] ?? '',
        paymentId: response['paymentId'],
        status: response['status'],
      );

      if (paymentResponse.success) {
        // Reload the payment to get updated status
        await loadPaymentById(paymentId);
        // Reload payment history
        await loadPaymentHistory();
      }

      state = state.copyWith(isLoading: false);
      return paymentResponse;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return null;
    }
  }

  /// Save payment method
  Future<void> savePaymentMethod(Map<String, dynamic> methodData) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final method = await _paymentService.savePaymentMethod(methodData);
      state = state.copyWith(
        savedMethods: [...state.savedMethods, method],
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Load saved payment methods
  Future<void> loadSavedPaymentMethods() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final methods = await _paymentService.getSavedPaymentMethods();
      state = state.copyWith(
        savedMethods: methods,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Delete payment method
  Future<void> deletePaymentMethod(String methodId) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      await _paymentService.deletePaymentMethod(methodId);
      state = state.copyWith(
        savedMethods: state.savedMethods
            .where((method) => method.id != methodId)
            .toList(),
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Get payment status
  Future<PaymentStatus?> getPaymentStatus(String paymentId) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await _paymentService.getPaymentStatus(paymentId);

      // Parse the status from the response
      final statusString = response['status'];
      if (statusString != null) {
        final status = PaymentStatus.values.firstWhere(
          (status) => status.name == statusString,
          orElse: () => PaymentStatus.pending,
        );

        state = state.copyWith(isLoading: false);
        return status;
      }

      state = state.copyWith(isLoading: false);
      return null;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return null;
    }
  }

  /// Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }
}

// Provider
final paymentProvider =
    StateNotifierProvider<PaymentNotifier, PaymentState>((ref) {
  return PaymentNotifier();
});
