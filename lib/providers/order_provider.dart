import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/order.dart';
import '../core/services/order_service.dart';

class OrderState {
  final List<Order> orders;
  final Order? selectedOrder;
  final bool isLoading;
  final String? error;

  OrderState({
    this.orders = const [],
    this.selectedOrder,
    this.isLoading = false,
    this.error,
  });

  OrderState copyWith({
    List<Order>? orders,
    Order? selectedOrder,
    bool? isLoading,
    String? error,
  }) {
    return OrderState(
      orders: orders ?? this.orders,
      selectedOrder: selectedOrder ?? this.selectedOrder,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class OrderNotifier extends StateNotifier<OrderState> {
  final OrderService _orderService = OrderService();

  OrderNotifier() : super(OrderState());

  Future<void> getMyOrders({int page = 1, int limit = 10}) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final orders = await _orderService.getMyOrders(page: page, limit: limit);
      state = state.copyWith(
        orders: orders,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> getOrderById(String orderId) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final order = await _orderService.getOrderById(orderId);
      state = state.copyWith(
        selectedOrder: order,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> createOrder(CreateOrderDto orderData) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final order = await _orderService.createOrder(orderData);
      state = state.copyWith(
        orders: [order, ...state.orders],
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> updateOrder(
      String orderId, Map<String, dynamic> updateData) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final updatedOrder = await _orderService.updateOrder(orderId, updateData);

      // Update in orders list
      final updatedOrders = state.orders.map((order) {
        if (order.id == orderId) {
          return updatedOrder;
        }
        return order;
      }).toList();

      // Update selected order if it's the same
      Order? updatedSelectedOrder = state.selectedOrder;
      if (state.selectedOrder?.id == orderId) {
        updatedSelectedOrder = updatedOrder;
      }

      state = state.copyWith(
        orders: updatedOrders,
        selectedOrder: updatedSelectedOrder,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> cancelOrder(String orderId) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      await _orderService.cancelOrder(orderId);

      // Update order status in list
      final updatedOrders = state.orders.map((order) {
        if (order.id == orderId) {
          return order.copyWith(status: 'cancelled');
        }
        return order;
      }).toList();

      // Update selected order if it's the same
      Order? updatedSelectedOrder = state.selectedOrder;
      if (state.selectedOrder?.id == orderId) {
        updatedSelectedOrder =
            state.selectedOrder!.copyWith(status: 'cancelled');
      }

      state = state.copyWith(
        orders: updatedOrders,
        selectedOrder: updatedSelectedOrder,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> getChefOrders({int page = 1, int limit = 10}) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final orders =
          await _orderService.getChefOrders(page: page, limit: limit);
      state = state.copyWith(
        orders: orders,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  void clearSelectedOrder() {
    state = state.copyWith(selectedOrder: null);
  }
}

final orderProvider = StateNotifierProvider<OrderNotifier, OrderState>(
  (ref) => OrderNotifier(),
);
