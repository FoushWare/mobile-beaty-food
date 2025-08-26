import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/cart_item.dart';
import '../models/recipe.dart';

class CartNotifier extends StateNotifier<List<CartItem>> {
  CartNotifier() : super([]);

  void addItem(Recipe recipe, {int quantity = 1, String? specialInstructions}) {
    final existingIndex = state.indexWhere((item) =>
        item.recipe.id == recipe.id &&
        item.specialInstructions == specialInstructions);

    if (existingIndex != -1) {
      // Update existing item
      final existingItem = state[existingIndex];
      final updatedItem = existingItem.copyWith(
        quantity: existingItem.quantity + quantity,
      );

      final newState = List<CartItem>.from(state);
      newState[existingIndex] = updatedItem;
      state = newState;
    } else {
      // Add new item
      final newItem = CartItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        recipe: recipe,
        quantity: quantity,
        specialInstructions: specialInstructions,
        addedAt: DateTime.now(),
      );
      state = [...state, newItem];
    }
  }

  void removeItem(String itemId) {
    state = state.where((item) => item.id != itemId).toList();
  }

  void updateQuantity(String itemId, int newQuantity) {
    if (newQuantity <= 0) {
      removeItem(itemId);
      return;
    }

    final newState = state.map((item) {
      if (item.id == itemId) {
        return item.copyWith(quantity: newQuantity);
      }
      return item;
    }).toList();

    state = newState;
  }

  void updateSpecialInstructions(String itemId, String? specialInstructions) {
    final newState = state.map((item) {
      if (item.id == itemId) {
        return item.copyWith(specialInstructions: specialInstructions);
      }
      return item;
    }).toList();

    state = newState;
  }

  void clearCart() {
    state = [];
  }

  double get subtotal {
    return state.fold(0.0, (sum, item) => sum + item.totalPrice);
  }

  double get deliveryFee {
    // Calculate delivery fee based on subtotal or distance
    if (subtotal >= 100) return 0.0; // Free delivery for orders over 100 EGP
    return 15.0; // Standard delivery fee
  }

  double get serviceFee {
    // Calculate service fee (e.g., 5% of subtotal)
    return subtotal * 0.05;
  }

  double get total {
    return subtotal + deliveryFee + serviceFee;
  }

  int get itemCount {
    return state.fold(0, (sum, item) => sum + item.quantity);
  }

  bool get isEmpty => state.isEmpty;
  bool get isNotEmpty => state.isNotEmpty;
}

final cartProvider = StateNotifierProvider<CartNotifier, List<CartItem>>(
  (ref) => CartNotifier(),
);

// Computed providers
final cartSubtotalProvider = Provider<double>((ref) {
  final cart = ref.watch(cartProvider);
  return cart.fold(0.0, (sum, item) => sum + item.totalPrice);
});

final cartDeliveryFeeProvider = Provider<double>((ref) {
  final subtotal = ref.watch(cartSubtotalProvider);
  if (subtotal >= 100) return 0.0;
  return 15.0;
});

final cartServiceFeeProvider = Provider<double>((ref) {
  final subtotal = ref.watch(cartSubtotalProvider);
  return subtotal * 0.05;
});

final cartTotalProvider = Provider<double>((ref) {
  final subtotal = ref.watch(cartSubtotalProvider);
  final deliveryFee = ref.watch(cartDeliveryFeeProvider);
  final serviceFee = ref.watch(cartServiceFeeProvider);
  return subtotal + deliveryFee + serviceFee;
});

final cartItemCountProvider = Provider<int>((ref) {
  final cart = ref.watch(cartProvider);
  return cart.fold(0, (sum, item) => sum + item.quantity);
});
