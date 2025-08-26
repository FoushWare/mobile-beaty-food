import 'recipe.dart';

class Favorite {
  final String id;
  final String userId;
  final String recipeId;
  final Recipe recipe;
  final DateTime createdAt;

  const Favorite({
    required this.id,
    required this.userId,
    required this.recipeId,
    required this.recipe,
    required this.createdAt,
  });

  factory Favorite.fromJson(Map<String, dynamic> json) {
    return Favorite(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      recipeId: json['recipeId'] ?? '',
      recipe: Recipe.fromJson(json['recipe'] ?? {}),
      createdAt:
          DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'recipeId': recipeId,
      'recipe': recipe.toJson(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  Favorite copyWith({
    String? id,
    String? userId,
    String? recipeId,
    Recipe? recipe,
    DateTime? createdAt,
  }) {
    return Favorite(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      recipeId: recipeId ?? this.recipeId,
      recipe: recipe ?? this.recipe,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
