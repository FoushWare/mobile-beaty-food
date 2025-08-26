import 'recipe.dart';

class CartItem {
  final String id;
  final Recipe recipe;
  final int quantity;
  final String? specialInstructions;
  final DateTime addedAt;

  CartItem({
    required this.id,
    required this.recipe,
    required this.quantity,
    this.specialInstructions,
    required this.addedAt,
  });

  double get totalPrice => recipe.price * quantity;

  CartItem copyWith({
    String? id,
    Recipe? recipe,
    int? quantity,
    String? specialInstructions,
    DateTime? addedAt,
  }) {
    return CartItem(
      id: id ?? this.id,
      recipe: recipe ?? this.recipe,
      quantity: quantity ?? this.quantity,
      specialInstructions: specialInstructions ?? this.specialInstructions,
      addedAt: addedAt ?? this.addedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'recipe': recipe.toJson(),
      'quantity': quantity,
      'specialInstructions': specialInstructions,
      'addedAt': addedAt.toIso8601String(),
    };
  }

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'],
      recipe: Recipe.fromJson(json['recipe']),
      quantity: json['quantity'],
      specialInstructions: json['specialInstructions'],
      addedAt: DateTime.parse(json['addedAt']),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CartItem && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
