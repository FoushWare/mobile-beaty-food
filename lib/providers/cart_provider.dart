import 'package:flutter/foundation.dart';
import 'package:baty_bites/models/recipe.dart';
import 'package:baty_bites/models/order.dart';
import 'package:baty_bites/core/constants/app_constants.dart';

class CartProvider extends ChangeNotifier {
  final List<CartItem> _items = [];

  List<CartItem> get items => _items;
  
  int get itemCount => _items.fold(0, (sum, item) => sum + item.quantity);
  
  double get subtotal => _items.fold(0, (sum, item) => sum + item.total);
  
  double get deliveryFee => subtotal >= AppConstants.freeDeliveryMinimum 
      ? 0.0 
      : AppConstants.defaultDeliveryFee;
  
  double get total => subtotal + deliveryFee;
  
  bool get isEmpty => _items.isEmpty;
  bool get isNotEmpty => _items.isNotEmpty;

  void addItem(Recipe recipe, {int quantity = 1, String? specialInstructions}) {
    final existingIndex = _items.indexWhere((item) => item.recipe.id == recipe.id);
    
    if (existingIndex >= 0) {
      // Update existing item
      _items[existingIndex] = _items[existingIndex].copyWith(
        quantity: _items[existingIndex].quantity + quantity,
        specialInstructions: specialInstructions ?? _items[existingIndex].specialInstructions,
      );
    } else {
      // Add new item
      _items.add(CartItem(
        recipe: recipe,
        quantity: quantity,
        specialInstructions: specialInstructions,
      ));
    }
    
    notifyListeners();
  }

  void removeItem(String recipeId) {
    _items.removeWhere((item) => item.recipe.id == recipeId);
    notifyListeners();
  }

  void updateQuantity(String recipeId, int quantity) {
    if (quantity <= 0) {
      removeItem(recipeId);
      return;
    }

    final index = _items.indexWhere((item) => item.recipe.id == recipeId);
    if (index >= 0) {
      _items[index] = _items[index].copyWith(quantity: quantity);
      notifyListeners();
    }
  }

  void updateSpecialInstructions(String recipeId, String? instructions) {
    final index = _items.indexWhere((item) => item.recipe.id == recipeId);
    if (index >= 0) {
      _items[index] = _items[index].copyWith(specialInstructions: instructions);
      notifyListeners();
    }
  }

  CartItem? getItem(String recipeId) {
    try {
      return _items.firstWhere((item) => item.recipe.id == recipeId);
    } catch (e) {
      return null;
    }
  }

  int getQuantity(String recipeId) {
    final item = getItem(recipeId);
    return item?.quantity ?? 0;
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }

  bool hasItem(String recipeId) {
    return _items.any((item) => item.recipe.id == recipeId);
  }

  // Calculate delivery fee based on distance (future implementation)
  double calculateDeliveryFee(double? distance) {
    if (subtotal >= AppConstants.freeDeliveryMinimum) {
      return 0.0;
    }
    
    if (distance == null || distance <= 5.0) {
      return AppConstants.defaultDeliveryFee;
    } else if (distance <= 10.0) {
      return AppConstants.defaultDeliveryFee * 1.5;
    } else {
      return AppConstants.defaultDeliveryFee * 2.0;
    }
  }

  // Validate cart before checkout
  bool validateCart() {
    return _items.isNotEmpty && _items.every((item) => 
      item.recipe.isAvailable && item.quantity > 0
    );
  }

  // Get cart summary for display
  Map<String, dynamic> getCartSummary() {
    final chefGroups = <String, List<CartItem>>{};
    
    for (final item in _items) {
      final chefId = item.recipe.chefId;
      if (!chefGroups.containsKey(chefId)) {
        chefGroups[chefId] = [];
      }
      chefGroups[chefId]!.add(item);
    }
    
    return {
      'itemCount': itemCount,
      'subtotal': subtotal,
      'deliveryFee': deliveryFee,
      'total': total,
      'chefCount': chefGroups.length,
      'chefGroups': chefGroups,
    };
  }
}